# LUMORA OS / ML4W Dotfiles — Source Audit

**Audit date:** 2026-10-24  
**Inputs:** `LUMORA-Ubuntu-Hyprland-Features.zip` and `dotfiles-main.zip` (ML4W OS dotfiles)  
**Scope:** archive structure, build scaffolding, session/configuration files, launcher scripts, package declarations, and static checks. No ISO was built and no VM boot test was performed.

## Executive summary

Keep LUMORA as the product and source of truth. Use ML4W as a feature/reference project rather than copying its entire configuration into the ISO. The LUMORA archive is small and brand-specific; ML4W contains a much larger desktop environment configuration with many dependencies and distribution-specific assumptions.

## Findings

### Fixed in this audit

1. **Duplicate wallpaper startup:** Hyprland configuration launched `swaybg` twice. Reduced to one startup command.
2. **Wallpaper picker process stacking:** selecting a wallpaper started another `swaybg` process without stopping the previous one. It now stops the existing process before applying the selected wallpaper.
3. **Hyprland block formatting:** expanded compact `dwindle` and `master` blocks to standard multi-line syntax for easier review and compatibility.
4. **Missing declared utilities:** added `policykit-1` for `pkexec`, `libnotify-bin` for `notify-send`, `xwayland`, `xdg-user-dirs`, and emoji fonts to the intended package list.
5. **Recovery diagnostic check:** changed the network command lookup from the service name `NetworkManager` to the executable `nmcli`; corrected compositor executable case to `Hyprland`.
6. **Static check coverage:** the checker now parses Waybar JSON, checks Python syntax without generating `__pycache__` files, checks shell syntax, and fails on duplicate package names.

### High-priority unresolved risks

1. **ISO builder is experimental.** The project uses Debian `live-build` in Ubuntu mode. The archive itself correctly warns this path is not proven. Static checks do not prove Ubuntu bootstrap, package installation, bootloader generation, or live-session startup works.
2. **Full package resolution remains unverified.** Official Ubuntu package index pages list Hyprland, QtWayland 5, and Calamares in `resolute`, but that does not prove every item in the LUMORA package list resolves together or that the live-build bootstrap succeeds.
3. **Installer is not release-ready.** A Calamares launcher is not a configured, validated Ubuntu installer. Do not install to a physical disk until partitioning, bootloader, modules, and post-install boot are tested in a disposable VM.
4. **Session/display-manager integration is unverified.** The session desktop entry exists, but the complete login path and environment setup have not been tested.
5. **Hardware support is unverified.** Audio, Wi-Fi, Bluetooth, suspend, multi-monitor behavior, screen sharing, portals, and AMD graphics have not been tested on real hardware or a VM.
6. **Update flow is privileged and potentially disruptive.** `apt-get full-upgrade` can remove packages or change the live system; review the transaction and do not use this as an unattended updater.
7. **Icon glyphs may render as tofu.** Waybar uses Nerd Font-style glyphs while the package list only guarantees JetBrains Mono and Inter. Noto Color Emoji was added, but that does not guarantee every Nerd Font glyph. Replace glyphs or ship a properly licensed icon font if missing symbols are observed.

## ML4W integration decision

Good candidates to adapt later:

- A more modular Hyprland configuration with separated keybindings, animations, monitor rules and appearance settings.
- A consistent, configurable Waybar layout and user-friendly settings.
- Clipboard history, idle/lock behavior, and wallpaper-based colour theming after package availability and security review.
- Clear first-run documentation and optional configuration profiles.

Do not bulk-copy ML4W's dotfiles into LUMORA: they contain many scripts and assumptions, a broader dependency set, and distribution-specific integration. Review the included ML4W license and upstream notices before redistributing any copied files. This audit intentionally ports general fixes and design practices rather than copying ML4W implementation files.

## Validation performed

- `bash linux/check-config.sh` — passed after changes.
- `bash -n` checks for the ISO builder and shell launchers — passed.
- Python AST parsing for the bundled Python utilities — passed.
- Waybar configuration JSON parse — passed.
- Archive structure and README review — completed.

## Validation not performed

- Ubuntu repository/package resolution.
- A clean ISO build.
- ISO checksum/signature verification against a release artifact.
- UEFI/BIOS boot or graphical login.
- Hardware, installer, update, recovery, or post-install tests.

## Recommended release gates

1. Run the build in a disposable Ubuntu 26.04 VM and resolve all missing package/bootstrap failures.
2. Boot the ISO in QEMU/KVM with UEFI and confirm a usable live session.
3. Test the installer only against a disposable virtual disk.
4. Test portals, network, audio, suspend/resume, screenshots, clipboard, lock, and multiple displays.
5. Build from a tagged source revision, publish checksums, document known issues, and label the release experimental until the full matrix passes.


## Follow-up migration: Ubuntu 26.04.1 LTS (2026-10-24)

- Updated the default ISO target from Ubuntu 24.04 (`noble`) to Ubuntu 26.04 LTS (`resolute`), amd64.
- Updated the package-list header and README build instructions.
- Kept the CI host runner on Ubuntu 24.04 while setting the target distribution to `resolute` in the build script.
- Added an amd64 guard.
- Verified via Ubuntu's official package index that `hyprland` (0.53.3+ds-4) and `qtwayland5` (5.15.18-1) are listed for `resolute`. This does not prove the full package set resolves or that live-build works.
- No ISO was built and no VM boot test was performed in this update.
