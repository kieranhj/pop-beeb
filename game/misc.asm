; misc.asm
; Originally MISC.S
; Miscellaneous game functions

.misc
\org = $f900
\DemoDisk = 0
\ tr on
\ lst off
\*-------------------------------
\ org org

IF _JMP_TABLE=FALSE
.VanishChar jmp VANISHCHAR
.movemusic BRK      ; jmp MOVEMUSIC
.moveauxlc clc
BRK ; bcc MOVEAUXLC ;relocatable
.firstguard jmp FIRSTGUARD
.markmeters jmp MARKMETERS

.potioneffect jmp POTIONEFFECT
.mouserescue jmp MOUSERESCUE
.StabChar jmp STABCHAR
.unholy jmp UNHOLY
.reflection jmp REFLECTION

.MarkKidMeter jmp MARKKIDMETER
.MarkOppMeter jmp MARKOPPMETER
.bonesrise jmp BONESRISE
.decstr jmp DECSTR
.DoSaveGame BRK     ; jmp DOSAVEGAME                    BEEB TODO SAVEGAME

\.LoadLevelX jmp LOADLEVELX         ; moved to master.asm
.checkalert jmp CHECKALERT
.dispversion BRK    ; jmp DISPVERSION
ENDIF

\*-------------------------------
\ lst
\ put eq
\ lst
\ put gameeq
\ lst
\ put seqdata
\ lst
\ put movedata
\ lst
\ put soundnames
\ lst off

\ dum $f0
\misc_Xcount ds 1
\misc_Xend ds 1
\ dend

\*-------------------------------
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

\POPside1 = $a9
\POPside2 = $ad

\FirstSideB = 3

\*-------------------------------
\*
\* Vanish character
\*
\*-------------------------------

.VANISHCHAR
{
 lda #86
 sta CharFace
 lda #0
 sta CharAction
 sta CharLife
 sec
 sbc OppStrength
 sta ChgOppStr
.return
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
 dum locals
]dest ds 2
]source ds 2
]endsourc ds 2
 dend

MOVEMEM sta ]dest+1
 stx ]source+1
 sty ]endsourc+1

 ldy #0
 sty ]dest
 sty ]source
 sty ]endsourc

:loop lda (]source),y
 sta (]dest),y
 iny
 bne :loop

 inc ]source+1
 inc ]dest+1
 lda ]source+1
 cmp ]endsourc+1
 bne :loop
 rts

*-------------------------------
*
* Move 1K of music data from $5000 mainmem to aux l.c.
*
*-------------------------------
MOVEMUSIC
 bit RWBANK1
 bit RWBANK1
 sta RAMRDmain

 lda #$d0
 ldx #$50
 ldy #$54
 jsr MOVEMEM

 sta RAMRDaux
]rts rts

*-------------------------------
*
*  Move $2000.5FFF mainmem to auxiliary language card
*  Also sets interrupt vector ($FFFE.FFFF) in both l.c.'s
*
*  NOTE: This code is loaded into mainmem by MASTER
*  and called while still in mainmem.  Once in aux l.c.
*  this routine is useless!
*
*  Returns control to main l.c. bank 1
*
*-------------------------------
Tmovemem = MOVEMEM-$b000

MOVEAUXLC
 sta ALTZPon
 bit RWBANK2
 bit RWBANK2

 lda #$d0
 ldx #$20
 ldy #$50
 jsr Tmovemem

 bit RWBANK1
 bit RWBANK1

 lda #$d0
 ldx #$50
 ldy #$60
 jsr Tmovemem

* & set VBL interrupts

 lda #vbli ;routine in GRAFIX
 sta $FFFE
 lda #>vbli
 sta $FFFF

 sta ALTZPoff

 lda #vbli
 sta $FFFE
 lda #>vbli
 sta $FFFF ;set in main l.c. too

 rts
ENDIF

\*-------------------------------
\*
\* Player can't run or jump past en-garde guard
\*
\*-------------------------------

.FIRSTGUARD
{
 lda EnemyAlert
 cmp #2
 bcc return_50
 lda CharSword
 bne return_50
 lda OpSword
 beq return_50
 lda OpAction
 cmp #2
 bcs return_50

 lda CharFace
 cmp OpFace
 beq return_50

 jsr getopdist
 cmp #LO(-15)
 bcc return_50

\* Bump off guard

 ldx CharBlockY
 lda FloorY+1,x
 sta CharY
 lda #bump
 jsr jumpseq
 jmp animchar
}
.return_50
 rts

\*-------------------------------
\*
\* Mark strength meters
\*
\*-------------------------------

.Mark3 jsr Mark1 ;mark 3 blocks
 iny
.Mark2 jsr Mark1 ;mark 2 blocks
 iny
.Mark1
{
 lda #4
 sta height
 clc
 lda #REDRAW_FRAMES
 jsr markwipe
 jmp markred
}

.MARKMETERS
{
 jsr MARKKIDMETER
 jmp MARKOPPMETER
}

.MARKKIDMETER
{
 ldy #20
 bne Mark3
}

.MARKOPPMETER
{
 ldy #28
 bne Mark2
 rts
}

\*-------------------------------
\*
\* Potion takes effect
\*
\*-------------------------------
wtlesstimer = 200
vibetimer = 3

.POTIONEFFECT
{
 lda CharID
 bne return_50

 ldx lastpotion
 beq return_50
 bpl notswd

\* Sword (-1)

 lda #1
 sta gotsword
 lda #s_Sword
 ldx #25
 jsr cuesong
 lda #$ff
 sta lightcolor
 lda #3
 sta lightning ;3 white flashes
 rts

\* Recharge meter (1)

.notswd cpx #1
 bne label_2

 lda KidStrength
 cmp MaxKidStr
 beq return ;already at full strength

 lda #$99
 sta lightcolor
 lda #2
 sta lightning ;2 orange flashes
 lda #s_ShortPot
 ldx #25
 jsr cuesong
 lda #1
 sta ChgKidStr
 rts

\* Boost meter (2)

.label_2 cpx #2
 bne label_3
 lda #$99
 sta lightcolor
 lda #5
 sta lightning ;5 orange flashes
 lda #s_Potion
 ldx #25
 jsr cuesong
 jmp boostmeter

\* Weightless (3)

.label_3 cpx #3
 bne label_4
 lda #s_ShortPot
 ldx #25
 jsr cuesong
 lda #wtlesstimer
 sta weightless
 lda #vibetimer
 sta vibes
 rts

\* Upside down (4)

.label_4 cpx #4
 bne label_5
 lda invert
 eor #$ff
 sta invert
 lda #2
 sta redrawflg
 jmp inverty

\* Yecch (5)

.label_5 cpx #5
 bne label_6
 lda #Splat ;yecch
 jsr addsound
 lda #LO(-1)
 sta ChgKidStr
 rts
.label_6
.return
  rts
}

\*-------------------------------
\*
\* Mouse rescues you
\*
\*-------------------------------
.MOUSERESCUE
{
 jsr LoadKid

 lda #24 ;mouse
 sta CharID
 lda #200
 sta CharX
 ldx #0
 stx CharBlockY
 lda FloorY+1,x
 sta CharY
 lda #LO(-1)
 sta CharFace
 sta CharLife
 lda #1
 sta OppStrength

 lda #Mscurry
 jsr jumpseq
 jsr animchar

 jmp SaveShad
}

\*-------------------------------
\*
\* Stab character
\*
\*-------------------------------

.STABCHAR
{
 lda CharLife
 bpl return ;already dead
 lda CharSword
 cmp #2
 bne local_DL ;defenseless
 lda CharID
 cmp #4
 beq local_wounded ;skel has no life points

 lda #1
 jsr decstr
 bne local_wounded

 ldx CharID
 beq local_killed

 ldx CharID
 cpx #4 ;skeleton
 bne local_killed
 lda #0
 sta ChgOppStr ;skel is invincible
.return
 rts

.local_killed jsr getbehind
 cmp #space
 bne local_onground
 jsr getdist ;to EOB
 cmp #4
 bcc local_onground
;if char is killed at edge, knock him off
 sec
 sbc #14
 jsr addcharx
 sta CharX
 inc CharBlockY
 lda #fightfall
 jsr jumpseq
 jmp label_3

.local_onground lda #stabkill
 bne label_2

.local_wounded lda #stabbed
.label_2 jsr jumpseq

.label_1 ldx CharBlockY
 lda FloorY+1,x
 sta CharY
 lda #0
 sta CharYVel

.label_3 lda #Splat
 jsr addsound

 jmp animchar

\* stabbed when defenseless

.local_DL lda #100
 jsr decstr

 lda #stabkill ;dropdead?
 jmp local_killed
}

\*-------------------------------
\*
\* If shadow dies, you die (& vice versa)
\*
\*-------------------------------

.UNHOLY
{
 lda level
 cmp #12
 bne return_54

 lda OpID
 ora CharID
 cmp #1 ;kid & shadow?
 bne return_54

 lda CharLife
 bpl return_54
 lda OpLife
 bmi return_54
;live char, dead opponent
 lda #$ff
 sta lightcolor
 lda #5
 sta lightning
 lda #Splat
 jsr addsound
 lda #100
 jmp decstr
}
.return_54
 rts

\*-------------------------------
\*
\*  R E F L E C T I O N
\*
\*-------------------------------

.REFLECTION
{
 jsr LoadKid
 jsr GetFrameInfo

 lda createshad ;flag set?
 cmp #$ff
 beq CreateShad ;yes--reflection comes to life

 jsr getunderft
 cmp #mirror ;is kid standing before mirror?
  bne return_54 ;no

 jsr getreflect ;get char data for reflection

 lda dmirr ;if kid is on wrong side of mirror,
 bmi return_54 ;don't draw reflection

\*  Draw kid's reflection (as a pseudo-character)

 jsr setupchar

\*  Crop edges

 ldx CharBlockY
 inx
 lda BlockTop,x
 cmp FCharY
 bcs return_54
 sta FCharCU

 lda CharBlockX ;of mirror
 asl A
 asl A;x 4
 clc
 adc #1
 sta FCharCL

 jmp addreflobj ;normal reflection
}

\*-------------------------------
\* Get char data for kid's reflection

.getreflect
{
 lda CharBlockX
 jsr getblockej
 clc
 adc #angle+3 ;fudge factor
 sta mirrx ;mirror x-coord (0-139)

 jsr getdist

 ldx CharFace
 bmi left

 eor #$ff ;facing right--
 clc
 adc #14 ;get dist to back of block

.left sec
 sbc #2 ;another fudge factor
 sta dmirr ;distance from mirror

 lda mirrx
 asl A
 sec
 sbc CharX
 sta CharX ;reflection x-coord

 lda CharFace
 eor #$ff
 sta CharFace

}
.return_55
 rts

\*-------------------------------
\* Bring reflection to life as shadowman

.CreateShad
{
 jsr getreflect ;get char data for reflection

 lda #0
 sta createshad

 lda #1 ;shadman
 sta CharID

 lda #MirrorCrack
 jsr addsound

 jsr SaveShad

 lda MaxKidStr
 sta MaxOppStr
 sta OppStrength
 lda #1
 sta KidStrength
 jmp markmeters
}

\*-------------------------------
\*
\* Bones rise
\*
\*-------------------------------
skelscrn = 1
skelx = 5
skely = 1
skeltrig = 2
skelprog = 2

.BONESRISE
{
 lda level
 cmp #3
 bne return_55

 lda ShadFace
 cmp #86
 bne return_55
 lda VisScrn
 cmp #skelscrn
 bne return_55
 lda exitopen
 beq return_55
 lda KidBlockX
 cmp #skeltrig
 beq trig
 cmp #skeltrig+1
 bne return_55

\* Remove dead skeleton

.trig lda VisScrn
 ldx #skelx
 ldy #skely
 jsr rdblock
 pha
 lda #floor
 sta (BlueType),y
 lda #24
 sta height
 lda #REDRAW_FRAMES
 jsr markred
 jsr markwipe
 iny
 jsr markred
 jsr markwipe
 pla
 cmp #bones
 bne return_55

\* Create live skeleton

 lda VisScrn
 sta CharScrn

 ldx #skely
 stx CharBlockY
 lda FloorY+1,x
 sta CharY

 lda #skelx
 sta CharBlockX
 jsr getblockej
 clc
 adc #angle+7
 sta CharX

 lda #LO(-1) ;left
 sta CharFace

 lda #arise
 jsr jumpseq
 jsr animchar

 lda #skelprog
 sta guardprog

 lda #LO(-1)
 sta CharLife
 lda #3
 sta OppStrength

 lda #0
 sta alertguard
 sta refract
 sta CharXVel
 sta CharYVel

 lda #2
 sta CharSword

 lda #4 ;skeleton
 sta CharID

 jmp SaveShad ;save ShadVars
}

\*-------------------------------
\*
\* Decrease strength by A (non-0)
\*
\* Out: non-0 if char lives, 0 if he dies
\*      ChgStrength
\*
\*-------------------------------

.DECSTR
{
 ldx CharID
 bne local_enemy

 cmp KidStrength
 bcs killkid

 eor #$ff
 clc
 adc #1 ;negate
 sta ChgKidStr
 rts

.local_enemy
 cmp OppStrength
 bcs killopp

 eor #$ff
 clc
 adc #1
 sta ChgOppStr
 rts
}

\*-------------------------------
\* Kill character (or opponent)
\* Return A = 0
\*-------------------------------

.killkid
{
 lda #0
 sec
 sbc KidStrength
 sta ChgKidStr

 lda #0
.return
 rts
}

\*-------------------------------

.killopp
{
 lda #0
 sec
 sbc OppStrength
 sta ChgOppStr

 lda #0
.return
 rts
}

IF _TODO
*-------------------------------
* Save current game to disk
*
* In: SavLevel = level ($ff to erase saved game)
*-------------------------------
DOSAVEGAME
 lda level
 cmp #FirstSideB
 bcs :doit ;must have reached side B
 lda #Splat
 jmp addsound
:doit

* Put data into save-game data area

 lda origstrength
 sta SavStrength

 lda FrameCount
 sta SavTimer
 lda FrameCount+1
 sta SavTimer+1

 lda NextTimeMsg
 sta SavNextMsg

* Write to disk

 jmp savegame
ENDIF

\*-------------------------------
\*
\* In: Kid & Shad data
\* Out: EnemyAlert
\*   2: kid & shad are on same stretch of floor
\*   1: slicer, gaps in floor, or other obstacles, but
\*      line of sight is clear
\*   0: can't see each other
\*
\*-------------------------------
gfightthres = 28*4

.CHECKALERT_safe
{
 lda #0
 sta EnemyAlert
}
.return_49
 rts

.CHECKALERT
{
 lda ShadID
 cmp #24 ;mouse?
 beq return_49
 cmp #1 ;shadowman?
 bne notshad
 lda level
 cmp #12
 bne CHECKALERT_safe;fight shadow only on level 12

.notshad
 lda KidPosn
 beq CHECKALERT_safe
 cmp #219
 bcc local_noclimb
 cmp #229
 bcc CHECKALERT_safe ;on staircase
.local_noclimb
 lda ShadFace
 cmp #86
 beq CHECKALERT_safe

 lda KidLife
 and ShadLife
 bpl CHECKALERT_safe ;one is dead

 lda KidScrn
 cmp ShadScrn
 bne CHECKALERT_safe

 lda KidBlockY
 cmp ShadBlockY
 bne CHECKALERT_safe

 lda #2 ;clear path
 sta EnemyAlert

\* Get range of blocks to scan (misc_Xcount --> misc_Xend)

 lda KidBlockX
 jsr getblockej
 clc
 adc #7 ;middle of block
 sta misc_Xcount

 lda ShadBlockX
 jsr getblockej
 clc
 adc #7
 sta misc_Xend

 IF 0
 lda misc_Xcount
 jsr getblockxp
 ldx #1
 jsr showpage
 lda misc_Xend
 jsr getblockxp
 ldx #2
 jsr showpage
 ENDIF

 lda misc_Xend
 cmp misc_Xcount
 bcs cont
 tax
 lda misc_Xcount
 sta misc_Xend
 stx misc_Xcount

.cont

\* If leftmost block is a slicer, skip it

 lda misc_Xcount
 jsr misc_rdblock
 cmp #slicer
 bne label_1
 lda #14
 clc
 adc misc_Xcount
 sta misc_Xcount

\* If rightmost block is a gate, skip it

.label_1 lda misc_Xend
 jsr misc_rdblock
 cmp #gate
 bne label_20
 lda misc_Xend
 sec
 sbc #14
 sta misc_Xend

.label_20 lda misc_Xend
 cmp misc_Xcount
 bcc return

\* Scan from misc_Xcount to misc_Xend (left to right)

 lda misc_Xcount
.loop cmp misc_Xend
 beq label_9
 bcs return

.label_9 jsr misc_rdblock

 cmp #block
 beq local_safe
 cmp #panelwif
 beq local_safe
 cmp #panelwof
 beq local_safe ;solid barrier blocks view

 cmp #loose
 beq local_view
 cmp #gate
 bne label_2
 lda (BlueSpec),y
 cmp #gfightthres
 bcs local_clear
 bcc local_view

.label_2 cmp #slicer
 beq local_view

 jsr cmpspace
 bne local_clear ;closed gate, slicer, gap in floor, etc.
;are obstacles but don't block view
.local_view lda #1
 sta EnemyAlert

.local_clear lda misc_Xcount
 clc
 adc #14
 sta misc_Xcount
 bne loop
 rts

.local_safe lda #0
 sta EnemyAlert
.return
 rts
}

\*-------------------------------
\* In: A = X-coord
\* Out: rdblock results
\*-------------------------------
.misc_rdblock
{
 jsr getblockxp
 tax
 ldy KidBlockY
 lda KidScrn
 jmp rdblock
}

IF _TODO
*-------------------------------
*
*  Display version # on text page 1 (& wait for keypress)
*
*-------------------------------
DISPVERSION
 lda #" "
 jsr lrcls

 sta RAMWRTmain

 ldx #0
:loop lda textline,x
 cmp #"@"
 beq :done
 sta $400,x ;top line of screen
 inx
 bpl :loop
:done
 lda RAMWRTaux
 sta $c054 ;PAGE2 off
 sta $c051 ;TEXT on

* Wait for keypress

:wloop lda $c000
 bpl :wloop
 sta $c010

 lda $c057 ;HIRES on
 lda $c050 ;TEXT off
 lda PAGE
 bne :1
 lda $c055 ;PAGE2 on
:1
 lda #" "
 jmp lrcls
ENDIF

\*-------------------------------
\ lst
\ ds 1
\ usr $a9,21,$b00,*-org
\ lst off
