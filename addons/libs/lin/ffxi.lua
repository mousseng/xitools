lin = lin or { }

-- Fetch an entity by its server ID. Helpful when looking up information from
-- packets, which tend to not include the entity index (since that's a client
-- thing only). Returns nil if no matching entity is found.
local function get_entity_by_server_id(id)
    -- The entity array is 2304 items long
    for x = 0, 2303 do
        local e = GetEntity(x)

        -- Ensure the entity is valid
        if e ~= nil and e.WarpPointer ~= 0 then
            if e.ServerId == id then
                return e
            end
        end
    end

    return nil
end
lin.get_entity_by_server_id = get_entity_by_server_id

-- Shorthand method to grab an entity's name (by server id, obviously) or a
-- placeholder string if the entity can't be found.
local function get_entity_name_by_server_id(id, default_name)
    local e = get_entity_by_server_id(id)

    if e ~= nil and e.Name ~= nil then
        return e.Name
    else
        return default_name or '[unknown]'
    end
end
lin.get_entity_name_by_server_id = get_entity_name_by_server_id

-- Determines if a particular entity (given as a server ID) belongs to the
-- player's alliance.
local function is_server_id_in_party(id)
    local party = AshitaCore:GetDataManager():GetParty()

    for i = 0, 17 do
        if party:GetMemberActive(i) == 1
        and party:GetMemberServerId(i) ~= 0 then
            local party_mem = GetEntity(party:GetMemberTargetIndex(i))

            if party_mem ~= nil and party_mem.ServerId == id then
                return true
            end
        end
    end

    return false
end
lin.is_server_id_in_party = is_server_id_in_party

-- Determines if a particular pet (given as a server ID) belongs to the
-- player's alliance.
local function is_pet_server_id_in_party(id)
    local party = AshitaCore:GetDataManager():GetParty()

    for i = 0, 17 do
        if party:GetMemberActive(i) == 1
        and party:GetMemberServerId(i) ~= 0 then
            local party_mem = GetEntity(party:GetMemberTargetIndex(i))

            if party_mem ~= nil and party_mem.PetTargetIndex ~= nil then
                local party_pet = GetEntity(party_mem.PetTargetIndex)

                if party_pet ~= nil and party_pet.ServerId == id then
                    return true
                end
            end
        end
    end

    return false
end
lin.is_pet_server_id_in_party = is_pet_server_id_in_party
