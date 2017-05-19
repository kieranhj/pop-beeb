; eq.h.asm
; Originally EQ.S
; Contains global definitions and memory addresses

\* eq
\*-------------------------------
\*
\*  Equates
\*
\*-------------------------------
\*  Main l.c.

rw18 = $d000
peelbuf1 = $d000
peelbuf2 = $d800
hrtables = $e000
unpack = $ea00 ;game only
hires = $ee00
master = $f880

\*  Auxmem

grafix = $400
tables = $e00
frameadv = $1290
redbufs = $5e00
menudata = $960f ;ed only
imlists = $ac00
endimspace = $b600
blueprnt = $b700

\*  Aux l.c.

bluecopy = $d000 ;bank 1

\*-------------------------------
\*
\*  Jump tables
\*
\*-------------------------------

IF _TODO
 dum master

_firstboot ds 3
_loadlevel ds 3
_reload ds 3
_loadstage2 ds 3
 ds 3

_attractmode ds 3
_cutprincess ds 3
_savegame ds 3
_loadgame ds 3
_dostartgame ds 3

_epilog ds 3
_loadaltset ds 3
 ds 3 ;_screendump
ENDIF

IF _EDITOR
 dum master ;ed

 ds 15

_edreboot ds 3
_gobuild ds 3
_gogame ds 3
_writedir ds 3
_readdir ds 3

_savelevel ds 3
_savelevelg ds 3
_screendump ds 3
ENDIF

IF _TODO
 dum hrtables

YLO ds $c0
YHI ds $c0
ENDIF

IF _TODO
 dum hires

_boot3 ds 3
_cls ds 3
_lay ds 3
_fastlay ds 3
_layrsave ds 3

_lrcls ds 3
_fastmask ds 3
_fastblack ds 3
_peel ds 3
_getwidth ds 3

_copy2000 ds 3
_copy2000aux ds 3
_setfastaux ds 3
_setfastmain ds 3
_copy2000ma ds 3

_copy2000am ds 3
ENDIF

IF _TODO
 dum unpack

SngExpand ds 3
DblExpand ds 3
DeltaExpPop ds 3
_inverty ds 3
DeltaExpWipe ds 3

purple ds 3
prompt ds 3
blackout ds 3
clr ds 3
text ds 3

setdhires ds 3
fadein ds 3
loadsuper ds 3
fadeout ds 3
ENDIF

IF _TODO
 dum grafix

gr ds 3
drawall ds 3
controller ds 3
 ds 3
saveblue ds 3

reloadblue ds 3
movemem ds 3
buttons ds 3
gtone ds 3
setcenter ds 3

dimchar ds 3
cvtx ds 3
zeropeel ds 3
zeropeels ds 3
pread ds 3

addpeel ds 3
copyscrn ds 3
sngpeel ds 3
rnd ds 3
cls ds 3

lay ds 3
fastlay ds 3
layrsave ds 3
lrcls ds 3
fastmask ds 3

fastblack ds 3
peel ds 3
getwidth ds 3
copy2000 ds 3
copy2000ma ds 3

setfastaux ds 3
setfastmain ds 3
loadlevel ds 3
attractmode ds 3
xminit ds 3

xmplay ds 3
cutprincess ds 3
xtitle ds 3
copy2000am ds 3
reload ds 3

loadstage2 ds 3
 ds 3
getselect ds 3
getdesel ds 3
edreboot ds 3 ;ed

gobuild ds 3 ;ed
gogame ds 3 ;ed
writedir ds 3 ;ed
readdir ds 3 ;ed
savelevel ds 3 ;ed

savelevelg ds 3 ;ed
addback ds 3
addfore ds 3
addmid ds 3
addmidez ds 3

addwipe ds 3
addmsg ds 3
savegame ds 3
loadgame ds 3
zerolsts ds 3

screendump ds 3
minit ds 3
mplay ds 3
savebinfo ds 3
reloadbinfo ds 3

inverty ds 3
normspeed ds 3
addmidezo ds 3
calcblue ds 3
zerored ds 3

xplaycut ds 3
checkIIGS ds 3
fastspeed ds 3
musickeys ds 3
dostartgame ds 3

epilog ds 3
loadaltset ds 3
xmovemusic ds 3
whoop ds 3
vblank ds 3

vbli ds 3
ENDIF

IF _TODO
 dum redbufs

 ds 60 ;unused
halfbuf ds 30
redbuf ds 30
fredbuf ds 30
floorbuf ds 30
wipebuf ds 30
movebuf ds 30
objbuf ds 30
whitebuf ds 30
topbuf ds 10
ENDIF

IF _EDITOR
 dum menudata ;ed only

menutype ds 30
menuspec ds 30
menubspec ds 30
ENDIF

IF _TODO
 dum frameadv

sure ds 3
fast ds 3
getinitobj ds 3
ENDIF

IF _TODO
 dum tables

ByteTable ds $100
OffsetTable ds $100
BlockTable ds $100
PixelTable ds $100
Mult10 ds $10
Mult7 ds $10
Mult30 ds $40
BlockEdge ds 20
BlockTop ds 5
BlockBot ds 5
FloorY ds 5
BlockAy ds 5
ENDIF

IF _TODO
 dum blueprnt

BLUETYPE ds 24*30
BLUESPEC ds 24*30
LINKLOC ds 256
LINKMAP ds 256
MAP ds 24*4
INFO ds 256
ENDIF

\*-------------------------------
\*
\*  Blueprint info
\*
\*-------------------------------
 
 IF _TODO
 dum INFO

 ds 64
KidStartScrn ds 1
KidStartBlock ds 1
KidStartFace ds 1
 ds 1
SwStartScrn ds 1
SwStartBlock ds 1
 ds 1
GdStartBlock ds 24
GdStartFace ds 24
GdStartX ds 24
GdStartSeqL ds 24
GdStartProg ds 24
GdStartSeqH ds 24
ENDIF

\*-------------------------------
\*
\*  Image lists
\*
\*-------------------------------
maxback = 200 ;x4
maxfore = 100 ;x4
maxwipe = 20 ;x5
maxpeel = 46 ;x4
maxmid = 46 ;x11
maxobj = 20 ;x12
maxmsg = 32 ;x5

IF _TODO
 dum imlists

genCLS ds 1

bgX ds maxback
bgY ds maxback
bgIMG ds maxback
bgOP ds maxback

fgX ds maxfore
fgY ds maxfore
fgIMG ds maxfore
fgOP ds maxfore

wipeX ds maxwipe
wipeY ds maxwipe
wipeH ds maxwipe
wipeW ds maxwipe
wipeCOL ds maxwipe

peelX ds maxpeel*2
peelY ds maxpeel*2
peelIMGL ds maxpeel*2
peelIMGH ds maxpeel*2

midX ds maxmid
midOFF ds maxmid
midY ds maxmid
midIMG ds maxmid
midOP ds maxmid
midTYP ds maxmid
midCU ds maxmid
midCD ds maxmid
midCL ds maxmid
midCR ds maxmid
midTAB ds maxmid

objINDX ds maxobj
objX ds maxobj
objOFF ds maxobj
objY ds maxobj
objIMG ds maxobj
objFACE ds maxobj
objTYP ds maxobj
objCU ds maxobj
objCD ds maxobj
objCL ds maxobj
objCR ds maxobj
objTAB ds maxobj

msgX ds maxmsg
msgOFF ds maxmsg
msgY ds maxmsg
msgIMG ds maxmsg
msgOP ds maxmsg
ENDIF

\*-------------------------------
\*
\*  Zero page - MAIN RAM
\*
\*-------------------------------
\*  $00-17: Hires parameters
\*-------------------------------
ORG $00

;.PAGE skip 1
;.XCO skip 1
;.YCO skip 1
;.OFFSET skip 1
;.IMAGE skip 2
;.OPACITY skip 1
;.TABLE skip 2
;.PEELBUF skip 2
;.PEELIMG skip 2
;.PEELXCO skip 1
;.PEELYCO skip 1
;.TOPCUT skip 1
;.LEFTCUT skip 1
;.RIGHTCUT skip 1
;.BANK skip 1
;.BOTCUT skip 1

;height = IMAGE
;width = IMAGE+1

\*-------------------------------
\*  $18-3f: Global vars
\*-------------------------------
; not sure why this is being explitly set
;ORG $18

;.JSTKX skip 1
;.JSTKY skip 1
;.BTN0 skip 1
;.BTN1 skip 1
;.BUTT0 skip 1
;.BUTT1 skip 1
;.JSTKUP skip 1
;.b0down skip 1
;.b1down skip 1
;.SINGSTEP skip 1
;.blackflag skip 1
;.SCRNUM skip 1
;.BlueType skip 2
;.BlueSpec skip 2
;.CUTTIMER skip 1
;.PRECED skip 1
;.spreced skip 1
;.PREV skip 3
;.sprev skip 3
;.scrnLeft skip 1
;.scrnRight skip 1
;.scrnAbove skip 1
;.scrnBelow skip 1
;.scrnBelowL skip 1
;.scrnAboveL skip 1
;.scrnAboveR skip 1
;.scrnBelowR skip 1
;.kbdX skip 1
;.kbdY skip 1
;.joyX skip 1
;.joyY skip 1
;.btn skip 1
;.butt skip 1

\*-------------------------------
\*
\*  Pages 2-3
\*
\*-------------------------------

IF _TODO
 dum $200

inmenu ds 1
inbuilder ds 1
ineditor ds 1
soundon ds 1
jctr ds 2
jthres1x ds 1
jthres1y ds 1
jthres2x ds 1
jthres2y ds 1
jvert ds 1
jhoriz ds 1
jbtns ds 1
joyon ds 1
develment ds 1
keypress ds 1
keydown ds 1
IIGS ds 1
ENDIF

IF _TODO
 dum $3c0

sortX ds $10
BELOW ds $10
SBELOW ds $10
ENDIF

IF _TODO
 dum $3f0

bluepTRK ds 1
bluepREG ds 1
binfoTRK ds 1
binfoREG ds 1
level ds 1
BBundID ds 1
redherring2 ds 1
pausetemp ds 1
recheck0 ds 1

 dend
ENDIF

\*-------------------------------
\*
\*  Misc. constants
\*
\*-------------------------------
ScrnWidth = 140
ScrnHeight = 192

ScrnLeft = 58
ScrnRight = ScrnLeft+ScrnWidth-1
ScrnTop = 0
ScrnBottom = ScrnTop+ScrnHeight-1

secmask = %11000000
reqmask = %00100000
idmask = %00011111

enum_and = 0
enum_ora = 1
enum_sta = 2
enum_eor = 3
enum_mask = 4
