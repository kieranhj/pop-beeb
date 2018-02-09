\ ******************************************************************
\\ VGM Player
\\ Code module
\ ******************************************************************

_ENABLE_AUDIO = TRUE				; enables output to sound chip (disable for silent testing/demo loop)


.vgm_player_start



;.tmp_var SKIP 1
;.tmp_msg_idx SKIP 1


;.num_to_bit				; look up bit N
;EQUB &01, &02, &04, &08, &10, &20, &40, &80

\ ******************************************************************
\ *	VGM music player routines
\ * Plays a RAW format VGM audio stream from an Exomiser compressed data stream
\ ******************************************************************

\ *	EXO VGM data file

\ * This must be compressed using the following flags:
\ * exomizer.exe raw -c -m 256 <file.raw> -o <file.exo>


\\ Initialise the VGM player with an Exomizer compressed data stream
\\ X - lo byte of data stream to be played
\\ Y - hi byte of data stream to be played
.vgm_init_stream
{
	\\ Initialise exomizer - must have some data ready to decrunch
	JSR exo_init_decruncher

	\\ Initialise music player
	LDA #0
	STA vgm_player_ended

	RTS
}


.vgm_deinit_player
{
	\\ Zero volume on all channels
	LDA #&9F: JSR psg_strobe
	LDA #&BF: JSR psg_strobe
	LDA #&DF: JSR psg_strobe
	LDA #&FF: JSR psg_strobe
	.return
	RTS
}

\\ "RAW" VGM data is just packets of chip register data, terminated with 255
\\ <packets section>
\\  [byte] - indicating number of data writes within the current packet (max 11)
\\  [dd] ... - data
\\  [byte] - number of data writes within the next packet
\\  [dd] ... - data
\\  ...`
\\ <eof section>
\\  [0xff] - eof

.vgm_poll_player
{
	\\ Assume this is called every 20ms..
	LDA vgm_player_ended
	BNE _sample_end

	\\ Get next byte from the stream
	jsr exo_get_decrunched_byte
	bcs _sample_end

	cmp #&ff
	beq _player_end

	\\ Byte is #data bytes to send to sound chip:
	TAY
	.sound_data_loop
	BEQ wait_20_ms
	TYA:PHA
	jsr exo_get_decrunched_byte
	bcc not_sample_end
	PLA
	JMP _sample_end

	.not_sample_end


	JSR psg_strobe
	PLA:TAY:DEY
	JMP sound_data_loop
	
	.wait_20_ms
	CLC
	RTS

	._player_end
	STA vgm_player_ended

	\\ Silence sound chip
	JSR vgm_deinit_player

	._sample_end
	SEC
	RTS
}

.vgm_sfx_stop
{
	ldy #0
	; FALLS THROUGH to vgm_sfx_play with Y=0 means address is invalid.
}
; X/Y contain address of SFX to be played
.vgm_sfx_play
{
	stx vgm_sfx_addr+0
	sty vgm_sfx_addr+1
	rts
}


.vgm_sfx_get_byte
{
	ldy #0
	lda (vgm_sfx_addr),y
	tay
	; advance ptr
	inc vgm_sfx_addr+0
	bne no_skip
	inc vgm_sfx_addr+1
.no_skip	
	tya	; so that flags are set
	rts
}

\\ Call every 50Hz to update any currently playing sfx
; Carry set if SFX finished
.vgm_sfx_update
{
	lda vgm_sfx_addr+1
	beq finished

	\\ Get packet size
	\\ Byte is #data bytes to send to sound chip:

	jsr vgm_sfx_get_byte
	beq packet_end

	; end of stream?
	cmp #&ff
	bne update

	; invalidate address
	lda #0
	sta vgm_sfx_addr+1

	\\ Silence sound chip
	JSR vgm_deinit_player
.finished
	sec
	rts

.update
	tax

.sound_data_loop

	; fetch packet byte
	jsr vgm_sfx_get_byte

	; send to sound chip
	jsr psg_strobe

	; for all bytes in packet
	dex
	bne sound_data_loop
.packet_end
	clc
	rts
}


; SN76489 register update
; A contains register data to write
; Trashes Y
.psg_strobe

.psg_strobe_sei
	sei					; **SELF-MODIFIED CODE**

IF _ENABLE_AUDIO

	ldy #255
	sty $fe43
	
	sta $fe41
	lda #0
	sta $fe40
	nop
	nop
	nop
	nop
	nop
	nop
	lda #$08
	sta $fe40

ENDIF ; _ENABLE_AUDIO

.psg_strobe_cli
	cli					; **SELF-MODIFIED CODE**
	RTS



PSG_STROBE_SEI_INSN = psg_strobe_sei
PSG_STROBE_CLI_INSN = psg_strobe_cli



.vgm_player_end

