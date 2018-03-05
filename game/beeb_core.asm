; beeb_core.asm
; Beeb specific routines that need to be in Core memory

TIMER_latch = 20000-2				; 20ms = 1x vsync :)
TIMER_start = (TIMER_latch /2)		; some % down the frame is our vsync point

.beeb_core_start

.beeb_set_default_palette
{
    \\ Set Palette
    CLC
    LDX #0
    LDA #0
    .palloop
    ORA beeb_palette,X
    INX
    STA &FE21
    AND #&F0
    ADC #&10
    BCC palloop

    RTS
}

.beeb_set_palette_all
{
    STA palloop+1

    \ Super hackballs!
    BIT #&40
    BEQ do_all

    \ Just black
    AND #&F
    STA &FE21
    RTS

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
}

\\ Just set CRTC registers we care about for game vs attract mode

.beeb_set_game_screen
{
IF BEEB_SCREEN_CHARS<>80
    LDA #1:STA &FE00            ; R1 = horizontal displayed
    LDA #BEEB_SCREEN_CHARS
    STA &FE01
ENDIF

    LDA #6:STA &FE00            ; R6 = vertical displayed
    LDA #BEEB_SCREEN_ROWS
    STA &FE01

    LDA #7:STA &FE00            ; R7 = vertical position
    LDA #BEEB_SCREEN_VPOS
    STA &FE01

    LDA #12:STA &FE00           ; R12 = screen start address, high
    LDA #HI(beeb_screen_addr/8)
    STA &FE01

    LDA #13:STA &FE00               ; R13 = screen start address, low
    LDA #LO(beeb_screen_addr/8)
    STA &FE01

    RTS
}

.beeb_set_attract_screen
{
    \\ Assume base MODE is 2 - if changed this to MODE 1 need to twiddle ULA

    LDA #6:STA &FE00            ; R6 = vertical displayed
    LDA #BEEB_DOUBLE_HIRES_ROWS
    STA &FE01

    LDA #7:STA &FE00            ; R7 = vertical position
    LDA #BEEB_DOUBLE_HIRES_VPOS
    STA &FE01

    LDA #12:STA &FE00           ; R12 = screen start address, high
    LDA #HI(beeb_double_hires_addr/8)
    STA &FE01

    LDA #13:STA &FE00               ; R13 = screen start address, low
    LDA #LO(beeb_double_hires_addr/8)
    STA &FE01

    RTS
}

.beeb_hide_screen
{
    LDA #8:STA &FE00            ; R8 = interlace
    LDA #&30:STA &FE01          ; blank screen
    RTS
}

.beeb_show_screen
{
    LDA #8:STA &FE00            ; R8 = interlace
    LDA #&00:STA &FE01          ; show screen (no interlace)
    RTS
}

\*-------------------------------
; CRTC & ULA data required to configure out special MODE 2
; Following data could be dumped after boot!

.beeb_palette
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
; Relocate image tables
\*-------------------------------

.beeb_plot_reloc_img
{
    LDY #0
    LDA (beeb_readptr), Y
    STA beeb_numimages              \ can get rid of this var

    \\ Relocate pointers to image data
    LDX #0
    .loop
    INY
\    CLC
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

; we set bits 0 and 2 of ACCCON, so that display=Main RAM, and shadow ram is selected as main memory
.shadow_init_buffers
{
    lda &fe34
    and #255-1  ; set D to 0
    ora #4    	; set X to 1
    sta &fe34
    rts
}

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
IF _IRQ_VSYNC
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
; IRQ code
\*-------------------------------

IF _IRQ_VSYNC
.beeb_irq_init
{
	SEI
	LDA IRQ1V:STA old_irqv
	LDA IRQ1V+1:STA old_irqv+1

	LDA #LO(beeb_irq_handler):STA IRQ1V
	LDA #HI(beeb_irq_handler):STA IRQ1V+1		; set interrupt handler

	LDA #64						; A=00000000
	STA &FE4B					; R11=Auxillary Control Register (timer 1 latched mode)

	LDA #&C0					; A=11000000
	STA &FE4E					; R14=Interrupt Enable (enable timer 1 interrupt)

	LDA #LO(TIMER_start)
	STA &FE44					; R4=T1 Low-Order Latches (write)
	LDA #HI(TIMER_start)
	STA &FE45					; R5=T1 High-Order Counter
	
	LDA #LO(TIMER_latch)
	STA &FE46
	LDA #HI(TIMER_latch)
	STA &FE47
	CLI

	RTS
}

.old_irqv
EQUW &FFFF

.beeb_irq_handler
{
	LDA &FC
	PHA

	LDA &FE4D
	AND #&40			; timer 1
	BEQ return_to_os

	\\ Acknowledge timer1 interrupt
	STA &FE4D

	\\ Increment vsync counter
	INC beeb_vsync_count

	\\ Pass on to OS IRQ handler
	.return_to_os
	PLA
	STA &FC
	JMP (old_irqv)		; RTI
}
ENDIF

\*-------------------------------
; Test code
\*-------------------------------

IF 0
.beeb_test_load_all_levels
{
    \\ Level load & plot test
    LDX #1

    .level_loop
    STX level
    JSR LoadLevelX

    LDX #1
    STX VisScrn

    .scrn_loop
    JSR getscrns
    JSR DoSure

\ Wait 1 second for keypress

    ldx#100:ldy#0:lda#&81:jsr osbyte	

    LDX VisScrn
    INX
    CPX #25
    STX VisScrn
    BNE scrn_loop

    LDX level
    INX
    CPX #15
    BNE level_loop
    RTS
}
ENDIF

IF 0
.beeb_test_sprite_plot
{
    JSR loadperm

\\    LDX #1
\\    STX level
\\    JSR LoadLevelX

    LDA #0
    JSR LoadStage2

\\    JSR beeb_shadow_select_main

    JSR vblank

    JSR beeb_set_mode2_no_clear
    JSR beeb_set_game_screen
    JSR beeb_show_screen

    JSR vblank

    LDA #1
    STA beeb_sprite_no

    LDA #0
    STA OFFSET

    LDA #0
    STA LEFTCUT
    STA TOPCUT
    LDA #40
    STA RIGHTCUT
    LDA #192
    STA BOTCUT


    .sprite_loop
    LDA beeb_sprite_no
    ASL A:ASL A
    AND #&1F

    LDA #LO(1)
    STA XCO

    LDA #127
    STA YCO

    LDA beeb_sprite_no
    STA IMAGE

    LDA #LO(chtable7)
    STA TABLE

    LDA #HI(chtable7)
    STA TABLE+1

    LDA #BEEB_SWRAM_SLOT_CHTAB678
    STA BANK

    LDA #enum_mask OR &80
    STA OPACITY

    JSR beeb_plot_sprite_LAY

    ldx#100:ldy#0:lda#&81:jsr osbyte	

    LDX OFFSET
    INX
    STX OFFSET
    CPX #7
    BCC sprite_loop

    LDX #0
    STX OFFSET    

    LDX beeb_sprite_no
    INX
    CPX #128
    BCS finished
    STX beeb_sprite_no
    JMP sprite_loop

    .finished
    RTS
}
ENDIF

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

; Clear status line characters
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

\*-------------------------------
; Test whether key is pressed (from Thrust!)
; A=Internal Key Number (IKN)
; Returns A=0 pressed A<>0 not pressed
\*-------------------------------

IF 0
.beeb_test_key
{
        PHP

	.L3AA7
        LDX     #$03
        LDY     #$0B
        SEI
        STX     SHEILA_System_VIA_Register_B
        LDX     #$7F
        STX     SHEILA_System_VIA_Data_Dir
        STA     SHEILA_System_VIA_Register_A_NH
        LDA     SHEILA_System_VIA_Register_A_NH
        STY     SHEILA_System_VIA_Register_B
        PLP
        LDX     #$00
        ROL     A
        BCC     no_press

        LDX     #$FF
		
	.no_press
        CPX     #$FF
        RTS
}
ENDIF

\*-------------------------------
; Copy SHADOW
; A=Start address PAGE
\*-------------------------------

.beeb_copy_shadow
{
    STA smRead+2
    STA smWrite+2

    LDX #0
    
    .next_page
    \\ Read from visible screen
    LDA &FE34:EOR #&4:STA &FE34

    .read_page_loop
    .smRead
    LDA &FF00, X
    STA DISKSYS_BUFFER_ADDR, X
    INX
    BNE read_page_loop

    \\ Copy to alternate screen
    LDA &FE34:EOR #&4:STA &FE34

    .write_page_loop
    LDA DISKSYS_BUFFER_ADDR, X
    .smWrite
    STA &FF00, X
    INX
    BNE write_page_loop

    INC smRead+2
    INC smWrite+2

    BPL next_page

    RTS
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

.beeb_core_end
