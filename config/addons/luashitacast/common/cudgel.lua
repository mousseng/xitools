local function HandleCudgel(args)
    if args[1] == 'cudgel' then
        gFunc.Disable('Main')
        gFunc.ForceEquip('Main', "Warp Cudgel")

        ashita.tasks.once(31, function()
            AshitaCore:GetChatManager():QueueCommand('/item "Warp Cudgel" <me>')
        end)

        ashita.tasks.once(40, function()
            gFunc.Enable('Main')
        end)
    end
end

return HandleCudgel
