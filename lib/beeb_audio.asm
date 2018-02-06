; POP - BBC MICRO - AUDIO ROUTINES
; Very much a WIP atm



; POP BBC PORT - Music player hook
; See aux_core.asm for the jump tables
; See soundnames.h.asm for the various effects & music enums
.BEEB_CUESONG
{
    lda #0
    jsr music_play_track
	rts
}
.BEEB_ADDSOUND
{
    lda #9	; SM Hacked to play a sfx
    jsr music_play_track	
	rts	
}



; call this function once to initialise the music system
.music_init
{
	jsr music_off

    \\ Start our event driven fx
    ldx #LO(music_event_handler)
    ldy #HI(music_event_handler)
    jsr start_eventv
	rts
}

.music_quit
{
    \\ Kill our event driven fx
    jsr stop_eventv
    rts
}

\\ Initialise music player - pass in VGM_stream_data address in X/Y, RAM bank number in A, or &80 for ANDY
\\ parses header from stream

.music_play
{
    sei

    sta fx_music_bank
    stx fx_music_addr+0
    sty fx_music_addr+1

    lda &f4
    pha

    ; page in the music bank - ANDY
    lda fx_music_bank
    jsr swr_select_bank

    ldx fx_music_addr+0
    ldy fx_music_addr+1
	jsr	vgm_init_stream

  
    ; restore previously paged ROM bank
    pla
    jsr swr_select_bank

	jsr music_on


    cli
    rts
    
}



; format is: address, bank
.pop_music_tracks
IF TRUE
    EQUW pop_music_01, &80
    EQUW pop_music_02, &80
    EQUW pop_music_03, &80
    EQUW pop_music_04, &80
    EQUW pop_music_05, &80
    EQUW pop_music_06, &80
    EQUW pop_music_07, &80
    EQUW pop_music_08, &80
    EQUW pop_music_09, &80		; #8
ENDIF
.pop_sound_fx
	EQUW pop_landing_sfx, &80		; #9


; A contains music track - 0 to 8
.music_play_track
{
    asl a
    asl a
    tax
    ; get bank
    lda pop_music_tracks+2,x
    pha
    ; get address
    lda pop_music_tracks+1,x
    tay
    lda pop_music_tracks+0,x
    tax
    pla
    ; play the track
    jsr music_play
    rts 
}

.fx_music_addr  SKIP 2
.fx_music_on    EQUB 0
.fx_music_bank  EQUB 0

.music_on
{
    lda #1
    sta fx_music_on
    rts
}

.music_off
{
    lda #0
    sta fx_music_on
	rts
}

.music_stop
{
	jsr music_off
    jsr vgm_deinit_player    
    rts
}

; called by vsync handler
.music_update
{
;    bra music_update_exit ; test code
    lda fx_music_on
    beq music_update_exit


    lda &f4
    pha

    ; page in the music bank
    lda fx_music_bank
    jsr swr_select_bank


	\\ Poll the music player
	jsr vgm_poll_player
    
    ; restore previously paged ROM bank
    pla
    jsr swr_select_bank

.music_update_exit
    rts    
}



.music_event_handler
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

    ; call our music interrupt handler
	jsr music_update
	
;	lda  count
;	sta &7c00
;	inc count

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
;.count EQUB 0
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
IF TRUE
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