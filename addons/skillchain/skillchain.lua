_addon.author  = 'lin'
_addon.name    = 'skillchain'
_addon.version = '0.2.0'

local Packet       = require 'packet'
local Weaponskills = require 'weaponskills'

require 'common'
require 'timer'

local Party   = {}
local Enemies = {}

local NonChainingSkills = {
    [8] = true,
    [36] = true,
    [37] = true,
    [79] = true,
    [80] = true,
    [87] = true,
    [89] = true,
    [143] = true,
    [149] = true,
    [150] = true,
    [230] = true
}

local DefaultConfig = {
    font = {
        family    = 'Consolas',
        size      = 10,
        color     = 0xFFFF0000,
        position  = { 50, 125 },
        bgcolor   = 0x80000000,
        bgvisible = true
    }
}

local SkillchainConfig = DefaultConfig

local function update_party(packet)
    local member1 = struct.unpack('i', packet, 0x08 + 1)
    local member2 = struct.unpack('i', packet, 0x08 + 1 + 12)
    local member3 = struct.unpack('i', packet, 0x08 + 1 + 24)
    local member4 = struct.unpack('i', packet, 0x08 + 1 + 36)
    local member5 = struct.unpack('i', packet, 0x08 + 1 + 48)
    local member6 = struct.unpack('i', packet, 0x08 + 1 + 60)

    Party = {
        [member1] = true,
        [member2] = true,
        [member3] = true,
        [member4] = true,
        [member5] = true,
        [member6] = true
    }

    -- just to keep things tidy
    Party[0] = nil
end

local function get_entity(server_id)
    -- entity array is 2304 items long
    for x = 0, 2303 do
        -- get the entity
        local e = GetEntity(x)

        -- ensure the entity is valid
        if e ~= nil and e.WarpPointer ~= 0 then
            if e.ServerId == server_id then
                return e
            end
        end
    end

    return nil
end

function load()
    SkillchainConfig = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', SkillchainConfig)

    -- initialize rendering data
    local font = AshitaCore:GetFontManager():Create('__skillchain_addon')
    font:SetColor(SkillchainConfig.font.color)
    font:SetFontFamily(SkillchainConfig.font.family)
    font:SetFontHeight(SkillchainConfig.font.size)
    font:SetBold(false)
    font:SetPositionX(SkillchainConfig.font.position[1])
    font:SetPositionY(SkillchainConfig.font.position[2])
    font:SetText('Skillchain ~ by lin')
    font:SetVisibility(true)
    font:GetBackground():SetColor(SkillchainConfig.font.bgcolor)
    font:GetBackground():SetVisibility(SkillchainConfig.font.bgvisible)

    -- initialize party data
    local party = AshitaCore:GetDataManager():GetParty()

    local member1 = party:GetMemberServerId(0)
    local member2 = party:GetMemberServerId(1)
    local member3 = party:GetMemberServerId(2)
    local member4 = party:GetMemberServerId(3)
    local member5 = party:GetMemberServerId(4)
    local member6 = party:GetMemberServerId(5)

    Party = {
        [member1] = true,
        [member2] = true,
        [member3] = true,
        [member4] = true,
        [member5] = true,
        [member6] = true
    }

    -- just to keep things tidy
    Party[0] = nil
end

function unload()
    local font = AshitaCore:GetFontManager():Get('__skillchain_addon')
    SkillchainConfig.font.position = { font:GetPositionX(), font:GetPositionY() }

    -- save config
    ashita.settings.save(_addon.path .. 'settings/settings.json', SkillchainConfig)

    -- unload font object
    AshitaCore:GetFontManager():Delete('__skillchain_addon')
end

function render()
    local font = AshitaCore:GetFontManager():Get('__skillchain_addon')
    local resx = AshitaCore:GetResourceManager()
    local e = T{}

    for k, v in pairs(Enemies) do
        local line = v.name

        for x = 1, #v.chain do
            line = line .. '\n   > ' .. Weaponskills[v.chain[x].id]
        end

        line = line .. '  ' .. (6 - math.abs(v.time - os.time())) .. 's'

        table.insert(e, line)
    end

    font:SetText(e:concat('\n'))
end

function handle_command(cmd)
    local args = cmd:args()

    if args[1] ~= '/sc' then
        return false
    end

    if #args > 1 and args[2] == 'dump' then
        for k, v in pairs(Party) do
          print('partymem ' .. k)
        end

        for k, v in pairs(Enemies) do
          print('target ' .. k .. ': ' .. #v)
        end
    end

    return true
end

function handle_packet(id, size, packet)
    if id == 0x00C8 then
        update_party(packet)
    elseif id == 0x0028 and ashita.bits.unpack_be(packet, 82, 4) == 3 then
        -- only look at WEAPONSKILL_FINISH packets
        local action = Packet.Server.parse(packet)

        -- gotta traverse our way to the meat of the action data
        for i = 1, action.target_count do
            local target = action.targets[i]

            for j = 1, target.action_count do
                local weaponskill = target.actions[j]

                -- bail out if it's a non-chaining weaponskill, or if not from our party
                if Party[action.actor_id] and not NonChainingSkills[weaponskill.animation] then
                    -- are we breaking a chain, or starting a new one?
                    if Enemies[target.id] == nil or not weaponskill.has_add_effect then
                        Enemies[target.id] = {
                            name = get_entity(target.id).Name,
                            time = nil,
                            chain = {}
                        }
                    end

                    -- once the chain window closes after ~6s,
                    -- drop the chain information
                    ashita.timer.remove_timer(target.id)
                    ashita.timer.create(target.id, 7, 1, function(tgt) Enemies[target.id] = nil end, target.id)

                    Enemies[target.id].time = os.time()
                    table.insert(Enemies[target.id].chain, { id = weaponskill.animation, element = nil })
                end
            end
        end
    end

    return false
end

ashita.register_event('load', load)
ashita.register_event('unload', unload)
ashita.register_event('render', render)
ashita.register_event('command', handle_command)
ashita.register_event('incoming_packet', handle_packet)
