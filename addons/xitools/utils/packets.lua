local bit = require('bit')

local outboundStartSynth = {
    id = 0x096,
    name = 'Start Synth',
    parse = function(packet)
        local startSynth = {
            crystal = struct.unpack('H', packet, 0x06 + 1),
            crystalIdx = struct.unpack('B', packet, 0x08 + 1),
            ingredientCount = struct.unpack('B', packet, 0x09 + 1),
            ingredient = {},
            ingredientIdx = {},
        }

        for i=0, 7 do
            startSynth.ingredient[i] = struct.unpack('H', packet, 0x0A + (i * 2) + 1)
        end

        for i=0, 7 do
            startSynth.ingredientIdx[i] = struct.unpack('B', packet, 0x1A + (i * 2) + 1)
        end

        return startSynth
    end,
}

local outboundFishingAction = {
    id = 0x110,
    name = 'Fishing Action',
    parse = function(packet)
        local fishingAction = {
            player = struct.unpack('I', packet, 0x04 + 1),
            fishHp = struct.unpack('I', packet, 0x08 + 1),
            playerIdx = struct.unpack('H', packet, 0x0C + 1),
            action = struct.unpack('B', packet, 0x0E + 1),
            catchKey = struct.unpack('I', packet, 0x10 + 1),
        }

        return fishingAction
    end,
    actionMap = {
        ['Cast'] = 2,
        ['Catch'] = 3,
        ['Stop'] = 4,
    },
}

local outboundInventoryDrop = {
    id = 0x028,
    name = 'Inventory Drop',
    parse = nil,
    make = function(this, quantity, container, slot)
        return this.id, struct.pack('IIBB', 0, quantity, container, slot):totable()
    end,
}

local outboundInventoryMove = {
    id = 0x029,
    name = 'Inventory Move',
    parse = nil,
    make = function(this, quantity, srcContainer, destContainer, srcIndex, tgtIndex)
        if srcContainer ~= destContainer then
            tgtIndex = 0x52
        end

        return this.id, struct.pack('IIBBBB', 0, quantity, srcContainer, destContainer, srcIndex, tgtIndex):totable()
    end,
}

local outboundTreasureLot = {
    id = 0x041,
    name = 'Treasure Lot',
    parse = nil,
    make = function(this, slot)
        return this.id, { 0x00, 0x00, 0x00, 0x00, slot }
    end,
}

local outboundTreasurePass = {
    id = 0x042,
    name = 'Treasure Pass',
    parse = nil,
    make = function(this, slot)
        return this.id, { 0x00, 0x00, 0x00, 0x00, slot }
    end,
}

local inboundZoneIn = {
    id = 0x00A,
    name = 'Zone In',
    ---@param packet string
    parse = function(packet)
        local zonein = {
            player = struct.unpack('i4', packet, 0x04 + 1),
            player_idx = struct.unpack('i2', packet, 0x08 + 1),
            zone = struct.unpack('i2', packet, 0x30 + 1),
        }

        return zonein
    end
}

local inboundPcUpdate = {
    id = 0x00D,
    name = 'PC Update',
    ---@param packet userdata
    parse = function(packet)
        return {
            player          = ashita.bits.unpack_be(packet,  32, 32),
            playerIndex     = ashita.bits.unpack_be(packet,  64, 16),
            updatedPosition = ashita.bits.unpack_be(packet,  80,  1) == 1,
            updatedStatus   = ashita.bits.unpack_be(packet,  81,  1) == 1,
            updatedVitals   = ashita.bits.unpack_be(packet,  82,  1) == 1,
            updatedName     = ashita.bits.unpack_be(packet,  83,  1) == 1,
            updatedModel    = ashita.bits.unpack_be(packet,  84,  1) == 1,
            isDespawned     = ashita.bits.unpack_be(packet,  85,  1) == 1,
            heading         = ashita.bits.unpack_be(packet,  88,  8),
            -- TODO: finish
            x               = ashita.bits.unpack_be(packet,  96, 32), -- float
            y               = ashita.bits.unpack_be(packet, 128, 32), -- float
            z               = ashita.bits.unpack_be(packet, 160, 32), -- float
        }
    end
}

local inboundChatMessage = {
    id = 0x017,
    name = 'Chat Message',
    ---@param packet string
    parse = function(packet)
        local chatmessage = {
            type    = struct.unpack('i1', packet, 0x04 + 1),
            from_gm = struct.unpack('i1', packet, 0x05 + 1),
            zone    = struct.unpack('i2', packet, 0x06 + 1),
            sender  = struct.unpack('s',  packet, 0x08 + 1),
            text    = struct.unpack('s',  packet, 0x18 + 1),
        }

        return chatmessage
    end
}

local inboundInventorySize = {
    id = 0x01C,
    name = 'Inventory Size',
    ---@param packet string
    parse = function(packet)
        local inventories = {}
        for i = 0, 17 do
            inventories[i] = {
                size = struct.unpack('i1', packet, 0x04 + i + 1),
                usable = struct.unpack('i1', packet, 0x24 + (2 * i) + 1),
            }
        end

        return inventories
    end
}

local inboundInventoryFinish = {
    id = 0x01D,
    name = 'Inventory Finish',
    ---@param packet string
    parse = function(packet)
        return {
            flag = struct.unpack('i1', packet, 0x04 + 1),
            container = struct.unpack('i1', packet, 0x05 + 1),
        }
    end
}

local inboundInventoryModify = {
    id = 0x01E,
    name = 'Inventory Modify',
    ---@param packet string
    parse = function(packet)
        return {
            quantity = struct.unpack('i4', packet, 0x04 + 1),
            container = struct.unpack('i1', packet, 0x08 + 1),
            slot = struct.unpack('i1', packet, 0x09 + 1),
        }
    end
}

local inboundInventoryAssign = {
    id = 0x01F,
    name = 'Inventory Assign',
    ---@param packet string
    parse = function(packet)
        return {
            quantity = struct.unpack('i4', packet, 0x04 + 1),
            item = struct.unpack('i2', packet, 0x08 + 1),
            container = struct.unpack('i1', packet, 0x0a + 1),
            slot = struct.unpack('i1', packet, 0x0b + 1),
            flag = struct.unpack('i1', packet, 0x0c + 1),
        }
    end
}

local inboundInventoryItem = {
    id = 0x020,
    name = 'Inventory Item',
    ---@param packet string
    parse = function(packet)
        return {
            container = struct.unpack('i1', packet, 0x0e + 1),
            slot = struct.unpack('i1', packet, 0x0f + 1),
            quantity = struct.unpack('i4', packet, 0x04 + 1),
            price = struct.unpack('i4', packet, 0x08 + 1),
            item = struct.unpack('i2', packet, 0x0c + 1),
            -- TODO: there's more stuff but i don't care
        }
    end
}

local inboundCaughtFish = {
    id = 0x027,
    name = 'Fish Catch',
    ---@param packet string
    parse = function(packet)
        local fish = {
            player = struct.unpack('I', packet, 0x04 + 1),
            playerIdx = struct.unpack('I', packet, 0x08 + 1),
            message = struct.unpack('H', packet, 0x0A + 1),
            fishId = struct.unpack('H', packet, 0x10 + 1),
            count = struct.unpack('B', packet, 0x14 + 1),
        }

        return fish
    end
}

local inboundAction = {
    id = 0x028,
    name = 'Action',
    ---@param packet userdata
    ---@return ActionPacket
    parse = function(packet)
        -- Collect top-level metadata. The category field will provide the context
        -- for the rest of the packet - that should be enough information to figure
        -- out what each target and action field are used for.
        ---@type ActionPacket
        local action = {
            actor_id     = ashita.bits.unpack_be(packet,  40, 32),
            target_count = ashita.bits.unpack_be(packet,  72,  6),
            result_count = ashita.bits.unpack_be(packet,  78,  4),
            category     = ashita.bits.unpack_be(packet,  82,  4),
            param        = ashita.bits.unpack_be(packet,  86, 32),
            recast       = ashita.bits.unpack_be(packet, 118, 32),
            targets      = {}
        }

        local bit_offset = 150

        -- Collect target information. The ID is the server ID, not the entity idx.
        for i = 1, action.target_count do
            action.targets[i] = {
                id           = ashita.bits.unpack_be(packet, bit_offset,      32),
                action_count = ashita.bits.unpack_be(packet, bit_offset + 32,  4),
                actions      = {}
            }

            -- Collect per-target action information. This is where more identifiers
            -- for what's being used lie - often the animation can be used for that
            -- purpose. Otherwise the message may be what you want.
            for j = 1, action.targets[i].action_count do
                action.targets[i].actions[j] = {
                    miss     = ashita.bits.unpack_be(packet, bit_offset + 36,  3),
                    kind     = ashita.bits.unpack_be(packet, bit_offset + 39,  2),
                    sub_kind = ashita.bits.unpack_be(packet, bit_offset + 41, 12),
                    info     = ashita.bits.unpack_be(packet, bit_offset + 53,  5),
                    scale    = ashita.bits.unpack_be(packet, bit_offset + 58,  5),
                    param    = ashita.bits.unpack_be(packet, bit_offset + 63, 17),
                    message  = ashita.bits.unpack_be(packet, bit_offset + 80, 10),
                    bit      = ashita.bits.unpack_be(packet, bit_offset + 90, 31),
                    has_proc           = false,
                    proc_animation     = nil,
                    proc_effect        = nil,
                    proc_param         = nil,
                    proc_message       = nil,
                    has_reaction       = false,
                    reaction_animation = nil,
                    reaction_effect    = nil,
                    reaction_param     = nil,
                    reaction_message   = nil,
                }

                -- Collect additional effect information for the action. This is
                -- where you'll find information about skillchains, enspell damage,
                -- et cetera.
                if ashita.bits.unpack_be(packet, bit_offset + 121, 1) == 1 then
                    action.targets[i].actions[j].has_proc       = true
                    action.targets[i].actions[j].proc_animation = ashita.bits.unpack_be(packet, bit_offset + 122, 6)
                    action.targets[i].actions[j].proc_effect    = ashita.bits.unpack_be(packet, bit_offset + 128, 4)
                    action.targets[i].actions[j].proc_param     = ashita.bits.unpack_be(packet, bit_offset + 132, 17)
                    action.targets[i].actions[j].proc_message   = ashita.bits.unpack_be(packet, bit_offset + 149, 10)

                    bit_offset = bit_offset + 37
                end

                -- Collect reaction effect information like spikes.
                if ashita.bits.unpack_be(packet, bit_offset + 122, 1) == 1 then
                    action.targets[i].actions[j].has_reaction       = true
                    action.targets[i].actions[j].reaction_animation = ashita.bits.unpack_be(packet, bit_offset + 123, 6)
                    action.targets[i].actions[j].reaction_effect    = ashita.bits.unpack_be(packet, bit_offset + 129, 4)
                    action.targets[i].actions[j].reaction_param     = ashita.bits.unpack_be(packet, bit_offset + 133, 14)
                    action.targets[i].actions[j].reaction_message   = ashita.bits.unpack_be(packet, bit_offset + 147, 10)

                    bit_offset = bit_offset + 34
                end

                bit_offset = bit_offset + 87
            end

            bit_offset = bit_offset + 36
        end

        return action
    end,
    actionTypes = {
        None = 0,
        Attack = 1,
        RangedFinish = 2,
        WeaponskillFinish = 3,
        SpellFinish = 4,
        ItemFinish = 5,
        AbilityFinish = 6,
        WeaponskillStart = 7,
        SpellStart = 8,
        ItemStart = 9,
        AbilityStart = 10,
        MobSkillFinish = 11,
        RangedStart = 12,
        PetAbilityFinish = 13,
        Dance = 14,
        RunWardEffusion = 15,
        Quarry = 16,
        Sprint = 17,
    }
}

local inboundBasic = {
    id = 0x029,
    name = 'Basic',
    ---@param packet string
    parse = function(packet)
        local basic = {
            sender     = struct.unpack('i4', packet, 0x04 + 1),
            target     = struct.unpack('i4', packet, 0x08 + 1),
            param      = struct.unpack('i4', packet, 0x0C + 1),
            value      = struct.unpack('i4', packet, 0x10 + 1),
            sender_tgt = struct.unpack('i2', packet, 0x14 + 1),
            target_tgt = struct.unpack('i2', packet, 0x16 + 1),
            message    = struct.unpack('i2', packet, 0x18 + 1),
        }

        return basic
    end
}

local inboundSpecial = {
    id = 0x02A,
    name = 'Special',
    ---@param packet string
    parse = function(packet)
        local special = {
            sender = struct.unpack('i4', packet, 0x04 + 1),
            param1 = struct.unpack('i4', packet, 0x08 + 1),
            param2 = struct.unpack('i4', packet, 0x0C + 1),
            param3 = struct.unpack('i4', packet, 0x10 + 1),
            param4 = struct.unpack('i4', packet, 0x14 + 1),
            senderIdx = struct.unpack('i2', packet, 0x18 + 1),
            message = struct.unpack('i2', packet, 0x1A + 1),
            -- name = struct.unpack('s', packet, 0x1E + 1),
        }

        return special
    end
}

local inboundDeath = {
    id = 0x02D,
    name = 'Death',
    ---@param packet string
    parse = function(packet)
        local death = {
            player     = struct.unpack('i4', packet, 0x04 + 1),
            target     = struct.unpack('i4', packet, 0x08 + 1),
            player_idx = struct.unpack('i2', packet, 0x0C + 1),
            target_idx = struct.unpack('i2', packet, 0x0E + 1),
            param1     = struct.unpack('i4', packet, 0x10 + 1),
            param2     = struct.unpack('i4', packet, 0x14 + 1),
            message    = struct.unpack('i2', packet, 0x18 + 1),
        }

        return death
    end
}

local inboundSynthAnimation = {
    id = 0x030,
    name = 'Synth Animation',
    ---@param packet string
    parse = function(packet)
        local synthAnimation = {
            player = struct.unpack('I4', packet, 0x04 + 1),
            playerIdx = struct.unpack('H', packet, 0x08 + 1),
            effect = struct.unpack('H', packet, 0x0A + 1),
            param = struct.unpack('B', packet, 0x0C + 1),
            animation = struct.unpack('B', packet, 0x0D + 1),
        }

        return synthAnimation
    end
}

local inboundNpcMessage = {
    id = 0x036,
    name = 'NPC Message',
    ---@param packet string
    parse = function(packet)
        local message = {
            sender     = struct.unpack('I', packet, 0x04 + 1),
            sender_idx = struct.unpack('H', packet, 0x08 + 1),
            message    = struct.unpack('H', packet, 0x0A + 1),
            mode       = struct.unpack('B', packet, 0x0C + 1),
        }

        return message
    end
}

local inboundKeyItems = {
    id = 0x055,
    name = 'Key Items',
    ---@param packet userdata
    parse = function(packet)
        local keyItems = {
            heldList = {},
            seenList = {},
            type = ashita.bits.unpack_be(packet, 0x84 * 8, 8)
        }

        local idBase = keyItems.type * 512
        local heldBit = 0x04 * 8
        local seenBit = 0x44 * 8

        for i = 0, 511 do
            keyItems.heldList[idBase + i] = ashita.bits.unpack_be(packet, heldBit + i, 1) == 1
            keyItems.seenList[idBase + i] = ashita.bits.unpack_be(packet, seenBit + i, 1) == 1
        end

        return keyItems
    end
}

local inboundCharStats = {
    id = 0x061,
    name = 'Character Stats',
    ---@param packet string
    parse = function(packet)
        local charstats = {
            max_hp      = struct.unpack('I4', packet, 0x04 + 1),
            max_mp      = struct.unpack('I4', packet, 0x08 + 1),

            main_job    = struct.unpack('I1', packet, 0x0C + 1),
            main_level  = struct.unpack('I1', packet, 0x0D + 1),
            sub_job     = struct.unpack('I1', packet, 0x0E + 1),
            sub_level   = struct.unpack('I1', packet, 0x0F + 1),
            current_exp = struct.unpack('I2', packet, 0x10 + 1),
            needed_exp  = struct.unpack('I2', packet, 0x12 + 1),

            base_str = struct.unpack('I2', packet, 0x14 + 1),
            base_dex = struct.unpack('I2', packet, 0x16 + 1),
            base_vit = struct.unpack('I2', packet, 0x18 + 1),
            base_agi = struct.unpack('I2', packet, 0x1A + 1),
            base_int = struct.unpack('I2', packet, 0x1C + 1),
            base_mnd = struct.unpack('I2', packet, 0x1E + 1),
            base_chr = struct.unpack('I2', packet, 0x20 + 1),

            bonus_str = struct.unpack('i2', packet, 0x22 + 1),
            bonus_dex = struct.unpack('i2', packet, 0x24 + 1),
            bonus_vit = struct.unpack('i2', packet, 0x26 + 1),
            bonus_agi = struct.unpack('i2', packet, 0x28 + 1),
            bonus_int = struct.unpack('i2', packet, 0x2A + 1),
            bonus_mnd = struct.unpack('i2', packet, 0x2C + 1),
            bonus_chr = struct.unpack('i2', packet, 0x2E + 1),

            atk = struct.unpack('I2', packet, 0x30 + 1),
            def = struct.unpack('I2', packet, 0x32 + 1),

            res_fire    = struct.unpack('i2', packet, 0x34 + 1),
            res_ice     = struct.unpack('i2', packet, 0x36 + 1),
            res_wind    = struct.unpack('i2', packet, 0x38 + 1),
            res_earth   = struct.unpack('i2', packet, 0x3A + 1),
            res_thunder = struct.unpack('i2', packet, 0x3C + 1),
            res_water   = struct.unpack('i2', packet, 0x3E + 1),
            res_light   = struct.unpack('i2', packet, 0x40 + 1),
            res_dark    = struct.unpack('i2', packet, 0x42 + 1),

            title = struct.unpack('I2', packet, 0x44 + 1),
            rank = struct.unpack('I2', packet, 0x46 + 1),
            rankpoints = struct.unpack('I2', packet, 0x48 + 1),
            homepoint = struct.unpack('I1', packet, 0x4A + 1),
            nation = struct.unpack('I1', packet, 0x50 + 1)
        }

        return charstats
    end
}

local inboundCharSkills = {
    id = 0x062,
    name = 'Character Skills',
    ---@param packet string
    parse = function(packet)
        local skillsUpdate = {
            combatSkills = {},
            craftSkills = {},
        }

        for i=0, 0x2F do
            skillsUpdate.combatSkills[i] = {
                level = bit.band(struct.unpack('H', packet, 0x80 + (i * 2) + 1), 0x7FFF),
                isCapped = bit.band(struct.unpack('H', packet, 0x80 + (i * 2) + 1), 0x8000) == 0x8000,
            }
        end

        for i=0, 0x09 do
            skillsUpdate.craftSkills[i] = {
                rank = bit.band(struct.unpack('H', packet, 0xE0 + (i * 2) + 1), 0x001F),
                level = bit.rshift(bit.band(struct.unpack('H', packet, 0xE0 + (i * 2) + 1), 0x7FE0), 5),
                isCapped = bit.band(struct.unpack('H', packet, 0xE0 + (i * 2) + 1), 0x8000) == 0x8000,
            }
        end

        return skillsUpdate
    end
}

local inboundMenuMerit = {
    id = 0x063,
    name = 'Menu Merit',
    -- This is only for the first packet in the sequence (it's 3 packets total),
    -- because it's the only one I care about for now.
    ---@param packet string
    parse = function(packet)
        local menumerit = {
            limit_points = struct.unpack('I2', packet, 0x08 + 1),
            merit_points = struct.unpack('I1', packet, 0x0A + 1),
        }

        return menumerit
    end
}

local inboundSynthResultPlayer = {
    id = 0x06F,
    name = 'Self Synth',
    ---@param packet string
    parse = function(packet)
        local selfSynth = {
            result = struct.unpack('B', packet, 0x04 + 1),
            quality = struct.unpack('b', packet, 0x05 + 1),
            count = struct.unpack('B', packet, 0x06 + 1),
            item = struct.unpack('H', packet, 0x08 + 1),
            lost = {
                [1] = struct.unpack('H', packet, 0x0A + 1),
                [2] = struct.unpack('H', packet, 0x0C + 1),
                [3] = struct.unpack('H', packet, 0x0E + 1),
                [4] = struct.unpack('H', packet, 0x10 + 1),
                [5] = struct.unpack('H', packet, 0x12 + 1),
                [6] = struct.unpack('H', packet, 0x14 + 1),
                [7] = struct.unpack('H', packet, 0x16 + 1),
                [8] = struct.unpack('H', packet, 0x18 + 1),
            },
            skill = {
                {
                    skillId = bit.band(struct.unpack('B', packet, 0x1A + 1), 63),
                    isSkillupAllowed = bit.band(struct.unpack('B', packet, 0x1A + 1), 40) == 40,
                    isDesynth = bit.band(struct.unpack('B', packet, 0x1A + 1), 80) == 80,
                },
                {
                    skillId = bit.band(struct.unpack('B', packet, 0x1B + 1), 63),
                    isSkillupAllowed = bit.band(struct.unpack('B', packet, 0x1B + 1), 40) == 40,
                    isDesynth = bit.band(struct.unpack('B', packet, 0x1B + 1), 80) == 80,
                },
                {
                    skillId = bit.band(struct.unpack('B', packet, 0x1C + 1), 63),
                    isSkillupAllowed = bit.band(struct.unpack('B', packet, 0x1C + 1), 40) == 40,
                    isDesynth = bit.band(struct.unpack('B', packet, 0x1C + 1), 80) == 80,
                },
                {
                    skillId = bit.band(struct.unpack('B', packet, 0x1D + 1), 63),
                    isSkillupAllowed = bit.band(struct.unpack('B', packet, 0x1D + 1), 40) == 40,
                    isDesynth = bit.band(struct.unpack('B', packet, 0x1D + 1), 80) == 80,
                },
            },
            skillup = {
                [1] = struct.unpack('B', packet, 0x1E + 1),
                [2] = struct.unpack('B', packet, 0x1F + 1),
                [3] = struct.unpack('B', packet, 0x20 + 1),
                [4] = struct.unpack('B', packet, 0x21 + 1),
            },
            crystal = struct.unpack('H', packet, 0x22 + 1),
        }

        return selfSynth
    end
}

local inboundSynthResultOther = {
    id = 0x070,
    name = 'Other Synth',
    ---@param packet string
    parse = function(packet)
        local otherSynth = {
            result = struct.unpack('B', packet, 0x04 + 1),
            quality = struct.unpack('b', packet, 0x05 + 1),
            count = struct.unpack('B', packet, 0x06 + 1),
            item = struct.unpack('H', packet, 0x08 + 1),
            lost = {
                [1] = struct.unpack('H', packet, 0x0A + 1),
                [2] = struct.unpack('H', packet, 0x0C + 1),
                [3] = struct.unpack('H', packet, 0x0E + 1),
                [4] = struct.unpack('H', packet, 0x10 + 1),
                [5] = struct.unpack('H', packet, 0x12 + 1),
                [6] = struct.unpack('H', packet, 0x14 + 1),
                [7] = struct.unpack('H', packet, 0x16 + 1),
                [8] = struct.unpack('H', packet, 0x18 + 1),
            },
            skill = {
                {
                    skillId = bit.band(struct.unpack('B', packet, 0x1A + 1), 63),
                    isSkillupAllowed = bit.band(struct.unpack('B', packet, 0x1A + 1), 40) == 40,
                    isDesynth = bit.band(struct.unpack('B', packet, 0x1A + 1), 80) == 80,
                },
                {
                    skillId = bit.band(struct.unpack('B', packet, 0x1B + 1), 63),
                    isSkillupAllowed = bit.band(struct.unpack('B', packet, 0x1B + 1), 40) == 40,
                    isDesynth = bit.band(struct.unpack('B', packet, 0x1B + 1), 80) == 80,
                },
                {
                    skillId = bit.band(struct.unpack('B', packet, 0x1C + 1), 63),
                    isSkillupAllowed = bit.band(struct.unpack('B', packet, 0x1C + 1), 40) == 40,
                    isDesynth = bit.band(struct.unpack('B', packet, 0x1C + 1), 80) == 80,
                },
                {
                    skillId = bit.band(struct.unpack('B', packet, 0x1D + 1), 63),
                    isSkillupAllowed = bit.band(struct.unpack('B', packet, 0x1D + 1), 40) == 40,
                    isDesynth = bit.band(struct.unpack('B', packet, 0x1D + 1), 80) == 80,
                },
            },
            playerName = struct.unpack('s', packet, 0x1E + 1),
        }

        return otherSynth
    end
}

local inboundFishBiteInfo = {
    id = 0x115,
    name = 'Fishing Bite Info',
    parse = function(packet)
        local fishBite = {
            biteId = struct.unpack('I', packet, 0x0A + 1),
            catchKey = struct.unpack('I', packet, 0x14 + 1),
        }

        return fishBite
    end,
}

local packets = {
    outbound = {
        startSynth = outboundStartSynth,
        fishingAction = outboundFishingAction,
        inventoryDrop = outboundInventoryDrop,
        inventoryMove = outboundInventoryMove,
        treasureLot = outboundTreasureLot,
        treasurePass = outboundTreasurePass,
    },
    inbound = {
        zoneIn = inboundZoneIn,
        pcUpdate = inboundPcUpdate,
        chatMessage = inboundChatMessage,
        inventorySize = inboundInventorySize,
        inventoryFinish = inboundInventoryFinish,
        inventoryModify = inboundInventoryModify,
        inventoryAssign = inboundInventoryAssign,
        inventoryItem = inboundInventoryItem,
        fishCatch = inboundCaughtFish,
        action = inboundAction,
        basic = inboundBasic,
        special = inboundSpecial,
        death = inboundDeath,
        synthAnimation = inboundSynthAnimation,
        npcMessage = inboundNpcMessage,
        keyItems = inboundKeyItems,
        charStats = inboundCharStats,
        charSkills = inboundCharSkills,
        menuMerit = inboundMenuMerit,
        synthResultPlayer = inboundSynthResultPlayer,
        synthResultOther = inboundSynthResultOther,
        fishBiteInfo = inboundFishBiteInfo,
    },
}

return packets
