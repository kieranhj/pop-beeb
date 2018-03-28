; beeb_platform.asm
; Beeb platform specific routines that need to be in Core memory

TIMER_latch = 20000-2				; 20ms = 1x vsync :)
TIMER_start = (TIMER_latch /2)		; some % down the frame is our vsync point

.beeb_platform_start

.beeb_set_default_palette
{
    \\ Set Palette
    CLC
    LDX #0
    LDA #0
    .palloop
    ORA ula_palette,X
    INX
    STA &FE21
    AND #&F0
    ADC #&10
    BCC palloop

    RTS
}

.beeb_set_palette_all
{
IF 0                \\ KC decided only ever to flash black background
    STA palloop+1

    \ Super hackballs!
    BIT #&40
    BEQ do_all
ENDIF

    \ Just black
    AND #&F
    STA &FE21
    RTS

IF 0
    .do_all
    CLC
    LDX #0
    LDA #0
    .palloop
    ORA #0
    INX
    STA &FE21
    AND #&F0
    ADC #&10
    BCC palloop
    
    RTS
ENDIF
}

\*-------------------------------
; CRTC & ULA data required to configure out special MODE 2
; Following data could be dumped after boot!

.ula_palette
{
    EQUB PAL_black
    EQUB PAL_red
    EQUB PAL_green
    EQUB PAL_yellow
    EQUB PAL_blue
    EQUB PAL_magenta
    EQUB PAL_cyan
    EQUB PAL_white

    EQUB PAL_black
    EQUB PAL_red
    EQUB PAL_green
    EQUB PAL_yellow
    EQUB PAL_blue
    EQUB PAL_magenta
    EQUB PAL_cyan
    EQUB PAL_white
}

\*-------------------------------
; Apple II RAM select - map to Beeb
\*-------------------------------

MACRO BEEB_SELECT_MAIN_MEM
{
    LDA &F4: PHA
}
ENDMACRO

MACRO BEEB_SELECT_AUX_MEM
{
    PLA:STA &F4:STA &FE30
}
ENDMACRO

; in double buffer mode, both display & main memory swap, but point to the opposite memory 
.shadow_swap_buffers
{

IF _AUDIO_DEBUG
    ; SM: some hacky code to help identify sound fx triggers
    jsr BEEB_DEBUG_DRAW_SFX
ENDIF

    lda &fe34
    eor #1+4	; invert bits 0 (CRTC) & 2 (RAM)
    sta &fe34
    rts
}

\*-------------------------------
; VSYNC code
\*-------------------------------

.beeb_wait_vsync
{
IF 1        ; rather than osbyte
    LDA beeb_vsync_count
    .wait_loop
    CMP beeb_vsync_count
    BEQ wait_loop
    RTS
ELSE
    LDA #19
    JMP osbyte
ENDIF
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

    LDA palette_table+1, X
    AND #MODE2_RIGHT_MASK
    STA map_2bpp_to_mode2_pixel+$01                     ; right 1
    ASL A
    STA map_2bpp_to_mode2_pixel+$02                     ; left 1

    LDA palette_table+2, X
    AND #MODE2_RIGHT_MASK
    STA map_2bpp_to_mode2_pixel+$10                     ; right 2
    ASL A
    STA map_2bpp_to_mode2_pixel+$20                     ; left 2
    
    LDA palette_table+3, X
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
; Debug fns
\*-------------------------------

IF _DEBUG
.temp_last_count EQUB 0

FR_COUNTER_X=78
FR_COUNTER_Y=BEEB_STATUS_ROW

.beeb_display_vsync_counter
{

    JSR beeb_plot_font_prep
    LDA #LO(beeb_screen_addr + FR_COUNTER_Y*BEEB_SCREEN_ROW_BYTES + FR_COUNTER_X*8)
    STA beeb_writeptr
    LDA #HI(beeb_screen_addr + FR_COUNTER_Y*BEEB_SCREEN_ROW_BYTES + FR_COUNTER_X*8)
    STA beeb_writeptr+1
    LDA #PAL_FONT:STA PALETTE

    SEC
    LDA beeb_vsync_count
    TAY
    SBC temp_last_count
    STY temp_last_count

    CMP #10
    BCC diff_ok
    LDA #9
    .diff_ok
    INC A
    JMP beeb_plot_font_glyph
}
ENDIF

.beeb_platform_end
