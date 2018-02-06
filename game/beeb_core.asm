; beeb_core.asm
; Beeb specific routines that need to be in Core memory

TIMER_latch = 20000-2				; 20ms = 1x vsync :)
TIMER_start = (TIMER_latch /2)		; some % down the frame is our vsync point

.beeb_core_start

\*-------------------------------
; Set custom CRTC mode for game
\*-------------------------------

.beeb_set_mode2_no_clear
{
    \\ Wait vsync
    LDA #19
    JSR osbyte

    \\ Set CRTC registers
    LDX #13
    .crtcloop
    STX &FE00
    LDA beeb_crtcregs, X
    STA &FE01
    DEX
    BPL crtcloop

    \\ Set ULA
    LDA #&F4            ; MODE 2
    STA &248            ; Tell the OS or it will mess with ULA settings at vsync
    STA &FE20

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

IF 1
.beeb_crtcregs
{
	EQUB 127 			; R0  horizontal total
	EQUB BEEB_SCREEN_CHARS				; R1  horizontal displayed
	EQUB 98				; R2  horizontal position
	EQUB &28			; R3  sync width
	EQUB 38				; R4  vertical total
	EQUB 0				; R5  vertical total adjust
	EQUB BEEB_SCREEN_ROWS				; R6  vertical displayed
	EQUB 34				; R7  vertical position; 35=top of screen
	EQUB 0				; R8  interlace
	EQUB 7				; R9  scanlines per row
	EQUB 32				; R10 cursor start
	EQUB 8				; R11 cursor end
	EQUB HI(beeb_screen_addr/8)		; R12 screen start address, high
	EQUB LO(beeb_screen_addr/8)		; R13 screen start address, low
}

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
ENDIF

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

IF 0
.beeb_select_main_mem
{
\ Main & Aux used to map to SHADOW but no longer
\    LDA &FE34
\    AND #&FB            ; mask out bit 2
\    STA &FE34

\ Now maps to multiple SWRAM banks so...

    \\ Remember current bank
    LDA &F4: PHA

    RTS
}
ENDIF

MACRO BEEB_SELECT_AUX_MEM
{
    PLA:STA &F4:STA &FE30
}
ENDMACRO

IF 0
.beeb_select_aux_mem
{
\ Main & Aux used to map to SHADOW but no longer
\    LDA &FE34
\    ORA #&C          ; mask in bit 2 & 3 (for HAZEL)
\    STA &FE34
\ Then SHADOW + SWRAM
\    LDA #BEEB_SWRAM_SLOT_AUX_HIGH
\    JMP swr_select_slot

\ Now maps to multiple SWRAM banks so...

    \\ Restore original bank
    PLA
    STA &F4:STA &FE30

    RTS
}
ENDIF

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
    ; I think it was a mistake to wait for vsync here!

    LDA PAGE
    EOR #&20
    STA PAGE

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

IF _DEBUG
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

IF _DEBUG
.beeb_test_sprite_plot
{
    JSR loadperm

    LDX #1
    STX level
    JSR LoadLevelX

\\    JSR beeb_shadow_select_main

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
    AND #&1F
    LDA #41
    STA XCO

    LDA #127
    STA YCO

    LDA beeb_sprite_no
    STA IMAGE

    LDA #LO(chtable1)
    STA TABLE

    LDA #HI(chtable1)
    STA TABLE+1

    LDA #BEEB_SWRAM_SLOT_CHTAB13
    STA BANK

    LDA #enum_mask OR &80
    STA OPACITY

    JSR beeb_plot_sprite_MLayMask

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

\*-------------------------------
; Additional PREP before sprite plotting for Beeb
\*-------------------------------

.beeb_PREPREP
{
    \\ Must have a swram bank to select or assert
    LDA BANK
    JSR swr_select_slot

    \ Turns TABLE & IMAGE# into IMAGE ptr
    \ Obtains WIDTH & HEIGHT
    
    JSR PREPREP

    \ Set a palette per swram bank
    \ Could set palette per sprite table or even per sprite

    LDA PALETTE
    JMP beeb_plot_sprite_setpalette
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

.beeb_core_end
