\ ******************************************************************
\\ VGM Player
\\ Code module
\ ******************************************************************

_ENABLE_AUDIO = TRUE				; enables output to sound chip (disable for silent testing/demo loop)


.vgm_player_start



.tmp_var SKIP 1
.tmp_msg_idx SKIP 1


.num_to_bit				; look up bit N
EQUB &01, &02, &04, &08, &10, &20, &40, &80

\ ******************************************************************
\ *	VGM music player routines
\ * Plays a RAW format VGM music stream from an Exomiser compressed data stream
\ ******************************************************************

\ *	EXO VGM data file

\ * This must be compressed using the following flags:
\ * exomizer.exe raw -c -m 1024 <file.raw> -o <file.exo>


\\ Initialise the VGM player with an Exomizer compressed data stream
\\ X - lo byte of data stream to be played
\\ Y - hi byte of data stream to be played
.vgm_init_stream
{
	\\ Initialise exomizer - must have some data ready to decrunch
	JSR exo_init_decruncher

	\\ Initialise music player - parses header
	JSR	vgm_init_player

	RTS
}


.vgm_init_player				; return non-zero if error
{
IF VGM_HEADER
\\ <header section>
\\  [byte] - header size - indicates number of bytes in header section

	jsr exo_get_decrunched_byte
	STA tmp_var
	CMP #5
	BCS parse_header			; we need at least 5 bytes to parse!
	JMP error

	.parse_header

\\  [byte] - indicates the required playback rate in Hz eg. 50/60/100

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	CMP #VGM_PLAYER_sample_rate		; we only support 50Hz files
	BEQ is_50HZ					; return non-zero to indicate error
	JMP error
	.is_50HZ
	DEC tmp_var

\\  [byte] - packet count lsb

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	DEC tmp_var

\\  [byte] - packet count msb

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	DEC tmp_var

\\  [byte] - duration minutes

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	DEC tmp_var

\\  [byte] - duration seconds

	jsr exo_get_decrunched_byte		; should really check carry status for EOF

	.header_loop
	DEC tmp_var
	BEQ done_header

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	\\ don't know what this byte is so ignore it
	JMP header_loop

	.done_header

\\ <title section>
\\  [byte] - title string size
	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	STA tmp_var

\\  [dd] ... - ZT title string

	LDX #0
	.title_loop
	STX tmp_msg_idx
	LDA tmp_var
	BEQ done_title				; make sure we consume all the title string
	DEC tmp_var

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	LDX tmp_msg_idx
	CPX #VGM_PLAYER_string_max
	BCS title_loop				; don't write if buffer full
	INX
	JMP title_loop

	\\ Where title string is smaller than our buffer
	.done_title

	.title_pad_loop
	CPX #VGM_PLAYER_string_max
	BCS done_title_padding
	INX
	JMP title_pad_loop
	.done_title_padding

\\ <author section>
\\  [byte] - author string size



	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	STA tmp_var



\\  [dd] ... - ZT author string

	LDX #0
	.author_loop
	STX tmp_msg_idx
	LDA tmp_var
	BEQ done_author				; make sure we consume all the author string
	DEC tmp_var

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	LDX tmp_msg_idx
	CPX #VGM_PLAYER_string_max
	BCS author_loop
	INX
	JMP author_loop

	\\ Where author string is smaller than our buffer
	.done_author
	.author_pad_loop
	CPX #VGM_PLAYER_string_max
	BCS done_author_padding
	INX
	JMP author_pad_loop
	.done_author_padding

	\\ Initialise vars
	;LDA #&FF
	;STA vgm_player_counter
	;STA vgm_player_counter+1

ENDIF

	LDA #0
	STA vgm_player_ended
;	STA vgm_player_last_reg
;	STA vgm_player_reg_bits

	\\ Return zero 
	RTS

	\\ Return error
	.error
	LDA #&FF
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

.vgm_poll_player
{
	\\ Assume this is called every 20ms..
;	LDA #0
;	STA vgm_player_reg_bits

	LDA vgm_player_ended
	BNE _sample_end

\\ <packets section>
\\  [byte] - indicating number of data writes within the current packet (max 11)
\\  [dd] ... - data
\\  [byte] - number of data writes within the next packet
\\  [dd] ... - data
\\  ...`
\\ <eof section>
\\  [0xff] - eof

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
	;INC vgm_player_counter				; indicate we have completed another frame of audio
	;BNE no_carry
	;INC vgm_player_counter+1
	;.no_carry

	CLC
	RTS

	._player_end
	STA vgm_player_ended

	\\ Silence sound chip
	JSR vgm_deinit_player

;	INC vgm_player_counter				; indicate we have completed one last frame of audio
;	BNE _sample_end
;	INC vgm_player_counter+1

	._sample_end
	SEC
	RTS
}

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

