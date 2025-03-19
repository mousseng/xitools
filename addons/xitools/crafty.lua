require('common')
local bit = require('bit')
local imgui = require('imgui')
local packets = require('utils/packets')
local recipesByIngredients = require('data.recipesByIngredients')
local recipesBySkill = require('data.recipesBySkill')
local ui = require('ui')

local Scale = 1.0

local iconTimes = '\xef\x81\x97'
local iconCheck = '\xef\x81\x98'
local imguiLeafNode = bit.bor(ImGuiTreeNodeFlags_Leaf, ImGuiTreeNodeFlags_NoTreePushOnOpen)
local textBaseWidth = imgui.CalcTextSize('A')
local inProgSynth = nil

local crystalMap = {
    -- nq crystals
    [4096] = 4096,
    [4097] = 4097,
    [4098] = 4098,
    [4099] = 4099,
    [4100] = 4100,
    [4101] = 4101,
    [4102] = 4102,
    [4103] = 4103,
    -- hq crystals
    [4238] = 4096,
    [4239] = 4097,
    [4240] = 4098,
    [4241] = 4099,
    [4242] = 4100,
    [4243] = 4101,
    [4244] = 4102,
    [4245] = 4103,
    -- some other shit
    [6506] = 4096,
    [6507] = 4097,
    [6508] = 4098,
    [6509] = 4099,
    [6510] = 4100,
    [6511] = 4101,
    [6512] = 4102,
    [6513] = 4103,
}

local skillsMap = {
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

local function GetInventoryTotals()
    local inv = AshitaCore:GetMemoryManager():GetInventory()
    local cumInv = {}
    -- the inventory array is not guaranteed to be compact, but counting id=0 or
    -- id=65535 is fine
    for i = 1, inv:GetContainerCountMax(0) do
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
    -- first we display the skill requirements and whether the player meets them
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

    -- then we show any key item requirements
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

    -- finally the ingredient list begins with the crystal
    local crystalCount = inv[recipe.crystal] or 0
    local crystalName = res:GetItemById(recipe.crystal).LogNameSingular[1]
    imgui.TreeNodeEx(('(%3i) %s'):format(crystalCount, crystalName), imguiLeafNode)

    -- and ends with the remaining items
    -- TODO: compact duplicates into "x2" or whatever
    for _, ingredientId in ipairs(recipe.ingredients) do
        local ingredientCount = inv[ingredientId] or 0
        local ingredientName = res:GetItemById(ingredientId).LogNameSingular[1]
        imgui.TreeNodeEx(('(%3i) %s'):format(ingredientCount, ingredientName), imguiLeafNode)
    end
end

local recipeFilter = { '' }
local searchResults = { [''] = { } }
local function FilterRecipes(filter)
    local res = AshitaCore:GetResourceManager()
    if searchResults[filter] == nil then
        searchResults[filter] = { }
        -- TODO: remove the "by skill" bits
        for skillId, recipeList in ipairs(recipesBySkill) do
            for _, recipe in ipairs(recipeList) do
                -- the abbreviated names are not always conducive to search, so we
                -- will test against both it and the full name
                local item = res:GetItemById(recipe.result)
                local itemName = item.Name[1]
                local fullName = item.LogNameSingular[1]
                if itemName:lower():match(filter)
                or fullName:lower():match(filter) then
                    table.insert(searchResults[filter], recipe)
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

        DrawFilteredRecipes(skills, searchResults[recipeFilter[1]:lower()])
    end
end

local function DrawHistory(options)
    if imgui.CollapsingHeader('Craft History') then
        if imgui.Button('Clear History') then
            options.history = T{}
        end

        local history = options.history

        if imgui.BeginTable('xitool.crafty.history', 3, ImGuiTableFlags_ScrollY, { textBaseWidth * 60, 400 * Scale }) then
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
                local skillups = T{ }
                for skillId, skillup in pairs(synth.skillup) do
                    if skillup.change ~= nil then
                        skillups:append(('%s %+.1f'):format(skillsAbbrMap[skillId] or skillId, skillup.change))
                    -- elseif not skillup.isSkillupAllowed then
                    --     skillups:append(('%s %s'):format(skillsAbbrMap[skillId] or skillId, iconTimes))
                    end
                end
                imgui.Text(skillups:join(' '))

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

---@type xitool
local crafty = {
    Name = 'crafty',
    Aliases = T{ 'c', 'craft' },
    DefaultSettings = T{
        isEnabled = T{ false },
        isVisible = T{ true },
        name = 'xitools.crafty',
        size = T{ -1, -1 },
        pos = T{ 100, 100 },
        flags = ImGuiWindowFlags_NoResize,
        skills = T{
            [0] = T{ 0.0 },
            [1] = T{ 0.0 },
            [2] = T{ 0.0 },
            [3] = T{ 0.0 },
            [4] = T{ 0.0 },
            [5] = T{ 0.0 },
            [6] = T{ 0.0 },
            [7] = T{ 0.0 },
            [8] = T{ 0.0 },
        },
        history = T{},
    },
    HandleCommand = function(args, options)
        if #args == 0 then
            options.isVisible[1] = not options.isVisible[1]
        end

        if #args == 1 and (args[1] == 'cl' or args[1] == 'clear') then
            options.history = T{}
        end
    end,
    HandlePacketOut = function(e, options)
        -- if we've requested a synth from the server, start our in-progress
        -- tracker. speculate on the results, since "Mangled Mess" isn't a very
        -- useful item name.
        if e.id == 0x096 and inProgSynth == nil then
            local startSynth = packets.outbound.startSynth.parse(e.data)
            local crystal = crystalMap[startSynth.crystal]
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
                skillup = T{ },
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

                for _, skill in pairs(synth.skill) do
                    if skill.skillId > 0 then
                        inProgSynth.skillup[skill.skillId - 48] = {
                            isSkillupAllowed = skill.isSkillupAllowed,
                            change = nil,
                        }
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
            if basic.message == 38 and player ~= nil and basic.target == player.ServerId and basic.param > 48 and basic.param < 58 then
                local latestSynth = options.history:first()
                latestSynth.skillup[basic.param - 48].change = basic.value / 10
                options.skills[basic.param - 48][1] = options.skills[basic.param - 48][1] + (basic.value / 10)
            elseif basic.message == 310 and player ~= nil and basic.target == player.ServerId and basic.param > 48 and basic.param < 58 then
                local latestSynth = options.history:first()
                latestSynth.skillup[basic.param - 48].change = -basic.value / 10
                options.skills[basic.param - 48][1] = options.skills[basic.param - 48][1] - (basic.value / 10)
            end
        end
    end,
    DrawConfig = function(options, gOptions)
        if imgui.BeginTabItem('crafty') then
            imgui.Checkbox('Enabled', options.isEnabled)
            imgui.Checkbox('Visible', options.isVisible)

            for id, skill in pairs(skillsMap) do
                imgui.InputFloat(skill, options.skills[id], 0.1, 0.1, '%.1f')
            end

            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options, gOptions)
        Scale = gOptions.uiScale[1]
        ui.DrawNormalWindow(options, gOptions, function()
            imgui.SetWindowFontScale(Scale)
            DrawSkills(options.skills)
            DrawRecipes(options.skills)
            DrawHistory(options)
        end)
    end,
}

return crafty
