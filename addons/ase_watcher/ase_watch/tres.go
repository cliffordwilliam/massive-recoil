package main

import (
	"encoding/json"
	"fmt"
	"math"
	"os"
	"path/filepath"
	"strings"
)

// fmtFloat formats a float for .tres output — always includes a decimal point,
// strips trailing zeros, but keeps at least one digit after the point.
func fmtFloat(v float64) string {
	v = math.Round(v*1e6) / 1e6
	if v == math.Trunc(v) {
		return fmt.Sprintf("%d.0", int64(v))
	}
	s := strings.TrimRight(fmt.Sprintf("%.6f", v), "0")
	if strings.HasSuffix(s, ".") {
		return s + "0"
	}
	return s
}

// ── Animation types ───────────────────────────────────────────────────────────

type aseRect struct {
	X, Y, W, H int
}

type aseFrame struct {
	Frame    aseRect
	Duration float64
}

type animation struct {
	Name   string
	Frames []animFrame
	Loop   bool
	Speed  float64
}

type animFrame struct {
	Rect     aseRect
	Duration float64
}

// buildAnimation converts raw Aseprite frames + tag metadata into an animation ready for .tres output.
func buildAnimation(name string, raw []aseFrame, loop bool, direction string, repeat int) animation {
	if len(raw) == 0 {
		return animation{Name: name, Loop: loop, Speed: 1.0}
	}

	minMs := raw[0].Duration
	for _, f := range raw[1:] {
		if f.Duration < minMs {
			minMs = f.Duration
		}
	}
	speed := math.Ceil(1000.0 / minMs)

	ordered := make([]aseFrame, len(raw))
	copy(ordered, raw)
	if direction == "reverse" || direction == "pingpong_reverse" {
		for i, j := 0, len(ordered)-1; i < j; i, j = i+1, j-1 {
			ordered[i], ordered[j] = ordered[j], ordered[i]
		}
	}

	passes := repeat
	if passes < 1 {
		passes = 1
	}

	var out []animFrame
	for range passes {
		for _, f := range ordered {
			out = append(out, animFrame{
				Rect:     f.Frame,
				Duration: math.Round(f.Duration/minMs*1e6) / 1e6,
			})
		}
		if (direction == "pingpong" || direction == "pingpong_reverse") && len(ordered) > 1 {
			mid := ordered[1 : len(ordered)-1]
			for i := len(mid) - 1; i >= 0; i-- {
				out = append(out, animFrame{
					Rect:     mid[i].Frame,
					Duration: math.Round(mid[i].Duration/minMs*1e6) / 1e6,
				})
			}
		}
	}

	return animation{Name: name, Frames: out, Loop: loop, Speed: speed}
}

// ── JSON shape from Aseprite ──────────────────────────────────────────────────

type aseJSON struct {
	Frames []struct {
		Frame    struct{ X, Y, W, H int }
		Duration float64
	}
	Meta struct {
		FrameTags []struct {
			Name      string
			From, To  int
			Direction string
			Repeat    string
		}
	}
}

// ── .tres writer ─────────────────────────────────────────────────────────────

func writeTres(key, tresUID, pngUID string) bool {
	jsonPath := filepath.Join(outputDir, key+".json")
	data, err := os.ReadFile(jsonPath)
	if err != nil {
		return false
	}

	var aj aseJSON
	if err := json.Unmarshal(data, &aj); err != nil {
		fmt.Printf("[ase] JSON parse error for %s: %v\n", key, err)
		return false
	}

	// Convert raw frames
	raw := make([]aseFrame, len(aj.Frames))
	for i, f := range aj.Frames {
		raw[i] = aseFrame{
			Frame:    aseRect{f.Frame.X, f.Frame.Y, f.Frame.W, f.Frame.H},
			Duration: f.Duration,
		}
	}

	// Build animations
	var anims []animation
	if len(aj.Meta.FrameTags) > 0 {
		for _, t := range aj.Meta.FrameTags {
			repeat := 0
			fmt.Sscanf(t.Repeat, "%d", &repeat)
			slice := raw[t.From : t.To+1]
			anims = append(anims, buildAnimation(t.Name, slice, repeat == 0, t.Direction, repeat))
		}
	} else {
		anims = []animation{buildAnimation("default", raw, true, "forward", 0)}
	}

	// Assign sequential AtlasTexture IDs
	type atlasEntry struct {
		id   string
		rect aseRect
	}
	type animRef struct {
		anim animation
		refs []struct {
			id       string
			duration float64
		}
	}

	counter := 0
	var atlasList []atlasEntry
	var animRefs []animRef

	for _, anim := range anims {
		ar := animRef{anim: anim}
		for _, frame := range anim.Frames {
			counter++
			id := fmt.Sprintf("AtlasTexture_%d", counter)
			atlasList = append(atlasList, atlasEntry{id, frame.Rect})
			ar.refs = append(ar.refs, struct {
				id       string
				duration float64
			}{id, frame.Duration})
		}
		animRefs = append(animRefs, ar)
	}

	// Build file content
	pngResPath := resPath(filepath.Join(outputDir, key+".png"))
	uidAttr := ""
	if pngUID != "" {
		uidAttr = fmt.Sprintf(` uid="%s"`, pngUID)
	}

	var sb strings.Builder
	fmt.Fprintf(&sb, "[gd_resource type=\"SpriteFrames\" format=3 uid=\"%s\"]\n\n", tresUID)
	fmt.Fprintf(&sb, "[ext_resource type=\"Texture2D\"%s path=\"%s\" id=\"1\"]\n\n", uidAttr, pngResPath)

	for _, a := range atlasList {
		fmt.Fprintf(&sb, "[sub_resource type=\"AtlasTexture\" id=\"%s\"]\n", a.id)
		fmt.Fprintf(&sb, "atlas = ExtResource(\"1\")\n")
		fmt.Fprintf(&sb, "region = Rect2(%d, %d, %d, %d)\n\n", a.rect.X, a.rect.Y, a.rect.W, a.rect.H)
	}

	var animBlocks []string
	for _, ar := range animRefs {
		var frameParts []string
		for _, ref := range ar.refs {
			frameParts = append(frameParts, fmt.Sprintf(
				`{"duration": %s, "texture": SubResource("%s")}`,
				fmtFloat(ref.duration), ref.id,
			))
		}
		loopStr := "false"
		if ar.anim.Loop {
			loopStr = "true"
		}
		animBlocks = append(animBlocks, fmt.Sprintf(
			"{\n\"frames\": [%s],\n\"loop\": %s,\n\"name\": &\"%s\",\n\"speed\": %s\n}",
			strings.Join(frameParts, ", "),
			loopStr,
			ar.anim.Name,
			fmtFloat(ar.anim.Speed),
		))
	}

	fmt.Fprintf(&sb, "[resource]\nanimations = [%s]\n", strings.Join(animBlocks, ", "))

	if err := os.WriteFile(filepath.Join(outputDir, key+".tres"), []byte(sb.String()), 0644); err != nil {
		fmt.Printf("[ase] Failed to write %s.tres: %v\n", key, err)
		return false
	}

	fmt.Printf("[ase] Wrote %s.tres (%d frames, %d animations)\n", key, len(atlasList), len(anims))
	return true
}
