; mover.asm
; Originally MOVER.S
; Moveable object code

.mover
\org = $ee00
PalaceEditor = 0
\ tr on
\ lst off
\*-------------------------------
\ org org

.animtrans jmp ANIMTRANS
.trigspikes jmp TRIGSPIKES
.pushpp jmp PUSHPP
.breakloose1 jmp BREAKLOOSE1
.breakloose jmp BREAKLOOSE

.animmobs jmp ANIMMOBS
.addmobs jmp ADDMOBS
.closeexit jmp CLOSEEXIT
.getspikes jmp GETSPIKES
.shakem jmp SHAKEM

.trigslicer jmp TRIGSLICER
.trigtorch jmp TRIGTORCH
.getflameflame jmp GETFLAMEFRAME
.smashmirror jmp SMASHMIRROR
.jamspikes jmp JAMSPIKES

.trigflask jmp TRIGFLASK
.getflaskflame jmp GETFLASKFRAME
.trigsword jmp TRIGSWORD
.jampp jmp JAMPP

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

\*-------------------------------
.gatevel EQUB 0,0,0,20,40,60,80,100,120

maxgatevel = P%-gatevel-1

\*-------------------------------
pptimer = 5 ;pressplate timer setting (min=3, max=30)
;(# cycles till plate pops up)

spiketimer = 15+128 ;spike timer setting (2-127) +128
;(# cycles till spikes retract)

slicetimer = 15 ;# cycles between slices

gatetimer = gmaxval+50 ;# cycles gate stays open

loosetimer = Ffalling ;# cycles till floor detaches

\* falling floor params

wiggletime = 4 ;# wiggling frames
FFaccel = 3
FFtermvel = 29
crumbletime = 2 ;# crumbling frames
crumbletime2 = 10
disappeartime = 2
FFheight = 17
CrushDist = 30

\* wipe heights

loosewipe = 31 ;[might erase spikes]
spikewipe = 31
slicerwipe = 63
platewipe = 16

.gateinc EQUB -1,4,4 ;for trdirec = 0,1,2 (down,up,upjam)

exitinc = 4
emaxval = 43*4

maxtr = trobspace-1
maxmob = mobspace-1

\*-------------------------------
\*
\* Search trans list for object (trloc,trscrn)
\*
\* In: numtrans, trloc, trscrn
\* Out: X = index, 0 if not listed
\*
\*-------------------------------
.searchtrob
{
 ldx numtrans
 beq return

.loop lda trloc,x
 cmp trloc
 bne next
 lda trscrn,x
 cmp trscrn
 beq return ;found it

.next dex
 bne loop

.return rts
}

\*-------------------------------
\*
\*  Add a new object to transition list
\*  If it's already listed, just change trdirec to new value
\*
\*  In: trdirec, trloc, trscrn
\*
\*-------------------------------
.addtrob
{
 jsr searchtrob ;Is object already listed?

 cpx #0
 bne chdir ;Yes--just change direc

\* It's not on the list - add it

 ldx numtrans
 cpx #maxtr
 beq return ;too many objects--trigger fails

 inx
 stx numtrans

 lda trdirec
 sta trdirec,x
 lda trloc
 sta trloc,x
 lda trscrn
 sta trscrn,x
 rts

\*  Object already listed - change direction

.chdir lda trdirec
 sta trdirec,x
.return rts
}

\*-------------------------------
\*
\*  Add a MOB to MOB list
\*
\*-------------------------------
.addamob
{
 ldx nummob
 cpx #maxmob
 beq return

 inx
 stx nummob

 jmp savemob

.return rts
}

\*-------------------------------
\*
\*  S A V E / L O A D   M O B
\*
\*-------------------------------
.savemob
{
 lda mobx
 sta mobx,x
 lda moby
 sta moby,x
 lda mobscrn
 sta mobscrn,x
 lda mobvel
 sta mobvel,x
 lda mobtype
 sta mobtype,x
 lda moblevel
 sta moblevel,x
 rts
}

.loadmob
{
 lda mobx,x
 sta mobx
 lda moby,x
 sta moby
 lda mobscrn,x
 sta mobscrn
 lda mobvel,x
 sta mobvel
 lda mobtype,x
 sta mobtype
 lda moblevel,x
 sta moblevel
}
.return_36
 rts

\*-------------------------------
\*
\*  Trigger slicer
\*
\*  In: A = initial state
\*
\*-------------------------------

.TRIGSLICER
{
 sta state ;temp

 lda (BlueSpec),y
 beq ok
 cmp #slicerRet
 bcc return_36 ;in mid-slice--don't interfere

\* Between slices--OK to trigger

.ok sty trloc

 lda state
 sta (BlueSpec),y

 lda VisScrn
 sta trscrn

 lda #1
 sta trdirec

 jmp addtrob ;add slicer to trans list
}

\*-------------------------------
\*
\* Close exit
\* (Open it all the way & let it slam shut)
\*
\*-------------------------------

.CLOSEEXIT
{
 sty trloc
 sta trscrn

 lda #emaxval ;all the way open
 sta (BlueSpec),y

 lda #3 ;coming down fast
 sta trdirec

 jmp addtrob ;add to trans list
}

\*-------------------------------

.SMASHMIRROR
{
 lda #86
 sta (BlueSpec),y
.return
 rts
}

\*-------------------------------
\*
\* Trigger flask
\*
\*-------------------------------

.TRIGFLASK
{
 sty trloc
 sta trscrn

 lda #1
 sta trdirec

\* Get rnd starting frame

 jsr rnd
 and #7
 ora (BlueSpec),y
 sta (BlueSpec),y
 jmp addtrob
}

\*-------------------------------
\*
\* Trigger sword
\*
\*-------------------------------

.TRIGSWORD
{
 sty trloc
 sta trscrn
 lda #1
 sta trdirec
 jsr rnd
 and #$1f
 sta (BlueSpec),y
 jmp addtrob
}

\*-------------------------------
\*
\* Trigger torch
\*
\*-------------------------------

.TRIGTORCH
{
 sty trloc
 sta trscrn

 lda #1
 sta trdirec

\* Get rnd starting frame

 jsr rnd
 and #$f
 sta (BlueSpec),y
 jmp addtrob
}

\*-------------------------------
\*
\*  Trigger spikes
\*
\*-------------------------------

.TRIGSPIKES
{
 lda (BlueSpec),y
 beq ready ;State = 0: spikes are fully retracted--
;spring 'em
 bpl return ;Nonzero, hibit clear: spikes are in motion
 cmp #$ff
 beq return ;jammed
 lda #spiketimer ;Nonzero, hibit set: spikes are fully
 sta (BlueSpec),y ;extended--reset timer to max value
.return rts
;Spring spikes
.ready ldx #1
}
.TRIGSPIKES_cont
{
 stx trdirec
 sty trloc

 lda tempscrn ;from rdblock
 sta trscrn

 jsr addtrob ;add spikes to trans list
 jsr redspikes

 lda #GateDown ;TEMP
 jmp addsound
}

\*-------------------------------
\*
\* Jam spikes (& remove from trans list)
\*
\* In: Same as TRIGSPIKES
\*
\*-------------------------------

.JAMSPIKES
{
 lda #$ff
 sta (BlueSpec),y
 ldx #LO(-1) ;stop object
 bmi TRIGSPIKES_cont
}

\*-------------------------------
\*
\* Get spike status: 0 = safe, 1 = sprung, 2 = springing
\*
\*-------------------------------

.GETSPIKES
{
 lda (BlueSpec),y
 bmi sprung
 beq safe ;fully retracted

 cmp #spikeExt
 bcc springing

.safe lda #0 ;safe: retracted or retracting
 rts

.sprung cmp #$ff ;jammed (body impaled on them)?
 beq safe
 lda #1
 rts

.springing lda #2
}
.return_42
 rts

\*-------------------------------
\*
\*  Break off section of loose floor
\*
\*-------------------------------
.BREAKLOOSE
 lda #1

.BREAKLOOSE1 ;in: A = initial state
{
 sta state

 lda (BlueType),y
 and #reqmask ;required floorpiece?
 bne return_42 ;yes--blocked below

 lda (BlueSpec),y
 bmi ok ;wiggling
 bne return_42 ;already triggered

.ok lda state
 sta (BlueSpec),y

 sty trloc

 lda tempscrn ;from rdblock
 sta trscrn

 lda #0 ;down
 sta trdirec

 jsr addtrob ;add floor to trans list
 jmp redloose
}

\*-------------------------------
\*
\*  Depress pressplate
\*
\*  In: results of RDBLOCK
\*     (tempblockx-y, tempscrn refer to pressplate)
\*
\*-------------------------------

.PUSHPP
{
 lda (BlueType),y
 and #idmask
 sta mover_pptype ;pressplate/upressplate/rubble
}
.pushpp1
{
 lda (BlueSpec),y ;LINKLOC index
 sta mover_linkindex
 tax
 jsr gettimer

 cmp #31
 beq return_42 ;plate is permanently down

 cmp #2
 bcs starttimer ;plate is temporarily down--
;just restart timer

\*  Fresh plate has been stepped on--reset timer

 lda #pptimer ;put plate down for the count
 jsr chgtimer

 sty trloc

 lda tempscrn ;from rdblock1
 sta trscrn

 lda #1
 sta trdirec

 jsr addtrob ;add to trans list

 jsr redplate ;add plate to redraw list

 lda #1
 sta alertguard
 lda #PlateDown
 jsr addsound

.trig jmp trigger ;trigger something?

\* plate is already down--just restart timer
\* (& retrigger gates)

.starttimer lda #pptimer
 jsr chgtimer
 jmp trig
}

\*-------------------------------
\*
\* Jam pressplate (dead weight)
\*
\* In: Same as PUSHPP
\*
\*-------------------------------

.JAMPP
{
 lda (BlueType),y
 and #idmask
 sta mover_pptype
 cmp #pressplate
 beq local_1

 lda #floor
 sta (BlueType),y
 lda #0
 sta (BlueSpec),y
 lda #rubble
 sta mover_pptype
 bne pushpp1

.local_1 lda #dpressplate
 sta (BlueType),y
 bne pushpp1
}

\*-------------------------------
\*
\*  We just pushed a pressplate -- did we trigger something?
\*
\*  In: mover_linkindex, mover_pptype
\*
\*-------------------------------

.trigger
{
.loop ldx mover_linkindex

 lda LINKLOC,x
 cmp #$ff
 beq return ;linked to nothing

 jsr getloc
 sta trloc

 jsr getscrn ;get block # and screen # of
 sta trscrn ;gadget to trigger

 jsr calcblue
 ldy trloc
 lda (BlueType),y
 and #idmask ;get objid into A

 jsr trigobj ;call appropriate trigger routine

 lda trdirec
 bmi skip ;trigger fails

 jsr addtrob ;add gadget to transition list

.skip ldx mover_linkindex
 inc mover_linkindex

 jsr getlastflag
 beq loop

.return
 rts
}

\*-------------------------------
\*
\*  Trigger object
\*
\*  Out: trdirec (-1 if trigger fails)
\*
\*-------------------------------

.trigobj
{
 cmp #gate
 bne local_1
 jmp triggate
.local_1
 cmp #exit
 bne local_2
 jmp openexit
.local_2
.return
 rts
}

\*-------------------------------
\*
\* Open exit
\*
\*-------------------------------

.openexit
{
 lda (BlueSpec),y
 bne fail ;Exit can only open, not close

 lda #1
 bpl local_1

.fail lda #LO(-1)
.local_1 sta trdirec
 rts
}

\*-------------------------------
\*
\*  Trigger gate
\*
\*  In: BlueSpec, Y, mover_pptype
\*  Out: trdirec
\*
\*-------------------------------

.triggate
{
 lda (BlueSpec),y ;current gate position

 ldx mover_pptype
 cpx #upressplate
 beq local_raise
 cpx #rubble
 beq local_jam

\* Lower gate

.local_lower cmp #gminval ;at bottom?
 bne yeslower ;no--lower it
;yes--trigger fails
.fail jmp stopobj

.yeslower
 lda #3 ;down fast
 sta trdirec
 rts

.local_jam ldx #2 ;open & jam
 stx trdirec
 cmp #gmaxval
 bcc label_1
 lda #$ff ;"jammed open" state
 bmi label_3

.local_raise ldx #1 ;open
 stx trdirec
 cmp #$ff
 beq fail ;jammed
 cmp #gmaxval
 bcc label_1
 lda #gatetimer
.label_3 sta (BlueSpec),y ;reset timer
 bne fail
.label_1
.return
 rts
}

\*-------------------------------
\*
\*  Animate transitional objects
\*  (Advance each object to next frame in animation table)
\*
\*-------------------------------

.animtrans_cleanflag skip 1

.ANIMTRANS
{
 lda #0
 sta trobcount

 ldx numtrans ;# objs in trans (0-maxtr)
 beq return

 lda #0
 sta animtrans_cleanflag

.loop stx tempnt

 jsr animobj ;animate obj #x

 ldx tempnt

 lda trdirec ;has object stopped?
 bpl label_1 ;no

 lda #LO(-1) ;yes--mark it for deletion
 sta animtrans_cleanflag ;& set cleanup flag

.label_1 sta trdirec,x ;save direction change if any

 dex
 bne loop

 lda animtrans_cleanflag
 beq return

\*  Delete all stopped objects (trdirec = ff)
\*  (i.e., copy entire list back onto
\*  itself, omitting stopped objects)

 ldx #1 ;source index (assume numtrans > 0)
 ldy #0 ;dest index

.dloop lda trdirec,x
 cmp #$ff
 beq next

 iny
 sta trdirec,y
 lda trloc,x
 sta trloc,y
 lda trscrn,x ;source
 sta trscrn,y ;dest

.next inx

 cpx numtrans
 bcc dloop
 beq dloop

 sty numtrans
.return
 rts
}

\*-------------------------------
\*
\*  Animate TROB #x
\*
\*-------------------------------
.animobj
{
 lda trloc,x
 sta trloc
 lda trscrn,x
 sta trscrn
 lda trdirec,x
 sta trdirec

\* Find out what kind of object it is

 lda trscrn
 jsr calcblue

 ldy trloc
 lda (BlueSpec),y
 sta state ;original state

 lda (BlueType),y
 and #idmask ;objid

\* and branch to appropriate subroutine

 cmp #torch
 bne label_1
 jsr animtorch
 jmp done

.label_1 cmp #upressplate
 beq label_plate
 cmp #pressplate
 bne label_2
.label_plate jsr animplate
 jmp done

.label_2 cmp #spikes
 bne label_3
 jsr animspikes
 jmp done

.label_3 cmp #loose
 bne label_31
 jsr animfloor
 jmp done

.label_31 cmp #space ;(loose floor turns into space)
 bne label_4
 jsr animspace
 jmp done

.label_4 cmp #slicer
 bne label_5
 jsr animslicer
 jmp done

.label_5 cmp #gate
 bne label_6
 jsr animgate
 jmp done

.label_6 cmp #exit
 bne label_7
 jsr animexit
 jmp done

.label_7 cmp #flask
 bne label_8
 jsr animflask
 jmp done

.label_8 cmp #sword
 bne label_9
 jsr animsword
 jmp done

.label_9 jsr stopobj ;obj is none of these--purge it from trans list!

.done lda state
 ldy trloc
 sta (BlueSpec),y

.return
 rts
}

\*-------------------------------
\*
\* Animate exit
\*
\*-------------------------------

.animexit
{
 ldx trdirec
 bmi cont
 cpx #3
 bcs local_downfast ;>= 3: coming down fast

 lda #RaisingExit
 jsr addsound

 lda state
 clc
 adc #exitinc
 sta state

 cmp #emaxval
 bcs local_stop

.cont jmp redexit

.local_stop jsr stopobj

 lda #GateDown
 jsr addsound
 lda #s_Stairs
 ldx #15
 jsr cuesong
 lda #1
 sta exitopen
 jsr mirappear
 jmp cont

\* Exit coming down fast

.local_downfast
 cpx #maxgatevel
 bcs label_2
 inx
 stx trdirec
.label_2 lda state
 sec
 sbc gatevel,x
 sta state
 beq cont
 bcs cont

 jsr stopobj

 lda #0
 sta state

 lda #GateSlam
 jsr addsound

 jmp cont
}

\*-------------------------------
\*
\*  Animate gate
\*
\*-------------------------------

.animgate
{
 ldx trdirec
 bmi cont ;gate has stopped

 cpx #3 ;trdirec >= 3: coming down fast
 bcs local_downfast

 lda state
 cmp #$ff
 beq local_stop ;jammed open
 clc
 adc gateinc,x
 sta state

 cpx #0
 beq local_goingdown

 cmp #gmaxval
 bcs local_attop ;stop at top

 lda #RaisingGate
 jsr addsound

 jmp cont

.local_goingdown
 cmp #gminval
 beq local_stop
 bcc local_stop

 cmp #gmaxval
 bcs cont ;at top
 jsr addlowersound

.cont jmp redgate ;mark gate for redrawing

.local_stop jsr stopobj

 lda #GateDown
 jsr addsound

 jmp cont

\* Gate has reached top
\* trdirec = 1: pause, then start to close again
\* trdirec = 2: jam at top

.local_attop
 cpx #2
 bcc local_tr1
 lda #$ff ;jammed-open value
 sta state
 jmp local_stop

.local_tr1 lda #gatetimer
 sta state

 lda #0 ;down
 sta trdirec
.return
 rts

\* Down fast

.local_downfast
 cpx #maxgatevel
 bcs label_2

 inx
 stx trdirec ;trdirec is velocity index
.label_2
 lda state
 sec
 sbc gatevel,x
 sta state
 beq cont
 bcs cont

 lda #0
 sta state
 jsr stopobj

 lda #GateSlam
 jsr addsound
 jmp cont
}

\*-------------------------------
\*
\*  Animate pressplate
\*
\*-------------------------------

.animplate
{
 ldx trdirec
 bmi return_37

 lda state
 tax
 jsr gettimer
 sec
 sbc #1
 pha
 jsr chgtimer
 pla
 cmp #2
 bcs return_37 ;timer stops at t=1

 lda #PlateUp
 jsr addsound

 jsr stopobj

 jmp redplate ;add obj to redraw buffer
}
.return_37
 rts

\*-------------------------------
\*
\*  Animate slicer
\*
\*-------------------------------

.animslicer
{
 ldx trdirec
 bmi local_done

 lda state
 tax
 and #$80
 sta state ;preserve hibit
 txa
 and #$7f
 clc
 adc #1
 cmp #slicetimer+1
 bcc label_1
 lda #1 ;wrap around
.label_1 ora state
 sta state
 and #$7f ;next frame #
 cmp #slicerExt
 bne label_2

 lda #JawsClash
 jsr addsound

.label_2 lda trscrn
 cmp VisScrn ;is slicer on visible screen?
 bne local_os ;no

 lda trloc
 jsr unindex
 cpx KidBlockY ;on same level as kid?
 bne local_os ;no

 lda KidLife
 bmi local_done
 ;If kid is dead, stop all unbloodied slicers
 lda state
 and #$80
 bne local_done

\* As soon as slicer is retracted, purge it from trans list

.local_os lda state
 and #$7f
 cmp #slicerRet
 bcc local_done

.local_purge jsr stopobj

.local_done lda state
 and #$7f
 cmp #slicerRet ;retracted?
 bcs return_37 ;yes--don't bother to redraw

 jmp redslicer
}

\*-------------------------------
\*
\* Animate flask
\*
\*-------------------------------

.animflask
{
 ldx trdirec
 bmi return_37

 lda trscrn
 cmp VisScrn
 bne animflask_purge

 lda state
 and #%11100000 ;potion #
 sta mover_temp1
 lda state
 and #%00011111 ;frame #
 jsr GETFLASKFRAME
 ora mover_temp1
 sta state

 jmp redflask
}
.animflask_purge
 jmp stopobj

\*-------------------------------
\*
\* Animate gleaming sword
\*
\*-------------------------------

.animsword
{
 lda trscrn
 cmp VisScrn
 bne animflask_purge

 dec state
 bne label_1
 jsr rnd
 and #$3f
 clc
 adc #40
 sta state

.label_1 jmp redsword
}
.return_38
 rts

\*-------------------------------
\*
\* Animate torch
\*
\*-------------------------------

.animtorch
{
 ldx trdirec
 bmi return_38

 lda trscrn
 cmp VisScrn
 bne animflask_purge

 lda state
 jsr GETFLAMEFRAME
 sta state

 jmp redtorch
}

\*-------------------------------
\*
\* Get flame frame
\*
\* In/out: A = state
\*
\*-------------------------------

.GETFLAMEFRAME
{
 sta state

 jsr rnd

 cmp state
 beq label_2
 cmp #torchLast+1
 bcc label_1

 lda state
.label_2 clc
 adc #1
 cmp #torchLast+1
 bcc label_1

 lda #0 ;wrap around
.label_1
.return
 rts
}

\*-------------------------------
\*
\* Get flask frame
\*
\* In/out: A = state (low 5 bits)
\*
\*-------------------------------

.GETFLASKFRAME
{
 clc
 adc #1
 cmp #bubbLast+1
 bcc return
 lda #1
.return
 rts
}

\*-------------------------------
\*
\* Animate spikes
\*
\*-------------------------------

.animspikes
{
 ldx trdirec
 bmi local_done

 lda state
 bmi timerloop ;Hibit set: remaining 7 bits
 ;represent timer value

\* Hibit clear: remaining 7 bits represent BGDATA frame #

 inc state

 cmp #spikeExt ;is extension complete?
 beq starttimer ;yes--start timer

 cmp #spikeRet ;is retraction complete?
 bne local_done ;not yet

 lda #0
 sta state ;yes--reset to "ready" state

 jsr stopobj

.local_done jmp redspikes

\* Spike timer loop

.starttimer
 lda #spiketimer
 sta state

 bne local_done

.timerloop
 dec state

 lda state
 and #$7f
 bne return_39
;Time's up
 lda #spikeExt+1 ;First "retracting" frame
 sta state

 bne local_done
}
.return_39
 rts

\*-------------------------------
\*
\* Animate loose floor
\*
\*-------------------------------

.animfloor
{
 ldx trdirec
 bmi red

\* When timer reaches max value & loose floor detaches:
\*  (1)  Change objid from "loose floor" to "empty space"
\*  (2)  Create a MOB to take over where TROB stopped

 inc state

 lda state
 bmi wiggle ;floor is only wiggling

 cmp #loosetimer
 bcc red

\* Timer has reached max value--detach floor

 jsr makespace
 sta state

 jsr stopobj

\* and create new MOB

 lda trloc
 jsr unindex

 asl A
 asl A ;x4
 sta mobx
 stx moblevel

 lda BlockBot+1,x
 sta moby

 lda trscrn
 sta mobscrn

 lda #0
 sta mobvel
 sta mobtype

 jsr addamob

.red jmp redloose

\* Floor is only wiggling

.wiggle ldx level
 cpx #13
 beq return_39

 cmp #wiggletime+$80
 bcc red

 lda #0
 sta state
 jsr stopobj ;stop wiggling

 jmp red
}

.animspace
{
 jsr stopobj
 jmp redloose
}

\*-------------------------------
\*
\*  Stop object (set trdirec = -1)
\*
\*-------------------------------

.stopobj
{
 lda #LO(-1)
 sta trdirec
 rts
}

\*-------------------------------
\* General redraw-object routine
\*-------------------------------

.redtrobj
{
 jsr check
 lda #REDRAW_FRAMES
 jsr markred
 jsr markwipe
 jsr checkright
 lda #REDRAW_FRAMES
 jsr markred
 jmp markwipe
}

\*-------------------------------
\* redraw torch/exit
\*-------------------------------

.redexit
.redtorch
{
 jsr checkright
 lda #REDRAW_FRAMES
 jmp markmove
}

\*-------------------------------
\* redraw flask/sword
\*-------------------------------

.redsword
.redflask
{
 jsr check
 lda #REDRAW_FRAMES
 jmp markmove
}

\*-------------------------------
\* redraw loose floor
\*-------------------------------

.redloose
{
 inc trobcount
 lda #loosewipe
 sta height
 jmp redtrobj
}

\*-------------------------------
\* redraw gate
\*-------------------------------

.redgate
{
 jsr checkright ;mark piece to right of gate
 lda #REDRAW_FRAMES
 jsr markmove
 jsr markfred
 jsr checkabover ;& piece to right of gate panel
 lda #REDRAW_FRAMES
 jmp markmove
}

\*-------------------------------
\* redraw spikes
\*-------------------------------

.redspikes
{
 inc trobcount
 lda #spikewipe
 sta height
 jmp redtrobj
}

\*-------------------------------
\* redraw slicer
\*-------------------------------

.redslicer
{
 inc trobcount
 lda #slicerwipe
 sta height
 jsr check
 lda #REDRAW_FRAMES
 jsr markred
 jmp markwipe
}

\*-------------------------------
\* redraw pressplate
\*-------------------------------

.redplate
{
 lda #platewipe
 sta height
 jmp redtrobj
}

\*-------------------------------
\*
\*  Before marking a piece in redraw buffer,
\*  check whether it's visible.
\*
\*  If piece is visible onscreen:
\*    return with carry clear, y = redbuf index
\*  If piece is not visible:
\*    return with carry set
\*
\*-------------------------------

.check_no ldy #30
 sec
.check_return
 rts
.check_above
{
 cmp scrnAbove
 bne check_return

 lda trloc
 sec
 sbc #20 ;if on top row, return 0-9 and cs
 tay

 sec
 rts
}

\*-------------------------------
\*  Check (trscrn, trloc)
\*-------------------------------

.check
{
 lda trscrn
 cmp VisScrn
 bne check_above

 ldy trloc
 cpy #30 ;i.e., "clc"
 rts
}

\*-------------------------------
\*  Check piece to left of (trscrn,trloc)
\*-------------------------------

.checkleft
{
 lda trscrn
 cmp VisScrn
 bne notonscrn
;piece is on this screen
 cpy #0
 beq check_no
 cpy #10
 beq check_no
 cpy #20
 beq check_no
;yes--piece is visible
 dey
 clc
 rts

.notonscrn
 cmp scrnRight
 bne check_above
;piece is on screen to right
 ldy trloc
 cpy #0
 beq yesr
 cpy #10
 beq yesr
 cpy #20
 bne yesr

.yesr tya
 clc
 adc #9 ;mark corresponding right-edge piece
 tay ;on this screen

 clc
 rts
}

\*-------------------------------
\*  Check piece to right of (trscrn,trloc)
\*-------------------------------

.checkright
{
 lda trscrn
 cmp VisScrn
 bne notonscrn
;piece is on this screen
 ldy trloc
 cpy #9
 beq check_no

 cpy #19
 beq check_no

 cpy #29
 beq check_no
;yes
 iny
 clc
 rts

.notonscrn
 cmp scrnLeft
 bne check_above
;piece is on screen to left
 ldy trloc
 cpy #9
 beq yesl

 cpy #19
 beq yesl

 cpy #29
 bne checkright_no

.yesl tya
 sec
 sbc #9 ;mark corresponding left-edge piece
 tay ;on this screen

 clc
 rts
}
.checkright_no
{
 ldy #30
 sec
}
.return_40
 rts

\*-------------------------------
\*  Check piece above & to right of (trscrn,trloc)
\*-------------------------------

.checkabover
{
 lda trscrn
 cmp VisScrn
 bne notonscrn
;piece is on this screen
 ldy trloc
 cpy #10
 bcc local_above ;piece is on top row

 cpy #19
 beq checkright_no

 cpy #29
 beq checkright_no
;yes
 tya
 sec
 sbc #9
 tay

 clc
 rts

.local_above
 iny
 sec
 rts

.notonscrn
 cmp scrnLeft
 bne notonleft
;piece is on screen to left
 ldy trloc
 cpy #9
 beq local_yes0

 cpy #19
 beq local_yesl

 cpy #29
 bne checkright_no

.local_yesl tya
 sec
 sbc #19 ;mark corresponding left-edge piece
 tay ;on this screen

 clc
 rts

.local_yes0 ldy #0
 sec
 rts

.notonleft
 cmp scrnBelow
 bne notbelow
;piece is on screen below
 ldy trloc
 cpy #9
 bcs checkright_no
;yes--piece is on top row
 tya
 clc
 adc #21
 tay

 clc
 rts

.notbelow
 cmp scrnBelowL
 bne return_40
 ;piece is on scrn below & to left
 ldy trloc
 cpy #9
 bne checkright_no
;yes--piece is in u.r.
 ldy #20
 clc
 rts
}

\*-------------------------------
\*
\*  Extract information from LINKLOC/LINKMAP
\*
\*  In: X = mover_linkindex
\*  Out: A = info
\*
\*-------------------------------

.gettimer
{
 lda LINKMAP,x
 and #%00011111 ;pressplate timer (0-31)
 rts
}

.chgtimer ;In: A = new timer setting
{
 and #%00011111
 sta mover_temp1
 lda LINKMAP,x
 and #%11100000
 ora mover_temp1
 sta LINKMAP,x
 rts
}

.getloc
{
 lda LINKLOC,x
 and #%00011111 ;screen posn (0-29)
 rts
}

.getlastflag
{
 lda LINKLOC,x
 and #%10000000 ;last-entry flag (0-1)
 rts
}

.getscrn
{
 lda LINKLOC,x
 and #%01100000 ;low 2 bits
 lsr A
 lsr A
 sta mover_temp1
 lda LINKMAP,x
 and #%11100000 ;high 3 bits
 adc mover_temp1
 lsr A
 lsr A
 lsr A;Result: screen # (0-31)
.return
 rts
}

\*-------------------------------
\*
\*  Update all MOBs (falling floors)
\*
\*-------------------------------
.ANIMMOBS
{
 ldx nummob ;# MOBs in motion (0-maxmob)
 beq return

.loop stx tempnt
 jsr loadmob

 jsr animmob ;animate MOB #x

 jsr checkcrush ;did we just crush a character?

 ldx tempnt
 jsr savemob

 dex
 bne loop

\* Delete MOBs that have ceased to exist

 ldx #1 ;source index (assume nummob > 0)
 ldy #0 ;dest index

.dloop lda mobvel,x
 cmp #$ff
 beq next

 iny
 sta mobvel,y
 lda mobx,x ;source
 sta mobx,y ;dest
 lda moby,x
 sta moby,y
 lda mobscrn,x
 sta mobscrn,y
 lda mobtype,x
 sta mobtype,y
 lda moblevel,x
 sta moblevel,y

.next inx

 cpx nummob
 bcc dloop
 beq dloop

 sty nummob

.return
 rts
}

\*-------------------------------
\*
\*   Animate MOB #x
\*
\*-------------------------------
.animmob
{
 lda mobtype
 bne done
 jsr mobfloor
.done
 lda mobvel
 bpl return ;is object stopping?
 inc mobvel ;yes
.return
 rts
}

\*-------------------------------
\*
\*  Animate falling floor
\*
\*-------------------------------
.mobfloor
{
 lda mobvel
 bmi return
.ok1
 cmp #FFtermvel
 bcs tv
 clc
 adc #FFaccel
 sta mobvel

.tv clc
 adc moby
 sta moby

\* check for collision w/floor

 ldx mobscrn ;on null screen?
 beq null ;yes--fall on

 cmp #LO(-30) ;negative?
 bcs local_fallon ;yes--fall on

 ldx moblevel
 cmp BlockAy+1,x
 bcc local_fallon

\* Passing thru floor plane--what to do?
\* First see what's there

 ldx moblevel
 stx tempblocky

 lda mobx
 lsr A
 lsr A
 sta tempblockx

 lda mobscrn
 sta tempscrn

 jsr rdblock1 ;A = objid
 sta mover_underFF ;under falling floor

 cmp #space
 beq local_passthru

 cmp #loose
 bne crash

\* Lands on loose floor
\* Knock out loose floor & continue

 jsr knockloose

 jmp local_passthru

\* Lands on solid floor

.crash
 lda #LooseCrash
 jsr addsound

 lda mobscrn
 sta tempscrn
 lda moblevel
 sta tempblocky
 jsr SHAKEM1 ;shake loose floors

 ldx moblevel
 lda BlockAy+1,x
 sta moby

 lda #LO(-crumbletime)
 sta mobvel

 jmp makerubble

\* Passes thru floor plane

.local_passthru
 jsr passthru
.local_fallon
.return rts

\* Falling on null screen

.null
 lda moby
 cmp #192+17
 bcc return
;MOB has fallen off null screen--delete it
 lda #LO(-disappeartime)
 sta mobvel

 rts
}

\*-------------------------------
\* Knock out loose floor
\*-------------------------------
.knockloose
{
 jsr makespace
 sta (BlueSpec),y

 lda mobvel
 lsr A
 sta mobvel

 ldx tempnt
 jsr savemob ;save this MOB

\* Create new MOB (add'l falling floor)

 lda moby
 clc
 adc #6
 sta moby

 jsr passthru

 jsr addamob

\* Retrieve old MOB

 ldx tempnt
 jsr loadmob

 jmp markmob
}

\*-------------------------------
\* Make space
\* Return A = BlueSpec
\*-------------------------------
.makespace
{
 lda #space ;change objid to empty space
 sta (BlueType),y

 IF PalaceEditor
 lda #1
 rts
 ENDIF

 lda #0
 ldx BGset1
 cpx #1 ;pal?
 bne return
 lda #1 ;stripe
.return rts
}

\*-------------------------------
\* Pass thru floor plane
\*-------------------------------
.passthru
{
 inc moblevel

 lda moblevel
 cmp #3
 bcc return_19

\* ... and onto next screen
\* (NOTE: moby may be negative)

 lda moby
 sec
 sbc #192
 sta moby

 lda #0
 sta moblevel

 lda mobscrn
 jsr getdown
 sta mobscrn
}
.return_19 rts

\*-------------------------------
\* Delete MOB & change objid of floorpiece it landed on
\* If pressplate, trigger before reducing it to rubble
\*-------------------------------
.makerubble
{
 lda moblevel
 sta tempblocky

 lda mobx
 lsr A
 lsr A
 sta tempblockx

 lda mobscrn
 sta tempscrn

 jsr rdblock1

 cmp #pressplate
 beq local_pp
 cmp #upressplate
 beq local_jampp
 cmp #floor
 beq local_notpp
 cmp #spikes
 beq local_notpp
 cmp #flask
 beq local_notpp
 cmp #torch
 beq local_notpp
 bne return_19 ;can't transform this piece into rubble

.local_jampp lda #rubble
 sta (BlueType),y

.local_pp jsr pushpp ;block lands on pressplate--
 jsr rdblock1 ;crush pp & jam open all gates

.local_notpp lda #rubble
 sta (BlueType),y
 jmp markmob
}

\*-------------------------------
\* Mark MOB
\*-------------------------------
.markmob
{
 lda mobscrn
 cmp VisScrn
 bne return

 lda #loosewipe
 sta height

 jsr indexblock
 lda #REDRAW_FRAMES
 jsr markred
 jsr markwipe

 inc tempblockx

 jsr indexblock
 lda #REDRAW_FRAMES
 jsr markred
 jsr markfred
 jmp markwipe

.return rts
}

\*-------------------------------
\*
\*  Did falling floor crush anybody?
\*
\*-------------------------------
.checkcrush
{
 jsr LoadKid
 jsr chcrush1 ;return cs if crush
 bcc return_20
 jsr crushchar
 jmp SaveKid

.chcrush1
 lda mobscrn
 cmp CharScrn ;on same screen as char?
 bne no

 lda mobx
 lsr A
 lsr A
 cmp CharBlockX ;same blockx?
 bne no

 lda moby
 cmp CharY
 bcs no ;mob is below char altogether

 lda CharY
 sec
 sbc #CrushDist
 cmp moby
 bcs no
 sec ;crush!
 rts

.no clc
}
.return_20 rts

\*-------------------------------
\*
\*  Crush char with falling block
\*  (Ordered by ANIMMOB)
\*
\*-------------------------------
.crushchar
{
 lda level
 cmp #13
 beq label_1
 lda CharPosn
 cmp #5
 bcc label_1
 cmp #15
 bcc return_20 ;running-->escape

.label_1 lda CharAction
 cmp #2
 bcc ground
 cmp #7
 bne return_20

\* Action code 0,1,7 -- on ground

.ground
 ldx CharBlockY
 inx
 lda FloorY,x
 sta CharY ;align w/floor

 lda #1
 jsr decstr
 beq kill

 lda CharPosn
 cmp #109
 beq return_20
 lda #crush
 jmp jumpseq

.kill lda #hardland ;temp
 jmp jumpseq
}

\*-------------------------------
\*
\*  Add all visible MOBs to object table (to be drawn later)
\*
\*-------------------------------
.ADDMOBS
{
 ldx nummob ;# objs in motion (0-maxmob)
 beq return_22

.loop stx tempnt
 jsr loadmob

 lda mobtype
 bne label_1
 jsr ATM ;Add this MOB
.label_1
 ldx tempnt
 dex
 bne loop
}
.return_22
 rts


\*-------------------------------
\*
\*  Add this MOB to obj table (if visible)
\*
\*-------------------------------
.ATM
{
\* Is floorpiece visible onscreen?

 lda mobscrn
 cmp VisScrn
 bne ok2

 lda moby
 cmp #192+17 ;17 is generous estimate of image height
 bcc ok
 rts
.ok2
 cmp scrnBelow
 bne return_22 ;not on screen below

 lda moby
 cmp #LO(-17)
 bcs ok1
 cmp #17
 bcs return_22
.ok1
 clc
 adc #192
 sta moby ;(this change won't be saved)
.ok

\* Get block #; index char

 lda moby
 jsr getblocky ;return blocky (0-3)
 sta tempblocky

 lda mobx
 lsr A
 lsr A
 sta tempblockx

 jsr indexblock
 sty FCharIndex

\* Mark floorbuf & fredbuf of affected blocks to R

.cont1
 inc tempblockx
 jsr indexblock  ;block to R

 lda #REDRAW_FRAMES
 jsr markfloor
 jsr markfred

 lda moby
 sec
 sbc #FFheight
 jsr getblocky ;highest affected blocky
 cmp tempblocky
 beq same

 sta tempblocky
 jsr indexblock ;block to U.R.

 lda #REDRAW_FRAMES
 jsr markfloor
 jsr markfred
.same

\* Get frame #

 lda #Ffalling
 sta mover_mobframe

 jmp addmobobj ;add MOB to object table
}

\*-------------------------------
\*
\*  Add MOB to object table
\*
\*  In: mob data
\*
\*-------------------------------
.addmobobj
{
 inc objX
 ldx objX

 lda mobtype ;0 = falling floor
 ora #$80
 sta objTYP,x

 lda mobx
 sta objX,x
 lda #0
 sta objOFF,x

 lda moby
 sta objY,x

 lda mover_mobframe
 sta objIMG,x

 lda #0
 sta objCU,x
 sta objCL,x
 lda #40
 sta objCR,x

 jmp setobjindx
 rts
}

\*-------------------------------
\*
\* Shake floors
\*
\* In: A = CharBlockY
\*
\*-------------------------------

.SHAKEM
{
 ldx level
 cpx #13
 beq return_18

 sta tempblocky

 lda VisScrn
 sta tempscrn
}

.SHAKEM1
{
 ldx #9
.loop txa
 pha
 sta tempblockx

 jsr rdblock1
 cmp #loose
 bne cont

 jsr shakeit

.cont pla
 tax
 dex
 bpl loop
}
.return_18 rts

\*-------------------------------
\* Shake loose floor
\*-------------------------------
.shakeit
{
 lda (BlueSpec),y
 bmi return_18 ;already wiggling
 bne return_18 ;active

 lda #$80
 sta (BlueSpec),y

 sty trloc

 lda tempscrn ;from rdblock
 sta trscrn

 lda #1
 sta trdirec

 jmp addtrob ;add floor to trans list
}

\*-------------------------------
\ lst
\ ds 1
\ usr $a9,21,$00,*-org
\ lst off
