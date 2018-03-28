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

\*-------------------------------
\* Local vars

\dum locals
\ Now defined in master.h.asm

\*-------------------------------
\* Music song #s
\ Moved to soundnames.h.asm

.title_filename     EQUS "TITLE  $"
.prolog_filename    EQUS "PROLOG $"
.sumup_filename     EQUS "SUMUP  $"
.credits_filename   EQUS "CREDITS$"
.epilog_filename    EQUS "EPILOG $"

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

    LDA SavLevel
    BPL go_mainloop
    STX SavLevel
    STZ SavError
    JMP ResumeGame_ReEnter  ; if loading

    .go_mainloop        ; if saving
    STX SavError        ; flag error
    STZ SavLevel        ; clear save flag
    JMP MainLoop        ; re-enter game (and keep fingers crossed)

    \\ We weren't saving so display crash message
    .not_trying_to_save

    \\ Firstly try and show the screen in case not visible
    LDA #8:STA &FE00:LDA #0:STA &FE01

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

\ NOT BEEB
\ jsr driveon

 jsr rdbluep ;blueprint
 jsr rdbg1 ;bg set 1
 jsr rdbg2 ;bg set 2
 jsr rdch4 ;char set 4

IF _AUDIO
    lda #3
    jsr BEEB_LOAD_AUDIO_BANK
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

;.bgset1_to_name
;EQUS "DUN1X  $"
;EQUS "PAL1X  $"
\EQUS "DUN1X  $"         ; bgset1=$02 just means side A/B of original disc
.bgset1_to_id
EQUB f_DUN1A, f_PAL1A

.rdbg1
{
    ldx newBGset1
    cpx BGset1
    beq return
    stx BGset1

    \ Now need to load 2x blocks for BGTAB1

    \ Set BANK for B
    lda #BEEB_SWRAM_SLOT_BGTAB1_B
    jsr swr_select_slot

    \ Load file B
    LDY BGset1
    LDX bgset1_to_id, Y
    INX
    lda #HI(bgtable1b)
    jsr disksys_load_sprite

    \ Relocate the IMG file
    LDA #LO(bgtable1b)
    STA beeb_readptr
    LDA #HI(bgtable1b)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img


    \ Set BANK for A
    lda #BEEB_SWRAM_SLOT_BGTAB1_A
    jsr swr_select_slot

    \ Load file B
    LDY BGset1
    LDX bgset1_to_id, Y
    lda #HI(bgtable1a)
    jsr disksys_load_sprite

    \ Relocate the IMG file
    LDA #LO(bgtable1a)
    STA beeb_readptr
    LDA #HI(bgtable1a)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    .return
    rts
}

;.bgset2_to_name
;EQUS "DUN2   $"
;EQUS "PAL2   $"
\EQUS "DUN2   $"            ; $02 just meant side B of original disc
.bgset2_to_id
EQUB f_DUN2, f_PAL2

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
    LDY BGset2
    LDX bgset2_to_id, Y
    lda #HI(bgtable2)
    jsr disksys_load_sprite

    \ Relocate the IMG file
    LDA #LO(bgtable2)
    STA beeb_readptr
    LDA #HI(bgtable2)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    .return
    rts
}

;.chset_to_name
;EQUS "GD     $"
;EQUS "SKEL   $"
;EQUS "GD     $"
;EQUS "FAT    $"
;EQUS "SHAD   $"
;EQUS "VIZ    $"
.chset_to_id
EQUB f_GD, f_SKEL, f_GD, f_FAT, f_SHAD, f_VIZ

.rdch4
{
    \ Merge guard type with level type
    lda newBGset1
    CLC:ROR A:ROR A
    ora newCHset

    cmp CHset
    beq return
    sta CHset

    \ Load sprite bank for guard
    lda #BEEB_SWRAM_SLOT_CHTAB4
    jsr swr_select_slot

    lda CHset
    and #&f
    tay
    ldx chset_to_id, y
    lda #HI(chtable4)
    jsr disksys_load_sprite

    \ Relocate the IMG file
    LDA #LO(chtable4)
    STA beeb_readptr
    LDA #HI(chtable4)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    \ Check if this is a Palace guard
    {
        LDA CHset
        BPL keep_pal

        \ Swap Guard outfit
        LDA #PAL_BMY
        LDX #PAL_BMW
        JSR beeb_plot_swap_pal

        \ Swap Guard blood...
        LDA #PAL_BRY
        LDX #PAL_BRW
        JSR beeb_plot_swap_pal
        .keep_pal
    }

    .return
    rts
}

\*-------------------------------
\*
\* read blueprint
\*
\*-------------------------------

;.beeb_level_filename   EQUS "LEVEL0 $"

.rdbluep
{
IF 0
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
ELSE
    JMP disksys_load_level
ENDIF
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

\* Reset the sequence timer

 JSR vsync_start_timer      ; reset the timer to zero

\* Play the cutscene

 lda #0 ;cut #0 (intro)
 jmp playcut ;Apple II was xplaycut aux l.c. via grafix
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

.wait_for_music_to_end
{
 JSR BEEB_MUSIC_IS_PLAYING
 BNE wait_for_music_to_end
 RTS
}

.pacRoom_name
EQUS "PRIN2  $"

pacRoom_size = &1100        ; by hand doh!

.CUTPRINCESS
{
 jsr blackout
 lda #1 ;seek track 0
}
.cutprincess1
{
 jsr LoadStage2 ;displaces bgtab1-2, chtab4

\ Need game screen dimensions

 JSR beeb_set_game_screen

\ Load Princess screen image
\ And MODE2 PLOT overlay

 LDX #LO(pacRoom_name)
 LDY #HI(pacRoom_name)
 LDA #HI(&8000 - pacRoom_size)
 JSR disksys_load_file

 LDA #HI(PRIN2_START)
 LDX #LO(&8000 - pacRoom_size)
 LDY #HI(&8000 - pacRoom_size)
 JSR PUCRUNCH_UNPACK

 JSR beeb_clear_status_line

\ Flip the screen buffers

 JSR vblank
 JSR PageFlip

\ Copy the screen buffers

 LDA #HI(PRIN2_START)
 JSR beeb_copy_shadow

\* Wait for music to stop in case we're on a fast device

 JSR wait_for_music_to_end

\ Display screen

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

IF _AUDIO
    ; SM: added title music load here
    jsr BEEB_LOAD_EPILOG_BANK
ENDIF

 jsr attract_epilog

    \ Could wait for keypress here... same as Apple II
    \ But they've probably waited long enough if listen to 2 minute tune
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
\ LDA #0
\ JSR disksys_set_drive

 lda #1
 sta musicon

\ Part one (PubCredit, AuthorCredit, TitleScreen, Prolog1)

 JSR attract_part_one

\ Sequence timer reset after Princess scene has loaded

 jsr PrincessScene

\ Part one (Prolog2, SilentTitle, BeebCredit)

 JSR attract_part_two

\ Go to demo
\ jmp Demo
}
\ Just fall through!

\*-------------------------------
\*
\*  Demo sequence
\*
\*-------------------------------

.Demo
{
 jsr blackout

 JSR vsync_stop_timer

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

\ BEEB AUDIO

 JSR audio_update_on

\* Go to TOPCTRL

 lda #0
 jmp start
}

\*-------------------------------
\* non-interruptible pause

IF _NOT_BEEB
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
ENDIF

.pauseNI        ; X=seconds
{
    LDY #0

    .seconds_loop

    LDA beeb_vsync_count
    .wait_for_vsync
    CMP beeb_vsync_count
    BEQ wait_for_vsync

    INY
    CPY #50
    BCC not_a_second

    LDY #0
    DEX
    .not_a_second

    CPX #0
    BNE seconds_loop
}
.return_61
    RTS

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

 JSR vsync_stop_timer

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

;.perm_file_names
;EQUS "CHTAB5 $"

.loadbank1
{
    \ Start with CHTAB1 + 3
    lda #BEEB_SWRAM_SLOT_CHTAB1
    jsr swr_select_slot

    LDX #LO(bank1_filename)
    LDY #HI(bank1_filename)
    LDA #HI(chtable1)
    JSR disksys_decrunch_file

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
    LDX #f_CHTAB5
    LDA #HI(chtable5)
    JSR disksys_load_sprite

    \ Relocate the IMG file
    LDA #LO(chtable5)
    STA beeb_readptr
    LDA #HI(chtable5)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    .return
    RTS
}

\*-------------------------------
\*
\*  Load stage 2 routines (side B)
\*
\*-------------------------------

;.chtab8_file_name
;EQUS "CHTAB8 $"

;.chtab9_file_name
;EQUS "CHTAB9 $"

.LoadStage2_Attract
{
IF _AUDIO
    ; SM: added intro music load & play trigger here
    jsr BEEB_LOAD_STORY_BANK
ENDIF

    \ Now load sprite banks

    lda #BEEB_SWRAM_SLOT_CHTAB9
    jsr swr_select_slot

    \ CHTAB9 (aka CHTAB6.A.B)

    LDX #f_CHTAB9
    LDA #HI(chtable9)
    JSR disksys_load_sprite

    \ Relocate the IMG file
    LDA #LO(chtable9)
    STA beeb_readptr
    LDA #HI(chtable9)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    lda #BEEB_SWRAM_SLOT_CHTAB678
    jsr swr_select_slot

    \ CHTAB7

    LDX #f_CHTAB7
    LDA #HI(chtable7)
    JSR disksys_load_sprite

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

    LDX #f_CHTAB8
    LDA #HI(chtable8)
    JSR disksys_load_sprite

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
\    LDA #0
\    JSR disksys_set_drive

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
\    LDA #2
\    JSR disksys_set_drive

IF _AUDIO
    ; SM: added intro music load & play trigger here
    lda #4
    jsr BEEB_LOAD_AUDIO_BANK
ENDIF

    \\ Need to switch CHTAB6 or CHTAB8 depending on level

    lda #BEEB_SWRAM_SLOT_CHTAB678
    jsr swr_select_slot

    LDX level
    CPX #3
    BCS later_cutscenes

    JMP loadch8     ; just the level 1-2 interstitial

    .later_cutscenes
    LDX #f_CHTAB6
    LDA #HI(chtable6)
    JSR disksys_load_sprite

    \ Relocate the IMG file
    LDA #LO(chtable6)
    STA beeb_readptr
    LDA #HI(chtable6)
    STA beeb_readptr+1
    JSR beeb_plot_reloc_img

    RTS
}

;.chtab6_file_name
;EQUS "CHTAB6 $"

;.chtab7_file_name
;EQUS "CHTAB7 $"

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

; Swap palette# in A for X
.beeb_plot_swap_pal
{
    STA beeb_temp
    STX beeb_data

    \ Get number of images
    LDY #0
    LDA (beeb_readptr), Y
    TAX

    \ For each image
    .loop

    \ Get pointer to sprite data
    INY
    LDA (beeb_readptr), Y
    STA beeb_writeptr

    INY
    LDA (beeb_readptr), Y
    STA beeb_writeptr+1

    PHY

    \ Pull out byte 2 (PALETTE)
    LDY #2
    LDA (beeb_writeptr), Y
    CMP beeb_temp
    BNE next_one

    \ Replace with our new data if there's a match
    LDA beeb_data
    STA (beeb_writeptr), Y

    .next_one
    PLY
    DEX
    BNE loop
    RTS
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
  LDA pop_beeb_build+4
  JMP beeb_plot_font_bcd
}
