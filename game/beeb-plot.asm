; beeb-plot
; BBC Micro plot functions

\*-------------------------------
\*
\*  Parameters passed to hires routines:
\*
\*  PAGE        $00 = hires page 1, $20 = hires page 2          - NOT BEEB UNLESS DOUBLE BUFFERING
\*  XCO         Screen X-coord (0=left, 39=right)
\*  YCO         Screen Y-coord (0=top, 191=bottom)
\*  OFFSET      # of bits to shift image right (0-6)
\*  IMAGE       Image # in table (1-127)
\*  TABLE       Starting address of image table (2 bytes)
\*  BANK        Memory bank of table (2 = main, 3 = aux)        BEEB = SWRAM slot
\*  OPACITY     Bits 0-6:
\*                0    AND
\*                1    OR
\*                2    STA
\*                3    special XOR (OR/shift/XOR)
\*                4    mask/OR
\*              Bit 7: 0 = normal, 1 = mirror
\*  LEFTCUT     Left edge of usable screen area
\*                (0 for full screen)
\*  RIGHTCUT    Right edge +1 of usable screen area
\*                (40 for full screen)
\*  TOPCUT      Top edge of usable screen area
\*                (0 for full screen)
\*  BOTCUT      Bottom edge +1 of usable screen area
\*                (192 for full screen)
\*
\*-------------------------------
\*
\*  Image table format:
\*
\*  Byte 0:    width (# of bytes)
\*  Byte 1:    height (# of lines)
\*  Byte 2-n:  image bytes (read left-right, top-bottom)
\*
\*-------------------------------

_USE_FASTLAY = TRUE         ; divert LayAND + LaySTA to FASTLAY versions

.beeb_plot_start


\*-------------------------------
\*
\*  L A Y
\*
\*  General routine to lay down an image on hi-res screen
\*  (Handles edge-clipping, bit-shifting, & mirroring)
\*
\*  Calls one of the following routines:
\*
\*    LayGen    General (OR, AND, STA)
\*    LayMask   Mask & OR
\*    LayXOR    Special XOR
\*
\*  Transfers control to MLAY if image is to be mirrored
\*
\*-------------------------------

.beeb_plot_sprite_LAY
{
;RASTER_COL PAL_magenta

 lda OPACITY
 bpl notmirr

 and #$7f
 sta OPACITY
 jmp beeb_plot_sprite_MLAY

.notmirr cmp #enum_and
 bne label_2
 jmp beeb_plot_sprite_LayAND

.label_2 cmp #enum_sta
 bne label_3
 jmp beeb_plot_sprite_LaySTA

.label_3
 JMP beeb_plot_sprite_LayMask
}

\*-------------------------------
\* LAY MASK
\*-------------------------------

IF _UNROLL_LAYMASK = FALSE
.beeb_plot_sprite_MLayMask
{
    LDA #1
    EQUB &2C        ; BIT = skip next two bytes
}
\\ Fall through
.beeb_plot_sprite_LayMask
{
    LDA #0
    STA beeb_mirror

    \ Get sprite data address 

    JSR beeb_PREPREP

    \  Check we're in the right function :)

    LDA beeb_mirror
    BEQ not_mirror
    LDA XCO
    SEC
    SBC WIDTH
    STA XCO
    .not_mirror

    \ CLIP here

    JSR CROP
    bpl cont
    .nothing_to_do
    jmp DONE
    .cont

    LDA PALETTE
    BPL not_full_fat
    JMP beeb_plot_sprite_LayMode2BM     ; beeb_mirror already set
    .not_full_fat

    JSR beeb_plot_sprite_setpalette

    \ Beeb screen address
    JSR beeb_plot_calc_screen_addr

    \ Parity inverted by Mirror
    LDA beeb_parity
    EOR beeb_mirror
    BEQ no_swap

\ L&R pixels need to be swapped over

    JSR beeb_plot_sprite_FlipPalette

    .no_swap

    \ Do we have a partial clip on left side?
    LDX OFFLEFT
    BEQ no_partial_left
    LDA OFFSET:LSR A:TAX
    BEQ no_partial_left
    DEC OFFLEFT
    .no_partial_left

    \ Calculate how many bytes of sprite data to unroll

    LDA VISWIDTH
    {
        CPX #0:BEQ no_partial_left
        INC A                   ; need extra byte of sprite data for left clip
        .no_partial_left
    }
    ; A = bytes_per_line_in_sprite
    CMP #0                      ; zero flag already set from CPX
    BEQ nothing_to_do           ; nothing to plot

    \ Calculate how deep our stack will be
    TAY
    ASL A: ASL A                ; we have W*4 pixels to unroll
    INC A
    STA beeb_stack_depth        ; stack will end up this many bytes lower than now

    \ Self-mod code to save a cycle per line
    ; Y = bytes_per_line_in_sprite
    DEY
    STY beeb_plot_sprite_LayMask_smSpriteBytes+1

    \ Calculate number of pixels visible on screen

    LDA VISWIDTH
    ASL A: ASL A
    {
        CPX #0:BEQ no_partial_left
        CLC
        ADC beeb_mode2_offset   ; have this many extra pixels on left side
        .no_partial_left
        LDY OFFRIGHT:BEQ no_partial_right
        SEC
        SBC beeb_mode2_offset
        .no_partial_right
    }
    ; A = number of visible pixels

    \ Calculate how many bytes we'll need to write to the screen

    LSR A
    CLC
    ADC beeb_parity             ; vispixels/2 + parity
    ; A = bytes_per_line_on_screen

    \ Self-mod code to save a cycle per line
    ASL A: ASL A: ASL A         ; x8
    STA beeb_plot_sprite_LayMask_smYMAX+1

    \ Calculate where to start reading data from stack
    {
        CPX #0:BEQ no_partial_left        ; left partial clip

        \ If clipping left start a number of bytes into the stack

        LDA beeb_mirror
        BEQ regular_clip

        \ MIRROR clip
        \ If mode2_offset then can see upto 3 more pixels
        \ pixels clipped = 4 - offset
        \ stack start = stack_depth + 1 - pixels clipped

        SEC
        LDA beeb_stack_depth
        SBC #3
        CLC
        ADC beeb_mode2_offset
        STA beeb_plot_sprite_LayMask_smStackStart+1
        BNE same_char_column

        .regular_clip

        \ Regular plot start [2-5] depending on mode2_offset
        SEC
        LDA #5
        SBC beeb_mode2_offset
        \ Self-mod code to save a cycle per line
        STA beeb_plot_sprite_LayMask_smStackStart+1
        BNE same_char_column

        .no_partial_left

        LDA beeb_mirror
        BEQ regular_plot

        \ MIRROR plot
        \ MIRROR = beeb_stack_depth+2 for parity or beeb_stack_depth+1 if even

        CLC
        LDA beeb_parity
        INC A
        ADC beeb_stack_depth
        STA beeb_plot_sprite_LayMask_smStackStart+1
        BNE check_offset

        \ If not clipping left then stack start is based on parity

        .regular_plot
        LDA beeb_parity
        EOR #1
        \ Self-mod code to save a cycle per line
        STA beeb_plot_sprite_LayMask_smStackStart+1

        .check_offset
        \ If we're on the next character column, move our write pointer

        LDA beeb_mode2_offset
        AND #&2
        BEQ same_char_column

        CLC
        LDA beeb_writeptr
        ADC #8
        STA beeb_writeptr
        BCC same_char_column
        INC beeb_writeptr+1
        .same_char_column
    }

    \ Set sprite data address skipping any bytes clipped off left
    {
        LDA beeb_mirror
        BEQ regular_plot

        \ Add RMOST to IMAGE for MIRROR case

        CLC
        LDA IMAGE
        ADC RMOST
        STA beeb_plot_sprite_LayMask_sprite_addr+1
        LDA IMAGE+1
        ADC #0
        STA beeb_plot_sprite_LayMask_sprite_addr+2

        \ MIRROR read down the stack

        LDA #OPCODE_DEX
        STA beeb_plot_sprite_LayMask_smDIR1
        STA beeb_plot_sprite_LayMask_smDIR2
        BNE done_check

        .regular_plot        
        CLC
        LDA IMAGE
        ADC OFFLEFT
        STA beeb_plot_sprite_LayMask_sprite_addr+1
        LDA IMAGE+1
        ADC #0
        STA beeb_plot_sprite_LayMask_sprite_addr+2

        \ REGULAR read up the stack

        LDA #OPCODE_INX
        STA beeb_plot_sprite_LayMask_smDIR1
        STA beeb_plot_sprite_LayMask_smDIR2
        .done_check
    }

    \ Save a cycle per line - player typically min 24 lines

IF _HALF_PLAYER
    LDA BEEBHACK
    BEQ no_beebhack

    \ The ugliest hack :(
    LDA WIDTH
    STA beeb_plot_sprite_LayMask_smEOR+1
    LDA #0
    STA beeb_plot_sprite_LayMask_smWIDTH+1
    BEQ done_beebhack

    .no_beebhack
    LDA WIDTH
    STA beeb_plot_sprite_LayMask_smWIDTH+1
    LDA #0
    STA beeb_plot_sprite_LayMask_smEOR+1

    .done_beebhack
ELSE
    LDA WIDTH
    STA beeb_plot_sprite_LayMask_smWIDTH+1
ENDIF
    LDA TOPEDGE
    STA beeb_plot_sprite_LayMask_smTOPEDGE+1

    \ Push a zero on the top of the stack in case of parity

    LDA #0
    PHA

    \ Remember where the stack is now
    
    TSX
    STX beeb_plot_sprite_LayMask_smSTACKTOP+1          ; use this to reset stack

    \ Calculate bottom of the stack and self-mod read address

    TXA
    SEC
    SBC beeb_stack_depth
    STA beeb_plot_sprite_LayMask_smSTACK1+1
    STA beeb_plot_sprite_LayMask_smSTACK2+1

    \\ Could probably just alter Stack Start and read from &100?
}

.beeb_plot_sprite_LayMask_plot_lines_loop

RASTER_COL PAL_cyan

\ Start at the end of the sprite data

    .beeb_plot_sprite_LayMask_smSpriteBytes
    LDY #0      ;beeb_bytes_per_line_in_sprite-1

\ Decode a line of sprite data using Exile method!
\ Current per pixel decode: STA ZP 3c+ TAX 2c+ LDA,X 4c=9c
\ Exile ZP: TAX 2c+ STA 4c+ LDA zp 3c=9c am I missing something?
\ Save 2 cycles per loop when shifting bytes down TXA vs LDA zp

    .beeb_plot_sprite_LayMask_line_loop

    .beeb_plot_sprite_LayMask_sprite_addr
    LDA &FFFF, Y
    BNE beeb_plot_sprite_LayMask_sprite_byte_has_pixels

\ Common case of a zero sprite data byte = 4x blank pixels

    PHA:PHA:PHA:PHA
    BEQ beeb_plot_sprite_LayMask_done_sprite_data_byte

\ Store sprite data in X

    .beeb_plot_sprite_LayMask_sprite_byte_has_pixels
    TAX

\ Mask pixel D

    AND #&11
    STA beeb_plot_sprite_LayMask_smPIXELD+1

\ Look up pixel map from ZP

.beeb_plot_sprite_LayMask_smPIXELD
    LDA &FF
    PHA                                 ; [3c]

\ Mask sprite data for pixel C

    TXA
    AND #&22
    STA beeb_plot_sprite_LayMask_smPIXELC+1

\ Look up pixel map from ZP

.beeb_plot_sprite_LayMask_smPIXELC
    LDA &FF
    PHA

\ Shift sprite data down to get pixels A & B

    TXA
    LSR A
    LSR A
    TAX

\ Mask pixel B

    AND #&11
    STA beeb_plot_sprite_LayMask_smPIXELB+1

\ Look up pixel map from ZP

.beeb_plot_sprite_LayMask_smPIXELB
    LDA &FF
    PHA

\ Mask pixel A

    TXA
    AND #&22
    STA beeb_plot_sprite_LayMask_smPIXELA+1

\ Look up pixel map from ZP

.beeb_plot_sprite_LayMask_smPIXELA
    LDA &FF
    PHA

\ Stop when we reach the left edge of the sprite data

    .beeb_plot_sprite_LayMask_done_sprite_data_byte
    DEY
    BPL beeb_plot_sprite_LayMask_line_loop

\ Always push the extra zero
\ Can't set it directly in case the loop gets interrupted and a return value pushed onto stack

    LDA #0
    PHA

RASTER_COL PAL_yellow

\ Sort out where to start in the stack lookup

    .beeb_plot_sprite_LayMask_smStackStart
    LDX #0  ;beeb_stack_start

\ Now plot that data to the screen left to right

    LDY #0
    CLC

.beeb_plot_sprite_LayMask_plot_screen_loop

.beeb_plot_sprite_LayMask_smDIR1
    INX
.beeb_plot_sprite_LayMask_smSTACK1
    LDA &100,X

.beeb_plot_sprite_LayMask_smDIR2
    INX
.beeb_plot_sprite_LayMask_smSTACK2
    ORA &100,X

\ Skip zero data

    BEQ beeb_plot_sprite_LayMask_skip_zero               ; BEEB really need to check this is faster in the general case!

\ Convert pixel data to mask

    STA beeb_plot_sprite_LayMask_load_mask+1             \ 4c not storing in a register
    .beeb_plot_sprite_LayMask_load_mask
    LDA mask_table              ; 4c

\ AND mask with screen

    AND (beeb_writeptr), Y

\ OR in sprite byte

    ORA beeb_plot_sprite_LayMask_load_mask+1             ; 4c

\ Write to screen

    STA (beeb_writeptr), Y

\ Next screen byte across

    .beeb_plot_sprite_LayMask_skip_zero
    TYA
    ADC #8
    TAY                         ; do it all backwards?!

    .beeb_plot_sprite_LayMask_smYMAX
    CPY #0
    BCC beeb_plot_sprite_LayMask_plot_screen_loop

\ Reset the stack pointer

    .beeb_plot_sprite_LayMask_smSTACKTOP
    LDX #0                 ; beeb_stack_ptr
    TXS

\ Have we completed all rows?

    LDY YCO
    DEY
    .beeb_plot_sprite_LayMask_smTOPEDGE
    CPY #0                 ; TOPEDGE
    STY YCO
    BEQ beeb_plot_sprite_LayMask_done_y

\ Move to next sprite data row

    CLC
    LDA beeb_plot_sprite_LayMask_sprite_addr+1
    .beeb_plot_sprite_LayMask_smWIDTH
    ADC #0                  ; WIDTH
    STA beeb_plot_sprite_LayMask_sprite_addr+1
    {
        BCC no_carry
        INC beeb_plot_sprite_LayMask_sprite_addr+2
        .no_carry
    }

\ Special case for half-height sprites

IF _HALF_PLAYER
    LDA beeb_plot_sprite_LayMask_smWIDTH+1
    .beeb_plot_sprite_LayMask_smEOR
    EOR #0
    STA beeb_plot_sprite_LayMask_smWIDTH+1
ENDIF

\ Next scanline

    LDA beeb_writeptr
    AND #&07
.beeb_plot_sprite_LayMask_smCMP
    CMP #&00
    BEQ beeb_plot_sprite_LayMask_smSEC

.beeb_plot_sprite_LayMask_smDEC
    DEC beeb_writeptr
    JMP beeb_plot_sprite_LayMask_plot_lines_loop

\ Need to move up a screen char row

.beeb_plot_sprite_LayMask_smSEC
    SEC
    LDA beeb_writeptr
.beeb_plot_sprite_LayMask_smSBC1
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
.beeb_plot_sprite_LayMask_smSBC2
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    JMP beeb_plot_sprite_LayMask_plot_lines_loop

    .beeb_plot_sprite_LayMask_done_y

\ Reset stack before we leave

    PLA
;RASTER_COL PAL_black
    JMP DONE

ENDIF

\*-------------------------------
\* LAY AND
\* Only used by transitional moving objects. OFFSET always 0?
\*-------------------------------

.beeb_plot_sprite_LayAND
{
IF _DEBUG
    LDA OFFSET
    BEQ offset_zero
    BRK
    .offset_zero
ENDIF

    \ Get sprite data address 

    JSR beeb_PREPREP

    \ CLIP here

    JSR CROP
    bpl cont
    .nothing_to_do
    jmp DONE
    .cont

IF _USE_FASTLAY
    \ BEEB GFX PERF - test CROP+FASTLAY as NO OFFSET
    JMP beeb_plot_sprite_FASTLAYAND_PP
ELSE
    RTS
ENDIF
}

\*-------------------------------
\* LAY STA
\* Only used for transitional moving objects - OFFSET always 0?
\*-------------------------------

.beeb_plot_sprite_LaySTA
{
IF _DEBUG
    LDA OFFSET
    BEQ offset_zero
    BRK
    .offset_zero
ENDIF

    \ Get sprite data address 

    JSR beeb_PREPREP

    \ CLIP here

    JSR CROP
    bpl cont
    .nothing_to_do
    jmp DONE
    .cont

IF _USE_FASTLAY
    \ BEEB GFX PERF - test CROP+FASTLAY as NO OFFSET
    JMP beeb_plot_sprite_FASTLAYSTA_PP
ELSE
    RTS
ENDIF
}


\*-------------------------------
\*
\*  M I R R O R    L A Y
\*
\*  Called by LAY
\*
\*  Specified starting byte (XCO, YCO) is image's bottom
\*  right corner, not bottom left; bytes are read off image
\*  table R-L, T-B and mirrored before printing.
\*
\*  In:  A = OPACITY, sans bit 7
\*
\*-------------------------------

.beeb_plot_sprite_MLAY ;A = OPACITY
{
 cmp #enum_and
 bne label_2
 jmp beeb_plot_sprite_MLayAND

.label_2 cmp #enum_sta
 bne label_3
 jmp beeb_plot_sprite_MLaySTA

.label_3
 JMP beeb_plot_sprite_MLayMask
}


\*-------------------------------
\* MIRROR AND
\*-------------------------------

.beeb_plot_sprite_MLayAND
{
    \\ This function originally used to display opponent energy bar
    \\ Now plotted using the font glyph system so not required
IF _DEBUG
    BRK ;JMP beeb_plot_sprite_LayAND
ELSE
    RTS
ENDIF
}

\*-------------------------------
\* MIRROR STA
\*-------------------------------

.beeb_plot_sprite_MLaySTA
{
    \\ This function originally used to display opponent energy bar
    \\ Now plotted using the font glyph system so not required
IF _DEBUG
    BRK ;JMP beeb_plot_sprite_LaySTA
ELSE
    RTS
ENDIF
}


\*-------------------------------
\*
\*  F A S T L A Y
\*
\*  Streamlined LAY routine
\*
\*  No offset - no clipping - no mirroring - no masking -
\*  no EOR - trashes IMAGE - may crash if overtaxed -
\*  but it's fast.
\*
\*  10/3/88: OK for images to protrude PARTLY off top
\*
\*-------------------------------

.beeb_plot_sprite_FASTLAY
{
 lda OPACITY

.label_1 cmp #enum_and
 bne label_2
 jmp beeb_plot_sprite_FASTLAYAND

.label_2 cmp #enum_sta
 bne label_3
 jmp beeb_plot_sprite_FASTLAYSTA

.label_3
\\ DROP THROUGH TO MASK for ORA, EOR & MASK
}

.beeb_plot_sprite_FASTMASK
{
    \ Get sprite data address 

    JSR beeb_PREPREP

    \ BEEB PALETTE
    LDX PALETTE
    BPL not_full_fat

    JMP beeb_plot_sprite_FastMaskMode2
    .not_full_fat

    LDA palette_addr_LO, X
    STA beeb_plot_sprite_FASTMASK_smPAL1+1
    STA beeb_plot_sprite_FASTMASK_smPAL2+1
    LDA palette_addr_HI, X
    STA beeb_plot_sprite_FASTMASK_smPAL1+2
    STA beeb_plot_sprite_FASTMASK_smPAL2+2

    \ Beeb screen address

    JSR beeb_plot_calc_screen_addr      ; can still lose OFFSET calcs

    \ Don't care about Carry

    \ Calculate how many bytes of sprite data to unroll

    LDA WIDTH
    STA beeb_plot_sprite_FASTMASK_smWIDTH+1
    STA beeb_plot_sprite_FASTMASK_smXMAX+1

    \ Set sprite data address skipping any bytes NO CLIP

    LDA IMAGE
    STA beeb_plot_sprite_FASTMASK_sprite_addr+1
    LDA IMAGE+1
    STA beeb_plot_sprite_FASTMASK_sprite_addr+2

\ Simple Y clip

    SEC
    LDA YCO
    SBC HEIGHT
    BCS no_yclip
    LDA #LO(-1)
    .no_yclip
    STA beeb_plot_sprite_FASTMASK_smTOPEDGE+1
}
.beeb_plot_sprite_FASTMASK_plot_lines_loop

\ Start at the end of the sprite data

    LDY #0
    LDX #0
    CLC

    .beeb_plot_sprite_FASTMASK_line_loop
    STX beeb_temp

\ Load 4 pixels of sprite data

    .beeb_plot_sprite_FASTMASK_sprite_addr
    LDA &FFFF, X
    STA beeb_data                   ; 3c

\ Lookup pixels D & C

    AND #&CC                        ; 2c
    BEQ beeb_plot_sprite_FASTMASK_skip_zeroDC

\ Shift down due to smaller palette lookup

    LSR A:LSR A                     ; 4c

    TAX

\ Convert pixel data to mask

    LDA map_2bpp_to_mask, X

\ AND mask with screen

    AND (beeb_writeptr), Y

\ OR in sprite byte

    .beeb_plot_sprite_FASTMASK_smPAL1
    ORA &FFFF, X

\ Write to screen

    STA (beeb_writeptr), Y

\ Increment write pointer

    .beeb_plot_sprite_FASTMASK_skip_zeroDC
    TYA:ADC #8:TAY

\ Lookup pixels B & A

    LDA beeb_data                   ; 3c
    AND #&33                        ; 2c
    BEQ beeb_plot_sprite_FASTMASK_skip_zeroBA

    TAX                             ; 2c

\ Convert pixel data to mask

    LDA map_2bpp_to_mask, X

\ AND mask with screen

    AND (beeb_writeptr), Y

\ OR in sprite byte

    .beeb_plot_sprite_FASTMASK_smPAL2
    ORA &FFFF, X

\ Write to screen

    STA (beeb_writeptr), Y

\ Next screen byte across

    .beeb_plot_sprite_FASTMASK_skip_zeroBA
    TYA:ADC #8:TAY

\ Increment sprite index

    LDX beeb_temp
    INX

    .beeb_plot_sprite_FASTMASK_smXMAX
    CPX #0
    BCC beeb_plot_sprite_FASTMASK_line_loop

\ Have we completed all rows?

    LDY YCO
    DEY
    .beeb_plot_sprite_FASTMASK_smTOPEDGE
    CPY #0                 ; TOPEDGE
    STY YCO
    BEQ beeb_plot_sprite_FASTMASK_done_y

\ Move to next sprite data row

    CLC
    LDA beeb_plot_sprite_FASTMASK_sprite_addr+1
    .beeb_plot_sprite_FASTMASK_smWIDTH
    ADC #0                  ; WIDTH
    STA beeb_plot_sprite_FASTMASK_sprite_addr+1
    {
        BCC no_carry
        INC beeb_plot_sprite_FASTMASK_sprite_addr+2
        .no_carry
    }

\ Next scanline

    LDA beeb_writeptr
    AND #&07
.beeb_plot_sprite_FASTMASK_smCMP
    CMP #&00
    BEQ beeb_plot_sprite_FASTMASK_smSEC

.beeb_plot_sprite_FASTMASK_smDEC
    DEC beeb_writeptr
    BRA beeb_plot_sprite_FASTMASK_plot_lines_loop

\ Need to move up a screen char row

.beeb_plot_sprite_FASTMASK_smSEC
    SEC
    LDA beeb_writeptr
.beeb_plot_sprite_FASTMASK_smSBC1
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
.beeb_plot_sprite_FASTMASK_smSBC2
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    BRA beeb_plot_sprite_FASTMASK_plot_lines_loop

    .beeb_plot_sprite_FASTMASK_done_y

\ Reset stack before we leave

    JMP DONE


\*-------------------------------
\* FASTLAY AND
\*-------------------------------

.beeb_plot_sprite_FASTLAYAND
{
    \ Get sprite data address 

    JSR beeb_PREPREP

    SEC
    LDA YCO
    SBC HEIGHT
    BCS no_yclip
    LDA #LO(-1)
    .no_yclip
    STA TOPEDGE
}
.beeb_plot_sprite_FASTLAYAND_PP
{
    \ BEEB PALETTE
    LDX PALETTE
    LDA palette_addr_LO, X
    STA beeb_plot_sprite_FASTLAYAND_PP_smPAL1+1
    STA beeb_plot_sprite_FASTLAYAND_PP_smPAL2+1
    LDA palette_addr_HI, X
    STA beeb_plot_sprite_FASTLAYAND_PP_smPAL1+2
    STA beeb_plot_sprite_FASTLAYAND_PP_smPAL2+2

    \ Beeb screen address

    JSR beeb_plot_calc_screen_addr      ; can still lose OFFSET calcs

    \ Don't care about Carry

    \ Calculate how many bytes of sprite data to unroll

    LDA WIDTH
    STA beeb_plot_sprite_FASTLAYAND_PP_smWIDTH+1
    STA beeb_plot_sprite_FASTLAYAND_PP_smXMAX+1

    \ Set sprite data address skipping any bytes NO CLIP

    LDA IMAGE
    STA beeb_plot_sprite_FASTLAYAND_PP_sprite_addr+1
    LDA IMAGE+1
    STA beeb_plot_sprite_FASTLAYAND_PP_sprite_addr+2

\ Simple Y clip

    LDA TOPEDGE
    STA beeb_plot_sprite_FASTLAYAND_PP_smTOPEDGE+1
}
.beeb_plot_sprite_FASTLAYAND_PP_plot_lines_loop
\ Start at the end of the sprite data

    LDY #0
    LDX #0
    CLC

    .beeb_plot_sprite_FASTLAYAND_PP_line_loop
    STX beeb_temp

\ Load 4 pixels of sprite data

    .beeb_plot_sprite_FASTLAYAND_PP_sprite_addr
    LDA &FFFF, X
    STA beeb_data

\ Lookup pixels D & C

    AND #&CC

\ Shift down due to smaller palette lookup

    LSR A:LSR A                     ; 4c

    TAX
    .beeb_plot_sprite_FASTLAYAND_PP_smPAL1
    LDA &FFFF, X

\ AND sprite data with screen

    AND (beeb_writeptr), Y

\ Write to screen

    STA (beeb_writeptr), Y

\ Increment write pointer

    TYA:ADC #8:TAY

\ Lookup pixels B & A

    LDA beeb_data
    AND #&33
    TAX
    .beeb_plot_sprite_FASTLAYAND_PP_smPAL2
    LDA &FFFF, X

\ AND sprite data with screen

    AND (beeb_writeptr), Y

\ Write to screen

    STA (beeb_writeptr), Y

\ Next screen byte across

    TYA:ADC #8:TAY

\ Increment sprite index

    LDX beeb_temp
    INX

    .beeb_plot_sprite_FASTLAYAND_PP_smXMAX
    CPX #0
    BCC beeb_plot_sprite_FASTLAYAND_PP_line_loop

\ Have we completed all rows?

    LDY YCO
    DEY
    .beeb_plot_sprite_FASTLAYAND_PP_smTOPEDGE
    CPY #0                 ; TOPEDGE
    STY YCO
    BEQ beeb_plot_sprite_FASTLAYAND_PP_done_y

\ Move to next sprite data row

    CLC
    LDA beeb_plot_sprite_FASTLAYAND_PP_sprite_addr+1
    .beeb_plot_sprite_FASTLAYAND_PP_smWIDTH
    ADC #0                  ; WIDTH
    STA beeb_plot_sprite_FASTLAYAND_PP_sprite_addr+1
    {
        BCC no_carry
        INC beeb_plot_sprite_FASTLAYAND_PP_sprite_addr+2
        .no_carry
    }

\ Next scanline

    LDA beeb_writeptr
    AND #&07

.beeb_plot_sprite_FASTLAYAND_PP_smCMP
    CMP #&00
    BEQ beeb_plot_sprite_FASTLAYAND_PP_smSEC

.beeb_plot_sprite_FASTLAYAND_PP_smDEC
    DEC beeb_writeptr
    BRA beeb_plot_sprite_FASTLAYAND_PP_plot_lines_loop

\ Need to move up a screen char row

.beeb_plot_sprite_FASTLAYAND_PP_smSEC
    SEC
    LDA beeb_writeptr
.beeb_plot_sprite_FASTLAYAND_PP_smSBC1
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
.beeb_plot_sprite_FASTLAYAND_PP_smSBC2
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    BRA beeb_plot_sprite_FASTLAYAND_PP_plot_lines_loop

    .beeb_plot_sprite_FASTLAYAND_PP_done_y

\ Reset stack before we leave

    JMP DONE

.beeb_plot_end
