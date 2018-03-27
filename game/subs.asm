; subs.asm
; Originally SUBS.S
; Subsystems of master

.subs
\DemoDisk = 0
\EditorDisk = 0
CheckTimer = 0
\org = $e000
\ tr on
\ lst off
\*-------------------------------
\*
\*   S  U  B  S
\*
\*-------------------------------
\ org org

IF _JMP_TABLE=FALSE
.addtorches jmp ADDTORCHES
.doflashon jmp DOFLASHON
\\.PageFlip jmp PAGEFLIP        \\ moved to hires_core.asm
\\.demo jmp DEMO                \\ moved to auto.asm
.showtime jmp SHOWTIME

.doflashoff jmp DOFLASHOFF
.lrclse BRK             ; jmp LRCLSE
\ jmp potioneffect
\ jmp checkalert
\ jmp reflection

.addslicers jmp ADDSLICERS
.pause jmp PAUSE
\ jmp bonesrise
.deadenemy jmp DEADENEMY
.playcut jmp PLAYCUT

.addlowersound jmp ADDLOWERSOUND
.RemoveObj jmp REMOVEOBJ
.addfall jmp ADDFALL
.setinitials jmp SETINITIALS
.startkid jmp STARTKID

.startkid1 jmp STARTKID1
.gravity jmp GRAVITY
.initialguards jmp INITIALGUARDS
.mirappear jmp MIRAPPEAR
.crumble jmp CRUMBLE
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
\
\*-------------------------------
\ dum $f0
\]Xcount ds 1
\]Xend ds 1
\subs_tempstate ds 1
\ dend

\
\POPside1 = $a9
\POPside2 = $ad
\
\* Message #s
\ Already defined in topctrl.asm
\LevelMsg = 1
\ContMsg = 2
\TimeMsg = 3

timemsgtimer = 20

\mirscrn = 4
\mirx = 4
\miry = 0 ;also in topctrl, auto

\*-------------------------------
IF CheckTimer
\min = 180
ELSE
\min = 1090 ;# frames per "minute"
ENDIF ;actual frame rate approx. 11 fps)

\sec = min/60
\t = 60 ;game time limit

\*-------------------------------
\ALTZPon = $c009
\ALTZPoff = $c008
\RAMWRTaux = $c005
\RAMWRTmain = $c004
\RAMRDaux = $c003
\RAMRDmain = $c002

\*-------------------------------
.SceneCount SKIP 2

\*-------------------------------
\* Level 13 only:  When you enter, trigger loose floors on
\* screen above
\*-------------------------------

.CRUMBLE
{
 lda level
 cmp #13
 bne return_52
 lda VisScrn
 cmp #23
 beq label_1
 cmp #16
 bne return_52
;Trigger blocks 2-7 on bottom row of scrn above
.label_1 lda scrnAbove
 sta tempscrn
 lda #2
 sta tempblocky
 ldx #7
.loop stx tempblockx
 jsr trigloose
 ldx tempblockx
 dex
 cpx #2
 bcs loop
}
.return_52
 rts

.trigloose
{
 jsr rdblock1
 cmp #loose
 bne return_52
 jsr rnd
 and #$0f
 eor #$ff
 clc
 adc #1
 jmp breakloose1
}

\*-------------------------------
\* Add all flasks & torches on VisScrn to trans list
\* & swords
\*-------------------------------

.ADDTORCHES
{
 lda VisScrn
 jsr calcblue

 ldy #29
.loop lda (BlueType),y
 and #idmask
 cmp #torch
 bne c1
 tya
 pha
 lda VisScrn
 jsr trigtorch
 pla
 tay
 bpl cont

.c1 cmp #flask
 bne c2
 tya
 pha
 lda VisScrn
 jsr trigflask
 pla
 tay
 bpl cont

.c2 cmp #sword
 bne cont
 tya
 pha
 lda VisScrn
 jsr trigsword
 pla
 tay
.cont dey
 bpl loop

.return
 rts
}

\*-------------------------------
\*
\* In: A = length of pause (1-256)
\*
\*-------------------------------
.PAUSE
{
.outer pha
 ldx #0
.loop dex
 bne loop
 pla
 sec
 sbc #1
 bne outer
.return
 rts
}

\*-------------------------------
\*
\*  F L A S H
\*
\*  Has a traumatic incident occured this frame?
\*  If so, do lightning flash
\*
\*-------------------------------

.DOFLASHON
{
\ jsr lrclse
\
\ jsr vblank
\
\ lda $c054
\ lda $c056 ;show lores
 STA vsync_palette_override
 rts
}

\*-------------------------------

.DOFLASHOFF
{
\ jsr vblank
\
\ lda PAGE
\ bne :1
\
\ lda $c055
\:1 lda $c057 ;show hires

 LDA #&80
 STA vsync_palette_override
 rts
}

IF _NOT_BEEB
*-------------------------------
*
* Clear lo-res screen only if we need to
*
* In: A = byte value
*
*------------------------------
LRCLSE
 cmp scrncolor ;last scrncolor
 beq ]rts

 jmp lrcls
ENDIF

\*-------------------------------
\* Add all slicers on CharBlockY to trans list
\*-------------------------------
;slicetimer = 15 ;from mover
slicersync = 3 ;# frames out of sync

.ADDSLICERS
{
 lda #slicetimer
 sta subs_tempstate

 lda CharScrn
 jsr calcblue

 ldy CharBlockY
 cpy #3
 bcs return_57

 lda Mult10,y
 tay
 clc
 adc #10
 sta sm+1
.loop
 lda (BlueType),y
 and #idmask
 cmp #slicer
 bne cont

 lda (BlueSpec),y
 tax
 and #$7f
 beq ok
 cmp #slicerRet
 bcc cont ;in mid-slice--leave it alone
.ok txa
 and #$80 ;get hibit
 ora subs_tempstate
 jsr trigslicer ;trigger slicer
 jsr getnextstate

.cont iny
.sm cpy #0
 bcc loop
}
.return_57
 rts

.getnextstate
{
 lda subs_tempstate
 sec
 sbc #slicersync
 cmp #slicerRet
 bcs ok
 clc
 adc #slicetimer+1-slicerRet
.ok sta subs_tempstate
 rts
}

\*-------------------------------
\*
\*  Special animation lists for princess's room
\*
\*-------------------------------
.ptorchx EQUB 11,27,LO(-1)      \\ APPLE II was 13,25
.ptorchoff EQUB 0,0             \\ APPLE II was 0,6
.ptorchy EQUB 112,112
.ptorchstate EQUB 1,6
.ptorchcount SKIP 1
.psandcount SKIP 1
.pstarcount SKIP 4

\*-------------------------------
\*
\*  Burn torches (Princess's room)
\*
\*-------------------------------

.pburn
{
 ldx ptorchcount ;last torch burned
 inx
 lda ptorchx,x
 bpl ok
 ldx #0
.ok stx ptorchcount
 lda ptorchx,x
 sta XCO
 lda ptorchoff,x
 sta OFFSET
 lda ptorchy,x
 sta YCO
 lda ptorchstate,x
 jsr getflameframe
 sta ptorchstate,x
 tax
 jsr psetupflame
 LDA #BEEB_SWRAM_SLOT_CHTAB678
 STA BANK       ; BEEB hideous hack
 jmp lay  ;<---DIRECT HIRES CALL        BEEB TODO check OK
}

\*-------------------------------
\*
\* Flow sand
\*
\*-------------------------------
.pflow
{
 ldx psandcount
 bmi return_57 ;no hourglass yet
 inx
 cpx #3
 bcc ok
 ldx #0
.ok stx psandcount
 ldy GlassState
 jmp flow ;<---Contains direct hires call
}

\*-------------------------------
\*
\* Twinkle stars
\*
\*-------------------------------

.pstars
{
 ldx #3
.loop lda pstarcount,x
 beq ok
 dec pstarcount,x
 bne ok
 txa
 pha
 jsr twinkle ;turn it off
 pla
 tax
.ok dex
 bpl loop

\* New twinkle?

 jsr rnd
 cmp #10
 bcs return
 jsr rnd
 and #3
 clc
 adc #5 ;A = rnd length of twinkle (5-8)
 pha
 jsr rnd
 jsr rnd
 and #3
 tax ;X = rnd star # (0-3)
 pla
 sta pstarcount,x
 jmp twinkle ;<---Contains direct hires call
.return
 RTS
}

\*-------------------------------
\*
\*  Play pre-recorded "princess" scenes
\*
\*  In: A = scene #
\*
\*-------------------------------

.AddrL EQUB LO(PlayCut0),LO(PlayCut1),LO(PlayCut2),LO(PlayCut3)
 EQUB LO(PlayCut4),LO(PlayCut5),LO(PlayCut6),LO(PlayCut7)
 EQUB LO(PlayCut8)
.AddrH EQUB HI(PlayCut0),HI(PlayCut1),HI(PlayCut2),HI(PlayCut3)
 EQUB HI(PlayCut4),HI(PlayCut5),HI(PlayCut6),HI(PlayCut7)
 EQUB HI(PlayCut8)

.PLAYCUT
{
 pha
 jsr initit
 pla
 tax

 IF 0 ;temp
 jmp PlayCut4
 ENDIF

 lda AddrL,x
 sta sm+1
 lda AddrH,x
 sta sm+2
.sm jsr $FFFF ;self-mod     \\ BEEB CAUTION - direct jump from inside a DLL - should be OK as stays in same module but...

 lda #1
 sta SPEED
.return
 rts
}

\*-------------------------------
IF DemoDisk
.PlayCut8
.PlayCut4
.PlayCut7
 brk
ELSE
\*-------------------------------
\* Cut #8: Princess sends out mouse
\*-------------------------------
.PlayCut8
{
 jsr getglass
 jsr addglass

 jsr startP8
 jsr SaveShad
 jsr startM8
 jsr SaveKid

 lda #20
 jsr play

 lda #Mleave
 jsr mjumpseq
 lda #20
 jsr play

 lda #Prise
 jsr pjumpseq

 lda #20
 jsr play

 lda #0
 sta KidPosn ;mouse disappears
 ldx #50
 lda #s_Heartbeat
 jmp PlaySongX
}

\*-------------------------------
\* Cut #4: Mouse returns to princess
\*-------------------------------
.PlayCut4
{
 jsr getglass
 jsr addglass

 jsr startP4
 jsr SaveShad
 jsr startM4
 jsr SaveKid
 lda #5
 jsr play

 lda #Pcrouch
 jsr pjumpseq
 lda #9
 jsr play

 lda #Mraise
 jsr mjumpseq

 lda #58
 jmp play
}

\*-------------------------------
\* Happy ending
\*-------------------------------
.PlayCut7
{
 lda #8
 sta SPEED

 lda #1
 sta soundon
 sta musicon ;they must listen!!

 jsr startP7
 jsr SaveShad
 lda #8
 jsr play

 jsr startK7
 jsr SaveKid
 lda #8
 jsr play

 lda #Pembrace
 jsr pjumpseq
 lda #5
 jsr play

 lda #runstop
 jsr vjumpseq
 lda #2
 jsr play

 lda #0
 sta KidPosn ;kid disappears on frame 8 of embrace

 lda #9
 jsr play

 lda  #s_Embrace
 jsr  PlaySong

 jsr startM7
 jsr SaveKid ;mouse runs in

 lda #12
 jsr play

 lda #Mclimb
 jsr mjumpseq

 lda #30
 jmp play
}
ENDIF

\*-------------------------------
\* Tragic ending
\*-------------------------------
.PlayCut6
{
 lda #22
 sta SPEED
 ldx #8 ;empty hourglass
 jsr addglass
 lda #2
 jsr play
 lda #s_Tragic
 jsr PlaySong
 lda #100
 jmp play
}

\*-------------------------------
\* Princess cut #5
\*-------------------------------
.PlayCut5
{
 jsr getglass
 cpx #7
 bcs Ominous ;sand is almost out--go for it
 jmp PlayCut1

.Ominous
 jsr getglass
 jsr addglass

 jsr startP5
 jsr SaveShad

 lda #2
 jsr play

 ldx #50
 lda #s_Heartbeat
 jsr PlaySongX

 lda #Palert
 jsr pjumpseq ;princess hears something...
 lda #12
 jsr play

 ldx #20
 lda #s_Danger
 jmp PlaySongX
}

\*-------------------------------
\* Princess cut #2 (lying down)
\*-------------------------------
.PlayCut2
{
 jsr getglass
 jsr addglass

 jsr startP2
 jsr SaveShad

 lda #2
 jsr play

 ldx #50
 lda #s_Heartbeat
 jsr PlaySongX
.return
 rts
}

\*-------------------------------
\* Princess cut #1 (standing)
\*-------------------------------
.PlayCut1
.PlayCut3
{
 jsr getglass
 jsr addglass

 jsr startP1
 jsr SaveShad

 lda #2
 jsr play

 ldx #50
 lda #s_Timer
 jmp PlaySongX
}

\*-------------------------------
\* Opening titles scene
\*-------------------------------
BEEB_CUT0_SPEED_FACTOR=4
.PlayCut0
{
 STZ level      ; this is not in game
 jsr startV0
 jsr SaveKid
 jsr startP0 ;put chars in starting posn
 jsr SaveShad

 lda #2
 jsr play ;animate 2 frames

 lda #s_Princess
 ldx #8
 jsr subs_PlaySongI     ; play song to end before continuing

 lda #5*BEEB_CUT0_SPEED_FACTOR
 jsr play

 lda #s_Squeek
 ldx #0
 jsr subs_PlaySongI ;door squeaks...
\ BEEB play creak before triggering Princess

 lda #Palert
 jsr pjumpseq ;princess hears something...
 lda #9
 jsr play

 lda #7
 sta SPEED

 lda #5*BEEB_CUT0_SPEED_FACTOR
 jsr play
 lda #Vapproach
 jsr vjumpseq
 lda #6
 jsr play
 lda #Vstop
 jsr vjumpseq
 lda #4
 jsr play ;vizier enters

\ lda #s_Vizier
\ ldx #12
\ jsr subs_PlaySongI
\ BEEB - start tune that will play across Vizier sequence
 lda #s_Vizier
 jsr BEEB_STORYSONG
 lda #12*BEEB_CUT0_SPEED_FACTOR
 jsr play
 
 lda #4*BEEB_CUT0_SPEED_FACTOR
 jsr play

 lda #Vapproach
 jsr vjumpseq
 lda #30
 jsr play
 lda #Vstop
 jsr vjumpseq
 lda #4
 jsr play ;stops in front of princess

\ lda #s_Buildup
\ ldx #25
\ jsr subs_PlaySongI
\ BEEB - just delay as song already playing
 lda #25*BEEB_CUT0_SPEED_FACTOR
 jsr play

 lda #Vraise ;raises arms
 jsr vjumpseq
 lda #1
 jsr play
 lda #Pback
 jsr pjumpseq
 lda #13
 jsr play
 ldx #0
 jsr addglass1 ;hourglass appears
 lda #5
 sta lightning
 lda #PAL_white
 sta lightcolor

 lda #12
 sta SPEED
 lda #5*BEEB_CUT0_SPEED_FACTOR
 jsr play
 lda #0
 sta psandcount ;sand starts flowing

\ lda #s_Magic
\ ldx #8
\ jsr subs_PlaySongI
\ BEEB - start tune that will play across Vizier sequence
 lda #s_Magic
 jsr BEEB_STORYSONG
 lda #8*BEEB_CUT0_SPEED_FACTOR
 jsr play

 lda #7
 sta SPEED
 lda #Vexit
 jsr vjumpseq
 lda #17
 jsr play
 ldx #1
 jsr addglass1 ;glass starts to fill
 lda #12
 jsr play
 lda #Pslump
 jsr pjumpseq
 lda #28
 jsr play

 lda #12
 sta SPEED
\ lda #s_StTimer
\ ldx #20
\ jmp subs_PlaySongI
\ BEEB - just delay as song already playing
 lda #20
 jmp play 
}

\*-------------------------------
\* Add hourglass to scene
\* In: X = state
\*-------------------------------
.addglass
 lda #0
 sta psandcount ;start sand flowing
.addglass1
{
 stx GlassState
 lda #2
 sta redrawglass
}
.return_56
 rts

\*-------------------------------
\* In: A = song #
\*     X = # cycles to play if sound is off
\*-------------------------------
.PlaySongX
{
 tay
 lda soundon
 and musicon
 bne label_1
 txa
 jmp play
.label_1 tya ;falls thru to PlaySong
}

\*-------------------------------
\*
\* Play Song (Princess's room)
\*
\* Button press ends song
\*
\* In: A = song #
\*
\*-------------------------------
.PlaySong
{
IF _AUDIO
 JSR BEEB_CUESONG               ; was jsr minit
ENDIF

; for BEEB better to run the cutscene player than go into single buffer mode and poke screen directly...
.loop
\ Check for keys
 lda #1
 jsr strobe

 lda keypress
 bmi interrupt

\ Play a frame
 LDA #1
 JSR play

\ See if music has finished or not
 jsr BEEB_MUSIC_IS_PLAYING
 cmp #0
 bne loop

.interrupt
 RTS
}

\*-------------------------------
\*
\* Play Song (Princess's room--Interruptible)
\*
\* Key or button press starts a new game
\*
\* In: A = song #
\*     X = # cycles to play if sound is off
\*
\*-------------------------------
.subs_PlaySongI
{
 tay
 lda soundon
 and musicon
 bne label_1
 txa
 beq return_56
 jmp play
.label_1 tya

IF _AUDIO
 jsr BEEB_STORYSONG             ; was jsr minit
ENDIF

; for BEEB better to run the cutscene player than go into single buffer mode and poke screen directly...
.loop
\ Check for keys
 jsr musickeys
 cmp #$80
 bcs interrupt

\ Play a frame
 LDA #1
 JSR play

\ See if music has finished or not
 jsr BEEB_MUSIC_IS_PLAYING
 cmp #0
 bne loop
 RTS

.interrupt
 jmp dostartgame
}

.return_63
 rts

\*-------------------------------

.subs_flashon
{
 lda lightning
 beq return_63
 lda lightcolor
 jsr doflashon
 JMP vblank
}

.subs_flashoff
{
 lda lightning
 beq return_63
 dec lightning
 jsr doflashoff
 JMP vblank
}

\*-------------------------------
\*
\*  Playback loop (simplified version of main loop in TOPCTRL)
\*
\*  In: A = sequence length (# of frames)
\*
\*-------------------------------

.play
{
 sta SceneCount
.playloop
 jsr rnd

 lda SPEED
 jsr pause

 jsr strobe ;strobe kbd & jstk

 lda level
 bne notdemo
 jsr demokeys
 bpl cont
 lda #1
 jmp dostartgame ;interrupted--start a new game

.notdemo
 lda keypress
 bmi return_63 ;key or button to end scene

.cont jsr subs_NextFrame ;Determine what next frame should look like

 jsr subs_flashon

 jsr subs_FrameAdv ;Update hidden page to reflect new reality
;& show it

 jsr subs_flashoff

 lda soundon
 beq label_1
\ NOT BEEB - sound played on EVENTV
\ jsr playback ;play back sound fx
 jsr zerosound
.label_1
\ NOT BEEB - sound played on EVENTV
\ jsr songcues

 dec SceneCount
 bne playloop
 rts
}

\*-------------------------------

.subs_NextFrame
{
 jsr subs_DoKid ;kid/vizier/mouse

 jsr subs_DoShad ;always princess

 rts
}

\*-------------------------------

.subs_FrameAdv
{
 jsr subs_DoFast

 jsr vblank

 jmp PageFlip
}

\*-------------------------------

.subs_DoKid
{
 jsr LoadKid
 lda CharPosn
 beq return_58

 jsr ctrlkidchar

 jsr animchar ;Get next frame from sequence table

 jsr SaveKid ;Save all changes to char data
}
.return_58
 rts

\*-------------------------------

.subs_DoShad
{
 jsr LoadShadwOp
 lda CharPosn
 beq return_58

 jsr ctrlshadchar

 jsr animchar

 jmp SaveShad
}

\*-------------------------------

.ctrlkidchar
 rts

.ctrlshadchar
 rts

\*-------------------------------

.subs_DoFast
{
\* Set up image lists

 jsr zerolsts

 lda redrawglass
 beq label_3
; dec redrawglass
 ldx GlassState
 jsr drawglass ;hourglass
.label_3
 jsr LoadKid ;can be kid or vizier
 lda CharPosn
 beq label_1
 jsr setupchar
 lda #30
 sta FCharIndex
 jsr addkidobj
.label_1
 jsr LoadShad ;always princess
 lda CharPosn
 beq label_2
 jsr setupchar
 lda #30
 sta FCharIndex
 jsr addkidobj
\ NOT BEEB
\ jsr pmask ;kludge to mask face & hair
.label_2
 jsr fast ;get char/objs into mid table

 jsr drawpost ;big white post

\* Draw to screen

 jsr pburn
 jsr pburn ;first put down 2 torch flames
 jsr pstars ;& twinkle stars

 jsr drawall ;...then draw the rest

 jmp pflow ;& flow sand

.return
 rts
}

\*-------------------------------
\*
\* Jumpseq for princess & vizier
\*
\* In: A = sequence #
\*
\*-------------------------------

.pjumpseq
{
 pha
 jsr LoadShad
 pla
 jsr jumpseq
 jmp SaveShad
}

.kjumpseq
.mjumpseq
.vjumpseq
{
 pha
 jsr LoadKid
 pla
 jsr jumpseq
 jmp SaveKid
}

\*-------------------------------
\*
\* Put characters in starting position for scene
\*
\*-------------------------------
floorY = 151

\* mouse runs to princess

.startM8
{
 jsr startM4
 lda #144
 sta CharX
 lda #Mstop
 jsr jumpseq
 jmp animchar
}

.startM4
{
 lda #24
 sta CharID
 lda #199
 sta CharX
 lda #floorY+1
 sta CharY
 lda #LO(-1)
 sta CharFace

 lda #Mscurry
 jsr jumpseq
 jmp animchar
}

\* princess w/mouse

.startP8
{
 jsr startP0
 lda #130
 sta CharX
 lda #floorY+3
 sta CharY
 lda #Pstroke
 jsr jumpseq
 jmp animchar
}

.startP4
{
 jsr startP1
 lda #142
 sta CharX
 lda #floorY+3
 sta CharY
 lda #Pstand
 jsr jumpseq
 jmp animchar
}

.startP5
{
 jsr startP0
 lda #160
 sta CharX
 rts
}

.startP2
{
 jsr startP0
 lda #89
 sta CharX
 lda #floorY
 sta CharY

 lda #Plie
 jsr jumpseq
 jmp animchar
}

.startP1
{
 jsr startP0
 lda #0
 sta CharFace
 rts
}

.startP7
{
 jsr startP0
 lda #136
 sta CharX
 lda #floorY-2
 sta CharY
 lda #Pwaiting
 ldx #1
\ NOT BEEB COPY PROTECT
\ cpx purpleflag
\ beq ok
\ lda #120 ;crash (copy protect)
.ok jsr jumpseq
 jmp animchar
}

.startM7
{
 jsr startM4
 lda #floorY-2
 sta CharY
 rts
}

.startP0
{
 lda #5
 sta CharID

 lda #120
 sta CharX
 lda #floorY
 sta CharY

 lda #LO(-1)
 sta CharFace

 lda #Pstand
 jsr jumpseq
 jmp animchar
}

.startV0
{
 lda #6
 sta CharID

 lda #197
 sta CharX
 lda #floorY
 sta CharY

 lda #LO(-1)
 sta CharFace

 lda #Vstand
 jsr jumpseq
 jmp animchar
}

.startK7
{
 lda #0
 sta CharID

 lda #198
 sta CharX
 lda #floorY-2
 sta CharY

 lda #LO(-1)
 sta CharFace

 lda #startrun
 jsr jumpseq
 jmp animchar
}

\*-------------------------------
\*
\* Init princess cut
\*
\*-------------------------------

.initit
{
\ lda #' '
\ sta scrncolor ;?           \\ NOT BEEB
 lda #0
 sta vibes
 sta redrawglass
 sta KidPosn
 sta ShadPosn
 sta ptorchcount
 ldx #3
.loop sta pstarcount,x
 dex
 bpl loop

 lda #LO(-1) ;no hourglass yet
 sta psandcount

 lda #12
 sta SPEED

 jsr zeropeels
 jsr zerored
 jsr zerosound
.return
 rts
}

\*-------------------------------
\*
\* Get hourglass state (based on time left)
\*
\* In: FrameCount
\* Out: X = glass state
\*
\*-------------------------------

.getglass
{
 jsr getminleft
 ldx #7
 lda MinLeft
 cmp #6
 bcc local_got
 dex
 cmp #$11
 bcc local_got
 dex
 cmp #$21
 bcc local_got
 dex
 cmp #$41
 bcc local_got
 dex
.local_got
.return
 rts
}

\*-------------------------------
\*
\* Show time if requested
\* (& constant time display during final minute)
\*
\* In: timerequest (0 = no, 1-2 = auto, 3 = from kbd,)
\*     4 = Vizier dead)
\*
\*-------------------------------

.SHOWTIME
{
 lda timerequest
 beq return
 lda KidLife
 bpl return

 jsr getminleft

 lda MinLeft
 cmp #2
 bcs normal
 lda SecLeft
 beq timeup

\* Countdown during final minute

 lda level
 cmp #14
 bcs normal
 bcc showsec ;stop countdown when clock stops

.timeup
 lda timerequest
 cmp #3
 bcc return ;Once t=0, show time only on kbd request

.normal
 lda msgtimer
 bne return ;wait till other msgs are gone

 STA msgdrawn       ; force this message to draw

 lda #TimeMsg
 sta message
 lda #timemsgtimer
 ldx timerequest
 cpx #4
 bcc norm
.delay lda #timemsgtimer+5 ;delay 5 cycles
.norm sta msgtimer

 lda #0
 sta timerequest
.return
 rts

.showsec
 lda SecLeft
 cmp #1;was 2
 bcc nomsg

 lda message
 cmp #TimeMsg
 beq label_2
 lda msgtimer
 bne return
 lda #TimeMsg
 sta message
.label_2 lda #1
 sta timerequest
 lda #1
 sta msgtimer
 rts
.nomsg lda #0
 sta timerequest
 sta msgtimer
 rts
}

\*-------------------------------
\* Add lowering-gate sound (only when gate is visible)
\* In: A = state
\*-------------------------------

.ADDLOWERSOUND
{
 lsr A
 LSR A  ; BEEB every 4th frame
 bcc return ;alt frames

 lda level
 cmp #3
 bne label_n
 lda trscrn
 cmp #2 ;Exception: Level 3, screen 2
 beq label_y
.label_n lda trscrn
 cmp scrnLeft
 bne label_1
 ldy trloc
 cpy #9
 beq label_y
 cpy #19
 beq label_y
 cpy #29
 beq label_y ;visible to left
.return rts

.label_1 cmp VisScrn
 bne return
 ldy trloc
 cpy #9
 beq return
 cpy #19
 beq return
 cpy #29
 beq return

.label_y lda #LoweringGate
 jmp addsound
}

\*-------------------------------
\*
\* Remove object
\*
\* In: A = lastpotion
\*
\*-------------------------------

.REMOVEOBJ
{
 sta lastpotion

 ldx #1
 stx clrbtn

 lda #floor
 sta (BlueType),y ;remove object
 lda #0
 sta (BlueSpec),y

 lda #35 ;TEMP
 sta height

 lda #REDRAW_FRAMES
 clc
 jsr markwipe
 jmp markred
}

\*-------------------------------
\*
\*  S E T  I N I T I A L S
\*
\*  Set initial states of gadgets
\*
\*-------------------------------
.SETINITIALS
{
 lda INFO ;number of screens +1
 sec
 sbc #1
 sta SCRNUM

.loop jsr DoScrn ;for every screen

 dec SCRNUM
 bne loop
 rts
}

\*-------------------------------
.DoScrn
{
 lda SCRNUM
 jsr calcblue

 ldy #29

.loop jsr getinitobj
 bcc skip
 sta (BlueSpec),y

.skip dey
 bpl loop

 rts
}

\*-------------------------------
\*
\*  S T A R T   K I D
\*
\*  Put kid in his starting position for this level
\*
\*-------------------------------
.STARTKID
{
 lda level
 cmp #3
 bne nomile

\* Level 3 milestone?

.special3
 lda milestone ;set to 1 when he gets past 1st gate
 beq nomile
 lda #LO(-1)
 sta KidStartFace
 lda #2
 sta KidStartScrn
 lda #6
 sta KidStartBlock ;put him just inside 1st gate...

 lda #7
 ldx #4
 ldy #0
 jsr rdblock
 lda #space
 sta (BlueType),y ;remove loose floor...
;& continue
.nomile
 lda KidStartScrn ;in INFO
 sta CharScrn

 lda KidStartBlock
 jsr unindex ;return A = blockx, X = blocky

 sta CharBlockX
 stx CharBlockY

 lda CharBlockX
 jsr getblockej
 clc
 adc #angle+7
 sta CharX ;put kid on starting block

 lda KidStartFace
 eor #$ff
 sta CharFace

 lda origstrength
 ldx level
 bne notdemo
 lda #4
.notdemo sta MaxKidStr
 sta KidStrength

 IF EditorDisk
 jmp normal
 ENDIF

 lda level
 cmp #1
 beq special1
 cmp #13
 beq special13
 bne normal

\* Special start for Level 1

.special1
 lda #5 ;scrn
 ldx #2 ;blockx
 ldy #0 ;blocky
 jsr rdblock
 jsr pushpp ;slam gate shut

 lda #stepfall
 jsr jumpseq
 jmp STARTKID1

\* & for level 13

.special13
 lda #running
 jsr jumpseq
 jmp STARTKID1

\* Normal start

.normal lda #turn
 jsr jumpseq ;start in standing posn
}

.STARTKID1
{
 ldx CharBlockY
 lda FloorY+1,x
 sta CharY

 lda #LO(-1)
 sta CharLife ;ff = alive

 lda #0 ;kid
 sta CharID

 lda #0
 sta CharXVel
 sta CharYVel
 sta waitingtojump
 sta weightless
 sta invert
 sta jarabove
 sta droppedout
 sta CharSword
 sta offguard

.done jsr animchar ;get next frame

\* WTLESS level only--kid falls into screen

 lda level
 cmp #7 ;WTLESS level
 bne notsp

\ NOT BEEB
\ lda yellowflag ;should be -
\ bmi :yelok
\ lda #$40
\ sta timebomb ;2nd level copy protection
\:yelok
 lda CharScrn
 cmp #17
 bne notsp
 lda #3 ;down
 jsr cut
.notsp
 jmp SaveKid ;save KidVars
.return
 rts
}

\*-------------------------------
\*
\*  G R A V I T Y
\*
\*-------------------------------
TermVelocity = 33
AccelGravity = 3
WtlessTermVel = 4
WtlessGravity = 1

.GRAVITY
{
 lda CharAction
 cmp #4
 bne return_29

 lda weightless
 bne wtless

 lda CharYVel
 clc
 adc #AccelGravity

 cmp #TermVelocity
 bcc GRAVITY_ok
 lda #TermVelocity
}
.GRAVITY_ok
 sta CharYVel
.return_29
 rts

.wtless
{
 lda CharYVel
 clc
 adc #WtlessGravity

 cmp #WtlessTermVel
 bcc GRAVITY_ok
 lda #WtlessTermVel
 bcs GRAVITY_ok
}

\*-------------------------------
\*
\*  Add falling velocity
\*
\*-------------------------------

.ADDFALL
{
 lda CharYVel
 clc
 adc CharY
 sta CharY

\* X-vel

 lda CharAction
 cmp #4 ;freefall?
 bne return_29

 lda CharXVel
 jsr addcharx
 sta CharX

 jmp rereadblocks
}

\*-------------------------------
\*
\* Set initial guard posns for entire level (call once)
\*
\*-------------------------------

.INITIALGUARDS
{
 ldy #24 ;screen #
.loop
 lda GdStartBlock-1,y
 cmp #30
 bcs nogd
 jsr unindex ;A = blockx
 jsr getblockej
 clc
 adc #angle+7
 sta GdStartX-1,y
 lda #0
 sta GdStartSeqH-1,y

.nogd dey
 bne loop
.return
 rts
}

\*-------------------------------
\*
\* Newly dead enemy--play music (or whatever)
\*
\* In: Char vars
\*
\*-------------------------------

.DEADENEMY
{
 lda level
 beq local_demo
 cmp #13
 beq wingame

 lda CharID
 cmp #1
 beq return ;shadow
 lda #s_Vict
 ldx #25
 jsr cuesong
.return rts

.local_demo lda #1
 sta milestone ;start demo, part 2
 lda #0
 sta PreRecPtr
 sta PlayCount
 rts

.wingame lda #s_Stairs      ; BEEB is Killed Jaffar tune
 ldx #25
 jsr cuesong

 lda #PAL_white
 sta lightcolor
 lda #10
 sta lightning

 lda #1
 sta exitopen
 lda #4
 sta timerequest

 lda #24
 ldx #0
 ldy #0
 jsr rdblock
 jmp pushpp ;open exit
}

\*-------------------------------
\*  Mirror appears (called by MOVER when exit opened)
\*-------------------------------

.MIRAPPEAR
{
 IF DemoDisk
 rts
 ELSE

 lda level
 cmp #4
 bne return

 lda #mirscrn
 ldx #mirx
 ldy #miry
 jsr rdblock
 lda #mirror
 sta (BlueType),y
.return
 rts
 ENDIF
}

\*-------------------------------
\ lst
\ ds 1
\ usr $a9,20,$400,*-org
\ lst off
