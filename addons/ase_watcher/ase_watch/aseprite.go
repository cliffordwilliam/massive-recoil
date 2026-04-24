package main

import (
	"os/exec"
	"path/filepath"
	"strings"
)

// listLayers returns all visible, non-private layers in the .ase file.
// Group folders (ending in /) and layers prefixed with _ are skipped.
func listLayers(asePath string) []string {
	out, err := exec.Command(
		"aseprite", "-b", "--all-layers", "--list-layer-hierarchy", asePath,
	).Output()
	if err != nil {
		return nil
	}

	var layers []string
	for _, line := range strings.Split(string(out), "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasSuffix(line, "/") {
			continue
		}
		parts := strings.Split(line, "/")
		if strings.HasPrefix(parts[len(parts)-1], "_") {
			continue
		}
		layers = append(layers, line)
	}
	return layers
}

// exportLayer runs aseprite to export a single layer as a packed sprite sheet + JSON data.
func exportLayer(asePath, layer, key string) bool {
	err := exec.Command(
		"aseprite", "-b",
		"--all-layers",
		"--layer", layer,
		"--list-tags",
		"--data", filepath.Join(outputDir, key+".json"),
		"--format", "json-array",
		"--sheet", filepath.Join(outputDir, key+".png"),
		"--sheet-type", "packed",
		"--merge-duplicates",
		asePath,
	).Run()

	if err == nil {
		logf("[ase]   → %s\n", key)
		return true
	}
	logf("[ase]   ✗ failed: %s\n", layer)
	return false
}
