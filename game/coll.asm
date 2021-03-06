; coll.asm
; Originally COLL.S
; Collision detection functions

.coll
\org = $4500
\ tr on
\ lst off
\*-------------------------------
\*
\*  PRINCE OF PERSIA
\*  Copyright 1989 Jordan Mechner
\*
\*-------------------------------
\ org org

IF _JMP_TABLE=FALSE
.checkbarr jmp CHECKBARR
.collisions jmp COLLISIONS
.getfwddist jmp GETFWDDIST
.checkcoll jmp CHECKCOLL
.animchar jmp ANIMCHAR

.checkslice jmp CHECKSLICE
.checkslice2 jmp CHECKSLICE2
\ jmp markmeters ;temp
.checkgate jmp CHECKGATE
\ jmp firstguard ;temp

.enemycoll jmp ENEMYCOLL
ENDIF

\*-------------------------------
\ lst
\ put eq
\ lst
\ put gameeq
\ lst
\ put seqdata
\ lst
\ put soundnames
\ lst
\ put movedata
\ lst off

\ dum $f0
\ztemp ds 1
\coll_CollFace ds 1
\coll_tempobjid ds 1
\tempstate ds 1
\ dend

\*-------------------------------
\*  Distance in pixels from either edge of block to barrier
\*  BarL + BarR + BarWidth == 14
\*
\*  Indexed by barrier code:
\*  0 = clear, 1 = panel/gate, 2 = flask, 3 = mirror/slicer
\*  4 = block

.BarL EQUB 0,12,2,0,0
.BarR EQUB 0,0,9,11,0

\*-------------------------------
\DeathVelocity = 33
\OofVelocity = 22

gatemargin = 6 ;higher = more generous

.return_34
 RTS

\*-------------------------------
\*
\*  C H E C K  B A R R I E R
\*
\*  Check for collisions with vertical barriers
\*
\*-------------------------------

.CHECKBARR
{
 lda #LO(-1) ;"no-collision" flag
 sta collideL
 sta collideR

\* Check for situations where character is temporarily
\* "collision-proof"

 lda CharAction
 cmp #7 ;turning?
 beq return_34

\* Initialize CD/SN buffers
\* (Copy "lastframe" data from "thisframe", "above", or "below";
\* init "thisframe" with FF)

 lda CharBlockY
 sta BlockYthis

 jsr initCDbufs

 lda BlockYthis
 sta BlockYlast

\* Get beginning & end of range

 lda CDRightEj
 jsr getblockxp
 clc
 adc #2
 cmp #11
 bcc ok
 lda #11
  ;Last (rightmost) block in range +1
.ok sta endrange

 lda CDLeftEj
 jsr getblockxp
 tax
 dex ;First (leftmost) block in range
 stx begrange

\* Get CD & SN data for every block in range [begrange..endrange]
\* on this level (BlockYthis) and on levels below & above

\* This level...

 lda BlockYthis
 sta blocky

 lda #LO(SNthisframe)
 ldx #LO(CDthisframe)
 jsr getCData

\* Level below...

 lda BlockYthis
 clc
 adc #1
 sta blocky

 lda #LO(SNbelow)
 ldx #LO(CDbelow)
 jsr getCData

\* ...and level above

 lda BlockYthis
 sec
 sbc #1
 sta blocky

 lda #LO(SNabove)
 ldx #LO(CDabove)
 jsr getCData

\* Got new data... now compare thisframe with lastframe
\* If a nybble has changed from 0 to 1, we have a collision.

 ldx #9
.loop2
 lda SNthisframe,x
 bmi no ;ff = no data for this frame
 cmp SNlastframe,x
 bne no ;no corresponding data for last frame

 lda CDlastframe,x
 and #$0f ;low nybble first (L edge of barr)
 bne noL

 lda CDthisframe,x
 and #$0f
 beq noL

 stx collideL ;We have collision w/ L edge
;x = block # (0-9)

.noL lda CDlastframe,x
 and #$f0 ;hi nybble (R edge of barr)
 bne noR

 lda CDthisframe,x
 and #$f0
 beq noR

 stx collideR ;collision w/ R edge
.noR
.no dex
 bpl loop2

 ldx collideL
 ldy collideR

.return
 rts
}

\*-------------------------------
\*
\*  G E T  C D A T A
\*
\*  Get "thisframe" data for specified blocky
\*
\*-------------------------------

.getCData
{
 sta smodSN+1
 stx smodCD+1

 lda begrange
 jsr getblockej ;left edge of block
 clc
 adc #angle ;perspective
 sta blockedge

 ldx begrange
.loop stx bufindex

\* First compare L edge of barr with R edge of char

 lda CharScrn
 ldx bufindex
 ldy blocky
 jsr getleftbar ;Get left edge of barrier

 cmp CDRightEj
 bcc RofL
 ;= means L of L
.LofL lda #0
 beq cont1

.RofL lda #$f
.cont1 sta ztemp

\* Now compare R edge of barr with L edge of char

 lda CharScrn
 ldx bufindex
 ldy blocky
 jsr getrightbar ;Get right edge of barrier

 cmp CDLeftEj
 bcc RofR
 beq RofR ;= means R of R

.LofR lda #$f0
 bne cont2

.RofR lda #0
.cont2 ora ztemp

 ldx tempblockx ;guaranteed 0-9 by rdblock
.smodCD sta CDthisframe,x

 lda tempscrn
.smodSN sta SNthisframe,x ;screen #

 lda blockedge
 clc
 adc #14
 sta blockedge

 ldx bufindex
 inx
 cpx endrange
 bne loop

.return
 rts
}

\*-------------------------------
\*
\*  I N I T   C D B U F S
\*
\*  Initialize SN and CD buffers
\*  (Take "lastframe" data from "thisframe", "above", or "below";
\*  init "thisframe" with FF)
\*
\*-------------------------------

.initCDbufs
{
 lda BlockYthis
 cmp BlockYlast ;same BlockY as last frame?
 beq usethis ;yes--copy data from "thisframe"

 clc
 adc #3
 cmp BlockYlast
 beq usethis

 sec
 sbc #6
 cmp BlockYlast
 beq usethis

\* BlockY has changed--copy data from "above" or "below"

 lda BlockYthis
 clc
 adc #1
 cmp BlockYlast
 beq useabove
 sec
 sbc #3
 cmp BlockYlast
 beq useabove

.usebelow
 lda #LO(SNbelow)
 ldx #LO(CDbelow)
 jmp cont

.useabove lda #LO(SNabove)
 ldx #LO(CDabove)
 jmp cont

.usethis lda #LO(SNthisframe)
 ldx #LO(CDthisframe)

.cont sta smodSN+1
 stx smodCD+1

\* Copy contents of appropriate SN & CD buffers (thisframe,
\* below, or above) into lastframe buffers...
\* and initialize SN buffers with $ff

 ldx #9
.zloop
.smodSN lda SNbelow,x
 sta SNlastframe,x

.smodCD lda CDbelow,x
 sta CDlastframe,x

 lda #$ff
 sta SNthisframe,x
 sta SNabove,x
 sta SNbelow,x

 dex
 bpl zloop

.return
 rts
}

\*-------------------------------
\*
\*  G E T   L E F T   B A R
\*
\*  Get X-coord of left edge of barrier
\*
\*  In:  X/Y/A = blockx/blocky/scrn
\*       blockedge
\*
\*  Out: A = screen X-coord (140)
\*       Return A = 255 if this block is no barrier
\*
\*-------------------------------

.getleftbar
{
 jsr rdblock ;get block ID

 jsr cmpbarr ;return A = barrier code #
 beq clear ;or -1 if clear
 tay

 lda blockedge
 clc
 adc BarL,y ;barr dist from L edge of block
 sec
 rts

.clear lda #255
 clc
 rts
}

\*-------------------------------
\*
\*  G E T   R I G H T   B A R
\*
\*  Get right edge of barrier, 0 if clear
\*
\*-------------------------------

.getrightbar
{
 jsr rdblock

 jsr cmpbarr
 beq clear
 tay

 lda blockedge
 clc
 adc #13
 sec
 sbc BarR,y ;barr dist from R edge of block
 sec
 rts

.clear lda #0
 clc
.return
 rts
}

\*-------------------------------
\*
\*  C O L L I S I O N S
\*
\*  If a collision was detected, act on it
\*
\*  In: collideL/R: - if no coll, 0-9 refers to block in
\*      which collision occurred
\*
\*  (CollideL is collision with LEFT EDGE of barrier
\*  CollideR is collision with RIGHT EDGE of barrier)
\*
\*-------------------------------

.COLLISIONS
{
 lda AMtimer ;antimatter timer
 beq cont
\ NOT BEEB
\ lda $c030
 dec AMtimer
 rts
.cont

\* Check for situations where we let character
\* pass thru barrier (e.g., climbing up onto ledge)

 lda CharAction
 cmp #2 ;hanging?
 beq return_32
 cmp #6 ;hanging?
 beq return_32
 lda CharPosn
 cmp #135
 bcc cont2
 cmp #149
 bcc return_32 ;climbing?

.cont2
 ldx collideL
 bmi noL
 stx collX
 jmp leftcoll

.noL ldx collideR
 bmi noR
 stx collX
 jmp rightcoll
.noR
}
.return_32
 rts

\*-------------------------------
\*
\*  R I G H T   C O L L I S I O N
\*
\*-------------------------------

.rightcoll
{
 lda CharSword
 cmp #2 ;if in fighting mode,
 beq label_1 ;waive front-facing requirement

 lda CharFace
 bpl return_32
.label_1
 jsr checkcoll1
 bcc return_32

 lda tempscrn
 ldx tempblockx
 ldy tempblocky

 jsr getrightbar ;edge of barr
 sec
 sbc CDLeftEj ;dist to char

 ldx #0 ;right
 jmp collide
}

\*-------------------------------
\*
\*  L E F T   C O L L I S I O N
\*
\*-------------------------------

.leftcoll
{
 lda CharSword
 cmp #2
 beq label_1

 lda CharFace
 bne return_32
.label_1
 jsr checkcoll1
 bcc return_32

 lda tempscrn
 ldx tempblockx
 ldy tempblocky
 jsr getleftbar
 sec
 sbc CDRightEj ;- dist to char

 ldx #LO(-1) ;left
 jmp collide
}

\*-------------------------------
\*
\* Call CHECKCOLL for block #X
\*
\* In: CD data; X = blockx
\*
\*-------------------------------

.checkcoll1
{
 stx tempblockx

 lda CharBlockY
 bpl label_2
 clc
 adc #3
 bne label_1

.label_2 cmp #3
 bcc label_1
 sec
 sbc #3
.label_1 sta tempblocky

 lda SNthisframe,x
 sta tempscrn

 jsr rdblock1

 jmp CHECKCOLL
}

\*-------------------------------
\*
\*  C H E C K   C O L L
\*
\*  In: RDBLOCK results (A = objid)
\*
\*  Out: tempblockx,tempblocky,tempscrn
\*       cs if collision, cc if not
\*
\*-------------------------------

.CHECKCOLL
{
 cmp #flask
 beq no ;flask is not really a barrier

 cmp #gate
 beq local_gate

 cmp #slicer
 beq local_slicer

 cmp #mirror
 beq local_mirror
 bne c1

\* You can pass thru mirror from R only if you take a
\* running jump

.local_mirror
 lda CharID
 bne c1 ;must be kid
 lda CharPosn
 cmp #39
 bcc c1
 cmp #44
 bcs c1
 lda CharFace
 bpl c1

 jsr smashmirror
 lda #$ff
 sta createshad ;set flag

 clc
 rts

\* Is slicer closed?

.local_slicer lda (BlueSpec),y
 cmp #slicerExt
 bne no ;no--pass thru
 beq c1

\* Is gate low enough to bar you?

.local_gate jsr gatebarr ;return cc if gate bars you
 bcc c1

\* no collision--pass thru barrier

.no clc
 rts

\* Yes, collision--get blockedge & return cs

.c1
 lda tempblockx
 jsr getblockej
 jsr AdjustScrn
 clc
 adc #angle
 sta blockedge
.yes sec
}
.return_33
 rts

\*-------------------------------
\*
\* AdjustScrn
\*
\* In:  tempscrn, VisScrn
\*      scrnLeft/Right/BelowL/BelowR
\*      A = X-coord on tempscrn
\*
\* Out: A = X=coord on VisScrn
\*
\*-------------------------------

.AdjustScrn
{
 ldx tempscrn
 cpx VisScrn
 beq return
 cpx scrnLeft
 beq osL
 cpx scrnBelowL
 beq osL
 cpx scrnRight
 beq osR
 cpx scrnBelowR
 beq osR
 rts
.osR clc
 adc #ScrnWidth
 rts
.osL sec
 sbc #ScrnWidth
.return
 rts
}

\*-------------------------------
\*
\*  C O L L I D E
\*
\*  In: A = distance from barrier to character
\*      X = coll direction (-1 = left, 0 = right)
\*      tempblockx,y,scrn set for collision block
\*
\*-------------------------------

.collide
{
 stx coll_CollFace ;temp var

 ldx CharLife ;dead?
 bpl return_33 ;yes--let him finish falling (or whatever)

 ldx CharPosn
 cpx #177 ;impaled?
 beq return_33 ;yes--ignore collision

 clc
 adc CharX
 sta CharX

\* In midair or on the ground?

 jsr rdblock1

 ldx coll_CollFace
 bpl faceL

 cmp #block ;If this block has no floor,
 beq label_2 ;use the one in front of it
 bne label_1

.label_2 dec tempblockx
 jmp label_3

.faceL cmp #panelwof ;Panelwof is only a problem
 beq label_4 ;when facing L
 cmp #panelwif
 beq label_4
 cmp #block
 bne label_1

.label_4 inc tempblockx
 lda tempscrn
 bne label_3
 lda tempblockx
 cmp #10
 bne label_3
 lda CharScrn
 sta tempscrn
 lda #0
 sta tempblockx ;screen 0 block 10 = CharScrn block 0

.label_3 jsr rdblock1

.label_1 jsr cmpspace
 bne GroundBump
}

\*-------------------------------
\* Bump into barrier w/o floor

.AirBump
{
 lda #LO(-4)
 jsr addcharx
 sta CharX

 lda CharAction
 cmp #4 ;already falling?
 bne label_3
;yes--just rebound off wall
 lda #0
 sta CharXVel
 beq smackwall

.label_3 lda #bumpfall
 jsr jumpseq
 jsr animchar

.smackwall
}

.BumpSound
{
 lda #1
 sta alertguard
 lda #SmackWall
 jmp addsound
}

\*-------------------------------
\* Bump into barrier w/floor

.GroundBump
{
 ldx CharBlockY

 lda CharSword
 cmp #2
 beq skipair ;no airbump if en garde

 lda FloorY+1,x
 sec
 sbc CharY
 cmp #15 ;constant
 bcs AirBump
.skipair
 lda FloorY+1,x
 sta CharY

 lda CharYVel
 cmp #OofVelocity
 bcc okvel
 lda #LO(-5)
 jsr addcharx
 sta CharX
 rts ;let checkfloor take care of it

.okvel lda #0
 sta CharYVel

 lda CharLife
 beq GroundBump_deadbump

\* Is he en garde?

 lda CharSword
 cmp #2
 beq CollideEng ;yes--collide en garde

\* Should it be a hard or a soft bump?

.normal
 ldx CharPosn ;last frame

 cpx #24
 beq local_hard
 cpx #25
 beq local_hard ;standjump-->hard

 cpx #40
 bcc label_1
 cpx #43
 bcc local_hard ;runjump-->hard

.label_1 cpx #102
 bcc label_2
 cpx #107
 bcc local_hard ;freefall-->hard

.label_2

.local_soft lda #bump
 jsr jumpseq
 jsr BumpSound ;soft bump sound?
 jmp animchar

.local_hard lda #hardbump
}
.GroundBump_doit
{
 jsr jumpseq
 jsr animchar

 jmp BumpSound
}
\* dead when he hits the wall
.GroundBump_deadbump
{
.return
 rts
}

\*-------------------------------
\* Collide en garde

.CollideEng
{
 lda coll_CollFace
 cmp CharFace
 beq collback

 lda #bumpengfwd
 bne GroundBump_doit

\* Char is en garde & trying to back into barrier

.collback
 lda #bumpengback
 jsr jumpseq
 jsr animchar ;get new frame

 lda #1
 jsr addcharx
 sta CharX
 rts
}

\*-------------------------------
\*
\*  G E T   F W D   D I S T
\*
\*  In: Char data
\*
\*  Out: A = size of "careful step" forward (0-14 pixels)
\*       X = what you're stepping up to
\*           (0 = edge, 1 = barrier, 2 = clear)
\*       RDBLOCK results for that block
\*
\*-------------------------------

.GETFWDDIST
{
\* Get edges

 jsr GetBaseBlock
 jsr setupchar
 jsr getedges

\* If this block contains barrier, get distance

 jsr getunderft ;read block underfoot
 sta coll_tempobjid

 jsr cmpbarr
 beq nextb ;This block is clear

 lda CharBlockX
 sta tempblockx
 jsr DBarr ;returns A = dist to barrier
 tax
 bpl tobarr

\* If next block contains barrier, get distance

.nextb
 jsr getinfront
 sta coll_tempobjid
 cmp #panelwof
 bne label_99 ;Panelwof is special case
 ldx CharFace ;if you're facing R
 bpl toEOB

.label_99 jsr cmpbarr
 beq nobarr

 lda infrontx
 sta tempblockx
 jsr DBarr
 tax
 bpl tobarr

\* If next block is dangerous (e.g., empty space)
\* or sword or potion, step to end of this block

.nobarr
 jsr getinfront ;read block in front
 sta coll_tempobjid

  cmp #loose
 beq toEOB ;step to end of block

 cmp #pressplate
 beq toEOB1

 cmp #sword
 beq toEOB1
 cmp #flask
 beq toEOB1

 jsr cmpspace
 beq toEOB

\* All clear--take a full step forward

.local_fullstep lda #11 ;natural step size

 ldx #2 ;clear
 bne done

\* Step to end of block (no "testfoot")

.toEOB1 jsr getdist
 beq local_fullstep
 ldx #0
 beq done

\* Step to end of block

.toEOB jsr getdist ;returns # pixels to end of block (0-13)

 ldx #0 ;edge

.done ldy coll_tempobjid
.return
 rts

\* Step up to barrier

.tobarr
 cmp #14
 bcs local_fullstep

 ldx #1 ;barrier
 bne done
}

\*-------------------------------
\*
\* Get distance to barrier
\*
\* In: rdblock results; coll_tempobjid
\*     Must have called setupchar/getedges
\* Out: A = distance to barrier (- if barr is behind char)
\*
\*-------------------------------

.DBarr
{
 lda coll_tempobjid
 cmp #gate
 bne ok
;treat gate as barrier only if down
 jsr gatebarr ;returns cs if open
 bcs local_clr

.ok lda tempblockx
 jsr getblockej
 clc
 adc #angle
 sta blockedge ;L edge of this block

 lda CharFace
 bmi checkL

\* Char facing R -- get distance to barrier

.checkR
 lda coll_tempobjid ;block ID

 jsr cmpbarr ;return A = barrier code #
 beq local_clr
 tay

 lda blockedge
 clc
 adc BarL,y
 sta ztemp ;left edge of barr

 sec
 sbc CDRightEj
 rts ;If -, barr is behind char

.local_clr lda #LO(-1)
 rts

\* Char facing L -- get distance to barr

.checkL
 lda coll_tempobjid

 jsr cmpbarr
 beq local_clr
 tay

 lda blockedge
 clc
 adc #13
 sec
 sbc BarR,y
 sta ztemp ;R edge of barr

 lda CDLeftEj
 sec
 sbc ztemp

.return
 rts
}

\*-------------------------------
\*
\*  A N I M   C H A R
\*
\*  Get next frame from sequence table;
\*  update char data accordingly.
\*  We're now ready to draw this frame.
\*
\*-------------------------------
.ANIMCHAR
{
.next jsr getseq ;get next byte from seqtab
 ;& increment CharSeq

 cmp #chx ;"change x" instruction?
 bne no1

 jsr getseq ;next byte is delta-x

 jsr addcharx
 sta CharX

 jmp next

\*-------------------------------
.no1 cmp #chy
 bne no2

 jsr getseq

 clc
 adc CharY
 sta CharY

 jmp next

\*-------------------------------
.no2 cmp #aboutface
 bne no3

 lda CharFace
 eor #$ff
 sta CharFace

 jmp next

\*-------------------------------
.no3 cmp #goto
 bne no4

.label_goto jsr getseq ;low byte of address
 pha

 jsr getseq ;high byte

 sta CharSeq+1
 pla
 sta CharSeq

 jmp next

\*-------------------------------
.no4 cmp #up
 bne no5

 dec CharBlockY

 jsr addslicers

 jmp next

\*-------------------------------
.no5 cmp #down
 bne no6

 inc CharBlockY

 jsr addslicers

 jmp next

\*-------------------------------
.no6 cmp #act
 bne no7

 jsr getseq
 sta CharAction

 jmp next

.no7 cmp #setfall
 bne no8

 jsr getseq
 sta CharXVel

 jsr getseq
 sta CharYVel

 jmp next

.no8
 cmp #ifwtless
 bne no9

 lda weightless ;weightless?
 bne label_goto ;yes--branch

 jsr getseq
 jsr getseq ;skip 2 bytes
 jmp next ;& continue

.no9 cmp #die
 bne no10
 jmp next

.no10 cmp #jaru
 bne no11

 lda #1
 sta jarabove ;jar floorboards above
 jmp next

.no11 cmp #jard
 bne no12

 lda #LO(-1)
 sta jarabove ;jar floorboards below
 jmp next

\*-------------------------------
.no12 cmp #tap
 bne no13

 jsr getseq ;sound #
 cmp #0 ;0: alert guard
 beq label_0

 cmp #1 ;1: footstep
 bne label_1
 lda #Footstep
.label_tap jsr addsound
.label_0 lda #1
 sta alertguard
 jmp next

.label_1 cmp #2 ;2: smack wall
 bne label_2
 lda #SmackWall
 bne label_tap
.label_2 jmp next

.no13 cmp #nextlevel
 bne no14

 jsr GoneUpstairs
 jmp next

.no14 cmp #effect
 bne no15

 jsr getseq ;effect #
 cmp #1
 bne fx0

 jsr potioneffect
.fx0 jmp next

.no15
\*-------------------------------
 sta CharPosn ;frame #

.return
 rts
}

\*-------------------------------
\* Char has gone upstairs
\* What do we do?
\*-------------------------------

.GoneUpstairs
{
 lda level
 cmp #13
 beq ok ;no music for level 13
 cmp #4
 bne label_1 ;mirror level is special
.label_3 lda #s_Shadow
 bne label_2

.label_1 lda #s_Upstairs
.label_2 ldx #25
 jsr cuesong

.ok inc NextLevel
 rts
}

\*-------------------------------
\*
\*  Sliced by slicer? (Does CD buf show char overlapping
\*  with a closed slicer?)
\*
\*  In: Char data, CD data
\*
\*-------------------------------

.CHECKSLICE
{
 lda CharBlockY
 sta tempblocky

 ldx #9

.loop stx tempblockx

 lda CDthisframe,x
 cmp #$ff ;char overlapping barr?
 bne ok ;no

\* Yes--is it a slicer?

 lda SNthisframe,x
 sta tempscrn

 jsr rdblock1
 cmp #slicer
 bne ok

 lda (BlueSpec),y
 and #$7f
 cmp #slicerExt ;slicer closed?
 beq coll_slice ;yes--slice!

\* No--keep checking

.ok ldx tempblockx
 dex
 bpl loop
}
.return_65
 rts

\* Slice!
\* In: rdblock results for slicer block
.coll_slice
{
 lda (BlueSpec),y
 ora #$80
 sta (BlueSpec),y ;set hibit (smear)

.cont lda CharPosn
 cmp #178 ;if already cut in half (e.g. by another slicer),
 beq return_65 ;leave him alone

 lda tempblockx
 jsr getblockej ;edge of slicer block
 clc
 adc #7
 sta CharX

 lda #8
 jsr addcharx
 sta CharX ;align char w/slicer

 ldx CharBlockY
 inx
 lda FloorY,x
 sta CharY ;align char w/floor

 lda #100
 jsr decstr

 lda #Splat
 jsr addsound

 lda #halve
 jsr jumpseq
 jmp animchar
}

\*-------------------------------
\*
\*  Sliced by slicer?
\*
\*  (Use this routine for enemy, who has no CD data)
\*
\*  In: Char data; GETEDGES results
\*
\*-------------------------------

.CHECKSLICE2
{
 jsr getunderft
 jsr local_slice ;return cs if sliced
 bcs return

 inc tempblockx
 jsr rdblock1

.local_slice
 cmp #slicer
 bne safe
 lda (BlueSpec),y
 and #$7f
 cmp #slicerExt
 bne safe ;slicer open

 lda tempblockx
 jsr getblockej
 clc
 adc #angle
 sta blockedge

 lda tempscrn
 ldx tempblockx
 ldy tempblocky
 jsr getleftbar
 cmp CDRightEj
 bcs safe

 lda tempscrn
 ldx tempblockx
 ldy tempblocky
 jsr getrightbar
 cmp CDLeftEj
 bcc safe
 beq safe

 jsr rdblock1
 jsr coll_slice
 sec
 rts

.safe clc
.return
 rts
}

\*-------------------------------
\*
\* Special situation: If char is standing directly under closing
\* gate, it knocks him aside when it shuts.
\*
\* In: Char data, CD data
\*
\*-------------------------------

.CHECKGATE
{
 lda CharAction
 cmp #7 ;turning
 beq label_1
 lda CharPosn
 cmp #15 ;standing?
 beq label_1
 cmp #108
 bcc return
 cmp #111 ;crouching?
 bcs return
.label_1
 jsr getunderft
 cmp #gate
 beq local_check

 dec tempblockx
 jsr rdblock1
 cmp #gate
 bne return
.local_check
 ldx tempblockx
 lda CDthisframe,x
 and CDlastframe,x
 cmp #$ff
 bne return

 jsr gatebarr
 bcs return

 jsr BumpSound

\* bump him left or right?

 lda tempblockx
 sta collX
 jsr getunderft
 lda tempblockx
 cmp collX
 beq local_left
 bcs local_right

.local_left lda #LO(-5)
 bne label_10
.local_right lda #5
.label_10 clc
 adc CharX
 sta CharX
.return
 rts
}

\*-------------------------------
\*
\* Return cc if gate bars you, cs if clear
\*
\*-------------------------------

.gatebarr
{
 lda (BlueSpec),y
 lsr A
 lsr A
 clc
 adc #gatemargin
 cmp imheight
.return
 rts
}

\*-------------------------------
\*
\* Limited collision detection for enemies
\* (backing into wall or gate while fighting)
\*
\*-------------------------------

.ENEMYCOLL
{
 lda AMtimer ;antimatter timer
 bne return

 lda CharAction
 cmp #1
 bne return ;must be on ground
 lda CharLife
 bpl return ;& alive
 lda CharSword
 cmp #2
 bcc return ;& en garde

 jsr getunderft
 cmp #block
 beq local_collide
 cmp #panelwif
 beq local_collide
 cmp #gate
 bne label_1
 jsr gatebarr
 bcc local_collide

\* If facing R, check block behind too

.label_1 lda CharFace
 bmi return
 dec tempblockx
 jsr rdblock1
 cmp #panelwif
 beq local_collide
 cmp #gate
 bne return
 jsr gatebarr
 bcc local_collide
.return
 rts

\* Char is en garde & trying to back into barrier
\* Put him right at edge

.local_collide
 jsr setupchar
 jsr getedges ;get edges

 lda tempscrn
 ldx tempblockx
 ldy tempblocky
 jsr rdblock
 sta coll_tempobjid
 jsr checkcoll
 bcc return

 jsr DBarr2 ;get A = dist to barrier
 tax
 bpl return
 eor #$ff
 clc
 adc #1
 jsr addcharx
 sta CharX

 lda #bumpengback
 jsr jumpseq
 jsr animchar ;get new frame
 jmp rereadblocks
}

\*-------------------------------
\*
\* Special version of DBarr for enemy collisions
\*
\* In: checkcoll results; coll_tempobjid
\*     Must have called setupchar/getedges
\* Out: A = distance to barrier (- if barr is behind char)
\*
\*-------------------------------

.DBarr2
{
 lda CharFace
 bpl checkL ;Note: reversed from DBarr

\* Char's back facing R -- get distance to barrier

.checkR
 lda coll_tempobjid ;block ID

 jsr cmpbarr ;return A = barrier code #
 beq local_clr
 tay

 lda blockedge
 clc
 adc BarL,y
 sta ztemp ;left edge of barr

 sec
 sbc CDRightEj
 rts ;If -, barr is behind char

.local_clr lda #LO(-1)
 rts

\* Char facing L -- get distance to barr

.checkL
 lda coll_tempobjid

 jsr cmpbarr
 beq local_clr
 tay

 lda blockedge
 clc
 adc #13
 sec
 sbc BarR,y
 sta ztemp ;R edge of barr

 lda CDLeftEj
 sec
 sbc ztemp

.return
 rts
}

\*-------------------------------
\ lst
\ ds 1
\ usr $a9,16,$b00,*-org
\ lst off
