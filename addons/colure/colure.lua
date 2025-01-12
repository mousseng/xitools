addon.name    = 'colure'
addon.author  = 'lin'
addon.version = '0.1'
addon.desc    = 'a GEO helper'

require('common')
local bit = require('bit')
local log = require('log')
local utils = require('utils')
local imgui = require('imgui')

local player = AshitaCore:GetMemoryManager():GetPlayer()
local isVisible = { true }
local windowFlags = ImGuiWindowFlags_NoDecoration
local quickTarget = nil

local colures = {
    specs = {
        { indi = 768, geo = 798, display = 'Regen',    name = 'Regen'      },
        { indi = 770, geo = 800, display = 'Refresh',  name = 'Refresh'    },
        { indi = 769, geo = 799, display = 'Poison',   name = 'Poison'     },
        { indi = 796, geo = 826, display = 'Paralyze', name = 'Paralysis'  },
        { indi = 797, geo = 827, display = 'Gravity',  name = 'Gravity'    },
    },
    boons = {
        { indi = 771, geo = 801, display = '+SPD',     name = 'Haste'      },
        { indi = 784, geo = 814, display = '+EVA',     name = 'Voidance'   },
        { indi = 780, geo = 810, display = '+DEF',     name = 'Barrier'    },
        { indi = 783, geo = 813, display = '+ACC',     name = 'Precision'  },
        { indi = 779, geo = 809, display = '+ATK',     name = 'Fury'       },
        { indi = 785, geo = 815, display = '+MACC',    name = 'Focus'      },
        { indi = 786, geo = 816, display = '+MEVA',    name = 'Attunement' },
        { indi = 781, geo = 811, display = '+MAB',     name = 'Acumen'     },
        { indi = 782, geo = 812, display = '+MDB',     name = 'Fend'       },
    },
    banes = {
        { indi = 795, geo = 825, display = '-SPD',     name = 'Slow'       },
        { indi = 792, geo = 822, display = '-EVA',     name = 'Torpor'     },
        { indi = 788, geo = 818, display = '-DEF',     name = 'Frailty'    },
        { indi = 791, geo = 821, display = '-ACC',     name = 'Slip'       },
        { indi = 787, geo = 817, display = '-ATK',     name = 'Wilt'       },
        { indi = 793, geo = 823, display = '-MACC',    name = 'Vex'        },
        { indi = 794, geo = 824, display = '-MEVA',    name = 'Languor'    },
        { indi = 789, geo = 819, display = '-MAB',     name = 'Fade'       },
        { indi = 790, geo = 820, display = '-MDB',     name = 'Malaise'    },
    },
    attrs = {
        { indi = 772, geo = 802, display = 'STR',      name = 'STR'        },
        { indi = 773, geo = 803, display = 'DEX',      name = 'DEX'        },
        { indi = 775, geo = 805, display = 'AGI',      name = 'AGI'        },
        { indi = 774, geo = 804, display = 'VIT',      name = 'VIT'        },
        { indi = 776, geo = 806, display = 'INT',      name = 'INT'        },
        { indi = 777, geo = 807, display = 'MND',      name = 'MND'        },
        { indi = 778, geo = 808, display = 'CHR',      name = 'CHR'        },
    },
}

local function listIndiOptions(spell)
    if not player:HasSpell(spell.indi) then
        return
    end

    if imgui.MenuItem('Indi on me') then
        AshitaCore:GetChatManager():QueueCommand( 1, string.format('/ma "Indi-%s" <me>', spell.name))
    end

    if imgui.MenuItem('Indi on party') then
        AshitaCore:GetChatManager():QueueCommand( 1, string.format('/ma "Indi-%s" <stal>', spell.name))
    end

    if quickTarget and imgui.MenuItem(string.format('Indi on %s', quickTarget)) then
        AshitaCore:GetChatManager():QueueCommand( 1, string.format('/ma "Indi-%s" %s', spell.name, quickTarget))
    end
end

local function listGeoOptions(spell, targets)
    if not player:HasSpell(spell.geo) then
        return
    end

    if imgui.MenuItem('Geo on target') then
        AshitaCore:GetChatManager():QueueCommand( 1, string.format('/ma "Geo-%s" <t>', spell.name))
    end

    if imgui.MenuItem('Geo on field') then
        AshitaCore:GetChatManager():QueueCommand( 1, string.format('/ma "Geo-%s" %s', spell.name, targets))
    end

    if quickTarget and imgui.MenuItem(string.format('Geo on %s', quickTarget)) then
        AshitaCore:GetChatManager():QueueCommand( 1, string.format('/ma "Geo-%s" %s', spell.name, quickTarget))
    end
end

local function drawSpellMenu(category, title, spells, targets)
    if imgui.Button(category) then
        imgui.OpenPopup(title)
    end

    if imgui.BeginPopup(title) then
        for _, spell in ipairs(spells) do
            if imgui.BeginMenu(spell.display) then
                listIndiOptions(spell)
                listGeoOptions(spell, targets)
                imgui.EndMenu()
            end
        end

        imgui.EndPopup()
    end
end

local function drawColure()
    if utils.ShouldHideUi() then
        return
    end

    if not isVisible[1] then
        AshitaCore:GetChatManager():QueueCommand(-1, '/addon unload colure')
        return
    end


    if imgui.Begin('colure', isVisible, windowFlags) then
        imgui.PushStyleColor(ImGuiCol_Border, { 0.69, 0.68, 0.78, 1.0 })
        drawSpellMenu('Boons', 'boonsPopup', colures.boons, '<stpt>')
        drawSpellMenu('Banes', 'banesPopup', colures.banes, '<stnpc>')
        drawSpellMenu('Stats', 'attrsPopup', colures.attrs, '<stpt>')
        drawSpellMenu('Other', 'specsPopup', colures.specs, '<stpt>')
        imgui.PopStyleColor()
    end

    imgui.End()
end

local function onCommand(e)
    local args = e.command:args()
    if args[1] ~= '/colure' then
        return
    end

    if args[2] == 'lock' then
        windowFlags = bit.bor(ImGuiWindowFlags_NoDecoration, ImGuiWindowFlags_NoBackground, ImGuiWindowFlags_NoMove)
    end

    if args[2] == 'unlock' then
        windowFlags = ImGuiWindowFlags_NoDecoration
    end

    if args[2] == 'quick' and args[3] then
        quickTarget = args:slice(3, 10):join(' ')
        log.inf('setting quicktarget to %s', quickTarget)
    end

    if args[2] == 'unquick' then
        quickTarget = nil
        log.inf('clearing quicktarget')
    end
end

ashita.events.register('command', 'command', onCommand)
ashita.events.register('d3d_present', 'd3d_present', drawColure)
