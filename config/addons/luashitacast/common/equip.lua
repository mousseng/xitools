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

---@class Gearset
---@field Base    LacSet
---@field AtNight LacSet?

local Slots = {
    Main  = 1,
    Sub   = 2,
    Range = 3,
    Ammo  = 4,
    Head  = 5,
    Body  = 6,
    Hands = 7,
    Legs  = 8,
    Feet  = 9,
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
    Remove = 'remove',
}

local Staves = {
    Light = nil,
    Dark = "Dark Staff",
    Fire = nil,
    Ice = "Ice Staff",
    Water = nil,
    Thunder = nil,
    Earth = "Earth Staff",
    Wind = "Auster's Staff",
}

local Obis = {
    Light = nil,
    Dark = nil,
    Fire = nil,
    Ice = nil,
    Water = nil,
    Thunder = nil,
    Earth = nil,
    Wind = nil,
}

local SetExtensions = {
    'AtNight',
}

---@param set table
---@return Gearset
local function NewSet(set)
    ---@type Gearset
    local parsedSet = {
        Base = {},
    }

    for slot, _ in pairs(Slots) do
        if set[slot] then
            parsedSet.Base[slot] = set[slot]
        end
    end

    for _, ext in pairs(SetExtensions) do
        if set[ext] then
            parsedSet[ext] = set[ext]
        end
    end

    return parsedSet
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
local function Item(slot, item)
    gFunc.Equip(Slots[slot] or slot, item)
end

---@param set   Gearset
---@param force boolean?
local function Set(set, force)
    local equipFn = gFunc.EquipSet
    if force then
        equipFn = gFunc.ForceEquipSet
    end

    equipFn(set.Base)

    if set.AtNight and Status.IsNight() then
        equipFn(set.AtNight)
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

---@param spell table
local function EquipObi(spell)
    local env = gData.GetEnvironment()
    if Obis[spell.Element]
    and (env.WeatherElement == spell.Element or env.DayElement == spell.Element) then
        Waist(Obis[spell.Element])
    end
end

---@param spell table
local function EquipStaff(spell)
    if Staves[spell.Element] then
        Main(Staves[spell.Element])
        Sub(Consts.Displaced)
    end
end

local function EquipStealth()
    local stealthGear = NewSet {
        Hands = "Dream Mittens +1",
        Back = "Skulker's Cape",
        Waist = "Swift Belt",
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
}
