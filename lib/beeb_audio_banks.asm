; Beeb Audio Banks
; All Audio is crammed into ANDY RAM - 4Kb located at &8000 and paged in using bank select &80.

;----------------------------------------------------------------
; Title sequence music bank
;----------------------------------------------------------------

CLEAR 0, &FFFF
ORG ANDY_START
GUARD ANDY_TOP
.pop_audio_bank0_start
.pop_music_title
INCBIN "audio/music/Prince of Persia - 01 - Title Screen.raw.exo" ; 2030 bytes
.pop_music_mirror
INCBIN "audio/music/Prince of Persia - 08 - Mirror Prince.raw.exo" ; 701 bytes

.pop_audio_bank0_end
SAVE "Audio0", pop_audio_bank0_start, pop_audio_bank0_end, 0

PRINT "--------"
PRINT "AUDIO BANK 0 size = ", ~(pop_audio_bank0_end - pop_audio_bank0_start)
PRINT "AUDIO BANK 0 free = ", ~(ANDY_TOP - pop_audio_bank0_end)
PRINT "--------"


;----------------------------------------------------------------
; Intro music bank
;----------------------------------------------------------------

CLEAR 0, &FFFF
ORG ANDY_START
GUARD ANDY_TOP
.pop_audio_bank1_start
.pop_music_intro
INCBIN "audio/music/Prince of Persia - 02 - Intro.raw.exo" ; 3497 bytes
.pop_audio_bank1_end
SAVE "Audio1", pop_audio_bank1_start, pop_audio_bank1_end, 0

PRINT "--------"
PRINT "AUDIO BANK 1 size = ", ~(pop_audio_bank1_end - pop_audio_bank1_start)
PRINT "AUDIO BANK 1 free = ", ~(ANDY_TOP - pop_audio_bank1_end)
PRINT "--------"


;----------------------------------------------------------------
; Logo sequence music bank
;----------------------------------------------------------------

CLEAR 0, &FFFF
ORG ANDY_START
GUARD ANDY_TOP
.pop_audio_bank2_start
.pop_music_03
INCBIN "audio/music/Prince of Persia - 03 - Hourglass.raw.exo"
.pop_music_09
INCBIN "audio/music/Prince of Persia - 09 - Grand Vizier.raw.exo" ; 1698 bytes
.pop_audio_bank2_end
;SAVE "Audio2", pop_audio_bank2_start, pop_audio_bank2_end, 0

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
INCBIN "audio/music/Prince of Persia - 05 - Get Sword.raw.exo"
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
.pop_music_glug
INCBIN "audio/ip/3glugs.raw.exo"

.pop_audio_bank3_end
SAVE "Audio3", pop_audio_bank3_start, pop_audio_bank3_end, 0

PRINT "--------"
PRINT "AUDIO BANK 3 size = ", ~(pop_audio_bank3_end - pop_audio_bank3_start)
PRINT "AUDIO BANK 3 free = ", ~(ANDY_TOP - pop_audio_bank3_end)
PRINT "--------"

;----------------------------------------------------------------
; Cutscene audio bank
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
.pop_audio_bank4_end
SAVE "Audio4", pop_audio_bank4_start, pop_audio_bank4_end, 0

PRINT "--------"
PRINT "AUDIO BANK 4 size = ", ~(pop_audio_bank4_end - pop_audio_bank4_start)
PRINT "AUDIO BANK 4 free = ", ~(ANDY_TOP - pop_audio_bank4_end)
PRINT "--------"
