; aux_core.asm
; Entire jump table for Aux (gameplay) code

.aux_core_start

MACRO JUMP_A name, base, index
{
    \\ Preserve A

    STX DLL_REG_X

    \\ Load function index

    LDX #(base + index)

    \\ Call jump function

    JMP jump_to_A
}   \\ 3c+2c+3c = 8c + 7b overhead per fn
ENDMACRO

.jump_to_A
{
    STA DLL_REG_A

    \\ Remember current bank
    LDA &F4: PHA

    LDA #6          ; hard code this aux A = 6
    STA &F4: STA &FE30

    LDA aux_core_fn_table_A_LO, X
    STA jump_to_addr_A + 1

    LDA aux_core_fn_table_A_HI, X

IF _DEBUG
    BMI fn_ok   ; can only jump into upper half of RAM!
    BRK         ; X=fn index that isn't implemented
    .fn_ok
ENDIF

    STA jump_to_addr_A + 2

    \\ Restore A before fn call
    LDX DLL_REG_X
    LDA DLL_REG_A
}
\\ Call function
.jump_to_addr_A
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
}   \\ 3c+3c+3c+2c+3c+4c+4c+4c+4c+4c+3c+3c+6c+3c+4c+3c+4c+3c+6c = 69c


MACRO JUMP_B name, base, index
{
    \\ Preserve A

    STX DLL_REG_X

    \\ Load function index

    LDX #(base + index)

    \\ Call jump function

    JMP jump_to_B
}   \\ 3c+2c+3c = 8c + 7b overhead per fn
ENDMACRO

.jump_to_B
{
    STA DLL_REG_A

    \\ Remember current bank
    LDA &F4: PHA

    LDA #7          ; hard code this aux B = 7
    STA &F4: STA &FE30

    LDA aux_core_fn_table_B_LO, X
    STA jump_to_addr_B + 1

    LDA aux_core_fn_table_B_HI, X

IF _DEBUG
    BMI fn_ok   ; can only jump into upper half of RAM!
    BRK         ; X=fn index that isn't implemented
    .fn_ok
ENDIF

    STA jump_to_addr_B + 2

    \\ Restore A before fn call
    LDX DLL_REG_X
    LDA DLL_REG_A
}
\\ Call function
.jump_to_addr_B
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
}   \\ 3c+3c+3c+2c+3c+4c+4c+4c+4c+4c+3c+3c+6c+3c+4c+3c+4c+3c+6c = 69c


IF _JMP_TABLE
\*-------------------------------
\* auto.asm
\*-------------------------------

.AutoCtrl JUMP_A AUTOCTRL, AUTO_BASE, 0
.checkstrike JUMP_A CHECKSTRIKE, AUTO_BASE, 1
.checkstab JUMP_A CHECKSTAB, AUTO_BASE, 2
.AutoPlayback JUMP_A AUTOPLAYBACK, AUTO_BASE, 3
.cutcheck JUMP_A CUTCHECK, AUTO_BASE, 4

.cutguard JUMP_A CUTGUARD, AUTO_BASE, 5
.addguard JUMP_A ADDGUARD, AUTO_BASE, 6
.cut JUMP_A CUT, AUTO_BASE, 7
.demo JUMP_A DEMO, AUTO_BASE, 8             \\ moved from subs.asm


\*-------------------------------
\* coll.asm
\*-------------------------------

.checkbarr JUMP_A CHECKBARR, COLL_BASE, 0
.collisions JUMP_A COLLISIONS, COLL_BASE, 1
.getfwddist JUMP_A GETFWDDIST, COLL_BASE, 2
.checkcoll JUMP_A CHECKCOLL, COLL_BASE, 3
.animchar JUMP_A ANIMCHAR, COLL_BASE, 4

.checkslice JUMP_A CHECKSLICE, COLL_BASE, 5
.checkslice2 JUMP_A CHECKSLICE2, COLL_BASE, 6
\ JUMP_A markmeters ;temp
.checkgate JUMP_A CHECKGATE, COLL_BASE, 7
\ JUMP_A firstguard ;temp

.enemycoll JUMP_A ENEMYCOLL, COLL_BASE, 8


\*-------------------------------
\* ctrl.asm
\*-------------------------------

.PlayerCtrl JUMP_B PLAYERCTRL, CTRL_BASE, 0
.checkfloor JUMP_B CHECKFLOOR, CTRL_BASE, 1
.ShadCtrl JUMP_B SHADCTRL, CTRL_BASE, 2
.rereadblocks JUMP_B REREADBLOCKS, CTRL_BASE, 3
.checkpress JUMP_B CHECKPRESS, CTRL_BASE, 4

.DoImpale JUMP_B DOIMPALE, CTRL_BASE, 5
.GenCtrl JUMP_B GENCTRL, CTRL_BASE, 6
.checkimpale JUMP_B CHECKIMPALE, CTRL_BASE, 7


\*-------------------------------
\* ctrlsubs.asm
\*-------------------------------

.getframe JUMP_A GETFRAME, CTRLSUBS_BASE, 0
.getseq JUMP_A GETSEQ, CTRLSUBS_BASE, 1
.getbasex JUMP_A GETBASEX, CTRLSUBS_BASE, 2
.getblockx JUMP_A GETBLOCKX, CTRLSUBS_BASE, 3
.getblockxp JUMP_A GETBLOCKXP, CTRLSUBS_BASE, 4

.getblocky JUMP_A GETBLOCKY, CTRLSUBS_BASE, 5
.getblockej JUMP_A GETBLOCKEJ, CTRLSUBS_BASE, 6
.addcharx JUMP_A ADDCHARX, CTRLSUBS_BASE, 7
.getdist JUMP_A GETDIST, CTRLSUBS_BASE, 8
.getdist1 JUMP_A GETDIST1, CTRLSUBS_BASE, 9

.getabovebeh JUMP_A GETABOVEBEH, CTRLSUBS_BASE, 10
.rdblock JUMP_A RDBLOCK, CTRLSUBS_BASE, 11
.rdblock1 JUMP_A RDBLOCK1, CTRLSUBS_BASE, 12
.setupsword JUMP_A SETUPSWORD, CTRLSUBS_BASE, 13
.getscrns JUMP_A GETSCRNS, CTRLSUBS_BASE, 14

.addguardobj JUMP_A ADDGUARDOBJ, CTRLSUBS_BASE, 15
.opjumpseq JUMP_A OPJUMPSEQ, CTRLSUBS_BASE, 16
.getedges JUMP_A GETEDGES, CTRLSUBS_BASE, 17
.indexchar JUMP_A INDEXCHAR, CTRLSUBS_BASE, 18
.quickfg JUMP_A QUICKFG, CTRLSUBS_BASE, 19

.cropchar JUMP_A CROPCHAR, CTRLSUBS_BASE, 20
.getleft JUMP_A GETLEFT, CTRLSUBS_BASE, 21
.getright JUMP_A GETRIGHT, CTRLSUBS_BASE, 22
.getup JUMP_A GETUP, CTRLSUBS_BASE, 23
.getdown JUMP_A GETDOWN, CTRLSUBS_BASE, 24

.cmpspace JUMP_A CMPSPACE, CTRLSUBS_BASE, 25
.cmpbarr JUMP_A CMPBARR, CTRLSUBS_BASE, 26
.addkidobj JUMP_A ADDKIDOBJ, CTRLSUBS_BASE, 27
.addshadobj JUMP_A ADDSHADOBJ, CTRLSUBS_BASE, 28
.addreflobj JUMP_A ADDREFLOBJ, CTRLSUBS_BASE, 29

.LoadKid JUMP_A LOADKID, CTRLSUBS_BASE, 30
.LoadShad JUMP_A LOADSHAD, CTRLSUBS_BASE, 31
.SaveKid JUMP_A SAVEKID, CTRLSUBS_BASE, 32
.SaveShad JUMP_A SAVESHAD, CTRLSUBS_BASE, 33
.setupchar JUMP_A SETUPCHAR, CTRLSUBS_BASE, 34

.GetFrameInfo JUMP_A GETFRAMEINFO, CTRLSUBS_BASE, 35
.indexblock JUMP_A INDEXBLOCK, CTRLSUBS_BASE, 36
.markred JUMP_A MARKRED, CTRLSUBS_BASE, 37
.markfred JUMP_A MARKFRED, CTRLSUBS_BASE, 38
.markwipe JUMP_A MARKWIPE, CTRLSUBS_BASE, 39

.markmove JUMP_A MARKMOVE, CTRLSUBS_BASE, 40
.markfloor JUMP_A MARKFLOOR, CTRLSUBS_BASE, 41
.unindex JUMP_A UNINDEX, CTRLSUBS_BASE, 42
.quickfloor JUMP_A QUICKFLOOR, CTRLSUBS_BASE, 43
.unevenfloor JUMP_A UNEVENFLOOR, CTRLSUBS_BASE, 44

.markhalf JUMP_A MARKHALF, CTRLSUBS_BASE, 45
.addswordobj JUMP_A ADDSWORDOBJ, CTRLSUBS_BASE, 46
.getblocky1 JUMP_A GETBLOCKYP, CTRLSUBS_BASE, 47
.checkledge JUMP_A CHECKLEDGE, CTRLSUBS_BASE, 48
.get2infront JUMP_A GET2INFRONT, CTRLSUBS_BASE, 49

.checkspikes JUMP_A CHECKSPIKES, CTRLSUBS_BASE, 50
.rechargemeter JUMP_A RECHARGEMETER, CTRLSUBS_BASE, 51
.addfcharx JUMP_A ADDFCHARX, CTRLSUBS_BASE, 52
.facedx JUMP_A FACEDX, CTRLSUBS_BASE, 53
.jumpseq JUMP_A JUMPSEQ, CTRLSUBS_BASE, 54

.GetBaseBlock JUMP_A GETBASEBLOCK, CTRLSUBS_BASE, 55
.LoadKidwOp JUMP_A LOADKIDWOP, CTRLSUBS_BASE, 56
.SaveKidwOp JUMP_A SAVEKIDWOP, CTRLSUBS_BASE, 57
.getopdist JUMP_A GETOPDIST, CTRLSUBS_BASE, 58
.LoadShadwOp JUMP_A LOADSHADWOP, CTRLSUBS_BASE, 59

.SaveShadwOp JUMP_A SAVESHADWOP, CTRLSUBS_BASE, 60
.boostmeter JUMP_A BOOSTMETER, CTRLSUBS_BASE, 61
.getunderft JUMP_A GETUNDERFT, CTRLSUBS_BASE, 62
.getinfront JUMP_A GETINFRONT, CTRLSUBS_BASE, 63
.getbehind JUMP_A GETBEHIND, CTRLSUBS_BASE, 64

.getabove JUMP_A GETABOVE, CTRLSUBS_BASE, 65
.getaboveinf JUMP_A GETABOVEINF, CTRLSUBS_BASE, 66
.cmpwall JUMP_A CMPWALL, CTRLSUBS_BASE, 67


\*-------------------------------
\* frameadv.asm
\*-------------------------------

.sure JUMP_B SURE, FRAMEADV_BASE, 0
.fast JUMP_B FAST, FRAMEADV_BASE, 1
.getinitobj JUMP_B GETINITOBJ, FRAMEADV_BASE, 2
.calcblue JUMP_B CALCBLUE, FRAMEADV_BASE, 3
.zerored JUMP_B ZERORED, FRAMEADV_BASE, 4

\*-------------------------------
\* gamebg.asm
\*-------------------------------

.updatemeters JUMP_B UPDATEMETERS, GAMEBG_BASE, 0
.DrawKidMeter JUMP_B DRAWKIDMETER, GAMEBG_BASE, 1
.DrawSword JUMP_B DRAWSWORD, GAMEBG_BASE, 2
.DrawKid JUMP_B DRAWKID, GAMEBG_BASE, 3
.DrawShad JUMP_B DRAWSHAD, GAMEBG_BASE, 4

.setupflame JUMP_B SETUPFLAME, GAMEBG_BASE, 5
.continuemsg RTS    ; JUMP_B CONTINUEMSG            BEEB TODO MESSAGES
.addcharobj JUMP_B ADDCHAROBJ, GAMEBG_BASE, 7
.setobjindx JUMP_B SETOBJINDX, GAMEBG_BASE, 8
.printlevel RTS     ; JUMP_B PRINTLEVEL             BEEB TODO MESSAGES

.DrawOppMeter JUMP_B DRAWOPPMETER, GAMEBG_BASE, 10
.flipdiskmsg BRK    ; JUMP_B FLIPDISKMSG            NOT BEEB
.timeleftmsg RTS    ; JUMP_B TIMELEFTMSG            BEEB TODO MESSAGES
.DrawGuard JUMP_B DRAWGUARD, GAMEBG_BASE, 13
.DrawGuard2 JUMP_B DRAWGUARD, GAMEBG_BASE, 14

.setupflask JUMP_B SETUPFLASK, GAMEBG_BASE, 15
.setupcomix JUMP_B SETUPCOMIX, GAMEBG_BASE, 16
.psetupflame JUMP_B PSETUPFLAME, GAMEBG_BASE, 17
.drawpost JUMP_B DRAWPOST, GAMEBG_BASE, 18
.drawglass JUMP_B DRAWGLASS, GAMEBG_BASE, 19

.initlay JUMP_B INITLAY, GAMEBG_BASE, 20
.twinkle RTS        ; JUMP_B TWINKLE               BEEB TODO GFX
.flow JUMP_B FLOW, GAMEBG_BASE, 22
.pmask RTS          ; JUMP_B PMASK                 BEEB TODO GFX


\*-------------------------------
\* grafix.asm
\*-------------------------------

GRAFIX_BANK = -1        ; currently in Core

.drawall jmp DRAWALL
;
\ jmp dispversion
\.saveblue BRK   ;jmp SAVEBLUE          ; Editor only
\
\.reloadblue BRK ;jmp RELOADBLUE        ; Editor only
.movemem BRK    ;jmp MOVEMEM
\.buttons jmp BUTTONS ;ed
;
;
\
.dimchar jmp DIMCHAR
.cvtx jmp CVTX
.zeropeel jmp ZEROPEEL
.zeropeels jmp ZEROPEELS
;
\
.addpeel jmp ADDPEEL
.copyscrn RTS   ;jmp COPYSCRN       BEEB TO DO OR NOT NEEDED?
.sngpeel jmp SNGPEEL
.rnd jmp RND
;
\ Removed unnecessary redirections
\ Removed Editor only fns
;
.addback jmp ADDBACK
.addfore jmp ADDFORE
.addmid jmp ADDMID
.addmidez jmp ADDMIDEZ
\
.addwipe jmp ADDWIPE
.addmsg jmp ADDMSG
;
;
.zerolsts jmp ZEROLSTS
\
;
;
;
\.savebinfo BRK  ;jmp SAVEBINFO         ; Editor only
\.reloadbinfo BRK;jmp RELOADBINFO       ; Editor only
\
;
\.normspeed RTS  ;jmp NORMSPEED         ; NOT BEEB
.addmidezo jmp ADDMIDEZO
;
;
\
;
\.checkIIGS BRK  ;jmp CHECKIIGS         ; NOT BEEB
\.fastspeed RTS  ;jmp FASTSPEED         ; NOT BEEB
;
;
\
;
;
;
;
.vblank jmp beeb_wait_vsync    ;VBLvect jmp VBLANK ;changed by InitVBLANK if IIc
\
.vbli BRK       ;jmp VBLI ;VBL interrupt


\*-------------------------------
\* audio.asm
\*-------------------------------

.gtone RTS      ;jmp GTONE          BEEB TODO SOUND
.minit jmp MINIT
.mplay jmp MPLAY
.whoop BRK      ;jmp WHOOP


\*-------------------------------
\* misc.asm
\*-------------------------------

.VanishChar JUMP_B VANISHCHAR, MISC_BASE, 0
.movemusic BRK      ; jmp MOVEMUSIC
.moveauxlc clc
BRK ; bcc MOVEAUXLC ;relocatable
.firstguard JUMP_B FIRSTGUARD, MISC_BASE, 3
.markmeters JUMP_B MARKMETERS, MISC_BASE, 4

.potioneffect JUMP_B POTIONEFFECT, MISC_BASE, 5
.mouserescue JUMP_B MOUSERESCUE, MISC_BASE, 6
.StabChar JUMP_B STABCHAR, MISC_BASE, 7
.unholy JUMP_B UNHOLY, MISC_BASE, 8
.reflection JUMP_B REFLECTION, MISC_BASE, 9

.MarkKidMeter JUMP_B MARKKIDMETER, MISC_BASE, 10
.MarkOppMeter JUMP_B MARKOPPMETER, MISC_BASE, 11
.bonesrise JUMP_B BONESRISE, MISC_BASE, 12
.decstr JUMP_B DECSTR, MISC_BASE, 13
.DoSaveGame BRK     ; jmp DOSAVEGAME           BEEB TODO SAVEGAME

\.LoadLevelX jmp LOADLEVELX             ; moved to master.asm
.checkalert JUMP_B CHECKALERT, MISC_BASE, 15
.dispversion BRK    ; jmp DISPVERSION


\*-------------------------------
\* mover.asm
\*-------------------------------

.animtrans JUMP_B ANIMTRANS, MOVER_BASE, 0
.trigspikes JUMP_B TRIGSPIKES, MOVER_BASE, 1
.pushpp JUMP_B PUSHPP, MOVER_BASE, 2
.breakloose1 JUMP_B BREAKLOOSE1, MOVER_BASE, 3
.breakloose JUMP_B BREAKLOOSE, MOVER_BASE, 4

.animmobs JUMP_B ANIMMOBS, MOVER_BASE, 5
.addmobs JUMP_B ADDMOBS, MOVER_BASE, 6
.closeexit JUMP_B CLOSEEXIT, MOVER_BASE, 7
.getspikes JUMP_B GETSPIKES, MOVER_BASE, 8
.shakem JUMP_B SHAKEM, MOVER_BASE, 9

.trigslicer JUMP_B TRIGSLICER, MOVER_BASE, 10
.trigtorch JUMP_B TRIGTORCH, MOVER_BASE, 11
.getflameframe JUMP_B GETFLAMEFRAME, MOVER_BASE, 12
.smashmirror JUMP_B SMASHMIRROR, MOVER_BASE, 13
.jamspikes JUMP_B JAMSPIKES, MOVER_BASE, 14

.trigflask JUMP_B TRIGFLASK, MOVER_BASE, 15
.getflaskflame JUMP_B GETFLASKFRAME, MOVER_BASE, 16
.trigsword JUMP_B TRIGSWORD, MOVER_BASE, 17
.jampp JUMP_B JAMPP, MOVER_BASE, 18


\*-------------------------------
\* specialk.asm
\*-------------------------------

.keys JUMP_B KEYS, SPECIALK_BASE, 0
.clrjstk JUMP_B CLRJSTK, SPECIALK_BASE, 1
.zerosound RTS ;jmp ZEROSOUND          BEEB TODO SOUND
.addsound RTS  ;jmp ADDSOUND           BEEB TODO SOUND
.facejstk JUMP_B FACEJSTK, SPECIALK_BASE, 4

.SaveSelect JUMP_B SAVESELECT, SPECIALK_BASE, 5
.LoadSelect JUMP_B LOADSELECT, SPECIALK_BASE, 6
.SaveDesel JUMP_B SAVEDESEL, SPECIALK_BASE, 7
.LoadDesel JUMP_B LOADDESEL, SPECIALK_BASE, 8
.initinput JUMP_B INITINPUT, SPECIALK_BASE, 9

.demokeys JUMP_B DEMOKEYS, SPECIALK_BASE, 10
.listtorches BRK ;jmp LISTTORCHES
.burn BRK        ;jmp BURN
.getminleft JUMP_B GETMINLEFT, SPECIALK_BASE, 13
.keeptime JUMP_B KEEPTIME, SPECIALK_BASE, 14

.shortentime BRK ;jmp SHORTENTIME
.cuesong RTS     ;jmp CUESONG          BEEB TODO MUSIC
\jmp DoSaveGame
\jmp LoadLevelX
\jmp decstr

.dloop BRK       ;jmp DLOOP
.strobe JUMP_B STROBE, SPECIALK_BASE, 18
.controller JUMP_B CONTROLLER, SPECIALK_BASE, 19

.setcenter RTS  ;jmp SETCENTER      BEEB TODO JOYSTICK
.pread BRK      ;jmp PREAD          JOYSTICK
.getselect JUMP_B GETSELECT, SPECIALK_BASE, 22
.getdesel JUMP_B GETDESEL, SPECIALK_BASE, 23
.musickeys JUMP_B MUSICKEYS, SPECIALK_BASE, 24


\*-------------------------------
\* subs.asm
\*-------------------------------

.addtorches JUMP_B ADDTORCHES, SUBS_BASE, 0
.doflashon RTS          ; JUMP_B DOFLASHON             BEEB TODO FLASH
.PageFlip JMP shadow_swap_buffers           ; JUMP_B PAGEFLIP
.subs_demo BRK          ; JUMP_B DEMO, SUBS_BASE, 3   \\ moved to auto.asm
.showtime JUMP_B SHOWTIME, SUBS_BASE, 4

.doflashoff RTS         ; JUMP_B DOFLASHOFF            BEEB TODO FLASH
.lrclse RTS             ; JUMP_B LRCLSE                BEEB TODO FLASH
\ JUMP_B potioneffect
\ JUMP_B checkalert
\ JUMP_B reflection

.addslicers JUMP_B ADDSLICERS, SUBS_BASE, 7
.pause JUMP_B PAUSE, SUBS_BASE, 8
\ JUMP_B bonesrise
.deadenemy JUMP_B DEADENEMY, SUBS_BASE, 9
.playcut JUMP_B PLAYCUT, SUBS_BASE, 10

.addlowersound RTS      ; JUMP_B ADDLOWERSOUND         BEEB TODO SOUND
.RemoveObj JUMP_B REMOVEOBJ, SUBS_BASE, 12
.addfall JUMP_B ADDFALL, SUBS_BASE, 13
.setinitials JUMP_B SETINITIALS, SUBS_BASE, 14
.startkid JUMP_B STARTKID, SUBS_BASE, 15

.startkid1 JUMP_B STARTKID1, SUBS_BASE, 16
.gravity JUMP_B GRAVITY, SUBS_BASE, 17
.initialguards JUMP_B INITIALGUARDS, SUBS_BASE, 18
.mirappear JUMP_B MIRAPPEAR, SUBS_BASE, 19
.crumble JUMP_B CRUMBLE, SUBS_BASE, 20


\*-------------------------------
\* FUNCTION addresses for AUX A
\*-------------------------------

.aux_core_fn_table_A_LO

\*-------------------------------
\* auto.asm
\*-------------------------------
AUTO_BASE = P%-aux_core_fn_table_A_LO
EQUB LO(AUTOCTRL)
EQUB LO(CHECKSTRIKE)
EQUB LO(CHECKSTAB)
EQUB LO(AUTOPLAYBACK)
EQUB LO(CUTCHECK)

EQUB LO(CUTGUARD)
EQUB LO(ADDGUARD)
EQUB LO(CUT)
EQUB LO(DEMO)

\*-------------------------------
\* coll.asm
\*-------------------------------
COLL_BASE = P%-aux_core_fn_table_A_LO
EQUB LO(CHECKBARR)
EQUB LO(COLLISIONS)
EQUB LO(GETFWDDIST)
EQUB LO(CHECKCOLL)
EQUB LO(ANIMCHAR)

EQUB LO(CHECKSLICE)
EQUB LO(CHECKSLICE2)
\ JUMP_TO markmeters ;temp
EQUB LO(CHECKGATE)
\ JUMP_TO firstguard ;temp

EQUB LO(ENEMYCOLL)

\*-------------------------------
\* ctrlsubs.asm
\*-------------------------------
CTRLSUBS_BASE = P%-aux_core_fn_table_A_LO
EQUB LO(GETFRAME)
EQUB LO(GETSEQ)
EQUB LO(GETBASEX)
EQUB LO(GETBLOCKX)
EQUB LO(GETBLOCKXP)

EQUB LO(GETBLOCKY)
EQUB LO(GETBLOCKEJ)
EQUB LO(ADDCHARX)
EQUB LO(GETDIST)
EQUB LO(GETDIST1)

EQUB LO(GETABOVEBEH)
EQUB LO(RDBLOCK)
EQUB LO(RDBLOCK1)
EQUB LO(SETUPSWORD)
EQUB LO(GETSCRNS)

EQUB LO(ADDGUARDOBJ)
EQUB LO(OPJUMPSEQ)
EQUB LO(GETEDGES)
EQUB LO(INDEXCHAR)
EQUB LO(QUICKFG)

EQUB LO(CROPCHAR)
EQUB LO(GETLEFT)
EQUB LO(GETRIGHT)
EQUB LO(GETUP)
EQUB LO(GETDOWN)

EQUB LO(CMPSPACE)
EQUB LO(CMPBARR)
EQUB LO(ADDKIDOBJ)
EQUB LO(ADDSHADOBJ)
EQUB LO(ADDREFLOBJ)

EQUB LO(LOADKID)
EQUB LO(LOADSHAD)
EQUB LO(SAVEKID)
EQUB LO(SAVESHAD)
EQUB LO(SETUPCHAR)

EQUB LO(GETFRAMEINFO)
EQUB LO(INDEXBLOCK)
EQUB LO(MARKRED)
EQUB LO(MARKFRED)
EQUB LO(MARKWIPE)

EQUB LO(MARKMOVE)
EQUB LO(MARKFLOOR)
EQUB LO(UNINDEX)
EQUB LO(QUICKFLOOR)
EQUB LO(UNEVENFLOOR)

EQUB LO(MARKHALF)
EQUB LO(ADDSWORDOBJ)
EQUB LO(GETBLOCKYP)
EQUB LO(CHECKLEDGE)
EQUB LO(GET2INFRONT)

EQUB LO(CHECKSPIKES)
EQUB LO(RECHARGEMETER)
EQUB LO(ADDFCHARX)
EQUB LO(FACEDX)
EQUB LO(JUMPSEQ)

EQUB LO(GETBASEBLOCK)
EQUB LO(LOADKIDWOP)
EQUB LO(SAVEKIDWOP)
EQUB LO(GETOPDIST)
EQUB LO(LOADSHADWOP)

EQUB LO(SAVESHADWOP)
EQUB LO(BOOSTMETER)
EQUB LO(GETUNDERFT)
EQUB LO(GETINFRONT)
EQUB LO(GETBEHIND)

EQUB LO(GETABOVE)
EQUB LO(GETABOVEINF)
EQUB LO(CMPWALL)

.aux_core_fn_table_A_HI
\*-------------------------------
\* auto.asm
\*-------------------------------
EQUB HI(AUTOCTRL)
EQUB HI(CHECKSTRIKE)
EQUB HI(CHECKSTAB)
EQUB HI(AUTOPLAYBACK)
EQUB HI(CUTCHECK)

EQUB HI(CUTGUARD)
EQUB HI(ADDGUARD)
EQUB HI(CUT)
EQUB HI(DEMO)

\*-------------------------------
\* coll.asm
\*-------------------------------
EQUB HI(CHECKBARR)
EQUB HI(COLLISIONS)
EQUB HI(GETFWDDIST)
EQUB HI(CHECKCOLL)
EQUB HI(ANIMCHAR)

EQUB HI(CHECKSLICE)
EQUB HI(CHECKSLICE2)
\ JUMP_TO markmeters ;temp
EQUB HI(CHECKGATE)
\ JUMP_TO firstguard ;temp

EQUB HI(ENEMYCOLL)

\*-------------------------------
\* ctrlsubs.asm
\*-------------------------------
EQUB HI(GETFRAME)
EQUB HI(GETSEQ)
EQUB HI(GETBASEX)
EQUB HI(GETBLOCKX)
EQUB HI(GETBLOCKXP)

EQUB HI(GETBLOCKY)
EQUB HI(GETBLOCKEJ)
EQUB HI(ADDCHARX)
EQUB HI(GETDIST)
EQUB HI(GETDIST1)

EQUB HI(GETABOVEBEH)
EQUB HI(RDBLOCK)
EQUB HI(RDBLOCK1)
EQUB HI(SETUPSWORD)
EQUB HI(GETSCRNS)

EQUB HI(ADDGUARDOBJ)
EQUB HI(OPJUMPSEQ)
EQUB HI(GETEDGES)
EQUB HI(INDEXCHAR)
EQUB HI(QUICKFG)

EQUB HI(CROPCHAR)
EQUB HI(GETLEFT)
EQUB HI(GETRIGHT)
EQUB HI(GETUP)
EQUB HI(GETDOWN)

EQUB HI(CMPSPACE)
EQUB HI(CMPBARR)
EQUB HI(ADDKIDOBJ)
EQUB HI(ADDSHADOBJ)
EQUB HI(ADDREFLOBJ)

EQUB HI(LOADKID)
EQUB HI(LOADSHAD)
EQUB HI(SAVEKID)
EQUB HI(SAVESHAD)
EQUB HI(SETUPCHAR)

EQUB HI(GETFRAMEINFO)
EQUB HI(INDEXBLOCK)
EQUB HI(MARKRED)
EQUB HI(MARKFRED)
EQUB HI(MARKWIPE)

EQUB HI(MARKMOVE)
EQUB HI(MARKFLOOR)
EQUB HI(UNINDEX)
EQUB HI(QUICKFLOOR)
EQUB HI(UNEVENFLOOR)

EQUB HI(MARKHALF)
EQUB HI(ADDSWORDOBJ)
EQUB HI(GETBLOCKYP)
EQUB HI(CHECKLEDGE)
EQUB HI(GET2INFRONT)

EQUB HI(CHECKSPIKES)
EQUB HI(RECHARGEMETER)
EQUB HI(ADDFCHARX)
EQUB HI(FACEDX)
EQUB HI(JUMPSEQ)

EQUB HI(GETBASEBLOCK)
EQUB HI(LOADKIDWOP)
EQUB HI(SAVEKIDWOP)
EQUB HI(GETOPDIST)
EQUB HI(LOADSHADWOP)

EQUB HI(SAVESHADWOP)
EQUB HI(BOOSTMETER)
EQUB HI(GETUNDERFT)
EQUB HI(GETINFRONT)
EQUB HI(GETBEHIND)

EQUB HI(GETABOVE)
EQUB HI(GETABOVEINF)
EQUB HI(CMPWALL)

\*-------------------------------
\* FUNCTION addresses for AUX B
\*-------------------------------

.aux_core_fn_table_B_LO

\*-------------------------------
\* ctrl.asm
\*-------------------------------
CTRL_BASE = P% - aux_core_fn_table_B_LO
EQUB LO(PLAYERCTRL)
EQUB LO(CHECKFLOOR)
EQUB LO(SHADCTRL)
EQUB LO(REREADBLOCKS)
EQUB LO(CHECKPRESS)

EQUB LO(DOIMPALE)
EQUB LO(GENCTRL)
EQUB LO(CHECKIMPALE)

\*-------------------------------
\* frameadv.asm
\*-------------------------------
FRAMEADV_BASE = P% - aux_core_fn_table_B_LO
EQUB LO(SURE)
EQUB LO(FAST)
EQUB LO(GETINITOBJ)
EQUB LO(CALCBLUE)
EQUB LO(ZERORED)

\*-------------------------------
\* gamebg.asm
\*-------------------------------
GAMEBG_BASE = P% - aux_core_fn_table_B_LO
EQUB LO(UPDATEMETERS)
EQUB LO(DRAWKIDMETER)
EQUB LO(DRAWSWORD)
EQUB LO(DRAWKID)
EQUB LO(DRAWSHAD)

EQUB LO(SETUPFLAME)
EQUB 0    ; EQUB LO(CONTINUEMSG)           BEEB TODO MESSAGES
EQUB LO(ADDCHAROBJ)
EQUB LO(SETOBJINDX)
EQUB 0    ; EQUB LO(PRINTLEVEL)

EQUB LO(DRAWOPPMETER)
EQUB 0    ; EQUB LO(FLIPDISKMSG)
EQUB 0    ; EQUB LO(TIMELEFTMSG)
EQUB LO(DRAWGUARD)
EQUB LO(DRAWGUARD)

EQUB LO(SETUPFLASK)
EQUB LO(SETUPCOMIX)
EQUB LO(PSETUPFLAME)
EQUB LO(DRAWPOST)
EQUB LO(DRAWGLASS)

EQUB LO(INITLAY)
EQUB 0    ; EQUB LO(TWINKLE)
EQUB LO(FLOW)
EQUB 0    ; EQUB LO(PMASK)

\*-------------------------------
\* mover.asm
\*-------------------------------
MOVER_BASE = P% - aux_core_fn_table_B_LO
EQUB LO(ANIMTRANS)
EQUB LO(TRIGSPIKES)
EQUB LO(PUSHPP)
EQUB LO(BREAKLOOSE1)
EQUB LO(BREAKLOOSE)

EQUB LO(ANIMMOBS)
EQUB LO(ADDMOBS)
EQUB LO(CLOSEEXIT)
EQUB LO(GETSPIKES)
EQUB LO(SHAKEM)

EQUB LO(TRIGSLICER)
EQUB LO(TRIGTORCH)
EQUB LO(GETFLAMEFRAME)
EQUB LO(SMASHMIRROR)
EQUB LO(JAMSPIKES)

EQUB LO(TRIGFLASK)
EQUB LO(GETFLASKFRAME)
EQUB LO(TRIGSWORD)
EQUB LO(JAMPP)

\*-------------------------------
\* specialk.asm
\*-------------------------------
SPECIALK_BASE = P% - aux_core_fn_table_B_LO
EQUB LO(KEYS)
EQUB LO(CLRJSTK)
EQUB 0     ; EQUB LO(ZEROSOUND)          BEEB TODO SOUND
EQUB 0     ; EQUB LO(ADDSOUND)           BEEB TODO SOUND
EQUB LO(FACEJSTK)

EQUB LO(SAVESELECT)
EQUB LO(LOADSELECT)
EQUB LO(SAVEDESEL)
EQUB LO(LOADDESEL)
EQUB LO(INITINPUT)

EQUB LO(DEMOKEYS)
EQUB 0         ; EQUB LO(LISTTORCHES)
EQUB 0         ; EQUB LO(BURN)
EQUB LO(GETMINLEFT)
EQUB LO(KEEPTIME)

EQUB 0         ; EQUB LO(SHORTENTIME)
EQUB 0         ; EQUB LO(CUESONG)          BEEB TODO MUSIC
 \jmp DoSaveGame
 \jmp LoadLevelX
 \jmp decstr

EQUB 0         ; EQUB LO(DLOOP)
EQUB LO(STROBE)
EQUB LO(CONTROLLER)

EQUB 0          ; EQUB LO(SETCENTER)      BEEB TODO JOYSTICK
EQUB 0          ; EQUB LO(PREAD)          JOYSTICK
EQUB LO(GETSELECT)
EQUB LO(GETDESEL)
EQUB LO(MUSICKEYS)

\*-------------------------------
\* subs.asm
\*-------------------------------
SUBS_BASE = P% - aux_core_fn_table_B_LO
EQUB LO(ADDTORCHES)
EQUB 0    ; EQUB LO(DOFLASHON)             BEEB TODO FLASH
EQUB 0    ; EQUB LO(shadow_swap_buffers)   ; JUMP_TO PAGEFLIP
EQUB 0    ; LO(DEMO)    // moved to auto.asm
EQUB LO(SHOWTIME)

EQUB 0    ; EQUB LO(DOFLASHOFF)            BEEB TODO FLASH
EQUB 0    ; EQUB LO(LRCLSE)                BEEB TODO FLASH
\ JUMP_TO potioneffect  ; in misc.asm
\ JUMP_TO checkalert    ; in misc.asm
\ JUMP_TO reflection    ; in misc.asm

EQUB LO(ADDSLICERS)
EQUB LO(PAUSE)
\ JUMP_TO bonesrise     ; in misc.asm
EQUB LO(DEADENEMY)
EQUB LO(PLAYCUT)

EQUB 0    ; EQUB LO(ADDLOWERSOUND)         BEEB TODO SOUND
EQUB LO(REMOVEOBJ)
EQUB LO(ADDFALL)
EQUB LO(SETINITIALS)
EQUB LO(STARTKID)

EQUB LO(STARTKID1)
EQUB LO(GRAVITY)
EQUB LO(INITIALGUARDS)
EQUB LO(MIRAPPEAR)
EQUB LO(CRUMBLE)

\*-------------------------------
\* misc.asm
\*-------------------------------
MISC_BASE = P% - aux_core_fn_table_B_LO
EQUB LO(VANISHCHAR)
EQUB 0      ; EQUB LO(MOVEMUSIC
EQUB 0      ; EQUB LO(MOVEAUXLC)
EQUB LO(FIRSTGUARD)
EQUB LO(MARKMETERS)

EQUB LO(POTIONEFFECT)
EQUB LO(MOUSERESCUE)
EQUB LO(STABCHAR)
EQUB LO(UNHOLY)
EQUB LO(REFLECTION)

EQUB LO(MARKKIDMETER)
EQUB LO(MARKOPPMETER)
EQUB LO(BONESRISE)
EQUB LO(DECSTR)
EQUB 0      ; EQUB LO(DOSAVEGAME)         BEEB TODO SAVEGAME

\.LoadLevelX jmp LOADLEVELX             ; moved to master.asm
EQUB LO(CHECKALERT)
EQUB 0      ; EQUB LO(DISPVERSION)


.aux_core_fn_table_B_HI

\*-------------------------------
\* ctrl.asm
\*-------------------------------
EQUB HI(PLAYERCTRL)
EQUB HI(CHECKFLOOR)
EQUB HI(SHADCTRL)
EQUB HI(REREADBLOCKS)
EQUB HI(CHECKPRESS)

EQUB HI(DOIMPALE)
EQUB HI(GENCTRL)
EQUB HI(CHECKIMPALE)

\*-------------------------------
\* frameadv.asm
\*-------------------------------
EQUB HI(SURE)
EQUB HI(FAST)
EQUB HI(GETINITOBJ)
EQUB HI(CALCBLUE)
EQUB HI(ZERORED)

\*-------------------------------
\* gamebg.asm
\*-------------------------------
EQUB HI(UPDATEMETERS)
EQUB HI(DRAWKIDMETER)
EQUB HI(DRAWSWORD)
EQUB HI(DRAWKID)
EQUB HI(DRAWSHAD)

EQUB HI(SETUPFLAME)
EQUB 0    ; EQUB HI(CONTINUEMSG)           BEEB TODO MESSAGES
EQUB HI(ADDCHAROBJ)
EQUB HI(SETOBJINDX)
EQUB 0    ; EQUB HI(PRINTLEVEL)

EQUB HI(DRAWOPPMETER)
EQUB 0    ; EQUB HI(FLIPDISKMSG)
EQUB 0    ; EQUB HI(TIMELEFTMSG)
EQUB HI(DRAWGUARD)
EQUB HI(DRAWGUARD)

EQUB HI(SETUPFLASK)
EQUB HI(SETUPCOMIX)
EQUB HI(PSETUPFLAME)
EQUB HI(DRAWPOST)
EQUB HI(DRAWGLASS)

EQUB HI(INITLAY)
EQUB 0    ; EQUB HI(TWINKLE)
EQUB HI(FLOW)
EQUB 0    ; EQUB HI(PMASK)

\*-------------------------------
\* mover.asm
\*-------------------------------
EQUB HI(ANIMTRANS)
EQUB HI(TRIGSPIKES)
EQUB HI(PUSHPP)
EQUB HI(BREAKLOOSE1)
EQUB HI(BREAKLOOSE)

EQUB HI(ANIMMOBS)
EQUB HI(ADDMOBS)
EQUB HI(CLOSEEXIT)
EQUB HI(GETSPIKES)
EQUB HI(SHAKEM)

EQUB HI(TRIGSLICER)
EQUB HI(TRIGTORCH)
EQUB HI(GETFLAMEFRAME)
EQUB HI(SMASHMIRROR)
EQUB HI(JAMSPIKES)

EQUB HI(TRIGFLASK)
EQUB HI(GETFLASKFRAME)
EQUB HI(TRIGSWORD)
EQUB HI(JAMPP)

\*-------------------------------
\* specialk.asm
\*-------------------------------
EQUB HI(KEYS)
EQUB HI(CLRJSTK)
EQUB 0     ; EQUB HI(ZEROSOUND)          BEEB TODO SOUND
EQUB 0     ; EQUB HI(ADDSOUND)           BEEB TODO SOUND
EQUB HI(FACEJSTK)

EQUB HI(SAVESELECT)
EQUB HI(LOADSELECT)
EQUB HI(SAVEDESEL)
EQUB HI(LOADDESEL)
EQUB HI(INITINPUT)

EQUB HI(DEMOKEYS)
EQUB 0         ; EQUB HI(LISTTORCHES)
EQUB 0         ; EQUB HI(BURN)
EQUB HI(GETMINLEFT)
EQUB HI(KEEPTIME)

EQUB 0         ; EQUB HI(SHORTENTIME)
EQUB 0         ; EQUB HI(CUESONG)          BEEB TODO MUSIC
 \jmp DoSaveGame
 \jmp LoadLevelX
 \jmp decstr

EQUB 0         ; EQUB HI(DLOOP)
EQUB HI(STROBE)
EQUB HI(CONTROLLER)

EQUB 0          ; EQUB HI(SETCENTER)      BEEB TODO JOYSTICK
EQUB 0          ; EQUB HI(PREAD)          JOYSTICK
EQUB HI(GETSELECT)
EQUB HI(GETDESEL)
EQUB HI(MUSICKEYS)

\*-------------------------------
\* subs.asm
\*-------------------------------
EQUB HI(ADDTORCHES)
EQUB 0    ; EQUB HI(DOFLASHON)             BEEB TODO FLASH
EQUB 0    ; EQUB HI(shadow_swap_buffers)   ; JUMP_TO PAGEFLIP
EQUB 0    ; HI(DEMO)    // moved to auto.asm
EQUB HI(SHOWTIME)

EQUB 0    ; EQUB HI(DOFLASHOFF)            BEEB TODO FLASH
EQUB 0    ; EQUB HI(LRCLSE)                BEEB TODO FLASH
\ JUMP_TO potioneffect  ; in misc.asm
\ JUMP_TO checkalert    ; in misc.asm
\ JUMP_TO reflection    ; in misc.asm

EQUB HI(ADDSLICERS)
EQUB HI(PAUSE)
\ JUMP_TO bonesrise     ; in misc.asm
EQUB HI(DEADENEMY)
EQUB HI(PLAYCUT)

EQUB 0    ; EQUB HI(ADDLOWERSOUND)         BEEB TODO SOUND
EQUB HI(REMOVEOBJ)
EQUB HI(ADDFALL)
EQUB HI(SETINITIALS)
EQUB HI(STARTKID)

EQUB HI(STARTKID1)
EQUB HI(GRAVITY)
EQUB HI(INITIALGUARDS)
EQUB HI(MIRAPPEAR)
EQUB HI(CRUMBLE)

\*-------------------------------
\* misc.asm
\*-------------------------------
EQUB HI(VANISHCHAR)
EQUB 0      ; EQUB LO(MOVEMUSIC)
EQUB 0      ; EQUB LO(MOVEAUXLC)
EQUB HI(FIRSTGUARD)
EQUB HI(MARKMETERS)

EQUB HI(POTIONEFFECT)
EQUB HI(MOUSERESCUE)
EQUB HI(STABCHAR)
EQUB HI(UNHOLY)
EQUB HI(REFLECTION)

EQUB HI(MARKKIDMETER)
EQUB HI(MARKOPPMETER)
EQUB HI(BONESRISE)
EQUB HI(DECSTR)
EQUB 0      ; EQUB LO(DOSAVEGAME)         BEEB TODO SAVEGAME

\.LoadLevelX jmp LOADLEVELX             ; moved to master.asm
EQUB HI(CHECKALERT)
EQUB 0      ; EQUB LO(DISPVERSION)

ENDIF

.aux_core_end

\\ Original approach
IF 0
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
ENDIF
