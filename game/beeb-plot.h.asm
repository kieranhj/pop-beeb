; beeb-plot
; BBC Micro plot functions
; Works directly on Apple II sprite data

.readptr    SKIP 2
.writeptr   SKIP 2

.numimages  SKIP 1
.width      SKIP 1
.height     SKIP 1

.yoffset    SKIP 1
.yindex     SKIP 1

.apple_count    SKIP 1          ; width
.apple_byte     SKIP 1          ; sprite data

.beeb_byte  SKIP 1              ; no lookup for screen byte
.beeb_count SKIP 1              ; beeb bits (8/4)

.bit_count  SKIP 1              ; apple bits (7)
.pal_index  SKIP 1              ; lookup for screen byte

.sprite_no  SKIP 1

PLOT_MODE = 1
