package main

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/fsnotify/fsnotify"
)

const debounceMs = 3000

var (
	watchDir    string
	outputDir   string
	port        int
	projectRoot string // absolute path to dir containing project.godot, or ""
	gitRoot     string // absolute path to git repo root, or ""

	logWriter io.Writer = os.Stdout
)

func logf(format string, args ...any) {
	msg := fmt.Sprintf(format, args...)
	fmt.Fprint(logWriter, msg)
}

func findProjectRoot(start string) string {
	dir := start
	for {
		if _, err := os.Stat(filepath.Join(dir, "project.godot")); err == nil {
			return dir
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return ""
		}
		dir = parent
	}
}

func findGitRoot(start string) string {
	out, err := exec.Command("git", "rev-parse", "--show-toplevel").
		Output()
	if err != nil {
		return ""
	}
	_ = start
	return strings.TrimSpace(string(out))
}

func main() {
	if len(os.Args) < 3 {
		fmt.Fprintln(os.Stderr, "usage: ase_watch <watch_dir> <output_dir> [port]")
		os.Exit(1)
	}

	watchDir = os.Args[1]
	outputDir = os.Args[2]
	port = 9876

	if len(os.Args) > 3 {
		p, err := strconv.Atoi(os.Args[3])
		if err != nil {
			fmt.Fprintln(os.Stderr, "invalid port:", os.Args[3])
			os.Exit(1)
		}
		port = p
	}

	projectRoot = findProjectRoot(outputDir)
	gitRoot = findGitRoot(outputDir)

	logPath := filepath.Join(outputDir, "ase_watch.log")
	f, err := os.OpenFile(logPath, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)
	if err == nil {
		logWriter = io.MultiWriter(os.Stdout, f)
		defer f.Close()
	} else {
		fmt.Fprintf(os.Stderr, "[ase] Could not open log file %s: %v\n", logPath, err)
	}

	logf("[ase] Starting (pid %d)\n", os.Getpid())
	logf("[ase] watch_dir=%s output_dir=%s port=%d\n", watchDir, outputDir, port)

	watch()
}

var aseExt = regexp.MustCompile(`\.(ase|aseprite)$`)

func watch() {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		fmt.Fprintln(os.Stderr, "[ase] Failed to create watcher:", err)
		os.Exit(1)
	}
	defer watcher.Close()

	if err := watcher.Add(watchDir); err != nil {
		logf("[ase] Failed to watch directory: %v\n", err)
		os.Exit(1)
	}

	logf("[ase] Watching %s\n", watchDir)

	lastSeen := make(map[string]int64)

	for {
		select {
		case event, ok := <-watcher.Events:
			if !ok {
				return
			}
			if event.Op&(fsnotify.Write|fsnotify.Create) == 0 {
				continue
			}
			fname := filepath.Base(event.Name)
			if !aseExt.MatchString(fname) {
				continue
			}
			nowMs := time.Now().UnixMilli()
			if nowMs-lastSeen[fname] < debounceMs {
				continue
			}
			lastSeen[fname] = nowMs
			handleChange(fname)

		case err, ok := <-watcher.Errors:
			if !ok {
				return
			}
			logf("[ase] Watcher error: %v\n", err)
		}
	}
}

func safeKey(layer string) string {
	r := strings.NewReplacer("/", "_", " ", "_")
	return r.Replace(layer)
}

func handleChange(fname string) {
	base := strings.TrimSuffix(fname, filepath.Ext(fname))
	asePath := filepath.Join(watchDir, fname)
	logf("[ase] %s changed — exporting layers…\n", base)

	layers := listLayers(asePath)
	if len(layers) == 0 {
		logf("[ase] No layers found for %s\n", base)
		return
	}

	type layerKey struct{ layer, key string }
	pairs := make([]layerKey, len(layers))
	newKeys := make(map[string]bool, len(layers))
	for i, layer := range layers {
		key := base + "_" + safeKey(layer)
		pairs[i] = layerKey{layer, key}
		newKeys[key] = true
	}

	// Export all layers in parallel
	var mu sync.Mutex
	var wg sync.WaitGroup
	var exported []string

	for _, p := range pairs {
		wg.Add(1)
		go func(layer, key string) {
			defer wg.Done()
			if exportLayer(asePath, layer, key) {
				mu.Lock()
				exported = append(exported, key)
				mu.Unlock()
			}
		}(p.layer, p.key)
	}
	wg.Wait()

	if len(exported) == 0 {
		logf("[ase] All exports failed for %s\n", base)
		return
	}

	// Write .tres files
	var written []string
	for _, key := range exported {
		tresUID := getTresUID(key)
		if tresUID == "" {
			logf("[ase] Could not get UID for %s — skipping\n", key)
			continue
		}
		if writeTres(key, tresUID, getPNGUID(key)) {
			written = append(written, key)
		}
	}

	// Delete JSON handoff files
	for _, key := range exported {
		for _, suffix := range []string{".json", ".json.tmp"} {
			os.Remove(filepath.Join(outputDir, key+suffix))
		}
	}

	// Remove stale outputs for layers no longer in this .ase
	pngs, _ := filepath.Glob(filepath.Join(outputDir, base+"_*.png"))
	for _, png := range pngs {
		stem := strings.TrimSuffix(filepath.Base(png), ".png")
		if !newKeys[stem] {
			os.Remove(png)
			os.Remove(filepath.Join(outputDir, stem+".tres"))
			logf("[ase]   removed stale: %s\n", stem)
		}
	}

	if len(written) > 0 {
		triggerScanAndReload(written)
	}
}
