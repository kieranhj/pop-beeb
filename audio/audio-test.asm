; POP music testbed

_DEBUG = FALSE

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
INCLUDE "lib/exomiser.asm"
INCLUDE "lib/vgmplayer.asm"
INCLUDE "lib/beeb_audio.asm"

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


.pop_landing_sfx
INCBIN "audio/music/landing-sfx.raw.exo"

.track_num EQUB 0
.code_entry
{


    jsr music_init

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