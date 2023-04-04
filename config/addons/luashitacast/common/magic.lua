local staves = {
    Dark = "Dark Staff",
}

local function HandleSpell(spell)
    local player = gData.GetPlayer()

    if spell.Type == 'White Magic' then
        gFunc.EquipSet('Mnd')
    elseif spell.Type == 'Black Magic' then
        gFunc.EquipSet('Int')
    end

    if spell.Type == 'Ninjutsu' then
        if spell.Name:startswith('Utsusemi') then
            gFunc.EquipSet('Eva')
            gFunc.EquipSet('Interrupt')
        else
            gFunc.EquipSet('Int')
        end
    end

    if spell.Skill == 'Healing Magic' then
        gFunc.EquipSet('Healing')
    elseif spell.Skill == 'Elemental Magic' then
        gFunc.EquipSet('Elemental')
    elseif spell.Skill == 'Enhancing Magic' then
        gFunc.EquipSet('Enhancing')
    elseif spell.Skill == 'Enfeebling Magic' then
        gFunc.EquipSet('Enfeebling')
    elseif spell.Skill == 'Divine Magic' then
        gFunc.EquipSet('Divine')
    elseif spell.Skill == 'Dark Magic' then
        gFunc.EquipSet('Dark')
    end

    if player.MainJobSync > 50 and staves[spell.Element] then
        gFunc.Equip('Main', staves[spell.Element])
        gFunc.Equip('Sub', 'displaced')
    end

    if spell.Name == 'Sneak' then
        gFunc.Equip('Back', "Skulker's Cape")
        gFunc.Equip('Feet', "Dream Boots +1")
    elseif spell.Name == 'Invisible' or spell.Name:startswith('Tonko') then
        gFunc.Equip('Back', "Skulker's Cape")
        gFunc.Equip('Hands', "Dream Mittens +1")
    end
end

return HandleSpell
