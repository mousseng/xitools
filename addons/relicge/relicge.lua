addon.name    = 'relicge'
addon.author  = 'lin'
addon.version = '0.1'
addon.desc    = 'Stats on dyna farming for relic'

require('common')
local imgui = require('imgui')

local CURRENCIES = {
    ['one byne bill']         = true,
    ['Tukuku whiteshell']     = true,
    ['Ordelle bronzepiece']   = true,
    ['one hundred byne bill'] = true,
    ['Lungo-Nango jadeshell'] = true,
    ['Montiont silverpiece']  = true,
}

local SINGLES = {
    ['one byne bill']       = true,
    ['Tukuku whiteshell']   = true,
    ['Ordelle bronzepiece'] = true,
}

local HUNDOS  = {
    ['one hundred byne bill'] = true,
    ['Lungo-Nango jadeshell'] = true,
    ['Montiont silverpiece']  = true,
}

local BYNES = {
    ['one byne bill']         = true,
    ['one hundred byne bill'] = true,
}

local SHELLS = {
    ['Tukuku whiteshell']     = true,
    ['Lungo-Nango jadeshell'] = true,
}

local PIECES = {
    ['Ordelle bronzepiece']  = true,
    ['Montiont silverpiece'] = true,
}

local party = AshitaCore:GetMemoryManager():GetParty()
local function isPartyMember(name)
    for i = 0, 17 do
        if party:GetMemberIsActive(i) == 1 and party:GetMemberName(i) == name then
            return true
        end
    end

    return false
end

local parser = { }
function parser.new()
    local STR_STAGGER = "(%w+)'s attack staggers the fiend"
    local STR_DEFEAT  = "(%w+) defeats the ([%w%s]+)"
    local STR_LOOT    = "You find an? ([%w%s-]+) on the ([%w%s]+)"

    local isStagger = false
    local avgBucket = 'avgDefeat'

    local p = {
        defeats     = 0,
        staggers    = 0,
        bynes       = 0,
        shells      = 0,
        pieces      = 0,
        fromDefeat  = 0,
        fromStagger = 0,
    }

    function p:line(str)
        return self:tryStagger(str)
            or self:tryDefeat(str)
            or self:tryLoot(str)
    end

    function p:tryStagger(str)
        local i, _, player = string.find(str, STR_STAGGER)
        if i == nil or player == nil then
            return false
        end

        if not isPartyMember(player) then
            return false
        end

        self.staggers = self.staggers + 1
        isStagger = true
        return true
    end

    function p:tryDefeat(str)
        local i, _, player, mob = string.find(str, STR_DEFEAT)
        if i == nil or player == nil then
            return false
        end

        if not isPartyMember(player) then
            return false
        end

        if isStagger then
            avgBucket = 'fromStagger'
        else
            avgBucket = 'fromDefeat'
        end

        self.defeats = self.defeats + 1
        isStagger = false
        return true
    end

    function p:tryLoot(str)
        local i, _, item, mob = string.find(str, STR_LOOT)
        if i == nil or item == nil or mob == nil then
            return false
        end

        if not CURRENCIES[item] then
            return false
        end

        local value = 0
        if SINGLES[item] then
            value = 1
        elseif HUNDOS[item] then
            value = 100
        end

        if BYNES[item] then
            self.bynes = self.bynes + value
        elseif SHELLS[item] then
            self.shells = self.shells + value
        elseif PIECES[item] then
            self.pieces = self.pieces + value
        end

        self[avgBucket] = self[avgBucket] + value
        return true
    end

    function p:getStats()
        local stats = {
            defeats = self.defeats,
            staggers = self.staggers,
            bynes = self.bynes,
            shells = self.shells,
            pieces = self.pieces,
            avgPerDefeat = 0,
            avgPerStagger = 0,
        }

        local nonstaggers = self.defeats - self.staggers
        if nonstaggers > 0 then
            stats.avgPerDefeat = self.fromDefeat / nonstaggers
        end

        if self.staggers > 0 then
            stats.avgPerStagger = self.fromStagger / self.staggers
        end

        return stats
    end

    return p
end

local function getCurrentLogFile()
    local playerName = party:GetMemberName(0)
    local today = os.date('%Y.%m.%d')
    return string.format('%s_%s.log', playerName, today)
end

local currentParser = parser.new()
local stats = nil
local function onText(e)
    if currentParser:line(e.message:strip_translate():strip_colors()) then
        stats = currentParser:getStats()
    end
end

local function onCommand(e)
    local args = e.command:args()
    if args[1] ~= '/relicge' then
        return
    end

    if args[2] == 'reset' then
        currentParser = parser.new()
        stats = currentParser:getStats()
    end

    if args[2] == 'replay' then
        local idx = (args[3] or '1'):tonumber()
        local log = args[4] or getCurrentLogFile()
        local newParser = parser.new()
        local logPath = string.format('%s/chatlogs/%s', AshitaCore:GetInstallPath(), log)
        local logFile = io.open(logPath, 'r')
        if logFile then
            logFile:seek('set', idx)
            for line in logFile:lines() do
                newParser:line(line)
            end

            currentParser = newParser
            stats = currentParser:getStats()
        end
    end

    e.blocked = true
end

local function onPresent()
    imgui.SetNextWindowSize({ -1, -1 })
    if imgui.Begin('relicge', { true }, ImGuiWindowFlags_NoDecoration) then
        if stats == nil then
            imgui.TextDisabled('no data to show')
        else
            imgui.Text(string.format('%-12s %4i', 'kills:', stats.defeats))
            imgui.Text(string.format('%-12s %4i', 'staggers:', stats.staggers))
            imgui.Text(string.format('%-12s %4i', 'bynes:', stats.bynes))
            imgui.Text(string.format('%-12s %4i', 'shells:', stats.shells))
            imgui.Text(string.format('%-12s %4i', 'pieces:', stats.pieces))
            imgui.Text(string.format('%-12s %4.1f', 'avg/defeat:', stats.avgPerDefeat))
            imgui.Text(string.format('%-12s %4.1f', 'avg/stagger:', stats.avgPerStagger))
        end
    end
    imgui.End()
end

ashita.events.register('text_in', 'text_in', onText)
ashita.events.register('command', 'command', onCommand)
ashita.events.register('d3d_present', 'd3d_present', onPresent)
