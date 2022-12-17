addon.name    = 'skillchain'
addon.author  = 'lin'
addon.version = '1.0.0'
addon.desc    = 'A little skillchain tracker so you know when things happen'

-- TODO: don't pollute the scope, just return objects from the helpers
require 'skillchain_data'
require 'skillchain_packethandler'
local settings = require('settings')
local text = require('lin.text')
local packets = require('lin.packets')

-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

local default_settings = {
    font = {
        visible = true,
        font_family = 'Consolas',
        font_height = scaling.scale_f(10),
        color = 0xFFFFFFFF,
        position_x = 100,
        position_y = 100,
        background = {
            visible = true,
            color = 0xA0000000,
        }
    }
}

local skillchain = {
    settings = settings.load(default_settings),
    chains = { },
    font = nil,
}

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        skillchain.settings = s
    end

    if (skillchain.font ~= nil) then
        skillchain.font:apply(skillchain.settings.font)
    end

    settings.save()
end)

-------------------------------------------------------------------------------
-- event handlers
-------------------------------------------------------------------------------

ashita.events.register('d3d_present', 'd3d_present_cb', function()
    local lines = { }
    local resx = AshitaCore:GetResourceManager()

    for _, mob in pairs(skillchain.chains) do
        if #mob.chain > 0 then
            -- Create the heading for our skillchain.
            table.insert(text, mob.name)

            -- Fill out the body of our skillchain.
            for _, chain in pairs(mob.chain) do
                -- Is this the first step of a chain? If so, don't show burstable
                -- elements (since you can't burst).
                if chain.type == ChainType.Starter then
                    local t1 = string.format('  > %s [%i dmg]', chain.name, chain.base_damage)
                    local t2 = string.format('    %s', chain.resonance)

                    table.insert(text, t1)
                    table.insert(text, t2)
                -- Otherwise, also display the bonus damage and burstable elements.
                elseif chain.type == ChainType.Skillchain then
                    local t1 = string.format('  > %s [%i + %i dmg]', chain.name, chain.base_damage, chain.bonus_damage or 0)
                    local t2 = string.format('    %s (%s)', chain.resonance, Elements[chain.resonance])

                    table.insert(text, t1)
                    table.insert(text, t2)
                -- Display any magic bursts that occurred and their damage.
                elseif chain.type == ChainType.MagicBurst then
                    local t = string.format('    Magic Burst! %s [%i dmg]', chain.name, chain.base_damage)

                    table.insert(text, t)
                elseif chain.type == ChainType.Miss then
                    local t = string.format('  ! %s missed.', chain.name)

                    table.insert(text, t)
                else -- chain.type == ChainType.Unknown
                end
            end

            -- Create the footer for our skillchain, noting the remaining window and
            -- including a spacer between the mobs.
            if mob.time ~= nil then
                local time_remaining = 8 - math.abs(mob.time - os.time())
                if time_remaining >= 0 then
                    table.insert(text, string.format('  > %is', time_remaining))
                else
                    table.insert(text, '  x')
                end
            end

            table.insert(text, '')
        end
    end

    -- Just clear out the last newline.
    lines[#lines] = nil
    skillchain.font.text = table.concat(lines, '\n')
end)

ashita.events.register('incoming_packet', 'incoming_packet_cb', function(e)
    if e.id == 0x28 then
        local action = lin.parse_action(e.data)

        if action.category == 3 then
            handle_weaponskill(action, skillchain.chains)
        elseif action.category == 4 then
            handle_magicability(action, skillchain.chains)
        elseif action.category == 13 then
            handle_petability(action, skillchain.chains)
        end
    end

    return false
end)

ashita.events.register('load', 'load_cb', function()
    skillchain.font = fonts.new(skillchain.settings.font)
end)

ashita.events.register('unload', 'unload_cb', function()
    if (skillchain.font ~= nil) then
        -- TODO: do we need to manually persist location changes?
        --       if so, maybe just :apply() to the settings object
        skillchain.font:destroy()
        skillchain.font = nil
    end

    settings.save()
end)
