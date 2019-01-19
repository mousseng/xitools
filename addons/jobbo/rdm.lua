-------------------------------------------------------------------------------
-- Red Mage configuration
-------------------------------------------------------------------------------

local job_code = 5

GlobalJobConfig = GlobalJobConfig or { }

GlobalJobConfig[job_code] = {
    [109] = {
        tag = 'RDM_Refresh',
        name = 'Refresh',
        duration = 150,
        recast = 18,
    },
    -- [57] = {
    --     tag = 'RDM_Haste',
    --     name = 'Haste',
    --     duration = 180,
    --     recast = 20,
    -- },
}
