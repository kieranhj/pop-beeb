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
SAVE "Audio2", pop_audio_bank2_start, pop_audio_bank2_end, 0



;----------------------------------------------------------------
; Game audio bank
;----------------------------------------------------------------

CLEAR 0, &FFFF
ORG ANDY_START
GUARD ANDY_TOP
.pop_audio_bank3_start

.pop_music_start
INCBIN "audio/music/Prince of Persia - 04 - Level Start.raw.exo"
.pop_music_sword
INCBIN "audio/music/Prince of Persia - 05 - Get Sword.raw.exo"
.pop_music_potion
INCBIN "audio/music/Prince of Persia - 06 - Potion.raw.exo"
.pop_music_death
INCBIN "audio/music/Prince of Persia - 07 - Death.raw.exo"

.pop_sfx_start
.pop_sfx_00 ; PlateDown
INCBIN "audio/sfx/00 platedown.raw"
.pop_sfx_01 ; PlateUp
INCBIN "audio/sfx/01 plateup.raw"
.pop_sfx_02 ; GateDown
INCBIN "audio/sfx/02 gatedown.raw"

.pop_sfx_05 ; Splat
INCBIN "audio/sfx/05 splat.raw"
.pop_sfx_06 ; MirrorCrack
INCBIN "audio/sfx/06 mirrorcrack.raw"
.pop_sfx_07 ; LooseCrash
INCBIN "audio/sfx/07 platecrash.raw"

.pop_sfx_09 ; Footstep
INCBIN "audio/sfx/09 footstep.raw"
.pop_sfx_10 ; RaisingExit
INCBIN "audio/sfx/10 exitrise.raw"
.pop_sfx_11 ; RaisingGate
INCBIN "audio/sfx/11 gaterise.raw"
.pop_sfx_12 ; LoweringGate
INCBIN "audio/sfx/12 gatelower.raw"
.pop_sfx_13 ; SmackWall
INCBIN "audio/sfx/13 ungh.raw"
.pop_sfx_14 ; Impaled
INCBIN "audio/sfx/14 impale.raw"
.pop_sfx_15 ; GateSlam
INCBIN "audio/sfx/15 gateslam.raw"
.pop_sfx_16 ; FlashMsg
INCBIN "audio/sfx/16 message.raw"
.pop_sfx_17 ; SwordClash1
INCBIN "audio/sfx/17 swordparry.raw"
.pop_sfx_18 ; SwordClash2
INCBIN "audio/sfx/18 swordhit.raw"
.pop_sfx_19 ; JawsClash
INCBIN "audio/sfx/19 jawsclash.raw"

.pop_sfx_03 ; SpecialKey1
.pop_sfx_04 ; SpecialKey2
.pop_sfx_08 ; GotKey
INCBIN "audio/sfx/annoyshort.raw"



.pop_sfx_end

PRINT "SFX size = ", (pop_sfx_end - pop_sfx_start), " bytes"

.pop_audio_bank3_end
SAVE "Audio3", pop_audio_bank3_start, pop_audio_bank3_end, 0

; TODO add more banks for the in game sfx & music
