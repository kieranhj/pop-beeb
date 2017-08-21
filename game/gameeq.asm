; gameeq.asm
; Originally GAMEEQ.S
; Contains game definitions and memory addresses
; In memory tables and array space

\*-------------------------------
\*
\*  Page 2-3 - AUX MEM
\*
\*-------------------------------

\ dum $212

.milestone skip 1
;.GlassState skip 1
;.redrawglass skip 1
.doortop skip 1
;.GuardColor skip 1
;.shadowaction skip 1
.skipmessage skip 1
;.savezp skip 32
;.MSset skip 1
;.rjumpflag skip 1
;.redherring skip 1

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
;.clrSEL skip 5
;.clrDESEL skip 5
.vibes skip 1
.SongCue skip 1
.musicon skip 1
;.redkidmeter skip 1
.NextLevel skip 1
.scrncolor skip 1
;.redoppmeter skip 1
.timerequest skip 1
