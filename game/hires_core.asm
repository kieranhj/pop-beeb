; hires_core.asm
; Function entry points for hires module in core ram

.hires_core

.cls jmp hires_cls
.lay jmp hires_lay
.fastlay jmp hires_fastlay
.layrsave jmp hires_layrsave

.lrcls BRK         ;jmp hires_lrcls    \ is implemented but not safe to call!
.fastmask jmp hires_fastmask
.fastblack jmp hires_fastblack
.peel jmp hires_peel
.getwidth jmp hires_getwidth

.copy2000 BRK      ;jmp copyscrnMM
.copy2000aux BRK   ;jmp copyscrnAA
.setfastaux BRK    ;jmp hires_SETFASTAUX
.setfastmain BRK   ;jmp hires_SETFASTMAIN
.copy2000ma BRK    ;jmp copyscrnMA

.copy2000am BRK    ;jmp copyscrnAM
.inverty BRK       ;jmp INVERTY

\*-------------------------------
\*
\* Assume hires routines are called from auxmem
\* (Exit with RAMRD, RAMWRT, ALTZP on)
\*
\*-------------------------------

.hires_cls
{
\ jsr mainmem
 BEEB_SELECT_MAIN_MEM
 jsr beeb_CLS
\ jsr hires_CLS
\ jmp auxmem
 BEEB_SELECT_AUX_MEM
 RTS
}

.hires_lay
{
\ jsr mainmem
 BEEB_SELECT_MAIN_MEM
 jsr beeb_plot_sprite_LAY
\ jsr hires_LAY
\ jmp auxmem
 BEEB_SELECT_AUX_MEM
 RTS
}

.hires_fastlay
{
\ jsr mainmem
 BEEB_SELECT_MAIN_MEM
 \ OFFSET not guaranteed to be set in Apple II (not used by hires_FASTLAY)
 LDA #0
 STA OFFSET
 jsr beeb_plot_sprite_FASTLAY
\ jsr hires_FASTLAY
\ jmp auxmem
 BEEB_SELECT_AUX_MEM
 RTS
}

.hires_layrsave
{
\ jsr mainmem
 BEEB_SELECT_MAIN_MEM
 jsr beeb_plot_layrsave
\ jsr hires_LAYRSAVE
\ jmp auxmem
 BEEB_SELECT_AUX_MEM
 RTS
}

.hires_lrcls
{
\ jsr mainmem
 BEEB_SELECT_MAIN_MEM
 BRK
\ jsr hires_LRCLS
\ jmp auxmem
 BEEB_SELECT_AUX_MEM
 RTS
}

.hires_fastmask
{
\ jsr mainmem
 BEEB_SELECT_MAIN_MEM
\ OFFSET not guaranteed to be set in Apple II (not used by hires_FASTLAY)
 LDA #0
 STA OFFSET
 jsr beeb_plot_sprite_FASTMASK
\ jsr hires_FASTMASK
\ jmp auxmem
 BEEB_SELECT_AUX_MEM
 RTS
}

.hires_fastblack
{
\ jsr mainmem
 BEEB_SELECT_MAIN_MEM
 jsr beeb_plot_wipe
\ jmp auxmem
 BEEB_SELECT_AUX_MEM
 RTS
}

.hires_peel
{
\ jsr mainmem
 BEEB_SELECT_MAIN_MEM
 jsr beeb_plot_peel
\ jsr hires_PEEL
\ jmp auxmem
 BEEB_SELECT_AUX_MEM
 RTS
}

.hires_getwidth
{
\ jsr mainmem
 BEEB_SELECT_MAIN_MEM

 jsr hires_GETWIDTH

\\ must preserve A&X
 STA regA+1

\\ must preserve callers SWRAM bank

\ jmp auxmem
 BEEB_SELECT_AUX_MEM
 
 .regA
 LDA #0
 RTS
}

IF _TODO
copyscrnMM
 jsr mainmem ;r/w main
]copyscrn jsr COPYSCRN
 jmp auxmem

copyscrnAA
 jsr auxmem ;r/w aux
 jmp ]copyscrn

copyscrnMA
 sta $c002 ;read main
 sta $c005 ;write aux
 jmp ]copyscrn

copyscrnAM
 sta $c003 ;read aux
 sta $c004 ;write main
 jmp ]copyscrn
ENDIF

\*-------------------------------

IF _NOT_BEEB
.mainmem
{
 BRK
\ NOT BEEB
\sta $c004 ;RAMWRT off
\sta $c002 ;RAMRD off
\rts
}

.auxmem
{
 BRK
\ NOT BEEB
\sta $c005 ;RAMWRT on
\sta $c003 ;RAMRD on
\rts
}
ENDIF
