# Changelog

All notable user-visible changes to EnhancedDisplays are documented here.

## 0.1.1 — 2026-08-16

- Added `showShortcutAlerts` to enable or disable EnhancedDisplays shortcut popups.
- Added `shortcutAlertDuration` to control popup duration without changing Hammerspoon's global hotkey alert duration.
- Added `moveLayoutMode = "mapped"` (default) so windows can translate their last EnhancedDisplays layout to the corresponding layout on the destination display.
- Added `relative` and `absolute` cross-display move modes.
- Kept `preserveAbsoluteSize = true` as a backwards-compatible per-action alias for absolute-size moves.
- Added `shortcutStatus()` for diagnosing macOS-reserved or otherwise unavailable shortcuts.
- Improved failed-hotkey binding diagnostics.
- Fixed a duplicate local layout-resolution line in `applyLayout()`.

## 0.1.0 — 2026-08-16

Initial public release.

- Added physical-display-aware window management built on `hs.screen`.
- Added readable shortcut notation such as `⌘4`, `cmd+4`, and `⌃⌥⌘V`.
- Added per-display shortcut maps so the same shortcut can use different layouts on different physical displays.
- Added optional `default` behavior for per-display shortcut maps.
- Added built-in full-screen, half, centered-half, third, two-thirds, and quarter layouts.
- Added arbitrary custom layouts using screen-relative unit rectangles.
- Added Moom-style `grid(columns, rows, x, y, width, height)` layout helper.
- Added `nextDisplay`, `previousDisplay`, and `moveToDisplay` actions.
- Added optional layout application after moving a window to another display.
- Added optional absolute-size preservation when moving between displays.
- Added display aliases and lookup by UUID, case-insensitive name substring, Lua pattern, or primary-display status.
- Added `listDisplays()` for discovering display names, UUIDs, aliases, and frames.
- Display lookup occurs at action time, allowing disconnected or powered-off external displays to return without restarting the Spoon.
- Added optional window gap and animation duration.
- Added runtime `bind()`, `stop()`, and `unbindAll()` helpers.
- Added comprehensive README, examples, contribution guide, and GitHub issue templates.
