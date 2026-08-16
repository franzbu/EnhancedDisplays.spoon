# Contributing to EnhancedDisplays

Thanks for helping improve EnhancedDisplays.

## Bug reports

Please include enough information to reproduce the problem:

- macOS version;
- Hammerspoon version;
- EnhancedDisplays version;
- number and arrangement of physical displays;
- relevant output from `spoon.EnhancedDisplays:listDisplays()`;
- the smallest configuration that reproduces the issue;
- Hammerspoon Console errors, if any.

If the problem only occurs after connecting, disconnecting, sleeping, waking, or powering a display on/off, mention that explicitly.

## Feature requests

Please describe the workflow you are trying to achieve rather than only the implementation you have in mind. EnhancedDisplays aims to keep the physical-display model simple, so new features should fit that model cleanly.

## Pull requests

Keep changes focused. Avoid unrelated formatting or refactoring in the same pull request as a behavioral change.

For code changes:

1. explain the problem being solved;
2. explain the approach;
3. test with at least one real display arrangement;
4. test Hammerspoon reloads;
5. update README examples when behavior or configuration changes;
6. update CHANGELOG.md for user-visible changes.

## Coding style

- Prefer readable Lua over clever Lua.
- Keep public configuration names descriptive.
- Avoid hard-coded absolute display coordinates.
- Use `hs.screen`-relative geometry for physical-display behavior.
- Resolve displays at execution time when practical so hot-plugging remains reliable.
- Preserve backwards compatibility within a release series unless there is a strong reason not to.
