; gameeq.h.asm
; Originally GAMEEQ.S
; Contains game definitions and memory addresses

\* gameeq
\*-------------------------------
\*
\*  Equates
\*
\*-------------------------------

\chtable1 = $6000               ; see pop-beeb.asm
\chtable2 = $8400               ; see pop-beeb.asm
\chtable3 = $0800               ; see pop-beeb.asm
\chtable4 = $9600               ; see pop-beeb.asm
\chtable5 = $a800               ; see pop-beeb.asm
\chtable6 = $6000               ; see pop-beeb.asm
\chtable7 = $9f00               ; see pop-beeb.asm

\bgtable1 = $6000               ; see pop-beeb.asm
\bgtable2 = $8400               ; see pop-beeb.asm

\topctrl = $2000                ; see topctrl.asm
\seqtable = $2800               ; see framedefs.asm
\seqtab = $3000                 ; see seqtable.asm
\ctrl = $3a00                   ; see ctrl.asm
\coll = $4500                   ; see coll.asm
\gamebg = $4c00                 ; see gamebg.asm
\auto = $5400                   ; see auto.asm

\mobtables = $b600              ; location determined by assembler
;savedgame = $b6f0

;msys = $d400
\ctrlsubs = $d000               ; see ctrlsubs.asm
\specialk = $d900               ; see specialk.asm
;textline = $dfd8                
\subs = $e000
;sound = $ea00
\mover = $ee00                  ; see mover.asm
\misc = $f900                   ; see misc.asm
;debugs = $fc00

\*-------------------------------
\*
\*  Jump tables
\*
\*-------------------------------

trobspace = $20
mobspace = $10
maxsfx = $20

IF _TODO
 dum savedgame

SavLevel ds 1
SavStrength ds 1
SavMaxed ds 1
SavTimer ds 2
 ds 1
SavNextMsg ds 1
ENDIF

\dum topctrl
\ jump table moved to topctrl.asm

\dum ctrl
\ jump table moved to ctrl.asm

\dum auto
\ jump table moved to auto.asm

\dum coll
\ jump table moved to coll.asm

\dum gamebg
\ jump table moved to gamebg.asm

\dum specialk
\ jump table moved to specialk.asm

\dum mover
\ jump table moved to mover.asm

\dum ctrlsubs
\ jump table moved to ctrlsubs.asm

\dum subs
\ jump table moved to subs.asm

IF _TODO
 dum sound

playback ds 3
ENDIF

IF _TODO
 dum msys

_minit ds 3
_mplay ds 3
ENDIF

\dum seqtable
\ tables moved to seqtable.asm

\dum misc
\ Moved to misc.asm

IF _TODO
 dum debugs

showpage ds 3
debugkeys ds 3
 ds 3
titlescreen ds 3
ENDIF

\*-------------------------------
\*
\*  Zero page
\*
\*-------------------------------

\ BEEB let assembler assign ZP addresses
\ORG $40

\*-------------------------------
\*
\*  Character data
\*
\*-------------------------------

.Char
.CharPosn skip 1
.CharX skip 1
.CharY skip 1
.CharFace skip 1
.CharBlockX skip 1
.CharBlockY skip 1
.CharAction skip 1
.CharXVel skip 1
.CharYVel skip 1
.CharSeq skip 2
.CharScrn skip 1
.CharRepeat skip 1
.CharID skip 1
.CharSword skip 1
.CharLife skip 1

.Kid
.KidPosn skip 1
.KidX skip 1
.KidY skip 1
.KidFace skip 1
.KidBlockX skip 1
.KidBlockY skip 1
.KidAction skip 1
.KidXVel skip 1
.KidYVel skip 1
.KidSeq skip 2
.KidScrn skip 1
.KidRepeat skip 1
.KidID skip 1
.KidSword skip 1
.KidLife skip 1

.Shad
.ShadPosn skip 1
.ShadX skip 1
.ShadY skip 1
.ShadFace skip 1
.ShadBlockX skip 1
.ShadBlockY skip 1
.ShadAction skip 1
.ShadXVel skip 1
.ShadYVel skip 1
.ShadSeq skip 2
.ShadScrn skip 1
.ShadRepeat skip 1
.ShadID skip 1
.ShadSword skip 1
.ShadLife skip 1

.FCharVars
.FCharImage skip 1
.FCharX skip 2
.FCharY skip 1
.FCharFace skip 1
.FCharIndex skip 1
.FCharCU skip 1
.FCharCD skip 1
.FCharCL skip 1
.FCharCR skip 1
.FCharTable skip 1

\*-------------------------------
\*  $40-e7: Game globals
\*-------------------------------

.framepoint skip 2
.Fimage skip 1
.Fdx skip 1
.Fdy skip 1
.Fcheck skip 1

\*-------------------------------
\*
\*  Misc. data
\*
\*-------------------------------

Fcheckmark = %01000000
Fthinmark = %00100000
Ffootmark = %00011111

floorheight = 15
angle = 7
VertDist = 11

UseFastlay = 0
UseLay = 1
UseLayrsave = 2
UseCharTable = $80

TypeKid = 0
TypeShad = 1
TypeGd = 2
TypeSword = 3
TypeReflect = 4
TypeComix = 5
TypeFF = $80
