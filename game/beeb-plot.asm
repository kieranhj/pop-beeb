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
\ Implement offset and clipping etc.

.beeb_plot_start

.beeb_plot_apple_mode_4
{
    \\ From hires_LAY
    lda OPACITY
    bpl notmirr

    and #$7f
    sta OPACITY

;    jmp MLAY
;
    .notmirr
    
    \ BEEB TEMP
    CMP #5
    BCC opacity_valid
    BRK
    .opacity_valid

;    cmp #enum_eor
;    bne label_1
;    jmp LayXOR
;
    .label_1 cmp #enum_mask
    bcc label_2
    
\    \ BEEB TEMP hack enum_mask to be enum_ora
\    LDA #enum_ora
\    STA OPACITY

    jmp beeb_plot_apple_mode_4_mask
;
    .label_2
;    jmp LayGen

    \\ Must have a swram bank to select or assert
    LDA BANK
    CMP #4
    BCC slot_set
    BRK                 ; swram slot for sprite not set!
    .slot_set
    JSR swr_select_slot

    \ Turns TABLE & IMAGE# into IMAGE ptr
    \ Obtains WIDTH & HEIGHT
    
    JSR PREPREP

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
    
    \ Look up Beeb screen address

    LDX XCO

    CLC
    LDA Mult8_LO,X
    ADC YLO, Y
    STA beeb_writeptr
    STA beeb_readptr
    LDA Mult8_HI,X
    ADC YHI, Y
    STA beeb_writeptr+1
    STA beeb_readptr+1

    LDA Mult8_MOD,X
    STA beeb_rem

    \ Complicated SHIFT and CARRY tables :S
  
    TAX
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
    \ Ignore shift for now - just plot on Beeb byte alignment

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
    \\ Must have a swram bank to select or assert
    LDA BANK
    CMP #4
    BCC slot_set
    BRK                 ; swram slot for sprite not set!
    .slot_set
    JSR swr_select_slot

    \ Turns TABLE & IMAGE# into IMAGE ptr
    \ Obtains WIDTH & HEIGHT
    
    JSR PREPREP

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
    
    \ Look up Beeb screen address

    LDX XCO
    CLC
    LDA Mult8_LO,X
    ADC YLO, Y
    STA beeb_writeptr
    STA beeb_readptr
    LDA Mult8_HI,X
    ADC YHI, Y
    STA beeb_writeptr+1
    STA beeb_readptr+1

    \ Look up Beeb shift start

    LDA Mult8_MOD,X
    STA beeb_rem

    \ Can add in OFFSET here?  Probably higher up actually - add to XCO
  
    TAX
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
    \ Ignore shift for now - just plot on Beeb byte alignment

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
    AND (beeb_writeptr), Y  ; mask screen byte
    ORA imbyte      ; merge image byte

    \\ As before

    .smod ORA (beeb_writeptr), Y
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
    STA imbyte      ; actually screen byte

    \ Convert byte to mask
    LDY beeb_next_carry
    LDA MASKTAB, Y

    LDY beeb_temp_y
    AND (beeb_writeptr), Y  ; mask screen byte
    ORA imbyte      ; merge image byte

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
.Div8_LO
FOR n,0,279,1
EQUB LO(n DIV 8)
NEXT
.Mod8_LO
FOR n,0,279,1
EQUB LO(n MOD 8)
NEXT
ENDIF
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
ENDIF
.Mult8_MOD
FOR n,0,39,1
x=(n * 7) MOD 8
EQUB x
NEXT


\*-------------------------------
\*
\* These functions should be moved to a separate non-plot Beeb module
\*
\*-------------------------------

.beeb_set_screen_mode
{
    \\ Set CRTC registers
    LDX #13
    .crtcloop
    STX &FE00
    LDA beeb_crtcregs, X
    STA &FE01
    DEX
    BPL crtcloop

    \\ Set ULA
    LDA #&88            ; MODE 4
    STA &FE20

    \\ Set Palette
    CLC
    LDA #7              ; PAL_black
    .palloop1
    STA &FE21
    ADC #&10
    BPL palloop1  
    EOR #7              ; PAL_white
    .palloop2
    STA &FE21
    ADC #&10
    BMI palloop2

    RTS
}

\*-------------------------------
; Relocate image tables

.beeb_plot_reloc_img
{
    LDY #0
    LDA (beeb_readptr), Y
    STA beeb_numimages              \ can get rid of this var

    \\ Relocate pointers to image data
    LDX #0
    .loop
    INY
    CLC
\    LDA (beeb_readptr), Y
\    ADC #LO(bgtable1)
\    STA (beeb_readptr), Y

    INY
    LDA (beeb_readptr), Y
\ Now at &0000 for BEEB data
\    SEC
\    SBC beeb_writeptr+1
    CLC
    ADC beeb_readptr+1
    STA (beeb_readptr), Y

    INX
    CPX beeb_numimages
    BCC loop

    .return
    RTS
}

\*-------------------------------
; Clear Beeb screen buffer

.beeb_CLS
{
\\ Ignore PAGE as no page flipping yet
\\ Fixed to MODE 1 screen address for now &3000 - &8000

IF BEEB_SCREEN_MODE == 4
  ldx #&80 - HI(beeb_screen_addr)
  lda #HI(beeb_screen_addr)
ELSE
  ldx #&50
  lda #&30
ENDIF
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

\*-------------------------------
; SHADOW RAM select

.beeb_shadow_select_main
{
    LDA &FE34
    AND #&FB            ; mask out bit 2
    STA &FE34
    RTS
}

.beeb_shadow_select_aux
{
    LDA &FE34
    ORA #4
    STA &FE34
    RTS
}


\*-------------------------------
\*
\* MODE 4 b&w plot directly from Apple II data
\*
\*-------------------------------

IF 0
.beeb_plot_apple_mode_4
{
    \\ From hires_LAY
    lda OPACITY
    bpl notmirr

    and #$7f
    sta OPACITY
;    jmp MLAY
;
    .notmirr
;    cmp #enum_eor
;    bne label_1
;    jmp LayXOR
;
;    .label_1 cmp #enum_mask
;    bcc label_2
;    jmp LayMask
;
;    .label_2 jmp LayGen

    \\ Must have a swram bank to select or assert
    LDA BANK
    CMP #4
    BCC slot_set
    BRK                 ; swram slot for sprite not set!
    .slot_set
    JSR swr_select_slot

    \ Turns TABLE & IMAGE# into IMAGE ptr
    \ Obtains WIDTH & HEIGHT
    
    JSR PREPREP

    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)

    \ Convert to Beeb screen layout

    \ Y offset into character row

    LDA YCO
    AND #&7
    STA beeb_yoffset

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

    \ Look up Beeb shift start

    LDA Mult8_REM,X
    STA beeb_rem

    \ Store height

    LDA HEIGHT
    STA beeb_height

    \ Switch blend mode

    ldx OPACITY ;hi bit off!
    cpx #5
    bcc in_range
    BRK                 ; means our OPACITY is out of range
    .in_range
    cpx #enum_sta
; BEEB TEMP always ORA
;    bne not_sta

    \ Force hack ORA for MODE 4
    ldx #enum_ora
    .not_sta

    \ Self-mod code

    lda OPCODE,x
    sta  smod
    sta  smod2

    \ Set sprite data address 

    LDA IMAGE
    STA sprite_addr+1
    LDA IMAGE+1
    STA sprite_addr+2

    \ Plot loop

    LDX #0          ; data index
    LDY beeb_yoffset          ; yoffset

    .yloop
    STY beeb_yoffset

    LDA WIDTH
    STA beeb_apple_count

    LDA #0
    STA beeb_byte

    LDA beeb_rem
    STA beeb_count

    .xloop

    .sprite_addr
    LDA &FFFF, X
    STA beeb_apple_byte

    LDA #7
    STA beeb_bit_count

    .bit_loop    
    LSR beeb_apple_byte       ; rotate bottom bit into Carry
    ROL beeb_byte        ; rotate carry into Beeb byte

    DEC beeb_count
    BNE next_bit

    \\ Write byte to screen
    LDA beeb_byte
 .smod ora (beeb_writeptr),y
   STA (beeb_writeptr), Y

    \\ Next screen column
    TYA
    CLC
    ADC #8
    TAY

    LDA #0
    STA beeb_byte

    LDA #8
    STA beeb_count

    .next_bit
    DEC beeb_bit_count
    BNE bit_loop

    \\ Next apple byte

    INX                 ; next apple byte
    DEC beeb_apple_count
    BNE xloop

    \\ Flush Beeb byte to screen if needed
    LDA beeb_count
    CMP #8
    BEQ done_row

    .flushloop
    ASL beeb_byte
    DEC beeb_count
    BNE flushloop

    LDA beeb_byte
 .smod2 ora (beeb_writeptr),y
    STA (beeb_writeptr), Y
    
    .done_row
    DEC beeb_height
    BEQ done

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
    .done

    .return
    RTS
}
ENDIF

\*-------------------------------
\*
\* MODE 1 colour plot directly from Apple II data
\*
\*-------------------------------

IF BEEB_SCREEN_MODE == 1
.beeb_plot_apple_mode_1
{
    ASL A
    TAX
    LDA bgtable1+1, X           \ WRONG
    STA beeb_readptr
    LDA bgtable1+2, X           \ WRONG
    STA beeb_readptr+1

    LDY #0
    LDA (beeb_readptr), Y
    STA beeb_width
    INY
    LDA (beeb_readptr), Y
    STA beeb_height

    CLC
    LDA beeb_readptr
    ADC #2
    STA init_addr + 1
    STA sprite_addr + 1
    LDA beeb_readptr+1
    ADC #0
    STA init_addr + 2
    STA sprite_addr + 2


    LDX #0          ; data index
    LDY #7          ; yoffset

    .yloop
    STY beeb_yoffset
    STY beeb_yindex

    LDA beeb_width
    STA beeb_apple_count

    LDA #0
    STA beeb_pal_index

    LDA #4
    STA beeb_count

    \\ Initialise palindex
    .init_addr
    LDA &FFFF, X
    STA beeb_apple_byte

    LSR beeb_apple_byte
    ROL beeb_pal_index

    LDA #6              ; we just consumed one
    STA beeb_bit_count

    .xloop

    .bit_loop    
    LSR beeb_apple_byte       ; rotate bottom bit into Carry
    ROL beeb_pal_index        ; rotate carry into palette index

    DEC beeb_count
    BNE next_bit

    \\ Write byte to screen
    LDA beeb_pal_index
    AND #&3F
    TAY
    LDA beeb_plot_pal_table_6_to_4, Y

    LDY beeb_yindex
    STA (beeb_writeptr), Y

    \\ Next screen column
    TYA
    CLC
    ADC #8
    STA beeb_yindex

    LDA #4
    STA beeb_count

    .next_bit
    DEC beeb_bit_count
    BNE bit_loop

    \\ Next apple byte

    INX                 ; next apple byte

    .sprite_addr
    LDA &FFFF, X
    STA beeb_apple_byte

    LDA #7
    STA beeb_bit_count

    DEC beeb_apple_count
    BNE xloop

    \\ Flush Beeb byte to screen if needed
    LDA beeb_count
    CMP #4
    BEQ done_row

    .flushloop
    ASL beeb_pal_index        ; rotate zero into palette index

    DEC beeb_count
    BNE flushloop

    LDA beeb_pal_index
    AND #&3F
    TAY
    LDA beeb_plot_pal_table_6_to_4, Y

    LDY beeb_yindex
    STA (beeb_writeptr), Y
    
    .done_row
    DEC beeb_height
    BEQ done

    LDY beeb_yoffset
    DEY
    BPL jump_yloop
    
    \\ Next char row

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr+1

    LDY #7
    .jump_yloop
    JMP yloop

    .done

    .return
    RTS
}


.beeb_plot_pal_table_6_to_4
FOR n,0,63,1

abc=(n >> 3) AND 7
bcd=(n >> 2) AND 7
cde=(n >> 1) AND 7
def=(n) AND 7

\\ even3
IF abc=3 OR abc=6 OR abc=7
    pixel3=&88          ; white3
ELIF abc=2
    pixel3=&80          ; yellow3
ELIF abc=5
    pixel3=&08          ; red3
ELSE
    pixel3=0
ENDIF

IF bcd=3 OR bcd=6 OR bcd=7
    pixel2=&44          ; white2
ELIF bcd=5
    pixel2=&40          ; yellow2
ELIF bcd=2
    pixel2=&04          ; red2
ELSE
    pixel2=0
ENDIF

IF cde=3 OR cde=6 OR cde=7
    pixel1=&22          ; white1
ELIF cde=2
    pixel1=&20          ; yellow1
ELIF cde=5
    pixel1=&02          ; red1
ELSE
    pixel1=0
ENDIF

IF def=3 OR def=6 OR def=7
    pixel0=&11          ; white0
ELIF def=5
    pixel0=&10          ; yellow0
ELIF def=2
    pixel0=&01          ; red0
ELSE
    pixel0=0
ENDIF

EQUB pixel3 OR pixel2 OR pixel1 OR pixel0

NEXT
ENDIF

.beeb_plot_end
