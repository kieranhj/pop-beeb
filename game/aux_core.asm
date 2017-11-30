; aux_core.asm
; Entire jump table for Aux (gameplay) code

.aux_core_start

MACRO JUMP_TO function, bank
{
    \\ Preserve A

    STA DLL_REG_A

    \\ Load function address

    LDA #LO(function)
    STA DLL_FUNC_LO
    LDA #HI(function)
    STA DLL_FUNC_HI

    \\ Load bank# and call jump fn

    LDA #bank
    JMP jump_to
}   \\ 3c+2c+3c+2c+3c+2c+3c = 18c + 15b overhead per fn :(
ENDMACRO

.jump_to        ; A=bank, X&Y=fn address
{
    \\ Store bank#
    STA DLL_BANK

    \\ Remember current bank
    LDA &F4: PHA

    \\ Switch to new swram bank
    LDA DLL_BANK
    STA &F4:STA &FE30

    \\ Set function address
    LDA DLL_FUNC_LO
    STA jump_to_addr+1

    LDA DLL_FUNC_HI
    STA jump_to_addr+2

    \\ Restore A before fn call
    LDA DLL_REG_A
}
\\ Call function
.jump_to_addr
    JSR &FFFF
{
    \\ Preserve A
    STA DLL_REG_A

    \\ Restore original bank
    PLA
    STA &F4:STA &FE30

    \\ Restore A before return
    LDA DLL_REG_A

    RTS
}   \\ 3c+3c+3c+3c+3c+4c+3c+4c+3c+4c+3c+6c+3c+4c+3c+4c+3c+6c = 65c!

IF _JMP_TABLE

\*-------------------------------
\* auto.asm
\*-------------------------------

AUTO_BANK = 6

.AutoCtrl JUMP_TO AUTOCTRL, AUTO_BANK
.checkstrike JUMP_TO CHECKSTRIKE, AUTO_BANK
.checkstab JUMP_TO CHECKSTAB, AUTO_BANK
.AutoPlayback JUMP_TO AUTOPLAYBACK, AUTO_BANK
.cutcheck JUMP_TO CUTCHECK, AUTO_BANK

.cutguard JUMP_TO CUTGUARD, AUTO_BANK
.addguard JUMP_TO ADDGUARD, AUTO_BANK
.cut JUMP_TO CUT, AUTO_BANK

\*-------------------------------
\* coll.asm
\*-------------------------------

COLL_BANK = 6

.checkbarr JUMP_TO CHECKBARR, COLL_BANK
.collisions JUMP_TO COLLISIONS, COLL_BANK
.getfwddist JUMP_TO GETFWDDIST, COLL_BANK
.checkcoll JUMP_TO CHECKCOLL, COLL_BANK
.animchar JUMP_TO ANIMCHAR, COLL_BANK

.checkslice JUMP_TO CHECKSLICE, COLL_BANK
.checkslice2 JUMP_TO CHECKSLICE2, COLL_BANK
\ JUMP_TO markmeters ;temp
.checkgate JUMP_TO CHECKGATE, COLL_BANK
\ JUMP_TO firstguard ;temp

.enemycoll JUMP_TO ENEMYCOLL, COLL_BANK

\*-------------------------------
\* ctrl.asm
\*-------------------------------

CTRL_BANK = 7

.PlayerCtrl JUMP_TO PLAYERCTRL, CTRL_BANK
.checkfloor JUMP_TO CHECKFLOOR, CTRL_BANK
.ShadCtrl JUMP_TO SHADCTRL, CTRL_BANK
.rereadblocks JUMP_TO REREADBLOCKS, CTRL_BANK
.checkpress JUMP_TO CHECKPRESS, CTRL_BANK

.DoImpale JUMP_TO DOIMPALE, CTRL_BANK
.GenCtrl JUMP_TO GENCTRL, CTRL_BANK
.checkimpale JUMP_TO CHECKIMPALE, CTRL_BANK

\*-------------------------------
\* ctrlsubs.asm
\*-------------------------------

CTRLSUBS_BANK = 6

.getframe JUMP_TO GETFRAME, CTRLSUBS_BANK
.getseq JUMP_TO GETSEQ, CTRLSUBS_BANK
.getbasex JUMP_TO GETBASEX, CTRLSUBS_BANK
.getblockx JUMP_TO GETBLOCKX, CTRLSUBS_BANK
.getblockxp JUMP_TO GETBLOCKXP, CTRLSUBS_BANK

.getblocky JUMP_TO GETBLOCKY, CTRLSUBS_BANK
.getblockej JUMP_TO GETBLOCKEJ, CTRLSUBS_BANK
.addcharx JUMP_TO ADDCHARX, CTRLSUBS_BANK
.getdist JUMP_TO GETDIST, CTRLSUBS_BANK
.getdist1 JUMP_TO GETDIST1, CTRLSUBS_BANK

.getabovebeh JUMP_TO GETABOVEBEH, CTRLSUBS_BANK
.rdblock JUMP_TO RDBLOCK, CTRLSUBS_BANK
.rdblock1 JUMP_TO RDBLOCK1, CTRLSUBS_BANK
.setupsword JUMP_TO SETUPSWORD, CTRLSUBS_BANK
.getscrns JUMP_TO GETSCRNS, CTRLSUBS_BANK

.addguardobj JUMP_TO ADDGUARDOBJ, CTRLSUBS_BANK
.opjumpseq JUMP_TO OPJUMPSEQ, CTRLSUBS_BANK
.getedges JUMP_TO GETEDGES, CTRLSUBS_BANK
.indexchar JUMP_TO INDEXCHAR, CTRLSUBS_BANK
.quickfg JUMP_TO QUICKFG, CTRLSUBS_BANK

.cropchar JUMP_TO CROPCHAR, CTRLSUBS_BANK
.getleft JUMP_TO GETLEFT, CTRLSUBS_BANK
.getright JUMP_TO GETRIGHT, CTRLSUBS_BANK
.getup JUMP_TO GETUP, CTRLSUBS_BANK
.getdown JUMP_TO GETDOWN, CTRLSUBS_BANK

.cmpspace JUMP_TO CMPSPACE, CTRLSUBS_BANK
.cmpbarr JUMP_TO CMPBARR, CTRLSUBS_BANK
.addkidobj JUMP_TO ADDKIDOBJ, CTRLSUBS_BANK
.addshadobj JUMP_TO ADDSHADOBJ, CTRLSUBS_BANK
.addreflobj JUMP_TO ADDREFLOBJ, CTRLSUBS_BANK

.LoadKid JUMP_TO LOADKID, CTRLSUBS_BANK
.LoadShad JUMP_TO LOADSHAD, CTRLSUBS_BANK
.SaveKid JUMP_TO SAVEKID, CTRLSUBS_BANK
.SaveShad JUMP_TO SAVESHAD, CTRLSUBS_BANK
.setupchar JUMP_TO SETUPCHAR, CTRLSUBS_BANK

.GetFrameInfo JUMP_TO GETFRAMEINFO, CTRLSUBS_BANK
.indexblock JUMP_TO INDEXBLOCK, CTRLSUBS_BANK
.markred JUMP_TO MARKRED, CTRLSUBS_BANK
.markfred JUMP_TO MARKFRED, CTRLSUBS_BANK
.markwipe JUMP_TO MARKWIPE, CTRLSUBS_BANK

.markmove JUMP_TO MARKMOVE, CTRLSUBS_BANK
.markfloor JUMP_TO MARKFLOOR, CTRLSUBS_BANK
.unindex JUMP_TO UNINDEX, CTRLSUBS_BANK
.quickfloor JUMP_TO QUICKFLOOR, CTRLSUBS_BANK
.unevenfloor JUMP_TO UNEVENFLOOR, CTRLSUBS_BANK

.markhalf JUMP_TO MARKHALF, CTRLSUBS_BANK
.addswordobj JUMP_TO ADDSWORDOBJ, CTRLSUBS_BANK
.getblocky1 JUMP_TO GETBLOCKYP, CTRLSUBS_BANK
.checkledge JUMP_TO CHECKLEDGE, CTRLSUBS_BANK
.get2infront JUMP_TO GET2INFRONT, CTRLSUBS_BANK

.checkspikes JUMP_TO CHECKSPIKES, CTRLSUBS_BANK
.rechargemeter JUMP_TO RECHARGEMETER, CTRLSUBS_BANK
.addfcharx JUMP_TO ADDFCHARX, CTRLSUBS_BANK
.facedx JUMP_TO FACEDX, CTRLSUBS_BANK
.jumpseq JUMP_TO JUMPSEQ, CTRLSUBS_BANK

.GetBaseBlock JUMP_TO GETBASEBLOCK, CTRLSUBS_BANK
.LoadKidwOp JUMP_TO LOADKIDWOP, CTRLSUBS_BANK
.SaveKidwOp JUMP_TO SAVEKIDWOP, CTRLSUBS_BANK
.getopdist JUMP_TO GETOPDIST, CTRLSUBS_BANK
.LoadShadwOp JUMP_TO LOADSHADWOP, CTRLSUBS_BANK

.SaveShadwOp JUMP_TO SAVESHADWOP, CTRLSUBS_BANK
.boostmeter JUMP_TO BOOSTMETER, CTRLSUBS_BANK
.getunderft JUMP_TO GETUNDERFT, CTRLSUBS_BANK
.getinfront JUMP_TO GETINFRONT, CTRLSUBS_BANK
.getbehind JUMP_TO GETBEHIND, CTRLSUBS_BANK

.getabove JUMP_TO GETABOVE, CTRLSUBS_BANK
.getaboveinf JUMP_TO GETABOVEINF, CTRLSUBS_BANK
.cmpwall JUMP_TO CMPWALL, CTRLSUBS_BANK

\*-------------------------------
\* frameadv.asm
\*-------------------------------

FRAMEADV_BANK = 7

.sure JUMP_TO SURE, FRAMEADV_BANK
.fast JUMP_TO FAST, FRAMEADV_BANK
.getinitobj JUMP_TO GETINITOBJ, FRAMEADV_BANK

\*-------------------------------
\* gamebg.asm
\*-------------------------------

GAMEBG_BANK = 7

.updatemeters JUMP_TO UPDATEMETERS, GAMEBG_BANK
.DrawKidMeter JUMP_TO DRAWKIDMETER, GAMEBG_BANK
.DrawSword JUMP_TO DRAWSWORD, GAMEBG_BANK
.DrawKid JUMP_TO DRAWKID, GAMEBG_BANK
.DrawShad JUMP_TO DRAWSHAD, GAMEBG_BANK

.setupflame JUMP_TO SETUPFLAME, GAMEBG_BANK
.continuemsg BRK    ; JUMP_TO CONTINUEMSG           BEEB TODO MESSAGES
.addcharobj JUMP_TO ADDCHAROBJ, GAMEBG_BANK
.setobjindx JUMP_TO SETOBJINDX, GAMEBG_BANK
.printlevel BRK     ; JUMP_TO PRINTLEVEL

.DrawOppMeter JUMP_TO DRAWOPPMETER, GAMEBG_BANK
.flipdiskmsg BRK    ; JUMP_TO FLIPDISKMSG
.timeleftmsg BRK    ; JUMP_TO TIMELEFTMSG
.DrawGuard JUMP_TO DRAWGUARD, GAMEBG_BANK
.DrawGuard2 JUMP_TO DRAWGUARD, GAMEBG_BANK

.setupflask JUMP_TO SETUPFLASK, GAMEBG_BANK
.setupcomix JUMP_TO SETUPCOMIX, GAMEBG_BANK
.psetupflame BRK    ; JUMP_TO PSETUPFLAME           BEEB TODO PRINCESS
.drawpost BRK       ; JUMP_TO DRAWPOST
.drawglass BRK      ; JUMP_TO DRAWGLASS

.initlay BRK        ; JUMP_TO INITLAY
.twinkle BRK        ; JUMP_TO TWINKLE
.flow BRK           ; JUMP_TO FLOW
.pmask BRK          ; JUMP_TO PMASK

\*-------------------------------
\* grafix.asm
\*-------------------------------

GRAFIX_BANK = -1        ; currently in Core

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
.vblank jmp beeb_wait_vsync    ;VBLvect jmp VBLANK ;changed by InitVBLANK if IIc
\
.vbli BRK       ;jmp VBLI ;VBL interrupt

\*-------------------------------
\* misc.asm
\*-------------------------------

MISC_BANK = -1      ; currently in Core

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

MOVER_BANK = 7

.animtrans JUMP_TO ANIMTRANS, MOVER_BANK
.trigspikes JUMP_TO TRIGSPIKES, MOVER_BANK
.pushpp JUMP_TO PUSHPP, MOVER_BANK
.breakloose1 JUMP_TO BREAKLOOSE1, MOVER_BANK
.breakloose JUMP_TO BREAKLOOSE, MOVER_BANK

.animmobs JUMP_TO ANIMMOBS, MOVER_BANK
.addmobs JUMP_TO ADDMOBS, MOVER_BANK
.closeexit JUMP_TO CLOSEEXIT, MOVER_BANK
.getspikes JUMP_TO GETSPIKES, MOVER_BANK
.shakem JUMP_TO SHAKEM, MOVER_BANK

.trigslicer JUMP_TO TRIGSLICER, MOVER_BANK
.trigtorch JUMP_TO TRIGTORCH, MOVER_BANK
.getflameflame JUMP_TO GETFLAMEFRAME, MOVER_BANK
.smashmirror JUMP_TO SMASHMIRROR, MOVER_BANK
.jamspikes JUMP_TO JAMSPIKES, MOVER_BANK

.trigflask JUMP_TO TRIGFLASK, MOVER_BANK
.getflaskflame JUMP_TO GETFLASKFRAME, MOVER_BANK
.trigsword JUMP_TO TRIGSWORD, MOVER_BANK
.jampp JUMP_TO JAMPP, MOVER_BANK

\*-------------------------------
\* specialk.asm
\*-------------------------------

SPECIALK_BANK = -1      ; currently in Core

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

SUBS_BANK = 7

.addtorches JUMP_TO ADDTORCHES, SUBS_BANK
.doflashon RTS          ; JUMP_TO DOFLASHON             BEEB TODO FLASH
.PageFlip JMP shadow_swap_buffers           ; JUMP_TO PAGEFLIP
.demo BRK               ; JUMP_TO DEMO
.showtime RTS           ; JUMP_TO SHOWTIME              BEEB TODO TIMER

.doflashoff RTS         ; JUMP_TO DOFLASHOFF            BEEB TODO FLASH
.lrclse RTS             ; JUMP_TO LRCLSE                BEEB TODO FLASH
\ JUMP_TO potioneffect
\ JUMP_TO checkalert
\ JUMP_TO reflection

.addslicers JUMP_TO ADDSLICERS, SUBS_BANK
.pause JUMP_TO PAUSE, SUBS_BANK
\ JUMP_TO bonesrise
.deadenemy JUMP_TO DEADENEMY, SUBS_BANK
IF _ALL_LEVELS
.playcut RTS            ; JUMP_TO PLAYCUT               BEEB TODO CUTSCENE
ELSE
.playcut BRK            ; JUMP_TO PLAYCUT
ENDIF

.addlowersound RTS      ; JUMP_TO ADDLOWERSOUND         BEEB TODO SOUND
.RemoveObj JUMP_TO REMOVEOBJ, SUBS_BANK
.addfall JUMP_TO ADDFALL, SUBS_BANK
.setinitials JUMP_TO SETINITIALS, SUBS_BANK
.startkid JUMP_TO STARTKID, SUBS_BANK

.startkid1 JUMP_TO STARTKID1, SUBS_BANK
.gravity JUMP_TO GRAVITY, SUBS_BANK
.initialguards JUMP_TO INITIALGUARDS, SUBS_BANK
.mirappear JUMP_TO MIRAPPEAR, SUBS_BANK
.crumble JUMP_TO CRUMBLE, SUBS_BANK

ENDIF

.aux_core_end
