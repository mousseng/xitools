# xitools
a collection of addons (and maybe some plugins) for Ashita that I made.
the ones in `ashita-v3` are no longer maintained since I'm using v4 now. sorry.

## addons
- `me` is a simple hud for displaying the player's basic status
- `tgt` is a simple hud for display the target's basic status
- `rcheck` makes it easy to check party/alliance readiness by asking and doing
  the tallying for you
- `skillchain` tracks active and potential skillchains and magic bursts
- `tracker` is a primitive ability tracker tailored for the author
- `logger` logs some simple packet data for diagnostic and dev purposes

### libs
- `core/` libraries are intended to be fundamental building blocks - common data
  structures and algorithms
- `lin/ffxi` has a bunch of utility-ish functions around ashita/ffxi tools
- `lin/packets` provides functions to turn binary packet data into usable lua
  tables
- `lin/jobs` contains job-related stuff. i probably don't need this, just too
  lazy to check the ashita docs for this
- `lin/text` is where all of the stuff related to text-display goes, like
  formatting numbers, colorizing stuff, and making percent bars

### v4 porting status
- [x] `me`
- [x] `tgt`
- [x] `rcheck`
- [ ] `skillchain`
- [ ] `tracker`
- [ ] `logger`
- [ ] ashitacast configs
  - i suspect this doesn't require any change, but still need to check

## config
these are my ashitacast configs. perhaps you'll find them useful; mostly i just
want them under source control with the rest of my ashita stuff.
