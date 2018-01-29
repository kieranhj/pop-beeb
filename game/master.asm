; master.asm
; Originally MASTER.S
; First boot code, system init, attract loop, level load etc.

.master
\ Moved to pop-beeb,asm
\DemoDisk = 0
\FinalDisk = 1

\org = $f880
\ lst off
\*-------------------------------
\*
\*  M  A  S  T  E  R
\*
\*  (3.5" version)
\*
\*  Sits in main l.c.
\*
\*-------------------------------
\ org org

 .firstboot jmp FIRSTBOOT
 .loadlevel jmp LOADLEVEL
 .reload BRK       ;jmp RELOAD                 EDITOR
 .loadstage2 BRK   ;jmp LoadStage2             UNUSED EXTERN?
 
 .attractmode jmp ATTRACTMODE
 .cutprincess jmp CUTPRINCESS
 .savegame BRK     ;jmp SAVEGAME               BEEB TODO SAVEGAME
 .loadgame BRK     ;jmp LOADGAME
 .dostartgame jmp DOSTARTGAME

 .epilog jmp EPILOG
 .loadaltset BRK   ;jmp LOADALTSET
\_screendump

.LoadLevelX jmp LOADLEVELX             ; moved from misc.asm

MACRO MASTER_LOAD_HIRES filename
{
 LDX #LO(filename)
 LDY #HI(filename)
 LDA #HI(beeb_screen_addr)
 JSR disksys_load_file
 JSR PageFlip               ; BEEB TODO figure out single/double buffer & wipe
}
ENDMACRO

MACRO MASTER_LOAD_DHIRES filename, lines
{
 LDX #LO(filename)
 LDY #HI(filename)
 LDA #HI(beeb_double_hires_addr + lines * 80 * 8)
 JSR disksys_load_file
 JSR PageFlip               ; BEEB TODO figure out single/double buffer & wipe
 JSR beeb_show_screen       ; in case previous blackout
}
ENDMACRO

\*-------------------------------
\ lst
\ put eq
\ lst
\ put gameeq
\ lst off
\
\Tmoveauxlc = moveauxlc-$b000

\*-------------------------------
\* RW18 ID bytes
\
\POPside1 = $a9
\POPside2 = $ad
\
\* RW18 zero page vars
\
\slot = $fd
\track = $fe
\lastrack = $ff
\
\* RW18 commands
\
\DrvOn = $00
\DrvOff = $01
\Seek = $02
\RdSeqErr = $03
\RdGrpErr = $04
\WrtSeqErr = $05
\WrtGrpErr = $06
\ModID = $07
\RdSeq = $83
\RdGrp = $84
\WrtSeq = $85
\WrtGrp = $86
\Inc = $40 ;.Inc to inc track

\*-------------------------------
\* Local vars

\dum locals
\ Now defined in master.h.asm

\*-------------------------------
\* Passed params

\ NOT BEEB
\params = $3f0

\*-------------------------------
\* Coordinates of default load-in level

.demolevel EQUB 0       ; BEEB CAN LOAD THESE AS FILES
.firstlevel EQUB 1      ; BEEB CAN LOAD THESE AS FILES

\*-------------------------------
\* Hi bytes of crunch data
\* Double hi-res (stage 1)

pacSplash = $40
delPresents = $70
delByline = $72
delTitle = $74
pacProlog = $7c
pacSumup = $60 ;mainmem
pacEpilog = $76 ;side B

\* Single hires (stage 2)

pacProom = $84

\*-------------------------------
\* Music song #s
\ Moved to soundnames.h.asm

\*-------------------------------
\* Soft switches
\ Already defined in grafix.asm
\IOUDISoff = $c07f
\IOUDISon = $c07e
\DHIRESoff = $c05f
\DHIRESon = $c05e
\HIRESon = $c057
\HIRESoff = $c056
\PAGE2on = $c055
\PAGE2off = $c054
\MIXEDon = $c053
\MIXEDoff = $c052
\TEXTon = $c051
\TEXToff = $c050
\ALTCHARon = $c00f
\ALTCHARoff = $c00e
\ADCOLon = $c00d
\ADCOLoff = $c00c
\ALTZPon = $c009
\ALTZPoff = $c008
\RAMWRTaux = $c005
\RAMWRTmain = $c004
\RAMRDaux = $c003
\RAMRDmain = $c002
\ADSTOREon = $c001
\ADSTOREoff = $c000

\RWBANK2 = $c083
\RWBANK1 = $c08b

\*-------------------------------
IF FinalDisk==0
kprincess = 'p'-$60 ;temp!
kdemo = 'd'-$60 ;temp!
krestart = 'r'-$60
ENDIF
kresume = 'l'-$60

\*-------------------------------
\*
\* Notes:
\*
\* Game code sits in auxmem & aux l.c. and uses aux z.p.
\*
\* Routines in main l.c. (including MASTER and HIRES)
\* are called via intermediary routines in GRAFIX (in auxmem).
\*
\* RW18 sits in bank 1 of main language card;
\* driveon switches it in, driveoff switches it out.
\*
\*-------------------------------
\*
\*  F I R S T B O O T
\*
\*-------------------------------

.FIRSTBOOT
{
\ NOT BEEB
\ lda MIXEDoff
\ jsr setaux

\* Set BBund ID byte

\ lda #POPside1
\ sta BBundID

\* Load hires tables & add'l hires routines

\ sta RAMWRTmain
\ lda #2
\ sta track
\ jsr rw18
\ db RdGrp.Inc
\ hex e0,e1,e2,e3,e4,e5,e6,e7,e8
\ hex e9,ea,eb,ec,ed,00,00,00,00

\* Load as much of Stage 3 as we can keep

 jsr loadperm

\* Turn off drive

\ jsr driveoff

\* Check for IIGS

\ jsr checkIIGS ;returns IIGS

\* Start attract loop

 jsr initsystem ;in topctrl

 lda #0
 sta invert ;rightside up Y tables

 lda #1
 sta soundon ;Sound on

IF _BOOT_ATTRACT
 jmp AttractLoop
ELSE
 jmp DOSTARTGAME
ENDIF
}

IF _TODO
*-------------------------------
*
*   Reload code & images
*   (Temp routine for game development)
*
*-------------------------------
RELOAD
 IF 0
 jsr driveon

 jsr loadperm
 jsr LoadStage3

 jmp driveoff
 ENDIF

*-------------------------------
*
* Load music (1K)
*
* Load at $5000 mainmem & move to aux l.c.
*
*-------------------------------
* Load music set 1 (title)

loadmusic1
 jsr setmain
 lda #34
 sta track
 jsr rw18
 db RdSeq,$4e ;we only want $50-53
]mm jsr setaux
 jmp xmovemusic

*-------------------------------
* Load music set 2 (game)

loadmusic2
 jsr setmain
 lda #20
 sta track
 jsr rw18
 db RdGrp.Inc
 hex 50,51,52,53,00,00,00,00,00
 hex 00,00,00,00,00,00,00,00,00
 jmp ]mm

*-------------------------------
* Load music set 3 (epilog)

loadmusic3
 jmp loadmusic1

*-------------------------------
setaux sta RAMRDaux
 sta RAMWRTaux
 rts

setmain sta RAMRDmain
 sta RAMWRTmain
 rts

*-------------------------------
*
*  D R I V E   O N
*
*  In: A = delay
*      BBundID
*
*  Sets auxmem
*
*-------------------------------
driveon lda #0
driveon1 sta :delay

 jsr setaux ;set auxmem

* switch in bank 1 (RW18)

 bit RWBANK1
 bit RWBANK1 ;1st 4k bank

* set Bbund ID

 lda BBundID
 sta :IDbyte

 jsr rw18
 db ModID
:IDbyte hex a9 ;Bbund ID byte

* turn on drive 1

 jsr rw18
 db DrvOn
:drive hex 01
:delay hex 00
 rts

*-------------------------------
*
*  D R I V E   O F F
*
*-------------------------------
driveoff jsr rw18
 db DrvOff

* switch in bank 2

 bit RWBANK2
 bit RWBANK2 ;2nd 4k bank

 sta $c010 ;clr kbd

 jmp setaux ;& set auxmem
ENDIF

\*-------------------------------
\*
\*  Set first level/demo level
\*
\*-------------------------------
.set1stlevel
{
 ldx firstlevel
\ ldx firstlevel+1
}
\\ Fall through!
.SetLevel
{
\ NOT BEEB
\ sta params
\ stx params+1
 rts
}

.setdemolevel
{
 ldx demolevel
\ ldx demolevel+1
 jmp SetLevel
}

IF _TODO
*-------------------------------
*
* Check track 22 to make sure it's the right disk
*
* (Scratch page 2 mainmem--return w/mainmem set)
*
*-------------------------------
checkdisk
 jsr setaux
 ldx #POPside2
 stx BBundID

 jsr driveon
:loop jsr setmain
 lda #22
 sta track
 jsr rw18
 db RdGrpErr.Inc
 hex 02,00,00,00,00,00,00,00,00
 hex 00,00,00,00,00,00,00,00,00
 bcc ]rts
 jsr error
 jmp :loop

*-------------------------------
*
* Save/load game
*
* Write/read 256 bytes of data: sector 0, track 23, side 2
* We scorch an entire track, but on side 2 we can afford it
*
*-------------------------------
SAVEGAME
 jsr checkdisk ;sets main

 sta RAMRDaux
 ldx #15
:loop lda savedgame,x ;aux
 sta $200,x ;main
 dex
 bpl :loop
 sta RAMRDmain

 lda #23
 sta track
 jsr rw18
 db WrtGrpErr
 hex 02,00,00,00,00,00,00,00,00
 hex 00,00,00,00,00,00,00,00,00
 bcc :ok
 jsr whoop
:ok jmp driveoff

*-------------------------------
LOADGAME
 jsr checkdisk ;sets main

 lda #23
 sta track
 jsr rw18
 db RdGrp
 hex 02,00,00,00,00,00,00,00,00
 hex 00,00,00,00,00,00,00,00,00

 sta RAMWRTaux
 ldx #15
:loop lda $200,x ;main
 sta savedgame,x ;aux
 dex
 bpl :loop

 jmp driveoff

*-------------------------------
*
* Load alt. character set (chtable4)
*
* In: Y = CHset4
*
*-------------------------------
LOADALTSET
 sty newCHset

 jsr driveon

 jsr rdch4

 jmp driveoff
ENDIF

\*-------------------------------
\*
\* L O A D   L E V E L
\*
\* In: bluepTRK, bluepREG
\*       TRK = track # (1-33)
\*       REG = region on track (0-1)
\*     A = BGset1; X = BGset2; Y = CHset4
\*
\* Load level into "working blueprint" buffer in auxmem;
\* game code will make a "backup copy" into aux l.c.
\* (which we can't reach from here).
\*
\* If bg & char sets in memory aren't right, load them in
\*
\*-------------------------------
.LOADLEVEL
{
 sta newBGset1
\ BEEB X STAYS AS LEVEL FOR BLUEPRINT
 sta newBGset2
 sty newCHset

\ NOT BEEB
\ jsr driveon

 jsr rdbluep ;blueprint
 jsr rdbg1 ;bg set 1
 jsr rdbg2 ;bg set 2
 jsr rdch4 ;char set 4

\ NOT BEEB - don't know what this is yet!
\ jsr vidstuff

\ NOT BEEB
\ jmp driveoff

\ Expand fist palette lookup

 LDA newBGset1
 BEQ is_dun
 LDA #8         ; is_pal
 .is_dun
 STA beeb_palette_toggle

\ Expand four palette tables in total

 LDA #4
 EOR beeb_palette_toggle
 LDX #LO(fast_palette_lookup_0)
 LDY #HI(fast_palette_lookup_0)
 JSR beeb_expand_palette_table

 LDA #5
 EOR beeb_palette_toggle
 LDX #LO(fast_palette_lookup_1)
 LDY #HI(fast_palette_lookup_1)
 JSR beeb_expand_palette_table

 LDA #6
 EOR beeb_palette_toggle
 LDX #LO(fast_palette_lookup_2)
 LDY #HI(fast_palette_lookup_2)
 JSR beeb_expand_palette_table
 
 LDA #7
 EOR beeb_palette_toggle
 LDX #LO(fast_palette_lookup_3)
 LDY #HI(fast_palette_lookup_3)
 JSR beeb_expand_palette_table

 RTS
}

\*-------------------------------
\ NOT BEEB
\setbluep
\ lda bluepTRK
\ sta track
\ lda bluepREG
\]rts rts

IF _TODO
*-------------------------------
vidstuff
 lda BBundID
 cmp #POPside2
 bne ]rts
 lda $c000
 cmp #"^"
 bne ]rts

 jsr setmain
 lda #12
 sta track
 jsr rw18
 db RdGrp.Inc
 hex 00,00,00,00,00,00,00,00,00
 hex 00,00,00,0c,0d,0e,0f,10,11
:loop jsr rw18
 db RdSeq.Inc
:sm hex 12
 lda :sm
 clc
 adc #$12
 sta :sm
 cmp #$6c
 bcc :loop
 jsr driveoff
 jsr setmain
 jmp $c00
ENDIF

\*-------------------------------
\* Track data for alt bg/char sets
\*
\* Set #:    0  1  2  3  4  5  6
\
\bg1trk hex 05,00,07
\bg2trk hex 12,02,09
\ch4trk hex 0d,03,04,05,0a,0b
\ch4off hex 0c,00,06,0c,00,06

\ Not sure what's going on here - suggests 3x sets of bg tiles
\ As these are loaded by track/sector and not filename, presume
\ The bg tiles are part loaded into memory location for bg
\ ANSWER: Tracks 07 & 09 are BGTAB1.DUN and BGTAB2.DUN but on the second disk to reduce swapping

\*-------------------------------
\rdbg1 ldx newBGset1
\ cpx BGset1 ;already in memory?
\ beq :rts ;yes--no need to load
\ stx BGset1
\ lda bg1trk,x
\ sta track
\ jsr rw18
\ db RdSeq.Inc,$60
\ jsr rw18
\ db RdSeq.Inc,$72
\]rts
\:rts rts

.bgset1_to_name
EQUS "DUN1X  $"
EQUS "PAL1X  $"
\EQUS "DUN1X  $"         ; bgset1=$02 just means side A/B of original disc

.rdbg1
{
    ldx newBGset1
\ BEEB TEMP
\    cpx BGset1
\    beq return
    stx BGset1

    \ index into table for filename
;    txa
    LDA BGset1
    asl a:asl a:asl a       ; x8
    clc
    adc #LO(bgset1_to_name)
    STA beeb_writeptr
    lda #HI(bgset1_to_name)
    adc #0
    STA beeb_writeptr+1

    \ Now need to load 2x blocks for BGTAB1

    \ Poke B into filename
    LDA #'B'
    LDY #4
    STA (beeb_writeptr), Y

    \ Set BANK for B
    lda #BEEB_SWRAM_SLOT_BGTAB1_B
    jsr swr_select_slot

    \ Load file B
    LDX beeb_writeptr
    LDY beeb_writeptr+1
    lda #HI(bgtable1b)
    jsr disksys_load_file

    \ Relocate the IMG file
    LDA #LO(bgtable1b)
    STA beeb_readptr
    LDA #HI(bgtable1b)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img


    \ Poke A into filename
    LDA #'A'
    LDY #4
    STA (beeb_writeptr), Y

    \ Set BANK for A
    lda #BEEB_SWRAM_SLOT_BGTAB1_A
    jsr swr_select_slot

    \ Load file B
    LDX beeb_writeptr
    LDY beeb_writeptr+1
    lda #HI(bgtable1a)
    jsr disksys_load_file

    \ Relocate the IMG file
    LDA #LO(bgtable1a)
    STA beeb_readptr
    LDA #HI(bgtable1a)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    .return
    rts
}

\rdbg2 ldx newBGset2
\ cpx BGset2
\ beq ]rts
\ stx BGset2
\ lda bg2trk,x
\ sta track
\ jsr rw18
\ db RdSeq.Inc,$84
\ rts

.bgset2_to_name
EQUS "DUN2   $"
EQUS "PAL2   $"
\EQUS "DUN2   $"            ; $02 just meant side B of original disc

.rdbg2
{
    ldx newBGset2
\ BEEB TEMP
\    cpx BGset2
\    beq return
    stx BGset2

    \ Need to define slot numbers for different data block
    lda #BEEB_SWRAM_SLOT_BGTAB2
    jsr swr_select_slot

    \ index into table for filename
    LDA BGset2
;    txa
    asl a:asl a:asl a       ; x8
    clc
    adc #LO(bgset2_to_name)
    tax
    lda #HI(bgset2_to_name)
    adc #0
    tay

    lda #HI(bgtable2)
    jsr disksys_load_file

    \ Relocate the IMG file
    LDA #LO(bgtable2)
    STA beeb_readptr
    LDA #HI(bgtable2)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    .return
    rts
}

\rdch4 ldx newCHset
\ cpx CHset
\ beq ]rts
\ stx CHset
\ lda ch4trk,x
\ sta track
\ lda ch4off,x
\ beq :off0
\ cmp #6
\ beq :off6
\ cmp #12
\ beq :off12
\ rts
\
\:off12 jsr rw18
\ db RdGrp.Inc
\ hex 00,00,00,00,00,00,00,00,00
\ hex 00,00,00,96,97,98,99,9a,9b
\ jsr rw18
\ db RdSeq.Inc,$9c
\ rts
\
\:off6 jsr rw18
\ db RdGrp.Inc
\ hex 00,00,00,00,00,00,96,97,98
\ hex 99,9a,9b,9c,9d,9e,9f,a0,a1
\ jsr rw18
\ db RdGrp.Inc
\ hex a2,a3,a4,a5,a6,a7,a8,a9,aa
\ hex ab,ac,ad,00,00,00,00,00,00
\ rts
\
\:off0 jsr rw18
\ db RdSeq.Inc,$96
\ jsr rw18
\ db RdGrp.Inc
\ hex a8,a9,aa,ab,ac,ad,00,00,00
\ hex 00,00,00,00,00,00,00,00,00
\]rts rts

.chset_to_name
EQUS "GD     $"
EQUS "SKEL   $"
EQUS "GD     $"
EQUS "FAT    $"
EQUS "SHAD   $"
EQUS "VIZ    $"

.rdch4
{
    ldx newCHset
\ BEEB TEMP
\    cpx CHset
\    beq return
    stx CHset

    \ Need to define slot numbers for different data block
    lda #BEEB_SWRAM_SLOT_CHTAB4
    jsr swr_select_slot

    \ index into table for filename
;    txa
    lda CHset
    asl a:asl a:asl a       ; x8
    clc
    adc #LO(chset_to_name)
    tax
    lda #HI(chset_to_name)
    adc #0
    tay

    lda #HI(chtable4)
    jsr disksys_load_file

    \ Relocate the IMG file
    LDA #LO(chtable4)
    STA beeb_readptr
    LDA #HI(chtable4)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    .return
    rts
}

\*-------------------------------
\*
\* read blueprint
\*
\*-------------------------------
\rdbluep
\ jsr setbluep
\ bne :reg1
\
\:reg0 jsr rw18
\ db RdGrpErr
\ hex b7,b8,b9,ba,bb,bc,bd,be,bf
\ hex 00,00,00,00,00,00,00,00,00
\ bcc ]rts
\ jsr error
\ jmp :reg0
\
\:reg1 jsr rw18
\ db RdGrpErr
\ hex 00,00,00,00,00,00,00,00,00
\ hex b7,b8,b9,ba,bb,bc,bd,be,bf
\ bcc ]rts
\ jsr error
\ jmp :reg1
.beeb_level_filename   EQUS "LEVEL0 $"

.rdbluep
{
    TXA
    BEQ set_drive
    LDA #2
    .set_drive
    JSR disksys_set_drive

    cpx #10
    bcs double_digit

    txa
    clc
    adc #'0'
    sta beeb_level_filename+5
    lda #' '
    sta beeb_level_filename+6
    bne do_load

    .double_digit
    txa
    clc
    adc #'0'-10
    sta beeb_level_filename+6
    lda #'1'
    sta beeb_level_filename+5

    .do_load
    lda #HI(blueprnt)
    ldx #LO(beeb_level_filename)
    ldy #HI(beeb_level_filename)
    jsr disksys_load_file
    
    rts
}

\*-------------------------------
\*
\* Copy one DHires page to another
\*
\*-------------------------------

.copy1to2
{
    LDA #HI(beeb_double_hires_addr)
    JMP beeb_copy_shadow

\ lda #$40 ;dest
\ ldx #$20 ;org
\ bne copydhires
\
\copy2to1
\ lda #$20
\ ldx #$40
\
\copydhires
\ sta IMAGE+1 ;dest
\ stx IMAGE ;org
\
\ jsr _copy2000aux
\ jmp _copy2000 ;in hires
}

\*-------------------------------
\*
\*  Cut to princess screen
\*
\*-------------------------------

.pacRoom_name
EQUS "PRIN   $"

.CUTPRINCESS
{
 jsr blackout
 lda #1 ;seek track 0
}
.cutprincess1
{
 jsr LoadStage2 ;displaces bgtab1-2, chtab4

\ lda #pacProom
\ jsr SngExpand

 MASTER_LOAD_HIRES pacRoom_name

\ Cutscenes take place in game mode

 JSR beeb_set_screen_mode

\ lda #$40
\ sta IMAGE+1
\ lda #$20
\ sta IMAGE ;copy page 1 to page 2
\ jmp _copy2000 ;in HIRES

 LDA #HI(beeb_screen_addr)
 JSR beeb_copy_shadow

\ BEEB TEMP load princess screen twice - could copy between MAIN & SHADOW
\ MASTER_LOAD_HIRES pacRoom_name

 JSR beeb_show_screen           ; BEEB show screen after blackout

 RTS
}

\*-------------------------------
\*
\*  Epilog (You Win)
\*
\*-------------------------------

.EPILOG
{
 lda #1
 sta soundon
 sta musicon
 jsr blackout

\ BEEB TODO check mem usage
\ jsr LoadStage1B

 jsr Epilog

\ NOT BEEB
\ lda #POPside1
\ sta BBundID
\ sta $c010

\ BEEB TODO wait for keypress
\.loop lda $c000
\ bpl .loop ;fall thru
}
\\ Fall thru!

\*-------------------------------
\*
\*  A  T  T  R  A  C  T
\*
\*  Self-running "attract mode"
\*
\*-------------------------------
.ATTRACTMODE
.AttractLoop
{
\ BEEB set drive 0 for attract
 LDA #0
 JSR disksys_set_drive

 lda #1
 sta musicon

 jsr SetupDHires

 jsr PubCredit

 jsr AuthorCredit

 jsr TitleScreen

 jsr Prolog1
.princess
 jsr PrincessScene

 jsr SetupDHires

 jsr Prolog2

 jsr SilentTitle

 jmp Demo
}

\*-------------------------------
\*
\* Set up double hi-res
\*
\*-------------------------------
.SetupDHires
{
\* Show black lo-res scrn

 jsr blackout

\* Load in Stage 1 data

\ BEEB TODO check memory usage
\ jmp LoadStage1A

 JMP beeb_set_double_hires
}

\*-------------------------------
\*
\* "Broderbund Software Presents"
\*
\*-------------------------------

.presents_filename
EQUS "PRESENT$"

.PubCredit
{
\* Unpack splash screen into DHires page 1

 jsr unpacksplash

\* Show DHires page 1

\ BEEB TODO - set MODE 1?
\ jsr setdhires

\* Copy to DHires page 2

\ BEEB TODO - double buffer
 jsr copy1to2

 lda #44
 jsr tpause

\* Unpack "Broderbund Presents" onto page 1

\ lda #delPresents
\ jsr DeltaExpPop

 MASTER_LOAD_DHIRES presents_filename, 12

\ ldx #80
\ lda #s_Presents
\ jsr master_PlaySongI

 LDA #10
 JSR tpause     \ BEEB TEMP pause not music

 jmp CleanScreen
}

\*-------------------------------
\*
\* Credit line disappears
\*
\*-------------------------------

.CleanScreen
{
\* Switch to DHires page 2
\* (credit line disappears)

\ BEEB TODO
\ lda PAGE2on

\* Copy DHires page 2 back to hidden page 1

\ jsr copy2to1

\* Display page 1

\ lda PAGE2off
.return
 rts
}

\*-------------------------------
\*
\* "A Game by Jordan Mechner"
\*
\*-------------------------------

.byline_filename
EQUS "BYLINE $"

.AuthorCredit
{
 lda #42
 jsr tpause

\* Unpack byline onto page 1

\ lda #delByline
\ jsr DeltaExpPop

 MASTER_LOAD_DHIRES byline_filename, 12

\ ldx #80
\ lda #s_Byline
\ jsr master_PlaySongI

 LDA #10
 JSR tpause     \ BEEB TEMP pause not music

\* Credit line disappears

 jmp CleanScreen
}

\*-------------------------------
\*
\* "Prince of Persia"
\*
\*-------------------------------

.title_filename
EQUS "TITLE  $"

.SilentTitle
{
 jsr unpacksplash

\ BEEB TODO double buffer?
 jsr copy1to2

 lda #20
 jsr tpause

\ lda #delTitle
\ jsr DeltaExpPop
 
 MASTER_LOAD_DHIRES title_filename, 12

 lda #160
 jmp tpause
}

\*-------------------------------

.TitleScreen
{
 lda #38
 jsr tpause

\* Unpack title onto page 1

\ lda #delTitle
\ jsr DeltaExpPop

 MASTER_LOAD_DHIRES title_filename, 12

\ ldx #140
\ lda #s_Title
\ jsr master_PlaySongI

 LDA #10
 JSR tpause     \ BEEB TEMP pause not music

\* Credit line disappears

 jmp CleanScreen
}

\*-------------------------------
\*
\*  Prologue, part 1
\*
\*-------------------------------

.prolog_filename
EQUS "PROLOG $"

.Prolog1
{
\ lda #pacProlog
\ sta RAMRDaux
\ jsr DblExpand

 MASTER_LOAD_DHIRES prolog_filename, 0

\ ldx #250
\ lda #s_Prolog
\ jmp master_PlaySongI

 LDA #10
 JSR tpause     \ BEEB TEMP pause not music
 RTS
}

\*-------------------------------
\*
\*  Princess's room: Vizier starts hourglass
\*
\*-------------------------------

.PrincessScene
{
 jsr blackout

\ BEEB TODO check mem usage by titles
\ jsr ReloadStuff ;wiped out by dhires titles

 lda #0 ;don't seek track 0
 jsr cutprincess1

 lda #0 ;cut #0 (intro)
 jmp playcut ;Apple II was xplaycut aux l.c. via grafix
}

\*-------------------------------
\*
\*  Prologue, part 2
\*
\*-------------------------------

.sumup_filename
EQUS "SUMUP  $"

.Prolog2
{
\ lda #pacSumup
\ sta RAMRDmain
\ jsr DblExpand

\ jsr setdhires

 MASTER_LOAD_DHIRES sumup_filename, 0

\ ldx #250
\ lda #s_Sumup
\ jmp master_PlaySongI

 LDA #10
 JSR tpause     \ BEEB TEMP pause not music
 RTS
}

\*-------------------------------
\*
\* Epilog
\*
\*-------------------------------

.epilog_filename
EQUS "EPILOG $"

.Epilog
{
\\ NOT BEEB
\ lda IIGS
\ bne SuperEpilog ;super hi-res ending if IIGS

\ lda #pacEpilog
\ sta RAMRDaux
\ jsr DblExpand

\ jsr setdhires

 MASTER_LOAD_DHIRES epilog_filename, 0

 jsr SetupDHires

 lda #s_Epilog
 jsr PlaySongNI
 lda #15
 jsr pauseNI
 jsr unpacksplash
 lda #75
 jsr pauseNI

 lda #s_Curtain
 jsr PlaySongNI
 lda #60
 jsr pauseNI

 jmp blackout
}

.splash_filename
EQUS "SPLASH $"

.unpacksplash
{
\ lda #pacSplash
\ sta RAMRDaux
\ jmp DblExpand

 MASTER_LOAD_DHIRES splash_filename, 0

 RTS
}

IF _NOT_BEEB
*-------------------------------
*
* Super hi-res epilog (IIGS only)
*
*-------------------------------
SuperEpilog
 lda #1 ;aux
 jsr fadein ;fade in epilog screen
 jsr setaux

 lda #s_Epilog
 jsr PlaySongNI

 jsr fadeout
 lda #0 ;main
 jsr fadein ;fade to palace screen
 jsr setaux

 lda #80
 jsr pauseNI

 lda #s_Curtain
 jsr PlaySongNI

 lda #255
 jsr pauseNI

 jsr fadeout ;...and fade to black

 jmp * ;and hang (because it's too much
;trouble to restart)
ENDIF

\*-------------------------------
\*
\*  Demo sequence
\*
\*-------------------------------

.Demo
{
 jsr blackout

\ NOT BEEB
\ jsr LoadStage3

\ BEEB set game screen mode (hires)
 JSR beeb_set_screen_mode

 jsr setdemolevel
 jsr rdbluep

\ jsr driveoff

\* Go to TOPCTRL

 lda #0
 jmp start
}

\*-------------------------------
\* non-interruptible pause

.pauseNI
{
.loop sta pausetemp
 ldy #20
.loop1 ldx #0
.loop2 dex
 bne loop2
 dey
 bne loop1

 lda pausetemp
 sec
 sbc #1
 bne loop
}
.return_61
 rts

\*-------------------------------
\*
\*  Start game? (if key or button pressed)
\*
\*-------------------------------
.master_StartGame
{
 jsr musickeys
 cmp #$80 ;key or button press?
 bcc return_61 ;no

 IF FinalDisk
 ELSE
 cmp #kdemo ;temp!
 bne label_1
 jmp Demo
.label_1 cmp #kprincess ;temp!
 bne label_2
 jmp master_princess
 ENDIF

.label_2 cmp #krestart
 bne label_3
 jmp AttractLoop
.label_3 ;fall thru to DOSTARTGAME
}

\*-------------------------------
\*
\*  Start a game
\*
\*-------------------------------
.DOSTARTGAME
{
 jsr blackout

\* Turn on drive & load Stage 3 routines

\ NOT BEEB
\:1 jsr LoadStage3

\ BEEB set game screen mode (hires)
 JSR beeb_set_screen_mode

\* Load 1st level

 jsr set1stlevel

 jsr rdbluep

\* Turn off drive & set aux

\ NOT BEEB
\ jsr driveoff

\* Go to TOPCTRL

 lda #1
 sta musicon

 IF DemoDisk
 ELSE

 lda keypress
 cmp #kresume
 bne newgame

\* Resume old game

 lda #4 ;arbitrary
 jmp startresume

 ENDIF

\* Start new game

.newgame
 lda #1
 jmp start
}

\*-------------------------------
\*
\* Load permanent code & data
\* (only once)
\*
\*-------------------------------
\loadperm
\ lda #3
\ sta track
\
\ jsr setaux
\
\ jsr rw18
\ db RdSeq.Inc,$0e
\
\ jsr rw18
\ db RdGrp.Inc
\ hex 04,05,06,07,08,09,0a,0b,0c
\ hex 0d,20,21,22,23,24,25,26,27
\
\ jsr setmain
\ lda #9
\ sta track
\ jsr rw18
\ db RdSeq.Inc,$84
\ jsr rw18
\ db RdSeq.Inc,$96
\
\ jsr rw18
\ db RdSeq.Inc,$08
\
\ jsr rw18
\ db RdGrp.Inc
\ hex 1a,1b,1c,1d,1e,1f,a8,a9,aa
\ hex ab,ac,ad,ae,af,b0,b1,b2,b3
\
\ jsr rw18
\ db RdGrp.Inc
\ hex b4,b5,b6,b7,b8,b9,ba,bb,bc
\ hex bd,be,bf,00,00,00,00,00,00
\
\*-------------------------------
\*
\* Load aux l.c. stuff (tracks 19-21 & 34)
\* (includes music set 1)
\*
\* Load into main hires area & move to aux l.c.
\*
\*-------------------------------
\ lda #19
\ sta track
\
\ jsr rw18
\ db RdGrp.Inc
\ hex 00,00,20,21,22,23,24,25,26
\ hex 27,28,29,2a,2b,2c,2d,2e,2f
\
\ jsr rw18
\ db RdGrp.Inc
\ hex 00,00,00,00,30,31,32,33,34
\ hex 35,36,37,38,39,3a,3b,3c,3d
\ jsr rw18
\ db RdSeq.Inc,$3e
\
\ lda #34
\ sta track
\ jsr rw18
\ db RdGrp.Inc
\ hex 00,00,50,51,52,53,54,55,56
\ hex 57,58,59,5a,5b,5c,5d,5e,5f
\
\ jsr setaux
\ lda #1
\ sta MSset
\
\ jsr setmain
\ jmp Tmoveauxlc
\
\ BEEB - Not sure what this loads on Apple II but for Beeb we'll load:
\ CHTAB IMG files for Kid
\ Probably the gameplay code into SHADOW RAM eventually
.perm_file_names
EQUS "CHTAB1 $"
EQUS "CHTAB3 $"
EQUS "CHTAB2 $"
EQUS "CHTAB5 $"

.bank1_filename
EQUS "BANK1  $"

.loadperm
{
    LDA #0
    JSR disksys_set_drive

    \ Start with CHTAB1 + 3
    lda #BEEB_SWRAM_SLOT_CHTAB13
    jsr swr_select_slot

IF BEEB_SWRAM_SLOT_CHTAB13=BEEB_SWRAM_SLOT_CHTAB25
    LDX #LO(bank1_filename)
    LDY #HI(bank1_filename)
    LDA #HI(SWRAM_START)
    JSR disksys_load_file
ELSE
    \ index into table for filename
    LDX #LO(perm_file_names)
    LDY #HI(perm_file_names)
    LDA #HI(chtable1)
    JSR disksys_load_file

    \ index into table for filename
    LDX #LO(perm_file_names + 8)
    LDY #HI(perm_file_names + 8)
    LDA #HI(chtable3)
    JSR disksys_load_file

    \ Then CHTAB2 + 5
    lda #BEEB_SWRAM_SLOT_CHTAB25
    jsr swr_select_slot

    \ index into table for filename
    LDX #LO(perm_file_names + 16)
    LDY #HI(perm_file_names + 16)
    LDA #HI(chtable2)
    JSR disksys_load_file

    \ index into table for filename
    LDX #LO(perm_file_names + 24)
    LDY #HI(perm_file_names + 24)
    LDA #HI(chtable5)
    JSR disksys_load_file
ENDIF

    \ Relocate the IMG file
    LDA #LO(chtable1)
    STA beeb_readptr
    LDA #HI(chtable1)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    \ Relocate the IMG file
    LDA #LO(chtable3)
    STA beeb_readptr
    LDA #HI(chtable3)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    \ Relocate the IMG file
    LDA #LO(chtable2)
    STA beeb_readptr
    LDA #HI(chtable2)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    \ Relocate the IMG file
    LDA #LO(chtable5)
    STA beeb_readptr
    LDA #HI(chtable5)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    .return
    rts
}

IF _TODO
*-------------------------------
*
*  Stage 1: static dbl hires screens -- no animation
*  Stage 2: character animation only (bg is unpacked)
*  Stage 3: full game animation
*
*-------------------------------
*
* Load Stage 1 data (sida A)
*
*-------------------------------
]lsub sta track
:test jsr rw18
 db RdSeqErr.Inc,$40
 bcc :ok
 jsr error
 jmp :test
:ok
 jsr rw18
 db RdSeq.Inc,$52
 jsr rw18
 db RdSeq.Inc,$64
 jsr rw18
 db RdSeq.Inc,$76
 jsr rw18
 db RdSeq.Inc,$88
 rts

LoadStage1A
 jsr driveon

 lda #22
 jsr ]lsub

 jsr setmain
 jsr rw18
 db RdSeq.Inc,$60
 jsr rw18
 db RdSeq.Inc,$72

 jsr loadmusic1

 jsr setaux
 lda #$ff
 sta BGset1
 sta BGset2
 sta CHset

 jmp driveoff

*-------------------------------
*
*  Load stage 1 (side B)
*
*-------------------------------
LoadStage1B
 jsr driveon

 jsr loadmusic3 ;epilog

 lda IIGS
 bne :shires ;Super hi-res ending only if IIGS

 lda #18
 jsr ]lsub
 jmp driveoff

:shires jsr loadsuper ;in unpack
 jmp driveoff

*-------------------------------
*
* Reload 2000-6000 auxmem
* (wiped out by dhires titles)
*
*-------------------------------
ReloadStuff
 jsr driveon

:test lda #4
 sta track
 jsr rw18
 db RdGrpErr
 hex 00,00,00,00,00,00,00,00,00
 hex 00,20,21,22,23,24,25,26,27
 bcc :ok
 jsr error
 jmp :test
:ok
 lda #15
 sta track
 jsr rw18
 db RdSeq.Inc,$28
 jsr rw18
 db RdSeq.Inc,$3a
 jsr rw18
 db RdSeq.Inc,$4c

 jmp driveoff
ENDIF

\*-------------------------------
\*
\*  Load stage 2 data (6000-a800)
\*
\*-------------------------------
\LoadStage2
\ ldx BBundID
\ cpx #POPside2
\ beq LoadStage2B
\
\LoadStage2A
\ jsr driveon
\
\ lda #0
\ jsr loadch7 ;side A only
\
\ lda #29
\]ls2 sta track
\
\:test jsr rw18
\ db RdSeqErr.Inc,$60
\ bcc :ok
\ jsr error
\ jmp :test
\:ok
\ jsr rw18
\ db RdSeq.Inc,$72
\ jsr rw18
\ db RdSeq.Inc,$84
\ jsr rw18
\ db RdGrp.Inc
\ hex 96,97,98,99,9a,9b,9c,9d,9e
\ hex 00,00,00,00,00,00,00,00,00
\
\ lda #$ff
\ sta BGset1
\ sta BGset2
\ sta CHset
\
\ jmp driveoff
\
\* Load chtable7 (side A only)
\
\loadch7
\ sta recheck0
\:test lda #28
\ sta track
\ jsr rw18
\ db RdGrpErr.Inc
\ hex 00,00,00,00,00,00,00,00,00
\ hex 00,00,00,00,9f,a0,a1,a2,a3
\ bcc :ok
\ jsr error
\ jmp :test
\:ok
\]rts rts
\
\*-------------------------------
\*
\*  Load stage 2 routines (side B)
\*
\*-------------------------------
\LoadStage2B
\ jsr driveon
\
\ lda #24
\ bne ]ls2

.chtab6_to_name
EQUS "CHTAB6X$"

.LoadStage2
{
    LDA #0
    JSR disksys_set_drive

    \\ Need to switch sCHTAB6 A/B according to Apple II disc layout

    LDA #0
    CLC
    ADC #'A'
    STA chtab6_to_name+6

    lda #BEEB_SWRAM_SLOT_CHTAB67
    jsr swr_select_slot

    lda #HI(chtable6)
    ldx #LO(chtab6_to_name)
    ldy #HI(chtab6_to_name)
    jsr disksys_load_file

    \ Relocate the IMG file
    LDA #LO(chtable6)
    STA beeb_readptr
    LDA #HI(chtable6)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    LDA #&ff
    sta BGset1
    sta BGset2

    JSR loadch7

    .return
    rts    
}

.chtab7_file_name
EQUS "CHTAB7 $"

.loadch7
{
    lda #BEEB_SWRAM_SLOT_CHTAB67
    jsr swr_select_slot

    lda #HI(chtable7)
    ldx #LO(chtab7_file_name)
    ldy #HI(chtab7_file_name)
    jsr disksys_load_file

    \ Relocate the IMG file
    LDA #LO(chtable7)
    STA beeb_readptr
    LDA #HI(chtable7)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    LDA #&ff
    STA CHset

    .return
    rts
}

IF _TODO
*-------------------------------
*
*  Load stage 3
*  Full version (from stage 1)
*
*  Reload 2000-AC00 auxmem, 6000-7200 mainmem
*
*-------------------------------
LoadStage3
 jsr driveon

 lda #4
 sta track

:loop jsr rw18
 db RdGrpErr.Inc
 hex 00,00,00,00,00,00,00,00,00
 hex 00,20,21,22,23,24,25,26,27
 bcc :ok
 jsr error
 jmp :loop
:ok
 jsr rw18
 db RdSeq.Inc,$60
 jsr rw18
 db RdSeq.Inc,$72 ;bgtable1

 jsr setmain
 jsr rw18
 db RdSeq.Inc,$60
 jsr rw18
 db RdSeq.Inc,$72

 jsr setaux

 lda #13
 sta track
 jsr rw18
 db RdGrp.Inc
 hex 00,00,00,00,00,00,00,00,00
 hex 00,00,00,96,97,98,99,9a,9b
 jsr rw18
 db RdSeq.Inc,$9c ;chtable4
 jsr rw18
 db RdSeq.Inc,$28
 jsr rw18
 db RdSeq.Inc,$3a
 jsr rw18
 db RdSeq.Inc,$4c
 jsr rw18
 db RdSeq.Inc,$84 ;bgtable2

 lda #0
 sta BGset1
 sta BGset2
 sta CHset

 jsr loadmusic2

 jmp setaux
ENDIF

\*-------------------------------
\*
\* Play song--interruptible & non-interruptible
\*
\* (Enter & exit w/ bank 2 switched in)
\*
\* In: A = song #
\*     X = length to pause if sound is turned off
\*
\*-------------------------------

.PlaySongNI ;non-interruptible
{
;(& ignores sound/music toggles)
\ jsr setaux
\ BEEB TODO music
 jsr minit      ; was xminit
 LDA #1
.loop
\ BEEB TODO music
 jsr mplay      ; was xmplay
 cmp #0
 bne loop
.return
 rts
}

\*-------------------------------

.master_PlaySongI ;interruptible
{
\ jsr setaux
\ beq return

 tay
 lda musicon
 and soundon
 beq master_pause

 tya
 jsr minit      ; was xminit
.loop jsr master_StartGame
 jsr mplay      ; was xmplay
 cmp #0
 bne loop
.return
 rts
}

.master_pause txa ;falls thru to tpause
\*-------------------------------
\*
\*  In: A = delay (max = 255)
\*
\*-------------------------------
.tpause
{
.loop sta pausetemp

 ldy #2
.loop1 ldx #0
.loop2 PHX:PHY:jsr master_StartGame:PLY:PLX
 dex
 bne loop2
 dey
 bne loop1

 lda pausetemp
 sec
 sbc #1
 bne loop
.return
 rts
}

IF _TODO
*-------------------------------
*
* Disk error
*
* Prompt user for correct disk side & wait for keypress
*
*-------------------------------
error
 jsr driveoff

 jsr prompt

 jmp driveon

\*-------------------------------
\ lst
\eof ds 1
\ usr $a9,1,$a80,*-org
\ lst off
ENDIF

\ BEEB MOVED FROM UNPACK.S

\*-------------------------------
\*
\* Show black screen (text page 1)
\*
\*-------------------------------
.blackout
{
    JMP beeb_set_blackout
}

\ BEEB MOVED FROM MISC.S

\*-------------------------------
\* alt bg & char set list
\* Level #:   0  1  2  3  4  5  6  7  8  9 10 11 12 13 14

.bgset1 EQUB 00,00,00,00,01,01,01,00,00,00,01,01,00,00,01
\bgset2 EQUB 00,00,00,00,01,01,01,02,02,02,01,01,02,02,01
.chset  EQUB 00,00,00,01,02,02,03,02,02,02,02,02,04,05,05

\*-------------------------------
\*
\* Load level from disk
\* In: X = level # (0-14)
\*
\*-------------------------------
.LOADLEVELX
{
\ Just keep X as level#

\ lda bluepTRKlst,x
\ sta bluepTRK
\ lda bluepREGlst,x
\ sta bluepREG

 lda bgset1,x ;A
\ pha
\ lda bgset2,x ;X
 ldy chset,x ;Y
\ tax
\ pla

 jmp LOADLEVEL ;in MASTER
}
