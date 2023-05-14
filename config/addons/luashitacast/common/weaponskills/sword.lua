local strSkills = T{ 'Flat Blade', 'Circle Blade', 'Vorpal Blade' }
local dexSkills = T{ 'Fast Blade' }
local mndSkills = T{ 'Requiescat' }
local strMndSkills = T{ 'Shining Blade', 'Seraph Blade', 'Swift Blade', 'Savage Blade', 'Sanguine Blade', 'Knights of Round', 'Death Blossom' }
local strIntSkills = T{ 'Burning Blade', 'Red Lotus Blade' }
local hpSkills = T{ 'Spirits Within' }

local function HandleWs(wsName)
    if strSkills:contains(wsName) then
        gFunc.EquipSet('Str')
    elseif dexSkills:contains(wsName) then
        gFunc.EquipSet('Dex')
    elseif mndSkills:contains(wsName) then
        gFunc.EquipSet('Mnd')
    elseif strMndSkills:contains(wsName) then
        gFunc.EquipSet('Mnd')
        gFunc.EquipSet('Str')
    elseif strIntSkills:contains(wsName) then
        gFunc.EquipSet('Int')
        gFunc.EquipSet('Str')
    elseif hpSkills:contains(wsName) then
    end
end

return HandleWs
