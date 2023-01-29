local ffxi = require('utils.ffxi')
local imgui = require('imgui')
local packets = require('utils.packets')

local function Dump(id, str)
    local date = os.date('*t')
    local log_name = string.format('packets %04i.%02i.%02i.log', date.year, date.month, date.day)
    local log_dir = string.format('%s/%s/', AshitaCore:GetInstallPath(), 'packetlogs')

    if not ashita.fs.exists(log_dir) then
        ashita.fs.create_dir(log_dir)
    end

    local log_file = io.open(string.format('%s/%s', log_dir, log_name), 'a')
    if log_file ~= nil then
        local header = string.format(
            '%s id %s\n',
            os.date('[%H:%M:%S]', os.time()),
            id)

        local footer = '\n\n'

        log_file:write(header .. str .. footer)
        log_file:close()
    end
end

local function WriteAction(action)
    local output =
        'actor_id: '     .. string.format('%i',   action.actor_id) .. ' (' .. ffxi.GetEntityNameByServerId(action.actor_id) .. ')\n' ..
        'target_count: ' .. string.format('%i',   action.target_count) .. '\n' ..
        'category: '     .. string.format('0x%x', action.category)     .. '\n' ..
        'param: '        .. string.format('0x%x', action.param)        .. '\n' ..
        'recast: '       .. string.format('%i',   action.recast)       .. '\n' ..
        'unknown: '      .. string.format('%i',   action.unknown)      .. '\n' ..
        'targets:\n'

    for i = 1, action.target_count do
        output = output ..
            '    id: '           .. tostring(action.targets[i].id) .. ' (' .. ffxi.GetEntityNameByServerId(action.targets[i].id) .. ')\n' ..
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

    Dump('in 0x028', output)
end

local function WriteBasic(basic)
    local output =
        'sender: '     .. string.format('%i', basic.sender) .. '\n' ..
        'target: '     .. string.format('%i', basic.target) .. '\n' ..
        'sender_tgt: ' .. string.format('%i', basic.sender_tgt) .. '\n' ..
        'target_tgt: ' .. string.format('%i', basic.target_tgt) .. '\n' ..
        'param: '      .. string.format('%i (0x%x)', basic.param, basic.param) .. '\n' ..
        'value: '      .. string.format('%i (0x%x)', basic.value, basic.value) .. '\n' ..
        'message: '    .. string.format('%i (0x%x)', basic.message, basic.message) .. '\n'

    Dump('in 0x029', output)
end

local function WriteSpecial(special)
    local output =
        string.format('sender: %i\n', special.sender) ..
        string.format('param1: %i\n', special.param1) ..
        string.format('param2: %i\n', special.param2) ..
        string.format('param3: %i\n', special.param3) ..
        string.format('param4: %i\n', special.param4) ..
        string.format('senderIdx: %i\n', special.senderIdx) ..
        string.format('message: %i (0x%x)\n', special.message, special.message)

    Dump('in 0x02A', output)
end

local function WriteSynthAnimation(synthAnim)
    local output =
        string.format('player: %i', synthAnim.player) .. '\n' ..
        string.format('playerIdx: %i', synthAnim.playerIdx) .. '\n' ..
        string.format('effect: %i', synthAnim.effect) .. '\n' ..
        string.format('param: %i', synthAnim.param) .. '\n' ..
        string.format('animation: %i', synthAnim.animation) .. '\n'

    Dump('in 0x030', output)
end

local function WriteSkillsUpdate(skillsUpdate)
    local output = 'combatSkills:\n'
    for i, combat in pairs(skillsUpdate.combatSkills) do
        output = output .. string.format('    level: %i, isCapped: %s', combat.level, combat.isCapped) .. '\n'
    end

    output = output .. 'craftSkills:\n'
    for i, craft in pairs(skillsUpdate.craftSkills) do
        output = output .. string.format('    rank: %i, level: %i, isCapped: %s', craft.rank, craft.level, craft.isCapped) .. '\n'
    end

    Dump('in 0x062', output)
end

local function WriteSelfSynth(synth)
    local output =
        string.format('result: %i', synth.result) .. '\n' ..
        string.format('quality: %i', synth.quality) .. '\n' ..
        string.format('count: %i', synth.count) .. '\n' ..
        string.format('item: %i', synth.item) .. '\n' ..
        'lost:' .. '\n' ..
        string.format('    item: %i', synth.lost[1]) .. '\n' ..
        string.format('    item: %i', synth.lost[2]) .. '\n' ..
        string.format('    item: %i', synth.lost[3]) .. '\n' ..
        string.format('    item: %i', synth.lost[4]) .. '\n' ..
        string.format('    item: %i', synth.lost[5]) .. '\n' ..
        string.format('    item: %i', synth.lost[6]) .. '\n' ..
        string.format('    item: %i', synth.lost[7]) .. '\n' ..
        string.format('    item: %i', synth.lost[8]) .. '\n' ..
        'skill:' .. '\n' ..
        string.format('    skillId: %i, isSkillupAllowed: %s, isDesynth: %s', synth.skill[1].skillId, synth.skill[1].isSkillupAllowed, synth.skill[1].isDesynth) .. '\n' ..
        string.format('    skillId: %i, isSkillupAllowed: %s, isDesynth: %s', synth.skill[2].skillId, synth.skill[2].isSkillupAllowed, synth.skill[2].isDesynth) .. '\n' ..
        string.format('    skillId: %i, isSkillupAllowed: %s, isDesynth: %s', synth.skill[3].skillId, synth.skill[3].isSkillupAllowed, synth.skill[3].isDesynth) .. '\n' ..
        string.format('    skillId: %i, isSkillupAllowed: %s, isDesynth: %s', synth.skill[4].skillId, synth.skill[4].isSkillupAllowed, synth.skill[4].isDesynth) .. '\n' ..
        'skillup:' .. '\n' ..
        string.format('    value: %i', synth.skillup[1]) .. '\n' ..
        string.format('    value: %i', synth.skillup[2]) .. '\n' ..
        string.format('    value: %i', synth.skillup[3]) .. '\n' ..
        string.format('    value: %i', synth.skillup[4]) .. '\n' ..
        string.format('crystal: %i', synth.crystal) .. '\n'

    Dump('in 0x06F', output)
end

local function WriteOtherSynth(synth)
    local output =
        string.format('result: %i', synth.result) .. '\n' ..
        string.format('quality: %i', synth.quality) .. '\n' ..
        string.format('count: %i', synth.count) .. '\n' ..
        string.format('item: %i', synth.item) .. '\n' ..
        'lost:' .. '\n' ..
        string.format('    item: %i', synth.lost[1]) .. '\n' ..
        string.format('    item: %i', synth.lost[2]) .. '\n' ..
        string.format('    item: %i', synth.lost[3]) .. '\n' ..
        string.format('    item: %i', synth.lost[4]) .. '\n' ..
        string.format('    item: %i', synth.lost[5]) .. '\n' ..
        string.format('    item: %i', synth.lost[6]) .. '\n' ..
        string.format('    item: %i', synth.lost[7]) .. '\n' ..
        string.format('    item: %i', synth.lost[8]) .. '\n' ..
        'skill:' .. '\n' ..
        string.format('    skillId: %i, isSkillupAllowed: %s, isDesynth: %s', synth.skill[1].skillId, synth.skill[1].isSkillupAllowed, synth.skill[1].isDesynth) .. '\n' ..
        string.format('    skillId: %i, isSkillupAllowed: %s, isDesynth: %s', synth.skill[2].skillId, synth.skill[2].isSkillupAllowed, synth.skill[2].isDesynth) .. '\n' ..
        string.format('    skillId: %i, isSkillupAllowed: %s, isDesynth: %s', synth.skill[3].skillId, synth.skill[3].isSkillupAllowed, synth.skill[3].isDesynth) .. '\n' ..
        string.format('    skillId: %i, isSkillupAllowed: %s, isDesynth: %s', synth.skill[4].skillId, synth.skill[4].isSkillupAllowed, synth.skill[4].isDesynth) .. '\n' ..
        string.format('playerName: %s', synth.playerName) .. '\n'

    Dump('in 0x070', output)
end

local function WriteStartSynth(synth)
    local output =
        string.format('crystal: %i', synth.crystal) .. '\n' ..
        string.format('crystalIdx: %i', synth.crystalIdx) .. '\n' ..
        string.format('ingredientCount: %i', synth.ingredientCount) .. '\n' ..
        'ingredient:' .. '\n' ..
        string.format('    item: %i', synth.ingredient[0]) .. '\n' ..
        string.format('    item: %i', synth.ingredient[1]) .. '\n' ..
        string.format('    item: %i', synth.ingredient[2]) .. '\n' ..
        string.format('    item: %i', synth.ingredient[3]) .. '\n' ..
        string.format('    item: %i', synth.ingredient[4]) .. '\n' ..
        string.format('    item: %i', synth.ingredient[5]) .. '\n' ..
        string.format('    item: %i', synth.ingredient[6]) .. '\n' ..
        string.format('    item: %i', synth.ingredient[7]) .. '\n' ..
        'ingredientIdx:' .. '\n' ..
        string.format('    index: %i', synth.ingredientIdx[0]) .. '\n' ..
        string.format('    index: %i', synth.ingredientIdx[1]) .. '\n' ..
        string.format('    index: %i', synth.ingredientIdx[2]) .. '\n' ..
        string.format('    index: %i', synth.ingredientIdx[3]) .. '\n' ..
        string.format('    index: %i', synth.ingredientIdx[4]) .. '\n' ..
        string.format('    index: %i', synth.ingredientIdx[5]) .. '\n' ..
        string.format('    index: %i', synth.ingredientIdx[6]) .. '\n' ..
        string.format('    index: %i', synth.ingredientIdx[7]) .. '\n'

    Dump('out 0x096', output)
end

local function DispatchPacketOut(e)
    if e.id == 0x096 then
        local packet = packets.outbound.startSynth.parse(e.data)
        WriteStartSynth(packet)
    end
end

local function DispatchPacketIn(e)
    if e.id == 0x028 then
        local packet = packets.inbound.action.parse(e.data_modified_raw)
        if packet.category == 0 or packet.category == 1 then return false end
        WriteAction(packet)
    elseif e.id == 0x029 then
        WriteBasic(packets.inbound.basic.parse(e.data))
    elseif e.id == 0x02A then
        WriteSpecial(packets.inbound.special.parse(e.data))
    elseif e.id == 0x030 then
        WriteSynthAnimation(packets.inbound.synthAnimation.parse(e.data))
    elseif e.id == 0x062 then
        WriteSkillsUpdate(packets.inbound.charSkills.parse(e.data))
    elseif e.id == 0x06F then
        WriteSelfSynth(packets.inbound.synthResultPlayer.parse(e.data))
    elseif e.id == 0x070 then
        WriteOtherSynth(packets.inbound.synthResultOther.parse(e.data))
    end
end

---@type xitool
local logger = {
    Name = 'logger',
    Load = function(options) end,
    HandlePacketOut = function(e, options)
        if options.loggedPackets.outbound[e.id] and options.loggedPackets.outbound[e.id][1] then
            DispatchPacketOut(e)
        end
    end,
    HandlePacket = function(e, options)
        if options.loggedPackets.inbound[e.id] and options.loggedPackets.inbound[e.id][1] then
            DispatchPacketIn(e)
        end
    end,
    DrawConfig = function(options)
        if imgui.BeginTabItem('log') then
            imgui.Checkbox('Enabled', options.isEnabled)

            imgui.Text('Inbound Packets')
            imgui.Separator()
            for _, packet in pairs(packets.inbound.sorted) do
                if options.loggedPackets.inbound[packet.id] then
                    imgui.Checkbox(packet.name, options.loggedPackets.inbound[packet.id])
                end
            end

            imgui.Text('Outbound Packets')
            imgui.Separator()
            for _, packet in pairs(packets.outbound.sorted) do
                if options.loggedPackets.outbound[packet.id] then
                    imgui.Checkbox(packet.name, options.loggedPackets.outbound[packet.id])
                end
            end
            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options) end,
}

return logger
