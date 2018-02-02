; gamebg.asm
; Originally GAMEBG.S
; Draw all special case game objects

.gamebg
\ThreeFive = 0
\org = $4c00
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

IF _JMP_TABLE = FALSE
.updatemeters jmp UPDATEMETERS
.DrawKidMeter jmp DRAWKIDMETER
.DrawSword jmp DRAWSWORD
.DrawKid jmp DRAWKID
.DrawShad jmp DRAWSHAD

.setupflame jmp SETUPFLAME
.continuemsg RTS    ; jmp CONTINUEMSG           BEEB TODO MESSAGES
.addcharobj jmp ADDCHAROBJ
.setobjindx jmp SETOBJINDX
.printlevel RTS     ; jmp PRINTLEVEL            BEEB TODO MESSAGES

.DrawOppMeter jmp DRAWOPPMETER
.flipdiskmsg BRK    ; jmp FLIPDISKMSG           NOT BEEB
.timeleftmsg RTS    ; jmp TIMELEFTMSG           BEEB TODO MESSAGES
.DrawGuard jmp DRAWGUARD
.DrawGuard2 jmp DRAWGUARD

.setupflask jmp SETUPFLASK
.setupcomix jmp SETUPCOMIX
.psetupflame jmp PSETUPFLAME
.drawpost jmp DRAWPOST
.drawglass jmp DRAWGLASS

.initlay jmp INITLAY
.twinkle BRK        ; jmp TWINKLE
.flow jmp FLOW
.pmask BRK          ; jmp PMASK
ENDIF

\ NOT BEEB COPY PROTECTION
\.yellow BRK         ; jmp YELLOW
\.setrecheck0 BRK    ; jmp SETRECHECK0
\.recheckyel BRK     ; jmp RECHECKYEL
\ ds 3
\ ds 3
\ ds 3

\*-------------------------------
\ lst
\ put eq
\ lst
\ put gameeq
\ lst off

\*-------------------------------
\*
\* 2nd level copy protection
\* signature check routine
\*
\*-------------------------------
IF ThreeFive
YELLOW lda #$80
 sta yellowflag
 rts

ELSE
\ put ryellow1
ENDIF

\*-------------------------------
\ lst
\ put movedata
\ lst off
\
\*-------------------------------

IF _TODO
 dum locals

xsave ds 1
addr ds 2
temp ds 1

 dend
ENDIF

.gamebg_tempsave skip $10

\*-------------------------------
\* Strength meters

.KidStrX EQUB 00,01,02,03,04,05,06,08,09,10,11,12
.KidStrOFF EQUB 00,00,00,00,00,00,00,00,00,00,00,00     \\ BEEB TODO OFFSET
\\.KidStrOFF EQUB 00,01,02,03,04,05,06,00,01,02,03,04

.OppStrX EQUB 27,28,29,30,31,32,34,35,36,37,38,39       \\ BEEB TODO MIRROR
.OppStrOFF EQUB 00,00,00,00,00,00,00,00,00,00,00,00     \\ BEEB TODO OFFSET
\\.OppStrX EQUB 39,38,37,36,35,34,32,31,30,29,28,27
\\.OppStrOFF EQUB 05,04,03,02,01,00,06,05,04,03,02,01

bullet = $88 ;in bgtable2
blank = $8c
.bline EQUB $89,$8a,$8b

\*-------------------------------
\* Post in Princess's room

postx = 31
posty = 152
postimg = $c ;chtable6

\*-------------------------------
\* Stars outside Princess's window

starx = 2
.stary EQUB $62,$65,$6d,$72
.stari EQUB $2a,$2b,$2b,$2a ;chtable6

\*-------------------------------
\* Hourglass

glassx = 19
glassy = 151
.glassimg EQUB $15,$0d,$0e,$0f,$10,$11,$12,$13,$14 ;chtable6
.sandht EQUB 0,1,2,3,4,5,6,7

flowx = glassx+1
flowy = glassy-2
.flowimg EQUB $16,$17,$18 ;chtable6

IF _TODO
*-------------------------------
* Masks for Princess's face & hair

pmaskdx hex 00,00
pmaskdy db -4,-33
pmaski hex 2c,22
ENDIF

\*-------------------------------
\* Comix

starimage = $41
startable = 0 ;chtable1

\*-------------------------------
\* Torch animation frames
\*               0  1  2  3  4  5  6  7  8  9 10 11
\*              12 13 14 15 16 17

.torchflame EQUB $52,$53,$54,$55,$56,$61,$62,$63,$64,$52,$54,$56
 EQUB $63,$61,$55,$53,$64,$62

.ptorchflame EQUB 1,2,3,4,5,6,7,8,9,3,5,7,1,4,9,2,8,6

\*-------------------------------
\* Bubbling flask frames
\*               0  1  2  3  4  5  6  7  8  9 10 11

.bubble EQUB $b2,$af,$b0,$b1,$b0,$af,$b1,$b0,$af

IF _TODO
*-------------------------------
* Message data: YCO, XCO, OFFSET, IMAGE

my = 90
lowmy = 153
hiconty = 73
lowconty = 168

contbox db hiconty,13,0,$7c ;Press button to continue
msgbox db my,15,0,$7b ;Empty message box
levelmsg db my-5,16,3,$7a ;"Level"
flipbox db my-1,13,0,$7e ;Turn disk over
timeleft db my,11,0,$7d ;Minutes left
seconds db my-5,14,0,$7f ;"Seconds"

*-------------------------------
* Numbers (0-12)

digit1 hex 00,00,00,00,00,00,00,00,00,00
 hex 71,71,71

digit2 hex 70,71,72,73,74,75,76,77,78,79
 hex 70,71,72

*-------------------------------
* Print "XX Minutes Left"
*-------------------------------
]rts rts

TIMELEFTMSG
 lda #timeleft
 ldx #>timeleft
 jsr setupimage

 lda MinLeft
 cmp #2
 bcs :ok
 lda KidAction
 cmp #3
 beq :ok
 cmp #4
 beq :ok ;falling
 lda KidBlockY
 cmp #1
 bne :ok
 lda #lowmy
 sta YCO ;keep msg box out of kid's way
:ok jsr superim1

 lda YCO
 sec
 sbc #5
 sta YCO

 lda XCO
 clc
 adc #1
 sta XCO
 lda #0
 sta OPACITY

 lda #ora
 sta OPACITY

 jsr getminleft

 lda MinLeft ;BCD byte (e.g., $55 = 55 minutes)
 cmp #2
 bcs :1
 lda SecLeft
:1 sta temp
 lsr
 lsr
 lsr
 lsr
 beq :skip1st
 tax
 lda digit2,x ;1st digit
 sta IMAGE

 jsr addmsg

:skip1st lda XCO
 clc
 adc #1
 sta XCO

 lda temp
 and #$f
 tax
 lda digit2,x ;2nd digit
 sta IMAGE

 jsr addmsg

* Minutes or seconds?

 lda MinLeft
 cmp #2
 bcs ]rts

 lda YCO
 pha
 lda #seconds
 ldx #>seconds
 jsr setupimage
 pla
 sta YCO
 lda #enum_sta
 sta OPACITY
 jmp addmsg ;replace "minutes" with "seconds"

*-------------------------------
* Print "Level XX"
*-------------------------------
]rts rts

PRINTLEVEL
 lda #msgbox
 ldx #>msgbox
 jsr superimage

 lda #levelmsg
 ldx #>levelmsg
 jsr setupimage

 jsr getlevelno
 cpx #10
 bcc :1
 lda #0
 sta OFFSET
:1
 lda #ora
 sta OPACITY
 jsr addmsg

 lda XCO
 clc
 adc #6
 sta XCO

 jsr getlevelno ;X = level # (0-12)
 lda digit1,x ;1st digit
 beq :skip1st
 sta IMAGE

 lda #ora
 sta OPACITY
 jsr addmsg

 lda XCO
 clc
 adc #1
 sta XCO

 jsr getlevelno
:skip1st lda digit2,x ;2nd digit
 sta IMAGE

 lda #ora
 sta OPACITY
 jmp addmsg

*-------------------------------
getlevelno
 ldx level
 cpx #13
 bcc :ok
 ldx #12
:ok
]rts rts

*-------------------------------
* Superimpose "Press button to continue" message
*-------------------------------
CONTINUEMSG
 lda #contbox
 ldx #>contbox
 jsr setupimage

 lda KidBlockX
 and #1
 bne :1
 lda #lowconty
 sta YCO
:1 jmp superim1

*-------------------------------
* Superimpose "Turn disk over" message
*-------------------------------
FLIPDISKMSG
 lda #flipbox
 ldx #>flipbox
 jmp superimage

*-------------------------------
* Superimpose image (using layrsave)
*-------------------------------
superimage
 jsr setupimage
superim1
 lda #enum_sta.$40
 sta OPACITY
 jmp addmsg

*-------------------------------
* Set up image
*
* In: A-X = image data addr
* Out: XCO, YCO, IMAGE
*-------------------------------
setupimage
 sta addr
 stx addr+1

 ldy #0
 lda (addr),y
 sta YCO
 iny
 lda (addr),y
 sta XCO
 iny
 lda (addr),y
 sta OFFSET
 iny
 lda (addr),y
 sta IMAGE
]rts
ENDIF
.return_28
 rts

\*-------------------------------
\* Draw Kid
\*-------------------------------

.DRAWKID
{
IF _DEBUG
 lda backtolife
 beq label_2
 DEC backtolife
 lda PAGE
 beq return_28 ;flash when coming back to life
ENDIF

.label_2 lda mergetimer
 bmi label_1
 and #1
 beq label_1
 jmp DrawEored ;flash between kid & shadowman

.label_1 jmp DrawNormal
}

\*-------------------------------
\* Draw Sword
\*-------------------------------

.DRAWSWORD
{
 jmp DrawNormal
}

\*-------------------------------
\* Draw Shadowman
\*-------------------------------

.DRAWSHAD
{
 jmp DrawEored
}

\*-------------------------------
\* Draw Guard
\*-------------------------------

.DRAWGUARD
{
IF EditorDisk
 lda #EditorDisk
 cmp #2
 beq DrawNormal
ENDIF

 lda GuardColor ;set by "ADDGUARD" in AUTO
 beq DrawNormal
 bne DrawShifted
}

\*-------------------------------

.DrawNormal
{
 lda #enum_mask
 sta OPACITY

 lda #UseLayrsave OR UseCharTable
 jmp addmid

.return
 rts
}

\*-------------------------------

.DrawShifted
{
\ lda #1
\ jsr chgoffset

\ lda #enum_mask

 lda #enum_eor          ; BEEB - this increments palette index at lowest level
 sta OPACITY

 lda #UseLayrsave OR UseCharTable
 jmp addmid
}

\*-------------------------------

.DrawEored
{
 lda #enum_eor          ; BEEB - this increments palette index at lowest level
 sta OPACITY

 lda #UseLayrsave OR UseCharTable
 jmp addmid
}

\*-------------------------------

.chgoffset
{
 clc
 adc OFFSET
 cmp #7
 bcc label_1

 inc XCO
 sec
 sbc #7

.label_1 sta OFFSET
 rts
}

\*-------------------------------
\*
\* Update strength meters
\*
\*-------------------------------

.UPDATEMETERS
{
 lda redkidmeter
 beq label_1

 jsr DrawKidMeter

.label_1 lda redoppmeter
 beq return

 jmp DrawOppMeter
.return
 rts
}

\*-------------------------------
\*
\* Draw kid's strength meter at lower left
\*
\*-------------------------------

.DRAWKIDMETER
{
 lda inbuilder
 bne return_53

 lda #191
 sta YCO
 lda #enum_sta
 sta OPACITY

 ldx #0
 stx xsave ;# of bullets drawn so far

.loop lda KidStrength
 sec
 sbc xsave ;# of bullets left to draw
 beq darkpart
 cmp #4
 bcs draw3
 cmp #3
 bcs draw2
 cmp #2
 bcc drawlast
;Draw 1 bullet
.draw1 ldy #1
 bne drline
 ;Draw 2 bullets
.draw2 ldy #2
 bne drline
;Draw 3 bullets
.draw3 ldy #3
 bne drline

.drawlast lda KidStrength
 cmp #2
 bcs steady
 lda PAGE
 beq skip ;flashes when down to 1
.steady lda #bullet
 ldy #1
 jsr draw
.skip jmp darkpart

\* Draw line of 1-3 bullets

.drline lda bline-1,y ;image #
 jsr draw
 jmp loop

.draw sta IMAGE
 ldx xsave
 tya
 clc
 adc xsave
 sta xsave

\* In: IMAGE; x = unit # (0 = leftmost)

.drawimg lda KidStrX,x
 sta XCO
 lda KidStrOFF,x
 sta OFFSET
 jmp addmsg

\* Draw blanks to limit of MaxKidStr

.darkpart
 lda #enum_and
 sta OPACITY
 lda #blank
 sta IMAGE
.dloop ldx xsave
 cpx MaxKidStr
 bcs return_53
 jsr drawimg
 inc xsave
 bne dloop
}
.return_53
 rts

\*-------------------------------
\*
\* Draw opp's strength meter at lower right
\*
\*-------------------------------

.DRAWOPPMETER
{
 lda inbuilder
 bne return_53

 lda OppStrength
 beq return_53

 lda ShadID
 cmp #24 ;mouse
 beq return_53
 cmp #4 ;skel
 beq return_53
 cmp #1 ;shadow
 bne label_1
 lda level
 cmp #12
 bne return_53 ;shad strength shows only on level 12
.label_1
 lda #191
 sta YCO
 lda #enum_sta OR $80 ;mirror
 sta OPACITY

 ldx #0
 stx xsave ;# of bullets drawn so far

.loop lda OppStrength
 sec
 sbc xsave ;# of bullets left to draw
 beq darkpart
 cmp #4
 bcs draw3
 cmp #3
 bcs draw2
 cmp #2
 bcc drawlast
;Draw 1 bullet
.draw1 ldy #1
 bne drline
 ;Draw 2 bullets
.draw2 ldy #2
 bne drline
;Draw 3 bullets
.draw3 ldy #3
 bne drline

.drawlast lda OppStrength
 cmp #2
 bcs steady
 lda PAGE
 beq darkpart ;flashes when down to 1
.steady lda #bullet
 ldy #1
 jmp draw

\* Draw line of 1-3 bullets

.drline lda bline-1,y ;image #
 jsr draw
 jmp loop

.draw sta IMAGE
 ldx xsave
 tya
 clc
 adc xsave
 sta xsave

.drawimg lda OppStrX,x
 sta XCO
 lda OppStrOFF,x
 sta OFFSET
 jmp addmsg

.darkpart
 lda #enum_and OR $80
 sta OPACITY
 lda #blank
 sta IMAGE
 ldx xsave
 jmp drawimg
}

\*-------------------------------
\*
\* Set up to draw bubbling flask
\*
\* In/out: same as SETUPFLAME
\*
\*-------------------------------
EmptyPot = 0
RefreshPot = %00100000
BoostPot = %01000000
MystPot = %01100000

boffset = 0             ; BEEB GFX PERF was 2 but means we can use FASTLAY or equiv

.SETUPFLASK
{
 lda #boffset
 sta OFFSET

 txa
 and #%11100000
 cmp #EmptyPot
 beq label_0
 cmp #BoostPot
 beq local_tall ;special flask (taller)
 bcc cont

\ BEEB TEMP - comment out
\ inc OFFSET ;mystery potion (blue)      ; BEEB TO DO - different palette

.local_tall lda YCO
 sec
 sbc #4
 sta YCO

.cont txa
 and #%00011111
 tax
 cpx #bubbLast+1
 bcc ok
 ldx #0
.ok lda bubble,x
 sta IMAGE

 inc XCO
 inc XCO

 lda YCO
 sec
 sbc #14
 sta YCO

 lda #enum_sta
 sta OPACITY

 lda #LO(bgtable2)
 sta TABLE
 lda #HI(bgtable2)
 sta TABLE+1

.return
 rts

.label_0 ldx #0
 beq ok
}

\*-------------------------------
\*
\* Setup to draw flame
\*
\* In: XCO = blockxco
\*     YCO = Ay
\*     X   = spreced
\*
\* Out: ready to call ADDBACK (or FASTLAY)
\*
\*-------------------------------

.SETUPFLAME
{
 cpx #torchLast+1
 bcs return

 lda torchflame,x
 sta IMAGE

 inc XCO

 lda YCO
 sec
 sbc #43
 sta YCO

 lda #enum_sta
 sta OPACITY

 lda #LO(bgtable1a)
 sta TABLE
 lda #HI(bgtable1a)
 sta TABLE+1

.return
 rts
}

\*-------------------------------
\*
\* Setup to draw flame (Princess's room)
\*
\* In: XCO, YCO; X = frame #
\* Out: Ready to call ADDMID or LAY
\*
\*-------------------------------

.PSETUPFLAME
{
 cpx #torchLast+1
 bcs return_59

 lda ptorchflame,x
 sta IMAGE

 lda #enum_sta
 sta OPACITY

 jsr initlay
}
.gamebg_setch6
{
 lda #LO(chtable6)
 sta TABLE
 lda #HI(chtable6)
 sta TABLE+1
 LDA #&FF           ; BEEB hideous hack :)
 STA BANK
}
.return_59
 rts


IF _TODO
*-------------------------------
*
* Twinkle one of the stars outside Princess's window
* (Update it directly on both screens)
*
* In: X = star # (0-3)
*
*-------------------------------
TWINKLE
 lda #starx
 sta XCO
 lda stary,x
 sta YCO
 lda stari,x
 sta IMAGE
 lda #enum_eor
 sta OPACITY
 jsr ]setch6
 jsr fastlay ;<--DIRECT HIRES CALL
 lda PAGE
 eor #$20
 sta PAGE ;& on other page
 jsr fastlay
 lda PAGE
 eor #$20
 sta PAGE
 rts
ENDIF

\*-------------------------------
\*
\* Draw big white post in Princess's room
\*
\*-------------------------------

.DRAWPOST
{
 lda #postx
 sta XCO
 lda #posty
 sta YCO
 lda #postimg
 sta IMAGE
 lda #enum_ora
 sta OPACITY
 jsr gamebg_setch6
 jmp addfore
}

\*-------------------------------
\*
\* Draw hourglass in Princess's room
\*
\* In: X = glass state (0-8, 0 = full)
\*
\*-------------------------------

.DRAWGLASS
{
 lda #glassx
 sta XCO
 lda #glassy
 sta YCO
 lda glassimg,x
 sta IMAGE
 lda #enum_sta
 sta OPACITY
 jsr gamebg_setch6
 jmp addback
}

IF _TODO
*-------------------------------
*
* Mask princess's face & hair for certain CharPosns
*
* (Called after ADDCHAROBJ)
*
*-------------------------------
PMASK
 ldx CharPosn
 cpx #19 ;plie
 bne :1
 ldx #0
 bpl :mask
:1 cpx #1 ;pslump-1
 beq :m1
 cpx #18 ;pslump-2
 bne :2
:m1 ldx #1
 bpl :mask
:2
ENDIF

.return_60
 rts

IF _TODO
:mask
 lda FCharY
 clc
 adc pmaskdy,x
 sta YCO

 lda XCO
 clc
 adc pmaskdx,x
 sta XCO

 lda pmaski,x
 sta IMAGE

 lda #5 ;chtable6
 sta TABLE

 lda #and
 sta OPACITY
 lda #UseLayrsave.$80
 jmp addmid
ENDIF

IF _NOT_BEEB
*-------------------------------
* If failed copy prot check due to disk not in drive, recheck
* In: a = 0 (Call after setrecheck0)
*-------------------------------
RECHECKYEL
 sta tempblockx
 sta tempblocky
 jsr indexblock ;set y = 0
 lda (locals),y ;All of this just to hide "lda recheck0"!
 beq ]rts
 ldx #5
 jsr yellow
 lda #$ff
 rts
ENDIF

\*-------------------------------
\*
\* Draw sand flowing through hourglass
\*
\* In: X = frame # (0-3)
\*     Y = hourglass state (0-8)
\*
\*-------------------------------

.FLOW
{
 cpy #8
 bcs return_60 ;glass is empty
 jsr initlay
 lda #glassy
 sec
 sbc sandht,y
 sta BOTCUT
 lda flowimg,x
 sta IMAGE
 lda #flowx
 sta XCO
 lda #0
 sta OFFSET
 lda #flowy
 sta YCO
 lda #enum_sta
 sta OPACITY
 jsr gamebg_setch6
 LDA #BEEB_SWRAM_SLOT_CHTAB67
 STA BANK       ; BEEB hideous hack
 jmp lay ;<---DIRECT HIRES CALL
}

\*-------------------------------
\* Save/restore FCharVars

.saveFChar
{
 ldx #$f
.loop lda FCharVars,x
 sta gamebg_tempsave,x
 dex
 bpl loop
 rts
}

.restoreFChar
{
 ldx #$f
.loop lda gamebg_tempsave,x
 sta FCharVars,x
 dex
 bpl loop
.return
 rts
}

\*-------------------------------
\*
\* Draw "comix" star
\*
\* In: Char data
\*
\*-------------------------------

.SETUPCOMIX
{
 jsr saveFChar
 jsr local_sub
 jmp restoreFChar

.local_sub lda #$ff
 sta FCharIndex

\* Get y-coord

 lda CharPosn
 cmp #185 ;dead
 beq local_low
 cmp #177 ;impaled
 beq local_imp
 cmp #106
 bcc label_80
 cmp #111 ;crouching
 bcc local_low
.label_80 cmp #178 ;halved
 beq return_27

 lda #LO(-15)
 ldx CharID
 beq label_3
 lda #LO(-11) ;kid strikes lower than opponent
.label_3 clc
 adc FCharY
 sta FCharY
 jmp label_8

.local_low lda #4
 clc
 adc FCharY
 sta FCharY
 jmp label_8

\* Get x-coord

.local_imp lda #LO(-5)  ; impaled
 bne label_9
.label_8 lda #5
.label_9 jsr addfcharx

\* Get color (kid red, opps blue)

 lda CharID
 beq label_2 ;kid: 0
 lda #1 ;opponents: 1
.label_2
 eor FCharX
 eor FCharFace
 and #1 ;look only at low bits
 bne label_1
 inc FCharX
 bne label_1
 inc FCharX+1
.label_1
 lda #starimage
 sta FCharImage
 lda #startable
 sta FCharTable

 lda #0
 sta FCharCU
 sta FCharCL
 lda #40
 sta FCharCR
 lda #192
 sta FCharCD

 lda #TypeComix
 jmp addcharobj
}
.return_27
 rts

\*-------------------------------
\*
\*  A D D   C H A R   O B J
\*
\*  Add a character to object table
\*
\*  In: FCharVars
\*      A = object type
\*
\*-------------------------------

.ADDCHAROBJ
{
 ldx objX ;# objects already in list
 inx
 cpx #maxobj
IF _DEBUG
 BCC max_ok
 BRK
 .max_ok
ELSE
 bcs return_27 ;list full (shouldn't happen)
ENDIF
 stx objX

 sta objTYP,x

 lda FCharX
 sta XCO
 lda FCharX+1
 sta OFFSET

 txa
 pha
 jsr cvtx ;from 280-res to byte/offset
 pla
 tax

 lda XCO
 sta objX,x
 lda OFFSET
 sta objOFF,x

 lda FCharY
 sta objY,x

 lda FCharCU
 sta objCU,x
 lda FCharCL
 sta objCL,x
 lda FCharCR
 sta objCR,x
 lda FCharCD
 sta objCD,x

 lda FCharImage
 sta objIMG,x

 lda FCharTable
 sta objTAB,x

 lda FCharFace
 sta objFACE,x

 jmp SETOBJINDX
}

\*-------------------------------
\*
\*  S E T  O B J  I N D X
\*
\*  Set object index
\*
\*-------------------------------

.SETOBJINDX
{
 lda FCharIndex
 sta objINDX,x

 cmp #30
 bcs os

 tax

 lda #1
 sta objbuf,x
.os
 rts
}

IF _TODO
*-------------------------------
*
* Text routines
*
* NOTE: These routines bypass normal data structures
* & write directly to hi-res page.
*
* Call at end of DRAWALL to make sure text goes on top
* of everything else.
*
*-------------------------------
*
* Call once before using other text routines
*
*-------------------------------
pretext
 jsr initlay

 lda #bgtable2
 sta TABLE
 lda #>bgtable2
 sta TABLE+1
 rts

*-------------------------------
* Part of "Yellow" copy-protection

SETRECHECK0
 lda #recheck0
 sta locals
 lda #>recheck0
 sta locals+1 ;fall thru (& return A = 0)
ENDIF

\*-------------------------------

.INITLAY
{
\ NOT BEEB
\ lda #3 ;auxmem
\ sta BANK          \\ BANK handled by setcharimg or setbgimg in grafix.asm

 lda #40
 sta RIGHTCUT
 lda #192
 sta BOTCUT ;use full screen
 lda #0
 sta LEFTCUT
 sta TOPCUT
 rts
}

IF _TODO
*-------------------------------
*
* Print character
*
* In: PAGE, XCO/OFFSET, YCO
*     a = ASCII value of character
* Out: XCO/OFFSET (modified)
*
*-------------------------------
prchar
 sec
 sbc #"/" ;"0" = 1
 sta IMAGE

 lda #ora
 sta OPACITY

 jsr lay

 inc XCO
 rts

*-------------------------------
 lst
 ds 1
 usr $a9,17,$00,*-org
 lst off
ENDIF
