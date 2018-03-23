\ ******************************************************************
\ *	Event Vector Routines
\ ******************************************************************

\\ System vars
.old_eventv				SKIP 2

.start_eventv				; new event handler in X,Y
{
	\\ Remove interrupt instructions
;	lda #NOP_OP
;	sta PSG_STROBE_SEI_INSN
;	sta PSG_STROBE_CLI_INSN
	
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
	jmp osbyte
}

IF 0			; not currently used
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
ENDIF

.vsync_palette_override EQUB &FF

.vsync_swap_buffers	EQUB 0

.vsync_enable_timer EQUB 0
.vsync_timer_ticks	EQUW 0

.vsync_start_timer
{
	LDA #&FF
	STA vsync_enable_timer

	STZ vsync_timer_ticks+0
	STZ vsync_timer_ticks+1

	RTS
}

.vsync_stop_timer
{
	STZ vsync_enable_timer
	RTS
}

.event_handler
{
	php
	cmp #4
	bne not_vsync

	\\ Preserve registers
	pha:txa:pha:tya:pha

	; prevent re-entry  - KC do we need this?
	lda re_entrant
	bne skip_update
	inc re_entrant

    ;-------------------------------------------------
    ; Add vsync IRQ service routines here 
    ;-------------------------------------------------

	\\ Increment vsync counter
	INC beeb_vsync_count

	\\ Swap frame buffers if requested
	LDA vsync_swap_buffers
	BEQ no_swap
	JSR shadow_swap_buffers
	DEC vsync_swap_buffers
	.no_swap

IF _AUDIO
    ; call our audio interrupt handler
	jsr audio_update
ENDIF
	
	; is real time counter enabled?
	{
		LDA vsync_enable_timer
		BEQ done

		INC vsync_timer_ticks+0
		BNE done
		INC vsync_timer_ticks+1
		.done
	}

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