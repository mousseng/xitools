-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'logger'
_addon.version = '1.0.0'

require 'utils'
require 'lin.packets'

-------------------------------------------------------------------------------
-- helper functions
-------------------------------------------------------------------------------

local function dump(id, str)
    local date = os.date('*t')
    local log_name = string.format('packets %04i.%02i.%02i.log', date.year, date.month, date.day)
    local log_dir = string.format('%s/%s/', AshitaCore:GetAshitaInstallPath(), 'packetlogs')

    if not ashita.file.dir_exists(log_dir) then
        ashita.file.create_dir(log_dir)
    end

    local log_file = io.open(string.format('%s/%s', log_dir, log_name), 'a')
    if log_file ~= nil then
        local header = string.format(
            '%s id %x\n',
            os.date('[%H:%M:%S]', os.time()),
            id)

        local footer = '\n\n'

        log_file:write(header .. str .. footer)
        log_file:close()
    end
end

local function write_action(action)
    local output =
        'actor_id: '     .. string.format('%i',   action.actor_id) .. ' (' .. GetEntityNameByServerId(action.actor_id) .. ')\n' ..
        'target_count: ' .. string.format('%i',   action.target_count) .. '\n' ..
        'category: '     .. string.format('0x%x', action.category)     .. '\n' ..
        'param: '        .. string.format('0x%x', action.param)        .. '\n' ..
        'recast: '       .. string.format('%i',   action.recast)       .. '\n' ..
        'unknown: '      .. string.format('%i',   action.unknown)      .. '\n' ..
        'targets:\n'

    for i = 1, action.target_count do
        output = output ..
            '    id: '           .. tostring(action.targets[i].id) .. ' (' .. GetEntityNameByServerId(action.targets[i].id) .. ')\n' ..
            '    action_count: ' .. tostring(action.targets[i].action_count) .. '\n' ..
            '    actions:\n'

        for j = 1, action.targets[i].action_count do
            output = output ..
                '        reaction: '               .. tostring(action.targets[i].actions[j].reaction) .. '\n' ..
                '        animation: '              .. tostring(action.targets[i].actions[j].animation) .. '\n' ..
                '        effect: '                 .. tostring(action.targets[i].actions[j].effect) .. '\n' ..
                '        stagger: '                .. tostring(action.targets[i].actions[j].stagger) .. '\n' ..
                '        param: '                  .. tostring(action.targets[i].actions[j].param) .. '\n' ..
                '        message: '                .. tostring(action.targets[i].actions[j].message) .. '\n' ..
                '        unknown: '                .. tostring(action.targets[i].actions[j].unknown) .. '\n' ..
                '        has_add_effect: '         .. tostring(action.targets[i].actions[j].has_add_effect) .. '\n' ..
                '        add_effect_animation: '   .. tostring(action.targets[i].actions[j].add_effect_animation) .. '\n' ..
                '        add_effect_effect: '      .. tostring(action.targets[i].actions[j].add_effect_effect) .. '\n' ..
                '        add_effect_param: '       .. tostring(action.targets[i].actions[j].add_effect_param) .. '\n' ..
                '        add_effect_message: '     .. tostring(action.targets[i].actions[j].add_effect_message) .. '\n' ..
                '        has_spike_effect: '       .. tostring(action.targets[i].actions[j].has_spike_effect) .. '\n' ..
                '        spike_effect_animation: ' .. tostring(action.targets[i].actions[j].spike_effect_animation) .. '\n' ..
                '        spike_effect_effect: '    .. tostring(action.targets[i].actions[j].spike_effect_effect) .. '\n' ..
                '        spike_effect_param: '     .. tostring(action.targets[i].actions[j].spike_effect_param) .. '\n' ..
                '        spike_effect_message: '   .. tostring(action.targets[i].actions[j].spike_effect_message) .. '\n'

            if j < action.targets[i].action_count then
                output = output .. '\n'
            end
        end

        if i < action.target_count then
            output = output .. '\n'
        end
    end

    dump(0x0028, output)
end

local function write_basic(basic)
    local output =
        'sender: '     .. string.format('%i', basic.sender) .. '\n' ..
        'target: '     .. string.format('%i', basic.target) .. '\n' ..
        'sender_tgt: ' .. string.format('%i', basic.sender_tgt) .. '\n' ..
        'target_tgt: ' .. string.format('%i', basic.target_tgt) .. '\n' ..
        'param: '      .. string.format('%i (0x%x)', basic.param, basic.param) .. '\n' ..
        'value: '      .. string.format('%i (0x%x)', basic.value, basic.value) .. '\n' ..
        'message: '    .. string.format('%i (0x%x)', basic.message, basic.message) .. '\n'

    dump(0x0029, output)
end

-------------------------------------------------------------------------------
-- event handlers
-------------------------------------------------------------------------------

ashita.register_event('incoming_packet', function(id, size, data)
    if id == 0x0028 then
        local packet = lin.parse_action(data)
        if packet.category == 0 or packet.category == 1 then return false end
        write_action(packet)
    elseif id == 0x0029 then
        write_basic(lin.parse_basic(data))
    end

    return false
end)
