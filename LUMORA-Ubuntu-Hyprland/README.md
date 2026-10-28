# LUMORA OS — Ubuntu + Hyprland (experimental)

This is a **new direction** for LUMORA OS. It retains the original LUMORA logo and wallpaper assets but replaces the Debian + GNOME desktop implementation with an Ubuntu-based Hyprland/Wayland desktop.

## Design

- Base target: Ubuntu 26.04.1 LTS (`resolute`), amd64
- Compositor: Hyprland (Wayland)
- Bar: Waybar
- App launcher: Wofi
- Terminal: Foot
- File manager: Thunar
- Notifications: Mako
- Lock/idle: swaylock + swayidle
- Screenshot/clipboard: grim, slurp, wl-clipboard
- LUMORA palette: deep black-violet `#130B20`, surfaces `#1C1230`, electric purple `#B026FF`, neon cyan `#00F0FF`

The archive's existing logo, wallpapers, and Windows customisation files are retained as reference assets. GNOME-specific shell extensions, dconf settings, GDM theme hooks, and the previous Debian build pipeline are not used by this new Linux desktop.

## Build (experimental)

Use a **disposable Ubuntu/Debian build VM** with internet and at least 25 GB free disk space. Do not build as root from your normal desktop session. The builder installs host build dependencies and uses `live-build` to attempt an Ubuntu `resolute` hybrid ISO:

```bash
bash linux/check-config.sh
bash linux/build-iso.sh
```

Output is placed under `~/lumora-hyprland-build/`. To select a different work folder:

```bash
WORK="$HOME/builds/lumora" bash linux/build-iso.sh
```

**Important limitations:** this is an initial engineering scaffold, not a verified release pipeline. Debian's `live-build` has historically been more straightforward with Debian than Ubuntu; Ubuntu 26.04-specific bootstrap, live-session startup, package resolution, Firefox packaging, session selection, and installer integration may need fixes. The script deliberately reports this as experimental. A source check is not a successful build, and a successful build is not a successful boot.

## First boot test checklist

Test in a VM before writing to a USB drive:

1. Boot both UEFI and (if required) legacy BIOS.
2. Confirm a Hyprland session starts and the Waybar appears.
3. `Super+Enter` opens Foot; `Super+Space` opens Wofi.
4. `Super+E` opens Thunar; `Super+B` launches the browser.
5. Verify Wi-Fi, sound, Bluetooth, screenshots, clipboard, screen lock, suspend and multiple monitors.
6. Confirm `xdg-desktop-portal-hyprland` works for screen sharing and file pickers.
7. Test installer only after it is deliberately configured for Ubuntu; the presence of Calamares alone does not make installation safe or functional.
8. Check logs for failed services and app launch errors.

## Keyboard shortcuts

| Shortcut | Action |
|---|---|
| Super + Enter | Terminal |
| Super + Space | Application launcher |
| Super + E | File manager |
| Super + B | Browser |
| Super + Q | Close focused window |
| Super + F | Fullscreen |
| Super + V | Toggle floating |
| Super + L | Lock screen |
| Super + Shift + E | Exit Hyprland |
| Super + arrows | Change focus |
| Super + Shift + arrows | Move window |

## Repository layout

- `assets/` — original LUMORA logos and wallpapers
- `linux/package-list.txt` — intended live-image packages
- `linux/overlay/includes.chroot/etc/skel/.config/` — default Hyprland/Waybar/Wofi/Foot/Mako settings
- `linux/overlay/includes.chroot/usr/share/backgrounds/lumora/` — wallpapers
- `linux/overlay/includes.chroot/usr/share/wayland-sessions/` — session entry
- `linux/build-iso.sh` — experimental ISO build attempt
- `linux/check-config.sh` — local static source checks
- `windows/` — original Windows theme scripts retained from the previous project

## Status

Source scaffold migrated to target Ubuntu 26.04.1 LTS (`resolute`) from the previous Ubuntu 24.04 (`noble`) target. Static checks can validate file presence and shell syntax, but no ISO has been built or boot-tested as part of creating this scaffold. Treat it as development work, not a daily-driver operating system.


## LUMORA feature apps (development implementation)

The overlay now includes LUMORA Hub, Welcome launcher, system information, wallpaper picker, update launcher, recovery diagnostics and an installer entry point. These are source-level implementations and must be tested inside the built live image.

- Hub: `Super+H` or application menu.
- Wallpapers: `Super+W`; applies selected image with `swaybg`.
- Software centre: launches GNOME Software if installed.
- Updates: asks for privilege approval and runs apt update/full-upgrade in Foot.
- Recovery: read-only diagnostics; it does not attempt automatic boot repairs.
- Installer: currently a guarded Calamares launcher, **not a validated Ubuntu installer**. Do not install to a real disk until Calamares modules, partitioning, bootloader and post-install boot are verified.
- Icon theme: Papirus is packaged; full OS-wide icon consistency still depends on app/toolkit support.

No claim is made that the ISO has been built or boot-tested. The live-build pipeline remains experimental.

## Source audit update (2026-10-24)

See [`AUDIT-REPORT.md`](AUDIT-REPORT.md) for findings from the LUMORA source and ML4W dotfiles review, including changes applied and release blockers. The audit fixes duplicate wallpaper startup, wallpaper process stacking, several declared runtime dependencies, a recovery diagnostic lookup, and expands static validation. **No ISO build or boot test has been completed by this audit.**


## Ubuntu 26.04 migration (2026-10-24)

- Default build target changed to Ubuntu 26.04 LTS (`resolute`), amd64.
- GitHub Actions runner remains `ubuntu-24.04` as the build host; the target distribution is selected separately by `linux/build-iso.sh`. This avoids depending on an unconfirmed hosted-runner label.
- Hyprland and QtWayland package entries were checked against Ubuntu's official package index for `resolute`; package resolution for the entire list still needs a real apt build.
- The pipeline remains experimental. No ISO build or VM boot test was performed in this migration.


## LUMORA theme update
See `THEME-UPDATE.md` for the ML4W-inspired Rofi, Hyprlock, Kitty/Bash, blur and GRUB styling added in this source revision.
