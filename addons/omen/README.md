omen
=================================================

do you like Omen? me too. do you hate reading the chat log? me too. this will
display your objectives in a neat window to make it easier to follow along with
what's happening!

usage
-------------------------------------------------

`/addon load omen`. that's it. it will pop up once you zone into the instance.

installation
-------------------------------------------------

in addition to the normal addon installation process of copying this into your
`addons/` folder, it's __highly recommended__ to include the following update
in your ashita datmap config (`config/ashita/custom.datmap.ini`):

```ini
[dialog.omen]
name        = dialog.omen
type        = 1
threaded    = 1
na_id       = 85627
jp_id       = -1
na_param    = 0
jp_param    = 0
```

this allows the addon to scan for message IDs on startup, which is important
because these IDs change with every single client update. i am lazy, so what
generally happens is that the addon is broken until i remember omen exists each
month.
