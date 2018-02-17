

.vsync_init
{

    \\ Start our event driven fx
    ldx #LO(event_handler)
    ldy #HI(event_handler)
    jsr start_eventv
    rts    
}

.vsync_exit
{
    \\ Kill our event driven fx
    jsr stop_eventv
    rts    
}

\ ******************************************************************
\ *	Event Vector Routines
\ ******************************************************************

\\ System vars
.old_eventv				SKIP 2

.start_eventv				; new event handler in X,Y
{
	\\ Remove interrupt instructions
	lda #NOP_OP
	sta PSG_STROBE_SEI_INSN
	sta PSG_STROBE_CLI_INSN
	
	\\ Set new Event handler
	sei
	lda EVENTV
	sta old_eventv
	lda EVENTV+1
	sta old_eventv+1

	stx EVENTV
	sty EVENTV+1
	cli
	
	\\ Enable VSYNC event.
	lda #14
	ldx #4
	jsr osbyte
	rts
}

.stop_eventv
{
	\\ Disable VSYNC event.
	lda #13
	ldx #4
	jsr osbyte

	\\ Reset old Event handler
	sei
	lda old_eventv
	sta EVENTV
	lda old_eventv+1
	sta EVENTV+1
	cli 

	\\ Insert interrupt instructions back
	lda #SEI_OP
	sta PSG_STROBE_SEI_INSN
	lda #CLI_OP
	sta PSG_STROBE_CLI_INSN
	rts
}        

.vsync_palette_override EQUB &FF

.vsync_request_flip	EQUB 0

.event_handler
{
	php
	cmp #4
	bne not_vsync

	\\ Preserve registers
	pha:txa:pha:tya:pha

	; prevent re-entry
	lda re_entrant
	bne skip_update
	inc re_entrant

    ;-------------------------------------------------
    ; Add vsync IRQ service routines here 
    ;-------------------------------------------------

	\\ Increment vsync counter
	INC beeb_vsync_count

	LDA vsync_request_flip
	BEQ no_flip
	JSR PageFlip
	DEC vsync_request_flip
	.no_flip

IF _AUDIO
    ; call our audio interrupt handler
	jsr audio_update
ENDIF
	
	; hack in screen flash
	{
		LDA vsync_palette_override
		BMI default

		JSR beeb_set_palette_all
		JMP skip_palette

		.default
		CMP #&FF
		BEQ skip_palette

		JSR beeb_set_default_palette

		LDA #&FF
		STA vsync_palette_override
		.skip_palette
	}

    ;-------------------------------------------------

	dec re_entrant
.skip_update

	\\ Restore registers
	pla:tay:pla:tax:pla

	\\ Return
    .not_vsync
	plp
	jmp (old_eventv)
	rts
.re_entrant EQUB 0
}