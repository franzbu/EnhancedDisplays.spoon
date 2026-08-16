-- Basic EnhancedDisplays example.
-- Add this to ~/.hammerspoon/init.lua after installing EnhancedDisplays.spoon.

local EnhancedDisplays = hs.loadSpoon("EnhancedDisplays")

EnhancedDisplays:start({
    displays = {
        laptop  = { name = "Built-in" },
        monitor = { name = "Studio Display" },
    },

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
