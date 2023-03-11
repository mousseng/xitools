local dexSkills = T{ 'Wasp Sting', 'Viper Bite', 'Evisceration' }
local agiSkills = T{ 'Extenterator' }
local mndSkills = T{ 'Energy Steal', 'Energy Drain' }
local chrSkills = T{ 'Shadowstitch' }
local dexAgiSkills = T{ 'Shark Bite' }
local dexIntSkills = T{ 'Gust Slash', 'Cyclone', 'Aeolian Edge' }
local dexChrSkills = T{ 'Dancing Edge' }

local function HandleWs(wsName)
    if dexSkills:contains(wsName) then
        gFunc.EquipSet('Dex')
    elseif agiSkills:contains(wsName) then
        gFunc.EquipSet('Agi')
    elseif mndSkills:contains(wsName) then
        gFunc.EquipSet('Mnd')
    elseif chrSkills:contains(wsName) then
        gFunc.EquipSet('Chr')
    elseif dexAgiSkills:contains(wsName) then
        gFunc.EquipSet('Dex')
        gFunc.EquipSet('Agi')
    elseif dexIntSkills:contains(wsName) then
        gFunc.EquipSet('Dex')
        gFunc.EquipSet('Int')
    elseif dexChrSkills:contains(wsName) then
        gFunc.EquipSet('Dex')
        gFunc.EquipSet('Chr')
    end
end

return HandleWs
