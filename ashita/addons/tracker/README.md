# tracker
It's kinda like `status` or whatever, but sucks a bit more. And is very specific
about what buffs it tracks (currently only Haste and Refresh).

# installation
The easiest way is to just copy the entire `xitools/addons/` folder to your
Ashita installation directory (to be merged with the existing `Ashita/addons`
directory). However, all that is needed for this particular addon is:
  - `xitools/addons/tracker/`
  - `xitools/addons/libs/lin/ffxi.lua`
  - `xitools/addons/libs/lin/text.lua`
  - `xitools/addons/libs/lin/packets.lua`

# usage
`/addon load tracker`

# known issues
- it doesn't detect shorter-than-normal durations. i'm sure that information is
  somewhere in a packet, or if not then could be calculated out.

# potential issues
- no unknown issues on the horizon
