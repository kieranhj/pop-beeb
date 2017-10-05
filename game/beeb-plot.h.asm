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

.beeb_stack_ptr         SKIP 1

.beeb_sprite_no  SKIP 1

.beeb_rem        SKIP 1
.beeb_data      SKIP 1
.beeb_temp      SKIP 1
