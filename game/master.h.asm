; master.h.asm
; Originally MASTER.S
; Local variables for master.asm

\*-------------------------------
\* Local vars

CLEAR locals, locals_top
ORG locals
GUARD locals_top

.master_dest skip 2
.master_source skip 2
.master_endsourc skip 2

.newBGset1 skip 1
.newBGset2 skip 1
.newCHset skip 1
