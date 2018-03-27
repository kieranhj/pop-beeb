; POP music testbed

_DEBUG = FALSE
_AUDIO_DEBUG = FALSE

; Platform includes

INCLUDE "lib/bbc.h.asm"
INCLUDE "lib/bbc_utils.h.asm"

ORG &70
GUARD &90

; Music Libraries
INCLUDE "lib/exomiser.h.asm"
INCLUDE "lib/vgmplayer.h.asm"

ORG &1900

.code_start

INCLUDE "lib/swr.asm"


; Music & Audio routines crammed in here
INCLUDE "lib/vsync.asm"
INCLUDE "lib/exomiser.asm"
INCLUDE "lib/vgmplayer.asm"
INCLUDE "game/beeb_audio.asm"

; SM: put music in ANDY. There are a few buffers we'll need to swap/load during the game.
.pop_music_04
INCBIN "audio/music/Prince of Persia - 04 - Level Start.raw.exo"
.pop_music_05
INCBIN "audio/music/Prince of Persia - 05 - Get Sword.raw.exo"
.pop_music_06
INCBIN "audio/music/Prince of Persia - 06 - Potion.raw.exo"
.pop_music_07
INCBIN "audio/music/Prince of Persia - 07 - Death.raw.exo"
.pop_music_08
INCBIN "audio/music/Prince of Persia - 08 - Mirror Prince.raw.exo"
.pop_music_09
INCBIN "audio/music/Prince of Persia - 09 - Grand Vizier.raw.exo"

; these will probably have to be loaded on demand, for title/intro/mission screens
.pop_music_01
INCBIN "audio/music/Prince of Persia - 01 - Title Screen.raw.exo"
.pop_music_02
INCBIN "audio/music/Prince of Persia - 02 - Intro.raw.exo"
.pop_music_03
INCBIN "audio/music/Prince of Persia - 03 - Hourglass.raw.exo"


.pop_sfx_start
.pop_sfx_00 ; PlateDown
INCBIN "audio/sfx/00 platedown.raw"
.pop_sfx_01 ; PlateUp
INCBIN "audio/sfx/01 plateup.raw"
.pop_sfx_02 ; GateDown
INCBIN "audio/sfx/annoyshort.raw"
.pop_sfx_03 ; SpecialKey1
INCBIN "audio/sfx/annoyshort.raw"
.pop_sfx_04 ; SpecialKey2
INCBIN "audio/sfx/annoyshort.raw"
.pop_sfx_05 ; Splat
INCBIN "audio/sfx/05 splat.raw"
.pop_sfx_06 ; MirrorCrack
INCBIN "audio/sfx/06 mirrorcrack.raw"
.pop_sfx_07 ; LooseCrash
INCBIN "audio/sfx/07 platecrash.raw"
.pop_sfx_08 ; GotKey
INCBIN "audio/sfx/annoyshort.raw"
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
.pop_sfx_end

.track_num EQUB 0
.code_entry
{
    jsr audio_init

    jsr vsync_init

    lda #0
    sta track_num

.track_loop
    lda track_num
    clc
    adc #48
    sta &7c00+20
    lda track_num

    jsr music_play_track
    jsr &ffe0
    inc track_num
    lda track_num
    cmp #9
    bne track_loop
    
    rts
}

.code_end

SAVE "Main", code_start, code_end, code_entry 