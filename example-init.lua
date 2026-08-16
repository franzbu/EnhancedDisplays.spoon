-- Add this block to your existing ~/.hammerspoon/init.lua.
-- Do NOT replace your other Hammerspoon configuration.

local EnhancedDisplays = hs.loadSpoon("EnhancedDisplays")

EnhancedDisplays:start({
    displays = {
        -- Replace with UUIDs after running:
        -- spoon.EnhancedDisplays:listDisplays()
        macbook = { name = "Built-in" },
        studio  = { name = "Studio Display" },
    },

    -- Optional gap around the positioned window, in points.
    gap = 0,

    -- Optional on-screen shortcut feedback.
    showShortcutAlerts = false,
    shortcutAlertDuration = 0.6,

    -- Translate the last layout to the destination display when possible.
    moveLayoutMode = "mapped",

    shortcuts = {
        -- Same shortcut, different layout depending on current display.
        ["⌘2"] = {
            macbook = "middleHalf",
            studio  = "middleThird",
        },

        -- Move focused window to the other connected display.
        ["⌘3"] = "nextDisplay",

        ["⌘4"] = {
            macbook = "rightHalf",
            studio  = "rightThird",
        },

        -- Examples:
        -- ["⌘1"] = "leftHalf",
        -- ["⌘⇧3"] = "previousDisplay",
        -- ["⌘⌥1"] = { action = "moveToDisplay", display = "macbook" },
        -- ["⌘⌥2"] = { action = "moveToDisplay", display = "studio" },
    },
})
