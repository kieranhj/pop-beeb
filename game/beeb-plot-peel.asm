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
}
.beeb_plot_peel_smEOR
    EOR #&07                ; _UPSIDE_DOWN = &00
{
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
    STA beeb_plot_peel_smPeel1+1

    \\ Self-mod a branch after correct number of bytes

    LDY layrsave_branch_location, X
    STY beeb_plot_peel_remove_branch+1
    BEQ no_branch

    LDA #OPCODE_BRA
    STA beeb_plot_peel_branch_origin, Y

    LDA layrsave_branch_offset, X
    STA beeb_plot_peel_branch_origin+1, Y
    .no_branch

    \\ Unrolled peel

    LDX HEIGHT
}
.beeb_plot_peel_y_loop
.beeb_plot_peel_branch_origin
{
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
    BEQ beeb_plot_peel_done_y
}

    LDA beeb_writeptr               ; 3c
    AND #&07                        ; 2c
.beeb_plot_peel_smCMP
    CMP #&00                        ; _UPSIDE_DOWN=&07
    BEQ beeb_plot_peel_smSEC                  ; 2c

.beeb_plot_peel_smDEC
    DEC beeb_writeptr               ; _UPSIDE_DOWN=INC
    INC beeb_readptr                     ; can't overflow as in multiples of 8
    BRA beeb_plot_peel_y_loop

.beeb_plot_peel_smSEC
    SEC                             ; _UPSIDE_DOWN=CLC
    LDA beeb_writeptr
.beeb_plot_peel_smSBC1
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7); _UPSIDE_DOWN=ADC
    STA beeb_writeptr
    LDA beeb_writeptr+1
.beeb_plot_peel_smSBC2
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7); _UPSIDE_DOWN=ADC
    STA beeb_writeptr+1

    CLC
    LDA beeb_readptr
    .beeb_plot_peel_smPeel1
    ADC #0          ; VISWIDTH*2*8 - 7
    STA beeb_readptr
    {
        BCC no_carry
        INC beeb_readptr+1
        .no_carry
    }
    JMP beeb_plot_peel_y_loop

.beeb_plot_peel_done_y

    \\ Remove the self-mod branch code

.beeb_plot_peel_remove_branch
{
    LDY #0
    BEQ return
    LDA #OPCODE_LDA_indirect_Y
    STA beeb_plot_peel_branch_origin, Y

    LDA #LO(beeb_readptr)
    STA beeb_plot_peel_branch_origin+1, Y

    .return
    RTS
}


ELSE

\*-------------------------------
\*
\*  P E E L = (CUSTOM) F A S T L A Y
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

.beeb_plot_peel
{
;RASTER_COL PAL_green

    \ Can't use PREPREP or setimage here as no TABLE!
    \ Assume IMAGE has been set correctly

    ldy #0
    lda (IMAGE),y
IF _DEBUG
    BNE width_ok
    BRK
    .width_ok
ENDIF
    sta WIDTH

    iny
    lda (IMAGE),y
IF _DEBUG
    BNE height_ok
    BRK
    .height_ok
ENDIF
    sta HEIGHT

    \ OFFSET IGNORED
    \ OPACITY IGNORED
    \ MIRROR IGNORED
    \ CLIPPING IGNORED

    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)

    \ Convert to Beeb screen layout

    \ Mask off Y offset

    LDY YCO
\ Bounds check YCO
IF _DEBUG
    CPY #192
    BCC y_ok
    BRK
    .y_ok
ENDIF

    \ Look up Beeb screen address

    LDX XCO
\ Bounds check XCO
IF _DEBUG
    CPX #70
    BCC x_ok
    BRK
    .x_ok
ENDIF

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

    \ No need for clip as not fastlay

    \ Extents

    LDA WIDTH
    ASL A
    ASL A
    ASL A
    ASL A       ; Mult16_LO
    SEC
    SBC #7
    STA smREADINC+1
    DEC A
    STA smYMAX+1

    LDX HEIGHT

    .y_loop

    .smYMAX
    LDY #0                          ; 2c
    SEC

    .x_loop
    LDA (beeb_readptr), Y           ; 5c
    STA (beeb_writeptr), Y          ; 6c

    TYA                     ; next char column [6c]
    SBC #8    
    TAY                     ; 6c

    BCS x_loop               ; 3c

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
    .smREADINC
    ADC #0                        ; VISWIDTH*2*8-7
    STA beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    BRA y_loop

    .done_y

;RASTER_COL PAL_black

    RTS
}
\\ 21*2-1=41c per Apple byte + ~14c per row
ENDIF

.palette_addr_LO
{
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_1)
    EQUB LO(fast_palette_lookup_2)
    EQUB LO(fast_palette_lookup_3)
    EQUB LO(fast_palette_lookup_4)
    EQUB LO(fast_palette_lookup_5)
    EQUB LO(fast_palette_lookup_6)
    EQUB LO(fast_palette_lookup_7)
    EQUB LO(fast_palette_lookup_8)
    EQUB LO(fast_palette_lookup_9)
    EQUB LO(fast_palette_lookup_10)
    EQUB LO(fast_palette_lookup_11)
    EQUB LO(fast_palette_lookup_12)
    EQUB LO(fast_palette_lookup_13)
    EQUB LO(fast_palette_lookup_14)
    EQUB LO(fast_palette_lookup_15)
    EQUB LO(fast_palette_lookup_16)
}

.palette_addr_HI
{
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_1)
    EQUB HI(fast_palette_lookup_2)
    EQUB HI(fast_palette_lookup_3)
    EQUB HI(fast_palette_lookup_4)
    EQUB HI(fast_palette_lookup_5)
    EQUB HI(fast_palette_lookup_6)
    EQUB HI(fast_palette_lookup_7)
    EQUB HI(fast_palette_lookup_8)
    EQUB HI(fast_palette_lookup_9)
    EQUB HI(fast_palette_lookup_10)
    EQUB HI(fast_palette_lookup_11)
    EQUB HI(fast_palette_lookup_12)
    EQUB HI(fast_palette_lookup_13)
    EQUB HI(fast_palette_lookup_14)
    EQUB HI(fast_palette_lookup_15)
    EQUB HI(fast_palette_lookup_16)
}

.beeb_plot_peel_end
