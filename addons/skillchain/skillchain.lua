-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'skillchain'
_addon.version = '1.0.0-beta'
_addon.unique  = '__skillchain_addon'

require 'skillchain_data'
require 'skillchain_packethandler'
require 'lin.text'
require 'lin.packets'

local config = { x = 100, y = 100, debug = false }
local chains = { }

-------------------------------------------------------------------------------
-- event handlers
-------------------------------------------------------------------------------

ashita.register_event('render', function()
    local font = AshitaCore:GetFontManager():Get(_addon.unique)
    local resx = AshitaCore:GetResourceManager()
    local text = { }

    for _, mob in pairs(chains) do
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
    text[#text] = nil
    font:SetText(table.concat(text, '\n'))
end)

ashita.register_event('incoming_packet', function (id, size, packet)
    if id == 0x0028 then
        local action = lin.parse_action(packet)

        if action.category == 3 then
            handle_weaponskill(action, chains)
        elseif action.category == 4 then
            handle_magicability(action, chains)
        elseif action.category == 13 then
            handle_petability(action, chains)
        end
    end

    return false
end)

ashita.register_event('command', function(cmd, ntype)
    local args = cmd:args()

    if args[1] ~= '/sc' or #args == 1 then
        return false
    end

    if #args[2] == 'debug' then
        config.debug = not config.debug
    end

    return false
end)

ashita.register_event('load', function()
    local font = AshitaCore:GetFontManager():Create(_addon.unique)
    config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', config)

    font:SetColor(0xFFFFFFFF)
    font:SetFontFamily('Consolas')
    font:SetFontHeight(10)
    font:SetBold(false)
    font:SetPositionX(config.x)
    font:SetPositionY(config.y)
    font:SetVisibility(true)
    font:GetBackground():SetColor(0xA0000000)
    font:GetBackground():SetVisibility(true)
end)

ashita.register_event('unload', function()
    config.x = AshitaCore:GetFontManager():Get(_addon.unique):GetPositionX()
    config.y = AshitaCore:GetFontManager():Get(_addon.unique):GetPositionY()

    AshitaCore:GetFontManager():Delete(_addon.unique)

    ashita.settings.save(_addon.path .. 'settings/settings.json', config)
end)
