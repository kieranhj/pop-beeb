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
\ Implement clipping and mirroring
\ Implement special XOR
\ Speed it up massively :(

.beeb_plot_start

.beeb_PREPREP
{
    \\ Must have a swram bank to select or assert
    LDA BANK
    CMP #4
    BCC slot_set
    BRK                 ; swram slot for sprite not set!
    .slot_set
    JSR swr_select_slot

    \ Turns TABLE & IMAGE# into IMAGE ptr
    \ Obtains WIDTH & HEIGHT
    
    JMP PREPREP
}

IF 0
.beeb_plot_apple_mode_4
{
    \\ From hires_LAY
    lda OPACITY
    bpl notmirr

    and #$7f
    sta OPACITY

\    jmp beeb_plot_MLAY

    .notmirr
    
    \ BEEB TEMP
    CMP #5
    BCC opacity_valid
    BRK
    .opacity_valid

    cmp #enum_eor
    bne label_1
\    jmp beeb_plot_LayXOR

    .label_1 cmp #enum_mask
    bcc label_2
    
    jmp beeb_plot_apple_mode_4_mask

    .label_2
    \ This is LayGen

    JSR beeb_PREPREP

    \ Check NULL sprite

    LDA WIDTH
    BNE width_ok
    JMP return
    .width_ok
    STA beeb_temp_width

    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)

    \ Convert to Beeb screen layout

    \ Mask off Y offset

    LDA YCO
    AND #&F8
    TAY    
    
    \ BEEB TEMP
    LDA OFFSET
    CMP #7
    BCC offset_ok
    BRK
    .offset_ok    

    \ Look up Beeb screen address w/ OFFSET

    LDX XCO
    CLC
    LDA Mult7_LO,X
    ADC OFFSET
    STA beeb_readptr            ; temp var LO(xpos)
    LDA Mult7_HI,X
    ADC #0
    STA beeb_readptr+1          ; temp var HI(xpos)

    \ beeb_readptr is now xpos [0-279]
    LDA beeb_readptr
    AND #&7
    STA beeb_rem                ; this is now our shift

    LDA beeb_readptr
    AND #&F8
    CLC
    ADC YLO, Y
    STA beeb_writeptr
    LDA beeb_readptr+1
    ADC YHI, Y
    STA beeb_writeptr+1

    \ Complicated SHIFT and CARRY tables :S

    LDX beeb_rem
    LDA SHIFTL,X
    STA smSHIFT+1
    STA smSHIFT2+1
    LDA SHIFTH,X
    STA smSHIFT+2
    STA smSHIFT2+2

    LDA CARRYL,X
    STA smCARRY+1
    LDA CARRYH,X
    STA smCARRY+2

    LDA CARRY_MASK, X
    STA smCARRY_MASK+1

    CPX #1
    BNE shift_not_1
    
    \ Shift 1 special case
    LDA CARRY_MASK1, X
    STA smCARRY_MASK+1

    .shift_not_1

    CPX WIDTH
    BCS width_plus_carryover

    \ Shift < Width special case

    DEC beeb_temp_width
    \ sm=(&FF<<W)>>S

    \ Special MASK derived from WIDTH
    LDA beeb_temp_width
    ASL A: ASL A: ASL A     ; x8
    CLC
    ADC #LO(SPECIAL_MASK1)
    STA special_mask_read+1
    LDA #HI(SPECIAL_MASK1)
    ADC #0
    STA special_mask_read+2

    .special_mask_read
    LDA SPECIAL_MASK1, X
    STA smSHIFT_MASK+1

    JMP switch_blend

    .width_plus_carryover

    \ Shift MASK derived from WIDTH
    LDA WIDTH
    ASL A: ASL A: ASL A     ; x8
    CLC
    ADC #LO(SHIFT_MASK)
    STA shift_mask_read+1
    LDA #HI(SHIFT_MASK)
    ADC #0
    STA shift_mask_read+2

    .shift_mask_read
    LDA SHIFT_MASK, X
    STA smSHIFT_MASK+1

    \ Switch blend mode
    .switch_blend

    ldx OPACITY ;hi bit off!

    \ Self-mod code

    lda OPCODE,x
    sta smod
    sta smod2

    \ Set sprite data address 

    LDA IMAGE
    STA sprite_addr+1
    STA sprite_addr2+1
    LDA IMAGE+1
    STA sprite_addr+2
    STA sprite_addr2+2

    \ Simple Y clip
    SEC
    LDA YCO
    SBC HEIGHT
    BCS no_yclip

    LDA #LO(-1)
    .no_yclip
    STA smTOP+1
    
    \ Now in Beeb formt in column order

    LDX #0                  ; index sprite data

    \ Store width & height (or just use directly?)

    LDA YCO
    STA beeb_height

    \ Y offset into character row

    AND #&7
    TAY

    .yloop
    STY beeb_yoffset

    \ Initialise carry with byte from screen masked appropriately
    .smCARRY_MASK
    LDA #0
    AND (beeb_writeptr), Y
    STA beeb_next_carry

    LDA beeb_temp_width
    BEQ done_x              ; nothing to do!
    STA beeb_width

    CLC

    .xloop
    STY beeb_temp_y

    LDA beeb_next_carry
    STA beeb_carry

    .sprite_addr
    LDY &FFFF, X            ; now beeb data
    INX                     ; next sprite byte

    .smCARRY
    LDA &FFFF, Y            ; carry N
    STA beeb_next_carry

    .smSHIFT
    LDA &FFFF, Y            ; shift N
    ORA beeb_carry

    \\ Would need to jump out of the loop here to carryover if shift<width && beeb_width==1 - doh!

    LDY beeb_temp_y

    .smod ORA (beeb_writeptr), Y
    STA (beeb_writeptr), Y

    TYA                     ; next char column [6c]
    ADC #8    
    TAY

    DEC beeb_width
    BNE xloop

    .done_x

    \ If shift<width
    LDA WIDTH
    CMP beeb_temp_width
    BEQ regular_carry

    \ We had one less loop - need to derive carryover
    STY beeb_temp_y

    .sprite_addr2
    LDY &FFFF, X            ; now beeb data
    INX

    .smSHIFT2
    LDA &FFFF, Y            ; shift N
    ORA beeb_next_carry
    STA beeb_next_carry   

    LDY beeb_temp_y
    .regular_carry

    \ Flush the carry over

    .smSHIFT_MASK
    LDA #0
    CMP #&FF
    BEQ no_carryover

    AND (beeb_writeptr), Y
    ORA beeb_next_carry
\    ora (beeb_writeptr),y   ; always ORA last byte because of 7 vs 8 pixel alignment?
    \ Needs to also have the operand mod
    .smod2 ORA (beeb_writeptr), Y
    STA (beeb_writeptr), Y

    .no_carryover

    \ Done a row

    LDY beeb_height
    DEY
    .smTOP
    CPY #0
    BEQ done_y
    STY beeb_height

    LDY beeb_yoffset
    DEY                     ; next line
    BPL yloop

    \ Need to move up a char row

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr+1

    LDY #7
    BNE yloop

    .done_y

    .return
    RTS
}


.beeb_plot_apple_mode_4_mask
{
    JSR beeb_PREPREP

    \ Check NULL sprite

    LDA WIDTH
    BNE width_ok
    JMP return
    .width_ok
    STA beeb_temp_width

    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)

    \ Convert to Beeb screen layout

    \ Mask off Y offset

    LDA YCO
    AND #&F8
    TAY    
    
    \ Look up Beeb screen address w/ OFFSET

    LDX XCO
    CLC
    LDA Mult7_LO,X
    ADC OFFSET
    STA beeb_readptr            ; temp var LO(xpos)
    LDA Mult7_HI,X
    ADC #0
    STA beeb_readptr+1          ; temp var HI(xpos)

    \ beeb_readptr is now xpos [0-279]
    LDA beeb_readptr
    AND #&7
    STA beeb_rem                ; this is now our shift

    LDA beeb_readptr
    AND #&F8
    CLC
    ADC YLO, Y
    STA beeb_writeptr
    LDA beeb_readptr+1
    ADC YHI, Y
    STA beeb_writeptr+1

    \ Complicated SHIFT and CARRY tables :S
  
    LDX beeb_rem
    LDA SHIFTL,X
    STA smSHIFT+1
    STA smSHIFT2+1
    LDA SHIFTH,X
    STA smSHIFT+2
    STA smSHIFT2+2

    LDA CARRYL,X
    STA smCARRY+1
    LDA CARRYH,X
    STA smCARRY+2

    LDA CARRY_MASK, X
    STA smCARRY_MASK+1

    CPX #1
    BNE shift_not_1
    
    \ Shift 1 special case
    LDA CARRY_MASK1, X
    STA smCARRY_MASK+1

    .shift_not_1

    CPX WIDTH
    BCS width_plus_carryover

    \ Shift < Width special case

    DEC beeb_temp_width
    \ sm=(&FF<<W)>>S

    \ Special MASK derived from WIDTH
    LDA beeb_temp_width
    ASL A: ASL A: ASL A     ; x8
    CLC
    ADC #LO(SPECIAL_MASK1)
    STA special_mask_read+1
    LDA #HI(SPECIAL_MASK1)
    ADC #0
    STA special_mask_read+2

    .special_mask_read
    LDA SPECIAL_MASK1, X
    STA smSHIFT_MASK+1

    JMP switch_blend

    .width_plus_carryover

    \ Shift MASK derived from WIDTH
    LDA WIDTH
    ASL A: ASL A: ASL A     ; x8
    CLC
    ADC #LO(SHIFT_MASK)
    STA shift_mask_read+1
    LDA #HI(SHIFT_MASK)
    ADC #0
    STA shift_mask_read+2

    .shift_mask_read
    LDA SHIFT_MASK, X
    STA smSHIFT_MASK+1

    \ Switch blend mode
    .switch_blend

    ldx OPACITY ;hi bit off!

    \ Self-mod code

    lda OPCODE,x
    sta smod
    sta smod2

    \ Set sprite data address 

    LDA IMAGE
    STA sprite_addr+1
    STA sprite_addr2+1
    LDA IMAGE+1
    STA sprite_addr+2
    STA sprite_addr2+2

    \ Simple Y clip
    SEC
    LDA YCO
    SBC HEIGHT
    BCS no_yclip

    LDA #LO(-1)
    .no_yclip
    STA smTOP+1
    
    \ Now in Beeb formt in column order

    LDX #0                  ; index sprite data

    \ Store width & height (or just use directly?)

    LDA YCO
    STA beeb_height

    \ Y offset into character row

    AND #&7
    TAY

    .yloop
    STY beeb_yoffset

    \ Initialise carry with byte from screen masked appropriately
    .smCARRY_MASK
    LDA #0
    AND (beeb_writeptr), Y
    STA beeb_next_carry

    LDA beeb_temp_width
    BEQ done_x              ; nothing to do!
    STA beeb_width

    CLC

    .xloop
    STY beeb_temp_y

    LDA beeb_next_carry
    STA beeb_carry

    .sprite_addr
    LDY &FFFF, X            ; now beeb data
    INX                     ; next sprite byte

    .smCARRY
    LDA &FFFF, Y            ; carry N
    STA beeb_next_carry

    .smSHIFT
    LDA &FFFF, Y            ; shift N
    ORA beeb_carry

    \\ Now have a byte to write
    STA imbyte

    \\ Convert it into a mask
    TAY
    LDA MASKTAB, Y

    LDY beeb_temp_y
    .smod AND (beeb_writeptr), Y  ; mask screen byte
    ORA imbyte      ; merge image byte
    STA (beeb_writeptr), Y

    TYA                     ; next char column [6c]
    ADC #8    
    TAY

    DEC beeb_width
    BNE xloop

    .done_x

    STY beeb_temp_y

    \ If shift<width
    LDA WIDTH
    CMP beeb_temp_width
    BEQ regular_carry

    \ We had one less loop - need to derive carryover
    .sprite_addr2
    LDY &FFFF, X            ; now beeb data
    INX

    .smSHIFT2
    LDA &FFFF, Y            ; shift N
    ORA beeb_next_carry
    STA beeb_next_carry   

    LDY beeb_temp_y
    .regular_carry

    \ Flush the carry over

    .smSHIFT_MASK
    LDA #0
    CMP #&FF
    BEQ no_carryover

    AND (beeb_writeptr), Y
    STA (beeb_writeptr), Y      ; actually screen byte

    \ Convert byte to mask
    LDY beeb_next_carry
    LDA MASKTAB, Y

    LDY beeb_temp_y
    .smod2 AND (beeb_writeptr), Y  ; mask screen byte
    ORA beeb_next_carry      ; merge image byte
    STA (beeb_writeptr), Y

    .no_carryover

    \ Done a row

    LDY beeb_height
    DEY
    .smTOP
    CPY #0
    BEQ done_y
    STY beeb_height

    LDY beeb_yoffset
    DEY                     ; next line
    BPL yloop

    \ Need to move up a char row

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr+1

    LDY #7
    JMP yloop

    .done_y

    .return
    RTS
}
ENDIF



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

.beeb_plot_sprite_LayGen
{
    \ Get sprite data address 

    JSR beeb_PREPREP

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

    LDA #&10:STA map_2bpp_to_mode2_pixel+&01
    LDA #&20:STA map_2bpp_to_mode2_pixel+&02
    LDA #&40:STA map_2bpp_to_mode2_pixel+&10
    LDA #&50:STA map_2bpp_to_mode2_pixel+&11
    LDA #&80:STA map_2bpp_to_mode2_pixel+&20
    LDA #&A0:STA map_2bpp_to_mode2_pixel+&22

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

    LDA map_2bpp_to_mode2_pixel+&02: LDY map_2bpp_to_mode2_pixel+&01
    STA map_2bpp_to_mode2_pixel+&01: STY map_2bpp_to_mode2_pixel+&02

    LDA map_2bpp_to_mode2_pixel+&20: LDY map_2bpp_to_mode2_pixel+&10
    STA map_2bpp_to_mode2_pixel+&10: STY map_2bpp_to_mode2_pixel+&20

    LDA map_2bpp_to_mode2_pixel+&22: LDY map_2bpp_to_mode2_pixel+&11
    STA map_2bpp_to_mode2_pixel+&11: STY map_2bpp_to_mode2_pixel+&22

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
    STX beeb_carry          ; use this to reset stack

.plot_lines_loop

    LDY WIDTH
    DEY                     ; bytes_per_line_in_sprite

\ Decode a line of sprite data using Exile method!

    LDX beeb_carry
    TXS

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
    LDX beeb_carry
    TXS

    .return
    JMP DONE
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

    \ Set palette

    LDA #&10:STA map_2bpp_to_mode2_pixel+&01
    LDA #&20:STA map_2bpp_to_mode2_pixel+&02
    LDA #&40:STA map_2bpp_to_mode2_pixel+&10
    LDA #&50:STA map_2bpp_to_mode2_pixel+&11
    LDA #&80:STA map_2bpp_to_mode2_pixel+&20
    LDA #&A0:STA map_2bpp_to_mode2_pixel+&22

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

    LDA map_2bpp_to_mode2_pixel+&02: LDY map_2bpp_to_mode2_pixel+&01
    STA map_2bpp_to_mode2_pixel+&01: STY map_2bpp_to_mode2_pixel+&02

    LDA map_2bpp_to_mode2_pixel+&20: LDY map_2bpp_to_mode2_pixel+&10
    STA map_2bpp_to_mode2_pixel+&10: STY map_2bpp_to_mode2_pixel+&20

    LDA map_2bpp_to_mode2_pixel+&22: LDY map_2bpp_to_mode2_pixel+&11
    STA map_2bpp_to_mode2_pixel+&11: STY map_2bpp_to_mode2_pixel+&22

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
    STX beeb_carry          ; use this to reset stack

.plot_lines_loop

    LDY WIDTH
    DEY                     ; bytes_per_line_in_sprite

\ Decode a line of sprite data using Exile method!

    LDX beeb_carry
    TXS

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
    LDX beeb_carry
    TXS

    .return
    JMP DONE
}


ALIGN &100
IF 0
.map_2bpp_to_mode2_pixel            ; foreground
{
    EQUB &00                        ; 00000000 either pixel logical 0
    EQUB &01                        ; 000A000a right pixel logical 1
    EQUB &02                        ; 00B000b0 left pixel logical 1

    skip &0D

    EQUB &04                        ; 000A000a right pixel logical 2
    EQUB &05                        ; 000A000a right pixel logical 3

    skip &0E

    EQUB &08                        ; 00B000b0 left pixel logical 2
    skip 1
    EQUB &0A                        ; 00B000b0 left pixel logical 3
}
ELSE
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
ENDIF
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


.beeb_plot_end
