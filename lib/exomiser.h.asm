\\ ******************************************************************
\\ EXOMISER (compression library)
\\ ******************************************************************

EXO_buffer_len = 256
EXO_TABL_SIZE = 156

\\ Declare ZP vars
.EXO_zp_src_hi	SKIP 1
.EXO_zp_src_lo	SKIP 1
.EXO_zp_src_bi	SKIP 1
.EXO_zp_bitbuf	SKIP 1

.EXO_zp_len_lo	SKIP 1
.EXO_zp_len_hi	SKIP 1

.EXO_zp_bits_lo	SKIP 1
.EXO_zp_bits_hi	SKIP 1

.EXO_zp_dest_hi	SKIP 1
.EXO_zp_dest_lo	SKIP 1	; dest addr lo
.EXO_zp_dest_bi	SKIP 1	; dest addr hi

