; POP - BBC MICRO - AUDIO ROUTINES
; Various handlers and hooks for the game code to playback SFX and MUSIC

IF _AUDIO

.beeb_audio

.beeb_audio_loaded_bank EQUB &FF

; POP BBC PORT - Music player hook
; See aux_core.asm for the jump tables
; See soundnames.h.asm for the various effects & music enums

; Start playing a game music track
; on entry:
; A contains song to play (1-16), and assumes correct audio bank has been loaded. (max 127 songs supported per table)
; X/Y contains table of songs used for lookups
; 'audio_cuesong_bank' contains the SWR bank the audio is stored in

.audio_cuesong_bank EQUB 0
.audio_cuesong
{
    stx lut1+1
    stx lut2+1
    sty lut1+2
    sty lut2+2

IF _DEBUG
    LDX audio_update_enabled
    BNE ok
    BRK
    .ok
ENDIF

    STA SongCue

    asl a
    tax
    inx
    ; get address
.lut1
    lda &ffff,x         ; Get HI byte from music table **MODIFIED**
    bne have_track    ; dont play if entry is 0
    STA SongCue
    RTS

    .have_track
    tay
    dex
.lut2
    lda &ffff,x     ; Get LO byte from music table **MODIFIED**
    tax
    ; get bank
    lda audio_cuesong_bank ;#BEEB_AUDIO_MUSIC_BANK
    ; play the track
    jsr music_play

.no_track    
    rts
}

; A contains index of song to be played 
.BEEB_CUESONG
{
    ldx #BEEB_AUDIO_MUSIC_BANK
    stx audio_cuesong_bank
    ldx #lo(pop_game_music)
    ldy #hi(pop_game_music)
    jmp audio_cuesong
}

; Start playing an intro music track
; A contains song to play (1-16), and assumes correct audio bank has been loaded.
.BEEB_INTROSONG
{
    ldx #BEEB_AUDIO_MUSIC_BANK
    stx audio_cuesong_bank    
    ldx #lo(pop_title_music)
    ldy #hi(pop_title_music)
    jmp audio_cuesong
}

IF BEEB_AUDIO_STORY_BANK=BEEB_AUDIO_EPILOG_BANK
.BEEB_EPILOGSONG
ENDIF
.BEEB_STORYSONG
{
    ldx #BEEB_AUDIO_STORY_BANK
    stx audio_cuesong_bank    
    ldx #lo(pop_title_music)
    ldy #hi(pop_title_music)
    jmp audio_cuesong
}

IF _AUDIO_BANK_OPTIMIZATION

; on entry:
; A is the audio bank file number (ie. the filename to be loaded $.Audio0, $.Audio1 etc.)
; X is the SWR *bank* (***NOT SLOT***) to select for loading into (Slots arent supported in POP)
; Y is the high byte of the address to load to
.beeb_load_audio_bank
{
    clc
    adc #48
    sta audio_filename+5    ; write ASCII value of bank number to "$.AudioX" filename string

    txa
    jsr swr_select_bank

    tya
    ldx #LO(audio_filename)
    ldy #HI(audio_filename)
    JMP disksys_load_file    
}
ENDIF

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

    plx
    stx beeb_audio_loaded_bank
;    tax

    ; preserve current SWR banksel
    lda &f4
    pha

    txa     ; A now contains audio file number


IF _AUDIO_BANK_OPTIMIZATION
;    lda #0                          ; audio file number
    ldx #BEEB_AUDIO_MUSIC_BANK
    ldy #HI(ANDY_START)
    jsr beeb_load_audio_bank
ELSE
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
ENDIF

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
IF _AUDIO_BANK_OPTIMIZATION
    lda #1                          ; audio bank number
    ldx #BEEB_AUDIO_STORY_BANK
    ldy #HI(pop_audio_bank1_start)
    jmp beeb_load_audio_bank

ELSE    
    lda #BEEB_AUDIO_STORY_BANK
    jsr swr_select_slot

    lda #HI(pop_audio_bank1_start)
    LDX #LO(audio1_filename)
    LDY #HI(audio1_filename)
    JMP disksys_load_file
ENDIF
}

.BEEB_LOAD_EPILOG_BANK
{
IF _AUDIO_BANK_OPTIMIZATION
    lda #2                          ; audio bank number
    ldx #BEEB_AUDIO_EPILOG_BANK
    ldy #HI(pop_audio_bank2_start)
    jmp beeb_load_audio_bank

ELSE        
    lda #BEEB_AUDIO_EPILOG_BANK
    jsr swr_select_slot

    lda #HI(pop_audio_bank2_start)
    LDX #LO(audio2_filename)
    LDY #HI(audio2_filename)
    JMP disksys_load_file
ENDIF
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
    asl a
    tax

    LDA vgm_player_ended
    BEQ skip_sfx

    ; get bank
;    pha
    ; get address
    lda pop_sound_fx+1,x
    tay
    lda pop_sound_fx+0,x
    tax
;    pla
    ; play the track
    lda #BEEB_AUDIO_SFX_BANK ; lda pop_sound_fx+2,x
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
    ;lda #0
    stz audio_update_enabled
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