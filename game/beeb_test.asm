; beeb_test.asm
; Beeb routines to test sprite plotting etc.

.beeb_test_start

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

.beeb_test_end
