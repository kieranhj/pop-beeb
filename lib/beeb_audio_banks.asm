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
INCBIN "audio/ip/m-lifepotion.raw.exo"
.pop_music_death
INCBIN "audio/music/Prince of Persia - 07 - Death.raw.exo"

.pop_audio_bank3_end
SAVE "Audio3", pop_audio_bank3_start, pop_audio_bank3_end, 0


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
