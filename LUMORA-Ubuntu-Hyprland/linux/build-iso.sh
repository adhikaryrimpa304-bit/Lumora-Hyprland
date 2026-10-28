#!/usr/bin/env bash
# Experimental Ubuntu 26.04.1 LTS (resolute) + Hyprland ISO builder.
# Use a clean Ubuntu/Debian build VM; this script does NOT overwrite the uploaded source archive.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${WORK:-$HOME/lumora-hyprland-build}"
DIST="${DIST:-resolute}"
ARCH="${ARCH:-amd64}"
if [[ "$(id -u)" -eq 0 ]]; then SUDO=(); else SUDO=(sudo); fi

printf '
LUMORA Ubuntu + Hyprland ISO builder
Base: Ubuntu %s / %s
Work: %s
' "$DIST" "$ARCH" "$WORK"
printf 'This is an experimental live-build pipeline; a successful ISO build and boot test are not guaranteed.

'
"${SUDO[@]}" apt-get update
"${SUDO[@]}" apt-get install -y live-build debootstrap squashfs-tools xorriso ubuntu-keyring ca-certificates grub-common fonts-dejavu-core
mkdir -p "$WORK"
cd "$WORK"
"${SUDO[@]}" lb clean --purge 2>/dev/null || true
lb config \
  --mode ubuntu \
  --distribution "$DIST" \
  --architectures "$ARCH" \
  --archive-areas "main restricted universe multiverse" \
  --binary-images iso-hybrid \
  --debian-installer none \
  --iso-volume "LUMORA-HYPR" \
  --iso-application "LUMORA OS — Ubuntu + Hyprland" \
  --iso-publisher "LUMORA OS" \
  --bootappend-live "boot=live components quiet splash username=lumora hostname=lumora locales=en_US.UTF-8 keyboard-layouts=us"
mkdir -p config/package-lists config/includes.chroot
cp "$ROOT/linux/package-list.txt" config/package-lists/lumora.list.chroot
cp -a "$ROOT/linux/overlay/includes.chroot/." config/includes.chroot/
# Ensure SDDM is available to start the Hyprland session on a live-config-created user.
mkdir -p config/hooks/normal
cat > config/hooks/normal/0100-lumora-display-manager.hook.chroot <<'HOOK'
#!/bin/sh
set -e
if command -v systemctl >/dev/null 2>&1; then
  systemctl enable sddm.service || true
fi
HOOK
chmod +x config/hooks/normal/0100-lumora-display-manager.hook.chroot
# Install a reliable first-login default for newly created live users.
mkdir -p config/hooks/normal
cat > config/hooks/normal/0200-lumora-permissions.hook.chroot <<'HOOK'
#!/bin/sh
set -e
chmod 0755 /usr/bin/lumora-welcome
if command -v update-desktop-database >/dev/null 2>&1; then update-desktop-database || true; fi
HOOK
chmod +x config/hooks/normal/0200-lumora-permissions.hook.chroot
"${SUDO[@]}" lb build
ISO="$(find "$WORK" -maxdepth 1 -type f -name '*.iso' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)"
if [[ -z "$ISO" || ! -s "$ISO" ]]; then echo 'ERROR: live-build finished without a non-empty ISO.' >&2; exit 1; fi
sha256sum "$ISO" | tee "$ISO.sha256"
echo "ISO created: $ISO"
echo 'Next: test UEFI and BIOS boot in a VM; verify terminal, Firefox, Thunar, audio, networking and installer.'
