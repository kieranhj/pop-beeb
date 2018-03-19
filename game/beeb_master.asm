; beeb_master.asm
; Actually routines used to support Beeb implementation of master.asm
; Not necessary routines that are specific to the BBC Master
; Although some might be!!
;
; Might as well sit in SWRAM rather than CORE as only used in Attract

.beeb_master_start

\*-------------------------------
; Copy SHADOW
; A=Start address PAGE
\*-------------------------------

.BEEB_COPY_SHADOW
{
    STA smRead+2
    STA smWrite+2

    LDX #0
    
    .next_page
    \\ Read from visible screen
    LDA &FE34:EOR #&4:STA &FE34

    .read_page_loop
    .smRead
    LDA &FF00, X
    STA DISKSYS_BUFFER_ADDR, X
    INX
    BNE read_page_loop

    \\ Copy to alternate screen
    LDA &FE34:EOR #&4:STA &FE34

    .write_page_loop
    LDA DISKSYS_BUFFER_ADDR, X
    .smWrite
    STA &FF00, X
    INX
    BNE write_page_loop

    INC smRead+2
    INC smWrite+2

    BPL next_page

    RTS
}

\*-------------------------------
; Hide & Show Screen
\*-------------------------------

.BEEB_HIDE_SCREEN
{
    LDX #LO(crtc_regs_hide_screen)
    LDY #HI(crtc_regs_hide_screen)
    JMP beeb_set_crtc_regs
}

.BEEB_SHOW_SCREEN
{
    LDX #LO(crtc_regs_show_screen)
    LDY #HI(crtc_regs_show_screen)
    JMP beeb_set_crtc_regs
}

\*-------------------------------
; Set game or attract screen resolution etc.
\*-------------------------------

\\ Just set CRTC registers we care about for game vs attract mode

.BEEB_SET_GAME_SCREEN
{
    LDX #LO(crtc_regs_game_screen)
    LDY #HI(crtc_regs_game_screen)
    JMP beeb_set_crtc_regs
}

.BEEB_SET_ATTRACT_SCREEN
{
    LDX #LO(crtc_regs_attract_screen)
    LDY #HI(crtc_regs_attract_screen)
    JMP beeb_set_crtc_regs
}

.beeb_set_crtc_regs
{
    STX beeb_readptr
    STY beeb_readptr+1

    LDY #0
    .loop
    LDA (beeb_readptr), Y
    BMI return
    STA &FE00
    INY
    LDA (beeb_readptr), Y
    STA &FE01
    INY
    BNE loop

    .return
    RTS 
}

.crtc_regs_hide_screen
{
    EQUB 8, &30                     ; R8 = interlace
    EQUB &FF
}

.crtc_regs_show_screen
{
    EQUB 8, &00                     ; R8 = interlace
    EQUB &FF
}

.crtc_regs_game_screen
{
IF BEEB_SCREEN_CHARS<>80
    EQUB 1, BEEB_SCREEN_CHARS         ; R1 = horizontal displayed
ENDIF
    EQUB 6, BEEB_SCREEN_ROWS          ; R6 = vertical displayed
    EQUB 7, BEEB_SCREEN_VPOS          ; R7 = vertical position
    EQUB 12, HI(beeb_screen_addr/8)   ; R12 = screen start address, high
    EQUB 13, LO(beeb_screen_addr/8)   ; R13 = screen start address, low
    EQUB &FF
}

.crtc_regs_attract_screen
{
    EQUB 6, BEEB_DOUBLE_HIRES_ROWS          ; R6 = vertical displayed
    EQUB 7, BEEB_DOUBLE_HIRES_VPOS          ; R7 = vertical position
    EQUB 12, HI(beeb_double_hires_addr/8)   ; R12 = screen start address, high
    EQUB 13, LO(beeb_double_hires_addr/8)   ; R13 = screen start address, low
    EQUB &FF
}

.beeb_master_end
