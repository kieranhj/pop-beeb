; beeb-plot-font
; BBC Micro plot functions
; Font data only

_UNROLL_FONT = TRUE         ; unroll 1x 2x 3x byte versions of font plot

SMALL_FONT_HEIGHT = 7

.beeb_plot_font_start

.beeb_plot_font_prep
{
    LDA #LO(small_font+1)
    STA TABLE
    LDA #HI(small_font+1)
    STA TABLE+1

    LDA small_font
    STA HEIGHT

IF _UNROLL_FONT
IF _DEBUG
    CMP #SMALL_FONT_HEIGHT
    BEQ height_ok
    BRK
    .height_ok
ENDIF
ENDIF

    RTS
}

\\ A=glyph#
\\ Plot at beeb_writeptr on screen
\\ Preload TABLE with font address
\\ No clip, no handling of plotting across character rows
IF _UNROLL_FONT = FALSE
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
ELSE
.beeb_plot_font_glyph
{
    STA IMAGE
    JSR setimage        ; set IMAGE address of glyph data

    LDX PALETTE

    LDY #0
    LDA (IMAGE), Y
    INY

    STA WIDTH           ; get WIDTH

    CMP #1
    BEQ beeb_plot_font_1

    CMP #3
    BCC beeb_plot_font_2

    JMP beeb_plot_font_3

    .beeb_plot_font_2

\\ Standard font width is 2 bytes

    \ BEEB PALETTE
    LDA palette_addr_LO, X
    STA smPAL1+1
    STA smPAL2+1
    LDA palette_addr_HI, X
    STA smPAL1+2
    STA smPAL2+2

    .loop
    STY beeb_temp

\ Load 4 pixels of sprite data

    LDA (IMAGE), Y
    STA beeb_data

\ Lookup pixels D & C

    AND #&CC

\ Shift down due to smaller palette lookup

    LSR A:LSR A                     ; 4c

    TAX
    .smPAL1
    LDA &FFFF, X

\ Write to screen

    LDY #0
    STA (beeb_writeptr), Y

\ Lookup pixels B & A

    LDA beeb_data
    AND #&33
    TAX
    .smPAL2
    LDA &FFFF, X

\ Write to screen

    LDY #8
    STA (beeb_writeptr), Y

\ Next line

    INC beeb_writeptr
    \\ Within character block so can't carry

\ Increment sprite index

    LDY beeb_temp
    INY
    CPY #SMALL_FONT_HEIGHT+1
    BCC loop

\ Next column

    CLC
    LDA beeb_writeptr
    ADC #(2 * 8) - SMALL_FONT_HEIGHT
    STA beeb_writeptr
    BCC no_carry
    INC beeb_writeptr+1
    .no_carry

    RTS
}

.beeb_plot_font_1
{
\\ Narrow font width is 1 bytes

    \ BEEB PALETTE
    LDA palette_addr_LO, X
    STA smPAL1+1
    LDA palette_addr_HI, X
    STA smPAL1+2

    .loop
    STY beeb_temp

\ Load 4 pixels of sprite data

    LDA (IMAGE), Y

\ Lookup pixels D & C

    AND #&CC

\ Shift down due to smaller palette lookup

    LSR A:LSR A                     ; 4c

    TAX
    .smPAL1
    LDA &FFFF, X

\ Write to screen

    LDY #0
    STA (beeb_writeptr), Y

\ Next line

    INC beeb_writeptr
    \\ Within character block so can't carry

\ Increment sprite index

    LDY beeb_temp
    INY
    CPY #SMALL_FONT_HEIGHT+1
    BCC loop

\ Next column

    INC beeb_writeptr
    BNE no_carry
    INC beeb_writeptr+1
    .no_carry

    RTS
}

.beeb_plot_font_3
{
    \\ Wide font width is 3 bytes

    \ BEEB PALETTE
    LDA palette_addr_LO, X
    STA smPAL1+1
    STA smPAL2+1
    STA smPAL3+1
    LDA palette_addr_HI, X
    STA smPAL1+2
    STA smPAL2+2
    STA smPAL3+2

    .loop
    STY beeb_temp

\ Load 4 pixels of sprite data

    LDA (IMAGE), Y
    STA beeb_data

\ Lookup pixels D & C

    AND #&CC

\ Shift down due to smaller palette lookup

    LSR A:LSR A                     ; 4c

    TAX
    .smPAL1
    LDA &FFFF, X

\ Write to screen

    LDY #0
    STA (beeb_writeptr), Y

\ Lookup pixels B & A

    LDA beeb_data
    AND #&33
    TAX
    .smPAL2
    LDA &FFFF, X

\ Write to screen

    LDY #8
    STA (beeb_writeptr), Y

    LDY beeb_temp
    INY
    STY beeb_temp

\ Load 4 pixels of sprite data

    LDA (IMAGE), Y

\ Lookup pixels D & C

    AND #&CC

\ Shift down due to smaller palette lookup

    LSR A:LSR A                     ; 4c

    TAX
    .smPAL3
    LDA &FFFF, X

\ Write to screen

    LDY #16
    STA (beeb_writeptr), Y

\ Next line

    INC beeb_writeptr
    \\ Within character block so can't carry

\ Increment sprite index

    LDY beeb_temp
    INY
    CPY #(2*SMALL_FONT_HEIGHT)+1
    BCC loop

\ Next column

    CLC
    LDA beeb_writeptr
    ADC #(3 * 8) - SMALL_FONT_HEIGHT
    STA beeb_writeptr
    BCC no_carry
    INC beeb_writeptr+1
    .no_carry

    RTS
}
ENDIF

\ X,Y = column, row on screen
\ beeb_readptr = string terminated with -1
\ A=PALETTE
.beeb_plot_font_string
{
    STA PALETTE

    CLC
    LDA Mult8_LO,X
    ADC Row_LO,Y
    STA beeb_writeptr
    LDA Mult8_HI,X
    ADC Row_HI,Y
    STA beeb_writeptr+1

    JSR beeb_plot_font_prep

    .loop
    LDY #0
    LDA (beeb_readptr), Y
    BMI done_loop
    BNE not_space

    CLC
    LDA beeb_writeptr
    ADC #16
    STA beeb_writeptr
    BCC no_carry
    INC beeb_writeptr+1
    .no_carry
    BNE next_char

    .not_space
    JSR beeb_plot_font_glyph

    .next_char
    INC beeb_readptr
    BNE loop
    INC beeb_readptr+1
    BNE loop

    .done_loop
    RTS
}

IF 0
SMALL_FONT_MAPCHAR
.string1
EQUB "This is a call", &FF
.string2
EQUB "TO ALL MY PAST", &FF
.string3
EQUB "RESIGNATIONS!!", &FF
.string4
EQUB "..HELLO WORLD..", &FF
ASCII_MAPCHAR

.test_font
{
  LDA #LO(string1):STA beeb_readptr
  LDA #HI(string1):STA beeb_readptr+1;
  LDX #0
  LDY #0
  LDA #0
  JSR beeb_plot_font_string

  LDA #LO(string2):STA beeb_readptr
  LDA #HI(string2):STA beeb_readptr+1
  LDX #0
  LDY #2
  LDA #14
  JSR beeb_plot_font_string

  LDA #LO(string3):STA beeb_readptr
  LDA #HI(string3):STA beeb_readptr+1
  LDX #0
  LDY #4
  LDA #4
  JSR beeb_plot_font_string

  LDA #LO(string4):STA beeb_readptr
  LDA #HI(string4):STA beeb_readptr+1
  LDX #0
  LDY #6
  LDA #10
  JSR beeb_plot_font_string
 
  RTS
}
ENDIF

.beeb_plot_font_end
