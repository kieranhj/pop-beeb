; auto.asm
; Originally AUTO.S
; AI for guards

.auto
\DemoDisk = 0
\org = $5400
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
.AutoCtrl jmp AUTOCTRL
.checkstrike jmp CHECKSTRIKE
.checkstab jmp CHECKSTAB
.AutoPlayback jmp AUTOPLAYBACK
.cutcheck jmp CUTCHECK

.cutguard jmp CUTGUARD
.addguard jmp ADDGUARD
.cut jmp CUT
.demo jmp DEMO
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
\
\ dum $f0
\ztemp ds 1
\prob ds 1
\auto_cutdir ds 1
\auto_ProgStart ds 2
\ dend

\plus1 db -1,1
\minus1 db 1,-1

\* Thresholds for cut to new screen

TopCutEdgePl = ScrnTop+10
TopCutEdgeMi = ScrnTop-16
BotCutEdge = ScrnBottom+24

LeftCutEdge = ScrnLeft-4
RightCutEdge = ScrnRight+4

\*-------------------------------
\* Locations of special objects

flaskscrn = 24
flaskx = 3
flasky = 0

\mirscrn = 4
\mirx = 4
\miry = 0

swordscrn = 15
swordx = 1
swordy = 0

\mousetimer = 150 ;from topctrl

\*-------------------------------
\* Strike/block ranges

strikerange1 = 12
strikerange2 = 29
blockrange1 = 0
blockrange2 = 29 ;from TestStrike

\*-------------------------------
\* Other constants:

swordthres = 90
engardethres = 60
strikethres1 = strikerange1
strikethres2 = strikerange2
blockthres1 = 10
blockthres2 = blockrange2
tooclose = strikethres1
toofar = strikethres2+6 ;min dist at which you can advance safely
offguardthres = 8
jumpthres = 50
runthres = 40
blocktime = 4

\*-------------------------------
\*
\* Fighter params (indexed by guardprog #)
\*
\* strikeprob = probability x255 of striking from ready posn
\* restrikeprob = prob x 255 of restriking after blocking
\* blockprob  = prob x255 of blocking opponent's strike
\* advprob = of advancing to within striking range
\* refractimer = length of refractory period after being hit
\*
\*               0   1   2   3   4   5   6   7   8   9   10  11

.strikeprob
 EQUB 075,100,075,075,075,050,100,220,000,060,040,060
.restrikeprob
 EQUB 000,000,000,005,005,175,020,010,000,255,255,150
.blockprob
 EQUB 000,150,150,200,200,255,200,250,000,255,255,255
.impblockprob
 EQUB 000,075,075,100,100,145,100,250,000,145,255,175
.advprob
 EQUB 255,200,200,200,255,255,200,000,000,255,100,100
.refractimer
 EQUB 020,020,020,020,010,010,010,010,000,010,000,000
.specialcolor
 EQUB 000,000,000,001,000,001,001,000,000,000,000,001
.extrastrength
 EQUB 000,000,000,000,001,000,000,000,000,000,000,000

numprogs = 12

\*-------------------------------
\* Basic guard strength & uniform color (indexed by level #)

.basicstrength
 EQUB 4,3,3,3,3,4,5 ;levels 0-6
 EQUB 4,4,5,5,5,4,6 ;levels 7-13

.basiccolor
 EQUB 1,0,0,0,1,1,1 ;0 = blue, 1 = red
 EQUB 0,0,0,1,1,0,0

shadstrength = 4

\*-------------------------------
\*
\* 10: kid (demo)
\* 11: enemy (demo)
\*
\*-------------------------------
\*
\*  Automatic enemy control routine
\*
\*  In: Char vars reflect position in PRECEDING frame;
\*      Op vars reflect position in UPCOMING frame
\*      guardprog = program #
\*
\*  (Exception: When used by kid fighting in demo, both
\*  Char & Op vars reflect preceding frame.)
\*
\*-------------------------------
.return_45 rts

.AUTOCTRL
{
 jsr DoRelease

 lda CharID
 beq label_5 ;control kid in demo

 lda justblocked
 beq jb0
 dec justblocked

.jb0 lda gdtimer
 beq gt0
 dec gdtimer
.gt0
 lda refract ;refractory period after being hit
 beq label_2
 dec refract
.label_2
 lda CharID
 cmp #24 ;mouse?
 beq label_6
 cmp #4 ;skel?
 beq label_3
 cmp #2 ;guard?
 bcc label_1
 lda level
 cmp #13 ;vizier?
 beq label_4
 jmp GuardProg
.label_1 jmp ShadowProg
.label_3 jmp SkelProg
.label_4 jmp VizierProg
.label_5 jmp KidProg
.label_6 jmp MouseProg
}

\*-------------------------------
\*  M O U S E
\*-------------------------------

.MouseProg
{
 lda CharFace
 cmp #86
 beq return_45
 lda CharAction
 beq label_1 ;already stopped
 lda CharX
 cmp #166
 bcs return_45
 lda #Mleave
 jsr jumpseq
 jmp animchar ;sets CharAction = 0

.label_1 lda CharX
 cmp #200
 bcc return_45
 jmp VanishChar
}

\*-------------------------------
\*  S H A D O W M A N
\*-------------------------------
IF DemoDisk
.ShadowProg
.SkelProg
.VizierProg
 brk

ELSE
.ShadowProg
{
 lda level
 cmp #4
 bne label_0
 jmp ShadLevel4

.label_0 cmp #5
 bne label_1
 jmp ShadLevel5

.label_1 cmp #6
 bne label_2
 jmp ShadLevel6

.label_2 cmp #12
 bne label_3
 jmp FinalShad
.label_3
}
.return_46
 rts

\*-------------------------------
\* Level-specific code for:
\* Level 6 (plunge)
\*-------------------------------

.ShadLevel6
{
 lda CharScrn
 cmp #1
 beq Shad6a
 rts

\* Level 6, screen 1
\* When kid jumps chasm, step on plate

.Shad6a
 lda KidPosn
 cmp #43
 bne return_46
 lda KidX
 cmp #$80
 bcs return_46
 jsr DoPress
 jmp DoFwd ;step fwd
}

\*-------------------------------
\* Level 5 (THIEF)
\*-------------------------------

.ShadLevel5
{
 lda CharScrn
 cmp #flaskscrn
 beq Shad5
.return
 rts

\* Level 5, screen 24
\* When gate opens, steal potion

.Shad5
 lda PlayCount
 bne label_1 ;continue playback

 lda #flaskscrn
 ldx #1 ;x
 ldy #0 ;y
 jsr rdblock ;gate
 lda (BlueSpec),y
 cmp #20
 bcc return
;begin playback
 lda #0
 sta PreRecPtr

.label_1 lda #LO(ShadProg5)
 ldx #HI(ShadProg5)
 jsr AutoPlayback

 lda CharX
 cmp #15
 bcs return
 jmp VanishChar
}

\*-------------------------------
\* Level 4 (mirror)
\*-------------------------------

.ShadLevel4
{
 lda CharScrn
 cmp #4
 bne return_46
 lda CharX
 cmp #80
 bcc local_gone
 jmp DoFwd ;run o.s.
.local_gone jmp VanishChar
}

\*-------------------------------
\* Level 12 (final battle)
\*-------------------------------

.FinalShad
{
\* Screen 15: Jump on top of kid

 lda CharScrn
 cmp #swordscrn
 bne cont
 lda shadowaction
 bne cont ;already did it
 lda OpX
 cmp #150
 bcs local_hold ;hold shad at top until kid arrives

 lda #1
 sta shadowaction
 bne cont

.local_hold lda #LO(shadpos12)
 ldx #HI(shadpos12)
 jmp csps
.return
 rts

\* Continue

.cont lda CharSword
 cmp #2
 bcs local_fight
 lda OpSword
 cmp #2
 bcs local_hostile
 lda offguard
 bne local_face
.local_hostile
 lda EnemyAlert
 cmp #2
 bcc label_2
 jsr getopdist
 cmp #swordthres
 bcs label_2 ;wait until kid gets close

 lda CharPosn
 cmp #15
 bne return
 jmp auto_DoEngarde ;draw on kid

\* turn to face kid

.label_2 jsr getopdist
 bpl return
 jmp DoBack

\* Normal fighting

.local_fight
 lda offguard
 beq label_1 ;has kid put up sword?
 lda refract
 bne label_1 ;yes--wait a moment--
 jmp DoDown ;--then lower your guard

.label_1 jmp EnGarde ;normal fighting

\* Face to face--swords down

.local_face jsr getopdist
 bmi local_merge ;whammo!

 lda EnemyAlert
 cmp #2
 bne local_wait
 lda OpPosn
 cmp #3
 bcc local_wait
 cmp #15
 bcc local_go
 cmp #127
 bcc local_wait
 cmp #133
 bcs local_wait

\* If kid starts moving towards you, reciprocate
\* (Accept startrun & stepfwd)

.local_go jmp DoFwd

\* Kid & shadow reunite

.local_merge
 lda #$ff ;white
 sta lightcolor
 lda #10
 sta lightning

 jsr boostmeter

 lda #s_Rejoin
 ldx #85
 jsr cuesong

 lda #42
 sta mergetimer

 lda #0
 sta CharID
 jsr SaveKid ;shadow turns into kid
 jmp VanishChar
.local_wait

 rts
}

\*-------------------------------
\* S K E L E T O N
\*-------------------------------

.SkelProg
{
 lda #2
 sta CharSword
 jmp GuardProg
}

\*-------------------------------
\* V I Z I E R
\*-------------------------------

.VizierProg
{
 jmp GuardProg
}
ENDIF ;DemoDisk

\*-------------------------------
\* K I D (in demo)
\*-------------------------------

.KidProg
{
 jmp GuardProg
}

\*-------------------------------
\* G U A R D
\*-------------------------------

.GuardProg
{
 lda CharSword
 cmp #2 ;Are you already en garde?
 bcc Alert ;no
 jmp EnGarde ;yes
.return
 rts
}

\*-------------------------------
\*
\* Alert (not en garde)
\*
\*-------------------------------

.Alert
{
 lda KidLife
 bpl return ;kid's dead--relax

\* If kid is behind you, turn to face him

 jsr getopdist
 ldx OpBlockY
 cpx CharBlockY
 bne difflevel
 cmp #LO(-8) ;if kid is right on top of you, go en garde!
 bcs local_eng
.difflevel
 ldx alertguard
 beq ok ;otherwise wait for a sound to alert you
 ldx #0
 stx alertguard
.local_alert
 cmp #128
 bcc local_eng
 cmp #LO(-4)
 bcs ok ;overlapping--stand still
 jmp auto_DoTurn ;turn around

\* If you can see kid, go en garde

.ok cmp #128
 bcs return ;kid is behind you

.local_eng lda EnemyAlert
 beq return

 lda level
 cmp #13
 bne label_1 ;Vizier only: wait for music to finish
 lda SongCue
 bne return

.label_1 jmp auto_DoEngarde
.return
 rts
}

\*-------------------------------
\*
\* En garde
\*
\*-------------------------------

.EnGarde
{
 lda CharPosn
 cmp #166
 beq return
 cmp #150
 bcc return ;wait till you're ready

 lda EnemyAlert
 cmp #2
 bcs ea2
 cmp #1 ;EnemyAlert = 1: Kid is in sight, but a
 beq return ;gap or barrier separates you--stay put

\* Kid is out of sight (EnemyAlert = 0)
\* If kid has "dropped out" of fight, follow him down

 lda droppedout ;flag set by CHECKFLOOR
 beq label_1
 jmp FollowKid

\* else return to alert position

.label_1 lda CharID
 cmp #4
 beq return ;(except skeleton)
 jmp DoDropguard

\* EnemyAlert = 2: Clear stretch of floor to player

\* If kid is stunned, let him recover...

.ea2 jsr getopdist
 bmi norec
 cmp #12
 bcc norec ;unless he's right on top of you
 lda OpPosn
 cmp #102
 bcc norec
 cmp #118
 bcs norec
 lda OpAction
 cmp #5
 beq return
.norec

\* Advance to closest safe distance

 jsr getopdist
 cmp #toofar
 bcs outofrange

 ldx CharSword
 cpx #2
 bcc offg

 cmp #tooclose
 bcc local_tooclose
 jmp InRange

.offg cmp #offguardthres
 bcc local_tooclose
 jmp InRange
.return
 rts

\* Out of range

.outofrange
 lda refract
 bne return

 lda CharFace
 cmp OpFace
 beq local_nojump ;chase him

 lda OpPosn
 cmp #7
 bcc local_norun
 cmp #15
 bcc local_runwait
.local_norun
 cmp #34
 bcc local_nojump
 cmp #44
 bcc local_jumpwait ;If kid is running towards you, stay put
.local_nojump
 jsr getinfront
 jsr cmpspace ;Don't advance unless solid floor
 beq local_gap
 jsr get2infront
 jsr cmpspace
 bne local_solid

.local_gap jmp auto_DoRetreat
.local_solid jmp auto_DoAdvance

\* Kid is trying to get past you--cut him down!

.local_jumpwait
 jsr getopdist
 cmp #jumpthres
 bcs return ;wait
 jmp auto_DoStrike

.local_runwait
 jsr getopdist
 cmp #runthres
 bcs return
.local_strike jmp auto_DoStrike

\* Too close to hit him

.local_tooclose
 lda CharFace
 cmp OpFace
 beq ret
 jmp auto_DoAdvance
.ret
 jmp auto_DoRetreat
}

\*-------------------------------
\*
\*  Kid has "dropped out" of fight
\*  Advance until you run out of floor--
\*  then decide whether to jump down after him
\*
\*-------------------------------

.FollowKid
{
 lda OpAction
 cmp #2
 beq local_hanging
 cmp #6
 beq local_hanging ;wait--kid is hanging on ledge

 jsr getinfront
 sta ztemp
 jsr cmpbarr
 bne local_stopped
 lda ztemp
 jsr cmpspace
 beq local_atedge
 jmp auto_DoAdvance

\* At edge of floor.  Follow kid down ONLY if:
\* (1) it's a 1-story drop to solid floor
\* (2) kid is still down there

.local_atedge
 jsr getinfront
 inc tempblocky
 jsr rdblock1
 sta ztemp ;is it safe?
 cmp #spikes
 beq local_stopped
 cmp #loose
 beq local_stopped
 jsr cmpbarr
 bne local_stopped
 lda ztemp
 jsr cmpspace
 beq local_stopped

 lda CharBlockY
 clc
 adc #1
 cmp OpBlockY
 bne local_stopped ;kid's not down there

\* It looks safe--follow him down

 jmp auto_DoAdvance

.local_stopped lda #0
 sta droppedout
 jmp auto_DoRetreat ;so you can kill him if he climbs up
.local_hanging
}
.return_47
 rts

\*-------------------------------
\*
\*  In range
\*
\*-------------------------------

.InRange
{
 lda OpSword ;is opponent armed & en garde?
 cmp #2
 beq local_fight ;yes

\* Opponent is unarmed or off guard--maul him!

 lda refract
 bne return_47

 jsr getopdist
 cmp #strikethres2
 bcc label_1
 jmp auto_DoAdvance ;advance until within range...
.label_1 jmp auto_DoStrike ;then strike

\* Opponent is en garde--use strategy

.local_fight
 jmp GenFight
}

\*-------------------------------
\*
\* General Fighting Routine
\*
\* (Fighters are en garde, face to face, and too close to
\* advance safely)
\*
\*-------------------------------

.GenFight
{
 jsr getopdist
 cmp #blockthres1
 bcc local_outofrange
 cmp #blockthres2
 bcs local_outofrange

 jsr MaybeBlock ;block opponent's strike?

 lda refract
 bne return

 jsr getopdist
 cmp #strikethres1
 bcc local_outofrange
 cmp #strikethres2
 bcs local_outofrange

 jmp MaybeStrike ;strike?

.local_outofrange
 jmp MaybeAdvance ;advance to within strike range?
.return
 rts
}

\*-------------------------------
\*
\* Advance to within strike range?
\* (Only consider it if gdtimer = 0)
\*
\*-------------------------------

.MaybeAdvance
{
 lda guardprog
 beq local_dumb ;Guard #0 is too dumb to care
 lda gdtimer
 bne return_47

.local_dumb jsr rndp
 cmp advprob,x
 bcs return_47

 jmp auto_DoAdvance
}

\*-------------------------------
\*
\* Block opponent's strike?
\*
\*-------------------------------

.MaybeBlock
{
 lda OpPosn
 cmp #152 ;guy4
 beq label_99
 cmp #153 ;guy5
 beq label_99
 cmp #162 ;guy22 (block to strike)
 bne return_48

.label_99 lda justblocked
 bne MaybeBlock_impaired
 jsr rndp
 cmp blockprob,x
 bcc MaybeBlock_block
}
.return_48
 rts

.MaybeBlock_impaired
{
 jsr rndp
 cmp impblockprob,x
 bcs return_48
}
.MaybeBlock_block
{
 jmp auto_DoBlock
}

\*-------------------------------
\*
\* Strike?
\*
\*-------------------------------

.MaybeStrike
{
 ldx OpPosn
 cpx #169
 beq return_48
 cpx #151 ;opponent starting to strike?
 beq return_48 ;yes--don't strike

 ldx CharPosn
 cpx #161 ;have I just blocked?
 beq local_restrike
 cpx #150
 beq local_restrike ;yes--restrike?

 jsr rndp
 cmp strikeprob,x
 bcs return_48
 jmp auto_DoStrike

.local_restrike
 jsr rndp
 cmp restrikeprob,x
 bcs return_48
 jmp auto_DoStrike
}

\*-------------------------------

.DoRelease
{
 lda #0
 sta clrF
 sta clrB
 sta clrU
 sta clrD
 sta clrbtn
 sta JSTKX
 sta JSTKY
 sta btn
 rts
}

.auto_DoAdvance
.DoFwd
{
 lda #LO(-1)
 sta clrF
 sta JSTKX
 rts
}

.auto_DoRetreat
.DoBack
{
 lda #LO(-1)
 sta clrB
 lda #1
 sta JSTKX
 rts
}

.auto_DoBlock
.DoUp
{
 lda #LO(-1)
 sta clrU
 sta JSTKY
 rts
}

.auto_DoTurn
.DoDown
{
 lda #LO(-1)
 sta clrD
 lda #1
 sta JSTKY
 rts
}

.DoStandup
{
 lda #LO(-1)
 sta clrU
 jmp DoBack
}

.DoDropguard
.DoRunaway
{
 lda #LO(-1)
 sta clrD
 jmp DoBack
}

.auto_DoEngarde
{
 lda #LO(-1)
 sta clrD
 jmp DoFwd
}

.auto_DoStrike
.DoPress
{
 lda #LO(-1)
 sta clrbtn
 sta btn
 rts
}

.DoRelBtn
{
 lda #0
 sta btn
.return
 rts
}

\*-------------------------------
\*
\*  R N D P
\*
\*  Return X = guardprog, A = rnd #
\*
\*-------------------------------

.rndp
{
 ldx guardprog
 jmp rnd
}

\*-------------------------------
\*
\*  C H E C K   S T R I K E
\*
\*  Check for sword contact
\*
\*  Going in: Kid & Shad vars represent position in
\*   UPCOMING frame
\*
\*  Out: Kid & Shad vars
\*  (Return Action = 99 if stabbed)
\*
\*-------------------------------

.CHECKSTRIKE
{
 lda KidPosn
 beq return
 cmp #219
 bcc local_noclimb
 cmp #229
 bcc return ;on staircase
.local_noclimb
 jsr LoadShadwOp
 jsr TestStrike
 jsr SaveShadwOp

 jsr LoadKidwOp
 jsr TestStrike
 jsr SaveKidwOp

.return
 rts
}

\*-------------------------------

.TestStrike
{
 lda CharSword
 cmp #2 ;in fighting mode?
 bne return ;no

 lda CharBlockY
 cmp OpBlockY
 bne return

\* Am I on a test (strike) frame?

 lda CharPosn
 cmp #153 ;guy5 (frame before full ext.)
 beq local_test
 cmp #154 ;guy6 (full ext.)
 bne return

\* I'm striking--is opponent blocking?

.local_test
 jsr getopdist
 cmp #blockrange1
 bcc local_nobloc

 cmp #blockrange2
 bcs local_nobloc

 lda OpPosn
 cmp #161
 beq label_11
 cmp #150 ;blocking?
 bne  local_nobloc ;no

\* Yes -- opponent blocks my strike

.label_1 lda #161
 sta OpPosn ;change opp to "successful block"

.label_11 lda CharID
 beq label_12 ;am I a guard?
 lda #blocktime ;yes--impair my blocking ability for a while
 sta justblocked

.label_12 lda #blockedstrike
 jsr jumpseq
 jmp animchar

\* Skewer opponent?

.local_nobloc
 lda CharPosn
 cmp #154 ;full ext
 bne return

 jsr getopdist

 ldx OpSword
 cpx #2
 bcs local_ong
 cmp #offguardthres
 bcs cont1
 rts
.local_ong cmp #strikerange1
 bcc return

.cont1 cmp #strikerange2
 bcs return

 lda #99 ;"stabbed"
 sta OpAction
.return
 rts
}

\*-------------------------------
\*  C H E C K   S T A B
\*-------------------------------

.CHECKSTAB
{
 lda ShadAction
 cmp #99
 bne label_1

 lda KidAction
 cmp #99
 beq doublestab
.label_2
 jsr LoadShad
 jsr StabChar
 jsr SaveShad

 jsr rndp
 lda refractimer,x
 sta refract

.label_1 lda KidAction
 cmp #99
 bne return

 jsr LoadKid
 jsr StabChar
 jmp SaveKid

\* Both chars finish lunge simultaneously

.doublestab
 lda #1
 sta KidAction
 bne label_2 ;player wins a tie
.return
 rts
}

\*-------------------------------
\* Change shadowman posn
\* In: A-X = shadpos L-H
\* Out: Char data
\*-------------------------------

.chgshadposn
{
 sta ztemp
 stx ztemp+1
 ldy #6
.loop lda (ztemp),y
 sta Char,y
 dey
 bpl loop

 ldy #7
 lda (ztemp),y
 jsr jumpseq

 lda #1
 sta CharID

 lda #0
 sta PlayCount ;zero playback counter
 rts
}
\* ... & save

.csps
{
 jsr chgshadposn

 lda #3
 sta guardprog

 lda #shadstrength
 sta MaxOppStr
 sta OppStrength

 jmp SaveShad
}

\*-------------------------------
\* (Posn, X, Y, Face, BlockX, BlockY, Action)
\*               0  1  2  3  4  5  6

.shadpos6a EQUB $0f,$51,$76,$00,$00,$01,$00
 EQUB stand

.shadpos5 EQUB $0f,$37,$37,$00,$ff,$00,$00
 EQUB stand ;just o.s. to L

.shadpos12 EQUB $0f,$51,$f0,$00,$00,$00,$00
 EQUB stepfall

\*-------------------------------
EndProg = -2
EndDemo = -1
Ctr = 0
Fwd = 1
Back = 2
Up = 3
Down = 4
Upfwd = 5
Press = 6
Release = 7

\* Commands:
\*
\* -2 - end of programmed sequence
\* -1 - end of demo
\*  0 - center jstk & release btn
\*  1 - jstk fwd
\*  2 - jstk back
\*  3 - jstk up
\*  4 - jstk down
\*  5 - jstk up & fwd
\*  6 - press & hold btn
\*  7 - release btn

\*-------------------------------
\*
\* Prerecorded sequence format:
\*
\*  1.  Frame # (1 byte)
\*  2.  Command (1 byte)
\*
\* 255 frames = approx. 25-30 seconds
\*
\*-------------------------------
\* Level 5 (THIEF): Steal potion

.ShadProg5
 EQUB 0,Ctr
 EQUB 1,Fwd
 EQUB 14,Ctr
 EQUB 18,Press
 EQUB 29,Release
 EQUB 45,Back
 EQUB 49,Fwd
 EQUB 255,EndProg

\*-------------------------------
\*
\*  Play back prerecorded movement sequence
\*
\*  In: A-X = program start addr
\*      PlayCount = frame #
\*      PreRecPtr = pointer to next command
\*
\*-------------------------------

.AUTOPLAYBACK
{
 sta auto_ProgStart
 stx auto_ProgStart+1

\* Inc frame counter

 lda PlayCount
 cmp #254
 bcs return
 inc PlayCount

\* Look up time of next command

 ldy PreRecPtr

 lda PlayCount
 cmp (auto_ProgStart),y
 bcs next

\* Not there yet--repeat last command

 dey
 lda (auto_ProgStart),y
 jmp ex

\* We're there--

.next iny
 lda (auto_ProgStart),y ;command
 iny
 sty PreRecPtr

\* Execute command

.ex cmp #LO(-1)
 beq enddemo
 cmp #0
 beq local_ctr
 cmp #1
 beq local_fwd
 cmp #2
 beq local_back
 cmp #3
 beq local_up
 cmp #4
 beq local_down
 cmp #5
 beq local_upfwd
 cmp #6
 beq local_press
 cmp #7
 beq local_release

.return
 rts

\* Commands

.local_ctr jmp DoRelease
.local_fwd jmp DoFwd
.local_back jmp DoBack
.local_up jmp DoUp
.local_down jmp DoDown
.local_upfwd jsr DoUp
 jmp DoFwd
.local_press jmp DoPress
.local_release jmp DoRelBtn

.enddemo ; lda autopilot
; bne :endpb
 jmp attractmode ;Game: end demo
.endpb ; lda #0 ;Editor: end playback
; sta autopilot
; rts
}

\*-------------------------------
\*
\*  C U T   C H E C K
\*
\*  Cut with kid
\*
\*-------------------------------

.CUTCHECK
{
 lda CUTTIMER
 beq ok

 dec CUTTIMER
.return
 rts

.ok
 jsr LoadKid
 jsr setupchar
 jsr getedges
 jsr cutchar ;cut with character
 bmi return ;no cut
 sta auto_cutdir

 jsr SaveKid

 lda CharScrn
 sta cutscrn

 lda ShadFace
 cmp #86 ;is there a guard on old screen?
 beq return ;no

\* What to do with guard?  Two choices:
\*
\*  (1) UPDATE -- leave guard behind on old screen (& update
\*      his coords so he'll still be there when we come back)
\*  (2) TRANSFER -- transfer guard to new screen (& delete his
\*      coords from old screen)

 lda ShadLife
 bpl update ;dead guard on old screen--leave him behind

 lda ShadSword
 cmp #2
 bne update

\* Is there a live guard on new screen?

 ldx KidScrn
 lda GdStartBlock-1,x
 cmp #30
 bcs nonew ;no

 lda GdStartSeqH-1,x
 beq update ;yes

\* If guard is too far o.s., leave him behind

.nonew
 lda auto_cutdir
 beq local_left
 cmp #1
 beq local_right
 cmp #2
 beq local_up

.local_down lda ShadBlockY
 cmp #3
 bcs transfer
 bcc update

.local_up lda ShadBlockY
 bmi transfer
 bpl update

.local_right lda ShadX
 cmp #ScrnWidth+25 ;25 is safety factor
 bcc update
 bcs transfer

.local_left lda ShadX
 cmp #256-ScrnWidth-25
 bcs update

\* Take him with us

.transfer jmp transferguard

\* Leave him behind

.update jmp updateguard 
}

\*-------------------------------
\*
\* Transfer guard from old screen to new screen
\* (Also remove any dead guards from new scrn)
\*
\*-------------------------------

.transferguard
{
 lda #LO(-1)
 ldx KidScrn ;new scrn
 sta GdStartBlock-1,x
 ldx ShadScrn ;old scrn
 sta GdStartBlock-1,x

 jsr LoadShad

 lda auto_cutdir
 jsr cut

 jmp SaveShad

 rts
}

\*-------------------------------
\*
\* Leaving guard behind on old screen--
\* update guard coords
\*
\*-------------------------------

.updateguard
{
 lda ShadFace
 cmp #86
 beq return ;no guard
 lda ShadID
 cmp #1
 beq return ;not for shadman
 cmp #24
 beq return ;or mouse
.gd
 lda #0 ;arbitrary--ADDGUARD will reconstruct
 sta tempblockx ;CharBlockX from CharX
 lda ShadBlockY
 sta tempblocky
 jsr indexblock
 tya
 ldx ShadScrn
 sta GdStartBlock-1,x

 lda ShadX
 sta GdStartX-1,x

 lda ShadFace
 sta GdStartFace-1,x

 lda guardprog
 sta GdStartProg-1,x

 lda ShadLife
 bpl ok
 lda #0
 sta GdStartSeqH-1,x
 beq cont

.ok lda ShadSeq
 sta GdStartSeqL-1,x
 lda ShadSeq+1
 sta GdStartSeqH-1,x

\* and deactivate enemy char

.cont lda #86
 sta ShadFace

 lda #0
 sta OppStrength
.return
 rts
}

\*-------------------------------
\*
\* If enemy has fallen to screen below, catch him before
\* he wraps around to top of VisScrn
\*
\*-------------------------------

.CUTGUARD
{
 lda ShadFace
 cmp #86
 beq return

 lda ShadY
 cmp #BotCutEdge
 bcc return

\* If guard, remove him altogether

 lda ShadID
 cmp #4
 beq local_skel
 cmp #1
 beq local_shad

.CUTGUARD_RemoveGd
 jsr deadenemy ;music, etc.

 ldx VisScrn
 lda #LO(-1)
 sta GdStartBlock-1,x
 lda #86
 sta ShadFace
 lda #0
 sta OppStrength
 lda #LO(-1)
 sta ChgOppStr
.return
 rts

\* If shad, vanish him

.local_shad lda ShadAction
 cmp #4
 bne return
 jsr LoadShad
 jsr VanishChar
 jmp SaveShad

\* If skel, change scrn

.local_skel lda ShadScrn
 jsr getdown
 sta ShadScrn
 cmp #3
 bne CUTGUARD_RemoveGd

\* Skel lands on scrn 3

 lda #Splat
 jsr addsound
 lda #$85
 sta ShadX
 lda #1
 sta ShadBlockY
 lda #0
 sta ShadFace
 lda #LO(-1)
 sta ShadLife
 jmp updateguard
}

\*-------------------------------
\*
\*  C U T   C H A R
\*
\*  Is character passing o.s.?  If so, cut with him to next scrn
\*
\*  Change CharX,Y,BlockY,Scrn to reflect posn on new scrn
\*
\*  Return A = direction of cut, -1 if no cut
\*
\*-------------------------------

.cutchar
{
 lda CharY

 ldx CharAction
 cpx #5
 beq notup
 cpx #4
 beq notup ;In freefall--cut only down
 cpx #3
 beq notup

\*  Cut up/down?

 cmp #TopCutEdgePl
 bcc CUTUP

 cmp #LO(TopCutEdgeMi)
 bcs CUTUP
.notup
 cmp #BotCutEdge
 bcs CUTDOWN

\*  Cut left/right?

 ldx CharPosn
 cpx #135
 bcc nocu
 cpx #150
 bcc nocut ;don't cut L/R on climbup
.nocu cpx #110
 bcc nosu
 cpx #120
 bcc nocut ;or on standup
.nosu cpx #150
 bcc nost
 cpx #163
 bcc nocut
 cpx #166
 bcc nost
 cpx #169
 bcc nocut ;or on strike/block
.nost lda CharAction
 cmp #7
 beq nocut ;or on turning

 ldx CharFace ;-1=left, 0=right
 beq faceR
;facing left
 lda leftej
 cmp #LeftCutEdge
 bcc CUTLEFT
 beq CUTLEFT

 cmp #ScrnRight+1
 bcs CUTRIGHT
 bcc nocut

.faceR
 lda CharScrn
 ldx #9
 ldy CharBlockY
 jsr rdblock

 cmp #panelwif
 beq nocutr
 cmp #panelwof
 beq nocutr ;don't cut R if a panel blocks view

 lda rightej
 cmp #RightCutEdge
 bcs CUTRIGHT

.nocutr lda rightej
 cmp #ScrnLeft-1
 bcc CUTLEFT
 beq CUTLEFT

.nocut lda #LO(-1)
 rts

\ BEEB TEMP comment out SOUND
.CUTLEFT ;jsr mirrmusic
 jsr milestone3
 lda #0
 bpl local_cut

.CUTRIGHT jsr stealsword
\ BEEB TEMP comment out SOUND
; jsr jaffmusic
 lda #1
 bpl local_cut

.CUTUP lda #2
 bpl local_cut

\* Level 6 ("Plunge"): Kid falls off screen 1 into next level

.CUTDOWN
 jsr infinity

 lda level
 cmp #6
 bne no6
 lda CharScrn
 cmp #1
 beq nocut
.no6
 lda #3
.local_cut pha
 jsr cut
 pla
.return
 rts
}

\*-------------------------------
\* Level 12--fall off into infinity
\*-------------------------------
.infinity
 rts

\*-------------------------------
\* Passed Level 3 milestone?
\*-------------------------------

.milestone3
{
 lda level
 cmp #3
 bne return
 lda #7 ;scrn to R of gate
.mcheck cmp CharScrn
 bne return
 lda #1
 sta milestone
 lda MaxKidStr
 sta origstrength
.return
 rts
}

\*-------------------------------
\* Level 12: Shadow steals sword
\*-------------------------------

.stealsword
{
 lda level
 cmp #12
 bne return
 lda CharScrn
 cmp #18 ;scrn below swordscrn
 bne return
 lda #swordscrn
 ldx #swordx
 ldy #swordy
 jsr rdblock
 lda #floor
 sta (BlueType),y
.return
 rts
}

IF _TODO    ; MUSIC
*-------------------------------
* Level 13: Play Jaffar's Theme
*-------------------------------
jaffmusic
 lda level
 cmp #13
 bne return
 lda exitopen
 bne return
 lda CharScrn
 cmp #3
 bne return
 lda #s_Jaffar
 ldx #25
 jmp cuesong

*-------------------------------
* Level 4 ("Mirror"): Play danger theme for mirror
*-------------------------------
mirrmusic
 lda exitopen
 beq :no4
 cmp #77
 beq :no4
 lda level
 cmp #4
 bne :no4
 lda CharBlockY
 cmp #miry
 bne :no4
 lda CharScrn
 cmp #11 ;scrn to R of mirscrn
 bne :no4
 lda #s_Danger
 ldx #50
 jsr cuesong
 lda #77
 sta exitopen ;so we don't repeat theme
:no4
return rts
ENDIF

\*-------------------------------
\*
\*  C U T
\*
\*  Move char from CharScrn to adjacent screen
\*
\*  In: A = cut dir: 0 = left, 1 = right, 2 = up, 3 = down
\*
\*-------------------------------

.CUT
{
 cmp #3
 beq Cdown
 cmp #1
 beq Cright
 cmp #2
 beq Cup

.Cleft
 lda CharScrn
 jsr getleft ;get new screen #
 sta CharScrn

 lda #140
 clc
 adc CharX
 sta CharX

 ldx #1 ;new FromDir
 rts

.Cright
 lda CharScrn
 jsr getright
 sta CharScrn

 lda CharX
 sec
 sbc #140
 sta CharX

 ldx #0
 rts

.Cup
 lda CharScrn
 jsr getup
 sta CharScrn

 lda CharBlockY
 clc
 adc #3
 sta CharBlockY

 lda CharY
 clc
 adc #189
 sta CharY

 ldx #3
 rts

.Cdown
 lda CharScrn
 jsr getdown
 sta CharScrn

 lda CharBlockY
 sec
 sbc #3
 sta CharBlockY

 lda CharY
 sec
 sbc #189
 sta CharY

 ldx #2
.return
 rts
}

\*-------------------------------
\*
\* A D D  G U A R D
\*
\* On cut to new screen--if guard is there, bring him to life
\* Also handles hard-wired shadowman appearances
\*
\* In: VisScrn
\*
\*-------------------------------

.ADDGUARD
{
 lda #0
 sta offguard

\* Level 12

 lda level
 cmp #12
 bne not12
 lda exitopen ;set when shadow drops
 bne return_44
 lda mergetimer
 bne label_1 ;shadow has been reabsorbed
 lda VisScrn
 cmp #swordscrn
.label_1 bne return_44
 sta CharScrn

 ldx #swordx
 ldy #swordy
 jsr rdblock
 cmp #sword
 beq return_44 ;sword is still there
 lda #0
 sta shadowaction
 lda #1
 sta exitopen
 lda #LO(shadpos12)
 ldx #HI(shadpos12)
 jmp csps

\* Level 6 (Plunge)

.not12
 lda level
 cmp #6 ;plunge
 bne not6

 lda VisScrn
 sta CharScrn
 cmp #1
 bne AddNormalGd

 lda exitopen
 cmp #77
 beq norepeat
 lda #s_Danger
 ldx #50
 jsr cuesong
 lda #77
 sta exitopen
.norepeat
 lda #LO(shadpos6a)
 ldx #HI(shadpos6a)
 jmp csps

\* Level 5 (Thief)

.not6 lda level
 cmp #5 ;thief
 bne not5

 lda VisScrn
 sta CharScrn
 cmp #flaskscrn
 bne AddNormalGd

 ldx #flaskx
 ldy #flasky
 jsr rdblock
 cmp #flask
 bne return_44 ;potion is gone

 lda #LO(shadpos5)
 ldx #HI(shadpos5)
 jmp csps
}
.return_44
 rts
.not5

\*-------------------------------

.AddNormalGd
{
 ldx VisScrn
 lda GdStartBlock-1,x
 cmp #30
 bcs return_44 ;no guard on this scrn

\* Bring guard to life (or death)

 stx CharScrn

 jsr unindex ;return A = blockx, X = blocky
 stx CharBlockY

 lda FloorY+1,x
 sta CharY

 ldx VisScrn
 lda GdStartX-1,x
 sta CharX
 jsr getblockxp
 sta CharBlockX

 ldx VisScrn
 lda GdStartFace-1,x
 sta CharFace

 lda level
 cmp #3
 bne label_3

 lda #4 ;skel
 bne label_4
.label_3 lda #2 ;guard
.label_4 sta CharID

 lda GdStartSeqH-1,x
 bne label_1 ;0 is code for fresh start

 lda CharID
 cmp #4
 bne label_5
 lda #2
 sta CharSword
 lda #landengarde ;skel (ready)
 bne label_6
.label_5 lda #0
 sta CharSword
 lda #alertstand ;guard
.label_6 jsr jumpseq
 jmp label_2

.label_1 sta CharSeq+1
 lda GdStartSeqL-1,x
 sta CharSeq

.label_2 jsr animchar

 lda CharPosn
 cmp #185 ;killed
 beq local_dead
 cmp #177 ;impaled
 beq local_dead
 cmp #178 ;halved
 beq local_dead

\* Live guard

 lda #LO(-1)
 sta CharLife

 lda #0
 sta alertguard
 sta refract
 sta justblocked

 jsr getgdstrength
 jmp cont

\* Dead guard

.local_dead lda #1
 sta CharLife
 lda #0
 sta OppStrength

\* Continue

.cont lda #0
 sta CharXVel
 sta CharYVel
 lda #1
 sta CharAction

 ldx VisScrn
 lda GdStartProg-1,x
 cmp #numprogs
 bcc ok
 lda #3 ;default
.ok sta guardprog

 ldx level
 lda basiccolor,x
 ldx guardprog
 eor specialcolor,x ;0 = normal, 1 = special
 sta GuardColor  ;0 = blue, 1 = red

 jmp SaveShad ;save ShadVars
}

\*-------------------------------
\* Get guard fighting strength
\*-------------------------------

.getgdstrength
{
 ldx level
 lda basicstrength,x
 ldx guardprog
 clc
 adc extrastrength,x
 sta MaxOppStr
 sta OppStrength
.return
 rts
}

\*-------------------------------
\ lst
\ ds 1
\ usr $a9,17,$800,*-org
\ lst off

\\ Moved from subs.asm as needs to be in same RAM bank

\*-------------------------------
\* Demo commands
\*-------------------------------

\ All defined in auto.asm
\EndProg = -2
\EndDemo = -1
\Ctr = 0
\Fwd = 1
\Back = 2
\Up = 3
\Down = 4
\Upfwd = 5
\Press = 6
\Release = 7

\*-------------------------------

.DemoProg1 ;up to fight w/1st guard
 EQUB 0,Ctr
 EQUB 1,Fwd
 EQUB 12,Ctr
 EQUB 30,Fwd ;start running...
 EQUB 37,Upfwd ;jump 1st pit
 EQUB 47,Ctr
 EQUB 48,Fwd ;& keep running
d1 = 66                         \\ BEEB stop one frame later?!
 EQUB d1,Ctr ;stop
 EQUB d1+8,Back ;look back...
 EQUB d1+10,Ctr
 EQUB d1+34,Back
 EQUB d1+35,Ctr
d2 = 115
 EQUB d2,Upfwd ;jump 2nd pit
 EQUB d2+13,Press ;& grab ledge
 EQUB d2+21,Up
 EQUB d2+42,Release
 EQUB d2+43,Ctr
 EQUB d2+44,Fwd
 EQUB d2+58,Down
 EQUB d2+62,Ctr
 EQUB d2+63,Fwd
 EQUB d2+73,Ctr
d3 = 193
 EQUB d3,Fwd
 EQUB d3+12,Ctr
 EQUB d3+40,EndDemo

\*-------------------------------
\*
\*  D  E  M  O
\*
\*  Controls kid's movements during self-running demo
\*
\*  (Called from PLAYERCTRL)
\*
\*-------------------------------

.DEMO
{
 lda #LO(DemoProg1)
 ldx #HI(DemoProg1)
 jmp AutoPlayback
}
