addon.name    = 'trials'
addon.author  = 'lin'
addon.version = '0.1'
addon.desc    = 'Track weaponskill points'

require('common')
local bit = require('bit')
local imgui = require('imgui')
local packets = require('packets')
local settings = require('settings')

local wsPoints = {
    [0x120] = 1 + 4, -- Light
    [0x121] = 1 + 4, -- Darkness
    [0x122] = 1 + 2, -- Gravitation
    [0x123] = 1 + 2, -- Fragmentation
    [0x124] = 1 + 2, -- Distortion
    [0x125] = 1 + 2, -- Fusion
    [0x126] = 1 + 1, -- Compression
    [0x127] = 1 + 1, -- Liquefaction
    [0x128] = 1 + 1, -- Induration
    [0x129] = 1 + 1, -- Reverberation
    [0x12A] = 1 + 1, -- Transfixion
    [0x12B] = 1 + 1, -- Scission
    [0x12C] = 1 + 1, -- Detonation
    [0x12D] = 1 + 1, -- Impaction
    [0x12E] = 1 + 4, -- Radiance
    [0x12F] = 1 + 4, -- Umbra
}

local defaultConfig = T{
    serverId = nil,
    isVisible = { true },
    weapons = {
        -- WSNM
        [16735] = { Name = 'Axe of Trials',      Cur = 0, Max = 300 },
        [16793] = { Name = 'Scythe of Trials',   Cur = 0, Max = 300 },
        [16892] = { Name = 'Spear of Trials',    Cur = 0, Max = 300 },
        [16952] = { Name = 'Sword of Trials',    Cur = 0, Max = 300 },
        [17456] = { Name = 'Club of Trials',     Cur = 0, Max = 300 },
        [17507] = { Name = 'Knuckles of Trials', Cur = 0, Max = 300 },
        [17527] = { Name = 'Pole of Trials',     Cur = 0, Max = 300 },
        [17616] = { Name = 'Dagger of Trials',   Cur = 0, Max = 300 },
        [17654] = { Name = 'Sapara of Trials',   Cur = 0, Max = 300 },
        [17773] = { Name = 'Kodachi of Trials',  Cur = 0, Max = 300 },
        [17815] = { Name = 'Tachi of Trials',    Cur = 0, Max = 300 },
        [17933] = { Name = 'Pick of Trials',     Cur = 0, Max = 300 },
        [18144] = { Name = 'Bow of Trials',      Cur = 0, Max = 300 },
        [18146] = { Name = 'Gun of Trials',      Cur = 0, Max = 300 },
        -- KSNM
        [17451] = { Name = 'Morgenstern',        Cur = 0, Max = 500 },
        [17509] = { Name = 'Destroyers',         Cur = 0, Max = 500 },
        [17589] = { Name = 'Thyrsusstab',        Cur = 0, Max = 500 },
        [17699] = { Name = 'Dissector',          Cur = 0, Max = 500 },
        [17793] = { Name = 'Senjuinrikio',       Cur = 0, Max = 500 },
        [17827] = { Name = 'Michishiba',         Cur = 0, Max = 500 },
        [17944] = { Name = 'Retributor',         Cur = 0, Max = 500 },
        [18005] = { Name = 'Heart Snatcher',     Cur = 0, Max = 500 },
        [18053] = { Name = 'Gravedigger',        Cur = 0, Max = 500 },
        [18097] = { Name = 'Gondo-Shizunori',    Cur = 0, Max = 500 },
        [18217] = { Name = 'Rampager',           Cur = 0, Max = 500 },
        [18378] = { Name = 'Subduer',            Cur = 0, Max = 500 },
        [17207] = { Name = 'Expunger',           Cur = 0, Max = 500 },
        [17275] = { Name = 'Coffinmaker',        Cur = 0, Max = 500 },
        -- Vigil
        [17744] = { Name = 'Brave Blade',        Cur = 0, Max = 250 },
        [18753] = { Name = 'Burning Fists',      Cur = 0, Max = 250 },
        [18034] = { Name = 'Dancing Dagger',     Cur = 0, Max = 250 },
        [18944] = { Name = 'Death Sickle',       Cur = 0, Max = 250 },
        [17956] = { Name = 'Double Axe',         Cur = 0, Max = 250 },
        [18592] = { Name = 'Elder Staff',        Cur = 0, Max = 250 },
        [18754] = { Name = 'Inferno Claws',      Cur = 0, Max = 250 },
        [18719] = { Name = 'Killer Bow',         Cur = 0, Max = 250 },
        [18589] = { Name = 'Mage\'s Staff',      Cur = 0, Max = 250 },
        [19102] = { Name = 'Main Gauche',        Cur = 0, Max = 250 },
        [18720] = { Name = 'Quicksilver',        Cur = 0, Max = 250 },
        [18120] = { Name = 'Radiant Lance',      Cur = 0, Max = 250 },
        [18426] = { Name = 'Sasuke Katana',      Cur = 0, Max = 250 },
        [18590] = { Name = 'Scepter Staff',      Cur = 0, Max = 250 },
        [18492] = { Name = 'Sturdy Axe',         Cur = 0, Max = 250 },
        [18003] = { Name = 'Swordbreaker',       Cur = 0, Max = 250 },
        [17742] = { Name = 'Vorpal Sword',       Cur = 0, Max = 250 },
        [18851] = { Name = 'Werebuster',         Cur = 0, Max = 250 },
        [17743] = { Name = 'Wightslayer',        Cur = 0, Max = 250 },
        [18443] = { Name = 'Windslicer',         Cur = 0, Max = 250 },
    },
}

local displayOrder = T{
    16735,
    16793,
    16892,
    16952,
    17456,
    17507,
    17527,
    17616,
    17654,
    17742,
    17743,
    17744,
    17773,
    17793,
    17815,
    17933,
    17956,
    18003,
    18034,
    18120,
    18144,
    18146,
    18426,
    18443,
    18492,
    18589,
    18590,
    18592,
    18719,
    18720,
    18753,
    18754,
    18851,
    18944,
    19102,
}

local config = settings.load(defaultConfig)
local tableFlags = bit.bor(ImGuiTableFlags_RowBg, ImGuiTableFlags_Borders, ImGuiTableFlags_NoBordersInBody)

local function LoadConfig(c)
    if c ~= nil then
        config = c
    end

    config.serverId = GetPlayerEntity().ServerId
    settings.save()
end

local function GetMainHand()
    local inv = AshitaCore:GetMemoryManager():GetInventory()

    local equipped = inv:GetEquippedItem(0).Index
    local container = bit.rshift(bit.band(equipped, 0xFF00), 8)
    local index = bit.band(equipped, 0x00FF)

    local item = inv:GetContainerItem(container, index)
    return item.Id
end

local function HandleWeaponskill(packet)
    local weapon = GetMainHand()
    if config.weapons[weapon] == nil then
        return
    end

    if packet.target_count < 1 then
        return
    end

    local target = packet.targets[1]
    if target.action_count < 1 then
        return
    end

    local action = target.actions[1]

    -- no points for misses
    if action.reaction == 0x01 or action.reaction == 0x09 then
        return
    end

    -- landing a weaponskill gives 1 point
    local earnedPoints = 1

    -- forming a skillchain gives bonus points
    if action.has_add_effect then
        earnedPoints = wsPoints[action.add_effect_message]
    end

    config.weapons[weapon].Cur = config.weapons[weapon].Cur + earnedPoints
    settings.save()
end

settings.register('settings', 'settings_update', function (s)
    LoadConfig(s)
end)

ashita.events.register('load', 'load', function()
    LoadConfig()
end)

ashita.events.register('unload', 'unload', function()
    settings.save()
end)

ashita.events.register('d3d_present', 'd3d_present', function()
    if config.isVisible[1] and imgui.Begin('trials', config.isVisible) then
        imgui.PushStyleVar(ImGuiStyleVar_CellPadding, { 10, 3 })
        if imgui.BeginTable('xitools.week.summary', 2, tableFlags) then
            for _, id in ipairs(displayOrder) do
                local trial = config.weapons[id]
                if trial.Cur > 0 then
                    imgui.TableNextRow()
                    imgui.TableNextColumn()
                    imgui.Text(trial.Name)
                    imgui.TableNextColumn()
                    imgui.Text(string.format('%i / %i', trial.Cur, trial.Max))
                end
            end

            imgui.EndTable()
        end

        imgui.PopStyleVar()
        imgui.End()
    end
end)

ashita.events.register('packet_in', 'packet_in', function(e)
    if e.id == 0x28 then
        local action = packets.inbound.action.parse(e.data_modified_raw)

        if action.actor_id == config.serverId and action.category == 3 then
            HandleWeaponskill(action)
        end
    end
end)

ashita.events.register('command', 'command', function(e)
    local args = e.command:args()

    if args[1] == '/trials' then
        config.isVisible[1] = not config.isVisible[1]
    end
end)
