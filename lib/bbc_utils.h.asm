\ ******************************************************************
\ *	Handy BBC Micro Macros
\ ******************************************************************

\\ Switch to given screen mode
MACRO BBC_SET_MODE mode
	LDA #22
	JSR &FFEE
	LDA #mode
	JSR &FFEE
ENDMACRO

\\ Turn off cursor by directly poking crtc
MACRO BBC_CURSOR_OFF
	LDA #10: STA &FE00
	LDA #32: STA &FE01
ENDMACRO

\\ Turn off cursor using OSWRCH
MACRO BBC_CURSOR_OFF_VDU
	LDA #23
	JSR &FFEE
	LDA #1
	JSR &FFEE
	LDA #0
	JSR &FFEE
	JSR &FFEE
	JSR &FFEE
	JSR &FFEE
	JSR &FFEE
	JSR &FFEE
	JSR &FFEE
	JSR &FFEE
ENDMACRO

\\ wait for vertical refresh
MACRO BBC_VSYNC
	lda #19
	jsr OSBYTE
ENDMACRO

\\ reset all memory from &3000 to &8000 to zero
\\ hides unsightly artefacts when screen mode switches
\\ 
MACRO BBC_CLEAR_VRAM
	sei
	lda #&30
	sta loop2+2
	lda #0
	ldy #&50
.loop
	ldx #0
.loop2
	sta &3000,x
	inx
	bne loop2
	inc loop2+2
	dey
	bne loop
	cli
ENDMACRO

; Emit the given cycle count & timing in milliseconds
MACRO OUTPUT_CYCLES cycles
PRINT " cycles=",cycles,",", 1/2000000*cycles*1000, "ms"
ENDMACRO

; Emit the byte size of a code routine - pass in the label of the routine and call this macro at the end of the routine.
MACRO OUTPUT_SIZE label
PRINT " code size=", *-label
ENDMACRO


; Emit some sound from the SN76489
; Freq=Hz
; channel=0 to 3, where 3 is noise channel
; volume=0 to 15 where 15 is loudest 
MACRO CHIPSOUND freq, channel, volume
    SNV = 4000000 / (2.0 * freq * 16.0 )
;	LDA #&9F + (channel<<5): JSR psg_strobe    ; ch zero vol
    LDA #&90 + (channel<<5) + (15-volume): JSR psg_strobe    ; ch vol	
	LDA #&80 + (channel<<5) + (SNV AND 15): JSR psg_strobe    ; ch tone bits 0-4
	LDA #SNV/16: JSR psg_strobe    ; ch0 tone bits 5-10
ENDMACRO

; freq=0 to 7, where bit 0-1 is freq, bit 2=1=white noise
MACRO CHIPNOISE freq, volume
    LDA #&90 + (3<<5) + (15-volume): JSR psg_strobe    ; ch vol
	LDA #&80 + (3<<5) + (freq AND 7): JSR psg_strobe    ; ch tone bits 0-3
	; no need to write data byte for noise channel
ENDMACRO
