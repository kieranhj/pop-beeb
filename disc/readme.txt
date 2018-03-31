
PRINCE of PERSIA
by Jordan Mechner

BBC Master version
Proudly Presented by Bitshifters


ABOUT
This faithful port has been lovingly
crafted from the original Apple II
6502 assembly source code posted on
GitHub by the author Jordan Mechner.

All original gameplay features (and
some original bugs!) are complete
but with an entirely custom written
sprite engine, music & audio system,
memory handler, file system and more.

Our goal was to create the ultimate
8-bit version of the game for the
BBC Master computer, featuring
entirely brand new 8 colour graphics
and a whole soundtrack based on the
PC midi music considered definitive
by the original author.

We hope you enjoy playing this game
as much as we've enjoyed making it.


CREDITS
Ported by Kieran Connell
Graphics by John 'Dethmunk' Blythe
Additional Code by Simon Morris
BBC Music & Sound by Inverse Phase
Bitshifters Logo by @Horsenburger


CONTACT
Visit our BBC Retro Coding webpage
https://bitshifters.github.io
Find us on Facebook
https://www.facebook.com/bitshiftrs/
Say hello on Twitter
https://twitter.com/khconnell
Join the Acorn community at Stardot
http://stardot.org.uk/forums/


INVERSE PHASE
is creating authentic chiptunes
please offer your support by visiting
www.inversephase.com


MANY THANKS
Matt Godbolt
Rich Talbot-Watkins
Stewart Badger
Richard 'Tricky' Broadhurst
Sarah Walker
Dave 'Arcadian' Moore
David 'Hoglet' Banks
Norbert @ princed.org
David @ princed.org
Matt Furniss
All our friends & supporters on Stardot


TOOLS USED
BeebAsm, b-em emulator, jsbeeb emulator
Exomizer, Pucrunch, Deflemask Tracker
Visual Studio Code, GitHub & more


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
floppy disc hardware, Retroclinic
DataCentre and MAMMFS for MMC devices.

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
