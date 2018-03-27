; POP - BBC MICRO - AUDIO ROUTINES
; Various handlers and hooks for the game code to playback SFX and MUSIC

IF _AUDIO

.beeb_audio

.beeb_audio_loaded_bank EQUB &FF

; POP BBC PORT - Music player hook
; See aux_core.asm for the jump tables
; See soundnames.h.asm for the various effects & music enums

; Start playing a game music track
; A contains song to play (1-16), and assumes correct audio bank has been loaded.
; Note that our song IDs dont match the Apple ones since we nicked them from the Master system version.
.BEEB_CUESONG
{
IF _DEBUG
    LDX audio_update_enabled
    BNE ok
    BRK
    .ok
ENDIF

    STA SongCue

    ;asl a
    asl a
    tax
    ; get address
    lda pop_game_music+1,x
    bne have_track    ; dont play if entry is 0
    STA SongCue
    RTS

    .have_track
    tay
    lda pop_game_music+0,x
    tax
    ; get bank
    lda #BEEB_AUDIO_MUSIC_BANK ;lda pop_game_music+2,x
    ; play the track
    jsr music_play

.no_track
	rts
}

; Start playing an intro music track
; A contains song to play (1-16), and assumes correct audio bank has been loaded.

.BEEB_INTROSONG
{
IF _DEBUG
    LDX audio_update_enabled
    BNE ok
    BRK
    .ok
ENDIF

    STA SongCue

    ;asl a
    asl a
    tax
    ; get address
    lda pop_title_music+1,x
    bne have_track    ; dont play if entry is 0
    STA SongCue
    RTS

    .have_track
    tay
    lda pop_title_music+0,x
    tax
    ; get bank
    lda #BEEB_AUDIO_MUSIC_BANK ;lda pop_title_music+2,x
    ; play the track
    jsr music_play

.no_track
    rts
}

IF BEEB_AUDIO_STORY_BANK=BEEB_AUDIO_EPILOG_BANK
.BEEB_EPILOGSONG
ENDIF
.BEEB_STORYSONG
{
IF _DEBUG
    LDX audio_update_enabled
    BNE ok
    BRK
    .ok
ENDIF

    STA SongCue

    ;asl a
    asl a
    tax
    ; get address
    lda pop_title_music+1,x
    bne have_track    ; dont play if entry is 0
    STA SongCue
    RTS

    .have_track
    tay
    lda pop_title_music+0,x
    tax
    ; get bank
    lda #BEEB_AUDIO_STORY_BANK ;lda pop_title_music+2,x
    ; play the track
    jsr music_play

.no_track
    rts
}

; A is audio bank number (0-2)
; Does not currently save SWR bank selection - this might need looking at.
.BEEB_LOAD_AUDIO_BANK
{
    CMP beeb_audio_loaded_bank
    BEQ already_loaded

    pha

    ; Kill all audio
    jsr music_stop
    jsr audio_sfx_stop

    ; Don't let update run
    JSR audio_update_off

    pla
    STA beeb_audio_loaded_bank
    tax

    ; preserve current SWR banksel
    lda &f4
    pha

    txa

    asl a:asl a:asl a   ; *8
    clc
    adc #LO(audio0_filename)
    tax
    lda #HI(audio0_filename)
    adc #0
    tay

    lda #BEEB_AUDIO_MUSIC_BANK                ; select ANDY
    jsr swr_select_bank

    \\ Load audio bank into ANDY
    lda #HI(ANDY_START)
    jsr disksys_load_file

    ; restore SWR bank
    pla
    jsr swr_select_bank
    
    ; OK to make noise now
    JSR audio_update_on

    .already_loaded
    rts
}

.BEEB_LOAD_STORY_BANK
{
    lda #BEEB_AUDIO_STORY_BANK
    jsr swr_select_slot

    lda #HI(pop_audio_bank1_start)
    LDX #LO(audio1_filename)
    LDY #HI(audio1_filename)
    JMP disksys_load_file
}

.BEEB_LOAD_EPILOG_BANK
{
    lda #BEEB_AUDIO_EPILOG_BANK
    jsr swr_select_slot

    lda #HI(pop_audio_bank2_start)
    LDX #LO(audio2_filename)
    LDY #HI(audio2_filename)
    JMP disksys_load_file
}

IF _AUDIO_DEBUG

SMALL_FONT_MAPCHAR
.sfx_string ; starts at offset 4
EQUS "SFX ............ ", &FF
.sfx_string_end
ASCII_MAPCHAR

; debugging function to render the last few sfx that were played
.BEEB_DEBUG_DRAW_SFX
{

    LDA #LO(sfx_string)
    STA beeb_readptr
    LDA #HI(sfx_string)
    STA beeb_readptr+1

    LDA #13
    LDX #0
    LDY #BEEB_STATUS_ROW
    JSR beeb_plot_font_string
    
    rts
}
ENDIF ; _AUDIO_DEBUG

; A should contain sfx id 0-19
.BEEB_ADDSOUND
{
IF _AUDIO_DEBUG
    pha
ENDIF

    jsr audio_play_sfx	

IF _AUDIO_DEBUG
    ldy #2
.copy2
    ldx #0
.copy
    lda sfx_string+5,x
    sta sfx_string+4,x
    inx
    cpx #12
    bne copy
    dey
    bne copy2



    pla


    tax
    and #&f0:lsr a:lsr a:lsr a:lsr a:clc:adc#1:sta sfx_string_end-4
    txa
    and #&0f:clc:adc#1:sta sfx_string_end-3
ENDIF ; _AUDIO_DEBUG


}
\\ Fall through!
.BEEB_ZEROSOUND
{
    rts
}

.BEEB_MUSIC_IS_PLAYING
{
    LDA vgm_player_ended
    EOR #&FF
    RTS
}

; call this function once to initialise the audio system
.audio_init
{
	JMP audio_update_off        ; don't update until we say so
}

\\ Initialise music player - pass in VGM_stream_data address in X/Y, RAM bank number in A, or &80 for ANDY
\\ parses header from stream

.music_play
{
    sei

    sta audio_bank

    lda &f4
    pha

    ; page in the music bank - ANDY
    lda audio_bank
    jsr swr_select_bank ; preserves X/Y

    ; X/Y contains address of vgm stream
	jsr	vgm_init_stream

  
    ; restore previously paged ROM bank
    pla
    jsr swr_select_bank

    ; override any sfx playing
    jsr audio_sfx_stop

    cli
    rts
}

.audio_sfx_stop
{
;   lda #0
;   sta pop_sound_fx+0
;   sta pop_sound_fx+1
;   rts
    JMP vgm_sfx_stop
}

; A contains sound effect id - 0 to 19
.audio_play_sfx
{
 ;   asl a
    asl a
    tax

    LDA vgm_player_ended
    BEQ skip_sfx

    ; get bank
    lda #BEEB_AUDIO_SFX_BANK ; lda pop_sound_fx+2,x
    pha
    ; get address
    lda pop_sound_fx+1,x
    tay
    lda pop_sound_fx+0,x
    tax
    pla
    ; play the track
    jsr vgm_sfx_play ;music_play

    .skip_sfx
    rts 
}



.audio_update_enabled    EQUB 0      ; flag for enabling music playback updates
.audio_bank             EQUB 0      ; SWR bank containing audio, will always be &80 now - ANDY RAM

; Enable music updates
.audio_update_on
{
    lda #1
    sta audio_update_enabled
    rts
}

; Disable music updates
.audio_update_off
{
    lda #0
    sta audio_update_enabled
	rts
}

; Stop any currently playing music and silence chip
.music_stop
{
    JMP vgm_deinit_player    
}



;------------------------------------------------------
; called by vsync handler, updates audio playback
;------------------------------------------------------
.audio_update
{
;    bra music_update_exit ; test code
    lda audio_update_enabled
    beq update_exit


    lda &f4
    pha

    ; page in the sfx bank
    lda #BEEB_AUDIO_SFX_BANK
    jsr swr_select_bank

    \\ Poll the SFX player
    jsr vgm_sfx_update

    ; page in the music bank
    lda audio_bank
    jsr swr_select_bank

    \\ Doing the music last gives it priority over SFX
	\\ Poll the music player
	jsr vgm_poll_player
    BCC still_playing

    \ Tell POP that a song has finished (some game features rely on this)
    STZ SongCue
    .still_playing

    ; restore previously paged ROM bank
    pla
    jsr swr_select_bank

.update_exit
    rts    
}

.beeb_audio_end

ENDIF ;_AUDIO