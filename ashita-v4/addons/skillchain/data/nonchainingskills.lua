-- A set-style table of weaponskills that do not interact with skillchains. It
-- is keyed by the animation ID.
return {
    [8] = true,
    [36] = true,
    [37] = true,
    [79] = true,
    [80] = true,
    [87] = true,
    [89] = true,
    [143] = true,
    [149] = true,
    [150] = true,
    [230] = true,
    -- HACK: dragoon jump abilities. For some reason these are counted as
    -- weaponskills rather than abilities, in spite of appearing in darkstar's
    -- ability table.
    [204] = true,
    [209] = true,
    [214] = true,
}
