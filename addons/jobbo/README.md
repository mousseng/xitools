# jobbo
A simple-to-configure (though perhaps limited in power) framework for tracking
important recasts and status durations for jobs.

There are significant caveats during this pre-1.0 stage:
 - it is designed very specifically to support the author's workflow and UI
 - it only supports spells currently
 - it only supports main-job configuration (you can still track subjob spells,
   but you can't configure it based on subjobs)
 - it's fuckin ugly as shit and probably buggy too

Another note (this is more of a design decision than issue) is that effects that
reduce your recast time means that the percent bar will start at a higher value
than 0. This is because those recast times are (currently) hard-coded in the
configuration.

> This addon is slow as fuck, I think. I'm avoiding using it for now, and might
> just make job-specific addons for tracking the abilities I care about instead.
> But it's here if you want it.

# installation
The easiest way is to just copy the entire `xitools/addons/` folder to your
Ashita installation directory (to be merged with the existing `Ashita/addons`
directory). However, all that is needed for this particular addon is:
  - `xitools/addons/jobbo/`
  - `xitools/addons/libs/utils.lua`
  - `xitools/addons/libs/packet.lua`
