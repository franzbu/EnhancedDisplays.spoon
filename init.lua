local obj = {}
obj.__index = obj

obj.name = "EnhancedDisplays"
obj.version = "0.1.1"
obj.author = "Franz B."
obj.homepage = "https://github.com/franzbu/EnhancedDisplays.spoon"
obj.license = "MIT"

obj.log = hs.logger.new("EnhancedDisplays", "warning")

-- Built-in layouts are screen-relative unit rectangles.
-- They therefore work correctly on displays with negative origins and on
-- displays with different resolutions/scaling.
obj.defaultLayouts = {
    full         = { x = 0,     y = 0,   w = 1,     h = 1 },

    leftHalf     = { x = 0,     y = 0,   w = 1/2,   h = 1 },
    rightHalf    = { x = 1/2,   y = 0,   w = 1/2,   h = 1 },
    topHalf      = { x = 0,     y = 0,   w = 1,     h = 1/2 },
    bottomHalf   = { x = 0,     y = 1/2, w = 1,     h = 1/2 },
    middleHalf   = { x = 1/4,   y = 0,   w = 1/2,   h = 1 },

    leftThird    = { x = 0,     y = 0,   w = 1/3,   h = 1 },
    middleThird  = { x = 1/3,   y = 0,   w = 1/3,   h = 1 },
    rightThird   = { x = 2/3,   y = 0,   w = 1/3,   h = 1 },
    leftTwoThirds  = { x = 0,   y = 0,   w = 2/3,   h = 1 },
    rightTwoThirds = { x = 1/3, y = 0,   w = 2/3,   h = 1 },

    topLeft      = { x = 0,     y = 0,   w = 1/2,   h = 1/2 },
    topRight     = { x = 1/2,   y = 0,   w = 1/2,   h = 1/2 },
    bottomLeft   = { x = 0,     y = 1/2, w = 1/2,   h = 1/2 },
    bottomRight  = { x = 1/2,   y = 1/2, w = 1/2,   h = 1/2 },
}

obj.config = { displays = {} }
obj.layouts = nil
obj.hotkeys = {}
obj.bindings = {}
obj.windowState = {}

obj.actionNames = {
    nextDisplay = true,
    previousDisplay = true,
    moveToDisplay = true,
    listDisplays = true,
}

obj.layouts = obj.defaultLayouts

local function shallowCopy(t)
    local out = {}
    for k, v in pairs(t or {}) do out[k] = v end
    return out
end

local function mergeTables(base, extra)
    local out = shallowCopy(base)
    for k, v in pairs(extra or {}) do out[k] = v end
    return out
end

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function normalizedName(s)
    return string.lower(trim(tostring(s or "")))
end

local function isRect(v)
    return type(v) == "table"
        and type(v.x) == "number"
        and type(v.y) == "number"
        and type(v.w) == "number"
        and type(v.h) == "number"
end

local function screenFrameString(screen)
    local f = screen:frame()
    return string.format("x=%.0f y=%.0f w=%.0f h=%.0f", f.x, f.y, f.w, f.h)
end

function obj:grid(cols, rows, x, y, w, h)
    assert(type(cols) == "number" and cols > 0, "cols must be > 0")
    assert(type(rows) == "number" and rows > 0, "rows must be > 0")
    assert(type(x) == "number" and type(y) == "number", "x/y must be numbers")
    assert(type(w) == "number" and type(h) == "number", "w/h must be numbers")

    return {
        x = x / cols,
        y = y / rows,
        w = w / cols,
        h = h / rows,
    }
end

-- Accepts either readable words (cmd+alt+4) or compact macOS symbols (⌘⌥4).
function obj:parseShortcut(spec)
    assert(type(spec) == "string", "shortcut must be a string")

    local s = trim(spec)
    s = s:gsub("⌘", "cmd+")
         :gsub("⌥", "alt+")
         :gsub("⌃", "ctrl+")
         :gsub("⇧", "shift+")

    s = s:gsub("%s*%+%s*", "+")
    s = s:gsub("%s+", "+")
    s = s:gsub("%++", "+")
    s = s:gsub("^%+", ""):gsub("%+$", "")

    local aliases = {
        cmd = "cmd", command = "cmd",
        alt = "alt", option = "alt", opt = "alt",
        ctrl = "ctrl", control = "ctrl",
        shift = "shift",
        fn = "fn",
    }

    local mods, key = {}, nil
    for token in s:gmatch("[^+]+") do
        local original = trim(token)
        local lower = string.lower(original)
        if aliases[lower] then
            table.insert(mods, aliases[lower])
        else
            if key ~= nil then
                error("shortcut must contain exactly one non-modifier key: " .. spec)
            end
            key = original
        end
    end

    if not key or key == "" then
        error("shortcut has no key: " .. spec)
    end

    return mods, string.lower(key)
end

function obj:_displayMatches(screen, selector)
    if selector == nil then return false end

    local uuid = screen:getUUID()
    local name = screen:name() or ""

    if type(selector) == "string" then
        if uuid and selector == uuid then return true end
        return string.find(normalizedName(name), normalizedName(selector), 1, true) ~= nil
    end

    if type(selector) ~= "table" then return false end

    if selector.uuid and uuid ~= selector.uuid then return false end

    if selector.name then
        if string.find(normalizedName(name), normalizedName(selector.name), 1, true) == nil then
            return false
        end
    end

    if selector.pattern then
        if string.match(string.lower(name), string.lower(selector.pattern)) == nil then
            return false
        end
    end

    if selector.primary ~= nil then
        local primary = hs.screen.primaryScreen()
        local isPrimary = primary and primary:getUUID() == uuid
        if isPrimary ~= selector.primary then return false end
    end

    return selector.uuid ~= nil
        or selector.name ~= nil
        or selector.pattern ~= nil
        or selector.primary ~= nil
end

function obj:displayAliasForScreen(screen)
    if not screen then return nil end

    -- Exact UUID matches first so a friendly name cannot accidentally steal a display.
    for alias, selector in pairs(self.config.displays or {}) do
        if type(selector) == "table" and selector.uuid and selector.uuid == screen:getUUID() then
            return alias
        elseif type(selector) == "string" and selector == screen:getUUID() then
            return alias
        end
    end

    for alias, selector in pairs(self.config.displays or {}) do
        if self:_displayMatches(screen, selector) then return alias end
    end

    return nil
end

function obj:resolveDisplay(selector)
    if selector == nil then return nil end

    local configured = (self.config.displays or {})[selector]
    if configured ~= nil then selector = configured end

    for _, screen in ipairs(hs.screen.allScreens()) do
        if self:_displayMatches(screen, selector) then return screen end
    end

    -- As a convenience, let Hammerspoon resolve raw UUID/name/id hints too.
    if type(selector) == "string" or type(selector) == "number" then
        local ok, result = pcall(hs.screen.find, selector)
        if ok then return result end
    end

    return nil
end

function obj:listDisplays(showAlert)
    local lines = {}
    for i, screen in ipairs(hs.screen.allScreens()) do
        local alias = self:displayAliasForScreen(screen)
        table.insert(lines, string.format(
            "%d. %s%s\n   UUID: %s\n   Frame: %s",
            i,
            screen:name() or "<unnamed>",
            alias and ("  [" .. alias .. "]") or "",
            screen:getUUID() or "<none>",
            screenFrameString(screen)
        ))
    end

    local output = table.concat(lines, "\n")
    print("\nEnhancedDisplays — connected displays\n" .. output .. "\n")

    if showAlert ~= false then
        hs.alert.show("EnhancedDisplays: display details printed to the Hammerspoon Console")
    end

    return output
end

function obj:_focusedWindow()
    local win = hs.window.focusedWindow()
    if not win then
        hs.alert.show("EnhancedDisplays: no focused window")
        return nil
    end
    return win
end

function obj:_resolveLayout(layout)
    if isRect(layout) then return layout end
    if type(layout) ~= "string" then return nil end
    return self.layouts[layout]
end

function obj:applyLayout(layout, win, screen)
    win = win or self:_focusedWindow()
    if not win then return false end

    local rect = self:_resolveLayout(layout)
    if not rect then
        hs.alert.show("EnhancedDisplays: unknown layout " .. tostring(layout))
        self.log.ef("Unknown layout: %s", tostring(layout))
        return false
    end

    screen = screen or win:screen()
    if not screen then return false end

    local frame = screen:fromUnitRect(rect)
    local gap = tonumber(self.config.gap or 0) or 0

    if gap > 0 then
        frame.x = frame.x + gap
        frame.y = frame.y + gap
        frame.w = math.max(1, frame.w - 2 * gap)
        frame.h = math.max(1, frame.h - 2 * gap)
    end

    win:setFrameInScreenBounds(frame, self.config.animationDuration or 0)
    return true
end

function obj:_orderedScreens()
    local screens = hs.screen.allScreens()
    table.sort(screens, function(a, b)
        local af, bf = a:frame(), b:frame()
        if af.x == bf.x then return af.y < bf.y end
        return af.x < bf.x
    end)
    return screens
end

function obj:_adjacentDisplay(win, delta)
    local screens = self:_orderedScreens()
    if #screens < 2 then return nil end

    local currentUUID = win:screen():getUUID()
    local index = nil
    for i, screen in ipairs(screens) do
        if screen:getUUID() == currentUUID then
            index = i
            break
        end
    end
    if not index then return nil end

    local target = ((index - 1 + delta) % #screens) + 1
    return screens[target]
end

function obj:_isLayoutAction(action)
    if type(action) == "string" then return self.layouts[action] ~= nil end
    if isRect(action) then return true end
    return type(action) == "table" and action.layout ~= nil and action.action == nil
end

function obj:_rememberWindowShortcut(win, shortcut)
    if not win or not shortcut then return end
    local id = win:id()
    if id then self.windowState[id] = { shortcut = shortcut } end
end

function obj:_mappedLayoutForScreen(win, screen)
    if not win or not screen then return nil end
    local id = win:id()
    local state = id and self.windowState[id] or nil
    if not state or not state.shortcut then return nil end

    local binding = (self.bindings or {})[state.shortcut]
    if binding == nil then return nil end

    local target = self:_targetForScreen(binding, screen)
    if self:_isLayoutAction(target) then return target end
    return nil
end

function obj:moveToDisplay(target, options, win)
    win = win or self:_focusedWindow()
    if not win then return false end

    options = options or {}
    local screen = target
    if type(target) ~= "userdata" then screen = self:resolveDisplay(target) end

    if not screen then
        hs.alert.show("EnhancedDisplays: target display is not connected")
        return false
    end

    local mode = options.moveLayoutMode or self.config.moveLayoutMode or "mapped"
    if options.preserveAbsoluteSize == true then mode = "absolute" end

    if mode ~= "mapped" and mode ~= "relative" and mode ~= "absolute" then
        hs.alert.show("EnhancedDisplays: invalid moveLayoutMode " .. tostring(mode))
        return false
    end

    local mappedLayout = nil
    if not options.layout and mode == "mapped" then
        mappedLayout = self:_mappedLayoutForScreen(win, screen)
    end

    -- Hammerspoon retains relative position and size by default; noResize=true
    -- keeps the absolute window size instead. Mapped mode first moves relatively
    -- and then applies the destination layout when one exists.
    local preserveAbsoluteSize = (mode == "absolute")
    win:moveToScreen(screen, preserveAbsoluteSize, true, self.config.animationDuration or 0)

    if options.layout then
        self:applyLayout(options.layout, win, screen)
    elseif mappedLayout then
        self:_runAction(mappedLayout, win, screen)
    end

    return true
end

function obj:moveToNextDisplay(options, win)
    win = win or self:_focusedWindow()
    if not win then return false end
    local screen = self:_adjacentDisplay(win, 1)
    if not screen then
        hs.alert.show("EnhancedDisplays: only one display is connected")
        return false
    end
    return self:moveToDisplay(screen, options, win)
end

function obj:moveToPreviousDisplay(options, win)
    win = win or self:_focusedWindow()
    if not win then return false end
    local screen = self:_adjacentDisplay(win, -1)
    if not screen then
        hs.alert.show("EnhancedDisplays: only one display is connected")
        return false
    end
    return self:moveToDisplay(screen, options, win)
end

function obj:_targetForScreen(binding, screen)
    if type(binding) ~= "table" or isRect(binding) then return binding end

    -- Explicit action/layout descriptors are not per-display maps.
    if binding.action or binding.layout then return binding end

    local alias = self:displayAliasForScreen(screen)

    if alias and binding[alias] ~= nil then return binding[alias] end

    -- Also allow direct keys by exact UUID or screen name.
    if screen then
        local uuid, name = screen:getUUID(), screen:name()
        if uuid and binding[uuid] ~= nil then return binding[uuid] end
        if name and binding[name] ~= nil then return binding[name] end
    end

    return binding.default
end

function obj:_targetForCurrentDisplay(binding, win)
    return self:_targetForScreen(binding, win and win:screen() or nil)
end

function obj:_runAction(action, win, screen)
    if type(action) == "string" then
        if self.layouts[action] then return self:applyLayout(action, win, screen) end
        if action == "nextDisplay" then return self:moveToNextDisplay({}, win) end
        if action == "previousDisplay" then return self:moveToPreviousDisplay({}, win) end
        if action == "listDisplays" then self:listDisplays(true); return true end

        hs.alert.show("EnhancedDisplays: unknown action/layout " .. action)
        return false
    end

    if isRect(action) then return self:applyLayout(action, win, screen) end

    if type(action) ~= "table" then return false end

    if action.layout and not action.action then
        return self:applyLayout(action.layout, win, screen)
    end

    if action.action == "nextDisplay" then
        return self:moveToNextDisplay(action, win)
    elseif action.action == "previousDisplay" then
        return self:moveToPreviousDisplay(action, win)
    elseif action.action == "moveToDisplay" then
        return self:moveToDisplay(action.display, action, win)
    elseif action.action == "listDisplays" then
        self:listDisplays(true)
        return true
    end

    hs.alert.show("EnhancedDisplays: invalid action")
    return false
end

function obj:_showShortcutAlert(shortcut)
    if self.config.showShortcutAlerts ~= true then return end

    local duration = tonumber(self.config.shortcutAlertDuration)
    if duration == nil then duration = 0.6 end
    if duration <= 0 then return end

    hs.alert.show("EnhancedDisplays: " .. shortcut, duration)
end

function obj:shortcutStatus(shortcut)
    local mods, key = self:parseShortcut(shortcut)
    local status = {
        assignable = hs.hotkey.assignable(mods, key),
        systemAssigned = hs.hotkey.systemAssigned(mods, key),
    }

    print(string.format(
        "EnhancedDisplays shortcut %s — assignable: %s, systemAssigned: %s",
        shortcut,
        tostring(status.assignable),
        hs.inspect(status.systemAssigned)
    ))

    return status
end

function obj:runBinding(binding, shortcut)
    -- listDisplays intentionally works without a focused window.
    if binding == "listDisplays"
        or (type(binding) == "table" and binding.action == "listDisplays") then
        return self:_runAction(binding, nil)
    end

    local win = self:_focusedWindow()
    if not win then return false end

    local target = self:_targetForCurrentDisplay(binding, win)
    if target == nil then
        local alias = self:displayAliasForScreen(win:screen()) or (win:screen():name() or "unknown display")
        hs.alert.show("EnhancedDisplays: no shortcut action for " .. alias)
        return false
    end

    local ok = self:_runAction(target, win)
    if ok and shortcut and self:_isLayoutAction(target) then
        self:_rememberWindowShortcut(win, shortcut)
    end
    return ok
end

function obj:bind(shortcut, binding)
    local mods, key = self:parseShortcut(shortcut)
    local hotkey = hs.hotkey.bind(mods, key, function()
        self:_showShortcutAlert(shortcut)
        self:runBinding(binding, shortcut)
    end)

    if not hotkey then
        self.log.ef("Could not bind shortcut %s", shortcut)
        hs.alert.show("EnhancedDisplays: could not bind " .. shortcut)
        return nil
    end

    table.insert(self.hotkeys, hotkey)
    self.bindings[shortcut] = binding
    return hotkey
end

function obj:unbindAll()
    for _, hotkey in ipairs(self.hotkeys or {}) do
        pcall(function() hotkey:delete() end)
    end
    self.hotkeys = {}
    self.bindings = {}
end

function obj:start(config)
    self:unbindAll()

    self.config = config or {}
    self.layouts = mergeTables(self.defaultLayouts, self.config.layouts or {})
    self.windowState = {}

    if self.config.animationDuration ~= nil then
        assert(type(self.config.animationDuration) == "number", "animationDuration must be a number")
    end
    if self.config.showShortcutAlerts ~= nil then
        assert(type(self.config.showShortcutAlerts) == "boolean", "showShortcutAlerts must be true or false")
    end
    if self.config.shortcutAlertDuration ~= nil then
        assert(type(self.config.shortcutAlertDuration) == "number" and self.config.shortcutAlertDuration >= 0,
            "shortcutAlertDuration must be a non-negative number")
    end
    if self.config.moveLayoutMode ~= nil then
        assert(self.config.moveLayoutMode == "mapped"
            or self.config.moveLayoutMode == "relative"
            or self.config.moveLayoutMode == "absolute",
            "moveLayoutMode must be mapped, relative, or absolute")
    end

    for shortcut, binding in pairs(self.config.shortcuts or {}) do
        self:bind(shortcut, binding)
    end

    return self
end

-- Familiar alias for users coming from EnhancedSpaces.
function obj:new(config)
    return self:start(config)
end

function obj:stop()
    self:unbindAll()
    return self
end

return obj
