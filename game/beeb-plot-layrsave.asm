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

.layrsave_branch_location
EQUB 14, 26, 38, 50, 62, 74, 86, 98, 0

.layrsave_branch_offset
EQUB 92, 80, 68, 56, 44, 32, 20, 8, 0

.layrsave_peel_adjust1
EQUB (1*2*8)-7, (2*2*8)-7, (3*2*8)-7, (4*2*8)-7, (5*2*8)-7, (6*2*8)-7, (7*2*8)-7, (8*2*8)-7, (9*2*8)-7

.layrsave_peel_adjust2
EQUB (1*2*8), (2*2*8), (3*2*8), (4*2*8), (5*2*8), (6*2*8), (7*2*8), (8*2*8), (9*2*8)

.beeb_plot_layrsave
{
    JSR beeb_PREPREP

    \ OK to page out sprite data now we have dimensions etc.

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
}
.beeb_plot_layrsave_smEOR
    EOR #&07        ; _UPSIDE_DOWN=&00
{
    CLC
    ADC PEELBUF
    STA PEELBUF
    BCC no_carry3
    INC PEELBUF+1
    .no_carry3

    \\ Jump to function
    LDX VISWIDTH
    DEX
IF _DEBUG
    CPX #BEEB_MAX_LAYRSAVE_WIDTH
    BCC width_ok
    BRK
.width_ok
ENDIF

    \\ Poke in stride values according to width

    LDA layrsave_peel_adjust1, X
    STA beeb_plot_layrsave_smPeel1+1

    LDA layrsave_peel_adjust2, X
    STA beeb_plot_layrsave_smPeel2+1

    \\ Self-mod a branch after correct number of bytes

    LDY layrsave_branch_location, X
    STY beeb_plot_layrsave_remove_branch+1
    BEQ no_branch

    LDA #OPCODE_BRA
    STA beeb_plot_layrsave_branch_origin, Y

    LDA layrsave_branch_offset, X
    STA beeb_plot_layrsave_branch_origin+1, Y
    .no_branch

    \\ Unrolled layrsave

    LDX beeb_height
}
.beeb_plot_layrsave_y_loop
.beeb_plot_layrsave_branch_origin
{
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

    .branch_target
    DEX
    BEQ beeb_plot_layrsave_done_y
}

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c

.beeb_plot_layrsave_smCMP
    CMP #&00                        ; _UPSIDE_DOWN=&07
    BEQ beeb_plot_layrsave_smSEC                  ; 2c

.beeb_plot_layrsave_smDEC
    DEC beeb_writeptr               ; _UPSIDE_DOWN=INC
    INC PEELBUF                     ; can't overflow as in multiples of 8
    BRA beeb_plot_layrsave_y_loop

.beeb_plot_layrsave_smSEC
    SEC                             ; _UPSIDE_DOWN=CLC
    LDA beeb_writeptr
.beeb_plot_layrsave_smSBC1
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7); _UPSIDE_DOWN=ADC
    STA beeb_writeptr
    LDA beeb_writeptr+1
.beeb_plot_layrsave_smSBC2
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7); _UPSIDE_DOWN=ADC
    STA beeb_writeptr+1

    CLC
    LDA PEELBUF
    .beeb_plot_layrsave_smPeel1
    ADC #0          ; VISWIDTH*2*8
    STA PEELBUF
    {
        BCC no_carry1
        INC PEELBUF+1
        .no_carry1
    }
    JMP beeb_plot_layrsave_y_loop

    .beeb_plot_layrsave_done_y
    CLC
    LDA PEELBUF
    .beeb_plot_layrsave_smPeel2
    ADC #0           ; VISWIDTH*2*8
    STA PEELBUF
    {
        BCC no_carry2
        INC PEELBUF+1
        .no_carry2
    }

IF _DEBUG
{
    LDA PEELBUF+1
    CMP #HI(peelbuf_top)
    BCC buf_ok
    BRK
    .buf_ok
}
ENDIF

\\ Remove the self-mod branch code

.beeb_plot_layrsave_remove_branch
{
    LDY #0
    BEQ return

    LDA #OPCODE_LDA_indirect_Y
    STA beeb_plot_layrsave_branch_origin, Y

    LDA #LO(beeb_writeptr)
    STA beeb_plot_layrsave_branch_origin+1, Y

    .return
    JMP DONE                ; restore vars
}
ENDIF

.beeb_plot_layrsave_end
