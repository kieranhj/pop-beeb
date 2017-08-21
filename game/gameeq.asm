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
;GlassState ds 1
;redrawglass ds 1
.doortop skip 1
;GuardColor ds 1
;shadowaction ds 1
;skipmessage ds 1
;savezp ds 32
;MSset ds 1
;rjumpflag ds 1
;redherring ds 1

\dum $300

.MinLeft skip 1
.NextTimeMsg skip 1
.SecLeft skip 1
.BGset1 skip 1
.BGset2 skip 1
.CHset skip 1
.FrameCount skip 2
;SongCount ds 1
;PreRecPtr ds 1
;gotsword ds 1
;message ds 1
.SPEED skip 1
;nummob ds 1
;clrSEL ds 5
;clrDESEL ds 5
.vibes skip 1
.SongCue skip 1
.musicon skip 1
;redkidmeter ds 1
.NextLevel skip 1
.scrncolor skip 1
;redoppmeter ds 1
.timerequest skip 1
