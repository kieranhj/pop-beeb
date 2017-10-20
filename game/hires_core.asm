; hires_core.asm
; Function entry points for hires module in core ram

.hires_core

._boot3 BRK         ;jmp boot3
._cls jmp hires_cls
._lay jmp hires_lay
._fastlay jmp hires_fastlay
._layrsave jmp hires_layrsave

._lrcls brk         ;jmp hires_lrcls    \ is implemented but not safe to call!
._fastmask jmp hires_fastmask
._fastblack jmp hires_fastblack
._peel jmp hires_peel
._getwidth jmp hires_getwidth

._copy2000 BRK      ;jmp copyscrnMM
._copy2000aux BRK   ;jmp copyscrnAA
._setfastaux BRK    ;jmp hires_SETFASTAUX
._setfastmain BRK   ;jmp hires_SETFASTMAIN
._copy2000ma BRK    ;jmp copyscrnMA

._copy2000am BRK    ;jmp copyscrnAM
._inverty BRK       ;jmp INVERTY

\*-------------------------------
\*
\* Assume hires routines are called from auxmem
\* (Exit with RAMRD, RAMWRT, ALTZP on)
\*
\*-------------------------------

.hires_cls
{
 jsr mainmem
 jsr beeb_CLS
\ jsr hires_CLS
 jmp auxmem
}

.hires_lay
{
 jsr mainmem
 jsr beeb_plot_sprite_LAY
\ jsr hires_LAY
 jmp auxmem
}

.hires_fastlay
{
 jsr mainmem
 \ OFFSET not guaranteed to be set in Apple II (not used by hires_FASTLAY)
 LDA #0
 STA OFFSET
 jsr beeb_plot_sprite_FASTLAY
\ jsr hires_FASTLAY
 jmp auxmem
}

.hires_layrsave
{
 jsr mainmem
 jsr beeb_plot_layrsave
\ jsr hires_LAYRSAVE
 jmp auxmem
}

.hires_lrcls
{
 jsr mainmem
 BRK
\ jsr hires_LRCLS
 jmp auxmem
}

.hires_fastmask
{
 jsr mainmem
\ OFFSET not guaranteed to be set in Apple II (not used by hires_FASTLAY)
 LDA #0
 STA OFFSET
 jsr beeb_plot_sprite_FASTMASK
\ jsr hires_FASTMASK
 jmp auxmem
}

.hires_fastblack
{
 jsr mainmem
 jsr beeb_plot_wipe
 jmp auxmem
}

.hires_peel
{
 jsr mainmem
 jsr beeb_plot_peel
\ jsr hires_PEEL
 jmp auxmem
}

.hires_getwidth
{
 jsr mainmem
 jsr hires_GETWIDTH
\\ must preserve A&X
 PHA:PHX
 JSR auxmem
 PLX:PLA
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

.mainmem
{
    JMP beeb_shadow_select_main
\ NOT BEEB
\sta $c004 ;RAMWRT off
\sta $c002 ;RAMRD off
\rts
}

.auxmem
{
    JMP beeb_shadow_select_aux
\ NOT BEEB
\sta $c005 ;RAMWRT on
\sta $c003 ;RAMRD on
\rts
}
