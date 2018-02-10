; beeb-lang.asm
; Variables stored in Language workspace &300 - &800
; Technically &300 is VDU workspace not Language workspace but whatevs

\\ Moved from eq.asm

\*-------------------------------
\*
\*  Image lists
\*
\*-------------------------------

IF 1
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
ENDIF
IF 0
.midCU skip maxmid
.midCD skip maxmid
.midCL skip maxmid
.midCR skip maxmid
.midTAB skip maxmid
.objINDX skip maxobj
.objX skip maxobj
.objOFF skip maxobj
.objY skip maxobj
.objIMG skip maxobj
.objFACE skip maxobj
.objTYP skip maxobj
.objCU skip maxobj
.objCD skip maxobj
.objCL skip maxobj
.objCR skip maxobj
.objTAB skip maxobj
ENDIF
