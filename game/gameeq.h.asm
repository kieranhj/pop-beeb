; gameeq.h.asm
; Originally GAMEEQ.S
; Contains game definitions and memory addresses

\* gameeq
\*-------------------------------
\*
\*  Equates
\*
\*-------------------------------

\ BEEB DEFINED IN pop-beeb.asm AS SWRAM BANKS
\chtable1 = $6000
\chtable2 = $8400
\chtable3 = $0800
\chtable4 = $9600
\chtable5 = $a800
\chtable6 = $6000
\chtable7 = $9f00

\bgtable1 = $6000
\bgtable2 = $8400

\topctrl = $2000                ; location determined by assembler
seqtable = $2800
seqtab = $3000
\ctrl = $3a00                   ; location determined by assembler
\coll = $4500                   ; location determined by assembler
\gamebg = $4c00                 ; location determined by assembler
\auto = $5400                   ; location determined by assembler

\mobtables = $b600              ; location determined by assembler
savedgame = $b6f0

msys = $d400
\ctrlsubs = $d000               ; location determined by assembler
\specialk = $d900               ; location determined by assembler
textline = $dfd8                ; location determined by assembler
\subs = $e000
sound = $ea00
\mover = $ee00                  ; location determined by assembler
\misc = $f900                   ; location determined by assembler
debugs = $fc00

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

;.yellowflag skip 1
;.timebomb skip 1
;.justblocked skip 1
.gdtimer skip 1
.framepoint skip 2
.Fimage skip 1
.Fdx skip 1
.Fdy skip 1
.Fcheck skip 1
.exitopen skip 1
;.collX skip 1
.lightning skip 1
.lightcolor skip 1
.offguard skip 1
.blockid skip 1
.blockx skip 1
;.blocky skip 1
;.infrontx skip 1
;.behindx skip 1
;.abovey skip 1
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
;.backtolife skip 1
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
;.savekidx skip 1
;.mirrx skip 1
;.dmirr skip 1
;.barrdist skip 1
;.barrcode skip 1
;.imwidth skip 1
;.imheight skip 1
;.leadedge skip 1
;.leftej skip 1
;.rightej skip 1
;.topej skip 1
;.leftblock skip 1
;.rightblock skip 1
;.topblock skip 1
;.bottomblock skip 1
;.CDLeftEj skip 1
;.CDRightEj skip 1
;.endrange skip 1
.bufindex skip 1
;.blockedge skip 1
;.collideL skip 1
;.collideR skip 1
.weightless skip 1
.cutorder skip 1
.AMtimer skip 1
;.begrange skip 1
;.scrn skip 1
;.keybufptr skip 1
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
;.MaxOppStr skip 1
.guardprog skip 1
.ManCtrl skip 1
.mergetimer skip 1
;.lastpotion skip 1
.origstrength skip 1
;.jmpaddr skip 2
.alertguard skip 1
.createshad skip 1
.stunned skip 1
.droppedout skip 1

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

TypeKid = 0
TypeShad = 1
TypeGd = 2
TypeSword = 3
TypeReflect = 4
TypeComix = 5
TypeFF = $80
