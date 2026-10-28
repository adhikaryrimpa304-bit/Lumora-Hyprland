# LUMORA Ubuntu 26.04.1 LTS migration report

Date: 2026-10-24
Target: Ubuntu 26.04 LTS (`resolute`), `amd64`

## Changes applied

- Changed the default ISO target from Ubuntu 24.04 (`noble`) to Ubuntu 26.04 (`resolute`).
- Updated the package-list baseline comment and README build instructions.
- Updated the GitHub Actions workflow name. The workflow host remains `ubuntu-24.04`; the image target is selected separately by the build script.
- Added a guard to prevent accidental builds for non-amd64 architectures.
- Updated migration and audit notes to distinguish target distro from CI build host.

## Package index checks

Ubuntu's official package index lists `hyprland` version `0.53.3+ds-4`, `qtwayland5` version `5.15.18-1`, and Calamares version `3.3.14-0ubuntu25` in `resolute`. These checks establish that those named packages are indexed for the target suite, not that the entire package list resolves as one transaction.

## Validation performed locally

- `bash linux/check-config.sh` — passed.
- `bash -n linux/build-iso.sh` — passed.
- Waybar configuration JSON parse — passed.

## Not performed / release blockers

- No networked `apt` dependency resolution against `resolute` from a real build environment.
- No `live-build` ISO build.
- No UEFI or BIOS boot test.
- No graphical login/session, audio/network, or installer test.
- Calamares is still only a launcher; a functional installer requires distribution-specific configuration and safe VM testing.

This is a source migration, not a verified ISO release.
