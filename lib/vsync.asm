

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

IF _AUDIO
    ; call our audio interrupt handler
	jsr audio_update
ENDIF




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