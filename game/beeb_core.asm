; beeb_core.asm
; Beeb specific routines that need to be in Core memory

TIMER_latch = 20000-2				; 20ms = 1x vsync :)
TIMER_start = (TIMER_latch /2)		; some % down the frame is our vsync point

.beeb_core_start

\*-------------------------------
; Set custom CRTC mode
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
    LDA #&F4            ; MODE 2
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
; SHADOW RAM select
\*-------------------------------

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

\ Also page in AUX HIGH code in SWRAM bank

    LDA #BEEB_SWRAM_SLOT_AUX_HIGH
    JMP swr_select_slot
}

\*-------------------------------
; VSYNC code
\*-------------------------------

.beeb_wait_vsync
{
IF _ENABLE_IRQ_VSYNC
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

IF _ENABLE_IRQ_VSYNC
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

    JSR beeb_shadow_select_main

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

.beeb_core_end
