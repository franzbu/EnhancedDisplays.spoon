# EnhancedDisplays

**Physical-display window management for Hammerspoon.**

EnhancedDisplays is a Hammerspoon Spoon for moving, resizing, and arranging windows across **real physical displays**. Its main idea is simple: a keyboard shortcut can perform a different window layout depending on the display that currently contains the focused window.

It is conceptually inspired by [EnhancedSpaces](https://github.com/franzbu/EnhancedSpaces.spoon), but the two projects solve different problems:

- **EnhancedSpaces** creates and manages virtual `mSpaces` on one physical display.
- **EnhancedDisplays** manages windows directly on two or more real displays.

EnhancedDisplays does not create virtual desktops, hide windows to simulate spaces, or replace macOS Spaces. It works with the displays macOS and Hammerspoon actually see.

**Current version: 0.1.1**

---

## First Things First: Who Is This For?

EnhancedDisplays is for people who use more than one monitor and want fast, predictable window placement without having to remember a completely different set of shortcuts for every display.

For example, perhaps you want:

- `⌘1` to mean **left half** on a laptop display,
- the same `⌘1` to mean **left third** on a larger external display,
- `⌃1` to move the active window to the other monitor,
- `⌘⌥1` to mean **top-left quarter** on the laptop but **top-left ninth** on the external display.

EnhancedDisplays is designed specifically for that kind of workflow.

A configuration can be as readable as this:

```lua
shortcuts = {
    ["⌘1"] = {
        laptop  = "leftHalf",
        monitor = "leftThird",
    },

    ["⌘2"] = {
        laptop  = "rightHalf",
        monitor = "middleThird",
    },

    ["⌃1"] = "nextDisplay",
}
```

The shortcut stays the same. EnhancedDisplays checks which physical display contains the focused window and applies the layout assigned to that display.

---

## Features

EnhancedDisplays 0.1.1 includes:

- display-aware global keyboard shortcuts;
- optional per-shortcut on-screen feedback with configurable duration;
- the same shortcut doing different things on different displays;
- easy shortcut notation using either macOS symbols or words;
- built-in halves, thirds, two-thirds, quarters, and full-screen layouts;
- arbitrary custom layouts using screen-relative coordinates;
- a Moom-style grid helper for 2×2, 3×3, 6×6, or any other grid;
- moving the focused window to the next or previous physical display;
- mapped cross-display moves that automatically convert a remembered layout to the corresponding destination-display layout;
- moving a window directly to a named display;
- optionally applying a layout immediately after moving to another display;
- friendly display aliases such as `laptop`, `studio`, `left`, or `projector`;
- display identification by UUID, name, pattern, or primary-display status;
- hot-plug tolerant display lookup: disconnected displays can return without restarting the Spoon;
- optional gaps around positioned windows;
- optional window-movement animation;
- additional hotkeys that can be added after startup with `bind()`.

The initial release deliberately focuses on a small, clean foundation. More advanced features can be added without turning the Spoon into a second virtual-space manager.

---

## Requirements

You need:

1. macOS;
2. [Hammerspoon](https://www.hammerspoon.org/);
3. Accessibility permission for Hammerspoon in **System Settings → Privacy & Security → Accessibility**.

EnhancedDisplays is written for current Hammerspoon APIs. The initial development target is **macOS 26.5 with Hammerspoon 1.1.1**; version 0.1.1 has not yet been broadly validated across older macOS/Hammerspoon combinations.

If a macOS or Hammerspoon update changes window-management behavior, please open an issue with your macOS version, Hammerspoon version, display arrangement, and a minimal configuration that reproduces the problem.

---

# Installation

## Option 1: Git clone

Clone the repository directly into Hammerspoon's `Spoons` directory:

```bash
mkdir -p ~/.hammerspoon/Spoons
git clone https://github.com/franzbu/EnhancedDisplays.spoon.git \
  ~/.hammerspoon/Spoons/EnhancedDisplays.spoon
```

Then reload Hammerspoon.

## Option 2: Download ZIP

Download the repository ZIP, extract it, and make sure the final folder is named:

```text
EnhancedDisplays.spoon
```

Move that folder to:

```text
~/.hammerspoon/Spoons/
```

The result should look like this:

```text
~/.hammerspoon/
├── init.lua
└── Spoons/
    └── EnhancedDisplays.spoon/
        ├── init.lua
        ├── README.md
        ├── CHANGELOG.md
        └── LICENSE
```

Reload Hammerspoon from its menu-bar menu after installation.

---

# Setting Up EnhancedDisplays

EnhancedDisplays is loaded from your existing `~/.hammerspoon/init.lua`.

Do **not** replace your existing Hammerspoon configuration. EnhancedDisplays is meant to live alongside your other Hammerspoon automation.

A minimal configuration is:

```lua
local EnhancedDisplays = hs.loadSpoon("EnhancedDisplays")

EnhancedDisplays:start({
    displays = {
        laptop  = { name = "Built-in" },
        monitor = { name = "Studio Display" },
    },

    -- Shortcut popups are off by default.
    showShortcutAlerts = false,
    shortcutAlertDuration = 0.6,

    -- When a window has a known EnhancedDisplays layout, translate that
    -- layout to the destination display when moving between displays.
    moveLayoutMode = "mapped",

    shortcuts = {
        ["⌘1"] = {
            laptop  = "leftHalf",
            monitor = "leftThird",
        },

        ["⌘2"] = {
            laptop  = "rightHalf",
            monitor = "middleThird",
        },

        ["⌘3"] = {
            monitor = "rightThird",
        },

        ["⌃1"] = "nextDisplay",
    },
})
```

The display names above are examples. The recommended long-term configuration is to identify displays by UUID.

---

# Finding Your Displays

Open the **Hammerspoon Console** and run:

```lua
spoon.EnhancedDisplays:listDisplays()
```

EnhancedDisplays prints each connected display's:

- name;
- UUID;
- frame;
- configured alias, if one matches.

Example output:

```text
EnhancedDisplays — connected displays
1. Built-in Retina Display  [laptop]
   UUID: 12345678-....
   Frame: x=0 y=0 w=1728 h=1117

2. Studio Display  [monitor]
   UUID: ABCDEF12-....
   Frame: x=-2880 y=0 w=2880 h=1620
```

The negative `x` coordinate in the example is normal: macOS uses one global coordinate system, so a display positioned to the left of the primary display has negative coordinates.

EnhancedDisplays handles that automatically.

## Recommended: use UUIDs

Once you know the UUIDs, use them in your configuration:

```lua
displays = {
    laptop = {
        uuid = "YOUR-LAPTOP-DISPLAY-UUID",
    },

    monitor = {
        uuid = "YOUR-EXTERNAL-DISPLAY-UUID",
    },
}
```

UUID matching is the safest choice because display names are not guaranteed to be unique.

---

# Display Aliases

Aliases let the rest of the configuration stay readable.

Instead of writing a UUID every time, you define it once:

```lua
displays = {
    laptop  = { uuid = "..." },
    monitor = { uuid = "..." },
}
```

You can then use `laptop` and `monitor` throughout your shortcut configuration.

EnhancedDisplays supports four selector styles.

## UUID

Preferred:

```lua
studio = {
    uuid = "E960804A-E9F2-4836-A3DE-FC7519A4D4F4",
}
```

## Name substring

Case-insensitive substring matching:

```lua
studio = {
    name = "Studio Display",
}
```

```lua
laptop = {
    name = "Built-in",
}
```

## Lua pattern

The pattern is matched against the lower-cased display name:

```lua
laptop = {
    pattern = "built.*in",
}
```

## Primary display

```lua
main = {
    primary = true,
}
```

A simple string is also accepted as a UUID or name substring:

```lua
displays = {
    studio = "Studio Display",
}
```

### Avoid ambiguous selectors

If two displays can match the same name selector, use UUIDs instead. Exact UUID matches are deliberately preferred by EnhancedDisplays.

---

# Keyboard Shortcuts

Easy shortcut assignment is the central design goal of EnhancedDisplays.

## macOS-symbol notation

```lua
["⌘1"]   = "leftHalf"
["⌘⌥2"]  = "bottomLeft"
["⌃1"]   = "nextDisplay"
["⌃⌥8"]  = "rightThird"
["⌘⇧3"]  = "previousDisplay"
```

## Word notation

The same shortcuts can be written as:

```lua
["cmd+1"]            = "leftHalf"
["cmd+alt+2"]        = "bottomLeft"
["ctrl+1"]           = "nextDisplay"
["ctrl+alt+8"]       = "rightThird"
["cmd+shift+3"]      = "previousDisplay"
```

Supported modifier names are:

| Symbol | Names |
|---|---|
| `⌘` | `cmd`, `command` |
| `⌥` | `alt`, `option`, `opt` |
| `⌃` | `ctrl`, `control` |
| `⇧` | `shift` |
| — | `fn` |

The parser is intentionally forgiving about spaces around `+`.


---

# Shortcut Popups

EnhancedDisplays can optionally show a small on-screen message whenever one of its shortcuts is triggered.

By default, shortcut popups are disabled:

```lua
showShortcutAlerts = false
```

To enable them:

```lua
showShortcutAlerts = true
```

Set how long the popup remains visible, in seconds:

```lua
shortcutAlertDuration = 0.6
```

For example, a very brief confirmation:

```lua
showShortcutAlerts = true
shortcutAlertDuration = 0.25
```

These settings affect only EnhancedDisplays shortcut feedback. Error messages such as an unknown layout or disconnected target display are still shown when needed.

---

# Three Ways to Assign a Shortcut

## 1. One layout everywhere

```lua
["⌘1"] = "leftHalf"
```

Wherever the focused window is, `⌘1` puts it in the left half of its current physical display.

## 2. Different layout on each display

```lua
["⌘1"] = {
    laptop  = "leftHalf",
    monitor = "leftThird",
}
```

This is the defining feature of EnhancedDisplays.

If the focused window is on `laptop`, the window becomes the left half.

If it is on `monitor`, the same shortcut makes it the left third.

You may also specify a fallback:

```lua
["⌘1"] = {
    laptop  = "leftHalf",
    monitor = "leftThird",
    default = "leftHalf",
}
```

`default` is used when the current display does not match any listed display alias.

If there is no matching display and no `default`, EnhancedDisplays leaves the window alone and shows an alert.

## 3. Run an action

```lua
["⌃1"] = "nextDisplay"
```

or:

```lua
["⌘⇧1"] = {
    action = "moveToDisplay",
    display = "monitor",
}
```

Actions are described below.

---

# Built-In Layouts

EnhancedDisplays includes the following layouts:

```text
full

leftHalf
middleHalf
rightHalf
topHalf
bottomHalf

leftThird
middleThird
rightThird
leftTwoThirds
rightTwoThirds

topLeft
topRight
bottomLeft
bottomRight
```

All built-in layouts are **relative to the display containing the focused window**.

## Halves

```text
leftHalf                 rightHalf
┌──────────┬──────────┐  ┌──────────┬──────────┐
│██████████│          │  │          │██████████│
│██████████│          │  │          │██████████│
│██████████│          │  │          │██████████│
└──────────┴──────────┘  └──────────┴──────────┘
```

`middleHalf` occupies the middle 50% of the screen width.

```text
middleHalf
┌─────┬──────────┬─────┐
│     │██████████│     │
│     │██████████│     │
│     │██████████│     │
└─────┴──────────┴─────┘
```

## Thirds

```text
leftThird                 middleThird               rightThird
┌──────┬──────┬──────┐   ┌──────┬──────┬──────┐   ┌──────┬──────┬──────┐
│██████│      │      │   │      │██████│      │   │      │      │██████│
│██████│      │      │   │      │██████│      │   │      │      │██████│
│██████│      │      │   │      │██████│      │   │      │      │██████│
└──────┴──────┴──────┘   └──────┴──────┴──────┘   └──────┴──────┴──────┘
```

## Two-thirds

```text
leftTwoThirds              rightTwoThirds
┌──────┬──────┬──────┐     ┌──────┬──────┬──────┐
│██████│██████│      │     │      │██████│██████│
│██████│██████│      │     │      │██████│██████│
└──────┴──────┴──────┘     └──────┴──────┴──────┘
```

## Quarters

```text
┌────────────┬────────────┐
│ topLeft    │ topRight   │
│            │            │
├────────────┼────────────┤
│ bottomLeft │ bottomRight│
│            │            │
└────────────┴────────────┘
```

---

# Custom Layouts

A custom layout is a screen-relative rectangle:

```lua
layouts = {
    center40 = {
        x = 0.30,
        y = 0,
        w = 0.40,
        h = 1,
    },
}
```

The coordinate system is normalized to the target display:

```text
x = 0      left edge
x = 1      right edge

y = 0      top edge
y = 1      bottom edge

w = 1      full display width
h = 1      full display height
```

For example:

```lua
layouts = {
    leftQuarterWidth = {
        x = 0,
        y = 0,
        w = 0.25,
        h = 1,
    },

    centeredHalf = {
        x = 0.25,
        y = 0,
        w = 0.50,
        h = 1,
    },
}
```

Then assign them exactly like built-in layouts:

```lua
shortcuts = {
    ["⌘5"] = "centeredHalf",
}
```

Custom layouts with the same names as built-in layouts override the built-in versions.

---

# Grid Helper

For people coming from Moom or another grid-based window manager, EnhancedDisplays includes:

```lua
EnhancedDisplays:grid(columns, rows, x, y, width, height)
```

Grid coordinates are **zero-based**.

## 2×2 example

```text
       x=0        x=1
    ┌──────────┬──────────┐
y=0 │          │          │
    ├──────────┼──────────┤
y=1 │          │          │
    └──────────┴──────────┘
```

Top-left quarter:

```lua
EnhancedDisplays:grid(2, 2, 0, 0, 1, 1)
```

Bottom-right quarter:

```lua
EnhancedDisplays:grid(2, 2, 1, 1, 1, 1)
```

## 3×3 example

```text
┌─────┬─────┬─────┐
│ 0,0 │ 1,0 │ 2,0 │
├─────┼─────┼─────┤
│ 0,1 │ 1,1 │ 2,1 │
├─────┼─────┼─────┤
│ 0,2 │ 1,2 │ 2,2 │
└─────┴─────┴─────┘
```

Top-left ninth:

```lua
EnhancedDisplays:grid(3, 3, 0, 0, 1, 1)
```

Center ninth:

```lua
EnhancedDisplays:grid(3, 3, 1, 1, 1, 1)
```

Right third spanning the top two rows:

```lua
EnhancedDisplays:grid(3, 3, 2, 0, 1, 2)
```

Left two-thirds of the full display:

```lua
EnhancedDisplays:grid(3, 3, 0, 0, 2, 3)
```

## 6×6 Moom-style example

The rightmost two columns of a 6×6 grid are:

```lua
EnhancedDisplays:grid(6, 6, 4, 0, 2, 6)
```

A custom layout can therefore be defined like this:

```lua
local EnhancedDisplays = hs.loadSpoon("EnhancedDisplays")

EnhancedDisplays:start({
    layouts = {
        rightTwoOfSix = EnhancedDisplays:grid(6, 6, 4, 0, 2, 6),
    },

    shortcuts = {
        ["⌘4"] = "rightTwoOfSix",
    },
})
```

This makes translating an existing Moom grid straightforward.

---

# Moving Windows Between Physical Displays

## Move to the next display

```lua
["⌃1"] = "nextDisplay"
```

With two connected displays, this simply toggles the focused window between them.

With three or more displays, EnhancedDisplays orders them by their screen position:

1. left to right;
2. then top to bottom when displays share the same horizontal position.

The list wraps around.

## Move to the previous display

```lua
["⌃⇧1"] = "previousDisplay"
```

## Move directly to one display

```lua
["⌘⇧1"] = {
    action = "moveToDisplay",
    display = "laptop",
}

["⌘⇧2"] = {
    action = "moveToDisplay",
    display = "monitor",
}
```

## Move and apply a layout

```lua
["⌘⇧2"] = {
    action = "moveToDisplay",
    display = "monitor",
    layout = "rightThird",
}
```

The window first moves to `monitor`, then becomes the right third of that display.

## Layout behavior when moving between displays

EnhancedDisplays supports three cross-display move modes.

### `mapped` — recommended

```lua
moveLayoutMode = "mapped"
```

This is the default.

EnhancedDisplays remembers the most recent **layout shortcut** used on each window. When that window is moved to another display, EnhancedDisplays looks up what the same shortcut means on the destination display and applies that destination layout.

For example:

```lua
["⌘1"] = {
    laptop  = "leftHalf",
    monitor = "leftThird",
}

["⌘⌥1"] = {
    laptop  = "topLeft",
    monitor = "ninth1",
}

["⌃1"] = "nextDisplay"
```

If a window is placed with `⌘1` on the laptop, it occupies the left half. Pressing the move-between-displays shortcut then moves it to the monitor and resizes it to the left third.

Likewise, a window placed with `⌘⌥1` changes from the laptop's top-left quarter to the monitor's top-left ninth.

If the destination display has **no mapping for the remembered shortcut**, EnhancedDisplays falls back to a normal relative move rather than guessing.

### `relative`

```lua
moveLayoutMode = "relative"
```

The window keeps approximately the same relative position and relative size on the destination display. This is Hammerspoon's normal `moveToScreen()` behavior.

### `absolute`

```lua
moveLayoutMode = "absolute"
```

The window keeps its absolute size while moving to the destination display.

You can override the global mode for one move action:

```lua
["⌃1"] = {
    action = "nextDisplay",
    moveLayoutMode = "absolute",
}
```

The older per-action option remains supported:

```lua
preserveAbsoluteSize = true
```

and is equivalent to `moveLayoutMode = "absolute"` for that action.

---

# Complete Two-Display Example

The following example demonstrates why display-aware shortcuts are useful.

The laptop display uses simple halves and quarters. The larger external display uses thirds and a 3×3 grid.

```lua
local EnhancedDisplays = hs.loadSpoon("EnhancedDisplays")

EnhancedDisplays:start({
    displays = {
        laptop = {
            name = "Built-in",
            -- Better: uuid = "YOUR-LAPTOP-UUID",
        },

        monitor = {
            name = "Studio Display",
            -- Better: uuid = "YOUR-MONITOR-UUID",
        },
    },

    gap = 0,
    animationDuration = 0,

    -- Optional shortcut feedback.
    showShortcutAlerts = false,
    shortcutAlertDuration = 0.6,

    -- Translate the last EnhancedDisplays layout when a window moves
    -- between displays.
    moveLayoutMode = "mapped",

    layouts = {
        -- 3×3 cells, numbered column-first:
        --
        --   1   4   7
        --   2   5   8
        --   3   6   9

        ninth1 = EnhancedDisplays:grid(3, 3, 0, 0, 1, 1),
        ninth2 = EnhancedDisplays:grid(3, 3, 0, 1, 1, 1),
        ninth3 = EnhancedDisplays:grid(3, 3, 0, 2, 1, 1),

        ninth4 = EnhancedDisplays:grid(3, 3, 1, 0, 1, 1),
        ninth5 = EnhancedDisplays:grid(3, 3, 1, 1, 1, 1),
        ninth6 = EnhancedDisplays:grid(3, 3, 1, 2, 1, 1),

        ninth7 = EnhancedDisplays:grid(3, 3, 2, 0, 1, 1),
        ninth8 = EnhancedDisplays:grid(3, 3, 2, 1, 1, 1),
        ninth9 = EnhancedDisplays:grid(3, 3, 2, 2, 1, 1),

        leftTopTwoRows       = EnhancedDisplays:grid(3, 3, 0, 0, 1, 2),
        leftBottomTwoRows    = EnhancedDisplays:grid(3, 3, 0, 1, 1, 2),
        middleTopTwoRows     = EnhancedDisplays:grid(3, 3, 1, 0, 1, 2),
        middleBottomTwoRows  = EnhancedDisplays:grid(3, 3, 1, 1, 1, 2),
        rightTopTwoRows      = EnhancedDisplays:grid(3, 3, 2, 0, 1, 2),
        rightBottomTwoRows   = EnhancedDisplays:grid(3, 3, 2, 1, 1, 2),
    },

    shortcuts = {
        -- Move between physical displays.
        ["⌃1"] = "nextDisplay",

        -- Command + number.
        ["⌘1"] = {
            laptop  = "leftHalf",
            monitor = "leftThird",
        },

        ["⌘2"] = {
            laptop  = "rightHalf",
            monitor = "middleThird",
        },

        ["⌘3"] = {
            monitor = "rightThird",
        },

        -- Command + Option + number.
        ["⌘⌥1"] = {
            laptop  = "topLeft",
            monitor = "ninth1",
        },

        ["⌘⌥2"] = {
            laptop  = "bottomLeft",
            monitor = "ninth2",
        },

        ["⌘⌥3"] = {
            laptop  = "topRight",
            monitor = "ninth3",
        },

        ["⌘⌥4"] = {
            laptop  = "bottomRight",
            monitor = "ninth4",
        },

        ["⌘⌥5"] = { monitor = "ninth5" },
        ["⌘⌥6"] = { monitor = "ninth6" },
        ["⌘⌥7"] = { monitor = "ninth7" },
        ["⌘⌥8"] = { monitor = "ninth8" },
        ["⌘⌥9"] = { monitor = "ninth9" },

        -- Control + Option + number: larger 3×3 combinations.
        ["⌃⌥1"] = { monitor = "leftTwoThirds" },
        ["⌃⌥2"] = { monitor = "rightTwoThirds" },

        ["⌃⌥3"] = { monitor = "leftTopTwoRows" },
        ["⌃⌥4"] = { monitor = "leftBottomTwoRows" },

        ["⌃⌥5"] = { monitor = "middleTopTwoRows" },
        ["⌃⌥6"] = { monitor = "middleBottomTwoRows" },

        ["⌃⌥7"] = { monitor = "rightTopTwoRows" },
        ["⌃⌥8"] = { monitor = "rightBottomTwoRows" },
    },
})
```

The important point is not the particular shortcuts. The important point is that **one shortcut table describes both displays without duplicating the whole configuration**.

With `moveLayoutMode = "mapped"`, the move-between-displays shortcut also remembers the last EnhancedDisplays placement shortcut used for a window. A laptop half can therefore become the corresponding monitor third, and a laptop quarter can become the corresponding monitor ninth automatically.

---

# Gap Around Windows

To leave a gap around every window moved by EnhancedDisplays:

```lua
EnhancedDisplays:start({
    gap = 4,

    shortcuts = {
        ["⌘1"] = "leftHalf",
        ["⌘2"] = "rightHalf",
    },
})
```

`gap` is measured in screen points.

Default:

```lua
gap = 0
```

The gap is applied inside the selected layout on all four sides.

---

# Animation

Set the movement duration in seconds:

```lua
EnhancedDisplays:start({
    animationDuration = 0.15,
    shortcuts = {
        ["⌘1"] = "leftHalf",
    },
})
```

For immediate movement:

```lua
animationDuration = 0
```

---

# Adding Shortcuts After Startup

You do not have to put every binding in the main `shortcuts` table.

After `start()` you can add another binding with:

```lua
EnhancedDisplays:bind("⌘9", "full")
```

Another example:

```lua
EnhancedDisplays:bind("⌃0", "nextDisplay")
```

This is useful for testing or for configuration split across several Lua files.

---

# Other Public Methods

## `start(config)`

Starts EnhancedDisplays, removes old bindings created by the Spoon, merges custom layouts with built-in layouts, and installs all shortcuts in `config.shortcuts`.

```lua
EnhancedDisplays:start({ ... })
```

## `new(config)`

Alias for `start(config)`, provided for users familiar with EnhancedSpaces:

```lua
EnhancedDisplays:new({ ... })
```

## `stop()`

Deletes all hotkeys created by EnhancedDisplays:

```lua
EnhancedDisplays:stop()
```

## `unbindAll()`

Deletes all current EnhancedDisplays hotkeys without otherwise changing the configuration:

```lua
EnhancedDisplays:unbindAll()
```

## `shortcutStatus(shortcut)`

Checks whether Hammerspoon reports a shortcut as assignable and whether macOS reports it as system-assigned:

```lua
spoon.EnhancedDisplays:shortcutStatus("⌃1")
```

This is particularly useful for `Control` + number shortcuts, which macOS may reserve for Mission Control / Spaces.

## `listDisplays(showAlert)`

Prints connected-display information to the Hammerspoon Console:

```lua
EnhancedDisplays:listDisplays()
```

To suppress the alert while still printing:

```lua
EnhancedDisplays:listDisplays(false)
```

## `applyLayout(layout)`

Applies a built-in or custom layout to the focused window:

```lua
EnhancedDisplays:applyLayout("rightThird")
```

## `moveToNextDisplay()`

```lua
EnhancedDisplays:moveToNextDisplay()
```

## `moveToPreviousDisplay()`

```lua
EnhancedDisplays:moveToPreviousDisplay()
```

## `moveToDisplay(alias)`

```lua
EnhancedDisplays:moveToDisplay("monitor")
```

---

# Display Hot-Plugging and Powered-Off Monitors

EnhancedDisplays does not cache a permanent list of connected displays at startup.

Display selectors are resolved when the relevant command runs.

This means:

- an external monitor can be disconnected;
- the monitor can be powered off completely;
- the Mac can temporarily run with one display;
- the display can later return;
- EnhancedDisplays can find it again without restarting the Spoon.

If a shortcut explicitly targets a display that is currently unavailable, EnhancedDisplays shows:

```text
EnhancedDisplays: target display is not connected
```

It does not move the window somewhere else automatically.

---

# How EnhancedDisplays Handles Multi-Monitor Coordinates

macOS and Hammerspoon use one global coordinate system for all displays.

For example:

```text
external display               primary laptop display
x = -2880                      x = 0

┌───────────────────────┐      ┌───────────────┐
│                       │      │               │
│                       │      │               │
└───────────────────────┘      └───────────────┘
```

A naive window manager that calculates every layout from absolute `(0,0)` coordinates can therefore place windows on the wrong display.

EnhancedDisplays avoids this problem.

Layouts are stored as **unit rectangles** such as:

```lua
rightThird = {
    x = 2/3,
    y = 0,
    w = 1/3,
    h = 1,
}
```

When the shortcut is pressed, EnhancedDisplays:

1. gets the focused window;
2. gets that window's current `hs.screen`;
3. converts the unit rectangle through that screen;
4. applies the resulting absolute frame to the window.

The same layout therefore works whether a display is:

- left or right of the primary display;
- above or below it;
- a different resolution;
- using different display scaling.

---

# Using EnhancedDisplays Alongside Other Hammerspoon Code

EnhancedDisplays is only a Spoon loaded by Hammerspoon.

Your existing `~/.hammerspoon/init.lua` can continue to contain unrelated automation such as:

```lua
-- VPN controls
hs.hotkey.bind(...)

-- Home automation
hs.hotkey.bind(...)

-- clocks, application launchers, scripts, etc.
```

Then load EnhancedDisplays somewhere in the same configuration:

```lua
local EnhancedDisplays = hs.loadSpoon("EnhancedDisplays")
EnhancedDisplays:start({ ... })
```

There is no need to move all of your existing Hammerspoon code into the Spoon.

---

# Using EnhancedDisplays with Moom or Other Window Managers

During migration, Moom or another window manager can remain installed.

However, **do not assign the same global shortcut in two applications at the same time**. If both EnhancedDisplays and another utility try to capture `⌘1`, the result may depend on registration order or one application may fail to register the shortcut.

A safe migration process is:

1. recreate one shortcut in EnhancedDisplays;
2. disable that shortcut in the old window manager;
3. reload Hammerspoon;
4. test on every display;
5. continue one shortcut at a time;
6. remove the old utility only after the complete setup works.

---

# Troubleshooting

## A shortcut does nothing

Check the Hammerspoon Console for errors and verify that Hammerspoon has Accessibility permission.

Also verify that another application is not already using the same global shortcut.

You can ask EnhancedDisplays/Hammerspoon to inspect a shortcut:

```lua
spoon.EnhancedDisplays:shortcutStatus("⌃1")
```

If `assignable` is `false`, the shortcut is usually reserved by macOS. `Control` + number shortcuts are commonly used for Mission Control / switching Desktop Spaces. Open **System Settings → Keyboard → Keyboard Shortcuts → Mission Control** and disable or change the conflicting Desktop shortcut, then reload Hammerspoon.

If `assignable` is `true` but the EnhancedDisplays shortcut still does nothing, another Hammerspoon hotkey may be shadowing it. Inspect active Hammerspoon hotkeys with:

```lua
hs.inspect(hs.hotkey.getHotkeys())
```

## `no shortcut action for ...`

You created a per-display shortcut but did not define an action for the current display.

For example:

```lua
["⌘3"] = {
    monitor = "rightThird",
}
```

On the laptop display, this intentionally has no action.

Add one if desired:

```lua
["⌘3"] = {
    laptop  = "full",
    monitor = "rightThird",
}
```

or add a fallback:

```lua
["⌘3"] = {
    monitor = "rightThird",
    default = "full",
}
```

## `target display is not connected`

The requested display alias currently resolves to no connected `hs.screen`.

Run:

```lua
spoon.EnhancedDisplays:listDisplays()
```

and verify your display selector.

## Wrong display alias matches

Use UUIDs instead of name substrings.

## A window is slightly smaller than expected

Check your `gap` setting.

```lua
gap = 0
```

removes EnhancedDisplays' additional gap.

## The window manager and another app fight over a shortcut

Remove or disable the duplicate shortcut in the other application, then reload Hammerspoon.

## Changes to `init.lua` are not active

Reload the Hammerspoon configuration from its menu or execute:

```lua
hs.reload()
```

---

# Current Scope of Version 0.1.1

The first release intentionally concentrates on physical-display geometry and easy shortcut assignment.

It does **not** currently include:

- virtual mSpaces;
- window references/sticky mSpaces;
- window swapping;
- automatic app-to-display placement rules;
- mouse-driven snapping;
- mouse-driven moving/resizing;
- a graphical layout editor;
- popup menus;
- a custom window switcher;
- saved layout sessions.

Those features are possible future additions where they make sense for physical monitors.

---

# Relationship to EnhancedSpaces

EnhancedDisplays borrows ideas from [EnhancedSpaces](https://github.com/franzbu/EnhancedSpaces.spoon), especially:

- readable configuration;
- named window layouts;
- keyboard-first window management;
- configurable snapping;
- the goal of making window management disappear into muscle memory.

But EnhancedDisplays deliberately does **not** reuse EnhancedSpaces' virtual-screen model.

In EnhancedSpaces, the main abstraction is an `mSpace`.

In EnhancedDisplays, the main abstraction is a real `hs.screen`.

Keeping the projects separate allows both to stay conceptually clean.

---

# Roadmap

Possible future additions include:

- window swapping;
- per-application display/layout rules;
- mouse/trackpad snapping;
- mouse/trackpad moving and resizing;
- layout cycling;
- menus and popup menus;
- optional saved layout sets;
- richer display-arrangement navigation;
- user-defined named actions;
- optional on-screen layout feedback.

The intention is to add these only when they fit the physical-display model cleanly.

---

# Updating

If you installed with Git:

```bash
cd ~/.hammerspoon/Spoons/EnhancedDisplays.spoon
git pull
```

Then reload Hammerspoon.

Before updating across major or experimental versions, read [CHANGELOG.md](CHANGELOG.md).

---

# Uninstalling EnhancedDisplays

Remove or comment out the EnhancedDisplays block in `~/.hammerspoon/init.lua`.

Then remove the Spoon:

```bash
rm -rf ~/.hammerspoon/Spoons/EnhancedDisplays.spoon
```

Reload Hammerspoon.

EnhancedDisplays does not need a background daemon or separate login item beyond Hammerspoon itself.

---

# Contributing

Bug reports and improvements are welcome.

When reporting a display/window problem, please include:

- macOS version;
- Hammerspoon version;
- EnhancedDisplays version;
- number of displays;
- display arrangement;
- relevant output from `spoon.EnhancedDisplays:listDisplays()`;
- the smallest shortcut/layout configuration that reproduces the issue.

See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

---

# License

EnhancedDisplays is released under the MIT License.

See [LICENSE](LICENSE).

---

# Changelog

See [CHANGELOG.md](CHANGELOG.md).

For version 0.1.1, the focus remains the physical-display foundation: display-aware shortcuts, screen-relative layouts, grid-based layouts, display aliases, mapped cross-display moves, and configurable shortcut feedback.
