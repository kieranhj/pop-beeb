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
.genCLS skip 1

\ BEEB MOVED TO POP-BEEB.ASM TO BE STORERD LOWER DOWN IN RAM
;.bgX skip maxback
;.bgY skip maxback
;.bgIMG skip maxback
;.bgOP skip maxback

;.fgX skip maxfore
;.fgY skip maxfore
;.fgIMG skip maxfore
;.fgOP skip maxfore

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
jvert ds 1
jhoriz ds 1
jbtns ds 1
joyon ds 1
ENDIF
.develment skip 1
.keypress skip 1
IF _TODO
keydown ds 1
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

\*-------------------------------
\*
\*  Blueprint info
\*
\*-------------------------------

IF 0 \\ BEEB TEMP
.blueprnt
.BLUETYPE skip 24*30
.BLUESPEC skip 24*30
.LINKLOC skip 256
.LINKMAP skip 256
.MAP skip 24*4
.INFO
 skip 64                ; not sure why this is skipped, unused?
.KidStartScrn skip 1
.KidStartBlock skip 1
.KidStartFace skip 1
 skip 1
.SwStartScrn skip 1
.SwStartBlock skip 1
 skip 1
.GdStartBlock skip 24
.GdStartFace skip 24
.GdStartX skip 24
.GdStartSeqL skip 24
.GdStartProg skip 24
.GdStartSeqH skip 24
ENDIF

.redbufs
 skip 60 ;unused - why?
.halfbuf skip 30
.redbuf skip 30
.fredbuf skip 30
.floorbuf skip 30
.wipebuf skip 30
.movebuf skip 30
.objbuf skip 30
.whitebuf skip 30
.topbuf skip 10
