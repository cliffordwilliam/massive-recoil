package main

import (
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"time"
)

var uidRe = regexp.MustCompile(`uid="([^"]+)"`)

// getTresUID returns the UID from the committed .tres in git, or requests a fresh one from Godot.
func getTresUID(key string) string {
	if gitRoot != "" {
		tresAbs := filepath.Join(outputDir, key+".tres")
		rel, err := filepath.Rel(gitRoot, tresAbs)
		if err == nil && !strings.HasPrefix(rel, "..") {
			out, err := exec.Command("git", "show", "HEAD:"+filepath.ToSlash(rel)).Output()
			if err == nil {
				if m := uidRe.FindSubmatch(out); m != nil {
					return string(m[1])
				}
			}
		}
	}
	return requestNewUID()
}

// getPNGUID reads the UID from the .png.import file written by Godot after a previous scan.
func getPNGUID(key string) string {
	data, err := os.ReadFile(filepath.Join(outputDir, key+".png.import"))
	if err != nil {
		return ""
	}
	if m := uidRe.Find(data); m != nil {
		if n := uidRe.FindSubmatch(data); n != nil {
			return string(n[1])
		}
	}
	return ""
}

// resPath converts an absolute PNG path to a Godot res:// path.
func resPath(absPath string) string {
	if projectRoot != "" {
		rel, err := filepath.Rel(projectRoot, absPath)
		if err == nil && !strings.HasPrefix(rel, "..") {
			return "res://" + filepath.ToSlash(rel)
		}
	}
	return "res://assets/images/dynamic/" + filepath.Base(absPath)
}

// godotSend opens a TCP connection to Godot, sends a message, and optionally reads a response.
func godotSend(message string, expectResponse bool) string {
	timeout := 5 * time.Second
	if expectResponse {
		timeout = 30 * time.Second
	}

	conn, err := net.DialTimeout("tcp", fmt.Sprintf("127.0.0.1:%d", port), timeout)
	if err != nil {
		fmt.Printf("[ase] Socket error: %v\n", err)
		return ""
	}
	defer conn.Close()

	conn.SetDeadline(time.Now().Add(timeout))
	conn.Write([]byte(message + "\n"))

	if !expectResponse {
		return ""
	}

	buf := make([]byte, 0, 256)
	tmp := make([]byte, 256)
	for {
		n, err := conn.Read(tmp)
		if n > 0 {
			buf = append(buf, tmp[:n]...)
		}
		if strings.Contains(string(buf), "\n") || err != nil {
			break
		}
	}
	return strings.TrimSpace(string(buf))
}

func requestNewUID() string {
	return godotSend("new_uid", true)
}

func triggerScanAndReload(keys []string) {
	godotSend("scan_and_reload:"+strings.Join(keys, ":"), false)
}
