; beeb-plot
; BBC Micro plot functions
; Works directly on Apple II sprite data

; need to know where we're locating this code!

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

\ BEEB TO DO
\ Use original game ZP variables
\ Implement special XOR - this will be done by using a different palette

.beeb_plot_start

.beeb_PREPREP
{
    \\ Must have a swram bank to select or assert
    LDA BANK
    JSR swr_select_slot

    \ Set a palette per swram bank
    \ Could set palette per sprite table or even per sprite

    LDY BANK
    LDA bank_to_palette_temp,Y
    JSR beeb_plot_sprite_SetExilePalette

    \ Turns TABLE & IMAGE# into IMAGE ptr
    \ Obtains WIDTH & HEIGHT
    
    JMP PREPREP
}



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

.beeb_plot_layrsave
{
    JSR beeb_PREPREP

    \ OK to page out sprite data now we have dimensions etc.

    \ Select MOS 4K RAM
    JSR swr_select_mos4k

    lda OPACITY
    bpl normal

    \ Mirrored
    LDA XCO
    SEC
    SBC WIDTH
    STA XCO

    .normal
    inc WIDTH ;extra byte to cover shift right

    \ on Beeb we could skip a column of bytes if offset>3

    jsr CROP
    bmi skipit

    lda PEELBUF ;PEELBUF: 2-byte pointer to 1st
    sta PEELIMG ;available byte in peel buffer
    lda PEELBUF+1
    sta PEELIMG+1

    \ Mask off Y offset

    LDA YCO
    STA PEELYCO

    AND #&F8
    TAY    

    \ Look up Beeb screen address

    LDX XCO
    STX PEELXCO

    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA scrn_addr+1
;    STA scrn_addr2+1
    LDA Mult16_HI,X
    ADC YHI,Y
    STA scrn_addr+2
;    STA scrn_addr2+2

    \ Ignore clip for now
    
    \ Make sprite

    LDY #0
    LDA VISWIDTH
    BNE width_ok

    .skipit
    JMP SKIPIT

    \ Store visible width

    .width_ok
    STA (PEELBUF), Y
    
    \ Calculate visible height

    INY
    LDA YCO
    SEC
    SBC TOPEDGE
    STA (PEELBUF),y ;Height of onscreen portion ("VISHEIGHT")

    STA beeb_height

    \ Increment (w,h) header to start of image data

    LDA PEELBUF
    CLC
    ADC #2
    STA PEELBUF
    LDA PEELBUF+1
    ADC #0
    STA PEELBUF+1

    LDA VISWIDTH
    ASL A                   ; bytes_per_line_on_screen
    STA VISWIDTH

    \ Y offset into character row

    LDA YCO
    AND #&7
    TAX

    .yloop
    STX beeb_yoffset

    LDA VISWIDTH
    STA beeb_width

    LDY #0                  ; would be nice (i.e. faster) to do all of this backwards
    CLC

    .xloop

    .scrn_addr
    LDA &FFFF,X

    STA (PEELBUF),Y
    INY

;    LDA #&FF
;    .scrn_addr2
;    LDA &FFFF,X

    TXA                     ; next char column [6c]
    ADC #8    
    TAX

    DEC beeb_width
    BNE xloop
    
    .done_x

    \ Update PEELBUF as we go along
    CLC
    LDA PEELBUF
    ADC VISWIDTH
    STA PEELBUF
    LDA PEELBUF+1
    ADC #0
    STA PEELBUF+1

    \ Have we done all lines?
    DEC beeb_height
    BEQ done

    \ Next scanline
    LDX beeb_yoffset
    DEX
    BPL yloop

    \ Next character row
    SEC
    LDA scrn_addr+1
    SBC #LO(BEEB_SCREEN_ROW_BYTES)
    STA scrn_addr+1
 ;   STA scrn_addr2+1
    LDA scrn_addr+2
    SBC #HI(BEEB_SCREEN_ROW_BYTES)
    STA scrn_addr+2
 ;   STA scrn_addr2+2

    LDX #7
    BNE yloop
    .done

    \ PEELBUF now updated on 

    JMP DONE                ; restore vars
}

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

.beeb_plot_wipe
{
    \ OFFSET IGNORED
    \ OPACITY IGNORED
    \ MIRROR IGNORED
    \ CLIPPING IGNORED
    
    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)

    \ Convert to Beeb screen layout

    \ Mask off Y offset

    LDA YCO
    AND #&F8
    TAY    

    \ Look up Beeb screen address

    LDX XCO
    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA scrn_addr+1
    LDA Mult16_HI,X
    ADC YHI,Y
    STA scrn_addr+2

    \ Simple Y clip
    SEC
    LDA YCO
    SBC height
    STA smTOP+1

    \ Store height

    LDA YCO
    STA beeb_height

    \ Y offset into character row

    AND #&7
    TAX
    
    \ Plot loop

    LDA width
    ASL A
    STA VISWIDTH

    .yloop
    STX beeb_yoffset

    LDA VISWIDTH
    STA beeb_width          ; bytes_per_line_on_screen

    CLC

    .xloop

    LDA OPACITY
    .scrn_addr
    STA &FFFF, X

    TXA                     ; next char column [6c]
    ADC #8    
    TAX

    DEC beeb_width
    BNE xloop
    
    .done_x
    LDA beeb_height
    DEC A
    .smTOP
    CMP #0
    BEQ done_y
    STA beeb_height

    \ Completed a line

    \ Next scanline

    LDX beeb_yoffset
    DEX
    BPL yloop

    \ Next character row

    SEC
    LDA scrn_addr+1
    SBC #LO(BEEB_SCREEN_ROW_BYTES)
    STA scrn_addr+1
    LDA scrn_addr+2
    SBC #HI(BEEB_SCREEN_ROW_BYTES)
    STA scrn_addr+2

    LDX #7
    BNE yloop
    .done_y

    RTS
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
\*  Still more streamlined version of FASTLAY (STA only)
\*
\*-------------------------------

.beeb_plot_peel
{
    \ Select MOS 4K RAM as our sprite bank
    JSR swr_select_mos4k

    \ Can't use PREPREP or setimage here as no TABLE!
    \ Assume IMAGE has been set correctly

    ldy #0
    lda (IMAGE),y
    sta WIDTH

    iny
    lda (IMAGE),y
    sta HEIGHT

    \ OFFSET IGNORED
    \ OPACITY IGNORED
    \ MIRROR IGNORED
    \ CLIPPING IGNORED

    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)

    \ Convert to Beeb screen layout

    \ Mask off Y offset

    LDA YCO
    AND #&F8
    TAY    

    \ Look up Beeb screen address

    LDX XCO
    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA scrn_addr+1
    LDA Mult16_HI,X
    ADC YHI,Y
    STA scrn_addr+2

    \ Set sprite data address 

    CLC
    LDA IMAGE
    ADC #2
    STA beeb_readptr
    LDA IMAGE+1
    ADC #0
    STA beeb_readptr+1

    \ Simple Y clip
    SEC
    LDA YCO
    SBC HEIGHT
    BCS no_yclip

    LDA #LO(-1)
    .no_yclip
    STA smTOP+1

    \ Store height

    LDA YCO
    STA beeb_height

    \ Y offset into character row

    AND #&7
    TAX

    \ Plot loop

    LDA WIDTH
    ASL A
    STA VISWIDTH

    .yloop
    STX beeb_yoffset

    LDA VISWIDTH
    STA beeb_width          ; bytes_per_line_on_screen

    LDY #0
    CLC

    .xloop

    LDA (beeb_readptr), Y
    INY

    .scrn_addr
    STA &FFFF, X

    TXA                     ; next char column [6c]
    ADC #8    
    TAX

    DEC beeb_width
    BNE xloop
    
    .done_x
    LDA beeb_height
    DEC A
    .smTOP
    CMP #0
    BEQ done_y
    STA beeb_height

    \ Completed a line - next row of sprite data

    CLC
    LDA beeb_readptr
    ADC VISWIDTH
    STA beeb_readptr
    LDA beeb_readptr+1
    ADC #0
    STA beeb_readptr+1

    \ Next scanline

    LDX beeb_yoffset
    DEX
    BPL yloop

    \ Next character row

    SEC
    LDA scrn_addr+1
    SBC #LO(BEEB_SCREEN_ROW_BYTES)
    STA scrn_addr+1
    LDA scrn_addr+2
    SBC #HI(BEEB_SCREEN_ROW_BYTES)
    STA scrn_addr+2

    LDX #7
    BNE yloop
    .done_y

    RTS
}


\*-------------------------------
; Beeb screen multiplication tables

IF 0
.Mult7_LO
FOR n,0,39,1
EQUB LO(n*7)
NEXT
.Mult7_HI
FOR n,0,39,1
EQUB HI(n*7)
NEXT
ENDIF

.Mult16_LO
FOR n,0,39,1
EQUB LO(n*16)
NEXT
.Mult16_HI          ; or shift...
FOR n,0,39,1
EQUB HI(n*16)
NEXT

\*-------------------------------
; New sprite routines - 2bpp expanded to MODE 2

.beeb_plot_sprite_LAY
{
 lda OPACITY
 bpl notmirr

 and #$7f
\ BEEB TEMP
\ sta OPACITY
 jmp beeb_plot_sprite_MLAY

.notmirr\ cmp #enum_eor
\ bne label_1
\ jmp LayXOR

.label_1 cmp #enum_mask
 bcc label_2
 jmp beeb_plot_sprite_LayMask

.label_2 jmp beeb_plot_sprite_LayGen
}

.beeb_plot_sprite_LayGen
{
    \ Get sprite data address 

    JSR beeb_PREPREP

    lda OPACITY
    BPL dont_reverse

    LDA XCO
    SEC
    SBC WIDTH
    STA XCO
    .dont_reverse

    \ CLIP here

    JSR CROP
    bpl cont
    jmp DONE
    .cont

    \ Check NULL sprite

    LDA VISWIDTH
    BNE width_ok
    JMP DONE
    .width_ok

    \ Set palette

\    JSR beeb_plot_sprite_SetPalette

    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)
    \ OFFSET (0-3) - maybe 0,1 or 8,9?

    \ Beeb screen address

    \ Mask off Y offset to get character row

    LDA YCO
    AND #&F8
    TAY    

    LDX XCO
    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16_HI,X
    ADC YHI,Y
    STA beeb_writeptr+1

    LDA YCO
    AND #&7
    STA beeb_yoffset            ; think about using y remaining counter cf Thrust

\ Handle OFFSET

    LDA OFFSET
    AND #&04
    ASL A
    CLC
    ADC beeb_writeptr
    STA beeb_writeptr
    LDA beeb_writeptr+1
    ADC #0
    STA beeb_writeptr+1

    LDA OFFSET
    LSR A
    AND #&1
    STA beeb_rem                ; this is parity

    ROR A
    ROR A           ; put parity into &80
    EOR OPACITY     ; mirror reverses parity
    BPL no_swap

\ L&R pixels need to be swapped over

    JSR beeb_plot_sprite_FlipPalette

    .no_swap

    LDX #OPCODE_INX
    lda OPACITY
    BPL not_mirrored

    \ INX -> DEX
    LDX #OPCODE_DEX

    .not_mirrored
    STX smSTACKdir1: STX smSTACKdir2

    AND #&7f    ;hi bit off
    TAX

    \ Self-mod code
    \ BEEB TEMP until MASK implemented

    CPX #enum_mask
    BNE enum_ok
    LDX #enum_sta
    .enum_ok

    \ Not even sure this is correct for MODE 2?

    lda OPCODE,x
    sta smod

    \ Set sprite data address 

    LDA IMAGE
    STA sprite_addr+1
    LDA IMAGE+1
    STA sprite_addr+2
    
    \ Simple Y clip
    SEC
    LDA YCO
    SBC HEIGHT
    BCS no_yclip

    LDA #LO(-1)
    .no_yclip
    STA smTOP+1

    TSX
    STX beeb_stack_ptr          ; use this to reset stack

.plot_lines_loop

    LDY WIDTH
    DEY                     ; bytes_per_line_in_sprite

\ Decode a line of sprite data using Exile method!

\ Push a zero on the end in case of parity

    LDA #0
    PHA

    .line_loop

    .sprite_addr
    LDA &FFFF, Y
    STA beeb_data
    AND #&11
    TAX
.smPIXELD
    LDA map_2bpp_to_mode2_pixel,X         ; could be in ZP ala Exile to save 2cx4=8c per sprite byte
    PHA                                 ; [3c]
    LDA beeb_data
    AND #&22
    TAX
.smPIXELC
    LDA map_2bpp_to_mode2_pixel,X
    PHA
    LDA beeb_data
    LSR A
    LSR A
    STA beeb_data
    AND #&11
    TAX
.smPIXELB
    LDA map_2bpp_to_mode2_pixel,X
    PHA
    LDA beeb_data
    AND #&22
    TAX
.smPIXELA
    LDA map_2bpp_to_mode2_pixel,X
    PHA
    DEY
    BPL line_loop

\ How many bytes to plot?

    LDA VISWIDTH
    ASL A           ; bytes_per_line_on_screen - can precompute
    STA beeb_width

\ If parity push an extra blank

    LDA beeb_rem
    BEQ no_extra
    LDA #0
    PHA
    INC beeb_width  ; and extra byte
    .no_extra

\ Not sure how Exile does this?

    TSX
    STX smSTACK1+1
    STX smSTACK2+1

\ None of this needs to happen each loop!

\ Sort out where to start in the stack lookup

    LDA OFFLEFT
    ASL A
    TAX

    LDA OPACITY
    BPL not_reversed
    LDA beeb_width
    SEC
    SBC OFFRIGHT
    ASL A
    INC A
    TAX
    .not_reversed

\ Now plot that data to the screen

    LDY beeb_yoffset
    CLC

.plot_screen_loop

    .smSTACKdir1
    INX
.smSTACK1
    LDA &100,X

    .smSTACKdir2
    INX
.smSTACK2
    ORA &100,X

\ Plotting mode here

    .smod
    STA (beeb_writeptr), Y

\ Write to screen

    STA (beeb_writeptr), Y

\ Next screen byte across

    TYA
    ADC #8
    TAY

    DEC beeb_width
    BNE plot_screen_loop

    LDX beeb_stack_ptr
    TXS

    LDA YCO
    DEC A
    .smTOP
    CMP #LO(-1)
    STA YCO
    BEQ done_y

\ Move to next sprite data row

    CLC
    LDA sprite_addr+1
    ADC WIDTH
    STA sprite_addr+1
    LDA sprite_addr+2
    ADC #0
    STA sprite_addr+2

\ Next scanline

    DEC beeb_yoffset
    BMI next_char_row
    JMP plot_lines_loop

\ Need to move up a screen char row

    .next_char_row
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr+1

    LDY #7
    STY beeb_yoffset
    JMP plot_lines_loop

\ Reset stack before we leave

    .done_y
    JMP DONE
}


.beeb_plot_sprite_LayMask
{
    \ Get sprite data address 

    JSR beeb_PREPREP

    lda OPACITY
    BPL dont_reverse

    LDA XCO
    SEC
    SBC WIDTH
    STA XCO
    .dont_reverse

    \ CLIP here

    JSR CROP
    bpl cont
    jmp DONE
    .cont

    \ Check NULL sprite

    LDA VISWIDTH
    BNE width_ok
    JMP DONE
    .width_ok

    \ Set palette

\    JSR beeb_plot_sprite_SetPalette

    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)
    \ OFFSET (0-3) - maybe 0,1 or 8,9?

    \ Beeb screen address

    \ Mask off Y offset to get character row

    LDA YCO
    AND #&F8
    TAY    

    LDX XCO
    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16_HI,X
    ADC YHI,Y
    STA beeb_writeptr+1

    LDA YCO
    AND #&7
    STA beeb_yoffset            ; think about using y remaining counter cf Thrust

\ Handle OFFSET

    LDA OFFSET
    AND #&04
    ASL A
    CLC
    ADC beeb_writeptr
    STA beeb_writeptr
    LDA beeb_writeptr+1
    ADC #0
    STA beeb_writeptr+1

    LDA OFFSET
    LSR A
    AND #&1
    STA beeb_rem                ; this is parity

    ROR A
    ROR A           ; put parity into &80
    EOR OPACITY     ; mirror reverses parity
    BPL no_swap

\ L&R pixels need to be swapped over

    JSR beeb_plot_sprite_FlipPalette

    .no_swap

    LDX #OPCODE_INX
    lda OPACITY
    BPL not_mirrored

    \ INX -> DEX
    LDX #OPCODE_DEX

    .not_mirrored
    STX smSTACKdir1: STX smSTACKdir2

    AND #&7f    ;hi bit off
    TAX

    \ Self-mod code

    \ Not even sure this is correct for MODE 2?

\    lda OPCODE,x
\    sta smod

    \ Set sprite data address 

    LDA IMAGE
    STA sprite_addr+1
    LDA IMAGE+1
    STA sprite_addr+2
    
    \ Simple Y clip
    SEC
    LDA YCO
    SBC HEIGHT
    BCS no_yclip

    LDA #LO(-1)
    .no_yclip
    STA smTOP+1

    TSX
    STX beeb_stack_ptr          ; use this to reset stack

.plot_lines_loop

    LDY WIDTH
    DEY                     ; bytes_per_line_in_sprite

\ Decode a line of sprite data using Exile method!

\ Push a zero on the end in case of parity

    LDA #0
    PHA

    .line_loop

    .sprite_addr
    LDA &FFFF, Y
    STA beeb_data
    AND #&11
    TAX
.smPIXELD
    LDA map_2bpp_to_mode2_pixel,X         ; could be in ZP ala Exile to save 2cx4=8c per sprite byte
\    ORA map_2bpp_to_left_mask,X
    PHA                                 ; [3c]
    LDA beeb_data
    AND #&22
    TAX
.smPIXELC
    LDA map_2bpp_to_mode2_pixel,X
\    ORA map_2bpp_to_right_mask,X
    PHA
    LDA beeb_data
    LSR A
    LSR A
    STA beeb_data
    AND #&11
    TAX
.smPIXELB
    LDA map_2bpp_to_mode2_pixel,X
\    ORA map_2bpp_to_left_mask,X
    PHA
    LDA beeb_data
    AND #&22
    TAX
.smPIXELA
    LDA map_2bpp_to_mode2_pixel,X
\    ORA map_2bpp_to_right_mask,X
    PHA
    DEY
    BPL line_loop

\ How many bytes to plot?

    LDA VISWIDTH
    ASL A           ; bytes_per_line_on_screen - can precompute
    STA beeb_width

\ If parity push an extra blank

    LDA beeb_rem
    BEQ no_extra
    LDA #0
    PHA
    INC beeb_width  ; and extra byte
    .no_extra

\ Not sure how Exile does this?

    TSX
    STX smSTACK1+1
    STX smSTACK2+1

\ None of this needs to happen each loop!

\ Sort out where to start in the stack lookup

    LDA OFFLEFT
    ASL A
    TAX

    LDA OPACITY
    BPL not_reversed
    LDA beeb_width
    SEC
    SBC OFFRIGHT
    ASL A
    INC A
    TAX
    .not_reversed

\ Now plot that data to the screen

    LDY beeb_yoffset
    CLC

.plot_screen_loop

    .smSTACKdir1
    INX
.smSTACK1
    LDA &100,X

    .smSTACKdir2
    INX
.smSTACK2
    ORA &100,X

    STA load_mask+1
    .load_mask
    LDA mask_table
    
\ Plotting mode here

    .smod
    AND (beeb_writeptr), Y

\ OR in sprite byte

    ORA load_mask+1

\ Write to screen

    STA (beeb_writeptr), Y

\ Next screen byte across

    TYA
    ADC #8
    TAY

    DEC beeb_width
    BNE plot_screen_loop

    LDX beeb_stack_ptr
    TXS

    LDA YCO
    DEC A
    .smTOP
    CMP #LO(-1)
    STA YCO
    BEQ done_y

\ Move to next sprite data row

    CLC
    LDA sprite_addr+1
    ADC WIDTH
    STA sprite_addr+1
    LDA sprite_addr+2
    ADC #0
    STA sprite_addr+2

\ Next scanline

    DEC beeb_yoffset
    BMI next_char_row
    JMP plot_lines_loop

\ Need to move up a screen char row

    .next_char_row
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr+1

    LDY #7
    STY beeb_yoffset
    JMP plot_lines_loop

\ Reset stack before we leave

    .done_y
    JMP DONE
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
\ cmp #enum_eor
\ bne label_1
\ jmp MLayXOR

.label_1 cmp #enum_mask
 bcc label_2
 jmp beeb_plot_sprite_LayMask               ; could be MLayMask custom fn

.label_2 jmp beeb_plot_sprite_LayGen        ; could be MLayGen custom fn
}


.beeb_plot_sprite_SetPalette
{
    \ Set palette

    LDA #&10:STA map_2bpp_to_mode2_pixel+&01
    LDA #&20:STA map_2bpp_to_mode2_pixel+&02
    LDA #&40:STA map_2bpp_to_mode2_pixel+&10
    LDA #&50:STA map_2bpp_to_mode2_pixel+&11
    LDA #&80:STA map_2bpp_to_mode2_pixel+&20
    LDA #&A0:STA map_2bpp_to_mode2_pixel+&22

    RTS
}

\ Top 4-bits are colour 3
\ Bottom 4-bits are lookup into pixel pairs for colours 1 & 2
\ Colour 0 always black
.beeb_plot_sprite_SetExilePalette
{
    TAX
    LSR A                     
    LSR A
    LSR A
    LSR A
    TAY                         ; Y = primary colour 

    LDA pixel_table,Y           ; map primary colour (0-15) to Mode 2
                                ; pixel value with that colour in both
                                ; pixels
    AND #$55                    
    STA map_2bpp_to_mode2_pixel+$11                     ; &11 - primary colour right pixel
    ASL A                       
    STA map_2bpp_to_mode2_pixel+$22                     ; &22 - primary colour left pixel
    
    TXA
    AND #$0F                    ; Y = (palette>>0)&15 - pair index
    TAY
    LDA palette_value_to_pixel_lookup,Y ; get pair
    TAY                         
    AND #$55                    ; get right pixel
    STA map_2bpp_to_mode2_pixel+$01                     ; right 1
    ASL A
    STA map_2bpp_to_mode2_pixel+$02                     ; left 1
    TYA
    AND #$AA                    ; get left pixel
    STA map_2bpp_to_mode2_pixel+$20                     ; left 2
    LSR A
    STA map_2bpp_to_mode2_pixel+$10                     ; right 2
    
    RTS
}

.beeb_plot_sprite_FlipPalette
{
\ L&R pixels need to be swapped over

    LDA map_2bpp_to_mode2_pixel+&02: LDY map_2bpp_to_mode2_pixel+&01
    STA map_2bpp_to_mode2_pixel+&01: STY map_2bpp_to_mode2_pixel+&02

    LDA map_2bpp_to_mode2_pixel+&20: LDY map_2bpp_to_mode2_pixel+&10
    STA map_2bpp_to_mode2_pixel+&10: STY map_2bpp_to_mode2_pixel+&20

    LDA map_2bpp_to_mode2_pixel+&22: LDY map_2bpp_to_mode2_pixel+&11
    STA map_2bpp_to_mode2_pixel+&11: STY map_2bpp_to_mode2_pixel+&22

    RTS    
}


.beeb_plot_sprite_LayGen_NoCrop
{
    \ Get sprite data address 

    JSR beeb_PREPREP

    \ Check NULL sprite

    LDA WIDTH
    BNE width_ok
    JMP DONE
    .width_ok

\    JSR beeb_plot_sprite_SetPalette

    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)
    \ OFFSET (0-3) - maybe 0,1 or 8,9?

    \ Beeb screen address

    \ Mask off Y offset to get character row

    LDA YCO
    AND #&F8
    TAY    

    LDX XCO
    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16_HI,X
    ADC YHI,Y
    STA beeb_writeptr+1

    LDA YCO
    AND #&7
    STA beeb_yoffset            ; think about using y remaining counter cf Thrust

\ Handle OFFSET

    LDA OFFSET
    AND #&04
    ASL A
    CLC
    ADC beeb_writeptr
    STA beeb_writeptr
    LDA beeb_writeptr+1
    ADC #0
    STA beeb_writeptr+1

    LDA OFFSET
    LSR A
    AND #&1
    STA beeb_rem                ; this is parity

    ROR A
    ROR A           ; put parity into &80
    EOR OPACITY     ; mirror reverses parity
    BPL no_swap

\ L&R pixels need to be swapped over

    JSR beeb_plot_sprite_FlipPalette

    .no_swap

    LDX #OPCODE_INX
    lda OPACITY
    BPL not_mirrored

    \ INX -> DEX
    LDX #OPCODE_DEX

    .not_mirrored
    STX smSTACKdir1: STX smSTACKdir2

    AND #&7f    ;hi bit off
    TAX

    \ Self-mod code

    \ Not even sure this is correct for MODE 2?

    lda OPCODE,x
    sta smod

    \ Set sprite data address 

    LDA IMAGE
    STA sprite_addr+1
    LDA IMAGE+1
    STA sprite_addr+2
    
    \ Simple Y clip
    SEC
    LDA YCO
    SBC HEIGHT
    BCS no_yclip

    LDA #LO(-1)
    .no_yclip
    STA smTOP+1

    TSX
    STX beeb_stack_ptr          ; use this to reset stack

.plot_lines_loop

    LDY WIDTH
    DEY                     ; bytes_per_line_in_sprite

\ Decode a line of sprite data using Exile method!

\ Push a zero on the end in case of parity

    LDA #0
    PHA

    .line_loop

    .sprite_addr
    LDA &FFFF, Y
    TAX
    AND #&11
    STA smPIXELD+1
.smPIXELD
    LDA map_2bpp_to_mode2_pixel         ; could be in ZP ala Exile to save 2cx4=8c per sprite byte
    PHA                                 ; [3c]
    TXA
    AND #&22
    STA smPIXELC+1
.smPIXELC
    LDA map_2bpp_to_mode2_pixel
    PHA
    TXA
    LSR A
    LSR A
    TAX
    AND #&11
    STA smPIXELB+1
.smPIXELB
    LDA map_2bpp_to_mode2_pixel
    PHA
    TXA
    AND #&22
    STA smPIXELA+1
.smPIXELA
    LDA map_2bpp_to_mode2_pixel
    PHA
    DEY
    BPL line_loop

\ How many bytes to plot?

    LDA WIDTH
    ASL A           ; bytes_per_line_on_screen - can precompute
    STA beeb_width

\ If parity push an extra blank

    LDA beeb_rem
    BEQ no_extra
    LDA #0
    PHA
    INC beeb_width  ; and extra byte
    .no_extra

\ Not sure how Exile does this?

    TSX
    STX smSTACK1+1
    STX smSTACK2+1

\ None of this needs to happen each loop!

\ Sort out where to start in the stack lookup

    LDX #0

    LDA OPACITY
    BPL not_reversed
    LDA beeb_width
    ASL A
    INC A
    TAX
    .not_reversed

\ Now plot that data to the screen

    LDY beeb_yoffset
    CLC

.plot_screen_loop

    .smSTACKdir1
    INX
.smSTACK1
    LDA &100,X

    .smSTACKdir2
    INX
.smSTACK2
    ORA &100,X

\ Plotting mode here

    .smod
    STA (beeb_writeptr), Y

\ Write to screen

    STA (beeb_writeptr), Y

\ Next screen byte across

    TYA
    ADC #8
    TAY

    DEC beeb_width
    BNE plot_screen_loop

    LDX beeb_stack_ptr
    TXS

    LDA YCO
    DEC A
    .smTOP
    CMP #LO(-1)
    STA YCO
    BEQ done_y

\ Move to next sprite data row

    CLC
    LDA sprite_addr+1
    ADC WIDTH
    STA sprite_addr+1
    LDA sprite_addr+2
    ADC #0
    STA sprite_addr+2

\ Next scanline

    DEC beeb_yoffset
    BMI next_char_row
    JMP plot_lines_loop

\ Need to move up a screen char row

    .next_char_row
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr+1

    LDY #7
    STY beeb_yoffset
    JMP plot_lines_loop

\ Reset stack before we leave

    .done_y
    JMP DONE
}


PAGE_ALIGN
.map_2bpp_to_mode2_pixel            ; background
{
    EQUB &00                        ; 00000000 either pixel logical 0
    EQUB &10                        ; 000A000a right pixel logical 1
    EQUB &20                        ; 00B000b0 left pixel logical 1

    skip &0D

    EQUB &40                        ; 000A000a right pixel logical 2
    EQUB &50                        ; 000A000a right pixel logical 3

    skip &0E

    EQUB &80                        ; 00B000b0 left pixel logical 2
    skip 1
    EQUB &A0                        ; 00B000b0 left pixel logical 3
}
\\ Flip entries in this table when parity changes


\*-------------------------------
; Clear Beeb screen buffer

.beeb_CLS
{
\\ Ignore PAGE as no page flipping yet

  ldx #HI(BEEB_SCREEN_SIZE)
  lda #HI(beeb_screen_addr)

  sta loop+2
  lda #0
  ldy #0
  .loop
  sta &3000,Y
  iny
  bne loop
  inc loop+2
  dex
  bne loop
  rts
}

.bank_to_palette_temp
{
    EQUB &71            \ bg
    EQUB &72            \ chtab13
    EQUB &72            \ chtab25
    EQUB &72            \ chtab467
}

.palette_value_to_pixel_lookup
{
    EQUB &07                        ; red / yellow
    EQUB &34                        ; blue / cyan
    EQUB &23                        ; magenta / red
\    equb $CA                        ; yellow bg, black bg
\    equb $C9                        ; green bg, red bg
\    equb $E3                        ; magenta bg, red bg
    equb $E9                        ; cyan bg, red bg
    equb $EB                        ; white bg, red bg
    equb $CE                        ; yellow bg, green bg
    equb $F8                        ; cyan bg, blue bg
    equb $E6                        ; magenta bg, green bg
    equb $CC                        ; green bg, green bg
    equb $EE                        ; white bg, green bg
    equb $30                        ; blue fg, blue fg
    equb $DE                        ; yellow bg, cyan bg
    equb $EF                        ; white bg, yellow bg
    equb $CB                        ; yellow bg, red bg
    equb $FB                        ; white bg, magenta bg
    equb $FE                        ; white bg, cyan bg
}

.pixel_table
{
    ;                                 ABCDEFGH
    equb $00                        ; 00000000 0  0  
    equb $03                        ; 00000011 1  1  
    equb $0C                        ; 00001100 2  2  
    equb $0F                        ; 00001111 3  3  
    equb $30                        ; 00110000 4  4  
    equb $33                        ; 00110011 5  5  
    equb $3C                        ; 00111100 6  6  
    equb $3F                        ; 00111111 7  7  
    equb $C0                        ; 11000000 8  8  
    equb $C3                        ; 11000011 9  9  
    equb $CC                        ; 11001100 10 10
    equb $CF                        ; 11001111 11 11
    equb $F0                        ; 11110000 12 12
    equb $F3                        ; 11110011 13 13
    equb $FC                        ; 11111100 14 14
    equb $FF                        ; 11111111 15 15
}

PAGE_ALIGN
.mask_table
FOR byte,0,255,1
left=byte AND &AA
right=byte AND &55

IF left = 0

    IF right = 0
        EQUB &FF
    ELSE
        EQUB &AA
    ENDIF

ELSE

    IF right = 0
        EQUB &55
    ELSE
        EQUB &00
    ENDIF

ENDIF

NEXT

.beeb_plot_end
