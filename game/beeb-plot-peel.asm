; beeb-plot-peel
; BBC Micro plot functions
; Specialisations of peel permutations

\*-------------------------------
\*
\*  NOT QUITE F A S T L A Y
\*
\*  Streamlined LAY routine
\*
\*  No offset - no clipping - no mirroring - no masking -
\*  no EOR - trashes IMAGE - may crash if overtaxed -
\*  but it's fast.
\*
\*  10/3/88: OK for images to protrude PARTLY off top
\*  Still more streamlined version of FASTLAY (STA only)
\*
\*  This Beeb function has no direct original equivalent
\*  because it is copying Beeb screen data directly back
\*  to the screen rather than unrolled sprite data
\* 
\*-------------------------------

.beeb_plot_peel_start

IF _UNROLL_LAYRSAVE
.peel_table_LO
EQUB LO(beeb_plot_peel_1byte)
EQUB LO(beeb_plot_peel_2bytes)
EQUB LO(beeb_plot_peel_3bytes)
EQUB LO(beeb_plot_peel_4bytes)
EQUB LO(beeb_plot_peel_5bytes)
EQUB LO(beeb_plot_peel_6bytes)
EQUB LO(beeb_plot_peel_7bytes)
EQUB LO(beeb_plot_peel_8bytes)
EQUB LO(beeb_plot_peel_9bytes)
;EQUB LO(beeb_plot_peel_10bytes)

.peel_table_HI
EQUB HI(beeb_plot_peel_1byte)
EQUB HI(beeb_plot_peel_2bytes)
EQUB HI(beeb_plot_peel_3bytes)
EQUB HI(beeb_plot_peel_4bytes)
EQUB HI(beeb_plot_peel_5bytes)
EQUB HI(beeb_plot_peel_6bytes)
EQUB HI(beeb_plot_peel_7bytes)
EQUB HI(beeb_plot_peel_8bytes)
EQUB HI(beeb_plot_peel_9bytes)
;EQUB HI(beeb_plot_peel_10bytes)

.beeb_plot_peel
{
    \ Select MOS 4K RAM as our sprite bank
    JSR swr_select_ANDY

    \ Can't use PREPREP or setimage here as no TABLE!
    \ Assume IMAGE has been set correctly

    ldy #0
    lda (IMAGE),y

IF _DEBUG
    BNE width_not_zero
    BRK
    .width_not_zero
ENDIF

    sta WIDTH

    iny
    lda (IMAGE),y
    sta HEIGHT

    \ OFFSET IGNORED
    \ OPACITY IGNORED
    \ MIRROR IGNORED
    \ CLIPPING IGNORED

    LDY YCO
    LDX XCO

    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16_HI,X
    ADC YHI,Y
    STA beeb_writeptr+1

    \ Set sprite data address 

    CLC
    LDA IMAGE
    ADC #9
    AND #&F8
    STA beeb_readptr
    LDA IMAGE+1
    ADC #0
    STA beeb_readptr+1

    LDA beeb_writeptr
    AND #&07
    EOR #&07
    CLC
    ADC beeb_readptr
    STA beeb_readptr
    BCC no_carry2
    INC beeb_readptr+1
    .no_carry2

    \\ Jump to function
    LDX WIDTH
    DEX
IF _DEBUG
    CPX #BEEB_MAX_LAYRSAVE_WIDTH
    BCC width_ok
    BRK
.width_ok
ENDIF
    LDA peel_table_LO,X
    STA jmp_addr+1
    LDA peel_table_HI,X
    STA jmp_addr+2
    .jmp_addr
    JMP &FFFF
}

.beeb_plot_peel_1byte
{
    LDX HEIGHT

    .y_loop

    LDY #0                          ; 2c
    LDA (beeb_readptr), Y           ; 5c
    STA (beeb_writeptr), Y          ; 6c

    LDY #8                          ; 2c
    LDA (beeb_readptr), Y           ; 5c
    STA (beeb_writeptr), Y          ; 6c

    DEX                             ; 2c
    BEQ done_y                      ; 2c

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr               ; 5c
    INC beeb_readptr                ; 5c     ; can't overflow as in multiples of 8

    BRA y_loop                      ; 3c

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    CLC
    LDA beeb_readptr
    ADC #(1*2*8) - 7          ; VISWIDTH*2*8
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    BRA y_loop

    .done_y

    RTS
}
\\ 26c per Apple byte + 24c per row

.beeb_plot_peel_2bytes
{
    LDX HEIGHT

    .y_loop

    LDY #0
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #8
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #16
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #24
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC beeb_readptr                     ; can't overflow as in multiples of 8

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
    LDA beeb_readptr
    ADC #(2*2*8) - 7          ; VISWIDTH*2*8
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    BRA y_loop

    .done_y

    RTS
}

.beeb_plot_peel_3bytes
{
    LDX HEIGHT

    .y_loop

    LDY #0
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #8
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #16
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #24
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #32
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #40
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC beeb_readptr                     ; can't overflow as in multiples of 8

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
    LDA beeb_readptr
    ADC #(3*2*8) - 7          ; VISWIDTH*2*8
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    BRA y_loop

    .done_y

    RTS
}

.beeb_plot_peel_4bytes
{
    LDX HEIGHT

    .y_loop

    LDY #0
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #8
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #16
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #24
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #32
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #40
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #48
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #56
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC beeb_readptr                     ; can't overflow as in multiples of 8

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
    LDA beeb_readptr
    ADC #(4*2*8) - 7          ; VISWIDTH*2*8
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    BRA y_loop

    .done_y

    RTS
}

.beeb_plot_peel_5bytes
{
    LDX HEIGHT

    .y_loop

    LDY #0
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #8
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #16
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #24
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #32
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #40
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #48
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #56
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #64
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #72
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC beeb_readptr                     ; can't overflow as in multiples of 8

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
    LDA beeb_readptr
    ADC #(5*2*8) - 7          ; VISWIDTH*2*8
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    BRA y_loop

    .done_y

    RTS
}

.beeb_plot_peel_6bytes
{
    LDX HEIGHT

    .y_loop

    LDY #0
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #8
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #16
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #24
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #32
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #40
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #48
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #56
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #64
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #72
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #80
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #88
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC beeb_readptr                     ; can't overflow as in multiples of 8

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
    LDA beeb_readptr
    ADC #(6*2*8) - 7          ; VISWIDTH*2*8
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    BRA y_loop

    .done_y

    RTS
}

.beeb_plot_peel_7bytes
{
    LDX HEIGHT

    .y_loop

    LDY #0
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #8
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #16
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #24
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #32
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #40
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #48
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #56
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #64
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #72
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #80
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #88
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #96
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #104
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC beeb_readptr                     ; can't overflow as in multiples of 8

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
    LDA beeb_readptr
    ADC #(7*2*8) - 7          ; VISWIDTH*2*8
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    BRA y_loop

    .done_y

    RTS
}

.beeb_plot_peel_8bytes
{
    LDX HEIGHT

    .y_loop

    LDY #0
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #8
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #16
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #24
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #32
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #40
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #48
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #56
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #64
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #72
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #80
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #88
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #96
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #104
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #112
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #120
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC beeb_readptr                     ; can't overflow as in multiples of 8

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
    LDA beeb_readptr
    ADC #(8*2*8) - 7          ; VISWIDTH*2*8
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    JMP y_loop

    .done_y

    RTS
}

.beeb_plot_peel_9bytes
{
    LDX HEIGHT

    .y_loop

    LDY #0
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #8
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #16
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #24
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #32
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #40
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #48
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #56
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #64
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #72
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #80
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #88
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #96
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #104
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #112
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #120
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #128
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #136
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC beeb_readptr                     ; can't overflow as in multiples of 8

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
    LDA beeb_readptr
    ADC #(9*2*8) - 7          ; VISWIDTH*2*8
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    JMP y_loop

    .done_y

    RTS
}

IF 0
.beeb_plot_peel_10bytes
{
    LDX HEIGHT

    .y_loop

    LDY #0
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #8
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #16
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #24
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #32
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #40
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #48
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #56
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #64
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #72
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #80
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #88
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #96
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #104
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #112
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #120
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #128
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #136
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #144
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    LDY #152
    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    DEX
    BEQ done_y

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    INC beeb_readptr                     ; can't overflow as in multiples of 8

    JMP y_loop

    .one_row_up

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    CLC
    LDA beeb_readptr
    ADC #(10*2*8) - 7          ; VISWIDTH*2*8
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    JMP y_loop

    .done_y

    RTS
}
ENDIF

ENDIF

.beeb_plot_peel_end
