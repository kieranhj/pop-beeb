; gameeq.asm
; Originally GAMEEQ.S
; Contains game definitions and memory addresses
; In memory tables and array space

\*-------------------------------
\*
\*  Page 2-3 - AUX MEM
\*
\*-------------------------------

IF _TODO
 dum $212

milestone ds 1
GlassState ds 1
redrawglass ds 1
ENDIF
.doortop skip 1
IF _TODO
GuardColor ds 1
shadowaction ds 1
skipmessage ds 1
savezp ds 32
MSset ds 1
rjumpflag ds 1
redherring ds 1
ENDIF

IF _TODO
 dum $300

MinLeft ds 1
NextTimeMsg ds 1
SecLeft ds 1
ENDIF
.BGset1 skip 1
IF _TODO
BGset2 ds 1
CHset ds 1
FrameCount ds 2
SongCount ds 1
PreRecPtr ds 1
gotsword ds 1
message ds 1
SPEED ds 1
nummob ds 1
clrSEL ds 5
clrDESEL ds 5
vibes ds 1
SongCue ds 1
ENDIF
.musicon skip 1
IF _TODO
redkidmeter ds 1
ENDIF
.NextLevel skip 1
.scrncolor skip 1
IF _TODO
redoppmeter ds 1
timerequest ds 1
ENDIF
