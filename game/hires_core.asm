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
.inverty jmp INVERTY

\ Moved from grafix.asm
.rnd jmp RND
.movemem BRK        ;jmp MOVEMEM
.copyscrn BRK       ;jmp COPYSCRN
.vblank jmp beeb_wait_vsync    ;VBLvect jmp VBLANK ;changed by InitVBLANK if IIc
.vbli BRK           ;jmp VBLI ;VBL interrupt

\ Moved from subs.asm
.PageFlip jmp PAGEFLIP

\.normspeed RTS  ;jmp NORMSPEED         ; NOT BEEB
\.checkIIGS BRK  ;jmp CHECKIIGS         ; NOT BEEB
\.fastspeed RTS  ;jmp FASTSPEED         ; NOT BEEB


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

\\ Moved from grafix.asm

\*-------------------------------
\*
\*  Generate random number
\*
\*  RNDseed := (5 * RNDseed + 23) mod 256
\*
\*-------------------------------
.RND
{
 lda RNDseed
 asl A
 asl A
 clc
 adc RNDseed
 clc
 adc #23
 sta RNDseed
.return rts
}

IF _TODO
*-------------------------------
*
*  Move a block of memory
*
*  In: A < X.Y
*
*  20 < 40.60 means 2000 < 4000.5fffm
\*  WARNING: If x >= y, routine will wipe out 64k
*
*-------------------------------
MOVEMEM sta grafix_dest+1
 stx grafix_source+1
 sty grafix_endsourc+1

 ldy #0
 sty grafix_dest
 sty grafix_source
 sty grafix_endsourc

:loop lda (grafix_source),y
 sta (grafix_dest),y
 iny
 bne :loop

 inc grafix_source+1
 inc grafix_dest+1
 lda grafix_source+1
 cmp grafix_endsourc+1
 bne :loop
 rts

*-------------------------------
*
* Copy one hires page to the other
*
* In: PAGE = dest scrn (00/20)
*
*-------------------------------
COPYSCRN
 lda PAGE
 clc
 adc #$20
 sta IMAGE+1 ;dest addr
 eor #$60
 sta IMAGE ;org addr

 jmp copy2000
ENDIF

IF _NOT_BEEB
*===============================
vblflag ds 1
*-------------------------------
*
* Wait for vertical blank (IIe/IIGS)
*
*-------------------------------
VBLANK
:loop1 lda $c019
 bpl :loop1
:loop lda $c019
 bmi :loop ;wait for beginning of VBL interval
return rts

*-------------------------------
*
* Wait for vertical blank (IIc)
*
*-------------------------------
VBLANKIIc
 cli ;enable interrupts

:loop1 bit vblflag
 bpl :loop1 ;wait for vblflag = 1
 lsr vblflag ;...& set vblflag = 0

:loop2 bit vblflag
 bpl :loop2
 lsr vblflag

 sei
 rts

* Interrupt jumps to ($FFFE) which points back to VBLI

VBLI
 bit $c019
 sta $c079 ;enable IOU access
 sta $c05b ;enable VBL int
 sta $c078 ;disable IOU access
 sec
 ror vblflag ;set hibit
:notvbl rti

*-------------------------------
*
* Initialize VBLANK vector with correct routine
* depending on whether or not machine is IIc
*
*-------------------------------
InitVBLANK
 lda $FBC0
 bne return ;not a IIc--use VBLANK

 sta RAMWRTaux

 lda #VBLANKIIc
 sta VBLvect+1
 lda #>VBLANKIIc
 sta VBLvect+2

 sei ;disable interrupts
 sta $c079 ;enable IOU access
 sta $c05b ;enable VBL int
 sta $c078 ;disable IOU access

return rts

\*-------------------------------
\*
\*  Is this a IIGS?
\*
\*  Out: IIGS (0 = no, 1 = yes)
\*       If yes, set control panel to default settings
\*       Exit w/RAM bank 2 switched in
\*
\*  Also initializes VBLANK routine
\*
\*-------------------------------
CHECKIIGS
 bit USEROM
 bit USEROM

 lda $FBB3
 cmp #6
 bne * ;II/II+/III--we shouldn't even be here
 sec
 jsr $FE1F
 bcs :notGS

 lda #1
 bne :set

:notGS lda #0
:set sta IIGS

 jsr InitVBLANK

 bit RWBANK2
 bit RWBANK2
return rts

*-------------------------------
*
*  Temporarily set fast speed (IIGS)
*
*-------------------------------
 xc
FASTSPEED
 lda IIGS
 beq return

 lda #$80
 tsb $C036 ;fast speed
return rts

*-------------------------------
*
* Restore speed to normal (& bg & border to black)
*
*-------------------------------
NORMSPEED
 lda IIGS
 beq return

 xc
 lda $c034
 and #$f0
 sta $c034 ;black border

 lda #$f0
 sta $c022 ;black bg, white text

 lda #$80
 trb $c036 ;normal speed
 xc off

 rts

*-------------------------------
*
*  Read control panel parameter (IIGS)
*
*  In: Y = location
*  Out: A = current setting
*
*-------------------------------
 xc
 xc
getparam
 lda IIGS
 beq return

 clc
 xce
 rep $30
 pha
 phy
 ldx #$0C03
 hex 22,00,00,E1 ;jsl E10000
 pla
 sec
 xce
 tay
 rts

*-------------------------------
*
* Set control panel parameter (IIGS only)
*
* In: A = desired value, Y = location
*
*-------------------------------
setparam
 clc
 xce
 rep $30
 and #$ff
 pha
 phy
 ldx #$B03
 hex 22,00,00,E1 ;jsl E10000
 sec
 xce
 rts

 xc off
ENDIF

\*-------------------------------
\*
\*  P A G E F L I P
\*
\*-------------------------------

.PAGEFLIP
{
\ jsr normspeed ;IIGS
\ lda PAGE
\ bne :1
\
\ lda #$20
\ sta PAGE
\ lda $C054 ;show page 1
\
\:3 lda $C057 ;hires on
\ lda $C050 ;text off
\ lda vibes
\ beq :rts
\ lda $c05e
\]rts rts
\:rts lda $c05f
\ rts
\
\:1 lda #0
\ sta PAGE
\ lda $C055 ;show page 2
\ jmp :3

    LDA PAGE
    EOR #&20
    STA PAGE

    JMP shadow_swap_buffers
}
