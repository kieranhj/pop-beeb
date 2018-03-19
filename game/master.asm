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

;.firstboot jmp FIRSTBOOT               ; moved to pop-beeb.asm
;.loadlevel jmp LOADLEVEL
;.reload BRK       ;jmp RELOAD          ; EDITOR
;.loadstage2 BRK   ;jmp LoadStage2      ; UNUSED EXTERN?
.goattract
.attractmode jmp ATTRACTMODE
.cutprincess jmp CUTPRINCESS
.savegame jmp SAVEGAME
.loadgame jmp LOADGAME
.dostartgame jmp DOSTARTGAME

.epilog jmp EPILOG
;.loadaltset BRK   ;jmp LOADALTSET      ; unusued Editor?
\_screendump

.LoadLevelX jmp LOADLEVELX              ; moved from misc.asm
.DoSaveGame jmp DOSAVEGAME              ; moved from misc.asm

.master_load_hires
{
 JSR beeb_set_game_screen
 LDA #HI(beeb_screen_addr)
 JSR disksys_load_file
 JSR vblank
 JMP PageFlip
}

MACRO MASTER_LOAD_HIRES filename
{
 LDX #LO(filename)
 LDY #HI(filename)
 JSR master_load_hires
}
ENDMACRO

.master_load_dhires
{
IF _DEMO_BUILD
 JSR plot_demo_url
ENDIF

 JSR beeb_clear_dhires_line
 JSR vblank
 JSR PageFlip
 JMP beeb_show_screen       ; in case previous blackout
}

MACRO MASTER_LOAD_DHIRES filename, pu_size
{
 LDX #LO(filename)
 LDY #HI(filename)
 LDA #HI(&8000 - pu_size)
 JSR disksys_load_file

 LDA #PUCRUNCH_BANK:JSR swr_select_slot
 LDX #LO(&8006 - pu_size)
 LDY #HI(&8006 - pu_size)
 JSR PUCRUNCH_UNPACK

 JSR master_load_dhires
}
ENDMACRO

MACRO MASTER_WIPE_DHIRES filename, pu_size
{
 LDX #LO(filename)
 LDY #HI(filename)
 LDA #HI(&8000 - pu_size)
 JSR disksys_load_file

 LDA #PUCRUNCH_BANK:JSR swr_select_slot
 LDX #LO(&8006 - pu_size)
 LDY #HI(&8006 - pu_size)
 JSR PUCRUNCH_UNPACK

 JSR beeb_clear_dhires_line
 JSR beeb_dhires_wipe
}
ENDMACRO

IF _DEMO_BUILD
SMALL_FONT_MAPCHAR
.url_message EQUS "bitshifters.github.io", &FF
ASCII_MAPCHAR

.plot_demo_url
{
    LDA #LO(url_message)
    STA beeb_readptr
    LDA #HI(url_message)
    STA beeb_readptr+1

    LDA #PAL_FONT
    LDX #38
    LDY #BEEB_STATUS_ROW
    JMP beeb_plot_font_string
}
ENDIF

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
\ NOT BEEB

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

\*-------------------------------
IF FinalDisk==0
kprincess = 'p'-$60 ;temp!
kdemo = 'd'-$60 ;temp!
krestart = 'r'-$60
ENDIF
kresume = IKN_l OR $80

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

.error_handler
{
    LDA SavLevel
    BEQ not_trying_to_save

    \\ We were in middle of save game but an error occured
    LDX #&FF
    TXS                 ; reset stack

    BPL go_mainloop
    STX SavLevel
    STZ SavError
    JMP ResumeGame_ReEnter  ; if loading

    .go_mainloop        ; if saving
    STX SavError        ; flag error
    STZ SavLevel        ; clear save flag
    JMP MainLoop        ; re-enter game (and keep fingers crossed)

    \\ We weren't saving so just restart
    .not_trying_to_save

    .wait_vsync
;    DEX:BEQ stop_wait       ; in case our event handler has crashed
    LDA vsync_swap_buffers
    BNE wait_vsync
    .stop_wait

    LDA &FE34:AND #&5:BEQ same_same
    CMP #&5:BEQ same_same

    \\ Attempt to write to visible screen - flip to single buffer
    lda &fe34:eor #4:sta &fe34	; invert bits 0 (CRTC) & 2 (RAM)
 
    .same_same
    JSR beeb_print_version_and_build
    
    LDA #LO(crash_strings):STA beeb_readptr
    LDA #HI(crash_strings):STA beeb_readptr+1
    LDX #0:LDY #0:LDA #PAL_FONT
    JSR beeb_plot_font_string

    LDX #0:LDY #2:LDA #PAL_FONT
    JSR beeb_plot_font_string
    
    LDX #0:LDY #4:LDA #PAL_FONT
    JSR beeb_plot_font_string

    LDX #0:LDY #6:LDA #PAL_FONT
    JSR beeb_plot_font_string

    \\ Plot Program Counter that was pushed onto the stack

    TSX:LDA &103, X: JSR beeb_plot_font_bcd
    TSX:LDA &102, X: JSR beeb_plot_font_bcd

    .spin
    BRA spin
}

.beeb_print_version_and_build
{
  \ Write initial string
  LDA #LO(version_string):STA beeb_readptr
  LDA #HI(version_string):STA beeb_readptr+1
  LDX #10
  LDY #BEEB_STATUS_ROW
  LDA #PAL_FONT
  JSR beeb_plot_font_string

  \ Print version #
  LDA pop_beeb_version
  LSR A:LSR A:LSR A:LSR A
  CLC
  ADC #1
  JSR beeb_plot_font_glyph

  LDA #GLYPH_DOT
  JSR beeb_plot_font_glyph

  LDA pop_beeb_version
  AND #&F
  CLC
  ADC #1
  JSR beeb_plot_font_glyph

  LDA #LO(build_string):STA beeb_readptr
  LDA #HI(build_string):STA beeb_readptr+1
  LDX #38
  LDY #BEEB_STATUS_ROW
  LDA #PAL_FONT
  JSR beeb_plot_font_string
  
  LDA pop_beeb_build+0:JSR beeb_plot_font_bcd
  LDA pop_beeb_build+1:JSR beeb_plot_font_bcd
  LDA pop_beeb_build+2:JSR beeb_plot_font_bcd

  LDA #GLYPH_DOT:JSR beeb_plot_font_glyph

  LDA pop_beeb_build+3:JSR beeb_plot_font_bcd
  LDA pop_beeb_build+4:JMP beeb_plot_font_bcd
}

IF _NOT_BEEB
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
IF _DEBUG
 ldx #_START_LEVEL
ELSE
 ldx #1
ENDIF
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
 ldx #0
\ ldx demolevel+1
 jmp SetLevel
}

IF _NOT_BEEB
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
ENDIF

\*-------------------------------
\*
\* Save/load game
\*
\* Write/read 256 bytes of data: sector 0, track 23, side 2
\* We scorch an entire track, but on side 2 we can afford it
\*
\*-------------------------------

.savegame_filename
EQUS "SAVE", 13

.savegame_params
EQUW savegame_filename
; file load address
EQUD savegame
; file exec address
EQUD 0
; start address or length
EQUD savedgame
; end address of attributes
EQUD savedgame_top

.SAVEGAME
{
    LDA #LO(savedgame)
    STA savegame_params+2
    STA savegame_params+10

    LDA #HI(savedgame)
    STA savegame_params+3
    STA savegame_params+11

    LDA #LO(savedgame_top)
    STA savegame_params+14
    LDA #HI(savedgame_top)
    STA savegame_params+15

    LDX #LO(savegame_params)
    LDY #HI(savegame_params)
    LDA #0
    JMP osfile
}

\*-------------------------------

.LOADGAME
{
    LDA #LO(savedgame)
    STA savegame_params+2

    LDA #HI(savedgame)
    STA savegame_params+3

	LDX #LO(savegame_params)
	LDY #HI(savegame_params)
	LDA #&FF
    JMP osfile
}

IF _TODO
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

\ jmp LOADLEVEL ;in MASTER
}
\ Fall through instead!
.LOADLEVEL
{
 sta newBGset1
\ BEEB X STAYS AS LEVEL FOR BLUEPRINT
 sta newBGset2
 sty newCHset

    \ Switch Guard palettes - super hacky and can only get away with it because background sprites
    \ Using these palettes never become loose pieces that can move - otherwise they would change too!
    {
        CMP #1
        BEQ is_palace

        \ Is Dungeon
        LDA #MODE2_YELLOW_PAIR
        STA palette_table+4*3+3     ; ick! Change colour 3 in palette 3 to Yellow (guard outfit)
        STA palette_table+4*4+3     ; ick! Change colour 3 in palette 4 to Yellow (guard outfit)
        
        LDA #MODE2_RED_PAIR
        STA palette_table+4*4+1     ; ick! Change colour 1 in palette 4 to Red (special guard)
        BNE is_done

        .is_palace
        LDA #MODE2_WHITE_PAIR
        STA palette_table+4*3+3     ; ick! Change colour 3 in palette 3 to White (guard outfit)
        STA palette_table+4*4+3     ; ick! Change colour 3 in palette 3 to White (guard outfit)

        LDA #MODE2_GREEN_PAIR
        STA palette_table+4*4+1     ; ick! Change colour 1 in palette 4 to Green (special guard)
        .is_done
    }

\ NOT BEEB
\ jsr driveon

 jsr rdbluep ;blueprint
 jsr rdbg1 ;bg set 1
 jsr rdbg2 ;bg set 2
 jsr rdch4 ;char set 4

IF _AUDIO
    LDA #0
    JSR disksys_set_drive       ; gah!

    lda #3
    jsr BEEB_LOAD_AUDIO_BANK

    LDA #2
    JSR disksys_set_drive
ENDIF

\ NOT BEEB - don't know what this is yet!
\ jsr vidstuff

\ NOT BEEB
\ jmp driveoff

 RTS
}

\*-------------------------------
\ NOT BEEB
\setbluep
\ lda bluepTRK
\ sta track
\ lda bluepREG
\]rts rts

IF _NOT_BEEB
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

.bgset1_to_name
EQUS "DUN1X  $"
EQUS "PAL1X  $"
\EQUS "DUN1X  $"         ; bgset1=$02 just means side A/B of original disc

.rdbg1
{
    ldx newBGset1
    cpx BGset1
    beq return
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

.bgset2_to_name
EQUS "DUN2   $"
EQUS "PAL2   $"
\EQUS "DUN2   $"            ; $02 just meant side B of original disc

.rdbg2
{
    ldx newBGset2
    cpx BGset2
    beq return
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
    cpx CHset
    beq return
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

.beeb_level_filename   EQUS "LEVEL0 $"

.rdbluep
{
\\ Now all levels on SIDE B

    LDA #2
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
}

\*-------------------------------
\*
\*  Cut to princess screen
\*
\*-------------------------------

.pacRoom_name
EQUS "PRIN2  $"

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

 JSR beeb_clear_status_line

\ Need game screen dimensions

 JSR beeb_set_game_screen

\ Load Princess screen image
\ And MODE2 PLOT overlay

 LDX #LO(pacRoom_name)
 LDY #HI(pacRoom_name)
 LDA #HI(PRIN2_START)
 JSR disksys_load_file

\ Flip the screen buffers

 JSR vblank
 JSR PageFlip

\ lda #$40
\ sta IMAGE+1
\ lda #$20
\ sta IMAGE ;copy page 1 to page 2
\ jmp _copy2000 ;in HIRES

\ Copy the screen buffers

 LDA #HI(PRIN2_START)
 JSR beeb_copy_shadow

\ Display

 JMP beeb_show_screen           ; BEEB show screen after blackout
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
.GOATTRACT
.ATTRACTMODE
.AttractLoop
{
\ Reset stack as never return from here

 LDX #&FF
 TXS

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

 jsr BeebCredit

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

\ jmp LoadStage1A

 JMP beeb_set_attract_screen
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
IF _AUDIO
    ; SM: added title music load & play trigger here
    ; load title audio bank
    lda #0
    jsr BEEB_LOAD_AUDIO_BANK
ENDIF


\* Unpack splash screen into DHires page 1

 jsr unpacksplash

\* Show DHires page 1

\ jsr setdhires

\* Copy to DHires page 2

 jsr copy1to2

IF _AUDIO
    lda #s_Presents
    jsr BEEB_INTROSONG
ENDIF

 lda #44/4
 jsr tpause

\* Unpack "Broderbund Presents" onto page 1

\ lda #delPresents
\ jsr DeltaExpPop

 MASTER_LOAD_DHIRES presents_filename, pu_presents_size



\ ldx #80
\ lda #s_Presents
\ jsr master_PlaySongI


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

\ lda PAGE2on

\* Copy DHires page 2 back to hidden page 1

\ jsr copy2to1

\* Display page 1

\ lda PAGE2off

\ Not needed on Beeb as just load the whole lower half of the screen

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
 lda #42/4
 jsr tpause

\* Unpack byline onto page 1

\ lda #delByline
\ jsr DeltaExpPop

 MASTER_LOAD_DHIRES byline_filename, pu_byline_size

\ ldx #80
\ lda #s_Byline
\ jsr master_PlaySongI

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
IF _AUDIO
    ; SM: added title music load & play trigger here
    ; load title audio bank
    lda #0
    jsr BEEB_LOAD_AUDIO_BANK
ENDIF

; jsr unpacksplash

\ Construct the title page without showing it

 LDX #LO(splash_filename)
 LDY #HI(splash_filename)
 LDA #HI(pu_splash_loadat)
 JSR disksys_load_file

 LDA #PUCRUNCH_BANK:JSR swr_select_slot
 LDX #LO(pu_splash_loadat + 6)
 LDY #HI(pu_splash_loadat + 6)
 JSR PUCRUNCH_UNPACK

 LDX #LO(title_filename)
 LDY #HI(title_filename)
 LDA #HI(pu_title_loadat)
 JSR disksys_load_file

 LDA #PUCRUNCH_BANK:JSR swr_select_slot
 LDX #LO(pu_title_loadat + 6)
 LDY #HI(pu_title_loadat + 6)
 JSR PUCRUNCH_UNPACK

 JSR beeb_clear_dhires_line

\ Now wipe to reveal

 JSR beeb_dhires_wipe

; jsr copy1to2

 lda #20/4
 jsr tpause

\ lda #delTitle
\ jsr DeltaExpPop
 
; MASTER_LOAD_DHIRES title_filename, 12

IF _AUDIO
    lda #s_Title
    jsr BEEB_INTROSONG
ENDIF

 lda #160/4
 jmp tpause
}

\*-------------------------------

.TitleScreen
{
 lda #38/4
 jsr tpause

\* Unpack title onto page 1

\ lda #delTitle
\ jsr DeltaExpPop

 MASTER_LOAD_DHIRES title_filename, pu_title_size

IF _AUDIO
    lda #s_Title
    jsr BEEB_INTROSONG
ENDIF

\ ldx #140
\ lda #s_Title
\ jsr master_PlaySongI

; SM: added this to give music chance to play out
 lda #120/4
 jmp tpause

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

 MASTER_WIPE_DHIRES prolog_filename, pu_prolog_size

\ ldx #250
\ lda #s_Prolog
\ jmp master_PlaySongI

 lda #30
 jmp tpause

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

\ jsr ReloadStuff ;wiped out by dhires titles

 lda #0 ;don't seek track 0
 jsr cutprincess1

IF _AUDIO
    ; SM: added intro music load & play trigger here
    ; BEEB TEMP - this should really be done in subs_PlaySongI
    lda #s_Princess
    jsr BEEB_INTROSONG
ENDIF

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

 MASTER_LOAD_DHIRES sumup_filename, pu_sumup_size

\ ldx #250
\ lda #s_Sumup
\ jmp master_PlaySongI

 RTS
}


\*-------------------------------
\*
\*  Beeb credits
\*
\*-------------------------------

.credits_filename
EQUS "CREDITS$"

.BeebCredit
{
 MASTER_WIPE_DHIRES credits_filename, pu_credits_size

 lda #30
 jmp tpause

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

\ BEEB set drive 0 - going to attract after this anyway
 LDA #0
 JSR disksys_set_drive

IF _AUDIO
    ; SM: added title music load & play trigger here
    ; load title audio bank
    lda #0              ; BEEB TODO not correct bank!
    jsr BEEB_LOAD_AUDIO_BANK
ENDIF

 jsr SetupDHires

 MASTER_LOAD_DHIRES epilog_filename, pu_epilog_size

 lda #s_Epilog
 jsr BEEB_INTROSONG
 lda #15
 jsr pauseNI
 jsr unpacksplash
 lda #75
 jsr pauseNI

 lda #s_Curtain
 jsr BEEB_INTROSONG
 lda #60
 jsr pauseNI

 jmp blackout
}

.splash_filename
EQUS "SPLASH $"

.unpacksplash
{
 MASTER_LOAD_DHIRES splash_filename, pu_splash_size

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

IF _AUDIO
    ; SM: hacked in game audio bank load here
    lda #3
    jsr BEEB_LOAD_AUDIO_BANK
ENDIF

\ NOT BEEB
\ jsr LoadStage3

 JSR loadbank1

\ BEEB set game screen mode (hires)
 JSR beeb_set_game_screen

 jsr setdemolevel

\ This gets loaded anyway at level load?
\ jsr rdbluep

\ jsr driveoff

\ BEEB AUDIO

 JSR audio_update_on

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

IF _AUDIO
    ; SM: hacked in game audio bank load here
    lda #3
    jsr BEEB_LOAD_AUDIO_BANK
ENDIF

\* Turn on drive & load Stage 3 routines

\ NOT BEEB
\:1 jsr LoadStage3

 JSR loadbank1

\ BEEB set game screen mode (hires)
 JSR beeb_set_game_screen

\* Load 1st level

 jsr set1stlevel

\ This gets loaded anyway at level load?
\ jsr rdbluep

\* Turn off drive & set aux

\ NOT BEEB
\ jsr driveoff

\* Go to TOPCTRL

 lda #1
 sta musicon

 \ BEEB - should probably reconcile with above
 JSR audio_update_on

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
IF _DEBUG
 LDA #_START_LEVEL
ELSE
 lda #1
ENDIF
 jmp start
}

\*-------------------------------
\*
\* Load permanent code & data
\* (only once)
\*
\*-------------------------------

.bank1_filename
EQUS "BANK1  $"

.perm_file_names
;EQUS "CHTAB1 $"
;EQUS "CHTAB2 $"
;EQUS "CHTAB3 $"
EQUS "CHTAB5 $"

.loadbank1
{
    \ Start with CHTAB1 + 3
    lda #BEEB_SWRAM_SLOT_CHTAB1
    jsr swr_select_slot

    LDX #LO(bank1_filename)
    LDY #HI(bank1_filename)
    LDA #HI(chtable1)
    JSR disksys_load_file

    \ Relocate the IMG file
    LDA #LO(chtable1)
    STA beeb_readptr
    LDA #HI(chtable1)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    \ Relocate the IMG file
    LDA #LO(chtable2)
    STA beeb_readptr
    LDA #HI(chtable2)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    \ Relocate the IMG file
    LDA #LO(chtable3)
    STA beeb_readptr
    LDA #HI(chtable3)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img


    lda #BEEB_SWRAM_SLOT_CHTAB5
    jsr swr_select_slot

    \ index into table for filename
    LDX #LO(perm_file_names)
    LDY #HI(perm_file_names)
    LDA #HI(chtable5)
    JSR disksys_load_file

    \ Relocate the IMG file
    LDA #LO(chtable5)
    STA beeb_readptr
    LDA #HI(chtable5)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    .return
    RTS
}

IF _NOT_BEEB
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
\*  Load stage 2 routines (side B)
\*
\*-------------------------------
\LoadStage2B
\ jsr driveon
\
\ lda #24
\ bne ]ls2

.chtab8_file_name
EQUS "CHTAB8 $"

.chtab9_file_name
EQUS "CHTAB9 $"

.LoadStage2_Attract
{
IF _AUDIO
    ; SM: added intro music load & play trigger here
    lda #1
    jsr BEEB_LOAD_AUDIO_BANK
ENDIF

    lda #BEEB_SWRAM_SLOT_CHTAB9
    jsr swr_select_slot

    \ CHTAB9 (aka CHTAB6.A.B)

    lda #HI(chtable9)
    ldx #LO(chtab9_file_name)
    ldy #HI(chtab9_file_name)
    jsr disksys_load_file

    \ Relocate the IMG file
    LDA #LO(chtable9)
    STA beeb_readptr
    LDA #HI(chtable9)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    lda #BEEB_SWRAM_SLOT_CHTAB678
    jsr swr_select_slot

    \ CHTAB7

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
}
\\ Fall through!
.loadch8
{
    \ CHTAB8 (aka CHTAB6.A.A)

    lda #HI(chtable8)
    ldx #LO(chtab8_file_name)
    ldy #HI(chtab8_file_name)
    jsr disksys_load_file

    \ Relocate the IMG file
    LDA #LO(chtable8)
    STA beeb_readptr
    LDA #HI(chtable8)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    RTS
}

.LoadStage2
{
    TAX

    \\ Invalidate catalog cache
    LDA #0
    JSR disksys_set_drive

    \\ Invalidate bg cache
    LDA #&ff
    sta CHset
    sta BGset1
    sta BGset2

    \\ This is cutscene so we know what to load
    CPX #0
    BNE in_game

    JMP LoadStage2_Attract

    .in_game
IF _AUDIO
    ; SM: added intro music load & play trigger here
    lda #4
    jsr BEEB_LOAD_AUDIO_BANK
ENDIF

    LDA #2
    JSR disksys_set_drive

    \\ Need to switch CHTAB6 or CHTAB8 depending on level

    lda #BEEB_SWRAM_SLOT_CHTAB678
    jsr swr_select_slot

    LDX level
    CPX #3
    BCS later_cutscenes

    JMP loadch8     ; just the level 1-2 interstitial

    .later_cutscenes
    lda #HI(chtable6)
    ldx #LO(chtab6_file_name)
    ldy #HI(chtab6_file_name)
    jsr disksys_load_file

    \ Relocate the IMG file
    LDA #LO(chtable6)
    STA beeb_readptr
    LDA #HI(chtable6)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    RTS
}

.chtab6_file_name
EQUS "CHTAB6 $"

.chtab7_file_name
EQUS "CHTAB7 $"

IF _NOT_BEEB
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

IF _NOT_BEEB
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
    JMP beeb_hide_screen
}

\*-------------------------------
\* Save current game to disk
\*
\* In: SavLevel = level ($ff to erase saved game)
\*-------------------------------

.SavError EQUB 0

\ Moved from gameeq.h.asm
.savedgame

.SavLevel EQUB 0
.SavStrength EQUB 0
.SavMaxed EQUB 0
.SavTimer EQUW 0
EQUB 0
.SavNextMsg EQUB 0

.savedgame_top

.DOSAVEGAME
{
\\ NOT BEEB
\ lda level
\ cmp #FirstSideB
\ bcs :doit ;must have reached side B
\ lda #Splat
\ jmp addsound
\:doit

\* Put data into save-game data area

 lda origstrength
 sta SavStrength

 lda FrameCount
 sta SavTimer
 lda FrameCount+1
 sta SavTimer+1

 lda NextTimeMsg
 sta SavNextMsg

\* Write to disk

 jmp savegame
}

\*-------------------------------
; Relocate image tables
\*-------------------------------

.beeb_plot_reloc_img
    LDY #0
    LDA (beeb_readptr), Y
    TAX

    \\ Relocate pointers to image data
.beeb_plot_reloc_img_loop
{
    INY

    CLC
    LDA (beeb_readptr), Y
    ADC beeb_readptr
    STA (beeb_readptr), Y

    INY
    LDA (beeb_readptr), Y
    ADC beeb_readptr+1
    STA (beeb_readptr), Y

    DEX
    BPL beeb_plot_reloc_img_loop
    RTS
}
