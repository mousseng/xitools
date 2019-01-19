# skillchain
Tracks potential and active skillchains within your party.

# installation
The easiest way is to just copy the entire `xitools/addons/` folder to your
Ashita installation directory (to be merged with the existing `Ashita/addons`
directory). However, all that is needed for this particular addon is:
  - `xitools/addons/skillchain/`
  - `xitools/addons/libs/utils.lua`
  - `xitools/addons/libs/packet.lua`

# usage
`/addon load skillchain`

# known issues
- incomplete pet support
  - how do i know what ability an avatar has used?
  - darkstar doesn't track an entity's owner correctly, so using that field to
    determine pet status is unreliable
  - no support at all for dragoon, beastmaster, and puppetmaster (unsure if they
    are even able to chain with their pets)
- no blue mage support
- no magic burst support
- some job abilities are treated as weaponskills by the server's packet handler
  - dragoon's Jump and High Jump are confirmed instances of this

# potential issues
- how do alliances play into this?
