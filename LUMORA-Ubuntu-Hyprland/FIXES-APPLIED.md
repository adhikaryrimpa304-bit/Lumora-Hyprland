# LUMORA OS — fixes applied after review

## Applied in this source revision
- Added SDDM and a live-session autologin configuration for the `lumora` live user and the LUMORA Hyprland session.
- Added a best-effort SDDM enable hook for the image build.
- Made the Polkit agent startup check multiple common executable paths instead of assuming one path.
- Added idle locking, display power saving, mouse move/resize gestures, audio mute/volume controls, microphone mute, and brightness shortcuts.
- Removed Nerd Font-only glyphs from Waybar so the status bar remains readable with ordinary fonts.
- Fixed the Welcome & Setup action so it shows welcome guidance instead of simply opening another Hub window.
- Disabled the Calamares launch path until a complete and validated installer configuration exists. This intentionally fails closed to protect disks.
- Added explicit warnings to the ISO script that the Debian `live-build` pipeline is not yet a validated Ubuntu live-image build method.

## Validation performed
- `bash linux/check-config.sh` passed.
- `bash -n linux/build-iso.sh` passed.
- Waybar JSON parsed successfully.

## Still unresolved / not claimed as fixed
- The Ubuntu 26.04 ISO build pipeline still needs redesign or a successful end-to-end build test using Ubuntu's supported image-building stack. The current Debian `live-build`-based script is exploratory only.
- The complete package set has not been resolved in a clean Ubuntu 26.04 amd64 environment.
- No ISO was built or boot-tested in this run; SDDM autologin/session startup is therefore not runtime-verified.
- Calamares installation is deliberately disabled until its modules, partitioning, target system setup, bootloader and branding are configured and tested.
- Hyprland from Ubuntu 26.04's archive may be older than current upstream Hyprland; the project needs a deliberate version strategy before release.

This is a source fix revision, not a bootable ISO or release candidate.
