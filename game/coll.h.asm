; coll.h.asm
; Local variables

CLEAR locals, locals_top
ORG locals
GUARD locals_top

\ dum locals
skip 8
.coll_ztemp skip 1
.coll_CollFace skip 1
.coll_tempobjid skip 1
.coll_tempstate skip 1
