# xitools
a collection of addons (and maybe some plugins) for Ashita that I made

## addons
- `skillchain` tracks active and potential skillchains and magic bursts
- `logger` logs some simple packet data for diagnostic and dev purposes
- `me` is a simple hud for displaying the player's basic status
- `tgt` is a simple hud for display the target's basic status
- `tracker` is a primitive ability tracker tailored for the author

### libs
- `packet` is a garbage dump of some packet-related functionality i needed
- `utils` is a garbage dump of everything else
- `lin/packets` is a simpler, less-disgusting, namespaced collection of the same
  packet functionality provided in `packet`
- `lin/jobs` contains job-related stuff. i probably don't need this, just too
  lazy to check the ashita docs for this
- `lin/text` is where all of the stuff related to text-display goes, like
  formatting numbers, colorizing stuff, and making percent bars

## config
these are my ashitacast configs. perhaps you'll find them useful; mostly i just
want them under source control with the rest of my ashita stuff.
