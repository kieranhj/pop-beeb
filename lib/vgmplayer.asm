\ ******************************************************************
\\ VGM Player
\\ Code module
\ ******************************************************************

_ENABLE_AUDIO = TRUE				; enables output to sound chip (disable for silent testing/demo loop)
_ENABLE_VOLUME = TRUE

.vgm_player_start



\ ******************************************************************
\ * Optimized VGM music player routines
\ * Plays a RAW format VGM audio stream from an Exomiser compressed or uncompressed data stream
\ ******************************************************************

\ *	EXO VGM data file

\ * This must be compressed using the following flags:
\ * exomizer.exe raw -c -m 256 <file.raw> -o <file.exo>


;----------------------------------------------------------------------------------
; Music playback routines
;----------------------------------------------------------------------------------


\\ Initialise the VGM player with an Exomizer compressed data stream
\\ X - lo byte of data stream to be played
\\ Y - hi byte of data stream to be played
.vgm_init_stream
{
	\\ Initialise music player
	stz vgm_player_ended

	\\ Initialise exomizer - must have some data ready to decrunch
	jmp exo_init_decruncher	
}


.vgm_deinit_player
{
	\\ Deinitialise music player
	LDA #&FF
	STA vgm_player_ended

	\\ FALLS THROUGH TO vgm_silence_psg
}

.vgm_silence_psg
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

; VGM "Music" player - fetches data from a compressed EXO stream
; We use EXO since music tracks benefit around 50% less RAM by using compression
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
	phy
	jsr exo_get_decrunched_byte
	bcc not_sample_end
	ply
	JMP _sample_end

	.not_sample_end


	JSR psg_strobe
	ply
	dey

;	JMP sound_data_loop
	bpl sound_data_loop	; equivalent to JMP as will always be positive
	
	.wait_20_ms
	CLC
	RTS

	._player_end
	; Happens in deinit fn
	;STA vgm_player_ended

	\\ Silence sound chip
	JSR vgm_deinit_player

	._sample_end
	SEC
	RTS
}



;----------------------------------------------------------------------------------
; Sound effect playback routines
;----------------------------------------------------------------------------------




; Stop any currently playing SFX
.vgm_sfx_stop
{
	ldy #0
	; FALLS THROUGH to vgm_sfx_play with Y=0 means address is invalid.
}
; Play a sound effect from memory
; SFX are stored as uncompressed RAW VGM
; Currently only one SFX can be played at once
; X/Y contain address of SFX to be played
.vgm_sfx_play
{
	stx vgm_sfx_addr+0
	sty vgm_sfx_addr+1

	rts
}

; fetch a byte from the currently selected SFX RAW data buffer
; returns byte in A, Y is trashed, X is preserved
; data buffer address is auto-incremented.
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

; SFX update routine - checks if a SFX is queued and feeds one update's worth of data to the sound chip.
; Call this routine every 50Hz 
; Carry set if SFX finished
.vgm_sfx_update
{
	; only play something if sfx addr hi byte is valid
	lda vgm_sfx_addr+1
	beq finished

; Ignore music player status for sfx
	lda vgm_player_ended
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

; volume ramp table - set by audio_set_volume - note that on SN chip 15=off, 0=full
.volume_table	EQUB 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15		;


; local ZP vars
volume_interp = locals + 0
volume_increment = locals + 2
volume_store = locals + 3


; 0 = 16* 0 =   0 &00
; 1 = 16* 1 =  16 &10
; 2 = 16* 2 =  32 &20
; 8 = 16* 8 =     &80 
;...
;15 = 16*15 = 240 &F0

; at full volume, it's 0 to 15 (0-15)
; at half volume it's 8 to 15 (0-8)
; at silence it's 15 to 15 (0-0)

;
.vgm_volume EQUB 15 ; volume is 0-15 where 0 is silence, 15 is full



.vgm_volume_up
{
	ldx vgm_volume
	cpx #15
	beq quit
	inx
	stx vgm_volume
	jsr vgm_set_volume
.quit
	rts
}

.vgm_volume_down
{
	ldx vgm_volume
	beq quit
	dex 
	stx vgm_volume
	jsr vgm_set_volume
.quit
	rts
}

; set volume by setting the 16-byte volume_table ramp using a hacky linear interpolation
; TODO: needs a bug fix as the full volume ramp is out by 1 level
; Note that volumes below 7 will degrade music quality due to lack of precision
; on entry X is volume (0=silence, 15=full)
.vgm_set_volume
{
IF _ENABLE_VOLUME
;	stx volume_store
	lda #15
	sta volume_store
;	sec
;	sbc volume_store
;	sta volume_store
	; set volume table
	lda #0
	stz volume_interp+0
	stz volume_interp+1
	
	cpx #0
	beq done_loopx
	inc volume_store
.loopx
	dec volume_store
	clc
	adc #17
	dex
	bne loopx
.done_loopx
	sta volume_increment

	; x=0 on entry
.loopx2
	clc
	lda volume_interp+1
	adc volume_store
	sta volume_table,x

	lda volume_interp+0
	clc
	adc volume_increment
	sta volume_interp+0
	lda volume_interp+1
	adc #0
	sta volume_interp+1

	; offset volume
	inx
	cpx #16
	bne loopx2
ENDIF
	rts
}



; SN76489 register update
; A contains register data to write
; Trashes Y
.psg_strobe

.psg_strobe_sei
;	sei					; **SELF-MODIFIED CODE**

IF _ENABLE_VOLUME
; Check if volume control needs applying
; First check if bit 7 is set, 0=DATA 1=LATCH

	bit psg_latch_bit 	; 
	beq no_volume 		; [3]

;	; this is a latch register write
; and check bit 4 to see if it is a volume register write, 1=VOLUME, 0=PITCH
	bit psg_volume_bit	; [4]
	beq no_volume		; not a volume register write

	tay				; [2]
	and #&f0		; [2]
	sta psg_register
	tya				; [2]
	and #&0f		; [2]

	tay				; [2]
	lda volume_table,y
	and #&0f
	ora psg_register

.no_volume

ENDIF ; _ENABLE_VOLUME


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
;	cli					; **SELF-MODIFIED CODE**
	RTS

.psg_register	EQUB 0		; cant be in ZP as used in IRQ
.psg_volume_bit	EQUB 16		; bit 4
.psg_latch_bit	EQUB 128	; bit 7

;PSG_STROBE_SEI_INSN = psg_strobe_sei
;PSG_STROBE_CLI_INSN = psg_strobe_cli



.vgm_player_end

