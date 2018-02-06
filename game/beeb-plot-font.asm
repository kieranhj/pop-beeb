; beeb-plot-font
; BBC Micro plot functions
; Font data only

.beeb_plot_font_start

.beeb_plot_font_prep
{
    LDA #LO(small_font+1)
    STA TABLE
    LDA #HI(small_font+1)
    STA TABLE+1

    LDA small_font
    STA HEIGHT

    RTS
}

\\ A=glyph#
\\ Plot at beeb_writeptr on screen
\\ Preload TABLE with font address
\\ No clip, no handling of plotting across character rows
.beeb_plot_font_glyph
{
    STA IMAGE
    JSR setimage        ; set IMAGE address of glyph data

    LDY #0
    LDA (IMAGE), Y
    STA WIDTH           ; get WIDTH

    ASL A:ASL A: ASL A  ; x8
    STA smYMAX1+1
    STA smYMAX2+1
    STA smYMAX3+1
    
    LDA IMAGE
    CLC
    ADC #1
    STA smFont+1
    LDA IMAGE+1
    ADC #0
    STA smFont+2

    \ BEEB PALETTE
    LDX PALETTE
    LDA palette_addr_LO, X
    STA smPAL1+1
    STA smPAL2+1
    LDA palette_addr_HI, X
    STA smPAL1+2
    STA smPAL2+2

    LDX #0
    LDY #0
    .row_loop
    STY beeb_yoffset

    .line_loop
    STX beeb_temp

\ Load 4 pixels of sprite data

    .smFont
    LDA &FFFF, X
    STA beeb_data

\ Lookup pixels D & C

    AND #&CC

\ Shift down due to smaller palette lookup

    LSR A:LSR A                     ; 4c

    TAX
    .smPAL1
    LDA &FFFF, X

\ Write to screen

    STA (beeb_writeptr), Y

\ Increment write pointer

    CLC
    TYA:ADC #8:TAY

    .smYMAX1
    CPY #0
    BCS done_line

\ Lookup pixels B & A

    LDA beeb_data
    AND #&33
    TAX
    .smPAL2
    LDA &FFFF, X

\ Write to screen

    STA (beeb_writeptr), Y

\ Next screen byte across

    CLC
    TYA:ADC #8:TAY

    .smYMAX2
    CPY #0
    BCS done_line

\ Increment sprite index

    LDX beeb_temp
    INX
    BNE line_loop

    .done_line
    LDX beeb_temp
    INX

    LDY beeb_yoffset
    INY
    CPY HEIGHT
    BNE row_loop

    CLC
    LDA beeb_writeptr
    .smYMAX3
    ADC #0
    STA beeb_writeptr
    BCC no_carry
    INC beeb_writeptr+1
    .no_carry

    RTS
}

.beeb_plot_font_end
