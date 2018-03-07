; audio.asm
; New module collecting together all sound & music functions
; Originally scattered around the Apple II code

.audio

.gtone RTS      ;jmp GTONE          BEEB TODO SOUND
.minit jmp BEEB_CUESONG     ; jmp MINIT
.mplay jmp MPLAY
.whoop BRK      ;jmp WHOOP


IF _TODO
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
ENDIF

\ On BEEB music player happens on EVENTV
\ This returns 0 when music has ended
\ Don't like that it knows VGM player internals
\ but will do for now

.MPLAY
{
 LDA vgm_player_ended
 EOR #&FF
 RTS
}

IF _TODO
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

IF _NOT_BEEB
*-------------------------------
*
* Cue song
*
* In: A = song #
*     X = # of cycles within which song must be played
*
*-------------------------------
CUESONG
 sta SongCue
 stx SongCount
 rts
ENDIF
