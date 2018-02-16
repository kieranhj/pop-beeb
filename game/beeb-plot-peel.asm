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

.beeb_plot_peel
{
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

    \\ Poke in stride values according to width

    LDA layrsave_peel_adjust1, X
    STA smPeel1+1

    \\ Self-mod a branch after correct number of bytes

    LDY layrsave_branch_location, X
    STY remove_branch+1
    BEQ no_branch

    LDA #OPCODE_BRA
    STA branch_origin, Y

    LDA layrsave_branch_offset, X
    STA branch_origin+1, Y
    .no_branch

    \\ Unrolled peel

    LDX HEIGHT

    .y_loop
    .branch_origin
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

    .branch_target
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
    .smPeel1
    ADC #0          ; VISWIDTH*2*8 - 7
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    JMP y_loop

    .done_y

    \\ Remove the self-mod branch code

    .remove_branch
    LDY #0
    BEQ return
    LDA #OPCODE_LDA_indirect_Y
    STA branch_origin, Y

    LDA #LO(beeb_readptr)
    STA branch_origin+1, Y

    .return
    RTS
}

ENDIF

.beeb_plot_peel_end
