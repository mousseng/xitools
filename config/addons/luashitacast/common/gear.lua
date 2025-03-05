local gear = {
    -- some consts
    Displaced       = "displaced",
    Remove          = "remove",
    -- weapons
    Kikoku          = "Kikoku",
    Naegling        = "Naegling",
    Tauret          = "Kaja Knife",
    Gokotai         = "Kaja Katana",
    Ternion         = "Ternion Dagger +1",
    Staccato        = "Staccato Staff",
    MaficCudgel     = "Mafic Cudgel",
    Solstice        = "Solstice",
    Gada            = "Gada",
    Colada          = "Colada",
    ChatoyantStaff  = "Chatoyant Staff",
    -- shields and grips
    Culminus        = "Culminus",
    EnkiStrap       = "Enki Strap",
    -- ranged
    Dunna           = "Dunna",
    -- ammo
    StaunchTath     = "Staunch Tathlum",
    GhastlyTath     = "Ghastly Tathlum +1",
    SapienceOrb     = "Sapience Orb",
    Yetshila        = "Yetshila",
    SeethingBomb    = "Seeth. Bomblet +1",
    DateShuriken    = "Date Shuriken",
    LuckyEgg        = "Per. Lucky Egg",
    -- necks
    VoltsurgeTorque = "Voltsurge Torque",
    SanctityNeck    = "Sanctity Necklace",
    MoonbeamNodowa  = "Moonbeam Nodowa",
    FotiaGorget     = "Fotia Gorget",
    ErraPendant     = "Erra Pendant",
    -- ears
    BrutalEar       = "Brutal Earring",
    HecateEar       = "Hecate's Earring",
    FriomisiEar     = "Friomisi Earring",
    OdrEar          = "Odr Earring",
    LugraEar        = "Lugra Earring +1",
    HypaspistEar    = "Hypaspist Earring",
    MendicantEar    = "Mendi. Earring",
    -- rings
    ShneddickRing   = "Shneddick Ring",
    DefendingRing   = "Defending Ring",
    RajasRing       = "Rajas Ring",
    RegalRing       = "Regal Ring",
    EponaRing       = "Epona's Ring",
    ShivaRing       = "Shiva Ring",
    MephitasRing    = "Mephitas's Ring +1",
    LebecheRing     = "Lebeche Ring",
    -- belts
    SailfiBelt      = "Sailfi Belt +1",
    SkrymirCord     = "Skrymir Cord",
    FotiaBelt       = "Fotia Belt",
    LatriaSash      = "Latria Sash",
    AusterityBelt   = "Austerity Belt +1",
    SiegelSash      = "Siegel Sash",
    RuminationSash  = "Rumination Sash",
    -- loose armor
    NaresCap        = "Nares Cap",
    ShriekerCuffs   = "Shrieker's Cuffs",
    AyaoGages       = "Ayao's Gages",
    DoyenPants      = "Doyen Pants",
    QuerkeningBrais = "Querkening Brais",
    InspiritedBoots = "Inspirited Boots",
    -- adhemar gear
    AdhemarHands    = "Adhemar Wrist. +1",
    -- herculean gear
    HercBody        = "Herculean Vest",
    HercHands       = "Herculean Gloves",
    HercLegs        = "Herculean Trousers",
    HercFeet        = "Herculean Boots",
    -- hizamaru gear
    HizamaruHead    = "Hiza. Somen +2",
    HizamaruBody    = "Hiza. Haramaki +2",
    HizamaruHands   = "Hizamaru Kote +2",
    HizamaruLegs    = "Hiza. Hizayoroi +2",
    HizamaruFeet    = "Hiza. Sune-Ate +2",
    -- mummu gear
    MummuHead       = "Mummu Bonnet +2",
    MummuBody       = "Mummu Jacket +2",
    MummuHands      = "Mummu Wrists +2",
    MummuLegs       = "Mummu Kecks +2",
    MummuFeet       = "Mummu Gamash. +2",
    MummuRing       = "Mummu Ring",
    -- jhakri gear
    JhakriHead      = "Jhakri Coronal +1",
    JhakriBody      = "Jhakri Robe +1",
    JhakriHands     = "Jhakri Cuffs +2",
    JhakriLegs      = "Jhakri Slops +1",
    JhakriFeet      = "Jhakri Pigaches +1",
    JhakriRing      = "Jhakri Ring",
    -- ayanmo gear
    AyanmoHead      = "Aya. Zucchetto +2",
    AyanmoBody      = "Ayanmo Corazza +1",
    AyanmoHands     = "Aya. Manopolas +1",
    AyanmoLegs      = "Aya. Cosciales +1",
    AyanmoFeet      = "Aya. Gambieras +1",
    AyanmoRing      = "Ayanmo Ring",
    -- JSE time!
    NIN = {
        -- artifact gear
        AfHead     = "Hachiya Hatsu. +3",
        AfBody     = "Hachi. Chain. +1",
        AfHands    = "Hachiya Tekko +1",
        AfLegs     = "Hachi. Hakama +1",
        AfFeet     = "Hachiya Kyahan +2",
        -- relic armor
        RelicHead  = "Mochi. Hatsuburi +2",
        RelicBody  = "Mochi. Chainmail +1",
        RelicHands = "Mochizuki Tekko +1",
        RelicLegs  = "Mochi. Hakama +1",
        RelicFeet  = "Mochi. Kyahan +1",
        -- empyrean gear
        EmpyHead   = "Hattori Zukin +2",
        EmpyBody   = "Hattori Ningi +2",
        EmpyHands  = "Hattori Tekko +2",
        EmpyLegs   = "Hattori Hakama +2",
        EmpyFeet   = "Hattori Kyahan +3",
        -- misc jse gear
        Ear        = "Hattori Earring",
        Neck       = "Ninja Nodowa +1",
        -- ambu capes
        AutoCape = { Name = "Andartia's Mantle", Augment = { 'DEX+20', '"Dbl.Atk."+10' } },
        CastCape = { Name = "Andartia's Mantle", Augment = { 'AGI+20', 'Fast Cast +10%' } },
        NukeCape = { Name = "Andartia's Mantle", Augment = { 'INT+20', '"Mag. Atk. Bns."+10' } },
        StrCape  = { Name = "Andartia's Mantle", Augment = { 'STR+29', 'Weapon skill damage +10%' } },
        DexCape  = { Name = "Andartia's Mantle", Augment = { 'DEX+30', 'Weapon skill damage +10%' } },
        AgiCape  = { Name = "Andartia's Mantle", Augment = { 'DEX+30', 'Weapon skill damage +10%' } },
    },
    GEO = {
        -- artifact gear
        AfHead     = "Geo. Galero +2",
        AfBody     = "Geo. Tunic +1",
        AfHands    = "Geo. Mitaines +2",
        AfLegs     = "Geomancy Pants +2",
        AfFeet     = "Geo. Sandals +2",
        -- relic armor
        RelicHead  = "Bagua Galero",
        RelicBody  = "Bagua Tunic +1",
        RelicHands = "Bagua Mitaines",
        RelicLegs  = "Bagua Pants +2",
        RelicFeet  = "Bagua Sandals +1",
        -- empyrean gear
        EmpyHead   = "Azimuth Hood +2",
        EmpyBody   = "Azimuth Coat",
        EmpyHands  = "Azimuth Gloves +1",
        EmpyLegs   = "Azimuth Tights",
        EmpyFeet   = "Azimuth Gaiters +2",
        -- misc jse gear
        Ear        = "Azimuth Earring",
        Neck       = "Bagua Charm +1",
        -- ambu capes
        IdleCape = { Name = "Nantosuelta's Cape", Augment = { 'VIT+20', 'Pet: "Regen"+10' } },
        CastCape = { Name = "Nantosuelta's Cape", Augment = { 'VIT+20', 'Fast Cast +10%' } },
        NukeCape = { Name = "Nantosuelta's Cape", Augment = { 'INT+20', '"Mag. Atk. Bns."+10' } },
        GeoCape  = "Lifestream Cape",
    },
    RDM = {
        -- artifact gear
        AfHead     = "Atrophy Chapeau",
        AfBody     = "Atrophy Tabard +1",
        AfHands    = "Atrophy Gloves +1",
        AfLegs     = "Atrophy Tights +1",
        AfFeet     = "Atrophy Boots",
        -- relic armor
        RelicHead  = "Viti. Chapeau +1",
        RelicBody  = "Viti. Tabard +1",
        RelicHands = "Viti. Gloves",
        RelicLegs  = "Viti. Tights",
        RelicFeet  = "Vitiation Boots +1",
        -- empyrean gear
        EmpyHead   = "Leth. Chappel +1",
        EmpyBody   = "Lethargy Sayon +1",
        EmpyHands  = "Leth. Ganth. +1",
        EmpyLegs   = "Leth. Fuseau +1",
        EmpyFeet   = "Leth. Houseaux +1",
        -- misc jse gear
        Ear        = "Leth. Earring +1",
        Neck       = "",
        -- ambu capes
        IdleCape = { Name = "Succelos's Cape", Augment = { 'Fast Cast +10%' } }, -- TODO
        CastCape = { Name = "Succelos's Cape", Augment = { 'MND+20', 'Fast Cast +10%' } },
        NukeCape = { Name = "Succelos's Cape", Augment = { 'Fast Cast +10%' } }, -- TODO
        HealCape = { Name = "Succelos's Cape", Augment = { 'Fast Cast +10%' } }, -- TODO
    },
    BLU = {
    },
    DNC = {
    },
}

require('common')
local chat = require('chat')
local resx = AshitaCore:GetResourceManager()

local function parseItem(potentialItem)
    local isItemString = type(potentialItem) == 'string'
    local isItemTable = type(potentialItem) == 'table' and potentialItem.Name ~= nil
    if not isItemString and not isItemTable then
        return nil
    end

    local realItem = potentialItem
    if isItemTable then
        realItem = potentialItem.Name
    end

    return realItem
end

local function isItem(potentialItem)
    local item = parseItem(potentialItem)
    -- special-case these because they're useful but not real
    if item == nil or item == gear.Remove or item == gear.Displaced then
        return true
    end

    return resx:GetItemByName(item, 0) ~= nil
end

local function hasItem(inventory, potentialItem)
    local item = parseItem(potentialItem)
    -- special-case these because they're useful but not real
    if item == nil or item == gear.Remove or item == gear.Displaced then
        return true
    end

    return inventory[item] or false
end

local function buildInventory()
    local inv = AshitaCore:GetMemoryManager():GetInventory()
    local containers = { 0, 8, 10, 11, 12, 13, 14, 15, 16 }
    local inventory = { }

    for _, container in ipairs(containers) do
        for index = 0, 80 do
            local item = inv:GetContainerItem(container, index)
            if item and item.Id > 0 then
                local name = resx:GetItemById(item.Id).Name[1]
                inventory[name] = true
            end
        end
    end

    return inventory
end

local function reportBadItem(k, v)
    print(chat.header(addon.name)
        :append(chat.message('Not a valid item: %s = "'):fmt(k))
        :append(chat.error(v))
        :append(chat.message('"'))
    )
end

local function reportMissingItem(k, v)
    print(chat.header(addon.name)
        :append(chat.message('Item not in inventory: %s = "'):fmt(k))
        :append(chat.error(v))
        :append(chat.message('"'))
    )
end

local function reportSummary(count)
    local colorize = chat.success
    if count > 0 then
        colorize = chat.error
    end

    print(chat.header(addon.name)
        :append(colorize('%d issues'):fmt(count))
        :append(chat.message(' found with profile gear!'))
    )
end

function gear:Validate()
    local issues = 0
    local inv = buildInventory()

    for k, v in pairs(self) do
        if not isItem(v) then
            issues = issues + 1
            reportBadItem(k, v)
        elseif not hasItem(inv, v) then
            issues = issues + 1
            reportMissingItem(k, v)
        end
    end

    for k, v in pairs(self.NIN) do
        if not isItem(v) then
            issues = issues + 1
            reportBadItem(k, v)
        elseif not hasItem(inv, v) then
            issues = issues + 1
            reportMissingItem(k, v)
        end
    end

    for k, v in pairs(self.GEO) do
        if not isItem(v) then
            issues = issues + 1
            reportBadItem(k, v)
        elseif not hasItem(inv, v) then
            issues = issues + 1
            reportMissingItem(k, v)
        end
    end

    reportSummary(issues)
end

return gear
