# PICRAFT


Built for LÖVE 11.4. Full support for ARM based Macs, Raspberry Pi 4, tvOS, and Intel.

See [http://www.love2d.org]() for more info.

Picraft was built using Lovecraft as a starting point. However, the code has been completely rewritten. A few stray files remain, but most can be safely removed from the project.

The purpose of this software is demonstrate how different algorithms can be used to produce different results. See lua code files under [game/generators](game/generators) for examples.

p_random and perlin noise code has been added to the code. checkout [game/random.lua](game/random.lua) and [game/perlin.lua](game/perlin.lua) to checkout to the algorithms.

Each level in the game uses either a different generator or a different seed.

# PACKAGE

`zip -r game picraft.love`


# TEST

`love11.4 tests`

# RUN

`love11.4 game`


## Credits, attributions and other rubbish ##

Made with the LÖVE framework
[http://www.love2d.org]()

Inspired by lovecraft, a game by Middlerun

[http://www.middlerun.net]()
