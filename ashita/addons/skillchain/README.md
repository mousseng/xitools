# skillchain
Tracks potential and active skillchains within your party.

# installation
The easiest way is to just copy the entire `xitools/addons/` folder to your
Ashita installation directory (to be merged with the existing `Ashita/addons`
directory). However, all that is needed for this particular addon is:
  - `xitools/addons/skillchain/`
  - `xitools/addons/libs/lin/text.lua`
  - `xitools/addons/libs/lin/packets.lua`

# usage
`/addon load skillchain`

# known issues
- no blue mage support
- some job abilities are treated as weaponskills by the server's packet handler
  - dragoon's Jump and High Jump are confirmed instances of this
  - Steal as well

# potential issues
- can puppetmasters' mammets weaponskill?
