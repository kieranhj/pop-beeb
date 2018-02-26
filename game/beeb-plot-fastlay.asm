; beeb-plot-fastlay
; BBC Micro plot functions
; Specialisations of fastlay permutations

.beeb_plot_fastlay_start

IF _UNROLL_FASTLAY
BEEB_MAX_FASTLAY_WIDTH=6

.fastlaysta_branch_location
EQUB 28, 54, 80, 106, 132, 0

.fastlaysta_branch_offset
EQUB 126, 100, 74, 48, 22, 0


.beeb_plot_sprite_FASTLAYSTA
{
    \ Get sprite data address 

    JSR beeb_PREPREP
}
.beeb_plot_sprite_FASTLAYSTA_PP
{
    \ PALETTE

    LDX PALETTE
    BPL not_full_fat
    JMP beeb_plot_sprite_FastLaySTAMode2
    .not_full_fat

    LDA palette_addr_LO, X
    STA beeb_readptr
    LDA palette_addr_HI, X
    STA beeb_readptr+1

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

    \\ Poke in stride values according to width

    LDX WIDTH
    STX smStride+1

    DEX
IF _DEBUG
    CPX #BEEB_MAX_FASTLAY_WIDTH
    BCC width_ok
    BRK
    .width_ok
ENDIF

    \\ Self-mod a branch after correct number of bytes

    LDY fastlaysta_branch_location, X
    STY remove_branch+1
    BEQ no_branch

    LDA #OPCODE_BRA
    STA branch_origin, Y

    LDA fastlaysta_branch_offset, X
    STA branch_origin+1, Y
    .no_branch

    \\ Unrolled fastlay STA

    .y_loop
    .branch_origin

\ Byte 0

    LDY #0:LDA (IMAGE), Y
    TAX:AND #&CC:LSR A: LSR A:TAY

    LDA (beeb_readptr), Y
    LDY #0:STA (beeb_writeptr), Y

    TXA:AND #&33:TAY
    LDA (beeb_readptr), Y
    LDY #8:STA (beeb_writeptr), Y

\ Byte 1

    LDY #1:LDA (IMAGE), Y
    TAX:AND #&CC:LSR A: LSR A:TAY

    LDA (beeb_readptr), Y
    LDY #16:STA (beeb_writeptr), Y

    TXA:AND #&33:TAY
    LDA (beeb_readptr), Y
    LDY #24:STA (beeb_writeptr), Y

\ Byte 2

    LDY #2:LDA (IMAGE), Y
    TAX:AND #&CC:LSR A: LSR A:TAY

    LDA (beeb_readptr), Y
    LDY #32:STA (beeb_writeptr), Y

    TXA:AND #&33:TAY
    LDA (beeb_readptr), Y
    LDY #40:STA (beeb_writeptr), Y

\ Byte 3

    LDY #3:LDA (IMAGE), Y
    TAX:AND #&CC:LSR A: LSR A:TAY

    LDA (beeb_readptr), Y
    LDY #48:STA (beeb_writeptr), Y

    TXA:AND #&33:TAY
    LDA (beeb_readptr), Y
    LDY #56:STA (beeb_writeptr), Y

\ Byte 4

    LDY #4:LDA (IMAGE), Y
    TAX:AND #&CC:LSR A: LSR A:TAY

    LDA (beeb_readptr), Y
    LDY #64:STA (beeb_writeptr), Y

    TXA:AND #&33:TAY
    LDA (beeb_readptr), Y
    LDY #72:STA (beeb_writeptr), Y

\ Byte 5

    LDY #5:LDA (IMAGE), Y
    TAX:AND #&CC:LSR A: LSR A:TAY

    LDA (beeb_readptr), Y
    LDY #80:STA (beeb_writeptr), Y

    TXA:AND #&33:TAY
    LDA (beeb_readptr), Y
    LDY #88:STA (beeb_writeptr), Y

\ Next sprite row

    CLC
    LDA IMAGE
    .smStride
    ADC #6
    STA IMAGE
    BCC no_carry
    INC IMAGE+1
    .no_carry

\ Have we completed all rows?

    LDY YCO
    DEY
    CPY beeb_height                ; TOPEDGE
    STY YCO
    BEQ done_y

\ Next scanline row

IF _UPSIDE_DOWN
    LDA beeb_writeptr
    AND #&07
    CMP #&7
    BEQ one_row_down

    INC beeb_writeptr
    JMP y_loop
    
\ Next character row

    .one_row_down
    CLC
    LDA beeb_writeptr
    ADC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    ADC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    JMP y_loop
ELSE
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
ENDIF
    .done_y

    \\ Remove the self-mod branch code

    .remove_branch
    LDY #0
    BEQ return

    LDA #OPCODE_LDA_indirect_Y
    STA branch_origin, Y

    LDA #LO(IMAGE)
    STA branch_origin+1, Y

    .return
    JMP DONE
}
ENDIF

.beeb_plot_fastlay_end
