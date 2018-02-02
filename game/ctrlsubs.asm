; ctrlsubs.asm
; Originally CTRLSUBS.S
; Misc. subroutines relating to character control & movement

.ctrlsubs
\org = $d000
\ tr on
\ lst off
\*-------------------------------
\*
\*  PRINCE OF PERSIA
\*  Copyright 1989 Jordan Mechner
\*
\*-------------------------------
\*
\*   Misc. subroutines relating to character control & movement
\*
\*-------------------------------
\ org org

IF _JMP_TABLE=FALSE
.getframe jmp GETFRAME
.getseq jmp GETSEQ
.getbasex jmp GETBASEX
.getblockx jmp GETBLOCKX
.getblockxp jmp GETBLOCKXP

.getblocky jmp GETBLOCKY
.getblockej jmp GETBLOCKEJ
.addcharx jmp ADDCHARX
.getdist jmp GETDIST
.getdist1 jmp GETDIST1

.getabovebeh jmp GETABOVEBEH
.rdblock jmp RDBLOCK
.rdblock1 jmp RDBLOCK1
.setupsword jmp SETUPSWORD
.getscrns jmp GETSCRNS

.addguardobj jmp ADDGUARDOBJ
.opjumpseq jmp OPJUMPSEQ
.getedges jmp GETEDGES
.indexchar jmp INDEXCHAR
.quickfg jmp QUICKFG

.cropchar jmp CROPCHAR
.getleft jmp GETLEFT
.getright jmp GETRIGHT
.getup jmp GETUP
.getdown jmp GETDOWN

.cmpspace jmp CMPSPACE
.cmpbarr jmp CMPBARR
.addkidobj jmp ADDKIDOBJ
.addshadobj jmp ADDSHADOBJ
.addreflobj jmp ADDREFLOBJ

.LoadKid jmp LOADKID
.LoadShad jmp LOADSHAD
.SaveKid jmp SAVEKID
.SaveShad jmp SAVESHAD
.setupchar jmp SETUPCHAR

.GetFrameInfo jmp GETFRAMEINFO
.indexblock jmp INDEXBLOCK
.markred jmp MARKRED
.markfred jmp MARKFRED
.markwipe jmp MARKWIPE

.markmove jmp MARKMOVE
.markfloor jmp MARKFLOOR
.unindex jmp UNINDEX
.quickfloor jmp QUICKFLOOR
.unevenfloor jmp UNEVENFLOOR

.markhalf jmp MARKHALF
.addswordobj jmp ADDSWORDOBJ
.getblocky1 jmp GETBLOCKYP
.checkledge jmp CHECKLEDGE
.get2infront jmp GET2INFRONT

.checkspikes jmp CHECKSPIKES
.rechargemeter jmp RECHARGEMETER
.addfcharx jmp ADDFCHARX
.facedx jmp FACEDX
.jumpseq jmp JUMPSEQ

.GetBaseBlock jmp GETBASEBLOCK
.LoadKidwOp jmp LOADKIDWOP
.SaveKidwOp jmp SAVEKIDWOP
.getopdist jmp GETOPDIST
.LoadShadwOp jmp LOADSHADWOP

.SaveShadwOp jmp SAVESHADWOP
.boostmeter jmp BOOSTMETER
.getunderft jmp GETUNDERFT
.getinfront jmp GETINFRONT
.getbehind jmp GETBEHIND

.getabove jmp GETABOVE
.getaboveinf jmp GETABOVEINF
.cmpwall jmp CMPWALL
ENDIF

\*-------------------------------
\ lst
\ put eq
\ lst
\ put gameeq
\ lst
\ put movedata
\ lst
\ put seqdata
\ lst
\ put soundnames
\ lst off

\*-------------------------------
\ dum locals
\
\ctrlsubs_tempright ds 1
\ztemp ds 2
\tempstate ds 1
\]cutdir ds 1
\
\ dend

\*-------------------------------
\*  Misc. data

.plus1 EQUB LO(-1),1
.minus1 EQUB 1,LO(-1)

maxmaxstr = 10 ;strength meter maximum

thinner = 3

\*-------------------------------
\*
\*  R E A D   B L O C K
\*
\*  In:  A = screen #
\*       X = block x (0-9 onscreen)
\*       Y = block y (0-2 onscreen)
\*
\*  Out: A,X = objid
\*       Y = block # (0-29)
\*       BlueType, BlueSpec set
\*       tempscrn,tempblockx,tempblocky = onscreen block coords
\*
\*  - Offscreen block values are traced to their home screen
\*  - Screen 0 is treated as a solid mass
\*
\*-------------------------------
.RDBLOCK
 sta tempscrn
 stx tempblockx
 sty tempblocky

.RDBLOCK1
{
 jsr handler ;handle offscreen references

 lda tempscrn
 beq nullscrn ;screen 0
 jsr calcblue ;returns BlueType/Spec

 ldy tempblocky
 lda Mult10,y
 clc
 adc tempblockx
 tay
 lda (BlueType),y
 and #idmask
 tax ;return result in X & A
 rts

.nullscrn lda #block
 tax
 rts

\*-------------------------------
\*  Handle offscreen block references (recursive)

.handler lda tempblockx
 bpl label_1
 jsr offleft
 jmp handler

.label_1 cmp #10
 bcc label_2
 jsr offrt
 jmp handler

.label_2 lda tempblocky
 bpl label_3
 jsr offtop
 jmp handler

.label_3 cmp #3
 bcc return
 jsr offbot
 jmp handler

.return rts

.offtop clc
 adc #3
 sta tempblocky

 lda tempscrn
 jsr GETUP
 sta tempscrn
 rts

.offbot sec
 sbc #3
 sta tempblocky

 lda tempscrn
 jsr GETDOWN
 sta tempscrn
 rts

.offleft clc
 adc #10
 sta tempblockx

 lda tempscrn
 jsr GETLEFT
 sta tempscrn
 rts

.offrt sec
 sbc #10
 sta tempblockx

 lda tempscrn
 jsr GETRIGHT
 sta tempscrn
 rts
}

\*-------------------------------
\*
\*  Get adjacent screen numbers
\*
\*  In:  A = original screen #
\*  Out: A = adjacent screen #
\*
\*-------------------------------
.GETLEFT
{
 beq return
 asl A
 asl A
 tax
 lda MAP-4,x
.return
 rts
}

.GETRIGHT
{
 beq return
 asl A
 asl A
 tax
 lda MAP-3,x
.return
 rts
}

.GETUP
{
 beq return
 asl A
 asl A
 tax
 lda MAP-2,x
.return
 rts
}

.GETDOWN
{
 beq return
 asl A
 asl A
 tax
 lda MAP-1,x
.return
 rts
}

\*-------------------------------
\*
\*  G E T   S C R E E N S
\*
\*  Get VisScrn's 8 surrounding screens from map
\*  (Store in scrnAbove, scrnBelow, etc.)
\*
\*-------------------------------
.GETSCRNS
{
 lda VisScrn
 jsr GETLEFT
 sta scrnLeft

 lda VisScrn
 jsr GETRIGHT
 sta scrnRight

 lda VisScrn
 jsr GETUP
 sta scrnAbove

 lda VisScrn
 jsr GETDOWN
 sta scrnBelow

\* and diagonals

 lda scrnBelow
 jsr GETLEFT
 sta scrnBelowL

 lda scrnBelow
 jsr GETRIGHT
 sta scrnBelowR

 lda scrnAbove
 jsr GETLEFT
 sta scrnAboveL

 lda scrnAbove
 jsr GETRIGHT
 sta scrnAboveR
 rts
}

\*-------------------------------
\*
\*  G E T   B A S E   X
\*
\*  In: Char data; frame data
\*
\*  Out: A = character's base X-coord
\*
\*-------------------------------
.GETBASEX
{
 lda Fcheck
 and #Ffootmark
  ;# pixels to count in from left edge of image
 eor #$ff
 clc
 adc #1 ;- Fcheck

 clc
 adc Fdx ;Fdx (+ = fwd, - = bkwd)

 jmp ADDCHARX ;Add to CharX in direction char is facing
}

\*-------------------------------
\*
\*  Add A to CharX in direction char is facing
\*
\*  In: A = # pixels to add (+ = fwd, - = bkwd)
\*      CharX = original char X-coord
\*      CharFace = direction char is facing
\*
\*  Out: A = new char X-coord
\*
\*-------------------------------
.ADDCHARX
{
 bit CharFace ;-1 = left (normal)
 bpl right ;0 = right (mirrored)

 eor #$ff
 clc
 adc #1 ;A := -A

.right clc
 adc CharX
 rts
}

\*-------------------------------
\*
\* Add A to FCharX
\* (A range: -127 to 127)
\*
\* In: A; FChar data
\* Out: FCharX
\*
\*-------------------------------
.ADDFCHARX
{
 sta ztemp
 bpl label_1 ;hibit clr

 lda #0
 sec
 sbc ztemp
 sta ztemp ;make it posititve

 lda #$ff ;hibit set
.label_1 eor FCharFace
 bmi left

 lda ztemp
 clc
 adc FCharX
 sta FCharX

 lda FCharX+1
 adc #0
 sta FCharX+1
 rts

.left lda FCharX
 sec
 sbc ztemp
 sta FCharX

 lda FCharX+1
 sbc #0
 sta FCharX+1
 rts
}

\*-------------------------------
\*
\* In: CharFace,CharBlockX,CharBlockY,CharScrn
\*
\* Out: Results of RDBLOCK for block underfoot/in front/etc.
\*
\*-------------------------------

.GETUNDERFT
{
 ldx CharBlockX
 ldy CharBlockY
 lda CharScrn
 jmp RDBLOCK
}

.GETINFRONT
{
 ldx CharFace
 inx
 lda CharBlockX
 clc
 adc plus1,x
 sta infrontx
 tax

 ldy CharBlockY
 lda CharScrn
 jmp RDBLOCK
}

.GET2INFRONT
{
 ldx CharFace
 inx
 lda CharBlockX
 clc
 adc plus1,x
 clc
 adc plus1,x
 tax

 ldy CharBlockY
 lda CharScrn
 jmp RDBLOCK
}

.GETBEHIND
{
 ldx CharFace
 inx
 lda CharBlockX
 clc
 adc minus1,x
 sta behindx
 tax

 ldy CharBlockY
 lda CharScrn
 jmp RDBLOCK
}

.GETABOVE
{
 ldy CharBlockY
 dey
 sty abovey

 ldx CharBlockX
 lda CharScrn
 jmp RDBLOCK
}

.GETABOVEINF
{
 ldx CharFace
 inx
 lda CharBlockX
 clc
 adc plus1,x
 sta infrontx
 tax

 ldy CharBlockY
 dey
 sty abovey

 lda CharScrn
 jmp RDBLOCK
}

.GETABOVEBEH
{
 ldx CharFace
 inx
 lda CharBlockX
 clc
 adc minus1,x
 sta behindx
 tax

 ldy CharBlockY
 dey
 sty abovey

 lda CharScrn
 jmp RDBLOCK
}

\*-------------------------------
\*
\*  G E T   D I S T A N C E
\*
\*  In: Char data
\*
\*  Out: A = # of pixels (0-13) to add to CharX to move
\*       char base X-coord to end of current block
\*
\*-------------------------------

.GETDIST
 jsr GETBASEX ;returns A = base X-coord

.GETDIST1
{
 jsr GETBLOCKXP ;returns A = block #, OFFSET = pixel #

 lda CharFace ;0=right, -1=left
 beq facingright

.facingleft
 lda OFFSET
 rts

.facingright
 lda #13
 sec
 sbc OFFSET
 rts
}

\*-------------------------------
\*
\*  G E T   B L O C K   E D G E
\*
\*  In:  A = block # (-5 to 14)
\*  Out: A = screen X-coord of left edge
\*
\*-------------------------------
.GETBLOCKEJ
{
 clc
 adc #5
 tax
 lda BlockEdge,x
 rts
}

\*-------------------------------
\*
\*  G E T   B L O C K   X
\*
\*  In:  A = X-coord
\*
\*  Out: A = # of the 14-pixel-wide block within which
\*           this pixel falls (0-9 onscreen)
\*
\*       OFFSET = pixel within this block
\*
\*  - Use GETBLOCKXP for objects on center plane
\*  - Use GETBLOCKX for absolute X-coords & foreground plane
\*
\*-------------------------------
.GETBLOCKXP
 sec
 sbc #angle

.GETBLOCKX
{
 tay

 lda PixelTable,y
 sta OFFSET

 lda BlockTable,y
 rts
}

\*-------------------------------
\*
\*  G E T   B L O C K   Y
\*
\*  In: A = screen Y-coord (0-255)
\*
\*  Out: A = block y (3 = o.s.)
\*
\*  - Use GETBLOCKYP for objects on center plane
\*  - Use GETBLOCKY for absolute Y-coords & foreground plane
\*
\*-------------------------------

.GETBLOCKY
{
 ldx #3
.loop cmp BlockTop+1,x
 bcs gotY
 dex
 bpl loop
.gotY txa
 rts
}

.GETBLOCKYP
{
 ldx #3
.loop cmp FloorY+1,x
 bcs gotY
 dex
 bpl loop
.gotY txa
 rts
}

\*-------------------------------
\*
\*  I N D E X   B L O C K
\*
\*  Index (tempblockx,tempblocky)
\*
\*  Return y = block # (0-29) and cc if block is onscreen
\*         y = 0 to 9 and cs if block is on screen above
\*         y = 30 and cs if block is o.s.
\*
\*-------------------------------

.INDEXBLOCK
{
 ldy tempblocky
 bmi above
 cpy #3
 bcs os

 lda tempblockx
 cmp #10
 bcs os ;0 <= tempblockx <= 9

 clc
 adc Mult10,y

 tay ;return y = block #
 clc ;and carry clr
 rts

.os ldy #30
 sec ;and carry set
 rts

.above ldy tempblockx
 sec
.return
 rts
}

\*-------------------------------
\*
\*  U N I N D E X
\*
\*  In: A = block index (0-29)
\*  Out: A = blockx, X = blocky
\*
\*-------------------------------
.UNINDEX
{
 ldx #0
.loop cmp #10
 bcc return
 sec
 sbc #10
 inx
 bne loop
.return
 rts
}

\*-------------------------------
\*
\*  G E T   B A S E   B L O C K
\*
\*  In: Char data
\*  Out: CharBlockX
\*
\*-------------------------------
.GETBASEBLOCK
{
 jsr getbasex
 jsr getblockxp
 sta CharBlockX
 rts
}

\*-------------------------------
\*
\*  F A C E   D X
\*
\*  In: CharFace; A = DX
\*
\*  Out: DX if char is facing right, -DX if facing left
\*
\*-------------------------------
.FACEDX
{
 bit CharFace
 bmi return

 eor #$ff
 clc
 adc #1 ;negate

.return
 rts
}

\*-------------------------------
\*
\*  J U M P S E Q
\*
\*  Jump to some other point in sequence table
\*
\*  In: A = sequence # (1-127)
\*
\*-------------------------------
.JUMPSEQ
{
 sec
 sbc #1
 asl A
 tax ;x = 2(a-1)

 lda seqtab,x
 sta CharSeq

 lda seqtab+1,x
 sta CharSeq+1
.return
 rts
}

\*-------------------------------
\*
\*  Similar routine for Opponent
\*
\*-------------------------------

.OPJUMPSEQ
{
 sec
 sbc #1
 asl A
 tax ;x = 2(a-1)

 lda seqtab,x
 sta OpSeq

 lda seqtab+1,x
 sta OpSeq+1
.return
 rts
}

\*-------------------------------
\*
\*  I N D E X   C H A R
\*
\*  In: Char data; GETEDGES results
\*
\*  Out: FCharIndex = character block index
\*
\*-------------------------------

.INDEXCHAR
{
 lda CharAction
 cmp #1
 bne label_4
;If CharAction = 1 (on solid ground)
;use leftblock/bottomblock
 lda bottomblock
 sta tempblocky

 lda leftblock
.label_1 sta tempblockx

 lda CharPosn
 cmp #135
 bcc label_2
 cmp #149
 bcc local_climbup

.label_2 cmp #2
 beq local_fall
 cmp #3
 beq local_fall
 cmp #4
 beq local_fall
 cmp #6
 bne label_3
.local_fall
.local_climbup dec tempblockx  ;if falling or climbing up

.label_3 jsr indexblock
 sty FCharIndex
 rts

\* else use CharBlockX/Y

.label_4 lda CharBlockY
 sta tempblocky

 lda CharBlockX
 jmp label_1
}

\*-------------------------------
\*
\*  S E T   U P   C H A R
\*
\*  Set up character for FRAMEADV
\*
\*  In: Char data
\*  Out: FChar data
\*
\*  Translate char data into the form "addchar" expects
\*  (Decode image #; get actual 280 x 192 screen coords)
\*
\*-------------------------------

.SETUPCHAR
{
 jsr zerocrop ;(can call cropchar later)

 jsr GETFRAMEINFO

 lda CharFace
 sta FCharFace

 jsr decodeim ;get FCharImage & Table from
 ;encoded Fimage & Fsword data
 lda #0
 sta FCharX+1

 lda Fdx
 jsr addcharx ;A := CharX + Fdx
 sec
 sbc #ScrnLeft ;different coord system
 sta FCharX

 asl FCharX
 rol FCharX+1
 beq pos

 lda FCharX
 cmp #$f0
 bcc pos
 lda #$ff
 sta FCharX+1
.pos  ;X := 2X
 lda Fdy
 clc
 adc CharY
 sec
 sbc #ScrnTop
 sta FCharY

 lda Fcheck
 eor FCharFace ;Look only at the hibits
 bmi ok ;They don't match-->even X-coord
;They match-->odd X-coord
 lda FCharX
 clc
 adc #1
 sta FCharX
 bcc ok
 inc FCharX+1
.ok
}
.return_43
 rts

\*-------------------------------
\*
\*  S E T   U P   S W O R D
\*
\*  In: Char & FChar data
\*
\*  If character's sword is visible, add it to obj table
\*
\*-------------------------------

.SETUPSWORD
{
 lda CharID
 cmp #2
 bne label_3
 lda CharLife
 bmi label_2 ;live guard's sword is always visible

.label_3 lda CharPosn
 cmp #229
 bcc label_1
 cmp #238
 bcc label_2 ;sheathing
.label_1 lda CharSword
 beq return_43
.label_2
 lda Fsword
 and #$3f ;frame #
 beq return_43 ;no sword for this frame

 jsr getswordframe

 ldy #0
 lda (framepoint),y
 beq return_43

 jsr decodeswim ;get FCharImage & Table

 iny
 lda (framepoint),y
 sta Fdx

 iny
 lda (framepoint),y
 sta Fdy

 lda Fdx
 jsr ADDFCHARX ;A := FCharX + Fdx

 lda Fdy
 clc
 adc FCharY
 sta FCharY

 jmp ADDSWORDOBJ
}

\*-------------------------------
\*
\*  G E T   F R A M E
\*
\*  In: A = frame # (1-192)
\*  Out: framepoint = 2-byte pointer to frame def table
\*
\*-------------------------------

.GETFRAME ;Kid uses main char set
{
 jsr getfindex
 lda framepoint
 clc
 adc #LO(Fdef)
 sta framepoint
 lda framepoint+1
 adc #HI(Fdef)
 sta framepoint+1
 rts
}

\*-------------------------------

.getaltframe1 ;Enemy uses alt set 1
{
 jsr getfindex
 lda framepoint
 clc
 adc #LO(altset1)
 sta framepoint
 lda framepoint+1
 adc #HI(altset1)
 sta framepoint+1
 rts
}

\*-------------------------------

\\ altset2 could be overlaid on top of altset1 to save RAM (in theory)
.getaltframe2 ;Princess & Vizier use alt set 2
{
 jsr getfindex
 lda framepoint
 clc
 adc #LO(altset2)
 sta framepoint
 lda framepoint+1
 adc #HI(altset2)
 sta framepoint+1
 rts
}

\*-------------------------------

.getfindex
{
 sec
 sbc #1
 sta ztemp
 sta framepoint

 lda #0
 sta ztemp+1
 sta framepoint+1

 asl framepoint
 rol framepoint+1
 asl framepoint
 rol framepoint+1 ;2-byte multiply by 4

 lda framepoint
 clc
 adc ztemp
 sta framepoint

 lda framepoint+1
 adc ztemp+1
 sta framepoint+1 ;make it x5
 rts
}

\*-------------------------------
\*
\* getswordframe
\*
\* In: A = frame #
\* Out: framepoint
\*
\*-------------------------------

.getswordframe
{
 sec
 sbc #1
 sta ztemp
 sta framepoint

 lda #0
 sta ztemp+1
 sta framepoint+1

 asl framepoint
 rol framepoint+1 ;x2

 lda framepoint
 clc
 adc ztemp
 sta framepoint

 lda framepoint+1
 adc ztemp+1
 sta framepoint+1 ;+1 is 3

 lda framepoint
 clc
 adc #LO(swordtab)
 sta framepoint

 lda framepoint+1
 adc #HI(swordtab)
 sta framepoint+1

 rts
}

\*-------------------------------
\*
\* Decode char image
\*
\* In:  Fimage, Fsword (encoded)
\*
\* Out: FCharImage (image #, 0-127)
\*      FCharTable (table #, 0-7)
\*
\*-------------------------------

.decodeim
{
 lda Fimage
 and #%10000000 ;bit 2 of table #
 sta ztemp

 lda Fsword
 and #%11000000 ;bits 0-1 of table #

 lsr A
 adc ztemp
 lsr A
 lsr A
 lsr A
 lsr A
 lsr A
 sta FCharTable

 lda Fimage
 and #$7f
\ NOT BEEB
\ ora timebomb ;must be 0!
 sta FCharImage

 rts
}

\*-------------------------------
\*
\* Decode sword image
\*
\* In: A = image #
\*
\* Out: FCharImage, FCharTable
\*
\*-------------------------------

.decodeswim
{
 sta FCharImage ;image #

 lda #2 ;chtable3
 sta FCharTable
 rts
}

\*-------------------------------
\*
\*  G E T   E D G E S
\*
\*  Get edges of character image
\*
\*  In: FChar data as set by "setframe"
\*
\*  Out: leftej/rightej/topej = boundaries of image (140-res)
\*       leftblock, rightblock, topblock, bottomblock
\*       CDLeftEj, CDRightEj (for coll detection)
\*       imheight, imwidth
\*
\*-------------------------------

.GETEDGES
{
 lda FCharImage
 ldx FCharTable
 jsr dimchar ;return A = image width, x = height
 stx imheight

 tax ;image width in bytes
 lda Mult7,x ;in 1/2 pixels
 clc
 adc #1 ;add 1/2 pixel
 lsr A;and divide by 2
 sta imwidth ;to get width in pixels

 lda FCharX+1
 lsr A
 lda FCharX
 ror A
 clc
 adc #ScrnLeft ;convert back to 140-res

\* (If facing LEFT, X-coord is leftmost pixel of LEFTMOST byte
\* of image; if facing RIGHT, leftmost pixel of RIGHTMOST byte.)

 ldx CharFace
 bmi ok ;facing L
;facing R
 sec
 sbc imwidth

.ok sta leftej
 clc
 adc imwidth
 sta rightej

 lda FCharY
 sec
 sbc imheight
 clc
 adc #1

 cmp #192
 bcc ok2
 lda #0

.ok2 sta topej

 jsr getblocky

 cmp #3
 bne label_1
 lda #LO(-1) ;if o.s., call it -1

.label_1 sta topblock

 lda FCharY
 jsr getblocky ;if o.s., call it 3
 sta bottomblock

 lda leftej
 jsr getblockx ;leftmost affected block
 sta leftblock

 lda rightej
 jsr getblockx ;rightmost affected block
 sta rightblock

\* get leading edge (for collision detection)

 lda #0
 sta ztemp

 lda Fcheck
 and #Fthinmark
 beq nothin

 lda #thinner ;make character 3 bits thinner
 sta ztemp ;on both sides

.nothin lda leftej
 clc
 adc ztemp
 sta CDLeftEj

 lda rightej
 sec
 sbc ztemp
 sta CDRightEj

 rts
}

\*===============================
\*
\*  Q U I C K   F L O O R
\*
\*  Mark for redraw whatever floorpieces character might be
\*  impinging on
\*
\*  In: CharData; GETEDGES results
\*
\*-------------------------------

.QUICKFLOOR
{
 lda CharPosn
 cmp #135
 bcc label_2
 cmp #149
 bcc local_climbup

.label_2 lda CharAction
 cmp #1
 bne label_1

 lda CharPosn
 cmp #78
 bcc return
 cmp #80
 bcc local_fall
.return rts

.label_1 cmp #2
 beq local_fall
 cmp #3
 beq local_fall
 cmp #4
 beq local_fall
 cmp #6
 bne return

.local_fall lda #LO(markfloor)
 ldx #HI(markfloor)
 bne cont1

.local_climbup
 lda #LO(markhalf)
 ldx #HI(markhalf)

\* Mark floorbuf/halfbuf for up to 6 affected blocks
\* Start with rightblock, work left to leftblock

.cont1
 sta marksm1+1
 sta marksm2+1
 stx marksm1+2
 stx marksm2+2

 lda rightblock
.loop sta tempblockx

 jsr markul

 lda tempblockx
 cmp leftblock
 beq return
 sec
 sbc #1
 bpl loop
}
.return_26
 rts

\* mark upper & lower blocks for this blockx

.markul
 lda bottomblock
 sta tempblocky

 jsr indexblock ;lower block
 lda #REDRAW_FRAMES
.marksm1 jsr markhalf

 lda topblock
 cmp bottomblock
 beq return_26
 sta tempblocky

 jsr indexblock ;upper block
 lda #2
.marksm2 jmp markhalf

\*-------------------------------
\*
\*  Q U I C K  F G
\*
\*  Mark for redraw any f.g. elements char (or his sword)
\*  might be impinging on
\*
\*  In: Char data; left/right/top/bottomblock
\*
\*-------------------------------

.QUICKFG
{
\* Quick fix to cover sword

 lda CharSword
 cmp #2
 bcc cont

 lda CharFace
 bpl faceR
 dec leftblock
 jmp cont

.faceR inc rightblock

\* Continue

.cont lda bottomblock
.outloop
 sta tempblocky

 lda rightblock
.loop sta tempblockx

 jsr indexblock
 lda #3
 jsr MARKFRED

 lda tempblockx
 cmp leftblock
 beq end
 sec
 sbc #1
 bpl loop
.end
 lda tempblocky
 cmp topblock
 beq return
 sec
 sbc #1
 bpl outloop
.return
 rts

\ NOT BEEB
\.bug jmp showpage
}

\*-------------------------------
\*
\*  C R O P   C H A R A C T E R
\*
\*  In: FChar data as set by "setframe"
\*      leftej,rightej, etc. as set by "getedges"
\*
\*  Out: FCharCL/CR/CU/CD
\*
\*-------------------------------

.CROPCHAR
{
\* If char is climbing stairs, mask door

 lda CharPosn
 cmp #224
 bcc nost
 cmp #229
 bcs nost
 lda doortop ;set by drawexitb
 clc
 adc #2
 cmp FCharY
 bcs return         ;:bug ;temp!
 sta FCharCU
.return rts

\ NOT BEEB
\.bug ldy #$F0
\ jsr showpage

.nost

\* If char is under solid (a&b) floor, crop top

 ldx leftblock
 ldy topblock
 lda CharScrn
 jsr rdblock
 cmp #block
 beq label_1
 jsr cmpspace
 beq local_not

\* Special case (more lenient): if char is jumping
\* up to touch ceiling

.label_1 lda CharAction
 bne label_10
 lda CharPosn
 cmp #79
 beq label_2
 cmp #81
 bne label_10
 beq label_2

\* Otherwise, both left & right topblocks must be solid

.label_10 ldx rightblock
 ldy topblock
 lda CharScrn
 jsr rdblock
 cmp #block
 beq label_2
 jsr cmpspace
 beq local_not

.label_2 ldx CharBlockY
 inx
 cpx #1
 beq ok

 lda BlockTop,x
 cmp FCharY
 bcs local_not

 sec
 sbc #floorheight
 cmp topej
 bcs local_not

.ok lda BlockTop,x
 sta FCharCU
 sta topej
.local_not

\* If char is standing left of a panel, crop R
\* Char is considered "left" if CDLeftEj falls within
\* panel block

 lda CDLeftEj
 jsr getblockx
 sta blockx

 tax
 ldy CharBlockY
 lda CharScrn
 jsr rdblock

 cmp #panelwof
 beq local_r
 cmp #panelwif
 bne nor

\* Char's foot is within panel block
\* Special case: If character is hanging R, we don't
\* need to check his head

.local_r lda CharFace
 bmi cont

 lda CharAction
 cmp #2
 beq r2 ;yes--hanging R

\* Check block to right of char's head

.cont
 ldx blockx
 ldy topblock
 lda CharScrn
 jsr rdblock

 cmp #block
 beq r2
 cmp #panelwof
 beq r2
 cmp #panelwif
 bne nor

\* Also a panel -- make a wall

.r2 lda tempblockx
 asl A
 asl A
 clc
 adc #4
 sta FCharCR
 rts

\* Is char standing to L of solid block?
\* (i.e. does CDRightEj fall within block?)

.nor
 lda CDRightEj
 jsr getblockx
 sta blockx

 tax
 ldy CharBlockY
 lda CharScrn
 jsr rdblock

 cmp #block
 bne nob

\* Foot is under block--what about head?

 ldx blockx
 ldy topblock
 lda CharScrn
 jsr rdblock

 cmp #block
 bne nob

\* Also a panel -- make a wall

.yescrop
 lda tempscrn
 cmp CharScrn
 bne nob

 lda tempblockx
 asl A
 asl A
 sta FCharCR
.nob
 rts
}

\*-------------------------------
\*
\*  Z E R O   C R O P
\*
\*-------------------------------

.zerocrop
{
 lda #0
 sta FCharCU
 sta FCharCL
 lda #40
 sta FCharCR
 lda #192
 sta FCharCD
 rts
}

\*===============================
\*
\*  C O M P A R E   S P A C E
\*
\*  Is it a space (can you pass thru)?
\*  NOTE: Solid block is considered a space (it has no floor)
\*
\*  In: A = objid
\*  Out: 0 = space, 1 = floor
\*
\*-------------------------------

.CMPSPACE
{
 cmp #space
 beq local_space
 cmp #pillartop
 beq local_space
 cmp #panelwof
 beq local_space
 cmp #block
 beq local_space
 cmp #archtop1
 bcs local_space

 lda #1
 rts

.local_space lda #0
 rts
}

\*-------------------------------
\*
\*  C O M P A R E   B A R R I E R
\*
\*  Is it a barrier?
\*
\*  Return A = 0 if clear, else A = barrier code #
\*
\*-------------------------------

.CMPBARR
{
 cmp #panelwif
 beq b1
 cmp #panelwof
 beq b1
 cmp #gate
 bne label_2

.b1 lda #1 ;panel/gate
 rts

.label_2 cmp #mirror
 beq yes3

 cmp #slicer
 bne label_3

.yes3 lda #3 ;mirror/slicer
 rts

.label_3 cmp #block
 bne label_4

 lda #4 ;block
 rts
.label_4
.local_clear lda #0
.return rts

.barr lda #1
 rts
}

\*-------------------------------
\*
\* Is it a wall? Return 0 if yes, 1 if no
\* (Solid block, or panel if you're facing L)
\*
\*-------------------------------

.CMPWALL
{
 cmp #block
 beq yes
 ldx CharFace
 bpl no
 cmp #panelwif
 beq yes
 cmp #panelwof
 beq yes
.no lda #1
 rts
.yes lda #0
 rts
}

\*-------------------------------
\*
\*  Add kid/reflection/shadowman/guard to object table
\*
\*  In: FChar data
\*
\*-------------------------------

.ADDKIDOBJ
{
 lda #TypeKid
 jmp addcharobj
}

\*-------------------------------

.ADDREFLOBJ
{
 lda #TypeReflect
 jmp addcharobj
}

\*-------------------------------

.ADDSHADOBJ
{
 lda #TypeShad
 jmp addcharobj
}

\*-------------------------------

.ADDGUARDOBJ
{
 lda #TypeGd
 jmp addcharobj
}

\*-------------------------------
\*
\* Add sword to object table
\* In: FChar data for character holding sword
\*
\*-------------------------------

.ADDSWORDOBJ
{
 lda #TypeSword
 jmp addcharobj
}

\*-------------------------------
\*
\*  G E T   S E Q
\*
\*  Get next byte from seqtable & advance CharSeq
\*  (2-byte pointer to sequence table)
\*
\*-------------------------------
.GETSEQ
{
 ldy #0
 lda (CharSeq),y
 pha

 inc CharSeq
 bne done
 inc CharSeq+1

.done pla
 rts
}

\*-------------------------------
\*
\*  G E T   F R A M E   I N F O
\*
\*  Get frame info for char (based on CharPosn)
\*
\*-------------------------------
.GETFRAMEINFO
{
 lda CharPosn
 jsr GETFRAME ;set framepoint

 jsr usealtsets ;if appropriate

 ldy #0
 lda (framepoint),y
 sta Fimage

 iny
 lda (framepoint),y
 sta Fsword

 iny
 lda (framepoint),y
 sta Fdx

 iny
 lda (framepoint),y
 sta Fdy

 iny
 lda (framepoint),y
 sta Fcheck
}
.return_23
 rts

\*-------------------------------
\*
\* Use alternate character image sets
\* (if appropriate)
\*
\* In: Char data; framepoint
\* Out: framepoint
\*
\*-------------------------------
.usealtsets
{
 ldx CharID
 beq return_23 ;kid uses main set, enemy uses alt set 1
 cpx #24
 beq return_23 ;mouse uses main set
 cpx #5
 bcs usealt2 ;princess & vizier use alt set 2

 lda CharPosn
 cpx #2
 bcc label_1
 cmp #102
 bcc return_23
 cmp #107
 bcs label_1
 ;frames 102-106 (falling): substitute 172-176 altset
 clc
 adc #70

.label_1 cmp #150
 bcc return_23
 cmp #190
 bcs return_23
;frames 150-189: use altset
 sec
 sbc #149
 jmp getaltframe1

.usealt2
 lda CharPosn
 jmp getaltframe2
}

\*===============================
\*
\*  M A R K
\*
\*  In: A = mark value (usually 2)
\*      Results of INDEXBLOCK:
\*      Y = block #; carry set or clear
\*
\*  Out: Preserve A, Y, carry
\*
\*-------------------------------

.mark_os
{
 cpy #10 ;top line from scrn above?
 bcs return ;no
 sta topbuf,y
 sec ;preserve cs
.return
 rts
}

.MARKRED
{
 bcs mark_os
 sta redbuf,y
 rts
}

.MARKFRED
{
 bcs return
 sta fredbuf,y
.return
 rts
}

.MARKWIPE
{
 bcs return
 pha
 lda wipebuf,y
 beq label_2
 lda height
 cmp whitebuf,y ;if wipebuf is already marked,
 bcc label_1 ;use larger of 2 whitebuf values
.label_2 lda height
 sta whitebuf,y
.label_1 pla
 sta wipebuf,y
 clc ;return with cc
.return
 rts
}

.MARKMOVE
{
 bcs mark_os
 sta movebuf,y
 rts
}

.MARKFLOOR
{
 bcs mark_os
 sta floorbuf,y
 rts
}

.MARKHALF
{
 bcs mark_os
 sta halfbuf,y
 rts
}

IF 0    \\ Weirdly duped from grafix.asm
\*-------------------------------
\*
\*  Z E R O   R E D
\*
\*  zero redraw buffers
\*
\*-------------------------------

.ZERORED
{
 lda #0

 ldy #29

.loop sta redbuf,y
 sta fredbuf,y
 sta floorbuf,y
 sta wipebuf,y
 sta movebuf,y
 sta objbuf,y
 sta halfbuf,y

 dey
 bpl loop

 ldy #9
.dloop sta topbuf,y
 dey
 bpl dloop

 rts
}
ENDIF

\*-------------------------------
\*
\*  C H E C K L E D G E
\*
\*  In: blockid = block that must be clear;
\*      A = RDBLOCK results for block that must be ledge
\*
\*  Out: A = 1 if grabbable, 0 if not
\*
\*-------------------------------

.CHECKLEDGE
{
 sta ztemp

 lda (BlueSpec),y
 sta coll_tempstate

 lda blockid ;must be clear

 cmp #block
 beq local_no

 cmp #panelwof ;CMPSPACE considers panel w/o floor
  bne cont ;to be clear--

 bit CharFace ;but it isn't if char wants to grab
 bpl local_no ;floorpiece to right
.cont
 jsr cmpspace
 bne local_no

\* Clear above -- is there a ledge in front?

 lda ztemp ;must be a solid floorpiece
;with exposed ledge
 cmp #loose
 bne local_notloose

 bit coll_tempstate
 bne local_no ;floor is already loose

.local_notloose
 cmp #panelwif
 bne cont2 ;panel w/floor can be grabbed
;only if facing right
 bit CharFace
 bmi local_no

.cont2 jsr cmpspace
 beq local_no

.local_yes lda #1
 rts

.local_no lda #0
}
.return_41
 rts

\*-------------------------------
\*
\*  C H E C K   S P I K E S
\*
\*  Spikes spring out when char passes over them (at any
\*  height).
\*
\*-------------------------------

.CHECKSPIKES
{
 lda rightej
 jsr getblockxp
 bmi return_41
 sta ctrlsubs_tempright

\* for blockx = leftblock to rightblock

 lda leftej
 jsr getblockxp
.loop_1 sta blockx

 jsr sub

 lda blockx
 cmp ctrlsubs_tempright
 beq return_41
 clc
 adc #1
 jmp loop_1

.sub sta tempblockx
 lda CharBlockY
 sta tempblocky
 lda CharScrn
 sta tempscrn
.loop_2 jsr rdblock1

 cmp #spikes
 bne again
 jmp trigspikes

.again jsr cmpspace
 bne return_41

 lda tempscrn
 beq return_41 ;null scrn
 cmp CharScrn
 bne return_41 ;wait till he's on same screen

 inc tempblocky
 jmp loop_2 ;check 1 level below
}

\*===============================
\*
\*  Load/save kid/shad vars
\*
\*-------------------------------
numvars = 16

.LOADKID
{
 ldx #numvars-1

.loop lda Kid,x
 sta Char,x

 dex
 bpl loop
 rts
}

.SAVEKID
{
 ldx #numvars-1

.loop lda Char,x
 sta Kid,x

 dex
 bpl loop
 rts
}

.LOADSHAD
{
 ldx #numvars-1

.loop lda Shad,x
 sta Char,x

 dex
 bpl loop
.return
 rts
}

.SAVESHAD
{
 ldx #numvars-1

.loop lda Char,x
 sta Shad,x

 dex
 bpl loop
 rts
}

\*  Load kid w/ opponent

.LOADKIDWOP
{
 ldx #numvars-1

.loop lda Kid,x
 sta Char,x

 lda Shad,x
 sta Op,x

 dex
 bpl loop
 rts
}

.SAVEKIDWOP
{
 ldx #numvars-1

.loop lda Char,x
 sta Kid,x

 lda Op,x
 sta Shad,x

 dex
 bpl loop
 rts
}

\* Load shadowman w/ opponent

.LOADSHADWOP
{
 ldx #numvars-1

.loop lda Shad,x
 sta Char,x

 lda Kid,x
 sta Op,x

 dex
 bpl loop
 rts
}

.SAVESHADWOP
{
 ldx #numvars-1

.loop lda Char,x
 sta Shad,x

 lda Op,x
 sta Kid,x

 dex
 bpl loop
 rts
}

\*-------------------------------
\*
\* Recharge strength meter to max
\*
\*-------------------------------

.RECHARGEMETER
{
 lda MaxKidStr
 sec
 sbc KidStrength
 sta ChgKidStr
.return
 rts
}

\*-------------------------------
\*
\* Boost strength meter max by 1 and recharge
\*
\*-------------------------------

.BOOSTMETER
{
 lda MaxKidStr
 cmp #maxmaxstr
 bcs label_1

 clc
 adc #1
 sta MaxKidStr

.label_1 jmp RECHARGEMETER
}

\*-------------------------------
\*
\* Get distance between char & opponent
\* (# pixels char must move fwd to reach opponent)
\* If dist is greater than 127, return 127 (+ or -)
\*
\*-------------------------------
estwidth = 13 ;rough est of char width

.GETOPDIST
{
 lda CharScrn
 cmp OpScrn
 bne safe

\* First, get A = OpX-CharX (abs. value <= 127)

 lda OpX
 cmp CharX
 bcc neg
 sec
 sbc CharX
 bpl got
 lda #127
 bpl got

.neg lda CharX
 sec
 sbc OpX
 bpl label_1
 lda #127
.label_1 eor #$ff
 clc
 adc #1 ;negate

\* If CharFace = left, negate

.got ldx CharFace
 bpl cont
 eor #$ff
 clc
 adc #1

\* If chars are facing in opposite directions,
\* adjust by estimate of width of figure

.cont tax
 lda CharFace
 eor OpFace
 bpl done
 txa
 cmp #127-estwidth
 bcs done2
 clc
 adc #estwidth
.done2 tax
 rts

.safe ldx #127 ;arbitrary large dist.
.done txa ;return value in A
.return
 rts
}

\*-------------------------------
\*
\*  Adjust CharY for uneven floor
\*
\*-------------------------------

.UNEVENFLOOR
{
 jsr getunderft
 cmp #dpressplate
 bne return
 inc CharY
.return
 rts
}

\*-------------------------------
\ lst
\ ds 1
\ usr $a9,19,$200,*-org
\ lst off
