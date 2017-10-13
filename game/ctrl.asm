; ctrl.asm
; Originally CTRL.S
; Player character control

.ctrl
\org = $3a00
\ tr on
\ lst off
\*-------------------------------
\ org org

.PlayerCtrl jmp PLAYERCTRL
.checkfloor jmp CHECKFLOOR
.ShadCtrl jmp SHADCTRL
.rereadblocks jmp REREADBLOCKS
.checkpress jmp CHECKPRESS

.DoImpale jmp DOIMPALE
.GenCtrl jmp GENCTRL
.checkimpale jmp CHECKIMPALE

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
\jxtemp ds 1
\jytemp ds 1
\jbtemp ds 1
\atemp ds 1
\ dend

\*-------------------------------
\*  Misc. changeable parameters

DeathVelocity = 33
OofVelocity = 22

grabreach = -8
grabspeed = 32 ;max Y-vel to grab ledge
grablead = 25 ;increase to grab ledge earlier
stuntime = 12

jumpupreach = 0
jumpupangle = -6

JumpBackThres = 6
StepOffFwd = 3
StepOffBack = 8

\swordthres = 90 ;to go en garde (facing fwd)
swordthresN = -10 ;" " (behind you)
blockthres = 32
graceperiod = 9
gdpatience = 15

gclimbthres = 6

stairthres = 30

\*-------------------------------
\*
\*  If he's passed thru floor plane, change CharBlockY
\*  If floor is solid, stop him
\*
\*-------------------------------

.falling
{
 lda CharY

 ldx CharBlockY
 inx
 cmp FloorY,x
 bcs label_1

 jmp fallon ;Hasn't reached floor yet

\* Character is passing thru floor plane

.label_1 jsr getunderft ;Check if there's
 ;solid floor underfoot
 cmp #block
 bne label_2 ;Solid block is special case--
 jsr InsideBlock ;reset him to either side of block

.label_2 jsr cmpspace
 bne hitflr

 inc CharBlockY ;Fall thru floor plane

.return
 rts
}

\*-------------------------------
\*
\*  C H E C K  F L O O R
\*
\*-------------------------------

.CHECKFLOOR
{
 lda CharAction
 cmp #6 ;hanging?
 beq return

 cmp #5 ;bumped?
 bne label_2
 lda CharPosn
 cmp #109 ;crouched (e.g. on loose floor)
 beq ong
 cmp #185 ;dead
 bne return
.ong jmp onground

.label_2 cmp #4 ;freefall
 beq falling
 cmp #3
 bne label_1
 lda CharPosn
 cmp #102
 bcc return
 cmp #106
 bcs return
 jmp fallon

.label_1 cmp #2 ;hanging
 beq return
 jmp onground ;7, 0, or 1: on the ground

.return
 RTS
}

\*-------------------------------
\*
\*  Floor stops him -- Choose appropriate landing
\*
\*-------------------------------

.hitflr
{
 ldx CharBlockY
 inx
 lda FloorY,x
 sta CharY ;align char w/floor

 jsr getunderft
 cmp #spikes
 beq hitspikes

\* Has he landed too close to edge?

 jsr getinfront
 jsr cmpspace
 bne cont ;no

 jsr getdist ;# pixels to edge
 cmp #4 ;was 2
 bcs cont
;Yes--move him back a little
 lda #LO(-3)
 jsr addcharx
 sta CharX

.cont jsr addslicers ;trigger slicers on this level

 lda CharLife
 bpl local_hardland ;dead before he hits the ground

 jsr getdist
 cmp #12
 bcc nc
 jsr getbehind
 cmp #spikes
 beq hitspikes ;check block behind if dist>=12

.nc jsr getunderft ;what has he landed on?
 cmp #spikes
 bne notspikes

.hitspikes
 jsr getspikes ;are spikes lethal?
 bne local_impale ;yes

.notspikes
 lda CharYVel
 cmp #OofVelocity
 bcc local_softland

 cmp #DeathVelocity
 bcc local_medland

.local_hardland
 lda #100
 jsr decstr
.hdland1
 lda #Splat
 jsr addsound

 lda #hardland
 bne doland

.local_medland
 lda CharID
 cmp #1
 beq local_softland ;shad lands easy
 cmp #2
 bcs local_hardland ;guards can't survive 2 stories

 lda #1
 jsr decstr
 beq hdland1

 lda #Splat
 jsr addsound

 lda #medland
 bne doland

.local_softland
 lda CharID
 cmp #2
 bcs gd ;guard always lands en garde
 lda CharSword
 cmp #2
 bne label_1
.gd lda #2
 sta CharSword
 lda #landengarde
 bne doland

.label_1 lda #softland
 bne doland

.local_impale jmp DoImpale

.doland jsr jumpseq
 jsr animchar

 lda #0
 sta CharYVel
.return
 rts
}

\*-------------------------------
\*
\*  Hasn't hit floor yet -- can he grab edge above?
\*
\*-------------------------------

.fallon
{
 lda btn ;is button down?
 and CharLife ;& is he alive?
 bpl return_31
 ;yes--can he grab edge?
 lda CharYVel
 cmp #grabspeed
 bcs return_31 ;no--falling too fast

 lda CharY
 clc
 adc #grablead
 ldx CharBlockY
 inx
 cmp FloorY,x
 bcc return_31  ;not within grabbing range yet

\*  Char is within vertical range, and button is down
\*  Is there a ledge within reach?

 lda CharX
 sta savekidx
 lda #LO(grabreach)
 jsr addcharx
 sta CharX
 jsr rereadblocks

 jsr fallon_test ;can you grab ledge?
 bne ok ;yes--do it
 lda savekidx
 sta CharX
 jmp rereadblocks
.ok ;do it!

\* Align char with block

 jsr getdist

 jsr addcharx
 sta CharX

 ldx CharBlockY
 inx
 lda FloorY,x
 sta CharY

 lda #0
 sta CharYVel

 lda #fallhang
 jsr jumpseq
 jsr animchar

 lda #stuntime
 sta stunned
}
.return_31
 rts

.fallon_test
{
 jsr getabove
 sta blockid
 jsr getaboveinf
 jmp checkledge
}

\*-------------------------------
\*  Is there floor underfoot?  If not, start to fall

.onground
{
 lda Fcheck
 and #fcheckmark
 beq return_31 ;0--no need to check

 jsr getunderft
 cmp #block
 bne label_1
 jsr InsideBlock ;If "inside" block, bump him outside
.label_1
 jsr cmpspace
 bne return_31

\* Level 12: Phantom bridge

 lda level
 cmp #12
 bne no
 lda mergetimer
 bpl no
 lda CharBlockY
 bne no
 lda CharScrn
 cmp #2
 beq yes
 cmp #13
 bne no
 lda tempblockx
 cmp #6
 bcc no
;Create floorboards on the fly
.yes lda #floor
 sta (BlueType),y
 jsr indexblock
 lda #REDRAW_FRAMES
 jsr sub
 iny
.sub jsr markwipe
 jmp markred
.no
}

\*-------------------------------
\*  No floor underfoot--commence falling

.startfall
{
 lda #0
 sta rjumpflag
 sta CharSword ;so you can grab on

 inc CharBlockY ;# of floor just below your feet
 jsr addslicers

 lda CharPosn ;upcoming frame
;(the one we're about to replace
;with first frame of falling seq)
 sta rjumpflag

 cmp #9 ;run-12
 beq local_stepfall
 cmp #13 ;run-16
 beq local_stepfall2
 cmp #26 ;standjump-19
 beq local_jumpfall
 cmp #44 ;runjump-11
 beq local_rjumpfall
 cmp #81
 bcc label_2
 cmp #86
 bcc local_hdropfall
.label_2 cmp #150
 bcc label_1
 cmp #180
 bcc local_fightfall ;from fighting stance
.label_1

.local_stepfall lda #stepfall
 bne doit

.local_stepfall2 lda #stepfall2
 bne doit

.local_jumpfall lda #jumpfall
 bne doit

.local_rjumpfall lda #rjumpfall
 bne doit

.local_hdropfall
 lda #5
 jsr addcharx
 sta CharX
 jsr rereadblocks
 jmp local_stepfall2
.return
 rts

.local_fightfall lda CharID
 cmp #2
 bcc local_player
 lda CharXVel
 bmi fb ;did gd step off fwd or bkwd?
 lda #0
 sta droppedout
 lda #efightfallfwd
 bne doit
.fb lda #efightfall
 bne doit
.local_player lda #1
 sta droppedout ;for guard's benefit
 lda #fightfall
 bne doit

\*-------------------------------

.doit jsr jumpseq
 jsr animchar ;advance 1 frame into fall

 jsr rereadblocks
 jsr getunderft
 jsr cmpwall
 beq local_bump
 jsr getinfront
 jsr cmpwall
 bne return
 jmp CDpatch

.local_bump jmp InsideBlock ;If "inside" block, bump him outside
}

.CDpatch
{
 lda rjumpflag
 cmp #44 ;running jump?
 bne patchX

 jsr getdist
 cmp #6
 bcs patchX ;dist >= 6...we're OK

 lda #patchfall
 jsr jumpseq
 jsr animchar
 jmp rereadblocks

.patchX lda #LO(-1)
.label_1 jsr addcharx
 sta CharX
 jmp rereadblocks
}

\*-------------------------------
\*
\* Char is "inside" a block--bump him outside
\* (hopefully the same side from which he entered)
\*
\* Change Char X & return rdblock results
\*
\*-------------------------------

.InsideBlock
{
 jsr getdist ;to EOB
 cmp #8
 bcs bumpback

.bumpfwd
 jsr getinfront
 cmp #block
 beq bumpback

 jsr getdist ;to EOB
 clc
 adc #4
.reland
 jsr addcharx
 sta CharX
 jsr rereadblocks ;reposition char
 jmp getunderft

.bumpback
 jsr getbehind
 cmp #block
 bne label_1
  ;we're screwed
;bump 2 back (what the hell)
 jsr getdist
 clc
 adc #14
 eor #$ff
 clc
 adc #8
 jmp reland
.label_1
 jsr getdist
 eor #$ff
 clc
 adc #8
 jmp reland
}

\*-------------------------------
\*
\*  S H A D O W   C O N T R O L
\*
\*-------------------------------

.SHADCTRL
{
 lda CharID
 cmp #24 ;mouse?
 bne label_1
 jmp AutoCtrl

.label_1 lda CharLife
 bpl local_dead
;Has char's life run out?
 lda OppStrength
 bne cont
 lda #0
 sta CharLife
 jsr deadenemy

.local_dead lda CharID
 cmp #1 ;shadow man?
 bne cont
 jmp VanishChar

.cont lda ManCtrl
 bne manualctrl

 jsr AutoCtrl

 jmp GenCtrl

\* Manual ctrl: enemy controlled by deselected device

.manualctrl
 jsr LoadDesel

 jsr getdesel

 jsr clrjstk

 jsr UserCtrl

 jmp SaveDesel
}

\*-------------------------------
\*
\*  P L A Y E R   C O N T R O L
\*
\*-------------------------------
.PLAYERCTRL
{
 lda CharLife
 bpl cont1 ;dead
 lda KidStrength
 bne cont1
 lda #0
 sta CharLife
.cont1
 lda stunned
 beq cont
 dec stunned

.cont lda level
 bne game
.demo jsr DemoCtrl
 jmp GenCtrl

\* Character controlled by selected device

.game jsr LoadSelect ;load jstk-push flags for selected device

 jsr getselect ;get current input from selected device

 jsr clrjstk ;clear appropriate jstk-push flags

 lda #2
 jsr UserCtrl

 jmp SaveSelect ;save updated jstk-push flags
}

\*-------------------------------
\* Player ctrl in demo

.DemoCtrl
{
 lda milestone
 bne finish
 lda CharSword
 beq preprog

 lda #10
 sta guardprog
 jsr AutoCtrl
 lda #11
 sta guardprog
 rts

.preprog jmp demo

.finish jsr clrall
 sta clrbtn
 lda #LO(-1)
 sta clrF
 sta JSTKX ;run o.s.
 rts
}

\*-------------------------------

.UserCtrl
{
 lda CharFace
 bpl faceL

 jmp GenCtrl

\* If char is facing right, reverse JSTK & clrF/clrB

.faceL jsr facejstk

 jsr GenCtrl

 jmp facejstk
}

\*-------------------------------
.clrall
{
 lda #0
 sta clrB
 sta clrF
 sta clrU
 sta clrD
 lda #1
 rts
}

\*-------------------------------
\*
\*  G E N E R A L   C O N T R O L
\*
\*  In: Raw input
\*        JSTKX (- fwd, + back, 0 center)
\*        JSTKY (- up, + down, 0 center)
\*        btn (- down, + up)
\*      Smart input
\*        clrF-B-U-D-btn (- = fresh press)
\*
\*  Set clr = 1 after using a press
\*
\*-------------------------------
.GENCTRL
{
 lda CharLife
 bmi alive

\* Dead character (If he's standing, collapse)

.dead lda CharPosn
 cmp #15
 beq drop
 cmp #166
 beq drop
 cmp #158
 beq drop
 cmp #171
 bne return
.drop lda #dropdead
 jmp jumpseq

\* Live character

.alive lda CharAction
 cmp #5 ;is char in mid-bump?
 beq clr
 cmp #4 ;or falling?
 beq clr
 bne underctrl
.clr
 jmp clrall

.underctrl
 lda CharSword
 cmp #2 ;in fighting mode?
 beq FightCtrl ;yes

 lda CharID
 cmp #2 ;kid or shadowman?
 bcc cont
 jmp GuardCtrl ;no

\* First question: what is char doing now?

.cont ldx CharPosn ;previous frame #

 cpx #15
 beq GenCtrl_standing

 cpx #48
 beq GenCtrl_turning

 cpx #50
 bcc label_0
 cpx #53
 bcc GenCtrl_standing ;turn7-8-9/crouch
.label_0
 cpx #4
 bcc GenCtrl_starting ;run4-5-6

 cpx #67
 bcc label_4
 cpx #70
 bcc GenCtrl_stjumpup ;starting to jump up

.label_4 cpx #15
 bcs label_2
 jmp GenCtrl_running ;run8-17

.label_2 cpx #87
 bcc label_1
 cpx #100
 bcs label_1
 jmp GenCtrl_hanging ;jumphang22-34

.label_1 cpx #109 ;crouching?
 beq GenCtrl_crouching
.label_3
.return
 rts
}

.GenCtrl_standing jmp standing
.GenCtrl_starting jmp starting
.GenCtrl_stjumpup jmp stjumpup
.GenCtrl_running jmp arunning
.GenCtrl_hanging jmp hanging
.GenCtrl_turning jmp turning
.GenCtrl_crouching jmp crouching

\*-------------------------------
\* Similar routine for guard

.GuardCtrl
{
 ldx CharPosn
 cpx #166 ;standing?
 beq alert
.return
 rts

.alert
 lda clrD
 bpl return
 lda clrF
 bmi local_engarde
 bpl local_turn

.local_engarde jmp ctrl_DoEngarde

.local_turn lda #1
 sta clrD
 lda #alertturn
 jmp jumpseq
}

\*-------------------------------
\* Char is en garde (CharSword = 2)

.FightCtrl
{
 lda CharAction
 cmp #2
 bcs return ;Must be on level ground (Action = 1)

\* If Enemy Alert is over, put away your sword

 jsr getunderft
 cmp #loose
 beq skip ;unless you're standing on loose floor

 lda EnemyAlert
 cmp #2
 bcc dropgd

\* If opponent is behind you, turn to face him

.skip jsr getopdist ;fwd distance to opponent
 cmp #swordthres
 bcc onalert
 cmp #128
 bcc dropgd
 cmp #LO(-4)
 bcs onalert ;overlapping
 jmp DoTurnEng

\* Enemy out of range--drop your guard
\* (kid & shadman only)

.dropgd lda CharID
 bne label_1
 sta heroic
 beq label_2
.label_1 cmp #2
 bcs onalert ;guard: remain en garde
.label_2
 ldx CharPosn
 cpx #171 ;wait for ready posn
 bne return

 lda #0
 sta CharSword

 lda #resheathe
 jmp jumpseq
.return
 rts
}

\*-------------------------------
\* Remain en garde

.onalert
{
 ldx CharPosn ;prev frame #
 cpx #161 ;successful block?
 bne nobloc
 lda clrbtn ;yes--restrike or retreat?
 bmi bts
 lda #retreat
 jmp jumpseq

\* Fresh button press to strike

.nobloc lda clrbtn
 bpl label_10
.bts
 lda CharID
 bne label_11
 lda #gdpatience
 sta gdtimer

.label_11 jsr ctrl_DoStrike

 lda clrbtn
 cmp #1
 beq return ;struck
.label_10 ;else didn't strike

\* Down to lower your sword

 lda clrD
 bpl nodrop

 ldx CharPosn
 cpx #158 ;ready
 beq ready1
 cpx #170
 beq ready1
 cpx #171
 bne return
.ready1
 lda #1
 sta clrD

 lda #0
 sta CharSword

 lda CharID
 beq drop ;for kid
 cmp #1
 beq sstand ;for shadman

.alert lda #goalertstand
 jmp jumpseq ;for guard

.drop lda #1
 sta offguard
 lda #graceperiod
 sta refract
 lda #0
 sta heroic
 lda #fastsheathe
 jmp jumpseq

.sstand lda #resheathe
 jmp jumpseq

\* Fwd to advance, up to block, back to retreat

.nodrop
 lda clrU
 bmi local_up
 lda clrF
 bmi local_fwd
 lda clrB
 bmi local_back

.return
 rts

.local_fwd jmp ctrl_DoAdvance
.local_up jmp ctrl_DoBlock
.local_back jmp ctrl_DoRetreat
}

\*-------------------------------

.DoTurnEng
{
 lda #turnengarde
 jmp jumpseq
}

\*-------------------------------

.ctrl_DoBlock
{
 ldx CharPosn
 cpx #158 ;ready
 beq label_2
 cpx #170
 beq label_2
 cpx #171
 beq label_2
 cpx #168 ;guy-2
 beq label_2

 cpx #165 ;adv
 beq label_2
 cpx #167 ;blocked strike
 beq label_3

.return
 rts

\* From ready position: Block if appropriate

.label_2 jsr getopdist
 cmp #blockthres
 bcs blockmiss ;too far

 lda #readyblock
 ldx CharID
 beq kid
 ldx OpPosn ;enemy sees kid 1 frame ahead
 cpx #152 ;guy4
 beq doit
 rts

.kid ldx OpPosn
 cpx #168 ;1 frame too early?
 beq return  ;yes--wait 1 frame

 cpx #151 ;guy3
 beq doit
 cpx #152 ;guy4
 beq doit
 cpx #162 ;guy22
 beq doit

 cpx #153 ;1 frame too late?
 bne blockmiss
  ;yes--skip 1 frame
 jsr doit
 jmp animchar

\* Strike-to-block

.label_3 lda #strikeblock
.doit ldx #1
 stx clrU
 jmp jumpseq
.blockmiss
 lda CharID
 bne ctrl_DoRetreat ;enemy doesn't waste blocks
 lda #readyblock
 bne doit
}

\*-------------------------------

.ctrl_DoStrike
{
 cpx #157
 beq label_1
 cpx #158
 beq label_1
 cpx #170
 beq label_1
 cpx #171
 beq label_1 ;strike from ready posn
 cpx #165
 beq label_1 ;from advance
 cpx #150
 beq label_2 ;from missed block
 cpx #161
 beq label_2 ;from successful block

.return
 rts

.label_1 lda CharID
 bne slo ;kid is fast, others slow

 lda #faststrike
 bne dostr

.slo lda #strike
.dostr ldx #1
 stx clrbtn
 jmp jumpseq

.label_2 lda #blocktostrike
 bne dostr
}

\*-------------------------------

.ctrl_DoRetreat
{
 ldx CharPosn
 cpx #158
 beq label_1 ;strike from ready posn
 cpx #170
 beq label_1
 cpx #171
 beq label_1
.return
 rts

.label_1 lda #retreat
 ldx #1
 stx clrB
 jmp jumpseq
}

\*-------------------------------

.ctrl_DoAdvance
{
 ldx CharPosn
 cpx #158
 beq label_1
 cpx #170
 beq label_1
 cpx #171
 beq label_1
.return
 rts

.label_1 lda CharID
 bne slo ;kid is faster
 lda #fastadvance
 bne doit
.slo lda #advance
.doit ldx #1
 stx clrF
 jmp jumpseq
}

\*-------------------------------
\*
\*  S T A N D I N G
\*
\*-------------------------------

.standing
{
\* Fresh button click: pick up object?

 lda clrbtn
 bpl noclick
 lda btn
 bpl noclick
 jsr TryPickup
 bne return ;yes

.noclick

\* Shadman only: down & fwd to go en garde

 lda CharID
 beq kid
 lda clrD
 bpl label_1
 lda clrF
 bpl label_1
 jmp ctrl_DoEngarde

\* If opponent is within range, go en garde
\* (For kid only)

.kid lda gotsword
 beq label_1 ;no sword

 lda offguard
 beq notoffg
 lda btn ;off guard--push btn to draw sword
 bpl btnup
.notoffg
 lda EnemyAlert
 cmp #2
 bcc local_safe
 jsr getopdist ;fwd distance to opponent
 cmp #LO(swordthresN)
 bcs danger
 cmp #swordthres
 bcs local_safe

.danger ldx #1
 stx heroic
 cmp #LO(-6)
 bcs local_behindyou

 lda OpID
 cmp #1
 bne local_engarde
 lda OpAction
 cmp #3
 beq local_safe
 lda OpPosn
 cmp #107
 bcc local_engarde
 cmp #118
 bcc local_safe ;let shadow land
.local_engarde jmp ctrl_DoEngarde

.local_behindyou jmp ctrl_DoTurn

.local_safe lda #0
 sta offguard

.label_1 lda btn
 bpl btnup

\*-------------------------------
\* Standing, button down

.label_2 lda clrB
 bmi standing_backB

 lda clrU
 bmi standing_up

 lda clrD
 bmi standing_down

 lda JSTKX
 bpl return

 lda clrF
 bmi standing_fwdB
.return
 rts
}

\*-------------------------------
\* Standing, button up

.btnup
{
 lda clrF
 bmi standing_fwd
 lda clrB
 bmi standing_back
 lda clrU
 bmi standing_up
 lda clrD
 bmi standing_down

 lda JSTKX
 bmi standing_fwd

.return
 rts
}

.standing_fwd jmp DoStartrun
.standing_fwdB jmp DoStepfwd

.standing_back jmp ctrl_DoTurn
.standing_backB jmp ctrl_DoTurn

.standing_fwdup jmp DoStandjump

\*-------------------------------
\* Standing, joystick up

.standing_up
{
\* In front of open stairs?

 jsr getunderft
 cmp #exit
 beq local_stairs
 jsr getbehind
 cmp #exit
 beq local_stairs
 jsr getinfront
 cmp #exit
 bne local_nostairs

.local_stairs lda (BlueSpec),y
 lsr A
 lsr A
 cmp #stairthres
 bcc local_nostairs

 jmp Stairs

\* No -- normal control

.local_nostairs
 lda JSTKX
 bmi standing_fwdup

\* Straight up...jump up & grab ledge if you can

 jmp DoJumpup
}

\*-------------------------------
\* Standing, joystick down

.standing_down
{
 lda #1
 sta clrD

\* If you're standing w/back to edge, down
\* means "climb down & hang from ledge"

\* If facing edge, "down" means "step off"

 jsr getinfront
 jsr cmpspace
 bne notfwd ;no cliff in front of you

 jsr getdist
 cmp #StepOffFwd
 bcs notfwd ;not close enough to edge
 lda #5
 jsr addcharx
 sta CharX
 jmp rereadblocks ;move fwd

.notfwd jsr getbehind
 jsr cmpspace
 bne no ;no cliff behind you

 jsr getdist
 cmp #StepOffBack
 bcc no ;not close enough to edge

\* Climb down & hang from ledge

 jsr getbehind
 sta blockid
 jsr getunderft
 jsr checkledge
 beq no

 ldx CharFace
 bpl succeed
 jsr getunderft
 cmp #gate
 bne succeed

 lda (BlueSpec),y
 lsr A
 lsr A
 cmp #gclimbthres
 bcc no

.succeed jsr getdist
 sec
 sbc #9

 jsr addcharx
 sta CharX

 lda #climbdown
 jmp jumpseq

\* Otherwise "down" means "crouch"

.no jmp DoCrouch
}

\*-------------------------------
\* Climb stairs

.Stairs
{
 lda tempblockx ;stairs block
 jsr getblockej
 clc
 adc #10
 sta CharX
 lda #LO(-1)
 sta CharFace

 lda #climbstairs
 jmp jumpseq
}
.return_24
 rts

\*-------------------------------
\*
\*  C R O U C H I N G
\*
\*-------------------------------

.crouching
{
\* Fresh button click?

 lda clrbtn
 bpl noclick

 jsr TryPickup
 bne return_24

\* Still crouching?

.noclick
 lda JSTKY
 cmp #1
 beq label_1
 lda #standup
 jmp jumpseq

.label_1 lda clrF
 bpl return_24
 lda #1
 sta clrF
 lda #crawl
 jmp jumpseq
}

\*-------------------------------
\*
\*  S T A R T I N G
\*
\*  First few frames of "startrun"
\*
\*-------------------------------

.starting
{
 lda JSTKY
 bmi jump
.return
 rts

.jump
 lda JSTKX
 bpl return

 jmp DoStandjump
}

\*-------------------------------
\* First few frames of "jumpup"

.stjumpup
{
 lda JSTKX
 bmi fwd
 lda clrF
 bmi fwd
.return
 rts
.fwd jmp DoStandjump
}

\*-------------------------------
\*
\* T U R N I N G
\*
\*-------------------------------

.turning
{
 lda btn
 bmi return_24

 lda JSTKX
 bpl return_24

 lda JSTKY
 bmi return_24

\* Jstk still fwd--convert turn to turnrun

 lda #turnrun
 jmp jumpseq
}

\*-------------------------------
\*
\*  R U N N I N G
\*
\*-------------------------------

.arunning
{
 lda JSTKX
 beq local_runstop ;jstk centered...stop running
 bpl local_runturn ;jstk back...turn around

\* Jstk is forward... keep running
\* & wait for signal to runjump or diveroll

 lda JSTKY
 bmi local_runjump ;jstk up... take a running jump

 lda clrD
 bmi local_diveroll ;jstk down... running dive & roll

.return
 rts

\*  Running dive & roll

.local_diveroll lda #1
 sta clrD

 lda #rdiveroll
 jmp jumpseq

\*  Running jump

.local_runjump
 lda clrU
 bpl return

 jmp DoRunjump

\*  Stop running

.local_runstop lda CharPosn
 cmp #7 ;run-10
 beq rs
 cmp #11 ;run-14
 bne return

.rs jsr clrall
 sta clrF

 lda #runstop
 jmp jumpseq

\*  Turn around & run the other way

.local_runturn
 jsr clrall
 sta clrB

 lda #runturn
 jmp jumpseq
}

\*-------------------------------
\*
\*  H A N G I N G
\*
\*-------------------------------

.hanging
{
 lda stunned
 bne label_9 ;can't climb up

 lda JSTKY
 bmi local_climbup ;jstk up-->climb up
.label_9
 lda btn
 bpl local_drop

\* If hanging on right-hand side of a panel
\* or either side of block,
\* switch to "hangstraight"

 lda CharAction
 cmp #6
 beq cont ;already hanging straight

 jsr getunderft
 cmp #block
 beq local_hangstrt

 ldx CharFace
 cpx #LO(-1) ;left
 bne cont

 cmp #panelwif
 beq local_hangstrt
 cmp #panelwof
 beq local_hangstrt

\* If ledge crumbles away, fall with it

.cont
 jsr getabove

 jsr cmpspace ;still there?
 beq local_drop ;no

\* just keep swinging

.return
 rts

.local_hangstrt lda #hangstraight
 jmp jumpseq

\*-------------------------------
\* climb up (if you can)

.local_climbup
 jsr clrall
 sta clrU
 sta clrbtn

 jsr getabove

 cmp #mirror
 beq label_10
 cmp #slicer
 bne label_1

.label_10 ldx CharFace
 beq fail
 bne succeed ;can only mount mirror facing L

.label_1 cmp #gate
 bne label_2

 ldx CharFace
 beq succeed
;can only mount closed gate facing R
 lda (BlueSpec),y
 lsr A
 lsr A
 cmp #gclimbthres
 bcc fail
 bcs succeed

.label_2
.succeed lda #climbup
 jmp jumpseq

.fail lda #climbfail
 jmp jumpseq

\*-------------------------------
.local_drop
 jsr clrall
 sta clrD ;clrD = 1, all others = 0

 jsr getbehind
 jsr cmpspace
 bne local_hangdrop

 jsr getunderft
 jsr cmpspace
 beq local_hangfall

.local_hangdrop
 jsr getunderft
 cmp #block
 beq local_sheer

 ldx CharFace
 bpl local_clear
 cmp #panelwof
 beq local_sheer
 cmp #panelwif
 bne local_clear

.local_sheer lda #LO(-7)
 jsr addcharx
 sta CharX

.local_clear lda #hangdrop
 jmp jumpseq

.local_hangfall
 lda #hangfall
 jmp jumpseq
}
.return_25
 rts

\*-------------------------------
\*
\*  D o  S t a r t r u n
\*
\*-------------------------------

.DoStartrun
{
\* If very close to a barrier, do a Stepfwd instead
\* (Exceptions: slicer & open gate)

 jsr getfwddist
 cpx #1 ;barrier?
 bne local_startrun ;no

 cpy #slicer
 beq local_startrun

.solidbarr
 jsr getfwddist
 cmp #8
 bcs local_startrun

 lda clrF
 bpl return_25

 jmp DoStepfwd

.local_startrun
 lda #startrun
 jmp jumpseq ;...start running
}

.ctrl_DoTurn
{
 jsr clrall
 sta clrB
;if enemy is behind you, draw as you turn
 lda gotsword
 beq label_1
 lda EnemyAlert
 cmp #2
 bcc label_1
 jsr getopdist
 bpl label_1
 jsr getdist ;to EOB
 cmp #2
 bcc label_1

 lda #2
 sta CharSword ;en garde
 lda #0
 sta offguard
 lda #turndraw
 bne label_2
.label_1 lda #turn
.label_2 jmp jumpseq ;...turn around
}

.DoStandjump
{
 lda #1
 sta clrU
 sta clrF

 lda #standjump
 jmp jumpseq ;...standing jump
}

.DoSdiveroll
{
 lda #1
 sta clrD

 lda #sdiveroll
 jmp jumpseq ;...standing dive & roll
}

.DoCrouch
{
 lda #stoop
 jsr jumpseq

 jsr clrall
 sta clrD
 rts
}

.ctrl_DoEngarde
{
 jsr clrall
 sta clrF
 sta clrbtn

 lda #2
 sta CharSword ;en garde

 lda CharID
 beq label_1
 cmp #1
 beq label_3 ;shad
 lda #guardengarde
 bne label_2
.label_1 lda #0
 sta offguard
.label_3 lda #engarde
.label_2 jmp jumpseq
}

\*-------------------------------
\*
\*  D o  J u m p u p
\*
\*  & grab ledge if you can
\*
\*-------------------------------

.DoJumpup
{
 jsr clrall
 sta clrU

 jsr getabove
 sta blockid

 jsr getaboveinf

 jsr checkledge ;Can you jump up & grab ledge?
 ;Returns 1 if you can, 0 if you can't
 bne  DoJumphang ;yes--do it

 jsr getabovebeh
 sta blockid

 jsr getabove

 jsr checkledge ;could you do it if you were 1 space back?
 bne jumpback ;yes--move back & do it

.jumphi jmp DoJumphigh

\*-------------------------------
\* Jump up & back to grab block directly overhead

.jumpback
 jsr getdist ;dist to front of block
 cmp #JumpBackThres
 bcc jumphi ;too far to fudge

 jsr getbehind
 jsr cmpspace ;floor behind you?
 beq DoJumpedge ;no

\* "Jump back" to block behind you & then proceed as usual

 jsr getdist
 sec
 sbc #14
 jsr addcharx
 sta CharX

 jsr rereadblocks

 jmp DoJumphang
}

\*-------------------------------
\* Your back is to ledge -- so do a "jumpbackhang"

.DoJumpedge
{
 jsr getabove

\* Get all the way back on this block

 jsr getdist
 sec
 sbc #10

 jsr addcharx
 sta CharX

\* now jump

 lda #jumpbackhang
 jmp jumpseq
}

\*-------------------------------

.DoJumphang
{
 jsr getaboveinf

\*  Choose the jumphang sequence (Long/Med) that
\*  will bring us closest to edge, then fudge the X-coord
\*  to make it come out exactly

 jsr getdist ;get distance to front of block
 sta ctrl_atemp ;# pixels (0-13) returned in A

 cmp #4
 bcc Med

.Long lda ctrl_atemp
 sec ;"Long" will add 4 to CharX
 sbc #4
 jsr addcharx
 sta CharX

 lda #jumphangLong
 jmp jumpseq
.Med
 jsr getfwddist
 cmp #4
 bcs okMed

 cpx #1 ;close to wall?
 beq Long ;yes--step back & do Long

.okMed lda ctrl_atemp
 jsr addcharx
 sta CharX

 lda #jumphangMed
 jmp jumpseq

.return
 rts
}

\*-------------------------------
\*
\*  D o  R u n  J u m p
\*
\*  Calibrate jump so that foot will push off at edge.
\*
\*-------------------------------
RJChange = 4 ;projected change in CharX
RJLookahead = 1 ;# blocks you can look ahead
RJLeadDist = 14 ;required leading distance in pixels
RJMaxFujBak = 8 ;# pixels we're willing to fudge back
RJMaxFujFwd = 2 ;and forward

.DoRunjump
{
 lda CharPosn
 cmp #7
 bcc return ;must be in full run

\* Count # of blocks to edge
\* (Use actual CharX)

 lda #0
 sta bufindex ;block counter

 lda #RJChange
 jsr addcharx
 sta ztemp ;projected CharX

 jsr getblockxp
 sta blockx

.loop lda blockx
 ldx CharFace
 inx
 clc
 adc plus1,x
 sta blockx

 tax
 ldy CharBlockY
 lda CharScrn
 jsr rdblock

 cmp #spikes
 beq done

 jsr cmpspace
 beq done

 inc bufindex

 lda bufindex
 cmp #RJLookahead+1
 bcc loop
 bcs noedge ;no edge in sight--jump anyway
.done

\* Calculate # of pixels to end of floor

 lda ztemp
 jsr getdist1 ;# pixels to end of block

 ldx bufindex ;# of blocks to end of floor
 clc
 adc Mult7,x
 clc
 adc Mult7,x ;# of pixels to end of floor

 sec
 sbc #RJLeadDist
;A = difference between actual dist to edge
;and distance covered by RunJump
 cmp #LO(-RJMaxFujBak)
 bcs ok ;move back a little & jump

 cmp #RJMaxFujFwd
 bcc  ok ;move fwd a little & jump

 cmp #$80
 bcc return ;still too far away--wait till next frame

 lda #LO(-3) ;He jumped too late; he'll miss edge
;But let's make it look good anyway
.ok clc
 adc #RJChange

 jsr addcharx
 sta CharX

\* No edge in sight -- just do any old long jump

.noedge
 jsr clrall
 sta clrU

 lda #runjump
 jmp jumpseq

.return
 rts
}

\*-------------------------------
\*
\*  D o  S t e p  F o r w a r d
\*
\*-------------------------------

.DoStepfwd
{
 lda #1
 sta clrF
 sta clrbtn

 jsr getfwddist ;returns A = distance to step (0-13)

 cmp #0
 beq label_1

.label_2 sta CharRepeat ;non-0 value

 clc
 adc #stepfwd1-1
 jmp jumpseq

.label_1 cpx #1
 beq thru ;If barrier, step thru

 cmp CharRepeat
 bne label_3 ;First time, test w/foot

.thru lda #11
 bne label_2 ;Second time, step off edge

.label_3 sta CharRepeat ;0

 lda #testfoot
 jmp jumpseq
}

\*-------------------------------
\*
\*  D o  J u m p  H i g h
\*
\*-------------------------------

.DoJumphigh
{
 jsr clrall
 sta clrU

 jsr getfwddist
 cmp #4
 bcs ok
 cpx #1 ;barrier?
 bne ok ;no

 sec
 sbc #3
 jsr addcharx
 sta CharX
.ok
 lda #jumpupreach
 jsr facedx
 sta ztemp

 jsr getbasex ;assume char standing still
 clc
 adc #LO(jumpupangle)
 clc
 adc ztemp ;get X-coord at which hand touches ceiling

 jsr getblockx
 tax

 ldy CharBlockY
 dey

 lda CharScrn
 jsr rdblock ;read this block

 cmp #block
 beq local_jumpup
 jsr cmpspace
 bne local_jumpup

 lda #highjump
 jmp jumpseq ;no ceiling above

.local_jumpup lda #jumpup
 jsr jumpseq ;touch ceiling
.return
 rts ;& don't forget to crop top
}

\*-------------------------------
\*  reread blocks
\*-------------------------------
.REREADBLOCKS
{
 jsr GetFrameInfo
 jmp GetBaseBlock
}

\*-------------------------------
\*
\*  Is character stepping on a pressure plate?
\*  or on loose floor?
\*
\*-------------------------------

.CHECKPRESS
{
 lda CharPosn
 cmp #87
 bcc label_1
 cmp #100
 bcc local_hanging ;87-99: jumphang22-34
 cmp #135
 bcc label_1
 cmp #141
 bcc local_hanging ;135-140: climb up/down
.label_1
 lda CharAction
 cmp #7
 beq local_ground ;turning
 cmp #5
 beq local_ground ;bumped
 cmp #2
 bcs return

\* Action code 7, 0 or 1: on the ground

.local_ground
 lda CharPosn
 cmp #79 ;jumpup/touch ceiling
 beq local_touchceil

 lda Fcheck
 and #fcheckmark
 beq return ;foot isn't touching floor

\*  Standing on a pressplate?

 jsr getunderft
.local_checkit
 cmp #upressplate
 beq local_PP
 cmp #pressplate
 bne local_notPP

.local_PP lda CharLife
 bmi local_push
 jmp jampp ;dead weight
.local_push jmp pushpp

.local_notPP cmp #loose
 bne return

 lda #1
 sta alertguard
 jmp breakloose

\*  Hanging on a pressplate?

.local_hanging
 jsr getabove
 jmp local_checkit
.return
 rts

\* Jumping up to touch ceiling?

.local_touchceil
 jsr getabove

 cmp #loose
 bne return

 jmp breakloose
}

\*-------------------------------
\*
\*  C H E C K   I M P A L E
\*
\*  Impalement by running or jumping onto spikes
\*  (Impalement by landing on spikes is covered by
\*  CHECKFLOOR:falling)
\*
\*-------------------------------

.CHECKIMPALE
{
 ldx CharBlockX
 ldy CharBlockY
 lda CharScrn
 jsr rdblock
 cmp #spikes
 bne return ;not spikes

 ldx CharPosn

 cpx #7
 bcc return

 cpx #15
 bcs label_2
 jmp local_running

.label_2 cpx #43 ;runjump-10
 beq local_jumpland

 cpx #26 ;standjump-19
 beq local_jumpland

.return
 rts

.local_running
 jsr getspikes
 cmp #2
 bcc return ;must be springing
 bcs local_impale

.local_jumpland
 jsr getspikes ;are spikes lethal?
 beq return ;no

.local_impale jmp DoImpale
}

\*-------------------------------
\* Impale char on spikes
\*
\* In: rdblock results
\*-------------------------------

.DOIMPALE
{
 jsr jamspikes

 ldx CharBlockY
 inx
 lda FloorY,x
 sta CharY ;align char w/floor

 lda tempblockx
 jsr getblockej ;edge of spikes
 clc
 adc #10
 sta CharX
 lda #8
 jsr addcharx
 sta CharX ;center char on spikes

 lda #0
 sta CharYVel

 lda #Impaled
 jsr addsound

 lda #100
 jsr decstr

 lda #impale
 jsr jumpseq
 jmp animchar
}

\*-------------------------------
\*
\*  Pick up object
\*  Return 0 if no result
\*
\*-------------------------------

.TryPickup
{
 jsr getunderft
 cmp #flask
 beq label_2
 cmp #sword
 bne label_1
.label_2 jsr getbehind
 jsr cmpspace
 beq local_no
 lda CharX
 lda #LO(-14)
 jsr addcharx
 sta CharX ;move char 1 block back
 jsr rereadblocks
.label_1 jsr getinfront
 cmp #flask
 beq local_pickup
 cmp #sword
 beq local_pickup
.local_no lda #0
 rts

.local_pickup jsr PickItUp
 lda #1
 rts
}

\*-------------------------------
\*
\* Pick something up
\*
\* In: rdblock results for object block ("infront")
\*
\*-------------------------------

.PickItUp
{
 ldx CharPosn
 cpx #109 ;crouch first, then pick up obj
 beq ok
 jsr getfwddist
 cpx #2
 beq label_0 ;right at edge
 jsr addcharx
 sta CharX
.label_0 lda CharFace
 bmi label_1
 lda #LO(-2)
 jsr addcharx
 sta CharX ;put char within reach of obj
.label_1 jmp DoCrouch

.ok cmp #sword
 beq PickupSword

 lda (BlueSpec),y
 lsr A
 lsr A
 lsr A
 lsr A
 lsr A;potion # (0-7)
 jsr RemoveObj

 lda #drinkpotion ;pick up & drink potion
 jmp jumpseq

.PickupSword
 lda #LO(-1) ;sword
 jsr RemoveObj

 lda #pickupsword
 jmp jumpseq ;pick up, brandish & sheathe sword
}

\*-------------------------------
\ lst
\ ds 1
\ usr $a9,16,$00,*-org
\ lst off
