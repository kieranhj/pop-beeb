; beeb-plot-wipe
; BBC Micro plot functions
; Specialisations of wipe permutations

\*-------------------------------
\*
\*  F A S T B L A C K
\*
\*  Wipe a rectangular area to black2
\*
\*  Width/height passed in IMAGE/IMAGE+1
\*  (width in bytes, height in pixels)
\*
\*-------------------------------

.beeb_plot_wipe_start

IF _UNROLL_WIPE

.beeb_plot_wipe
{
    LDY YCO
    LDX XCO

    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16_HI,X
    ADC YHI,Y
    STA beeb_writeptr+1
    
    \\ Jump to function
IF _DEBUG
    LDX width
    CPX #4
    BEQ width_ok
    BRK
.width_ok
ENDIF
}
\\ Fall through!
.beeb_plot_wipe_4bytes   ; 34 Apple bytes = 8 Beeb bytes
    LDX height

.beeb_plot_wipe_y_loop
{
    LDA #0

    LDY #0
    STA (beeb_writeptr), Y

    LDY #8
    STA (beeb_writeptr), Y

    LDY #16
    STA (beeb_writeptr), Y

    LDY #24
    STA (beeb_writeptr), Y

    LDY #32
    STA (beeb_writeptr), Y

    LDY #40
    STA (beeb_writeptr), Y

    LDY #48
    STA (beeb_writeptr), Y

    LDY #56
    STA (beeb_writeptr), Y

    DEX
    BEQ beeb_plot_wipe_done_y
}

    LDA beeb_writeptr
    AND #&07

.beeb_plot_wipe_smCMP
    CMP #&00
    BEQ beeb_plot_wipe_smSEC

.beeb_plot_wipe_smDEC
    DEC beeb_writeptr
    BRA beeb_plot_wipe_y_loop

.beeb_plot_wipe_smSEC
    SEC
    LDA beeb_writeptr
.beeb_plot_wipe_smSBC1
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
.beeb_plot_wipe_smSBC2
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    BRA beeb_plot_wipe_y_loop

.beeb_plot_wipe_done_y
    RTS    

ENDIF

.beeb_plot_wipe_end
