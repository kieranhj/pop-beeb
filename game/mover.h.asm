; mover.h.asm
; Local variables

CLEAR locals, locals_top
ORG locals
GUARD locals_top

\ dum locals
;.mover_state skip 1
;.mover_temp1 skip 2
;.mover_linkindex skip 1
;.mover_pptype skip 1
.mover_mobframe skip 1
.mover_underFF skip 1
