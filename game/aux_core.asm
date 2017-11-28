; aux_core.asm
; Entire jump table for Aux (gameplay) code

.aux_core_start

IF _JMP_TABLE

\*-------------------------------
\* auto.asm
\*-------------------------------

.AutoCtrl jmp AUTOCTRL
.checkstrike jmp CHECKSTRIKE
.checkstab jmp CHECKSTAB
.AutoPlayback jmp AUTOPLAYBACK
.cutcheck jmp CUTCHECK

.cutguard jmp CUTGUARD
.addguard jmp ADDGUARD
.cut jmp CUT

\*-------------------------------
\* coll.asm
\*-------------------------------

.checkbarr jmp CHECKBARR
.collisions jmp COLLISIONS
.getfwddist jmp GETFWDDIST
.checkcoll jmp CHECKCOLL
.animchar jmp ANIMCHAR

.checkslice jmp CHECKSLICE
.checkslice2 jmp CHECKSLICE2
\ jmp markmeters ;temp
.checkgate jmp CHECKGATE
\ jmp firstguard ;temp

.enemycoll jmp ENEMYCOLL

\*-------------------------------
\* ctrl.asm
\*-------------------------------

.PlayerCtrl jmp PLAYERCTRL
.checkfloor jmp CHECKFLOOR
.ShadCtrl jmp SHADCTRL
.rereadblocks jmp REREADBLOCKS
.checkpress jmp CHECKPRESS

.DoImpale jmp DOIMPALE
.GenCtrl jmp GENCTRL
.checkimpale jmp CHECKIMPALE

\*-------------------------------
\* ctrlsubs.asm
\*-------------------------------

.getframe jmp GETFRAME
.getseq jmp GETSEQ
.getbasex jmp GETBASEX
.getblockx jmp GETBLOCKX
.getblockxp jmp GETBLOCKXP

.getblocky jmp GETBLOCKY
.getblockej jmp GETBLOCKEJ
.addcharx jmp ADDCHARX
.getdist jmp GETDIST
.getdist1 jmp GETDIST1

.getabovebeh jmp GETABOVEBEH
.rdblock jmp RDBLOCK
.rdblock1 jmp RDBLOCK1
.setupsword jmp SETUPSWORD
.getscrns jmp GETSCRNS

.addguardobj jmp ADDGUARDOBJ
.opjumpseq jmp OPJUMPSEQ
.getedges jmp GETEDGES
.indexchar jmp INDEXCHAR
.quickfg jmp QUICKFG

.cropchar jmp CROPCHAR
.getleft jmp GETLEFT
.getright jmp GETRIGHT
.getup jmp GETUP
.getdown jmp GETDOWN

.cmpspace jmp CMPSPACE
.cmpbarr jmp CMPBARR
.addkidobj jmp ADDKIDOBJ
.addshadobj jmp ADDSHADOBJ
.addreflobj jmp ADDREFLOBJ

.LoadKid jmp LOADKID
.LoadShad jmp LOADSHAD
.SaveKid jmp SAVEKID
.SaveShad jmp SAVESHAD
.setupchar jmp SETUPCHAR

.GetFrameInfo jmp GETFRAMEINFO
.indexblock jmp INDEXBLOCK
.markred jmp MARKRED
.markfred jmp MARKFRED
.markwipe jmp MARKWIPE

.markmove jmp MARKMOVE
.markfloor jmp MARKFLOOR
.unindex jmp UNINDEX
.quickfloor jmp QUICKFLOOR
.unevenfloor jmp UNEVENFLOOR

.markhalf jmp MARKHALF
.addswordobj jmp ADDSWORDOBJ
.getblocky1 jmp GETBLOCKYP
.checkledge jmp CHECKLEDGE
.get2infront jmp GET2INFRONT

.checkspikes jmp CHECKSPIKES
.rechargemeter jmp RECHARGEMETER
.addfcharx jmp ADDFCHARX
.facedx jmp FACEDX
.jumpseq jmp JUMPSEQ

.GetBaseBlock jmp GETBASEBLOCK
.LoadKidwOp jmp LOADKIDWOP
.SaveKidwOp jmp SAVEKIDWOP
.getopdist jmp GETOPDIST
.LoadShadwOp jmp LOADSHADWOP

.SaveShadwOp jmp SAVESHADWOP
.boostmeter jmp BOOSTMETER
.getunderft jmp GETUNDERFT
.getinfront jmp GETINFRONT
.getbehind jmp GETBEHIND

.getabove jmp GETABOVE
.getaboveinf jmp GETABOVEINF
.cmpwall jmp CMPWALL

\*-------------------------------
\* frameadv.asm
\*-------------------------------

.sure jmp SURE
.fast jmp FAST
.getinitobj jmp GETINITOBJ

\*-------------------------------
\* grafix.asm
\*-------------------------------

.gr BRK         ;jmp GR
.drawall jmp DRAWALL
.controller jmp CONTROLLER
\ jmp dispversion
.saveblue BRK   ;jmp SAVEBLUE
\
.reloadblue BRK ;jmp RELOADBLUE
.movemem BRK    ;jmp MOVEMEM
.buttons jmp BUTTONS ;ed
.gtone RTS      ;jmp GTONE          BEEB TODO SOUND
.setcenter RTS  ;jmp SETCENTER      BEEB TODO JOYSTICK
\
.dimchar jmp DIMCHAR
.cvtx jmp CVTX
.zeropeel jmp ZEROPEEL
.zeropeels jmp ZEROPEELS
.pread BRK      ;jmp PREAD          JOYSTICK
\
.addpeel jmp ADDPEEL
.copyscrn RTS   ;jmp COPYSCRN       BEEB TO DO OR NOT NEEDED?
.sngpeel jmp SNGPEEL
.rnd jmp RND
.cls jmp CLS
\
.lay jmp LAY
.fastlay jmp FASTLAY
.layrsave jmp LAYRSAVE
.lrcls RTS      ;jmp LRCLS          BEEB TO DO OR NOT NEEDED?  USED FOR SCREEN FLASH
.fastmask jmp FASTMASK
\
.fastblack jmp FASTBLACK
.peel jmp PEEL
.getwidth jmp GETWIDTH
.copy2000 BRK   ;jmp COPY2000
.copy2000ma BRK ;jmp COPY2000MA

.setfastaux BRK ;jmp SETFASTAUX
.setfastmain BRK;jmp SETFASTMAIN
.loadlevel BRK  ;jmp LOADLEVEL
.attractmode BRK;jmp ATTRACTMODE
.xminit BRK     ;jmp XMINIT

.xmplay BRK     ;jmp XMPLAY
.cutprincess RTS;jmp CUTPRINCESS                BEEB TODO CUTSCENES
.xtitle BRK     ;jmp XTITLE
.copy2000am BRK ;jmp COPY2000AM
.reload BRK     ;jmp RELOAD

.loadstage2 BRK ;jmp LOADSTAGE2
\ jmp RELOAD
.getselect jmp GETSELECT
.getdesel jmp GETDESEL
.edreboot BRK   ;jmp EDREBOOT ;ed
\
.gobuild BRK    ;jmp GOBUILD ;ed
.gogame BRK     ;jmp GOGAME ;ed
.writedir BRK   ;jmp WRITEDIR ;ed
.readdir BRK    ;jmp READDIR ;ed
.svelevel BRK   ;jmp SAVELEVEL ;ed
\
.saavelevelg BRK;jmp SAVELEVELG ;ed
.addback jmp ADDBACK
.addfore jmp ADDFORE
.addmid jmp ADDMID
.addmidez jmp ADDMIDEZ
\
.addwipe jmp ADDWIPE
.addmsg BRK     ;jmp ADDMSG
.savegame BRK   ;jmp SAVEGAME
.loadgame BRK   ;jmp LOADGAME
.zerolsts jmp ZEROLSTS
\
.screendump BRK ;jmp SCREENDUMP
.minit BRK      ;jmp MINIT
.mplay BRK      ;jmp MPLAY
.savebinfo BRK  ;jmp SAVEBINFO
.reloadbinfo BRK;jmp RELOADBINFO
\
.inverty jmp INVERTY
.normspeed RTS  ;jmp NORMSPEED                      NOT BEEB
.addmidezo jmp ADDMIDEZO
.calcblue jmp CALCBLUE
.zerored jmp ZERORED
\
.xplaycut BRK   ;jmp XPLAYCUT
.checkIIGS BRK  ;jmp CHECKIIGS                      NOT BEEB
.fastspeed RTS  ;jmp FASTSPEED                      NOT BEEB
.musickeys BRK  ;jmp MUSICKEYS                      BEEB TODO SOUND
.dostartgame BRK;jmp DOSTARTGAME
\
.epilog BRK     ;jmp EPILOG
.loadaltset BRK ;jmp LOADALTSET
.xmovemusic BRK ;jmp XMOVEMUSIC
.whoop BRK      ;jmp WHOOP
.vblank JMP beeb_wait_vsync    ;VBLvect jmp VBLANK ;changed by InitVBLANK if IIc
\
.vbli BRK       ;jmp VBLI ;VBL interrupt

\*-------------------------------
\* misc.asm
\*-------------------------------

.VanishChar BRK     ; jmp VANISHCHAR
.movemusic BRK      ; jmp MOVEMUSIC
.moveauxlc clc
BRK ; bcc MOVEAUXLC ;relocatable
.firstguard jmp FIRSTGUARD
.markmeters jmp MARKMETERS

.potioneffect jmp POTIONEFFECT
.mouserescue BRK    ; jmp MOUSERESCUE
.StabChar jmp STABCHAR
.unholy jmp UNHOLY
.reflection jmp REFLECTION

.MarkKidMeter jmp MARKKIDMETER
.MarkOppMeter jmp MARKOPPMETER
.bonesrise jmp BONESRISE
.decstr jmp DECSTR
.DoSaveGame BRK     ; jmp DOSAVEGAME                    BEEB TODO SAVEGAME

.LoadLevelX jmp LOADLEVELX
.checkalert jmp CHECKALERT
.dispversion BRK    ; jmp DISPVERSION

\*-------------------------------
\* mover.asm
\*-------------------------------

.animtrans jmp ANIMTRANS
.trigspikes jmp TRIGSPIKES
.pushpp jmp PUSHPP
.breakloose1 jmp BREAKLOOSE1
.breakloose jmp BREAKLOOSE

.animmobs jmp ANIMMOBS
.addmobs jmp ADDMOBS
.closeexit jmp CLOSEEXIT
.getspikes jmp GETSPIKES
.shakem jmp SHAKEM

.trigslicer jmp TRIGSLICER
.trigtorch jmp TRIGTORCH
.getflameflame jmp GETFLAMEFRAME
.smashmirror jmp SMASHMIRROR
.jamspikes jmp JAMSPIKES

.trigflask jmp TRIGFLASK
.getflaskflame jmp GETFLASKFRAME
.trigsword jmp TRIGSWORD
.jampp jmp JAMPP

\*-------------------------------
\* specialk.asm
\*-------------------------------

 .keys jmp KEYS
 .clrjstk jmp CLRJSTK
 .zerosound RTS ;jmp ZEROSOUND          BEEB TODO SOUND
 .addsound RTS  ;jmp ADDSOUND           BEEB TODO SOUND
 .facejstk jmp FACEJSTK

 .SaveSelect jmp SAVESELECT
 .LoadSelect jmp LOADSELECT
 .SaveDesel jmp SAVEDESEL
 .LoadDesel jmp LOADDESEL
 .initinput jmp INITINPUT

 .demokeys jmp DEMOKEYS
 .listtorches BRK ;jmp LISTTORCHES
 .burn BRK        ;jmp BURN
 .getminleft BRK  ;jmp GETMINLEFT
 .keeptime RTS    ;jmp KEEPTIME         BEEB TODO TIMER

 .shortentime BRK ;jmp SHORTENTIME
 .cuesong RTS     ;jmp CUESONG          BEEB TODO MUSIC
 \jmp DoSaveGame
 \jmp LoadLevelX
 \jmp decstr

 .dloop BRK       ;jmp DLOOP
 .strobe jmp STROBE

\*-------------------------------
\* subs.asm
\*-------------------------------

.addtorches jmp ADDTORCHES
.doflashon RTS          ; jmp DOFLASHON             BEEB TODO FLASH
.PageFlip jmp shadow_swap_buffers           ; jmp PAGEFLIP
.demo BRK               ; jmp DEMO
.showtime RTS           ; jmp SHOWTIME              BEEB TODO TIMER

.doflashoff RTS         ; jmp DOFLASHOFF            BEEB TODO FLASH
.lrclse RTS             ; jmp LRCLSE                BEEB TODO FLASH
\ jmp potioneffect
\ jmp checkalert
\ jmp reflection

.addslicers jmp ADDSLICERS
.pause jmp PAUSE
\ jmp bonesrise
.deadenemy jmp DEADENEMY
IF _ALL_LEVELS
.playcut RTS            ; jmp PLAYCUT               BEEB TODO CUTSCENE
ELSE
.playcut BRK            ; jmp PLAYCUT
ENDIF

.addlowersound RTS      ; jmp ADDLOWERSOUND         BEEB TODO SOUND
.RemoveObj jmp REMOVEOBJ
.addfall jmp ADDFALL
.setinitials jmp SETINITIALS
.startkid jmp STARTKID

.startkid1 jmp STARTKID1
.gravity jmp GRAVITY
.initialguards jmp INITIALGUARDS
.mirappear jmp MIRAPPEAR
.crumble jmp CRUMBLE

ENDIF

.aux_core_end
