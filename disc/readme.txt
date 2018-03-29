
PRINCE of PERSIA
by Jordan Mechner

BBC Master version
Proudly Presented by Bitshifters


ABOUT
Original Apple II, bugs and all.
Lovingly crafted over approximately
one year to create the ultimate 8-bit
version of the game.  <MOAR>


CREDITS
Ported by Kieran Connell
Graphics by John 'Dethmunk' Blythe
BBC Music & Sound by Inverse Phase
Additional Code by Simon Morris
Bitshifters Logo by Steve Horsborough


CONTACT
Visit our BBC Retro Coding webpage
https://bitshifters.github.io
Find us on Facebook: <link>
Say hello on Twitter @khconnell
Join the conversation at the Stardot
forums: <link>


INVERSE PHASE
www.inversephase.com
Facebook: <link>
Twitter: <link>
Soundcloud: <link>
Bandcamp: <link>
Patreon: <link>


MANY THANKS
Matt Godbolt
Rich Talbot-Watkins
Richard 'Tricky' Broadhurst
Sarah Walker
Dave 'Arcadian' Moore
Norbert @ Princed
David @ Princed
Matt Furniss
All our friends & supporters on Stardot


TOOLS USED
BeebAsm assembler: <link>
b-em emulator: <link>
jsbeeb emulator: <link>
Exomizer compressor: <link>
Pucrunch compressor: <link>
Deflemask Tracker: <link>
Visual Studio Code
GitHub


TECHNICAL SUPPORT
This game requires a standard issue
BBC Master 128K computer with all 4x
sideways RAM banks available and PAGE
at &E00.

Type "P.~PAGE" in BASIC to
check your PAGE value.  If this is
higher than &E00 then you may have
a ROM installed that is claiming
precious RAM!  Try unplugging any
non-essential ROMS with *UNPLUG.

This game has been tested on real
floppy disc, DataCentre, SMART SPI,
Turbo MMC and MMFS hardware.

For DataCentre:
*IMPORT -0 pop-beeb.ssd
*DTRAP

For MMC type systems:
Add the pop-beeb.ssd image to your
BEEB.MMB file using your regular tool
remembering the disc number used:
*DIN <disc no>
To enable save game:
*DUNLOCK <disc no>

Hit SHIFT-BREAK to boot the disc!

If you experience a crash or other bug
please report this on our GitHub page
along with an emulator save state file
if possible.


RELEASE NOTES
30/3/2018 Version 1.0
