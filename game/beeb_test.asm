; beeb_test.asm
; Beeb routines to test sprite plotting etc.

.beeb_test_start

\*-------------------------------
; Test code
\*-------------------------------

IF 0
.beeb_test_load_all_levels
{
    \\ Level load & plot test
    LDX #1

    .level_loop
    STX level
    JSR LoadLevelX

    LDX #1
    STX VisScrn

    .scrn_loop
    JSR getscrns
    JSR DoSure

\ Wait 1 second for keypress

    ldx#100:ldy#0:lda#&81:jsr osbyte	

    LDX VisScrn
    INX
    CPX #25
    STX VisScrn
    BNE scrn_loop

    LDX level
    INX
    CPX #15
    BNE level_loop
    RTS
}
ENDIF

IF 0
.beeb_test_sprite_plot
{
    JSR loadperm

\\    LDX #1
\\    STX level
\\    JSR LoadLevelX

    LDA #0
    JSR LoadStage2

\\    JSR beeb_shadow_select_main

    JSR vblank

    JSR beeb_set_mode2_no_clear
    JSR beeb_set_game_screen
    JSR beeb_show_screen

    JSR vblank

    LDA #1
    STA beeb_sprite_no

    LDA #0
    STA OFFSET

    LDA #0
    STA LEFTCUT
    STA TOPCUT
    LDA #40
    STA RIGHTCUT
    LDA #192
    STA BOTCUT


    .sprite_loop
    LDA beeb_sprite_no
    ASL A:ASL A
    AND #&1F

    LDA #LO(1)
    STA XCO

    LDA #127
    STA YCO

    LDA beeb_sprite_no
    STA IMAGE

    LDA #LO(chtable7)
    STA TABLE

    LDA #HI(chtable7)
    STA TABLE+1

    LDA #BEEB_SWRAM_SLOT_CHTAB678
    STA BANK

    LDA #enum_mask OR &80
    STA OPACITY

    JSR beeb_plot_sprite_LAY

    ldx#100:ldy#0:lda#&81:jsr osbyte	

    LDX OFFSET
    INX
    STX OFFSET
    CPX #7
    BCC sprite_loop

    LDX #0
    STX OFFSET    

    LDX beeb_sprite_no
    INX
    CPX #128
    BCS finished
    STX beeb_sprite_no
    JMP sprite_loop

    .finished
    RTS
}
ENDIF

.beeb_test_end
