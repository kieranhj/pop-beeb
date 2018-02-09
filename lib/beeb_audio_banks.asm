; Beeb Audio Banks
; All Audio is crammed into ANDY RAM - 4Kb located at &8000 and paged in using bank select &80.

;----------------------------------------------------------------
; Title sequence music bank
;----------------------------------------------------------------

CLEAR 0, &FFFF
ORG ANDY_START
GUARD ANDY_TOP
.pop_audio_bank0_start
.pop_music_01
INCBIN "audio/music/Prince of Persia - 01 - Title Screen.raw.exo" ; 2030 bytes
.pop_music_08
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
.pop_music_02
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
.pop_music_09
INCBIN "audio/music/Prince of Persia - 09 - Grand Vizier.raw.exo" ; 1698 bytes
.pop_audio_bank2_end
SAVE "Audio2", pop_audio_bank2_start, pop_audio_bank2_end, 0


; TODO add more banks for the in game sfx & music
