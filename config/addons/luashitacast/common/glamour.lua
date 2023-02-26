local defaultGlam = {
    Head = "Dream Hat +1",
    Body = "Dream Robe",
    Hands = "Dream Mitts +1",
    Legs = "Dream Pants +1",
    Feet = "Dream Boots +1",
}

local function ShouldDisable(args)
    return (#args == 1 and gState.LockStyle) or args[2] == 'off'
end

local function HandleGlam(args)
    if args[1] == 'glam' then
        if ShouldDisable(args) then
            gState.LockStyle = false
            AshitaCore:GetChatManager():QueueCommand(1, '/lockstyle off')
            return
        end

        local glamSet = gProfile.Sets.Glamour
        gFunc.LockStyle(glamSet or defaultGlam)
    end
end

return HandleGlam
