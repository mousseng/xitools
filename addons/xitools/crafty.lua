require('common')
local bit = require('bit')
local imgui = require('imgui')
local packets = require('utils.packets')
local recipesByIngredients = require('data.recipesByIngredients')
local recipesBySkill = require('data.recipesBySkill')
local ui = require('ui')

local iconTimes = '\xef\x81\x97'
local iconCheck = '\xef\x81\x98'
local imguiLeafNode = bit.bor(ImGuiTreeNodeFlags_Leaf, ImGuiTreeNodeFlags_NoTreePushOnOpen)
local textBaseWidth = imgui.CalcTextSize('A')
local inProgSynth = nil

local skillsMap = {
    [0] = 'Fishing',
    [1] = 'Woodworking',
    [2] = 'Smithing',
    [3] = 'Goldsmithing',
    [4] = 'Clothcraft',
    [5] = 'Leathercraft',
    [6] = 'Bonecraft',
    [7] = 'Alchemy',
    [8] = 'Cooking',
}

local skillsAbbrMap = {
    [0] = 'FSH',
    [1] = 'CRP',
    [2] = 'BSM',
    [3] = 'GSM',
    [4] = 'WVR',
    [5] = 'LTW',
    [6] = 'BON',
    [7] = 'ALC',
    [8] = 'CUL',
}

local resultsMap = {
    [0] = 'NQ',
    [1] = 'Fail',
    [2] = 'HQ1',
    [3] = 'HQ2',
    [4] = 'HQ3',
}

-- this is probably too expensive to be running as often as we are, but fuck it
local function GetInventoryTotals()
    local inv = AshitaCore:GetMemoryManager():GetInventory()
    local cumInv = {}
    for i = 0, inv:GetContainerCount(0) do
        local slot = inv:GetContainerItem(0, i)
        if cumInv[slot.Id] == nil then
            cumInv[slot.Id] = slot.Count
        else
            cumInv[slot.Id] = cumInv[slot.Id] + slot.Count
        end
    end

    return cumInv
end

local skillDisplay = '%-13s %5.1f'
local function DrawSkills(skills)
    imgui.PushStyleVar(ImGuiStyleVar_CellPadding, { 20, 2 })
    if imgui.BeginTable('xitool.crafty.skills', 2, ImGuiTableFlags_SizingFixedFit) then
        for id, skill in pairs(skillsMap) do
            imgui.TableNextColumn()
            imgui.Text(skillDisplay:format(skill, skills[id][1]))
        end
        imgui.EndTable()
    end
    imgui.PopStyleVar()
end

local function DrawRecipe(recipe, skills, inv, res)
    for skillId, skillLevel in ipairs(recipe.skills) do
        if skillLevel > 0 then
            local indicator = iconTimes
            if skills[skillId][1] + 14 > skillLevel then
                indicator = iconCheck
                imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.StatusGreen)
            else
                imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.StatusRed)
            end
            imgui.TreeNodeEx(('%s %s %i'):format(indicator, skillsMap[skillId], skillLevel), imguiLeafNode)
            imgui.PopStyleColor()
        end
    end

    if recipe.keyItem > 0 then
        local hasKeyItem = AshitaCore:GetMemoryManager():GetPlayer():HasKeyItem(recipe.keyItem)
        local keyItemName = res:GetString('keyitems.names', recipe.keyItem)
        local indicator = iconTimes
        if hasKeyItem then
            indicator = iconCheck
            imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.StatusGreen)
        else
            imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.StatusRed)
        end
        imgui.TreeNodeEx(('%s %s'):format(indicator, keyItemName), imguiLeafNode)
        imgui.PopStyleColor()
    end

    local crystalCount = inv[recipe.crystal] or 0
    local crystalName = res:GetItemById(recipe.crystal).LogNameSingular[1]
    imgui.TreeNodeEx(('(%3i) %s'):format(crystalCount, crystalName), imguiLeafNode)

    for _, ingredientId in ipairs(recipe.ingredients) do
        local ingredientCount = inv[ingredientId] or 0
        local ingredientName = res:GetItemById(ingredientId).LogNameSingular[1]
        imgui.TreeNodeEx(('(%3i) %s'):format(ingredientCount, ingredientName), imguiLeafNode)
    end
end

local recipeFilter = { '' }
local searchResults = T{ [''] = T{ } }
local function FilterRecipes(filter)
    local res = AshitaCore:GetResourceManager()
    if searchResults[filter] == nil then
        searchResults[filter] = T{ }
        for skillId, recipeList in ipairs(recipesBySkill) do
            for _, recipe in ipairs(recipeList) do
                -- the abbreviated names are not always conducive to search, so we
                -- will test against both it and the full name
                local item = res:GetItemById(recipe.result)
                local itemName = item.Name[1]
                local fullName = item.LogNameSingular[1]
                if itemName:lower():match(filter)
                or fullName:lower():match(filter) then
                    searchResults[filter]:append(recipe)
                end
            end
        end
    end
end

local function DrawFilteredRecipes(skills, filteredRecipes)
    -- there are thousands of recipes in the game, and drawing all of them in
    -- imgui is going to be a huge performance hit. we could certainly limit the
    -- search to >2 characters, but i feel it's better to just truncate the list
    local res = AshitaCore:GetResourceManager()
    local inv = GetInventoryTotals()
    local displayCount = math.min(32, #filteredRecipes)

    for i=1,displayCount do
        local recipe = filteredRecipes[i]
        local itemName = res:GetItemById(recipe.result).LogNameSingular[1]

        imgui.PushID(('%s%i'):format(recipe.result, recipe.id))
        if imgui.TreeNode(('%s x%i'):format(itemName, recipe.count)) then
            DrawRecipe(recipe, skills, inv, res)
            imgui.TreePop()
        end
        imgui.PopID()
    end

    if #filteredRecipes > 32 then
        imgui.TreeNodeEx(('%i recipes found; results truncated'):format(#filteredRecipes), imguiLeafNode)
    end
end

local function DrawRecipes(skills)
    if imgui.CollapsingHeader('Recipe List') then
        if imgui.InputText('search recipes', recipeFilter, 256) then
            FilterRecipes(recipeFilter[1]:lower())
        end

        DrawFilteredRecipes(skills, searchResults[recipeFilter[1]])
    end
end

local function DrawHistory(history)
    if imgui.CollapsingHeader('Craft History') then
        if imgui.BeginTable('xitool.crafty.history', 3, ImGuiTableFlags_ScrollY, { textBaseWidth * 60, 400 }) then
            local res = AshitaCore:GetResourceManager()
            imgui.TableSetupScrollFreeze(0, 1)
            imgui.TableSetupColumn('Synth', ImGuiTableColumnFlags_NoHide, textBaseWidth * 30)
            imgui.TableSetupColumn('Result', ImGuiTableColumnFlags_NoHide, textBaseWidth * 10)
            imgui.TableSetupColumn('Skillup', ImGuiTableColumnFlags_NoHide, textBaseWidth * 20)
            imgui.TableHeadersRow()

            for i, synth in pairs(history) do
                imgui.TableNextRow()

                imgui.TableNextColumn()
                if synth.count > 1 then
                    imgui.Text(('%s x%i'):format(res:GetItemById(synth.item).Name[1] or synth.item, synth.count))
                else
                    imgui.Text(('%s'):format(res:GetItemById(synth.item).Name[1] or synth.item))
                end

                imgui.TableNextColumn()
                imgui.Text(('%s'):format(resultsMap[synth.result] or 'Unknown'))

                imgui.TableNextColumn()
                if synth.skillup ~= nil then
                    imgui.Text(('%s %+.1f'):format(skillsMap[synth.skillup.skillId] or synth.skillup.skillId, synth.skillup.change))
                end

                for _, itemId in pairs(synth.lost) do
                    imgui.TableNextRow()
                    imgui.TableNextColumn()
                    imgui.Text(('    lost %s'):format(res:GetItemById(itemId).Name[1] or itemId))
                end
            end
            imgui.EndTable()
        end
    end
end

local function DrawCraft(skillId)
end

---@type xitool
local crafty = {
    Name = 'crafty',
    Load = function(options) end,
    HandlePacketOut = function(e, options)
        -- if we've requested a synth from the server, start our in-progress
        -- tracker. speculate on the results, since "Mangled Mess" isn't a very
        -- useful item name.
        if e.id == 0x096 and inProgSynth == nil then
            local startSynth = packets.outbound.startSynth.parse(e.data)
            local crystal = startSynth.crystal
            local sortedIngredients = T{}
            for i=0,startSynth.ingredientCount-1 do
                if startSynth.ingredient[i] ~= 0 then
                    sortedIngredients:append(startSynth.ingredient[i])
                end
            end
            local ingredientHash = sortedIngredients:sort():join(',')
            local targetRecipe = recipesByIngredients[crystal][ingredientHash] or { itemId = 0, count = 0 }

            inProgSynth = {
                startTime = os.time(),
                result = nil,
                item = targetRecipe.itemId,
                count = targetRecipe.count,
                lost = nil,
                skillup = nil,
            }
        end
    end,
    HandlePacket = function(e, options)
        -- we are immediately told what the result is via the animation the
        -- server wants us to play, and also get a more detailed value
        if e.id == 0x030 then
            local anim = packets.inbound.synthAnimation.parse(e.data)
            local player = GetPlayerEntity()
            if player ~= nil and anim.player == player.ServerId and inProgSynth ~= nil then
                inProgSynth.result = anim.param
            end
        -- sometimes the result response will come immediately (a cancel), and
        -- sometimes you have to wait 15 seconds. regardless, one SHOULD come.
        elseif e.id == 0x06F then
            local synth = packets.inbound.synthResultPlayer.parse(e.data)
            -- if the server cancels our synth, nil out the in-progress object
            if synth.result == 3 or synth.result == 4 or synth.result == 6 or synth.result == 7 then
                inProgSynth = nil
            -- otherwise, update with the real results and push it to the GUI
            elseif inProgSynth ~= nil and inProgSynth.startTime then
                -- we don't want to replace the synth name with Mangled Mess if
                -- a good item ID was found during the request
                if synth.item ~= 29695 or inProgSynth.item == 0 then
                    inProgSynth.item = synth.item
                    inProgSynth.count = synth.count
                end
                inProgSynth.lost = T{}
                for _, itemId in pairs(synth.lost) do
                    if itemId > 0 then
                        inProgSynth.lost:append(itemId)
                    end
                end

                table.insert(options.history, 1, inProgSynth)
                inProgSynth = nil
            end
        -- skillups come after the results, but won't always appear. so we
        -- don't wait for them, just update the most recent completed synth
        -- with whatever skillup we get
        elseif e.id == 0x029 then
            local basic = packets.inbound.basic.parse(e.data)
            if basic.param < 48 or basic.param > 57 then return end

            local player = GetPlayerEntity()
            if basic.message == 38 and player ~= nil and basic.target == player.ServerId then
                local latestSynth = options.history:first()
                latestSynth.skillup = {
                    skillId = basic.param - 48,
                    change = basic.value / 10,
                }

                options.skills[basic.param - 48][1] = options.skills[basic.param - 48][1] + (basic.value / 10)
            elseif basic.message == 310 and player ~= nil and basic.target == player.ServerId then
                local latestSynth = options.history:first()
                latestSynth.skillup = {
                    skillId = basic.param - 48,
                    change = -basic.value / 10,
                }

                options.skills[basic.param - 48][1] = options.skills[basic.param - 48][1] - (basic.value / 10)
            end
        end
    end,
    DrawConfig = function(options)
        if imgui.BeginTabItem('crafty') then
            imgui.Checkbox('Enabled', options.isEnabled)

            for id, skill in pairs(skillsMap) do
                imgui.InputFloat(skill, options.skills[id], 0.1, 0.1, '%.1f')
            end

            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options)
        ui.DrawNormalWindow(options, function()
            DrawSkills(options.skills)
            DrawRecipes(options.skills)
            DrawHistory(options.history)
            for i = 0, 8 do
                DrawCraft(i)
            end
        end)
    end,
}

return crafty
