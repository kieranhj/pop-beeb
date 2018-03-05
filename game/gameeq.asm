; gameeq.asm
; Originally GAMEEQ.S
; Contains game definitions and memory addresses
; In memory tables and array space

\*-------------------------------
\*
\*  Page 2-3 - AUX MEM
\*
\*-------------------------------

\dum $320
;PAGE_ALIGN
PRINT "ALIGN LOST ", ~((P%+&7F) AND &FF80)-P%, " BYTES"
ALIGN &80  ; doesn't need to be page aligned but must be contained within same paage

.CDthisframe skip $10
.CDlastframe skip $10
.CDbelow skip $10
.CDabove skip $10
.SNthisframe skip $10
.SNlastframe skip $10
.SNbelow skip $10
.SNabove skip 10
.BlockYthis skip 1
.BlockYlast skip 1
