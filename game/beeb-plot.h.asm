; beeb-plot
; BBC Micro plot functions
; Works directly on Apple II sprite data

.beeb_readptr    SKIP 2
.beeb_writeptr   SKIP 2

.beeb_numimages  SKIP 1
.beeb_width      SKIP 1
.beeb_height     SKIP 1

.beeb_yoffset    SKIP 1
.beeb_yindex     SKIP 1

.beeb_carry         SKIP 1
;.beeb_apple_count    SKIP 1          ; width
.beeb_temp_y        SKIP 1
;.beeb_apple_byte     SKIP 1          ; sprite data

.beeb_temp_offset   SKIP 1
;.beeb_byte      SKIP 1              ; no lookup for screen byte
.beeb_temp_width    SKIP 1
;.beeb_count     SKIP 1              ; beeb bits (8/4)

.beeb_next_carry    SKIP 1
;.beeb_bit_count  SKIP 1              ; apple bits (7)
.beeb_pal_index  SKIP 1              ; lookup for screen byte

.beeb_sprite_no  SKIP 1
.beeb_rem        SKIP 1

BEEB_SCREEN_MODE = 4
;BEEB_SCREEN_ROW_BYTES = 640
