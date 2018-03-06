
\ ******************************************************************
\ *	Exomiser (decompression library)
\ ******************************************************************

.exo_start



\\ Uses memory:
\\ &0400-0800	- 1024 byte decompression buffer
\\ &0D02-0D9F	-  156 byte decompression table
\\ Plus ZP vars
\\ Exomiser decruncher routine installs empty NMI handler at &0d00

\\ Compress data using:
\\ exomizer.exe raw -c -m 256 <file.raw> -o <file.exo>

\ ******************************************************************
\ *	Space reserved for runtime buffers not preinitialised
\ ******************************************************************

; this is now packed in to language workspace at &0400
\\ If you want to make this bigger than 1024 then need to find somewhere else to put it!!

\\ Exomiser unpack buffer (must be page aligned)
\\ Now moved this to the language workspace at &0400 - &0800
EXO_buffer_start = EXO_buffer ; &400
EXO_buffer_end = EXO_buffer_start + EXO_buffer_len

; -------------------------------------------------------------------
; this 156 byte table area may be relocated. It may also be clobbered
; by other data between decrunches.
; Located at spare OS memory page &0d02 - 0x0d9f reserved for Econet/Trackball/NMI
; RTI (&40) is written to &0d00 for clean NMI handler
; -------------------------------------------------------------------
; Note that page 13 is used by SmartSPI as workspace RAM, so not safe to put EXO buffer here anymore.
EXO_TABL_SIZE = 156

IF TRUE

.exo_tabl_bi SKIP EXO_TABL_SIZE
SMART_SPI_FIX = TRUE

ELSE

	SMART_SPI_FIX = TRUE




	IF SMART_SPI_FIX
	exo_tabl_bi  = &0cff - EXO_TABL_SIZE
	ELSE
	exo_tabl_bi  = &0d9f - EXO_TABL_SIZE
	ENDIF

ENDIF


exo_tabl_lo = exo_tabl_bi + 52
exo_tabl_hi = exo_tabl_bi + 104


; -------------------------------------------------------------------
; Unpack a compressed data stream previously initialized by exo_init_decruncher
; to the memory address specified in X,Y





.exo_unpack
{
	STX write_chr+1
	STY write_chr+2

	.next_chr
	JSR exo_get_decrunched_byte
	BCS all_done
	.write_chr	STA &ffff				; **SELF-MODIFIED**
	INC write_chr+1
	BNE next_chr
	INC write_chr+2
	BNE next_chr
	.all_done
	RTS
}

; -------------------------------------------------------------------
; Fetch byte from an exomiser compressed data stream
; for this exo_get_crunched_byte routine to work the crunched data has to be
; crunced using the -m <buffersize> and possibly the -l flags. Any other
; flag will just mess things up.
.exo_get_crunched_byte
{

._byte
	lda &ffff ; EXO data stream address	; **SELF-MODIFIED CODE**
_byte_lo = _byte + 1
_byte_hi = _byte + 2

	\\ advance input stream memory address
	INC _byte_lo
	bne _byte_skip_hi
	INC _byte_hi			; forward decrunch
._byte_skip_hi:

	rts						; decrunch_file is called.
}

; -------------------------------------------------------------------


EXO_crunch_byte_lo = exo_get_crunched_byte + 1
EXO_crunch_byte_hi = exo_get_crunched_byte + 2



; -------------------------------------------------------------------
; jsr this label to init the decruncher, it will init used zeropage
; zero page locations and the decrunch tables
; no constraints on register content, however the
; decimal flag has to be #0 (it almost always is, otherwise do a cld)
; X/Y contains address of EXO crunched data stream
; -------------------------------------------------------------------
.exo_init_decruncher				; pass in address of (crunched data-1) in X,Y
{
IF SMART_SPI_FIX
	; EXO buffer has been relocated from &0D00 so no need to hack NMI stuff
ELSE
	lda #&40					; Ensure RTI at &0D00 for clean NMI handling
	sta &0D00					; should possibly call *fx143,12 to claim NMI ownership also
ENDIF
	
	
	stx EXO_crunch_byte_lo
	sty EXO_crunch_byte_hi

	jsr exo_get_crunched_byte
	sta EXO_zp_bitbuf

	ldx #0
	stx EXO_zp_dest_lo
	stx EXO_zp_dest_hi
	stx EXO_zp_len_lo
	stx EXO_zp_len_hi
	ldy #0
; -------------------------------------------------------------------
; calculate tables (49 bytes)
; x and y must be #0 when entering
;
._init_nextone
	inx
	tya
	and #$0f
	beq _init_shortcut		; starta p� ny sekvens

	txa			; this clears reg a
	lsr a			; and sets the carry flag
	ldx EXO_zp_bits_lo
._init_rolle
	rol a
	rol EXO_zp_bits_hi
	dex
	bpl _init_rolle		; c = 0 after this (rol EXO_zp_bits_hi)

	adc exo_tabl_lo-1,y
	tax

	lda EXO_zp_bits_hi
	adc exo_tabl_hi-1,y
._init_shortcut
	sta exo_tabl_hi,y
	txa
	sta exo_tabl_lo,y

	ldx #4
	jsr exo_bit_get_bits		; clears x-reg.
	sta exo_tabl_bi,y
	iny
	cpy #52
	bne _init_nextone
}
\\ Fall through!	

._do_exit
	rts

; -------------------------------------------------------------------
; decrunch one byte
;
.exo_get_decrunched_byte
{
	ldy EXO_zp_len_lo
	bne _do_sequence
	ldx EXO_zp_len_hi
	bne _do_sequence2

	jsr exo_bit_get_bit1
	beq _get_sequence
; -------------------------------------------------------------------
; literal handling (13 bytes)
;
	jsr exo_get_crunched_byte
	bcc _do_literal
; -------------------------------------------------------------------
; count zero bits + 1 to get length table index (10 bytes)
; y = x = 0 when entering
;
._get_sequence
._seq_next1
	iny
	jsr exo_bit_get_bit1
	beq _seq_next1
	cpy #$11
	bcs _do_exit
; -------------------------------------------------------------------
; calulate length of sequence (zp_len) (17 bytes)
;
	ldx exo_tabl_bi - 1,y
	jsr exo_bit_get_bits
	adc exo_tabl_lo - 1,y
	sta EXO_zp_len_lo
	lda EXO_zp_bits_hi
	adc exo_tabl_hi - 1,y
	sta EXO_zp_len_hi
; -------------------------------------------------------------------
; here we decide what offset table to use (20 bytes)
; x is 0 here
;
	bne _seq_nots123
	ldy EXO_zp_len_lo
	cpy #$04
	bcc _seq_size123
._seq_nots123
	ldy #$03
._seq_size123
	ldx exo_tabl_bit - 1,y
	jsr exo_bit_get_bits
	adc exo_tabl_off - 1,y
	tay
; -------------------------------------------------------------------
; calulate absolute offset (zp_src) (27 bytes)
;
	ldx exo_tabl_bi,y
	jsr exo_bit_get_bits;
	adc exo_tabl_lo,y
	bcc _seq_skipcarry
	inc EXO_zp_bits_hi
	clc
._seq_skipcarry
	adc EXO_zp_dest_lo
	sta EXO_zp_src_lo
	lda EXO_zp_bits_hi
	adc exo_tabl_hi,y
	adc EXO_zp_dest_hi
; -------------------------------------------------------------------
	cmp #HI(EXO_buffer_len)
	bcc _seq_offset_ok
	sbc #HI(EXO_buffer_len)
	clc
; -------------------------------------------------------------------
._seq_offset_ok
	sta EXO_zp_src_hi
	adc #HI(EXO_buffer_start)
	sta EXO_zp_src_bi
._do_sequence
	ldy #0
._do_sequence2
	ldx EXO_zp_len_lo
	bne _seq_len_dec_lo
	dec EXO_zp_len_hi
._seq_len_dec_lo
	dec EXO_zp_len_lo
; -------------------------------------------------------------------
	ldx EXO_zp_src_lo
	bne _seq_src_dec_lo
	ldx EXO_zp_src_hi
	bne _seq_src_dec_hi
; ------- handle buffer wrap problematics here ----------------------
	ldx #HI(EXO_buffer_len)
	stx EXO_zp_src_hi
	ldx #HI(EXO_buffer_end)
	stx EXO_zp_src_bi
; -------------------------------------------------------------------
._seq_src_dec_hi
	dec EXO_zp_src_hi
	dec EXO_zp_src_bi
._seq_src_dec_lo
	dec EXO_zp_src_lo
; -------------------------------------------------------------------
	lda (EXO_zp_src_lo),y
; -------------------------------------------------------------------
._do_literal
	ldx EXO_zp_dest_lo
	bne _seq_dest_dec_lo
	ldx EXO_zp_dest_hi
	bne _seq_dest_dec_hi
; ------- handle buffer wrap problematics here ----------------------
	ldx #HI(EXO_buffer_len)
	stx EXO_zp_dest_hi
	ldx #HI(EXO_buffer_end)
	stx EXO_zp_dest_bi
; -------------------------------------------------------------------
._seq_dest_dec_hi
	dec EXO_zp_dest_hi
	dec EXO_zp_dest_bi
._seq_dest_dec_lo
	dec EXO_zp_dest_lo
; -------------------------------------------------------------------
	sta (EXO_zp_dest_lo),y
	clc
	rts
}

; -------------------------------------------------------------------
; two small static tables (6 bytes)
;
.exo_tabl_bit
{
	EQUB 2,4,4
}
.exo_tabl_off
{
	EQUB 48,32,16
}

; -------------------------------------------------------------------
; get x + 1 bits (1 byte)
;
.exo_bit_get_bit1
	inx
; -------------------------------------------------------------------
; get bits (31 bytes)
;
; args:
;   x = number of bits to get
; returns:
;   a = #bits_lo
;   x = #0
;   c = 0
;   EXO_zp_bits_lo = #bits_lo
;   EXO_zp_bits_hi = #bits_hi
; notes:
;   y is untouched
;   other status bits are set to (a == #0)
; -------------------------------------------------------------------
.exo_bit_get_bits
{
	lda #$00
	sta EXO_zp_bits_lo
	sta EXO_zp_bits_hi
	cpx #$01
	bcc _bit_bits_done
	lda EXO_zp_bitbuf
._bit_bits_next
	lsr a
	bne _bit_ok
	jsr exo_get_crunched_byte
	ror a
._bit_ok
	rol EXO_zp_bits_lo
	rol EXO_zp_bits_hi
	dex
	bne _bit_bits_next
	sta EXO_zp_bitbuf
	lda EXO_zp_bits_lo
._bit_bits_done
	rts
}
; -------------------------------------------------------------------
; end of decruncher
; -------------------------------------------------------------------


.exo_end

