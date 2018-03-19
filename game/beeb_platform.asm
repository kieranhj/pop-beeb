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

.beeb_platform_end
