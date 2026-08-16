-- Advanced two-display example.
-- Laptop: halves + quarters.
-- Large external display: thirds + 3x3 grid.

local EnhancedDisplays = hs.loadSpoon("EnhancedDisplays")

EnhancedDisplays:start({
    displays = {
        macbook = {
            name = "Built-in",
            -- Recommended once known:
            -- uuid = "YOUR-MACBOOK-DISPLAY-UUID",
        },

        studio = {
            name = "Studio Display",
            -- Recommended once known:
            -- uuid = "YOUR-STUDIO-DISPLAY-UUID",
        },
    },

    gap = 0,
    animationDuration = 0,
    showShortcutAlerts = false,
    shortcutAlertDuration = 0.6,
    moveLayoutMode = "mapped",

    layouts = {
        -- 3x3 cells, numbered column-first:
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

        leftTopTwoRows      = EnhancedDisplays:grid(3, 3, 0, 0, 1, 2),
        leftBottomTwoRows   = EnhancedDisplays:grid(3, 3, 0, 1, 1, 2),
        middleTopTwoRows    = EnhancedDisplays:grid(3, 3, 1, 0, 1, 2),
        middleBottomTwoRows = EnhancedDisplays:grid(3, 3, 1, 1, 1, 2),
        rightTopTwoRows     = EnhancedDisplays:grid(3, 3, 2, 0, 1, 2),
        rightBottomTwoRows  = EnhancedDisplays:grid(3, 3, 2, 1, 1, 2),
    },

    shortcuts = {
        -- Move focused window between connected displays.
        ["⌃1"] = "nextDisplay",

        -- MacBook halves / Studio Display thirds.
        ["⌘1"] = {
            macbook = "leftHalf",
            studio  = "leftThird",
        },

        ["⌘2"] = {
            macbook = "rightHalf",
            studio  = "middleThird",
        },

        ["⌘3"] = {
            studio = "rightThird",
        },

        -- MacBook quarters / Studio Display ninths.
        ["⌘⌥1"] = { macbook = "topLeft",     studio = "ninth1" },
        ["⌘⌥2"] = { macbook = "bottomLeft",  studio = "ninth2" },
        ["⌘⌥3"] = { macbook = "topRight",    studio = "ninth3" },
        ["⌘⌥4"] = { macbook = "bottomRight", studio = "ninth4" },
        ["⌘⌥5"] = { studio = "ninth5" },
        ["⌘⌥6"] = { studio = "ninth6" },
        ["⌘⌥7"] = { studio = "ninth7" },
        ["⌘⌥8"] = { studio = "ninth8" },
        ["⌘⌥9"] = { studio = "ninth9" },

        -- Studio Display larger 3x3 combinations.
        ["⌃⌥1"] = { studio = "leftTwoThirds" },
        ["⌃⌥2"] = { studio = "rightTwoThirds" },
        ["⌃⌥3"] = { studio = "leftTopTwoRows" },
        ["⌃⌥4"] = { studio = "leftBottomTwoRows" },
        ["⌃⌥5"] = { studio = "middleTopTwoRows" },
        ["⌃⌥6"] = { studio = "middleBottomTwoRows" },
        ["⌃⌥7"] = { studio = "rightTopTwoRows" },
        ["⌃⌥8"] = { studio = "rightBottomTwoRows" },
    },
})
