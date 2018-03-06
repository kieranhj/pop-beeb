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

.beeb_platform_end
