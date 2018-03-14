; beeb-lang.asm
; Variables stored in Language workspace &300 - &800
; Technically &300 is VDU workspace not Language workspace but whatevs

\\ Moved from eq.asm

\*-------------------------------
\*
\*  Image lists
\*
\*-------------------------------

.genCLS skip 1

.bgX skip maxback
.bgY skip maxback
.bgIMG skip maxback
.bgOP skip maxback

.fgX skip maxfore
.fgY skip maxfore
.fgIMG skip maxfore
.fgOP skip maxfore

.wipeX skip maxwipe
.wipeY skip maxwipe
.wipeH skip maxwipe
.wipeW skip maxwipe
.wipeCOL skip maxwipe

.peelX skip maxpeel*2
.peelY skip maxpeel*2
.peelIMGL skip maxpeel*2
.peelIMGH skip maxpeel*2

.midX skip maxmid
.midOFF skip maxmid
.midY skip maxmid
.midIMG skip maxmid
.midOP skip maxmid
.midTYP skip maxmid
