#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo 'Checking LUMORA Hyprland source tree…'
for f in   "$ROOT/linux/package-list.txt"   "$ROOT/linux/overlay/includes.chroot/etc/skel/.config/hypr/hyprland.conf"   "$ROOT/linux/overlay/includes.chroot/etc/skel/.config/waybar/config"   "$ROOT/linux/overlay/includes.chroot/usr/bin/lumora-welcome"; do
  [[ -s "$f" ]] || { echo "Missing/empty: $f" >&2; exit 1; }
  echo "OK: ${f#"$ROOT"/}"
done
bash -n "$ROOT/linux/build-iso.sh"
bash -n "$ROOT/linux/overlay/includes.chroot/usr/bin/lumora-welcome"
bash -n "$ROOT/linux/overlay/includes.chroot/usr/bin/lumora-update"
bash -n "$ROOT/linux/overlay/includes.chroot/usr/bin/lumora-installer"
python3 - "$ROOT" <<'PYJSON'
import json, pathlib, sys
root = pathlib.Path(sys.argv[1])
for rel in [
    'linux/overlay/includes.chroot/etc/skel/.config/waybar/config',
]:
    p = root / rel
    if rel.endswith('.json') or rel.endswith('/config'):
        json.loads(p.read_text())
        print(f'OK: valid JSON: {rel}')
PYJSON
for f in lumora-hub lumora-system-info lumora-wallpapers lumora-recovery; do
  python3 - "$ROOT/linux/overlay/includes.chroot/usr/bin/$f" <<'PYSYNTAX'
import ast, pathlib, sys
ast.parse(pathlib.Path(sys.argv[1]).read_text(), filename=sys.argv[1])
PYSYNTAX
done
for f in lumora-hub.desktop lumora-system-info.desktop lumora-wallpapers.desktop lumora-update.desktop lumora-recovery.desktop lumora-installer.desktop; do
  [[ -s "$ROOT/linux/overlay/includes.chroot/usr/share/applications/$f" ]] || { echo "Missing desktop entry: $f" >&2; exit 1; }
done
# Check required live-session configuration and the safety gate around Calamares.
[[ -s "$ROOT/linux/overlay/includes.chroot/etc/sddm.conf.d/10-lumora-live.conf" ]] || { echo 'Missing SDDM live-session configuration' >&2; exit 1; }
grep -q '^sddm$' "$ROOT/linux/package-list.txt" || { echo 'SDDM is missing from package list' >&2; exit 1; }
grep -q 'Installation is disabled' "$ROOT/linux/overlay/includes.chroot/usr/bin/lumora-installer" || { echo 'Installer safety gate missing' >&2; exit 1; }
# Fail on duplicate package entries.
duplicates=$(awk '!/^#/ && NF {print $1}' "$ROOT/linux/package-list.txt" | sort | uniq -d)
if [[ -n "$duplicates" ]]; then echo "Duplicate packages:\n$duplicates" >&2; exit 1; fi
echo 'Static source checks passed. This does not validate Ubuntu package availability or prove the ISO boots.'
