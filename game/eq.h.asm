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
\hrtables = $e000               ; location determined by assembler
unpack = $ea00 ;game only
\hires = $ee00                  ; location determined by assembler
master = $f880

\*  Auxmem

\grafix = $400                  ; location determined by assembler
\tables = $e00                  ; location determined by assembler
\frameadv = $1290               ; location determined by assembler
\redbufs = $5e00                ; location determined by assembler
menudata = $960f ;ed only
\imlists = $ac00                ; location determined by assembler
endimspace = $b600
\blueprnt = $b700               ; location determined by assembler

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

IF EditorDisk
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

\dum hires
\ jump tables moved to hires.asm

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

\dum grafix
\ jump tables moved to grafix.asm

\dum redbufs
\ redbufs moved to eq.asm

IF EditorDisk
 dum menudata ;ed only

menutype ds 30
menuspec ds 30
menubspec ds 30
ENDIF

\dum frameadv
\ jump table moved to frameadv.asm


\dum tables
\ tables moved to eq.asm


\dum blueprnt
\ definition moved to eq.asm


\*-------------------------------
\*
\*  Blueprint info
\*
\*-------------------------------
 
 \dum INFO
 \ Definition moved to eq.asm


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

\dum imlists
\ imlists moved to eq.asm

\*-------------------------------
\*
\*  Zero page - MAIN RAM
\*
\*-------------------------------
\*  $00-17: Hires parameters
\*-------------------------------

; NB these are shared between MAIN MEM & AUX MEM on Apple II

ORG $00

.PAGE skip 1
.XCO skip 1
.YCO skip 1
.OFFSET skip 1
.IMAGE skip 2
.OPACITY skip 1
.TABLE skip 2
.PEELBUF skip 2
.PEELIMG skip 2
.PEELXCO skip 1
.PEELYCO skip 1
.TOPCUT skip 1
.LEFTCUT skip 1
.RIGHTCUT skip 1
.BANK skip 1
.BOTCUT skip 1

height = IMAGE
width = IMAGE+1

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
.blackflag skip 1
.SCRNUM skip 1
.BlueType skip 2
.BlueSpec skip 2
;.CUTTIMER skip 1
.PRECED skip 1
.spreced skip 1
.PREV skip 3
.sprev skip 3
.scrnLeft skip 1
.scrnRight skip 1
.scrnAbove skip 1
.scrnBelow skip 1
.scrnBelowL skip 1
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
