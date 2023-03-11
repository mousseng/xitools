local strDexSkills = T{ 'Blade: Rin', 'Blade: Retsu', 'Blade: Jin', 'Blade: Ten', 'Blade: Ku' }
local strIntSkills = T{ 'Blade: Teki', 'Blade: To', 'Blade: Chi', 'Blade: Ei', }
local dexIntSkills = T{ 'Blade: Yu' }

local function HandleWs(wsName)
    if strDexSkills:contains(wsName) then
        gFunc.EquipSet('Str')
        gFunc.EquipSet('Dex')
    elseif strIntSkills:contains(wsName) then
        gFunc.EquipSet('Int')
        gFunc.EquipSet('Str')
    elseif dexIntSkills:contains(wsName) then
        gFunc.EquipSet('Int')
        gFunc.EquipSet('Dex')
    elseif wsName == 'Blade: Shun' then
        gFunc.EquipSet('Dex')
    end
end

return HandleWs
