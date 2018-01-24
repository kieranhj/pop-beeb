; grafix.asm
; Originally GRAFIX.S
; All Apple II hi-res graphics functions

_DIV7_TABLES = TRUE                ; use tables (faster) or loop (smaller) to DIV & MOD by 7

.grafix
\org = $400
\ tr on
\ lst off
\ lstdo off
\*-------------------------------
\*
\*  PRINCE OF PERSIA
\*  Copyright 1989 Jordan Mechner
\*
\*-------------------------------
\ org org
\
IF _JMP_TABLE=FALSE
.gr BRK         ;jmp GR
.drawall jmp DRAWALL
;
\ jmp dispversion
\.saveblue BRK   ;jmp SAVEBLUE
\
\.reloadblue BRK ;jmp RELOADBLUE
.movemem BRK    ;jmp MOVEMEM
\.buttons jmp BUTTONS ;ed
.gtone RTS      ;jmp GTONE          BEEB TODO SOUND
;
\
.dimchar jmp DIMCHAR
.cvtx jmp CVTX
.zeropeel jmp ZEROPEEL
.zeropeels jmp ZEROPEELS
;
\
.addpeel jmp ADDPEEL
.copyscrn RTS   ;jmp COPYSCRN       BEEB TO DO OR NOT NEEDED?
.sngpeel jmp SNGPEEL
.rnd jmp RND
;
\ Removed unnecessary redirections
\ Removed Editor only fns
;
.addback jmp ADDBACK
.addfore jmp ADDFORE
.addmid jmp ADDMID
.addmidez jmp ADDMIDEZ
\
.addwipe jmp ADDWIPE
.addmsg jmp ADDMSG
;
;
.zerolsts jmp ZEROLSTS
\
;
.minit jmp MINIT
.mplay jmp MPLAY
\.savebinfo BRK  ;jmp SAVEBINFO
\.reloadbinfo BRK;jmp RELOADBINFO
\
;
\.normspeed RTS  ;jmp NORMSPEED                      NOT BEEB
.addmidezo jmp ADDMIDEZO
;
;
\
;
\.checkIIGS BRK  ;jmp CHECKIIGS                      NOT BEEB
\.fastspeed RTS  ;jmp FASTSPEED                      NOT BEEB
.musickeys jmp MUSICKEYS
;
\
;
;
;
.whoop BRK      ;jmp WHOOP
.vblank JMP beeb_wait_vsync    ;VBLvect jmp VBLANK ;changed by InitVBLANK if IIc
\
.vbli BRK       ;jmp VBLI ;VBL interrupt
ENDIF
\
\*-------------------------------
\ lst
\ put eq
\ lst
\ put gameeq
\ lst
\ put soundnames
\ lst off
\*-------------------------------
\ dum locals
\grafix_temp
\grafix_dest ds 2
\grafix_source ds 2
\grafix_endsourc ds 2
\index ds 1
\
\ dend

\*-------------------------------
\*  Apple soft switches

\ NOT BEEB
\IOUDISoff = $c07f
\IOUDISon = $c07e
\DHIRESoff = $c05f
\DHIRESon = $c05e
\HIRESon = $c057
\HIRESoff = $c056
\PAGE2on = $c055
\PAGE2off = $c054
\MIXEDon = $c053
\MIXEDoff = $c052
\TEXTon = $c051
\TEXToff = $c050
\ALTCHARon = $c00f
\ALTCHARoff = $c00e
\ADCOLon = $c00d
\ADCOLoff = $c00c
\ALTZPon = $c009
\ALTZPoff = $c008
\RAMWRTaux = $c005
\RAMWRTmain = $c004
\RAMRDaux = $c003
\RAMRDmain = $c002
\ADSTOREon = $c001
\ADSTOREoff = $c000
\RWBANK2 = $c083
\RWBANK1 = $c08b
\USEROM = $c082

\*-------------------------------
\*  Key equates
\ Should be in specialk.asm
CTRL = $60
ESC = $9b
DELETE = $7f
SHIFT = $20
\ BEEB use IKN defines in bbc.asm.h

ksound = IKN_s OR &80
kmusic = IKN_m OR &80

\*-------------------------------
\*  Joystick "center" width (increase for bigger center)

cwidthx = 10 ;15
cwidthy = 15 ;21

\*-------------------------------
\*  Addresses of character image tables
\*  (Bank: 2 = main, 3 = aux)

.chtabbank EQUB BEEB_SWRAM_SLOT_CHTAB13, BEEB_SWRAM_SLOT_CHTAB25, BEEB_SWRAM_SLOT_CHTAB13, BEEB_SWRAM_SLOT_CHTAB4, BEEB_SWRAM_SLOT_CHTAB25, BEEB_SWRAM_SLOT_CHTAB67, BEEB_SWRAM_SLOT_CHTAB67

.chtablist EQUB HI(chtable1),HI(chtable2),HI(chtable3),HI(chtable4)
 EQUB HI(chtable5),HI(chtable6),HI(chtable7)

IF _HALF_PLAYER
.chtabhack EQUB 1,1,1,0,1,0,0,0
ENDIF

.chtabpal EQUB &00, &00, &00, &02, &00, &02, &02

\ NOT BEEB
\.dummy EQUB maxpeel,maxpeel

\*-------------------------------
\*
\*  A D D B A C K
\*
\*  Add an image to BACKGROUND image list
\*
\*  In: XCO, YCO, IMAGE (coded), OPACITY
\*
\*  IMAGE bit 7 specifies image table (0 = bgtable1,
\*  1 = bgtable2); low 6 bits = image # within table
\*
\*-------------------------------
.ADDBACK
{
 ldx bgX ;# images already in list
 inx
IF _DEBUG
 CPX bgTOP
 BCC top_ok
 STX bgTOP
 .top_ok
 CPX #maxback
 BCC max_ok
 BRK
 .max_ok
ELSE
 cpx #maxback
 bcs return ;list full (shouldn't happen)
ENDIF

 lda XCO
 sta bgX,x

 lda YCO
 cmp #192
 bcs return
 sta bgY,X

 lda IMAGE
\ Bounds check image#
IF _DEBUG
 BNE image_ok
 BRK
 .image_ok
ENDIF
 sta bgIMG,X

 lda OPACITY
 sta bgOP,X

 stx bgX
.return rts
}

\*-------------------------------
\*
\*  A D D F O R E
\*
\*  Add an image to FOREGROUND image list
\*
\*  In: same as ADDBACK
\*
\*-------------------------------
.ADDFORE
{
 ldx fgX
 inx
IF _DEBUG
 CPX fgTOP
 BCC top_ok
 STX fgTOP
 .top_ok
 CPX #maxfore
 BCC max_ok
 BRK
 .max_ok
ELSE
 cpx #maxfore
 bcs return
ENDIF

 lda XCO
 sta fgX,X

 lda YCO
 cmp #192
 bcs return
 sta fgY,X

 lda IMAGE
 sta fgIMG,X

 lda OPACITY
 sta fgOP,X

 stx fgX
.return rts
}

\*-------------------------------
\*
\*  A D D M S G
\*
\*  Add an image to MESSAGE image list (uses bg tables)
\*
\*  In:  XCO, OFFSET, YCO, IMAGE (coded), OPACITY (bit 6 coded)
\*
\*-------------------------------

.ADDMSG
{
 ldx msgX
 inx
 cpx #maxmsg
 bcs return

 lda XCO
 sta msgX,X
 lda OFFSET
 sta msgOFF,X

 lda YCO
 sta msgY,X

 lda IMAGE
 sta msgIMG,X

 lda OPACITY
 sta msgOP,X

 stx msgX
.return
 rts
}

\*-------------------------------
\*
\*  A D D  W I P E
\*
\*  Add image to wipe list
\*
\*  In: XCO, YCO, height, width; A = color
\*
\*-------------------------------

.ADDWIPE
{
 ldx wipeX
 inx
IF _DEBUG
 CPX wipeTOP
 BCC top_ok
 STX wipeTOP
 CPX #maxwipe
 .top_ok
 BCC max_ok
 BRK
 .max_ok
ELSE
 cpx #maxwipe
 bcs return
ENDIF

 sta wipeCOL,x
 lda blackflag ;TEMP
 beq label_1 ;
 lda #$ff ;
 sta wipeCOL,x ;
.label_1
 lda XCO
 sta wipeX,x
 lda YCO
 sta wipeY,x

 lda height
 sta wipeH,x
 lda width
 sta wipeW,x

 stx wipeX
.return
 rts
}

\*-------------------------------
\*
\*  A D D   M I D
\*
\*  Add an image to mid table
\*
\*  In:  XCO, OFFSET, YCO, IMAGE, TABLE, OPACITY
\*       FCharFace, FCharCU-CD-CL-CR
\*       A = midTYP
\*
\*  midTYP bit 7: 1 = char tables, 0 = bg tables
\*  midTYP bits 0-6:
\*    0 = use fastlay (normal for floorpieces)
\*    1 = use lay alone
\*    2 = use lay with layrsave (normal for characters)
\*
\*  For char tables: IMAGE = image #, TABLE = table #
\*  For bg tables: IMAGE bits 0-6 = image #, bit 7 = table #
\*
\*-------------------------------

.ADDMID
{
 ldx midX
 inx
IF _DEBUG
 CPX midTOP
 BCC top_ok
 STX midTOP
 .top_ok
 CPX #maxmid
 BCC max_ok
 BRK
 .max_ok
ELSE
 cpx #maxmid
 bcs return
ENDIF

 sta midTYP,x

 lda XCO
 sta midX,x
 lda OFFSET
 sta midOFF,x

 lda YCO
 sta midY,x

 lda IMAGE
 sta midIMG,x

 lda TABLE
 sta midTAB,x

 lda FCharFace ;- left, + right
 eor #$ff ;+ normal, - mirror
 and #$80
 ora OPACITY
 sta midOP,x

 lda FCharCU
 sta midCU,x
 lda FCharCD
 sta midCD,x
 lda FCharCL
 sta midCL,x
 lda FCharCR
 sta midCR,x

 stx midX
.return
 rts
}

\*-------------------------------
\*
\*  ADDMID "E-Z" version
\*
\*  No offset, no mirroring, no cropping
\*
\*  In: XCO, YCO, IMAGE, TABLE, OPACITY
\*      A = midTYP
\*
\*-------------------------------
.ADDMIDEZ
; lda #0        ; bug that this zeroes A?
 stz OFFSET
.ADDMIDEZO
{
 ldx midX
 inx
IF _DEBUG
 CPX midTOP
 BCC top_ok
 STX midTOP
 .top_ok
 CPX #maxmid
 BCC max_ok
 BRK
 .max_ok
ELSE
 cpx #maxmid
 bcs return
ENDIF

 sta midTYP,x

 lda XCO
 sta midX,x
 lda OFFSET
 sta midOFF,x

 lda YCO
 sta midY,x

 lda IMAGE
 sta midIMG,x

 lda TABLE
 sta midTAB,x

 lda OPACITY
 sta midOP,x

 lda #0
 sta midCU,x
 sta midCL,x
 lda #40
 sta midCR,x
 lda #192
 sta midCD,x

 stx midX
.return rts
}

\*-------------------------------
\*
\*  A D D P E E L
\*
\*  (Call immediately after layrsave)
\*  Add newly generated image to peel list
\*
\*-------------------------------
.ADDPEEL
{
 lda PEELIMG+1
 beq return ;0 is layersave's signal to skip it

 lda PAGE
 beq label_1

\IF CopyProtect
\ ldx purpleflag ;should be 1!
\ lda dummy,x
\ELSE
 lda #maxpeel

.label_1 sta sm+1 ;self-mod

 tax
 lda peelX,x ;# of images in peel list
 clc
 adc #1
IF _DEBUG
 CMP peelTOP
 BCC top_ok
 STA peelTOP
 .top_ok
 cmp #maxpeel
 BCC max_ok
 BRK
 .max_ok
ELSE
 cmp #maxpeel
 bcs return
ENDIF
 sta peelX,x
 clc
.sm adc #0 ;0/maxpeel
 tax

 lda PEELXCO
 sta peelX,x
 lda PEELYCO
 sta peelY,x ;x & y coords of saved image

 lda PEELIMG
 sta peelIMGL,x
 lda PEELIMG+1
 sta peelIMGH,x ;2-byte image address (in peel buffer)

.return rts
}

\*-------------------------------
\*
\*  D R A W A L L
\*
\*  Draw everything in image lists
\*
\*  This is the only routine that calls HIRES routines.
\*
\*-------------------------------
.DRAWALL
{
 jsr DOGEN ;Do general stuff like cls

 lda blackflag ;TEMP
 bne label_1 ;

RASTER_COL PAL_blue

 jsr SNGPEEL ;"Peel off" characters
;(using the peel list we
;set up 2 frames ago)

RASTER_COL PAL_black

.label_1 jsr ZEROPEEL ;Zero just-used peel list

 jsr DRAWWIPE ;Draw wipes

 jsr DRAWBACK ;Draw background plane images

 jsr DRAWMID ;Draw middle plane images
;(& save underlayers to now-clear peel list)

 jsr DRAWFORE ;Draw foreground plane images

 jmp DRAWMSG ;Draw messages
}

\*-------------------------------
\*
\*  D O  G E N
\*
\*  Do general stuff like clear screen
\*
\*-------------------------------
.DOGEN
{
 lda genCLS
 beq return
 jsr cls

\* purple copy-protection
\ NOT BEEB
\.label_1 ldx BGset1
\ cpx #1
\ bne return
\ lda #0
\ sta dummy-1,x

.return rts
}

\*-------------------------------
\*
\*  D R A W W I P E
\*
\*  Draw wipe list (using "fastblack")
\*
\*-------------------------------
.DRAWWIPE
{
 lda wipeX ;# of images in list
 beq return ;list is empty

 lda #1 ;start with image #1
.loop pha
 tax

 lda wipeH,x
 sta IMAGE ;height
 lda wipeW,x
 sta IMAGE+1 ;width
 lda wipeX,X
 sta XCO ;x-coord
 lda wipeY,X
 sta YCO ;y-coord
 lda wipeCOL,X
 sta OPACITY ;color
 jsr fastblack

 pla
 clc
 adc #1
 cmp wipeX
 bcc loop
 beq loop
.return rts
}

\*-------------------------------
\*
\*  D R A W B A C K
\*
\*  Draw b.g. list (using fastlay)
\*
\*-------------------------------
.DRAWBACK
{
 lda bgX ;# of images in list
 beq return

 ldx #1
.loop stx index

 lda bgIMG,x
 sta IMAGE ;coded image #
 jsr setbgimg ;extract TABLE, BANK, IMAGE

 lda bgX,x
 sta XCO
 lda bgY,X
 sta YCO
 lda bgOP,x
 sta OPACITY
 jsr fastlay

 ldx index
 inx
 cpx bgX
 bcc loop
 beq loop
.return rts
}

\*-------------------------------
\*
\*  D R A W F O R E
\*
\*  Draw foreground list (using fastmask/fastlay)
\*
\*-------------------------------
.DRAWFORE
{
 lda fgX
 beq return

 ldx #1
.loop stx index

 lda fgIMG,x
 sta IMAGE
 jsr setbgimg

 lda fgX,x
 sta XCO
 lda fgY,x
 sta YCO

 lda fgOP,x ;opacity
 \ BEEB TEMP moved this here so enum_mask OPACITY gets passed through
 sta OPACITY ;fastlay for everything else
 cmp #enum_mask
 bne label_1
 jsr fastmask
 jmp cont

.label_1 
 jsr fastlay

.cont ldx index
 inx
 cpx fgX
 bcc loop
 beq loop
.return rts
}

\*-------------------------------
\*
\*  S N G   P E E L
\*
\*  Draw peel list (in reverse order) using "peel" (fastlay)
\*
\*-------------------------------
.SNGPEEL
{
 ldx PAGE
 beq label_1
 ldx #maxpeel
.label_1 stx sm+1
 lda peelX,x ;# of images in list
 beq return

.loop pha
 clc
.sm adc #0 ;self-mod: 0 or maxpeel
 tax

 lda peelIMGL,x
 sta IMAGE
 lda peelIMGH,x
 sta IMAGE+1
 lda peelX,x
 sta XCO
 lda peelY,x
 sta YCO
 lda #enum_sta
 sta OPACITY
 jsr peel

 pla
 sec
 sbc #1
 bne loop
.return rts
}

\*-------------------------------
\*
\*  D R A W M I D
\*
\*  Draw middle list (floorpieces & characters)
\*
\*-------------------------------
.DRAWMID
{
 lda midX ;# of images in list
 beq return

 ldx #1
.loop stx index

 lda midIMG,x
 sta IMAGE
 lda midTAB,x
 sta TABLE
 lda midX,x
 sta XCO
 lda midY,x
 sta YCO
 lda midOP,x
 sta OPACITY

 lda midTYP,x ;+ use bg tables
 bmi UseChar ;- use char tables
 jsr setbgimg ;protects A,X
 jmp GotTable

.UseChar jsr setcharimg ;protects A,X

.GotTable ;A = midTYP,x
 and #$7f ;low 7 bits: 0 = fastlay, 1 = lay, 2 = layrsave
 beq local_fastlay
 cmp #1
 beq local_lay
 cmp #2
 beq local_layrsave

.Done ldx index
 inx
 cpx midX
 bcc loop
 beq loop
.return rts

\* midTYP values:
\*    0 = use fastlay (normal for floorpieces)
\*    1 = use lay alone
\*    2 = use lay with layrsave (normal for characters)

.local_fastlay
 jsr fastlay
 jmp Done

.local_layrsave
RASTER_COL PAL_red

 jsr setaddl ;set additional params for lay

 jsr layrsave ;save underlayer in peel buffer
 jsr ADDPEEL ;& add to peel list

RASTER_COL PAL_magenta
 jsr lay ;then lay down image
RASTER_COL PAL_black

 jmp Done

.local_lay jsr setaddl
 jsr lay
 jmp Done

.setaddl lda midOFF,x
 sta OFFSET
 lda midCL,x
 sta LEFTCUT
 lda midCR,x
 sta RIGHTCUT
 lda midCU,x
 sta TOPCUT
 lda midCD,x
 sta BOTCUT
 rts
}

\*-------------------------------
\*
\*  D R A W M S G
\*
\*  Draw message list (using bg tables & lay)
\*
\*  OPACITY bit 6: 1 = layrsave, 0 = no layrsave
\*
\*-------------------------------
.DRAWMSG
{
 lda msgX
 beq return

 ldx #1
.loop stx index

 lda msgIMG,x
 sta IMAGE
 jsr setbgimg

 lda msgX,x
 sta XCO
 lda msgOFF,x
 sta OFFSET
 lda msgY,x
 sta YCO

 lda #0
 sta LEFTCUT
 sta TOPCUT
 lda #40
 sta RIGHTCUT
 lda #192
 sta BOTCUT

 lda msgOP,x
 sta OPACITY
 and #%01000000
 beq label_1
 lda OPACITY
 and #%10111111 ;bit 6 set: use layrsave
 sta OPACITY

 jsr layrsave
 jsr ADDPEEL

.label_1 jsr lay

 ldx index
 inx
 cpx msgX
 bcc loop
 beq loop
.return rts
}

\*-------------------------------
\*
\*  S E T   B  G   I M A G E
\*
\*  In: IMAGE = coded image #
\*  Out: BANK, TABLE, IMAGE set for hires call + PALETTE (BEEB)
\*
\*  Protect A,X
\*
\*-------------------------------
.setbgimg
{
 tay

\lda #3 ;auxmem
\sta BANK

 lda #0
 sta TABLE
IF _HALF_PLAYER
 STA BEEBHACK
ENDIF


 lda IMAGE ;Bit 7: 0 = bgtable1, 1 = bgtable2
IF _DEBUG
 BNE image_ok1
 BRK
 .image_ok1
ENDIF
 bpl bg1

 and #$7f
IF _DEBUG
 BNE image_ok2
 BRK
 .image_ok2
ENDIF
 sta IMAGE

\ BGTAB2

 PHX:TAX
 LDA bgimg2pal-1, X
 EOR beeb_palette_toggle
 STA PALETTE:PLX

 LDA #BEEB_SWRAM_SLOT_BGTAB2
 STA BANK

 lda #HI(bgtable2)
 bne ok

.bg1

 LDA IMAGE

 PHX:TAX
 LDA bgimg1pal-1, X
 EOR beeb_palette_toggle
 STA PALETTE
 TXA:PLX

\ BGTAB1

 CMP #88
 BCS not_A

\ BGTAB A

 LDA #BEEB_SWRAM_SLOT_BGTAB1_A
 STA BANK

 lda #HI(bgtable1a)
 BNE ok

 .not_A

\ BGTAB B

 SEC
 SBC #87
 STA IMAGE

 LDA #BEEB_SWRAM_SLOT_BGTAB1_B
 STA BANK

 lda #HI(bgtable1b)

.ok sta TABLE+1

 tya
 rts
}

\*-------------------------------
\*
\*  S E T   C H A R   I M A G E
\*
\*  In: TABLE = chtable # (0-7)
\*  Out: BANK, TABLE set for hires call
\*
\*  Protect A,X
\*
\*-------------------------------
.setcharimg
{
 pha

 ldy TABLE
 lda chtabbank,y
 sta BANK

\\ BEEB HACK
IF _HALF_PLAYER
 lda chtabhack,y
 sta BEEBHACK
ENDIF

 lda #0
 sta TABLE
 lda chtablist,y
 sta TABLE+1

 LDA chtabpal, Y
 STA PALETTE

 pla
 rts
}

\*-------------------------------
\*
\*  D I M C H A R
\*
\*  Get dimensions of character
\*  (Misc. routine for use by CTRL)
\*
\*  In: A = image #, X = table #
\*  Out: A = width, X = height
\*
\*-------------------------------

.DIMCHAR
{
 sta IMAGE
 stx TABLE
 jsr setcharimg
 jmp getwidth
}

\*-------------------------------
\*
\*  C V T X
\*
\*  Convert X-coord to byte & offset
\*  Works for both single & double hires
\*
\*  In: XCO/OFFSET = X-coord (2 bytes)
\*  Out: XCO/OFFSET = byte/offset
\*
\*  Hires scrn: X-coord range 0-279, byte range 0-39
\*  Dbl hires scrn: X-coord range 0-559, byte range 0-79
\*
\*  Trashes Y-register
\*
\*  Returns accurate results for all input (-32767 to 32767)
\*  but wildly offscreen values will slow it down
\*
\*-------------------------------
XL = XCO
XH = OFFSET

range = 36*7 ;largest multiple of 7 under 256

.CVTX
{
 lda #0
 sta grafix_temp

 lda XH
 bmi negative ;X < 0
 beq ok ;0 <= X <= 255

.loop lda grafix_temp
 clc
 adc #36
 sta grafix_temp

 lda XL
 sec
 sbc #range
 sta XL

 lda XH
 sbc #0
 sta XH

 bne loop

.ok
IF _DIV7_TABLES

 ldy XL
 lda ByteTable,y
 clc
 adc grafix_temp
 sta XCO

 lda OffsetTable,y
 sta OFFSET

ELSE

 LDA XL
 LDY #0
.loop2              ; worst case loop 36 times = 2c+2c+2c+2c+3c=11c*36=396c :(
 CMP #7
 BCC done_loop2
 INY
 \ Carry set
 SBC #7
 BRA loop2
.done_loop2
 STA OFFSET

 TYA
 adc grafix_temp
 sta XCO

ENDIF

 RTS

.negative
 lda grafix_temp
 sec
 sbc #36
 sta grafix_temp

 lda XL
 clc
 adc #range
 sta XL

 lda XH
 adc #0
 sta XH
 bne negative
 beq ok
.return rts
}

\*-------------------------------
\*
\*  Z E R O L I S T S
\*
\*  Zero image lists (except peel lists)
\*
\*-------------------------------
.ZEROLSTS
{
 lda #0
 sta genCLS
 sta wipeX
 sta bgX
 sta midX
 sta objX
 sta fgX
 sta msgX
 rts
}

\*-------------------------------
\*
\*  Zero both peel lists
\*
\*-------------------------------
.ZEROPEELS
{
 lda #0
 sta peelX
 sta peelX+maxpeel
.return rts
}

\*-------------------------------
\*
\*  Z E R O P E E L
\*
\*  Zero peel list & buffer for whichever page we're on
\*
\*  (Point PEELBUF to beginning of appropriate peel buffer
\*  & set #-of-images byte to zero)
\*
\*-------------------------------
.ZEROPEEL
{
 lda #0
 ldx PAGE
 beq page1
.page2 sta peelX+maxpeel
 lda #LO(peelbuf2)
 sta PEELBUF
 lda #HI(peelbuf2)
 sta PEELBUF+1
 rts

.page1 sta peelX
 lda #LO(peelbuf1)
 sta PEELBUF
 lda #HI(peelbuf1)
 sta PEELBUF+1
 rts
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
*  G  T  O  N  E
*
*  Call this routine to confirm special-key presses
*  & any other time we want to bypass normal sound interface
*
*-------------------------------
SK1Pitch = 15
SK1Dur = 50

GTONE ldy #SK1Pitch
 ldx #>SK1Pitch
 lda #SK1Dur
 jmp tone

*-------------------------------
*
*  Whoop speaker (like RW18)
*
*-------------------------------
WHOOP
 ldy #0
:1 tya
 bit $c030
:2 sec
 sbc #1
 bne :2
 dey
 bne :1
return rts

*-------------------------------
*
*  Produce tone
*
*  In: y-x = pitch lo-hi
*      a = duration
*
*-------------------------------
tone
 sty :pitch
 stx :pitch+1
:outloop bit $c030
 ldx #0
:midloop ldy #0
:inloop iny
 cpy :pitch
 bcc :inloop
 inx
 cpx :pitch+1
 bcc :midloop
 sec
 sbc #1
 bne :outloop
 rts

:pitch ds 2

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

IF _NOT_BEEB
*-------------------------------
*
*  Calls to hires & master routines
*
*  Hires & master routines are in main lc & use main zp;
*  rest of code uses aux lc, zp.
*
*-------------------------------
*
*  Master
*
*-------------------------------
\\ BEEB Removed unnecessary redirection
ENDIF

\*-------------------------------
\*
\* Edmaster (editor disk only)
\*
\*-------------------------------
IF EditorDisk

SAVELEVEL sta ALTZPoff
 jsr _savelevel
 sta ALTZPon
 rts

SAVELEVELG sta ALTZPoff
 jsr _savelevelg
 sta ALTZPon
 rts

READDIR sta ALTZPoff
 jsr _readdir
 sta ALTZPon
 rts

WRITEDIR sta ALTZPoff
 jsr _writedir
 sta ALTZPon
 rts

GOBUILD sta ALTZPoff
 jsr _gobuild
 sta ALTZPon
 rts

GOGAME sta ALTZPoff
 jsr _gogame
 sta ALTZPon
 rts

EDREBOOT sta ALTZPoff
 jsr _edreboot
 sta ALTZPon
 rts

ELSE
.SAVELEVEL
.SAVELEVELG
.READDIR
.WRITEDIR
.GOBUILD
.GOGAME
.EDREBOOT rts
ENDIF

\*-------------------------------
\*
\*  Hires
\*
\*-------------------------------
\\ BEEB Removed redirections

\*-------------------------------
\*
\*  Call sound routines (in aux l.c. bank 1)
\*  Exit with bank 2 switched in
\*
\*-------------------------------
\grafix_bank1in bit RWBANK1
\ bit RWBANK1
\ rts

.mplay_temp
EQUB 0

.MINIT
{
\ jsr grafix_bank1in
\ jsr CALLMINIT
 LDA #&FF
 STA mplay_temp
 RTS
}

\grafix_bank2in bit RWBANK2
\ bit RWBANK2
\ rts

.MPLAY
{
\ jsr grafix_bank1in
\ jsr CALLMPLAY
\ jmp grafix_bank2in

 LDA mplay_temp
 DEC A
 STA mplay_temp
 RTS
}

IF _NOT_BEEB
\*-------------------------------
\*
\* Copy hires params from aux to main z.p.
\*
\* (Enter & exit w/ ALTZP on)
\*
\*-------------------------------
.prehr
{
 BRK
\ NOT BEEB
\ ldx #$17
\.loop sta ALTZPon ;aux zp
\ lda $00,x
\ sta ALTZPoff ;main zp
\ sta $00,x
\ dex
\ bpl loop
\ sta ALTZPon
\ rts
}

\*-------------------------------
\*
\* Copy hires params from main to aux z.p.
\*
\* (Enter & exit w/ ALTZP on)
\*
\*-------------------------------
.posthr
{
 BRK
\ NOT BEEB
\ ldx #$17
\.loop sta ALTZPoff
\ lda $00,x
\ sta ALTZPon
\ sta $00,x
\ dex
\ bpl loop
\.return rts
}
ENDIF

IF EditorDisk
*-------------------------------
*
*  Save master copy of blueprint in l.c. bank 1
*
*-------------------------------
SAVEBLUE
 jsr grafix_bank1in
 lda #>$d700
 ldx #>$b700
 ldy #>$b700+$900
 jsr movemem
 jmp grafix_bank2in

SAVEBINFO
 jsr grafix_bank1in
 lda #>$d000
 ldx #>$a600
 ldy #>$a600+$600
 jsr movemem
 jmp grafix_bank2in

*-------------------------------
*
* Reload master copy of blueprint from l.c. bank 1
*
*-------------------------------
RELOADBLUE
 jsr grafix_bank1in
 lda #>$b700
 ldx #>$d700
 ldy #>$d700+$900
 jsr movemem
 jmp grafix_bank2in

RELOADBINFO
 jsr grafix_bank1in
 lda #>$a600
 ldx #>$d000
 ldy #>$d000+$600
 jsr movemem
 jmp grafix_bank2in
ENDIF

IF _TODO
*-------------------------------
*
*  Display lo-res page 1
*
*-------------------------------
GR jmp gtone ;temp!
ENDIF


IF _TODO
*-------------------------------
*
*  Routines to interface with MSYS (Music System II)
*
*-------------------------------
*
* Switch zero page
*
*-------------------------------
switchzp
 ldx #31
:loop ldy savezp,x
 lda $00,x
 sta savezp,x
 tya
 sta $00,x
 dex
 bpl :loop
 rts

*-------------------------------
*
*  Call MINIT
*
*  In: A = song #
*
*-------------------------------
CALLMINIT
 pha
 jsr switchzp
 pla
 jsr _minit
 jmp switchzp

*-------------------------------
*
*  Call MPLAY
*
*  Out: A = song #
*  (Most songs set song # = 0 when finished)
*
*-------------------------------
CALLMPLAY
 lda soundon
 and musicon
 beq :silent

 jsr switchzp
 jsr _mplay ;returns INDEX
 pha
 jsr switchzp
 pla
 rts

:silent lda #0
return rts
ENDIF

\*-------------------------------
\*
\*  M U S I C   K E Y S
\*
\*  Call while music is playing
\*
\*  Esc to pause, Ctrl-S to turn sound off
\*  Return A = ASCII value (FF for button)
\*  Clear hibit if it's a key we've handled
\*
\*-------------------------------

.MUSICKEYS
{
\ Check CTRL first
 LDA #&79
 LDX #IKN_ctrl EOR &80
 JSR osbyte

 TXA
 AND #&80
 STA beeb_ctrl_key

\ lda $c000
\ sta keypress
\ bpl nokey
\ sta $c010

\ Check keys above CTRL
 LDA #&79
 LDX #&2
 JSR osbyte

 CPX #&FF
 BEQ nokey

 TXA
 ORA #&80
 STA keypress

 CMP #IKN_esc OR &80
 bne cont

.froze
\ lda $c000
\ sta keypress
\ bpl froze
\ sta $c010

 LDA #&79
 LDX #IKN_esc EOR &80
 JSR osbyte

 TXA
 BPL froze

 and #$7f
 rts

.cont
 cmp #ksound
 bne label_3
 lda soundon
 eor #1
 sta soundon

.label_21
 beq label_2
 jsr gtone

.label_2
 lda #0
 rts

.label_3
 cmp #kmusic
 bne label_1
 lda musicon
 eor #1
 sta musicon
 jmp label_21

.label_1
.nobtn
 lda keypress
 rts

\ Check Apple / joystick button
\ lda $c061
\ ora $c062
\ bpl :nobtn
\ lda #$ff

.nokey
 LDA #0
 STA keypress

.return
 rts
}

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

\*-------------------------------
\ lst
\eof ds 1
\ usr $a9,4,$0000,*-org
\ lst off
ENDIF
