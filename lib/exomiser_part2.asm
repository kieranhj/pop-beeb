; -------------------------------------------------------------------
; decrunch one byte
;
._do_exit
    rts
    
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

