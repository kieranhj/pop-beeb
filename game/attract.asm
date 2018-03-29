; attract.asm
; Moved all attract mode sequence to separate module

.attract_start

\*-------------------------------
\* Sequence MACROS
\*-------------------------------

MACRO MASTER_LOAD_DHIRES filename, pu_size, atrow
{
 LDX #LO(filename)
 LDY #HI(filename)
 LDA #HI(&8000 - pu_size)
 JSR disksys_load_file

 LDX #LO(&8000 - pu_size)
 LDY #HI(&8000 - pu_size)
 LDA #HI(beeb_double_hires_addr + atrow * BEEB_SCREEN_ROW_BYTES)
 JSR PUCRUNCH_UNPACK

 JSR beeb_clear_dhires_line

IF _DEMO_BUILD
 JSR plot_demo_url
ENDIF
}
ENDMACRO

MACRO MASTER_SHOW_DHIRES sequence_time
{
 LDX #LO(sequence_time)
 LDY #HI(sequence_time)
 JSR master_show_dhires
}
ENDMACRO

MACRO MASTER_WIPE_DHIRES sequence_time
{
 LDX #LO(sequence_time)
 LDY #HI(sequence_time)
 JSR wait_for_timer_XY
 JSR beeb_dhires_wipe
}
ENDMACRO

MACRO MASTER_BLOCK_UNTIL sequence_time
{
 LDX #LO(sequence_time)
 LDY #HI(sequence_time)
 JSR wait_for_timer_XY
}
ENDMACRO

.master_show_dhires
{
 JSR wait_for_timer_XY
 JSR vblank
 JSR PageFlip
 JMP beeb_show_screen       ; in case previous blackout
}

\*-------------------------------
\* Demo watermark
\*-------------------------------

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
\*
\* Set up double hi-res
\*
\*-------------------------------
.SetupDHires
{
\* Show black lo-res scrn

 jsr blackout

\* Configure screen for attract mode

 JMP beeb_set_attract_screen
}

\*-------------------------------
\*
\* "Broderbund Software Presents"
\*
\*-------------------------------

.ATTRACT_PART_ONE       ; aka PubCredit
{
 jsr SetupDHires

IF _AUDIO
    ; SM: added title music load & play trigger here
    ; load title audio bank
    lda #0
    jsr BEEB_LOAD_AUDIO_BANK
ENDIF

\* Unpack splash screen into DHires page 1

 MASTER_LOAD_DHIRES splash_filename, pu_splash_size, 0

\* Start the main tune!

IF _AUDIO
    lda #s_Presents
    jsr BEEB_INTROSONG
ENDIF

 MASTER_SHOW_DHIRES 0

\* Start our sequence timer

 JSR vsync_start_timer

\* Copy to DHires page 2 so can load to this and swap when required

 jsr copy1to2

\* Unpack "Broderbund Presents" onto page 2

 MASTER_LOAD_DHIRES presents_filename, pu_presents_size, 12
 
\* Show the presents screen at 0:02.00

 MASTER_SHOW_DHIRES 2.5*50

\* Rest of sequence moved here

 jsr AuthorCredit
 
 \* Show the byline at 0:07.00

 MASTER_SHOW_DHIRES 7.5*50

 jsr TitleScreen
 
 \* Show title at 0:15.00

 MASTER_SHOW_DHIRES 15.5*50

\* Play next tune (Apple II only)

IF _AUDIO
    lda #s_Title
    jsr BEEB_INTROSONG
ENDIF

 jsr Prolog1

\ Wait here before going to cutscene

 MASTER_BLOCK_UNTIL 34*50

 RTS
}

\*-------------------------------
\*
\* "A Game by Jordan Mechner"
\*
\*-------------------------------

.AuthorCredit
{
\* Unpack byline onto page 1

 MASTER_LOAD_DHIRES byline_filename, pu_byline_size, 12

 RTS
}

\*-------------------------------
\*
\* "Prince of Persia"
\*
\*-------------------------------

CUTSCENE_END_TIME=49.85*50
CREDITS_SHOW_TIME=5*50

.SilentTitle
{
IF _AUDIO
    ; SM: added title music load & play trigger here
    ; load title audio bank
    lda #0
    jsr BEEB_LOAD_AUDIO_BANK
ENDIF

\* Construct the title page & logo without showing it

 MASTER_LOAD_DHIRES splash_filename, pu_splash_size, 0

\* Add the title

 MASTER_LOAD_DHIRES title_filename, pu_title_size, 12

\* Now wipe to reveal when music finishes (could test explicitly?)

 MASTER_WIPE_DHIRES (CUTSCENE_END_TIME + 12*50)

 RTS
}

\*-------------------------------

.TitleScreen
{
\* Unpack title onto page 1

 MASTER_LOAD_DHIRES title_filename, pu_title_size, 12

 RTS
}

\*-------------------------------
\*
\*  Prologue, part 1
\*
\*-------------------------------

.Prolog1
{
 MASTER_LOAD_DHIRES prolog_filename, pu_prolog_size, 0
 
 MASTER_WIPE_DHIRES 25*50

IF _AUDIO
    lda #s_Prolog
    jsr BEEB_INTROSONG
ENDIF

 RTS
}

\*-------------------------------
\*
\*  Prologue, part 2
\*
\*-------------------------------

.ATTRACT_PART_TWO       ; aka Prolog2
{
 jsr SetupDHires

\* Load and display Prolog immediately

 MASTER_LOAD_DHIRES sumup_filename, pu_sumup_size, 0
 MASTER_SHOW_DHIRES 0

\* But wait to trigger additional music piece

 MASTER_BLOCK_UNTIL CUTSCENE_END_TIME

 lda #s_Sumup
 jsr BEEB_INTROSONG

\* Move rest of part two here

 jsr SilentTitle

 jsr BeebCredit

\* Wipe after title been on for 4 seconds

 MASTER_WIPE_DHIRES (CUTSCENE_END_TIME + 12*50 + CREDITS_SHOW_TIME)

\* Show Credits for 4 seconds

 MASTER_BLOCK_UNTIL (CUTSCENE_END_TIME + 12*50 + 2*CREDITS_SHOW_TIME)

 RTS
}

\*-------------------------------
\*
\*  Beeb credits
\*
\*-------------------------------

.BeebCredit
{
\* Load Credits screen

 MASTER_LOAD_DHIRES credits_filename, pu_credits_size, 0

 RTS
}

\*-------------------------------
\*
\* Epilog
\*
\*-------------------------------

.ATTRACT_EPILOG
{
\ BEEB set drive 0 - going to attract after this anyway
\ LDA #0
\ JSR disksys_set_drive

    \\ Invalidate bg cache
    LDA #&ff
    sta CHset
    sta BGset1
    sta BGset2

 jsr SetupDHires

\* Load the screen

 MASTER_LOAD_DHIRES epilog_filename, pu_epilog_size, 0

\* Start the music

 lda #s_Epilog
 jsr BEEB_EPILOGSONG

\* Hack wait fn to ignore keys

    LDA #&2C        ; BIT abs
    STA smWait_for_timer_loop

\* Show the screen

 MASTER_SHOW_DHIRES 0 

\* Start the sequence timer

 JSR vsync_start_timer

\* Show the splash after 30 secs

 MASTER_LOAD_DHIRES splash_filename, pu_splash_size, 0
 MASTER_SHOW_DHIRES 30*50

 jsr copy1to2

\* Show the title after another X secs

 jsr TitleScreen
 MASTER_WIPE_DHIRES 50*50

\* Show the Jordan credit after another X secs

 jsr AuthorCredit
 MASTER_WIPE_DHIRES 70*50

\* Show our credits after another X secs

 jsr BeebCredit
 MASTER_WIPE_DHIRES 90*50

 MASTER_BLOCK_UNTIL 116*50
 jsr blackout           ; oh for a fade

\* Wait for some time (tbc) or just the end of the tune :)

 JSR wait_for_music_to_end

\* Undo hack

    LDA #&20        ; JSR abs
    STA smWait_for_timer_loop

 jmp blackout
}

\*-------------------------------
\*
\* Wait functions for attract sequence
\*
\*-------------------------------

.wait_for_timer_XY
    STY smWait_for_timer_Ticks_HI+1
    STX smWait_for_timer_Ticks_LO+1

    .smWait_for_timer_loop
    JSR master_StartGame

    LDA vsync_timer_ticks+1
    .smWait_for_timer_Ticks_HI
    CMP #&FF
    BCC smWait_for_timer_loop

    LDA vsync_timer_ticks+0
    .smWait_for_timer_Ticks_LO
    CMP #&FF
    BCC smWait_for_timer_loop

    RTS

.attract_end
