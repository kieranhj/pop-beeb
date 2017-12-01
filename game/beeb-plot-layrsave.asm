; beeb-plot-layrsave
; BBC Micro plot functions
; Specialisations of layrsave permutations

\*-------------------------------
\*
\*  L A Y E R S A V E
\*
\*  In:  Same as for LAY, plus PEELBUF (2 bytes)
\*  Out: PEELBUF (updated), PEELIMG (2 bytes), PEELXCO, PEELYCO
\*
\*  PEELIMG is 2-byte pointer to beginning of image table.
\*  (Hi byte = 0 means no image has been stored.)
\*
\*  PEELBUF is 2-byte pointer to first available byte in
\*  peel buffer.
\*
\*-------------------------------

.beeb_plot_layrsave_start

IF _UNROLL_LAYRSAVE
BEEB_MAX_LAYRSAVE_WIDTH=9

.layrsave_table_LO
EQUB LO(beeb_plot_layrsave_1byte)
EQUB LO(beeb_plot_layrsave_2bytes)
EQUB LO(beeb_plot_layrsave_3bytes)
EQUB LO(beeb_plot_layrsave_4bytes)
EQUB LO(beeb_plot_layrsave_5bytes)
EQUB LO(beeb_plot_layrsave_6bytes)
EQUB LO(beeb_plot_layrsave_7bytes)
EQUB LO(beeb_plot_layrsave_8bytes)
EQUB LO(beeb_plot_layrsave_9bytes)
;EQUB LO(beeb_plot_layrsave_10bytes)

.layrsave_table_HI
EQUB HI(beeb_plot_layrsave_1byte)
EQUB HI(beeb_plot_layrsave_2bytes)
EQUB HI(beeb_plot_layrsave_3bytes)
EQUB HI(beeb_plot_layrsave_4bytes)
EQUB HI(beeb_plot_layrsave_5bytes)
EQUB HI(beeb_plot_layrsave_6bytes)
EQUB HI(beeb_plot_layrsave_7bytes)
EQUB HI(beeb_plot_layrsave_8bytes)
EQUB HI(beeb_plot_layrsave_9bytes)
;EQUB HI(beeb_plot_layrsave_10bytes)

.beeb_plot_layrsave
{
    JSR beeb_PREPREP

    \ OK to page out sprite data now we have dimensions etc.

    \ Select MOS 4K RAM
    JSR swr_select_ANDY

    lda OPACITY
    bpl normal

    \ Mirrored
    LDA XCO
    SEC
    SBC WIDTH
    STA XCO

    \ Do we always need this?

    .normal
    inc WIDTH ;extra byte to cover shift right

    \ on Beeb we could skip a column of bytes if offset>3

    jsr CROP
    bmi skipit

    lda PEELBUF ;PEELBUF: 2-byte pointer to 1st
    sta PEELIMG ;available byte in peel buffer
    lda PEELBUF+1
    sta PEELIMG+1

    LDY YCO
    STY PEELYCO
    LDX XCO
    STX PEELXCO

    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16_HI,X
    ADC YHI,Y
    STA beeb_writeptr+1

    LDA VISWIDTH
    BNE width_not_zero

    .skipit
    JSR swr_deselect_ANDY
    JMP SKIPIT

    .width_not_zero
    LDY #0
    STA (PEELBUF), Y

    \ Calculate visible height

    INY
    LDA YCO
    SEC
    SBC TOPEDGE
    STA (PEELBUF), Y ;Height of onscreen portion ("VISHEIGHT")
    STA beeb_height

    CLC
    LDA PEELBUF
    ADC #9
    AND #&F8
    STA PEELBUF
    BCC no_carry
    INC PEELBUF+1
    .no_carry

    LDA beeb_writeptr
    AND #&07
    EOR #&07
    CLC
    ADC PEELBUF
    STA PEELBUF
    BCC no_carry2
    INC PEELBUF+1
    .no_carry2

    \\ Jump to function
    LDX VISWIDTH
    DEX
IF _DEBUG
    CPX #BEEB_MAX_LAYRSAVE_WIDTH
    BCC width_ok
    BRK
.width_ok
ENDIF
    LDA layrsave_table_LO,X
    STA jmp_addr+1
    LDA layrsave_table_HI,X
    STA jmp_addr+2
    .jmp_addr
    JMP &FFFF
}

.beeb_plot_layrsave_1byte
{
    LDX beeb_height

    .y_loop

    LDY #0
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #8
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC PEELBUF                     ; can't overflow as in multiples of 8

    BRA y_loop

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    CLC
    LDA PEELBUF
    ADC #(1*2*8) - 7          ; VISWIDTH*2*8
    STA PEELBUF
    BCC no_carry
    INC PEELBUF+1
    .no_carry

    BRA y_loop

    .done_y
    {
        CLC
        LDA PEELBUF
        ADC #(1*2*8)            ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
        .no_carry
    }

IF _DEBUG
    LDA PEELBUF+1
    CMP #&90
    BCC buf_ok
    BRK
    .buf_ok
ENDIF

    JSR swr_deselect_ANDY
    JMP DONE                ; restore vars
}

.beeb_plot_layrsave_2bytes
{
    LDX beeb_height

    .y_loop

    LDY #0
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #8
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #16
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #24
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC PEELBUF                     ; can't overflow as in multiples of 8

    BRA y_loop

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    CLC
    LDA PEELBUF
    ADC #(2*2*8) - 7          ; VISWIDTH*2*8
    STA PEELBUF
    BCC no_carry
    INC PEELBUF+1
    .no_carry

    BRA y_loop

    .done_y
    {
        CLC
        LDA PEELBUF
        ADC #(2*2*8)            ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
        .no_carry
    }

IF _DEBUG
    LDA PEELBUF+1
    CMP #&90
    BCC buf_ok
    BRK
    .buf_ok
ENDIF

    JSR swr_deselect_ANDY
    JMP DONE                ; restore vars
}

.beeb_plot_layrsave_3bytes
{
    LDX beeb_height

    .y_loop

    LDY #0
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #8
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #16
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #24
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #32
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #40
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC PEELBUF                     ; can't overflow as in multiples of 8

    BRA y_loop

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    CLC
    LDA PEELBUF
    ADC #(3*2*8) - 7          ; VISWIDTH*2*8
    STA PEELBUF
    BCC no_carry
    INC PEELBUF+1
    .no_carry

    BRA y_loop

    .done_y
    {
        CLC
        LDA PEELBUF
        ADC #(3*2*8)            ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
        .no_carry
    }

IF _DEBUG
    LDA PEELBUF+1
    CMP #&90
    BCC buf_ok
    BRK
    .buf_ok
ENDIF

    JSR swr_deselect_ANDY
    JMP DONE                ; restore vars
}

.beeb_plot_layrsave_4bytes
{
    LDX beeb_height

    .y_loop

    LDY #0
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #8
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #16
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #24
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #32
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #40
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #48
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #56
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC PEELBUF                     ; can't overflow as in multiples of 8

    BRA y_loop

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    CLC
    LDA PEELBUF
    ADC #(4*2*8) - 7          ; VISWIDTH*2*8
    STA PEELBUF
    BCC no_carry
    INC PEELBUF+1
    .no_carry

    BRA y_loop

    .done_y
    {
        CLC
        LDA PEELBUF
        ADC #(4*2*8)            ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
        .no_carry
    }

IF _DEBUG
    LDA PEELBUF+1
    CMP #&90
    BCC buf_ok
    BRK
    .buf_ok
ENDIF

    JSR swr_deselect_ANDY
    JMP DONE                ; restore vars
}

.beeb_plot_layrsave_5bytes
{
    LDX beeb_height

    .y_loop

    LDY #0
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #8
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #16
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #24
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #32
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #40
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #48
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #56
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #64
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #72
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC PEELBUF                     ; can't overflow as in multiples of 8

    BRA y_loop

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    CLC
    LDA PEELBUF
    ADC #(5*2*8) - 7          ; VISWIDTH*2*8
    STA PEELBUF
    BCC no_carry
    INC PEELBUF+1
    .no_carry

    BRA y_loop

    .done_y
    {
        CLC
        LDA PEELBUF
        ADC #(5*2*8)            ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
        .no_carry
    }

IF _DEBUG
    LDA PEELBUF+1
    CMP #&90
    BCC buf_ok
    BRK
    .buf_ok
ENDIF

    JSR swr_deselect_ANDY
    JMP DONE                ; restore vars
}

.beeb_plot_layrsave_6bytes
{
    LDX beeb_height

    .y_loop

    LDY #0
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #8
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #16
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #24
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #32
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #40
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #48
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #56
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #64
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #72
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #80
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #88
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC PEELBUF                     ; can't overflow as in multiples of 8

    BRA y_loop

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    {
        CLC
        LDA PEELBUF
        ADC #(6*2*8) - 7          ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
    }
    .no_carry

    BRA y_loop

    .done_y
    {
        CLC
        LDA PEELBUF
        ADC #(6*2*8)            ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
        .no_carry
    }

IF _DEBUG
    LDA PEELBUF+1
    CMP #&90
    BCC buf_ok
    BRK
    .buf_ok
ENDIF

    JSR swr_deselect_ANDY
    JMP DONE                ; restore vars
}

.beeb_plot_layrsave_7bytes
{
    LDX beeb_height

    .y_loop

    LDY #0
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #8
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #16
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #24
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #32
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #40
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #48
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #56
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #64
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #72
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #80
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #88
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #96
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #104
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC PEELBUF                     ; can't overflow as in multiples of 8

    BRA y_loop

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    {
        CLC
        LDA PEELBUF
        ADC #(7*2*8) - 7          ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
    }
    .no_carry

    BRA y_loop

    .done_y
    {
        CLC
        LDA PEELBUF
        ADC #(7*2*8)            ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
        .no_carry
    }

IF _DEBUG
    LDA PEELBUF+1
    CMP #&90
    BCC buf_ok
    BRK
    .buf_ok
ENDIF

    JSR swr_deselect_ANDY
    JMP DONE                ; restore vars
}

.beeb_plot_layrsave_8bytes
{
    LDX beeb_height

    .y_loop

    LDY #0
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #8
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #16
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #24
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #32
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #40
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #48
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #56
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #64
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #72
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #80
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #88
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #96
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #104
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #112
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #120
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC PEELBUF                     ; can't overflow as in multiples of 8

    BRA y_loop

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    {
        CLC
        LDA PEELBUF
        ADC #(8*2*8) - 7          ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
    }
    .no_carry

    JMP y_loop

    .done_y
    {
        CLC
        LDA PEELBUF
        ADC #(8*2*8)            ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
        .no_carry
    }

IF _DEBUG
    LDA PEELBUF+1
    CMP #&90
    BCC buf_ok
    BRK
    .buf_ok
ENDIF

    JSR swr_deselect_ANDY
    JMP DONE                ; restore vars
}

.beeb_plot_layrsave_9bytes
{
    LDX beeb_height

    .y_loop

    LDY #0
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #8
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #16
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #24
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #32
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #40
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #48
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #56
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #64
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #72
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #80
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #88
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #96
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #104
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #112
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #120
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #128
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #136
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC PEELBUF                     ; can't overflow as in multiples of 8

    BRA y_loop

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    {
        CLC
        LDA PEELBUF
        ADC #(9*2*8) - 7          ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
    }
    .no_carry

    JMP y_loop

    .done_y
    {
        CLC
        LDA PEELBUF
        ADC #(9*2*8)            ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
        .no_carry
    }

IF _DEBUG
    LDA PEELBUF+1
    CMP #&90
    BCC buf_ok
    BRK
    .buf_ok
ENDIF

    JSR swr_deselect_ANDY
    JMP DONE                ; restore vars
}

IF 0
.beeb_plot_layrsave_10bytes
{
    LDX beeb_height

    .y_loop

    LDY #0
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #8
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #16
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #24
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #32
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #40
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #48
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #56
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #64
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #72
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #80
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #88
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #96
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #104
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #112
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #120
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #128
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #136
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #144
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    LDY #152
    LDA (beeb_writeptr), Y
    STA (PEELBUF), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC PEELBUF                     ; can't overflow as in multiples of 8

    JMP y_loop

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    {
        CLC
        LDA PEELBUF
        ADC #(10*2*8) - 7          ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
    }
    .no_carry

    JMP y_loop

    .done_y
    {
        CLC
        LDA PEELBUF
        ADC #(10*2*8)            ; VISWIDTH*2*8
        STA PEELBUF
        BCC no_carry
        INC PEELBUF+1
        .no_carry
    }

IF _DEBUG
    LDA PEELBUF+1
    CMP #&90
    BCC buf_ok
    BRK
    .buf_ok
ENDIF

    JSR swr_deselect_ANDY
    JMP DONE                ; restore vars
}
ENDIF

ENDIF

.beeb_plot_layrsave_end
