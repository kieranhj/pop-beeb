; beeb_screen.asm
; Beeb screen specific routines that need to be in Core memory

.beeb_screen_start

\*-------------------------------
; Clear Beeb screen buffer
\*-------------------------------

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

\*-------------------------------
; Clear status line characters
\*-------------------------------

; Y=start character [0-79]
; X=number of characters to clear
.beeb_clear_status_X
{
    CLC
    LDA Mult8_LO,Y
    ADC #LO(beeb_status_addr)
    STA beeb_writeptr
    LDA Mult8_HI,Y
    ADC #HI(beeb_status_addr)
    STA beeb_writeptr+1

    .loop
    LDA #0

    LDY #0
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y

    DEX
    BEQ done_loop

    CLC
    LDA beeb_writeptr
    ADC #8
    STA beeb_writeptr
    BCC no_carry
    INC beeb_writeptr+1
    .no_carry
    BNE loop

    .done_loop
    RTS
}

.beeb_clear_status_line
{
    LDY #0
    LDX #80
    JMP beeb_clear_status_X
}

.beeb_clear_text_area
{
    LDY #20
    LDX #40
    JMP beeb_clear_status_X
}

.beeb_clear_player_energy
{
    LDY #0
    LDX #20
    JMP beeb_clear_status_X
}

.beeb_clear_opp_energy
{
    LDY #68
    LDX #12
    JMP beeb_clear_status_X
}

\*-------------------------------
\* Invert Y-tables
\*-------------------------------

.INVERTY
{
 ldx #191 ;low line
 ldy #0 ;high line

\* Switch low & high lines

.loop lda YLO,x
 pha
 lda YLO,y
 sta YLO,x
 pla
 sta YLO,y

 lda YHI,x
 pha
 lda YHI,y
 sta YHI,x
 pla
 sta YHI,y

\* Move 1 line closer to ctr

 dex
 iny
 cpy #96
 bcc loop

\\ Now self-mode code to invert usage
\\ This code is currently in Core

    \ CMP #&00 <> CMP #&07
    LDA beeb_plot_sprite_FASTLAYSTA_PP_smCMP+1
    EOR #&07
    STA beeb_plot_sprite_FASTLAYSTA_PP_smCMP+1
    STA beeb_plot_layrsave_smCMP+1

    \ DEC zp <> INC zp
    LDA beeb_plot_sprite_FASTLAYSTA_PP_smDEC
    EOR #(OPCODE_DECzp EOR OPCODE_INCzp)
    STA beeb_plot_sprite_FASTLAYSTA_PP_smDEC
    STA beeb_plot_layrsave_smDEC

    \ SEC <> CLC
    LDA beeb_plot_sprite_FASTLAYSTA_PP_smSEC
    EOR #(OPCODE_SEC EOR OPCODE_CLC)
    STA beeb_plot_sprite_FASTLAYSTA_PP_smSEC
    STA beeb_plot_layrsave_smSEC

    \ SBC #imm <> ADC #imm
    LDA beeb_plot_sprite_FASTLAYSTA_PP_smSBC1
    EOR #(OPCODE_SBCimm EOR OPCODE_ADCimm)
    STA beeb_plot_sprite_FASTLAYSTA_PP_smSBC1
    STA beeb_plot_sprite_FASTLAYSTA_PP_smSBC2
    STA beeb_plot_layrsave_smSBC1
    STA beeb_plot_layrsave_smSBC2

    \ EOR #&07 <> EOR #&00
    LDA beeb_plot_layrsave_smEOR+1
    EOR #&07
    STA beeb_plot_layrsave_smEOR+1

\\ Any code in Main has to be modded twice

    \ Invert code in current RAM
    JSR beeb_plot_invert_code_in_main
 
    \ Make other buffer writable
    lda &fe34
    eor #4	; invert bits 0 (CRTC) & 2 (RAM)
    sta &fe34

    \ Invert code in SHADOW RAM
    JSR beeb_plot_invert_code_in_main

    \ Switch back to double buffer
    lda &fe34
    eor #4	; invert bits 0 (CRTC) & 2 (RAM)
    sta &fe34

    RTS
}

.beeb_plot_invert_code_in_main
{
    \ CMP #&00 <> CMP #&07
    LDA beeb_plot_wipe_smCMP+1
    EOR #&07
    STA beeb_plot_wipe_smCMP+1
    STA beeb_plot_sprite_LayMask_smCMP+1
    STA beeb_plot_sprite_FASTMASK_smCMP+1
    STA beeb_plot_sprite_FASTLAYAND_PP_smCMP+1
    STA beeb_plot_peel_smCMP+1

    \ DEC zp <> INC zp
    LDA beeb_plot_wipe_smDEC
    EOR #(OPCODE_DECzp EOR OPCODE_INCzp)
    STA beeb_plot_wipe_smDEC
    STA beeb_plot_sprite_LayMask_smDEC
    STA beeb_plot_sprite_FASTMASK_smDEC
    STA beeb_plot_sprite_FASTLAYAND_PP_smDEC
    STA beeb_plot_peel_smDEC

    \ SEC <> CLC
    LDA beeb_plot_wipe_smSEC
    EOR #(OPCODE_SEC EOR OPCODE_CLC)
    STA beeb_plot_wipe_smSEC
    STA beeb_plot_sprite_LayMask_smSEC
    STA beeb_plot_sprite_FASTMASK_smSEC
    STA beeb_plot_sprite_FASTLAYAND_PP_smSEC
    STA beeb_plot_peel_smSEC

    \ SBC #imm <> ADC #imm
    LDA beeb_plot_wipe_smSBC1
    EOR #(OPCODE_SBCimm EOR OPCODE_ADCimm)
    STA beeb_plot_wipe_smSBC1
    STA beeb_plot_wipe_smSBC2
    STA beeb_plot_sprite_LayMask_smSBC1
    STA beeb_plot_sprite_LayMask_smSBC2
    STA beeb_plot_sprite_FASTMASK_smSBC1
    STA beeb_plot_sprite_FASTMASK_smSBC2
    STA beeb_plot_sprite_FASTLAYAND_PP_smSBC1
    STA beeb_plot_sprite_FASTLAYAND_PP_smSBC2
    STA beeb_plot_peel_smSBC1
    STA beeb_plot_peel_smSBC2

    \ EOR #&07 <> EOR #&00
    LDA beeb_plot_peel_smEOR+1
    EOR #&07
    STA beeb_plot_peel_smEOR+1

    RTS  
}

\*-------------------------------
; "Double Hires" FX for Attract
\*-------------------------------

; X=column [0-79]
; A=offset [0-1]
.beeb_dhires_copy_column
{
    CLC
    ADC Mult8_LO, X
    STA beeb_writeptr
    LDA #HI(beeb_double_hires_addr)
    ADC Mult8_HI, X
    STA beeb_writeptr+1

    LDX #BEEB_DOUBLE_HIRES_ROWS
    .row_loop

    LDY #0
    .char_loop
    LDA (beeb_writeptr), Y
    PHA

    \\ Write to visible screen
    LDA &FE34:EOR #&4:STA &FE34

    PLA
    STA (beeb_writeptr), Y

    \\ Read from invisible screen
    LDA &FE34:EOR #&4:STA &FE34

    INY:INY
    CPY #8
    BCC char_loop

    CLC
    LDA beeb_writeptr
    ADC #LO(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    ADC #HI(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr+1
    
    DEX
    BNE row_loop

    .return
    RTS
}

.beeb_dhires_wipe
{
    LDX #0
    .loop
    STX beeb_temp

    LDA #0
    JSR beeb_dhires_copy_column

    LDA #1
    LDX beeb_temp
    JSR beeb_dhires_copy_column

    LDX beeb_temp
    INX
    CPX #80
    BCC loop

    RTS
}

\*-------------------------------
\* IN: XCO, YCO
\* OUT: beeb_writeptr (to crtc character), beeb_yoffset, beeb_parity (parity)
\*-------------------------------

.beeb_plot_calc_screen_addr
{
    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)
    \ OFFSET (0-3) - maybe 0,1 or 8,9?

    LDX XCO
    LDY YCO

    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16_HI,X
    ADC YHI,Y
    STA beeb_writeptr+1

    \ Handle OFFSET

    LDA OFFSET
    LSR A
    STA beeb_mode2_offset       ; not needed by every caller

    AND #&1
    STA beeb_parity             ; this is parity

    ROR A                       ; return parity in C
    RTS
}

\*-------------------------------
; Additional PREP before sprite plotting for Beeb
\*-------------------------------

.beeb_PREPREP
{
    \\ Must have a swram bank to select or assert
    LDA BANK
IF _DEBUG
    SEC
    SBC #4
    CMP #4
    BCC bank_ok
    BRK
    .bank_ok
    LDA BANK
ENDIF
    JSR swr_select_slot

    \ Turns TABLE & IMAGE# into IMAGE ptr
    \ Obtains WIDTH & HEIGHT
    
    JSR PREPREP

    \ On BEEB eor blend mode changed to PALETTE bump

    LDA OPACITY
    CMP #enum_eor
    BNE not_eor
    INC PALETTE
    .not_eor

    \ PALETTE now set per sprite

    \ BIT 6 of PALETTE specifies whether sprite is secretly half vertical res

    LDA PALETTE
    AND #&40
    STA BEEBHACK

    \ BIT 7 of PALETTE actually indicates there is no palette - data is 4bpp

    LDA PALETTE
    AND #&BF
    STA PALETTE

    RTS
}

\*-------------------------------
\*
\* Palette functions
\*
\*-------------------------------

.beeb_plot_sprite_setpalette
{
    BMI return
    ASL A:ASL A
    TAX

    STZ map_2bpp_to_mode2_pixel+&00                     ; left + right 0

    INX
    LDA palette_table, X
    AND #MODE2_RIGHT_MASK
    STA map_2bpp_to_mode2_pixel+$01                     ; right 1
    ASL A
    STA map_2bpp_to_mode2_pixel+$02                     ; left 1

    INX
    LDA palette_table, X
    AND #MODE2_RIGHT_MASK
    STA map_2bpp_to_mode2_pixel+$10                     ; right 2
    ASL A
    STA map_2bpp_to_mode2_pixel+$20                     ; left 2
    
    INX
    LDA palette_table, X
    AND #MODE2_RIGHT_MASK
    STA map_2bpp_to_mode2_pixel+$11                     ; right 3
    ASL A
    STA map_2bpp_to_mode2_pixel+$22                     ; left 3

    .return
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


\*-------------------------------
; Expands 6 bytes left/right logical 0/1/2/3 pixels into all byte combinations
\*-------------------------------

IF 0    \\ Currently unused as tables are built as assemble time
.beeb_expand_palette_table
{
    STX beeb_writeptr
    STY beeb_writeptr+1

\\ Update palette address table x2

    TAX
    LDA beeb_writeptr
    STA palette_addr_LO, X
    LDA beeb_writeptr+1
    STA palette_addr_HI, X
    TXA

\\ Set small palette lookup

    JSR beeb_plot_sprite_setpalette

\\ Wipe expanded palette lookup

    LDY #0
    LDA #0
    .wipe
    STA (beeb_writeptr), Y
    INY
    CPY #&34
    BNE wipe 

\\ Exapnd each entry in palette lookup

    LDY #0
    .loop

IF 0
    TYA:AND #&88            ; pixel D
    LSR A:LSR A         ; shift down
    TAX
    LDA map_2bpp_to_mode2_pixel, X      ; left pixel logical 0/1/2/3
    ORA (beeb_writeptr), Y
    STA (beeb_writeptr), Y

    TYA:AND #&44            ; pixel C
    LSR A: LSR A        ; shift down
    TAX
    LDA map_2bpp_to_mode2_pixel, X      ; right pixel logical 0/1/2/3
    ORA (beeb_writeptr), Y
    STA (beeb_writeptr), Y
ENDIF

    TYA:AND #&22            ; pixel B
    TAX
    LDA map_2bpp_to_mode2_pixel, X      ; left pixel logical 0/1/2/3
    ORA (beeb_writeptr), Y
    STA (beeb_writeptr), Y

    TYA:AND #&11            ; pixel A
    TAX
    LDA map_2bpp_to_mode2_pixel, X      ; right pixel logical 0/1/2/3
    ORA (beeb_writeptr), Y
    STA (beeb_writeptr), Y

    INY
    CPY #&34
    BCC loop

    .return
    RTS
}
ENDIF

.beeb_screen_end
