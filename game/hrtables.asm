; hrtables.asm
; Originally HRTABLES.S
; Hires Tables

.hrtables
\org = $e000
\ tr on
\ lst off
\*-------------------------------
\ org org
\*-------------------------------
\*
\* YLO/YHI
\*
\* Index: Screen Y-coord (0-191, 0 = top)
\* Returns base address on hires page 1 (add $2000 for page 2)
\*
\*-------------------------------

\\ Needs to be changed for Beeb screen addressing!

\\ Apple II hi-res
\\ For Scanline y address = 
\\ &2000 + (((Y% MOD 64) DIV 8) * &80) + ((Y% MOD 8) * &400) + ((Y% DIV 64) * &28)

; Would ideally be PAGE_ALIGN
.YLO
FOR y,0,199,1
\\ address=&2000 + (((Y% MOD 64) DIV 8) * &80) + ((Y% MOD 8) * &400) + ((Y% DIV 64) * &28)
address = beeb_screen_addr + ((y DIV 8) * BEEB_SCREEN_ROW_BYTES) + (y MOD 8)
EQUB LO(address)
NEXT

; Would ideally be PAGE_ALIGN
.YHI
FOR y,0,199,1
\\ address=&2000 + (((Y% MOD 64) DIV 8) * &80) + ((Y% MOD 8) * &400) + ((Y% DIV 64) * &28)
address = beeb_screen_addr + ((y DIV 8) * BEEB_SCREEN_ROW_BYTES) + (y MOD 8)
EQUB HI(address)
NEXT
