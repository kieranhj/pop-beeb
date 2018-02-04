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

.wipe_table_LO
EQUB LO(beeb_plot_wipe_1byte)
EQUB LO(beeb_plot_wipe_2bytes)
EQUB LO(beeb_plot_wipe_3bytes)
EQUB LO(beeb_plot_wipe_4bytes)

.wipe_table_HI
EQUB HI(beeb_plot_wipe_1byte)
EQUB HI(beeb_plot_wipe_2bytes)
EQUB HI(beeb_plot_wipe_3bytes)
EQUB HI(beeb_plot_wipe_4bytes)

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
    LDX width
    DEX
IF _DEBUG
    CPX #4
    BCC width_ok
    BRK
.width_ok
ENDIF
    LDA wipe_table_LO,X
    STA jmp_addr+1
    LDA wipe_table_HI,X
    STA jmp_addr+2
    .jmp_addr
    JMP &FFFF
}

.beeb_plot_wipe_1byte   ; 1 Apple byte = 2 Beeb bytes
{
    LDX height

    .y_loop
    LDA #0                          ; 2c

    LDY #0                          ; 2c
    STA (beeb_writeptr), Y          ; 6c

    LDY #8                          ; 2c
    STA (beeb_writeptr), Y          ; 6c

    DEX                             ; 2c
    BEQ done_y                      ; 2c

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr               ; 5c
    BRA y_loop                      ; 3c

    .one_row_up
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    BRA y_loop

    .done_y
    RTS    
}
\\ 2+16c per abyte + 4+7+8=19c per line

.beeb_plot_wipe_2bytes   ; 2 Apple bytes = 4 Beeb bytes
{
    LDX height

    .y_loop
    LDA #0

    LDY #0
    STA (beeb_writeptr), Y

    LDY #8
    STA (beeb_writeptr), Y

    LDY #16
    STA (beeb_writeptr), Y

    LDY #24
    STA (beeb_writeptr), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr
    AND #&07
    BEQ one_row_up

    DEC beeb_writeptr
    BRA y_loop

    .one_row_up
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    BRA y_loop

    .done_y
    RTS    
}

.beeb_plot_wipe_3bytes   ; 3 Apple bytes = 6 Beeb bytes
{
    LDX height

    .y_loop
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

    DEX
    BEQ done_y

    LDA beeb_writeptr
    AND #&07
    BEQ one_row_up

    DEC beeb_writeptr
    BRA y_loop

    .one_row_up
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    BRA y_loop

    .done_y
    RTS    
}


.beeb_plot_wipe_4bytes   ; 34 Apple bytes = 8 Beeb bytes
{
    LDX height

    .y_loop
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
    BEQ done_y

    LDA beeb_writeptr
    AND #&07
    BEQ one_row_up

    DEC beeb_writeptr
    BRA y_loop

    .one_row_up
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    BRA y_loop

    .done_y
    RTS    
}

ENDIF

.beeb_plot_wipe_end
