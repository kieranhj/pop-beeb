; hrparams.asm
; Originally HRPARAMS.S
; Data tables for hires

hrparams=*

\ tr on
\* hrparams

\hrtables = $e000
\hrparams = $00
\*-------------------------------
\ hrtables defined in hrtables.asm

IF _TODO
*-------------------------------
 dum hrparams

PAGE ds 1
XCO ds 1
YCO ds 1
OFFSET ds 1
IMAGE ds 2
OPACITY ds 1
TABLE ds 2

PEELBUF ds 2
PEELIMG ds 2
PEELXCO ds 1
PEELYCO ds 1

TOPCUT ds 1
LEFTCUT ds 1
RIGHTCUT ds 1
BANK ds 1
BOTCUT ds 1

 dend
ENDIF

\ Already defined in eq.h.asm
\height = IMAGE
\width = IMAGE+1
color = OPACITY

\ lst off
