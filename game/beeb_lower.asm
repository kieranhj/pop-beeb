; lower.asm
; BSS vars in lower RAM (&900-&D00)

\\ from eq.asm
IF 1

IF 1
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
IF _NOT_BEEB
IIGS ds 1
ENDIF
.beeb_keypress_ctrl skip 1

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
ENDIF
.pausetemp skip 1
.recheck0 skip 1

\*-------------------------------
\*
\*  Blueprint info
\*
\*-------------------------------

\\ Moved to pop-beeb.asm

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

\\ Moved from gameeq.asm

IF 1

\*-------------------------------
\*  BEEB: moved from ZP
\*  $40-e7: Game globals
\*-------------------------------

;.yellowflag skip 1
;.timebomb skip 1
.justblocked skip 1
.gdtimer skip 1
.exitopen skip 1
.collX skip 1
.lightning skip 1
.lightcolor skip 1
.offguard skip 1
.blockid skip 1
.blockx skip 1
.blocky skip 1
.infrontx skip 1
.behindx skip 1
.abovey skip 1
.tempblockx skip 1
.tempblocky skip 1
.tempscrn skip 1
;.tempid skip 1
.numtrans skip 1
.tempnt skip 1
.redrawflg skip 1
;.xdiff skip 2
;.ydiff skip 2
;.xdir skip 1
;.ydir skip 1
.RNDseed skip 1
.invert skip 1
.PlayCount skip 1
.refract skip 1
IF _DEBUG
.backtolife skip 1
ENDIF
.cutplan skip 1
;.lastcmd skip 1
;.distfallen skip 1
.cutscrn skip 1
.waitingtojump skip 1
;.trigppabove skip 1
;.direcpp skip 1
;.blockaddr skip 2
;.delay skip 1
;.XCOORD skip 2
.savekidx skip 1
.mirrx skip 1
.dmirr skip 1
;.barrdist skip 1
;.barrcode skip 1
.imwidth skip 1
.imheight skip 1
;.leadedge skip 1
.leftej skip 1
.rightej skip 1
.topej skip 1
.leftblock skip 1
.rightblock skip 1
.topblock skip 1
.bottomblock skip 1
.CDLeftEj skip 1
.CDRightEj skip 1
.endrange skip 1
.bufindex skip 1
.blockedge skip 1
.collideL skip 1
.collideR skip 1
.weightless skip 1
.cutorder skip 1
.AMtimer skip 1
.begrange skip 1
;.scrn skip 1
.keybufptr skip 1
.VisScrn skip 1
.OppStrength skip 1
;.jarabove skip 1
.KidStrength skip 1
.ChgKidStr skip 1
.MaxKidStr skip 1
.EnemyAlert skip 1
.ChgOppStr skip 1
.heroic skip 1
.clrF skip 1
.clrB skip 1
.clrU skip 1
.clrD skip 1
.clrbtn skip 1
.Fsword skip 1
;.purpleflag skip 1 ;$da
.msgtimer skip 1
.msgdrawn skip 1
.MaxOppStr skip 1
.guardprog skip 1
.ManCtrl skip 1
.mergetimer skip 1
.lastpotion skip 1
.origstrength skip 1
;.jmpaddr skip 2
.alertguard skip 1
.createshad skip 1
.stunned skip 1
.droppedout skip 1


\*-------------------------------
\*
\*  Page 2-3 - AUX MEM
\*
\*-------------------------------

\ dum $212

.milestone skip 1
.GlassState skip 1
.redrawglass skip 1
.doortop skip 1
.GuardColor skip 1
.shadowaction skip 1
.skipmessage skip 1
;.savezp skip 32
;.MSset skip 1
.rjumpflag skip 1
;.redherring skip 1

\*-------------------------------
\*
\*  Page 2-3 - AUX MEM
\*
\*-------------------------------

\dum $300

.MinLeft skip 1
.NextTimeMsg skip 1
.SecLeft skip 1
.BGset1 skip 1
.BGset2 skip 1
.CHset skip 1
.FrameCount skip 2
;.SongCount skip 1
.PreRecPtr skip 1
.gotsword skip 1
.message skip 1
.SPEED skip 1
.nummob skip 1
.clrSEL skip 5
.clrDESEL skip 5
.vibes skip 1
.SongCue skip 1
.musicon skip 1
.redkidmeter skip 1
.NextLevel skip 1
.scrncolor skip 1
.redoppmeter skip 1
.timerequest skip 1

\*-------------------------------
\*
\*  Character data
\*
\*-------------------------------

.Op
.OpPosn skip 1
.OpX skip 1
.OpY skip 1
.OpFace skip 1
.OpBlockX skip 1
.OpBlockY skip 1
.OpAction skip 1
.OpXVel skip 1
.OpYVel skip 1
.OpSeq skip 2
.OpScrn skip 1
.OpRepeat skip 1
.OpID skip 1
.OpSword skip 1
.OpLife skip 1


keybuflen = 10
.keybuf skip keybuflen

\*-------------------------------
\*
\*  MOBTABLES
\*
\*-------------------------------

.mobtables

.trloc skip trobspace
.trscrn skip trobspace
.trdirec skip trobspace

.mobx skip mobspace
.moby skip mobspace
.mobscrn skip mobspace
.mobvel skip mobspace
.mobtype skip mobspace
.moblevel skip mobspace

;.soundtable ds maxsfx

.trobcount skip 1
ENDIF

\*-------------------------------
\*
\*  Page 2-3 - AUX MEM
\*
\*-------------------------------

IF 0
\dum $320
;PAGE_ALIGN
ALIGN &80  ; doesn't need to be page aligned but must be contained within same paage

.CDthisframe skip $10
.CDlastframe skip $10
.CDbelow skip $10
.CDabove skip $10
.SNthisframe skip $10
.SNlastframe skip $10
.SNbelow skip $10
.SNabove skip 10
.BlockYthis skip 1
.BlockYlast skip 1
ENDIF
