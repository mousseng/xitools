---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

---@class LacSet
---@field Main  string?
---@field Sub   string?
---@field Range string?
---@field Ammo  string?
---@field Head  string?
---@field Body  string?
---@field Hands string?
---@field Legs  string?
---@field Feet  string?
---@field Neck  string?
---@field Waist string?
---@field Ear1  string?
---@field Ear2  string?
---@field Ring1 string?
---@field Ring2 string?
---@field Back  string?

---@class LacSetExt
---@field AtNight     LacSet?
---@field AtNightPlus LacSet?
---@field AtHalfMp    LacSet?

local Slots = {
    Main  =  1,
    Sub   =  2,
    Range =  3,
    Ammo  =  4,
    Head  =  5,
    Body  =  6,
    Hands =  7,
    Legs  =  8,
    Feet  =  9,
    Neck  = 10,
    Waist = 11,
    Ear1  = 12,
    Ear2  = 13,
    Ring1 = 14,
    Ring2 = 15,
    Back  = 16,
}

local Consts = {
    Displaced = 'displaced',
    Remove    = 'remove',
}

local Elements = {
    Light     = 'Dark',
    Dark      = 'Light',
    Fire      = 'Water',
    Ice       = 'Fire',
    Water     = 'Lightning',
    Lightning = 'Earth',
    Earth     = 'Wind',
    Wind      = 'Ice',
}

local Staves = {
    Light   = nil,
    Dark    = "Dark Staff",
    Fire    = "Fire Staff",
    Ice     = "Ice Staff",
    Water   = "Neptune's Staff",
    Thunder = "Thunder Staff",
    Earth   = "Earth Staff",
    Wind    = "Auster's Staff",
}

local Obis = {
    Light   = nil,
    Dark    = nil,
    Fire    = nil,
    Ice     = "Hyorin Obi",
    Water   = nil,
    Thunder = nil,
    Earth   = nil,
    Wind    = nil,
}

local SetExtensionTypes = {
    'AtNight',
    'AtNightPlus',
    'AtHalfMp',
}

---@type { [string]: LacSetExt }
local SetExtensions = {}

--- Given a gearset definition, trim all the extension properties not supported
--- by LAC and return the base set. Known extensions are stored in a map to be
--- equipped in the correct circumstances.
---@param set LacSetExt
---@return LacSet
local function NewSet(set)
    ---@type LacSet
    local trimmedSet = {}

    for slot, _ in pairs(Slots) do
        if set[slot] then
            trimmedSet[slot] = set[slot]
        end
    end

    local setId = tostring(trimmedSet)
    SetExtensions[setId] = {}
    for _, ext in pairs(SetExtensionTypes) do
        if set[ext] then
            SetExtensions[setId][ext] = set[ext]
        end
    end

    return trimmedSet
end

---@param slot string|number
local function Disable(slot)
    gFunc.Disable(slot)
end

---@param slot string|number
local function Enable(slot)
    gFunc.Enable(slot)
end

---@param slot string|number
---@param item string
local function Item(slot, item, force)
    if force then
        gFunc.ForceEquip(Slots[slot] or slot, item)
    else
        gFunc.Equip(Slots[slot] or slot, item)
    end
end

---@param set   LacSet
---@param force boolean?
local function Set(set, force)
    local equipFn = gFunc.EquipSet
    if force then
        equipFn = gFunc.ForceEquipSet
    end

    equipFn(set)

    local setId = tostring(set)
    local setExt = SetExtensions[setId]
    if setExt.AtNight and Status.IsNight() then
        equipFn(setExt.AtNight)
    end

    if setExt.AtNightPlus and Status.IsNightPlus() then
        equipFn(setExt.AtNightPlus)
    end

    if setExt.AtHalfMp and Status.IsHalfMp() then
        equipFn(setExt.AtHalfMp)
    end
end

-- Hack. TODO: actually track convert MP.
local function LockSet(set, timer)
    gFunc.LockSet(set.Base, timer)

    if set.AtNight and Status.IsNight() then
        gFunc.LockSet(set.AtNight, timer)
    end
end

local Main  = Item:bindn(Slots.Main)
local Sub   = Item:bindn(Slots.Sub)
local Range = Item:bindn(Slots.Range)
local Ammo  = Item:bindn(Slots.Ammo)
local Head  = Item:bindn(Slots.Head)
local Body  = Item:bindn(Slots.Body)
local Hands = Item:bindn(Slots.Hands)
local Legs  = Item:bindn(Slots.Legs)
local Feet  = Item:bindn(Slots.Feet)
local Neck  = Item:bindn(Slots.Neck)
local Waist = Item:bindn(Slots.Waist)
local Ear1  = Item:bindn(Slots.Ear1)
local Ear2  = Item:bindn(Slots.Ear2)
local Ring1 = Item:bindn(Slots.Ring1)
local Ring2 = Item:bindn(Slots.Ring2)
local Back  = Item:bindn(Slots.Back)

-- Equips an owned obi appropriate for the spell being cast. This ensures the
-- total bonus earned from the obi is positive, but doesn't account for any
-- iridescence modifiers.
---@param spell table
local function EquipObi(spell)
    if not Obis[spell.Element] then return end

    local env = gData.GetEnvironment()
    local ele = spell.Element
    local opp = Elements[ele]
    local mult = 1.0

    if env.WeatherElement == ele then
        if string.match(env.Weather, 'x2') then
            mult = mult + 0.25
        else
            mult = mult + 0.10
        end
    elseif env.WeatherElement == opp then
        if string.match(env.Weather, 'x2') then
            mult = mult - 0.25
        else
            mult = mult - 0.10
        end
    end

    if env.DayElement == ele then
        mult = mult + 0.10
    elseif env.DayElement == opp then
        mult = mult - 0.10
    end

    if mult > 1.0 then
        Waist(Obis[ele])
    end
end

-- Equips an owned staff appropriate for the spell being cast.
---@param spell table
local function EquipStaff(spell)
    if Staves[spell.Element] then
        Main(Staves[spell.Element])
        Sub(Consts.Displaced)
    end
end

-- Equips gear with bonuses to sneak and invis effects.
local function EquipStealth()
    local stealthGear = NewSet {
        Hands = "Dream Mittens +1",
        Back = "Skulker's Cape",
        Feet = "Dream Boots +1",
    }

    Set(stealthGear)
end

return {
    NewSet  = NewSet,
    Slots   = Slots,
    Special = Consts,
    Staves  = Staves,
    Obis    = Obis,
    Main    = Main,
    Sub     = Sub,
    Range   = Range,
    Ammo    = Ammo,
    Head    = Head,
    Body    = Body,
    Hands   = Hands,
    Legs    = Legs,
    Feet    = Feet,
    Neck    = Neck,
    Waist   = Waist,
    Ear1    = Ear1,
    Ear2    = Ear2,
    Ring1   = Ring1,
    Ring2   = Ring2,
    Back    = Back,
    Stealth = EquipStealth,
    Staff   = EquipStaff,
    Obi     = EquipObi,
    Disable = Disable,
    Enable  = Enable,
    Item    = Item,
    Set     = Set,
    LockSet = LockSet,
}
