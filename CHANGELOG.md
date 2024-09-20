# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2024-09-20

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`yaru_window_linux` - `v0.2.1`](#yaru_window_linux---v021)
 - [`yaru_window_manager` - `v0.1.2+1`](#yaru_window_manager---v0121)
 - [`yaru_window_platform_interface` - `v0.1.2+1`](#yaru_window_platform_interface---v0121)
 - [`yaru_window` - `v0.2.1+1`](#yaru_window---v0211)
 - [`yaru_window_web` - `v0.0.3+1`](#yaru_window_web---v0031)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `yaru_window` - `v0.2.1+1`
 - `yaru_window_web` - `v0.0.3+1`

---

#### `yaru_window_linux` - `v0.2.1`

 - **FIX**(linux): wire up YaruWindow.onClose with didRequestAppExit() (#35).
 - **FEAT**: always call gtk_window_set_title in yaru_window_set_title.

#### `yaru_window_manager` - `v0.1.2+1`

 - **FIX**: `_handleClose` conditioned to the state stream (#31).
 - **FIX**(yaru_window_manager): remove linux from the list of platforms (#24).

#### `yaru_window_platform_interface` - `v0.1.2+1`

 - **FIX**(linux): wire up YaruWindow.onClose with didRequestAppExit() (#35).

