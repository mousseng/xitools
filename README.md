# xitools
a collection of addons (and maybe some plugins) for Ashita that I made

## addons
- `logger` logs some simple packet data for diagnostic and dev purposes
- `me` is a simple hud for displaying the player's basic status
- `rcheck` makes it easy to check party/alliance readiness by asking and doing
  the tallying for you
- `skillchain` tracks active and potential skillchains and magic bursts
- `tgt` is a simple hud for display the target's basic status
- `tracker` is a primitive ability tracker tailored for the author
- `xp` is a shitty exp tracker. you should probably just use watchexp instead


### libs
- `lin/ffxi` has a bunch of utility-ish functions around ashita/ffxi tools
- `lin/packets` provides functions to turn binary packet data into usable lua
  tables
- `lin/jobs` contains job-related stuff. i probably don't need this, just too
  lazy to check the ashita docs for this
- `lin/text` is where all of the stuff related to text-display goes, like
  formatting numbers, colorizing stuff, and making percent bars

## config
these are my ashitacast configs. perhaps you'll find them useful; mostly i just
want them under source control with the rest of my ashita stuff.
