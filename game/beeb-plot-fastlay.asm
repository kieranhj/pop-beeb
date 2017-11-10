; beeb-plot-fastlay
; BBC Micro plot functions
; Specialisations of fastlay permutations

.beeb_plot_fastlay_start

IF _UNROLL_FASTLAY
BEEB_MAX_FASTLAY_WIDTH=6

.fastlaysta_table_LO
EQUB LO(beeb_plot_fastlaysta_1byte)
EQUB LO(beeb_plot_fastlaysta_2bytes)
EQUB LO(beeb_plot_fastlaysta_3bytes)
EQUB LO(beeb_plot_fastlaysta_4bytes)
EQUB LO(beeb_plot_fastlaysta_5bytes)
EQUB LO(beeb_plot_fastlaysta_6bytes)

.fastlaysta_table_HI
EQUB HI(beeb_plot_fastlaysta_1byte)
EQUB HI(beeb_plot_fastlaysta_2bytes)
EQUB HI(beeb_plot_fastlaysta_3bytes)
EQUB HI(beeb_plot_fastlaysta_4bytes)
EQUB HI(beeb_plot_fastlaysta_5bytes)
EQUB HI(beeb_plot_fastlaysta_6bytes)

.beeb_plot_sprite_FASTLAYSTA
{
    \ Get sprite data address 

    JSR beeb_PREPREP
}
.beeb_plot_sprite_FASTLAYSTA_PP
{
    \ Calc screen address

    LDY YCO
    LDX XCO

    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16_HI,X
    ADC YHI,Y
    STA beeb_writeptr+1

\ Simple Y clip

    SEC
    LDA YCO
    SBC HEIGHT
    BCS no_yclip
    LDA #LO(-1)
    .no_yclip
    STA beeb_height

    LDX WIDTH
IF _DEBUG
    CPX #BEEB_MAX_FASTLAY_WIDTH
    BCC width_ok
    BRK
    .width_ok
ENDIF
    DEX

    LDA fastlaysta_table_LO,X
    STA jmp_addr+1
    LDA fastlaysta_table_HI,X
    STA jmp_addr+2

    .jmp_addr
    JMP &FFFF
}

.beeb_plot_fastlaysta_1byte
{
    .y_loop

\ Load 4 pixels of sprite data

    LDY #0
    LDA (IMAGE), Y

    STA beeb_data

\ Lookup pixels D & C

    AND #&CC
    TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    STA (beeb_writeptr), Y

\ Lookup pixels B & A

    LDA beeb_data
    AND #&33
    TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    LDY #8
    STA (beeb_writeptr), Y

\ Next sprite row

    {
        INC IMAGE
        BNE no_carry
        INC IMAGE+1
        .no_carry
    }

\ Have we completed all rows?

    LDY YCO
    DEY
    CPY beeb_height                ; TOPEDGE
    STY YCO
    BEQ done_y

\ Next scanline row

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    BRA y_loop

\ Next character row

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
    JMP DONE
}

.beeb_plot_fastlaysta_2bytes
{
    .y_loop

\ Load 4 pixels of sprite data

    LDY #0
    LDA (IMAGE), Y

\ Lookup pixels D & C

    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    STA (beeb_writeptr), Y

\ Lookup pixels B & A

    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    LDY #8
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #1
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #16
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #24
    STA (beeb_writeptr), Y

\ Next sprite row

    {
        CLC
        LDA IMAGE
        ADC #2
        STA IMAGE
        BCC no_carry
        INC IMAGE+1
        .no_carry
    }

\ Have we completed all rows?

    LDY YCO
    DEY
    CPY beeb_height                ; TOPEDGE
    STY YCO
    BEQ done_y

\ Next scanline row

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    BRA y_loop

\ Next character row

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
    JMP DONE
}

.beeb_plot_fastlaysta_3bytes
{
    .y_loop

\ Load 4 pixels of sprite data

    LDY #0
    LDA (IMAGE), Y

\ Lookup pixels D & C

    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    STA (beeb_writeptr), Y

\ Lookup pixels B & A

    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    LDY #8
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #1
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #16
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #24
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #2
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #32
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #40
    STA (beeb_writeptr), Y

\ Next sprite row

    {
        CLC
        LDA IMAGE
        ADC #3
        STA IMAGE
        BCC no_carry
        INC IMAGE+1
        .no_carry
    }

\ Have we completed all rows?

    LDY YCO
    DEY
    CPY beeb_height                ; TOPEDGE
    STY YCO
    BEQ done_y

\ Next scanline row

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    BRA y_loop

\ Next character row

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
    JMP DONE
}

.beeb_plot_fastlaysta_4bytes
{
    .y_loop

\ Load 4 pixels of sprite data

    LDY #0
    LDA (IMAGE), Y

\ Lookup pixels D & C

    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    STA (beeb_writeptr), Y

\ Lookup pixels B & A

    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    LDY #8
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #1
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #16
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #24
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #2
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #32
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #40
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #3
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #48
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #56
    STA (beeb_writeptr), Y

\ Next sprite row

    {
        CLC
        LDA IMAGE
        ADC #4
        STA IMAGE
        BCC no_carry
        INC IMAGE+1
        .no_carry
    }

\ Have we completed all rows?

    LDY YCO
    DEY
    CPY beeb_height                ; TOPEDGE
    STY YCO
    BEQ done_y

\ Next scanline row

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    JMP y_loop

\ Next character row

    .one_row_up
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    JMP y_loop

    .done_y
    JMP DONE
}

.beeb_plot_fastlaysta_5bytes
{
    .y_loop

\ Load 4 pixels of sprite data

    LDY #0
    LDA (IMAGE), Y

\ Lookup pixels D & C

    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    STA (beeb_writeptr), Y

\ Lookup pixels B & A

    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    LDY #8
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #1
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #16
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #24
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #2
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #32
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #40
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #3
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #48
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #56
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #4
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #64
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #72
    STA (beeb_writeptr), Y

\ Next sprite row

    {
        CLC
        LDA IMAGE
        ADC #5
        STA IMAGE
        BCC no_carry
        INC IMAGE+1
        .no_carry
    }

\ Have we completed all rows?

    LDY YCO
    DEY
    CPY beeb_height                ; TOPEDGE
    STY YCO
    BEQ done_y

\ Next scanline row

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    JMP y_loop

\ Next character row

    .one_row_up
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    JMP y_loop

    .done_y
    JMP DONE
}

.beeb_plot_fastlaysta_6bytes
{
    .y_loop

\ Load 4 pixels of sprite data

    LDY #0
    LDA (IMAGE), Y

\ Lookup pixels D & C

    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    STA (beeb_writeptr), Y

\ Lookup pixels B & A

    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X

\ Write to screen

    LDY #8
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #1
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #16
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #24
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #2
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #32
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #40
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #3
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #48
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #56
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #4
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #64
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #72
    STA (beeb_writeptr), Y

\ Next 4 pixels

    LDY #6
    LDA (IMAGE), Y
    STA beeb_data:AND #&CC:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #80
    STA (beeb_writeptr), Y
    LDA beeb_data:AND #&33:TAX
    LDA map_2bpp_to_mode2_palN, X
    LDY #88
    STA (beeb_writeptr), Y

\ Next sprite row

    {
        CLC
        LDA IMAGE
        ADC #6
        STA IMAGE
        BCC no_carry
        INC IMAGE+1
        .no_carry
    }

\ Have we completed all rows?

    LDY YCO
    DEY
    CPY beeb_height                ; TOPEDGE
    STY YCO
    BEQ done_y

\ Next scanline row

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC beeb_writeptr
    JMP y_loop

\ Next character row

    .one_row_up
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    JMP y_loop

    .done_y
    JMP DONE
}
ENDIF

.beeb_plot_fastlay_end
