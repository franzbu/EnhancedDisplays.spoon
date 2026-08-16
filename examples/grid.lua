-- Grid-based layouts similar to Moom.

local EnhancedDisplays = hs.loadSpoon("EnhancedDisplays")

EnhancedDisplays:start({
    layouts = {
        -- Rightmost two columns of a 6x6 grid.
        rightTwoOfSix = EnhancedDisplays:grid(6, 6, 4, 0, 2, 6),

        -- Center cell of a 3x3 grid.
        centerNinth = EnhancedDisplays:grid(3, 3, 1, 1, 1, 1),

        -- Right third spanning top two rows of a 3x3 grid.
        rightTopTwoRows = EnhancedDisplays:grid(3, 3, 2, 0, 1, 2),
    },

    shortcuts = {
        ["⌘4"]  = "rightTwoOfSix",
        ["⌘⌥5"] = "centerNinth",
        ["⌃⌥7"] = "rightTopTwoRows",
    },
})
