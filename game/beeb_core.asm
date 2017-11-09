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
; SHADOW RAM select
\*-------------------------------

.beeb_shadow_select_main
{
\    LDA &FE34
\    AND #&FB            ; mask out bit 2
\    STA &FE34
    RTS
}

.beeb_shadow_select_aux
{
    LDA &FE34
    ORA #&8         ;&C          ; mask in bit 2 & 3 (for HAZEL)
    STA &FE34

\ Also page in AUX HIGH code in SWRAM bank

    LDA #BEEB_SWRAM_SLOT_AUX_HIGH
    JMP swr_select_slot
}

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
    LDA PAGE
    EOR #&20
    STA PAGE

    lda &fe34
    eor #1+4	; invert bits 0 & 2
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
ELSE
    LDA #19
    JMP osbyte
ENDIF

    RTS
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

.beeb_PREPREP
{
    \\ Must have a swram bank to select or assert
    LDA BANK
    JSR swr_select_slot

    \ Set a palette per swram bank
    \ Could set palette per sprite table or even per sprite

    LDY BANK
    LDA bank_to_palette_temp,Y
    JSR beeb_plot_sprite_SetExilePalette

    \ Turns TABLE & IMAGE# into IMAGE ptr
    \ Obtains WIDTH & HEIGHT
    
    JMP PREPREP
}

\*-------------------------------
; Exile palette tables

.palette_value_to_pixel_lookup
{
    MODE2_PIXELS    MODE2_RED_PAIR, MODE2_YELLOW_PAIR
    MODE2_PIXELS    MODE2_BLUE_PAIR, MODE2_CYAN_PAIR
    MODE2_PIXELS    MODE2_MAGENTA_PAIR, MODE2_RED_PAIR
    MODE2_PIXELS    MODE2_MAGENTA_PAIR, MODE2_BLUE_PAIR
    equb $EB                        ; white bg, red bg
    equb $CE                        ; yellow bg, green bg
    equb $F8                        ; cyan bg, blue bg
    equb $E6                        ; magenta bg, green bg
    equb $CC                        ; green bg, green bg
    equb $EE                        ; white bg, green bg
    equb $30                        ; blue fg, blue fg
    equb $DE                        ; yellow bg, cyan bg
    equb $EF                        ; white bg, yellow bg
    equb $CB                        ; yellow bg, red bg
    equb $FB                        ; white bg, magenta bg
    equb $FE                        ; white bg, cyan bg
}

.pixel_table
{
    ;                                 ABCDEFGH
    equb $00                        ; 00000000 0  0  
    equb $03                        ; 00000011 1  1  
    equb $0C                        ; 00001100 2  2  
    equb $0F                        ; 00001111 3  3  
    equb $30                        ; 00110000 4  4  
    equb $33                        ; 00110011 5  5  
    equb $3C                        ; 00111100 6  6  
    equb $3F                        ; 00111111 7  7  
    equb $C0                        ; 11000000 8  8  
    equb $C3                        ; 11000011 9  9  
    equb $CC                        ; 11001100 10 10
    equb $CF                        ; 11001111 11 11
    equb $F0                        ; 11110000 12 12
    equb $F3                        ; 11110011 13 13
    equb $FC                        ; 11111100 14 14
    equb $FF                        ; 11111111 15 15
}

\*-------------------------------
; Beeb screen multiplication tables

\*-------------------------------
; Very lazy table for turning MODE 2 black pixels into MASK

PAGE_ALIGN
.mask_table
FOR byte,0,255,1
left=byte AND &AA
right=byte AND &55

IF left = 0

    IF right = 0
        EQUB &FF
    ELSE
        EQUB &AA
    ENDIF

ELSE

    IF right = 0
        EQUB &55
    ELSE
        EQUB &00
    ENDIF

ENDIF

NEXT

MACRO MAP_2BPP_TO_MODE2 col1, col2, col3
FOR byte,0,&CC,1
D=(byte AND &80)>>6 OR (byte AND &8)>>3
C=(byte AND &40)>>5 OR (byte AND &4)>>2
B=(byte AND &20)>>4 OR (byte AND &2)>>1
A=(byte AND &10)>>3 OR (byte AND &1)>>0
; Pixels DCBA (0,3)
; Map pairs DC and BA of left & right pixels
IF D=0
    pD=0
ELIF D=1
    pD=col1 AND MODE2_LEFT_MASK
ELIF D=2
    pD=col2 AND MODE2_LEFT_MASK
ELSE
    pD=col3 AND MODE2_LEFT_MASK
ENDIF

IF C=0
    pC=0
ELIF C=1
    pC=col1 AND MODE2_RIGHT_MASK
ELIF C=2
    pC=col2 AND MODE2_RIGHT_MASK
ELSE
    pC=col3 AND MODE2_RIGHT_MASK
ENDIF

IF B=0
    pB=0
ELIF B=1
    pB=col1 AND MODE2_LEFT_MASK
ELIF B=2
    pB=col2 AND MODE2_LEFT_MASK
ELSE
    pB=col3 AND MODE2_LEFT_MASK
ENDIF

IF A=0
    pA=0
ELIF A=1
    pA=col1 AND MODE2_RIGHT_MASK
ELIF A=2
    pA=col2 AND MODE2_RIGHT_MASK
ELSE
    pA=col3 AND MODE2_RIGHT_MASK
ENDIF

EQUB pA OR pB OR pC OR pD
NEXT
ENDMACRO

PAGE_ALIGN
.map_2bpp_to_mode2_palN
MAP_2BPP_TO_MODE2 MODE2_CYAN_PAIR, MODE2_GREEN_PAIR, MODE2_WHITE_PAIR

.Mult16_HI          ; or shift...
FOR n,0,39,1
EQUB HI(n*16)
NEXT

; This table turns MODE 5 2bpp packed data directly into MODE 2 mask bytes

PAGE_ALIGN
.map_2bpp_to_mask
FOR byte,0,&CC,1
left=(byte AND &88) OR (byte AND &22)
right=(byte AND &44) OR (byte AND &11)

IF left = 0

    IF right = 0
        EQUB &FF
    ELSE
        EQUB &AA
    ENDIF

ELSE

    IF right = 0
        EQUB &55
    ELSE
        EQUB &00
    ENDIF

ENDIF

NEXT

.Mult16_LO
FOR n,0,39,1
EQUB LO(n*16)
NEXT

PAGE_ALIGN
.map_2bpp_to_mode2_pixel            ; background
{
    EQUB &00                        ; 00000000 either pixel logical 0
    EQUB &10                        ; 000A000a right pixel logical 1
    EQUB &20                        ; 00B000b0 left pixel logical 1

    skip &0D

    EQUB &40                        ; 000A000a right pixel logical 2
    EQUB &50                        ; 000A000a right pixel logical 3

    skip &0E

    EQUB &80                        ; 00B000b0 left pixel logical 2
    skip 1
    EQUB &A0                        ; 00B000b0 left pixel logical 3
}
\\ Flip entries in this table when parity changes

\*-------------------------------
; Set palette per swram bank
; Needs to be a palette per image bank
; Or even better per sprite

.bank_to_palette_temp
{
    EQUB &71            \ bg
    EQUB &72            \ chtab13
    EQUB &72            \ chtab25
    EQUB &73            \ chtab467
}

.beeb_core_end
