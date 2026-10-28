# Migration notes

- This is a clean Ubuntu + Hyprland branch, not an in-place patch of the old Debian GNOME ISO.
- Original LUMORA logo/wallpaper assets are retained.
- GNOME shell extensions, dconf configuration, GDM-specific styling, Calamares Debian settings, and old Debian live-build hooks are intentionally excluded.
- The old ZIP was not modified.
- No ISO build, runtime launch test, or installer test was performed while generating this scaffold.
- Ubuntu live-build compatibility and package availability are the first engineering tasks to verify.

## Ubuntu 26.04.1 LTS target update (2026-10-24)

- Changed the ISO target codename from `noble` (Ubuntu 24.04 LTS) to `resolute` (Ubuntu 26.04 LTS).
- Updated package-list comments, README build documentation, and ISO workflow naming.
- Kept the GitHub Actions host runner at `ubuntu-24.04`; it is a build host, not the target root filesystem. The build script explicitly requests `resolute`.
- Added an architecture guard for amd64 to avoid silently attempting an unvalidated architecture.
- Official Ubuntu package index confirms `hyprland` and `qtwayland5` exist in `resolute`; the full package list and live-build compatibility remain unverified until the ISO pipeline is run.
