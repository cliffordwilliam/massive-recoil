#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""
ase_watch.py — watches .ase files and rebuilds per-layer SpriteFrames .tres files.

Usage: ase_watch.py <watch_dir> <output_dir> <port>
Requires: inotify-tools (sudo apt install inotify-tools), aseprite CLI, git
"""

import json
import math
import re
import socket
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


# ── Bootstrap ─────────────────────────────────────────────────────────────────

WATCH_DIR = Path(sys.argv[1])
OUTPUT_DIR = Path(sys.argv[2])
PORT = int(sys.argv[3]) if len(sys.argv) > 3 else 9876
DEBOUNCE_MS = 3000


def _find_project_root(start: Path) -> Path | None:
    for p in [start, *start.parents]:
        if (p / "project.godot").exists():
            return p
    return None


def _find_git_root(start: Path) -> Path | None:
    r = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, cwd=str(start),
    )
    return Path(r.stdout.strip()) if r.returncode == 0 else None


PROJECT_ROOT = _find_project_root(OUTPUT_DIR)
GIT_ROOT = _find_git_root(OUTPUT_DIR)


def _res_path(abs_path: Path) -> str:
    if PROJECT_ROOT:
        try:
            return "res://" + abs_path.relative_to(PROJECT_ROOT).as_posix()
        except ValueError:
            pass
    return "res://assets/images/dynamic/" + abs_path.name


# ── Godot socket helpers ──────────────────────────────────────────────────────


def _godot(message: str, expect_response: bool = False) -> str | None:
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(30 if expect_response else 5)
            s.connect(("127.0.0.1", PORT))
            s.sendall((message + "\n").encode())
            if not expect_response:
                return None
            buf = b""
            while b"\n" not in buf:
                chunk = s.recv(256)
                if not chunk:
                    break
                buf += chunk
            return buf.decode().strip()
    except Exception as e:
        print(f"[ase] Socket error: {e}")
    return None


def request_new_uid() -> str | None:
    """Ask Godot to provision a fresh resource UID."""
    return _godot("new_uid", expect_response=True)


def trigger_scan_and_reload(keys: list[str]) -> None:
    """Tell Godot to scan the filesystem then hot-reload these .tres files."""
    _godot("scan_and_reload:" + ":".join(keys))


# ── UID helpers ───────────────────────────────────────────────────────────────


def get_tres_uid(key: str) -> str | None:
    """Return the committed .tres UID from git, or request a fresh one from Godot."""
    if GIT_ROOT:
        tres_abs = OUTPUT_DIR / (key + ".tres")
        try:
            rel = tres_abs.relative_to(GIT_ROOT)
            r = subprocess.run(
                ["git", "show", f"HEAD:{rel}"],
                capture_output=True, text=True, cwd=str(GIT_ROOT),
            )
            if r.returncode == 0:
                m = re.search(r'uid="([^"]+)"', r.stdout)
                if m:
                    return m.group(1)
        except ValueError:
            pass
    return request_new_uid()


def get_png_uid(key: str) -> str | None:
    """Read the PNG UID from its .import file (written by Godot after a previous scan)."""
    p = OUTPUT_DIR / (key + ".png.import")
    if p.exists():
        m = re.search(r'uid="([^"]+)"', p.read_text())
        return m.group(1) if m else None
    return None


# ── Aseprite helpers ──────────────────────────────────────────────────────────


def list_layers(ase_path: Path) -> list[str]:
    r = subprocess.run(
        ["aseprite", "-b", "--all-layers", "--list-layer-hierarchy", str(ase_path)],
        capture_output=True, text=True,
    )
    layers = []
    for line in r.stdout.splitlines():
        line = line.strip()
        if not line or line.endswith("/"):
            continue
        if not line.split("/")[-1].startswith("_"):
            layers.append(line)
    return layers


def export_layer(ase_path: Path, layer: str, key: str) -> bool:
    r = subprocess.run([
        "aseprite", "-b",
        "--all-layers",
        "--layer", layer,
        "--list-tags",
        "--data", str(OUTPUT_DIR / (key + ".json")),
        "--format", "json-array",
        "--sheet", str(OUTPUT_DIR / (key + ".png")),
        "--sheet-type", "packed",
        "--merge-duplicates",
        str(ase_path),
    ], capture_output=True)
    if r.returncode == 0:
        print(f"[ase]   → {key}")
        return True
    print(f"[ase]   ✗ failed: {layer}")
    return False


# ── .tres writer ──────────────────────────────────────────────────────────────


def _fmt(v: float) -> str:
    """Format a float for .tres output — always includes a decimal point."""
    v = round(v, 6)
    if v == int(v):
        return f"{int(v)}.0"
    s = f"{v:.6f}".rstrip("0")
    return s if not s.endswith(".") else s + "0"


def _build_animation(
    name: str,
    raw_frames: list,
    *,
    loop: bool,
    direction: str,
    repeat: int,
) -> dict:
    if not raw_frames:
        return {"name": name, "frames": [], "loop": loop, "speed": 1.0}

    min_ms = min(float(f["duration"]) for f in raw_frames)
    speed = float(math.ceil(1000.0 / min_ms))

    ordered = list(raw_frames)
    if direction in ("reverse", "pingpong_reverse"):
        ordered = list(reversed(ordered))

    out_frames: list[dict] = []
    for _ in range(max(repeat, 1)):
        for f in ordered:
            out_frames.append({
                "rect": f["frame"],
                "duration": round(float(f["duration"]) / min_ms, 6),
            })
        if direction in ("pingpong", "pingpong_reverse") and len(ordered) > 1:
            for f in list(reversed(ordered))[1:-1]:
                out_frames.append({
                    "rect": f["frame"],
                    "duration": round(float(f["duration"]) / min_ms, 6),
                })

    return {"name": name, "frames": out_frames, "loop": loop, "speed": speed}


def write_tres(key: str, tres_uid: str, png_uid: str | None) -> bool:
    json_path = OUTPUT_DIR / (key + ".json")
    if not json_path.exists():
        return False

    data = json.loads(json_path.read_text())
    raw_frames = data.get("frames", [])
    tags = data.get("meta", {}).get("frameTags", [])

    animations = (
        [
            _build_animation(
                t["name"],
                raw_frames[int(t["from"]): int(t["to"]) + 1],
                loop=int(t.get("repeat", 0)) == 0,
                direction=t.get("direction", "forward"),
                repeat=int(t.get("repeat", 0)),
            )
            for t in tags
        ]
        if tags
        else [_build_animation("default", raw_frames, loop=True, direction="forward", repeat=0)]
    )

    # Assign AtlasTexture IDs and collect all frame references
    counter = 0
    atlas_list: list[tuple[str, dict]] = []
    anim_refs: list[tuple[dict, list[tuple[str, float]]]] = []
    for anim in animations:
        refs: list[tuple[str, float]] = []
        for frame in anim["frames"]:
            counter += 1
            aid = f"AtlasTexture_{counter}"
            atlas_list.append((aid, frame["rect"]))
            refs.append((aid, frame["duration"]))
        anim_refs.append((anim, refs))

    # Header + ext_resource
    png_res = _res_path(OUTPUT_DIR / (key + ".png"))
    uid_attr = f' uid="{png_uid}"' if png_uid else ""
    lines: list[str] = [
        f'[gd_resource type="SpriteFrames" format=3 uid="{tres_uid}"]',
        "",
        f'[ext_resource type="Texture2D"{uid_attr} path="{png_res}" id="1"]',
        "",
    ]

    # AtlasTexture sub-resources
    for aid, r in atlas_list:
        lines += [
            f'[sub_resource type="AtlasTexture" id="{aid}"]',
            'atlas = ExtResource("1")',
            f'region = Rect2({r["x"]}, {r["y"]}, {r["w"]}, {r["h"]})',
            "",
        ]

    # [resource] animations array
    anim_blocks: list[str] = []
    for anim, refs in anim_refs:
        frame_parts = [
            f'{{"duration": {_fmt(d)}, "texture": SubResource("{aid}")}}'
            for aid, d in refs
        ]
        loop_str = "true" if anim["loop"] else "false"
        anim_blocks.append(
            "{\n"
            f'"frames": [{", ".join(frame_parts)}],\n'
            f'"loop": {loop_str},\n'
            f'"name": &"{anim["name"]}",\n'
            f'"speed": {_fmt(anim["speed"])}\n'
            "}"
        )

    lines += [
        "[resource]",
        "animations = [" + ", ".join(anim_blocks) + "]",
        "",
    ]

    (OUTPUT_DIR / (key + ".tres")).write_text("\n".join(lines))
    print(f"[ase] Wrote {key}.tres ({len(atlas_list)} frames, {len(animations)} animations)")
    return True


# ── Main handler ──────────────────────────────────────────────────────────────


def _safe_key(layer: str) -> str:
    return layer.replace("/", "_").replace(" ", "_")


def handle_change(fname: str) -> None:
    base = Path(fname).stem
    ase_path = WATCH_DIR / fname
    print(f"[ase] {base} changed — exporting layers…")

    layers = list_layers(ase_path)
    if not layers:
        print(f"[ase] No layers found for {base}")
        return

    layer_keys: list[tuple[str, str]] = [(layer, f"{base}_{_safe_key(layer)}") for layer in layers]
    new_keys = {key for _, key in layer_keys}

    # Export all layers in parallel
    with ThreadPoolExecutor() as pool:
        futures = {
            pool.submit(export_layer, ase_path, layer, key): key
            for layer, key in layer_keys
        }

    exported: list[str] = []
    for fut, key in futures.items():
        try:
            if fut.result():
                exported.append(key)
        except Exception as e:
            print(f"[ase] Export error for {key}: {e}")

    if not exported:
        print(f"[ase] All exports failed for {base}")
        return

    # Resolve UIDs and write .tres files
    # PNG UIDs come from .import files written by Godot on its previous scan.
    # On first export the .import doesn't exist yet — Godot resolves ext_resource by path instead.
    written: list[str] = []
    for key in exported:
        tres_uid = get_tres_uid(key)
        if not tres_uid:
            print(f"[ase] Could not get UID for {key} — skipping")
            continue
        if write_tres(key, tres_uid, get_png_uid(key)):
            written.append(key)

    # Purge JSON handoff files
    for key in exported:
        for suffix in (".json", ".json.tmp"):
            p = OUTPUT_DIR / (key + suffix)
            if p.exists():
                p.unlink()

    # Remove stale outputs for layers no longer in this .ase
    for png in OUTPUT_DIR.glob(f"{base}_*.png"):
        stale = png.stem
        if stale not in new_keys:
            png.unlink(missing_ok=True)
            tres = OUTPUT_DIR / (stale + ".tres")
            if tres.exists():
                tres.unlink()
            print(f"[ase]   removed stale: {stale}")

    if written:
        trigger_scan_and_reload(written)


# ── Watch loop ────────────────────────────────────────────────────────────────


def main() -> None:
    last_seen: dict[str, int] = {}
    proc = subprocess.Popen(
        ["inotifywait", "-m", "-e", "close_write,moved_to", "--format", "%f", str(WATCH_DIR)],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True,
    )
    if not proc.stdout:
        print("[ase] Failed to open inotifywait stdout")
        return

    print(f"[ase] Watching {WATCH_DIR}")
    try:
        for line in proc.stdout:
            fname = line.strip()
            if not re.search(r"\.(ase|aseprite)$", fname):
                continue
            now_ms = int(time.time() * 1000)
            if now_ms - last_seen.get(fname, 0) < DEBOUNCE_MS:
                continue
            last_seen[fname] = now_ms
            handle_change(fname)
    finally:
        proc.terminate()


if __name__ == "__main__":
    main()
