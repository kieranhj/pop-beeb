; beeb-plot
; BBC Micro plot functions
; Works directly on Apple II sprite data

.beeb_readptr    SKIP 2
.beeb_writeptr   SKIP 2

.beeb_numimages  SKIP 1
.beeb_sprite_no  SKIP 1

.beeb_width      SKIP 1
.beeb_height     SKIP 1

.beeb_yoffset    SKIP 1
.beeb_stack_ptr  SKIP 1

.beeb_parity     SKIP 1
.beeb_data       SKIP 1
.beeb_temp       SKIP 1

.beeb_mode2_offset  SKIP 1
.beeb_vispixels     SKIP 1
.beeb_sprpixels     SKIP 1
.beeb_bytes_per_line_on_screen SKIP 1
.beeb_bytes_per_line_in_sprite SKIP 1
.beeb_stack_depth SKIP 1
.beeb_stack_start SKIP 1
.beeb_partial_left  SKIP 1
