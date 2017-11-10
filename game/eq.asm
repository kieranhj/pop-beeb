; eq.asm
; Originally EQ.S
; Contains global definitions and memory addresses
; In memory tables and array space

\*-------------------------------
\*
\*  Image lists
\*
\*-------------------------------

.imlists

\\ Moved to beeb-lang.asm to store in Language workspace area = &300 - &800

IF 0
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

\ BEEB GFX PERF - can make these *1 if single buffered
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
ENDIF

\\ Moved to beeb-lower.asm to store in lower (below PAGE) RAM = &900 - &D00

IF 0
IF 1
.objCD skip maxobj
.objCL skip maxobj
.objCR skip maxobj
.objTAB skip maxobj
ENDIF

.msgX skip maxmsg
.msgOFF skip maxmsg
.msgY skip maxmsg
.msgIMG skip maxmsg
.msgOP skip maxmsg

\*-------------------------------
\*
\*  Pages 2-3
\*
\*-------------------------------

\ dum $200

.inmenu skip 1
.inbuilder skip 1
IF _TODO
ineditor ds 1
ENDIF
.soundon skip 1
IF _TODO
jctr ds 2
jthres1x ds 1
jthres1y ds 1
jthres2x ds 1
jthres2y ds 1
ENDIF
.jvert skip 1
.jhoriz skip 1
.jbtns skip 1
.joyon skip 1
.develment skip 1
.keypress skip 1
.keydown skip 1
IF _TODO
IIGS ds 1
ENDIF

\dum $3c0

.sortX skip $10
.BELOW skip $10
.SBELOW skip $10

\dum $3f0

IF _TODO
bluepTRK ds 1
bluepREG ds 1
binfoTRK ds 1
binfoREG ds 1
ENDIF
.level skip 1
IF _TODO
BBundID ds 1
redherring2 ds 1
pausetemp ds 1
ENDIF
.recheck0 skip 1

.redbufs
 ;skip 60 ;unused - why?
.halfbuf skip 30
.redbuf skip 30
.fredbuf skip 30
.floorbuf skip 30
.wipebuf skip 30
.movebuf skip 30
.objbuf skip 30
.whitebuf skip 30
.topbuf skip 10

IF _DEBUG
.bgTOP      skip 1
.fgTOP      skip 1
.wipeTOP    skip 1
.peelTOP    skip 1
.midTOP     skip 1
.objTOP     skip 1
.msgTOP     skip 1 
ENDIF

ENDIF

\*-------------------------------
\*
\*  Blueprint info
\*
\*-------------------------------

\\ Moved to pop-beeb.asm as now stored in HAZEL
