; Beeb Audio Banks
; All Audio is crammed into ANDY RAM - 4Kb located at &8000 and paged in using bank select &80.

;----------------------------------------------------------------
; Title sequence music bank
;----------------------------------------------------------------

CLEAR 0, &FFFF
ORG ANDY_START
GUARD ANDY_TOP
.pop_audio_bank0_start
.pop_music_intro
INCBIN "audio/ip/m-intro-wrongsignaturevgm.raw.exo"
.pop_music_prolog
INCBIN "audio/ip/m-story1.raw.exo"
.pop_music_sumup
INCBIN "audio/ip/m-story5-end-merge-bla.raw.exo"
.pop_audio_bank0_end
SAVE "Audio0", pop_audio_bank0_start, pop_audio_bank0_end, 0

PRINT "--------"
PRINT "AUDIO BANK 0 size = ", ~(pop_audio_bank0_end - pop_audio_bank0_start)
PRINT "AUDIO BANK 0 free = ", ~(ANDY_TOP - pop_audio_bank0_end)
PRINT "--------"


;----------------------------------------------------------------
; Eiplog (you win) music bank
;----------------------------------------------------------------

CLEAR 0, &FFFF
ORG ANDY_START
GUARD ANDY_TOP
.pop_audio_bank2_start
.pop_music_epilog
INCBIN "audio/ip/m-story4.raw.exo"          ; TEMP! Just longest tune
.pop_audio_bank2_end
SAVE "Audio2", pop_audio_bank2_start, pop_audio_bank2_end, 0

PRINT "--------"
PRINT "AUDIO BANK 2 size = ", ~(pop_audio_bank2_end - pop_audio_bank2_start)
PRINT "AUDIO BANK 2 free = ", ~(ANDY_TOP - pop_audio_bank2_end)
PRINT "--------"

;----------------------------------------------------------------
; Game audio bank
;----------------------------------------------------------------

CLEAR 0, &FFFF
ORG ANDY_START
GUARD ANDY_TOP
.pop_audio_bank3_start

.pop_music_start
INCBIN "audio/ip/m-begin.raw.exo"
.pop_music_sword
INCBIN "audio/ip/m-killguard-or-sword.raw.exo"
.pop_music_potion
INCBIN "audio/ip/m-potion-sliced.raw.exo"
.pop_music_lifepotion
INCBIN "audio/ip/m-lifepotion-sliced.raw.exo"
.pop_music_death
INCBIN "audio/ip/m-playerdeath-reg.raw.exo"
.pop_music_heroic
INCBIN "audio/ip/m-playerdeath-sword.raw.exo"
.pop_music_rejoin
INCBIN "audio/ip/m-story5-end-merge-bla.raw.exo"
.pop_music_shadow
INCBIN "audio/ip/m-e4-killedbyshadow.raw.exo"
.pop_music_jaffar
INCBIN "audio/ip/m-jaffar.raw.exo"

.pop_audio_bank3_end
SAVE "Audio3", pop_audio_bank3_start, pop_audio_bank3_end, 0

PRINT "--------"
PRINT "AUDIO BANK 3 size = ", ~(pop_audio_bank3_end - pop_audio_bank3_start)
PRINT "AUDIO BANK 3 free = ", ~(ANDY_TOP - pop_audio_bank3_end)
PRINT "--------"

;----------------------------------------------------------------
; In Game Cutscene audio bank
;----------------------------------------------------------------

CLEAR 0, &FFFF
ORG ANDY_START
GUARD ANDY_TOP
.pop_audio_bank4_start
.pop_music_tragic
INCBIN "audio/ip/m-cutscene-notmuchtime.raw.exo"
.pop_music_timer
INCBIN "audio/ip/m-cutscene-pre2_4_6_C.raw.exo"
.pop_music_heartbeat
INCBIN "audio/ip/m-cutscene-pre8_9.raw.exo"
.pop_music_embrace
INCBIN "audio/ip/m-embrace.raw.exo"
.pop_audio_bank4_end
SAVE "Audio4", pop_audio_bank4_start, pop_audio_bank4_end, 0

PRINT "--------"
PRINT "AUDIO BANK 4 size = ", ~(pop_audio_bank4_end - pop_audio_bank4_start)
PRINT "AUDIO BANK 4 free = ", ~(ANDY_TOP - pop_audio_bank4_end)
PRINT "--------"
