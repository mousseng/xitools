local MID_BOSSES = {
    [0] = 'Glassy Thinker',
    [1] = 'Glassy Craver',
    [2] = 'Glassy Gorger',
}

local BIG_BOSSES = {
    [0] = 'Kin',
    [1] = 'Gin',
    [2] = 'Kei',
    [3] = 'Kyou',
    [4] = 'Fu',
    [5] = 'Ou',
}

---Clears the state for when players are moved to the next floor
---@param msg   OmenMessage
---@param state OmenObjectives
local function moveToNewFloor(msg, state)
    state.transient = {}
    state.mainTimer = state.mainTimer + (msg.params[1] * 60)
    state.floorTimer = 0
    state.floor = {
        summary = 'no floor objective yet',
        status  = 'pending',
    }
end

---Updates the summary with a parameterless message
---@param msg   OmenMessage
---@param state OmenObjectives
local function updateSummary0(msg, state)
    state.floor.summary = msg.summary
end

---Updates the summary with a 1-parameter message
---@param msg   OmenMessage
---@param state OmenObjectives
local function updateSummary1(msg, state)
    state.floor.summary = msg.summary:format(msg.params[1])
end

---Updates the summary for the mid-boss
---@param msg   OmenMessage
---@param state OmenObjectives
local function updateSummaryMid(msg, state)
    local bossName = MID_BOSSES[msg.params[1]]
    state.floor.summary = msg.summary:format(bossName)
end

---Updates the summary for the final boss
---@param msg   OmenMessage
---@param state OmenObjectives
local function updateSummaryBig(msg, state)
    local bossName = BIG_BOSSES[msg.params[1]]
    state.floor.summary = msg.summary:format(bossName)
end

---Updates the floor timer with the remaining seconds
---@param msg   OmenMessage
---@param state OmenObjectives
local function updateFloorTimer(msg, state)
    state.floorTimer = msg.params[1]
end

--[[
-- for transient obj, param4 seems to indicate status:
--   0 = new
--   1 = success
--   2 = failed
--   3 = update
--]]

---Sets or updates a 1-parameter transient objective
---@param msg   OmenMessage
---@param state OmenObjectives
local function updateTransientObjective1(msg, state)
    local objNum = msg.params[1]
    local obj = state.transient[objNum]

    if obj == nil then
        state.transient[objNum] = {
            summary = msg.summary,
            status  = 'pending',
            cur     = 0,
            max     = msg.params[2],
        }
    elseif msg.params[4] == 1 then
        obj.cur = msg.params[2]
        obj.status = 'success'
    elseif msg.params[4] == 2 then
        obj.cur = msg.params[2]
        obj.status = 'failure'
    elseif msg.params[4] == 3 then
        obj.cur = msg.params[2]
    end
end

---Sets or updates a 2-parameter transient objective
---@param msg   OmenMessage
---@param state OmenObjectives
local function updateTransientObjective2(msg, state)
    local objNum = msg.params[1]
    local obj = state.transient[objNum]

    if obj == nil then
        state.transient[objNum] = {
            summary = msg.summary:format(msg.params[2]),
            status  = 'pending',
            cur     = 0,
            max     = msg.params[3],
        }
    elseif msg.params[4] == 1 then
        obj.cur = msg.params[3]
        obj.status = 'success'
    elseif msg.params[4] == 2 then
        obj.cur = msg.params[3]
        obj.status = 'failure'
    elseif msg.params[4] == 3 then
        obj.cur = msg.params[3]
    end
end

---@type OmenMessageTemplate[]
local messages = {
    [7324] = {
        text = "Your stay has been extended by # minute[/s].",
        func = moveToNewFloor,
    },
    [7330] = {
        summary = 'Vanquish all transcended foes',
        text = "Vanquish all transcended foes.",
        func = updateSummary0,
    },
    [7331] = {
        summary = 'Vanquish %d sweetwater foes',
        text = "Vanquish # sweetwater foe[/s].",
        func = updateSummary1,
    },
    [7332] = {
        summary = 'Vanquish 1 specific monster',
        text = "Vanquish 1 specific monster.",
        func = updateSummary0,
    },
    [7333] = {
        summary = 'Vanquish all monsters',
        text = "Vanquish all monsters.",
        func = updateSummary0,
    },
    [7334] = {
        summary = 'Free floor!',
        text = "The light shall come even if you fail to obey.",
        func = updateSummary0,
    },
    [7335] = {
        summary = 'Vanquish %s',
        text = "Vanquish the [Glassy Thinker/Glassy Craver/Glassy Gorger].",
        func = updateSummaryMid,
    },
    [7336] = {
        summary = 'Vanquish %s',
        text = "Vanquish [Kin/Gin/Kei/Kyou/Fu/Ou].",
        func = updateSummaryBig,
    },
    [7337] = {
        summary = 'Open %d treasure portents',
        text = "Open # treasure portent[/s].",
        func = updateSummary1,
    },
    [7338] = {
        text = "A spectral light flares up.",
        func = function(msg, state)
            state.floor.status = 'success'
        end,
    },
    -- [7339]
    -- [7340]
    [7341] = {
        text = "Follow the light and carry out your charge before time runs out. You have # second[/s] remaining.",
        func = updateFloorTimer,
    },
    [7342] = {
        text = "Carry out your charge before time runs out. You have # second[/s] remaining.",
        func = updateFloorTimer,
    },
    -- [7343]
    -- [7344]
    [7345] = {
        summary = 'Perform a multi-step skillchain',
        text = "#: [Execute/You have executed/You have failed to execute/You have executed] # skillchain[/s] using weapon skills on your foes!",
        func = updateTransientObjective1,
    },
    [7346] = {
        summary = 'Deal critical hits',
        text = "#: [Deal/You have dealt/You have failed to deal/You have dealt] # critical hit[/s] to your foes.",
        func = updateTransientObjective1,
    },
    [7347] = {
        summary = 'Vanquish foes',
        text = "#: [Vanquish/You have vanquished/You have failed to vanquish/You have vanquished] # foe[/s].",
        func = updateTransientObjective1,
    },
    [7348] = {
        summary = 'Cast spells',
        text = "#: [Cast/You have cast/You have failed to cast/You have cast] # spell[/s] on your foes.",
        func = updateTransientObjective1,
    },
    [7349] = {
        summary = 'Use abilities',
        text = "#: [Use/You have used/You have failed to use/You have used] # [ability/abilities] on your foes.",
        func = updateTransientObjective1,
    },
    [7350] = {
        summary = 'Use physical weaponskills',
        text = "#: [Use/You have used/You have failed to use/You have used] # physical weapon skill[/s] on your foes.",
        func = updateTransientObjective1,
    },
    [7351] = {
        summary = 'Use elemental weaponskills',
        text = "#: [Use/You have used/You have failed to use/You have used] # elemental weapon skill[/s] on your foes.",
        func = updateTransientObjective1,
    },
    [7352] = {
        summary = 'Use weaponskills',
        text = "#: [Use/You have used/You have failed to use/You have used] # weapon skill[/s] on your foes.",
        func = updateTransientObjective1,
    },
    [7353] = {
        summary = 'Perform magic bursts',
        text = "#: [Perform/You have performed/You have failed to perform/You have performed] # magic burst[/s] on your foes.",
        func = updateTransientObjective1,
    },
    [7354] = {
        summary = 'Deal damage in one attack round',
        text = "#: [Reduce/You have reduced/You have failed to reduce/You have reduced] your foe's HP by at least # in a single auto-attack.",
        func = updateTransientObjective1,
    },
    [7355] = {
        summary = 'Deal exact damage in one attack round',
        text = "#: [Reduce/You have reduced/You have failed to reduce/You have reduced] your foe's HP by # in a single auto-attack.",
        func = updateTransientObjective1,
    },
    [7356] = {
        summary = 'Deal damage in one weaponskill',
        text = "#: [Reduce/You have reduced/You have failed to reduce/You have reduced] your foe's HP by at least # using a single weapon skill.",
        func = updateTransientObjective1,
    },
    [7357] = {
        summary = 'Deal exact damage in one weaponskill',
        text = "#: [Reduce/You have reduced/You have failed to reduce/You have reduced] your foe's HP by # using a single weapon skill.",
        func = updateTransientObjective1,
    },
    [7358] = {
        summary = 'Deal damage in one non-burst spell',
        text = "#: [Reduce/You have reduced/You have failed to reduce/You have reduced] your foe's HP by at least # using a single magic attack without performing a magic burst.",
        func = updateTransientObjective1,
    },
    [7359] = {
        summary = 'Deal exact damage in one non-burst spell',
        text = "#: [Reduce/You have reduced/You have failed to reduce/You have reduced] your foe's HP by # using a single magic attack without performing a magic burst.",
        func = updateTransientObjective1,
    },
    [7360] = {
        summary = 'Deal damage in one magic burst',
        text = "#: [Reduce/You have reduced/You have failed to reduce/You have reduced] your foe's HP by at least # using a single magic burst.",
        func = updateTransientObjective1,
    },
    [7361] = {
        summary = 'Deal exact damage in one magic burst',
        text = "#: [Reduce/You have reduced/You have failed to reduce/You have reduced] your foe's HP by # using a single magic burst.",
        func = updateTransientObjective1,
    },
    [7362] = {
        summary = 'Restore %d HP',
        text = "#: [Restore/You have restored/You have failed to restore/You have restored] at least # HP # time[/s].",
        func = updateTransientObjective2,
    },
}

return messages
