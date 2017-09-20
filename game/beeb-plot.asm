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
    SBC #LO(BEEB_SCREEN_WIDTH)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_WIDTH)
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
    SBC #LO(BEEB_SCREEN_WIDTH)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_WIDTH)
    STA beeb_writeptr+1

    LDY #7
    JMP yloop

    .done_y

    .return
    RTS
}


IF 0
\ Plot sprite 1 Apple byte wide (7 pixels)
\ Depending on shift it may cover 1 or 2 Beeb screen bytes
\ If shift = 0 or shift = 1 then just 1 byte
\ If shift > 1 then covers 2 bytes
\ Don't want to plot the last bit of our byte
\ I.e. mask = &FE but shifted!
.beeb_plot_mode4_width1
{
    \ Enter with shift (mod) in X

    LDA SHIFTL,X
    STA smSHIFT+1
    LDA SHIFTH,X
    STA smSHIFT+2

    LDA CARRYL,X
    STA smCARRY+1
    LDA CARRYH,X
    STA smCARRY+2

    LDA CARRY_MASK_1, X
    STA smCARRY_MASK+1

    LDA SHIFT_MASK, X
    STA smSHIFT_MASK+1

    \ Switch blend mode

    ldx OPACITY ;hi bit off!

    \ Self-mod code

    lda OPCODE,x
    sta smod
    sta smod2

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

    \ We know beeb_width = 1

    \ Initialise carry with byte from screen masked appropriately
    .smCARRY_MASK
    LDA #0
    AND (beeb_writeptr), Y
    STA beeb_next_carry

    CLC

    .xloop
    STY beeb_temp_y

    LDA beeb_next_carry
    STA beeb_carry

    .sprite_addr
    LDA &FFFF, X            ; now beeb data
    TAY

    .smCARRY
    LDA &FFFF, Y            ; carry N
    STA beeb_next_carry

    .smSHIFT
    LDA &FFFF, Y            ; shift N
    ORA beeb_carry

    LDY beeb_temp_y

    .smod ORA (beeb_writeptr), Y
    STA (beeb_writeptr), Y

    INX                     ; next sprite byte

    TYA                     ; next char column [6c]
    ADC #8    
    TAY

    \ Know beeb_width = 1

    \ Flush the carry over but with one less bit
    \ Shift == 0 -> no carry over
    \ Shift == 1 -> no carry over
    \ Shift == 2 -> carry over = 1 bit
    \ Shift == 3 -> 2
    \ Shift == 4 -> 3
    \ Shift == 5 -> 4
    \ Shift == 6 -> 5
    \ Shift == 7 -> 6 bits

    .smSHIFT_MASK
    LDA #0
    AND (beeb_writeptr), Y
    ORA beeb_next_carry

    \ Needs to also have the operand mod
    .smod2 ORA (beeb_writeptr), Y
    STA (beeb_writeptr), Y

    .no_carry_pixels

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
    SBC #LO(BEEB_SCREEN_WIDTH)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_WIDTH)
    STA beeb_writeptr+1

    LDY #7
    BNE yloop

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
IF 0            \ need to implement sprite draw mirroring first!
    LDA XCO
    SEC
    SBC WIDTH
    STA XCO
ENDIF

    .normal
    inc WIDTH ;extra byte to cover shift right

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
    LDA Mult8_LO,X
    ADC YLO, Y
    STA beeb_readptr
    LDA Mult8_HI,X
    ADC YHI, Y
    STA beeb_readptr+1

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
    STA peel_addr+1
    LDA PEELBUF+1
    ADC #0
    STA peel_addr+2

    LDX #0                  ; index sprite data

    \ Y offset into character row

    LDA YCO
    AND #&7
    TAY

    .yloop
    STY beeb_yoffset

    LDA VISWIDTH
    STA beeb_width

    CLC

    .xloop
    LDA (beeb_readptr), Y

    .peel_addr
    STA &FFFF, X
    INX

    TYA                     ; next char column [6c]
    ADC #8    
    TAY

    DEC beeb_width
    BNE xloop
    
    .done_x
    DEC beeb_height
    BEQ done

    LDY beeb_yoffset
    DEY
    BPL yloop

    SEC
    LDA beeb_readptr
    SBC #LO(BEEB_SCREEN_WIDTH)
    STA beeb_readptr
    LDA beeb_readptr+1
    SBC #HI(BEEB_SCREEN_WIDTH)
    STA beeb_readptr+1

    LDY #7
    BNE yloop
    .done

    \ Must update PEELBUF on way out
    CLC
    TXA
    ADC peel_addr+1
    STA PEELBUF
    LDA peel_addr+2
    ADC #0
    STA PEELBUF+1

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
    LDA Mult8_LO,X
    ADC YLO, Y
    STA beeb_writeptr
    LDA Mult8_HI,X
    ADC YHI, Y
    STA beeb_writeptr+1

    \ Set sprite data address 

    CLC
    LDA IMAGE
    ADC #2
    STA sprite_addr+1
    LDA IMAGE+1
    ADC #0
    STA sprite_addr+2

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
    TAY

    \ Plot loop

    LDX #0          ; data index

    .yloop
    STY beeb_yoffset

    LDA WIDTH
    STA beeb_width

    CLC

    .xloop

    .sprite_addr
    LDA &FFFF, X
    INX

    STA (beeb_writeptr), Y

    TYA                     ; next char column [6c]
    ADC #8    
    TAY

    DEC beeb_width
    BNE xloop
    
    .done_x
    LDA beeb_height
    DEC A
    .smTOP
    CMP #0
    BEQ done_y
    STA beeb_height

    LDY beeb_yoffset
    DEY
    BPL yloop

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_WIDTH)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_WIDTH)
    STA beeb_writeptr+1

    LDY #7
    BNE yloop
    .done_y

    RTS
}


.beeb_plot_MLAY ;A = OPACITY
{
 cmp #enum_eor
 bne label_1
\ jmp beeb_plot_MLayXOR

.label_1 cmp #enum_mask
 bcc label_2
\ jmp beeb_plot_MLayMask

.label_2 jmp beeb_plot_MLayGen
}


.beeb_plot_MLayGen
{
    JSR beeb_PREPREP

    LDA XCO
    SEC
    SBC WIDTH
    STA XCO

\ Must implement CROP for mirror

    jsr CROP
    bpl cont
    jmp DONE
    .cont

    \ Check NULL sprite

    LDA VISWIDTH
    BNE width_ok
    JMP DONE
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

    LDX WIDTH                  ; index sprite data
    ; actually needs to be related to right cut

    \ Store width & height (or just use directly?)

    LDA YCO
    STA beeb_height

    \ Y offset into character row

    AND #&7
    TAY

    .yloop
    STY beeb_yoffset

    \ Initialise carry with byte from screen masked appropriately
    \ Should initialise carry from sprite data if clipped on that side...

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
    DEX                     ; next sprite byte
    LDY &FFFF, X            ; now beeb data

    \ Reverse bits for mirror
    LDA MIRROR, Y
    TAY

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
    DEX
    LDY &FFFF, X            ; now beeb data

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

    \ Sprite data read backwards

    TXA
    CLC
    ADC VISWIDTH            ; we just plotted this many
    ADC WIDTH               ; now go up a line of sprite data
    TAX

    LDY beeb_yoffset
    DEY                     ; next line
    BPL yloop

    \ Need to move up a char row

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_WIDTH)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_WIDTH)
    STA beeb_writeptr+1

    LDY #7
    BNE yloop

    .done_y

    .return
    RTS
}


\*-------------------------------
; Beeb screen multiplication tables

.Mult7_LO
FOR n,0,39,1
EQUB LO(n*7)
NEXT
.Mult7_HI
FOR n,0,39,1
EQUB HI(n*7)
NEXT

.Mult8_LO
FOR n,0,39,1
x=(n * 7) DIV 8
EQUB LO(x*8)
NEXT
.Mult8_HI
FOR n,0,39,1
x=(n * 7) DIV 8
EQUB HI(x*8)
NEXT
IF 0
.Mult8_REM
FOR n,0,39,1
x=(n * 7) MOD 8
EQUB 8 - x
NEXT
.Mult8_MOD
FOR n,0,39,1
x=(n * 7) MOD 8
EQUB x
NEXT
ENDIF

\*-------------------------------
; New sprite routines - 2bpp expanded to MODE 2

.beeb_plot_sprite_LayGen
{
    \ Get sprite data address 

    JSR beeb_PREPREP

    \ CLIP here

    \ Check NULL sprite

    LDA WIDTH
    BEQ return    

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
    LDA Mult16,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16X,X
    ADC YHI,Y
    STA beeb_writeptr+1

    LDA YCO
    AND #&7
    STA beeb_yoffset            ; think about using y remaining counter cf Thrust

    \ 

    lda OPACITY
    AND #&7f    ;hi bit off
    TAX

    \ Self-mod code

    lda OPCODE,x
    sta smod
    sta smod2

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

    .plot_lines_loop

    LDY WIDTH
    DEY                     ; bytes_per_line_in_sprite

\ Decode a line of sprite data using Exile method!

    .line_loop

    .sprite_data
    LDA &FFFF, Y
    TAX
    AND #&11
    STA smPIXELD+2
.smPIXELD
    LDA map_2bpp_to_mode2_pixel         ; could be in ZP ala Exile to save 2cx4=8c per sprite byte
    PHA                                 ; [3c]
    TXA
    AND #&22
    STA smPIXELC+2
.smPIXELC
    LDA map_2bpp_to_mode2_pixel
    PHA
    TXA
    LSR A
    LSR A
    TAX
    AND #&11
    STA smPIXELB+2
.smPIXELB
    LDA map_2bpp_to_mode2_pixel
    PHA
    TXA
    AND #&22
    STA smPIXELA+2
.smPIXELA
    LDA map_2bpp_to_mode2_pixel
    PHA
    DEY
    BPL line_loop
    LDA #0
    PHA                                   ; extra byte for parity?
    INY




    LDA YCO
    DEC A
    .smTOP
    CMP #LO(-1)
    STA YCO
    BNE plot_lines_loop

    .return
    RTS
}

ALIGN &100
.map_2bpp_to_mode2_pixel
{
    EQUB &00                        ; &00
    EQUB &01                        ; 000A000a right pixel logical 1
    EQUB &02                        ; 00B000b0 left pixel logical 1

    skip &0D

    EQUB &10                        ; 000A000a right pixel logical 2
    EQUB &11                        ; 000A000a right pixel logical 3

    skip &0F

    EQUB &20                        ; 00B000b0 left pixel logical 2
    skip 1
    EQUB &22                        ; 00B000b0 left pixel logical 3
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


.beeb_plot_end
