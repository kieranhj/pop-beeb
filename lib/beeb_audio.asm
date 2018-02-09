; POP - BBC MICRO - AUDIO ROUTINES
; Very much a WIP atm

; all filenames are 8 characters in length
.audio0_filename EQUS "Audio0 $"    ; title music
.audio1_filename EQUS "Audio1 $"    ; intro music
.audio2_filename EQUS "Audio2 $"    ; grand vizier music


; POP BBC PORT - Music player hook
; See aux_core.asm for the jump tables
; See soundnames.h.asm for the various effects & music enums

; Start playing a music track
; A contains song to play (0-8), and assumes correct audio bank has been loaded.
; Note that our song IDs dont match the Apple ones since we nicked them from the Master system version.
.BEEB_CUESONG
{
;    lda #0
    jsr music_play_track
	rts
}

; A is audio bank number (0-2)
; Does not currently save SWR bank selection - this might need looking at.
.BEEB_LOAD_AUDIO_BANK
{
    asl a:asl a:asl a   ; *8
    clc
    adc #LO(audio0_filename)
    tax
    lda #HI(audio0_filename)
    adc #0
    tay

    lda #&80                ; select ANDY
    jsr swr_select_bank

    \\ Load title music into ANDY
;    ldx #LO(music1_filename)
;    ldy #HI(music1_filename)
    lda #HI(ANDY_START)
    jsr disksys_load_file
    rts
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

    jsr music_play_sfx	

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


	rts	
}
.BEEB_ZEROSOUND
{
    rts
}


; call this function once to initialise the audio system
.audio_init
{
	jsr music_off

	rts
}

.audio_quit
{
    jsr music_off
    rts
}

\\ Initialise music player - pass in VGM_stream_data address in X/Y, RAM bank number in A, or &80 for ANDY
\\ parses header from stream

.music_play
{
    sei

    sta fx_music_bank
    stx fx_music_addr+0
    sty fx_music_addr+1

    lda &f4
    pha

    ; page in the music bank - ANDY
    lda fx_music_bank
    jsr swr_select_bank

    ldx fx_music_addr+0
    ldy fx_music_addr+1
	jsr	vgm_init_stream

  
    ; restore previously paged ROM bank
    pla
    jsr swr_select_bank

	jsr music_on


    cli
    rts
    
}



; format is: address, bank
.pop_music_tracks
IF TRUE
    EQUW pop_music_01, &8080
    EQUW pop_music_02, &8080
    EQUW pop_music_03, &8080
    EQUW pop_music_04, &8080
    EQUW pop_music_05, &8080
    EQUW pop_music_06, &8080
    EQUW pop_music_07, &8080
    EQUW pop_music_08, &8080
    EQUW pop_music_09, &8080		; #8
ENDIF

.pop_sound_fx
	EQUW pop_sfx_00, &80		; #9
	EQUW pop_sfx_01, &80		; #9
	EQUW pop_sfx_02, &80		; #9
	EQUW pop_sfx_03, &80		; #9
	EQUW pop_sfx_04, &80		; #9
	EQUW pop_sfx_05, &80		; #9
	EQUW pop_sfx_06, &80		; #9
	EQUW pop_sfx_07, &80		; #9
	EQUW pop_sfx_08, &80		; #9
	EQUW pop_sfx_09, &80		; #9
	EQUW pop_sfx_10, &80		; #9
	EQUW pop_sfx_11, &80		; #9
	EQUW pop_sfx_12, &80		; #9
	EQUW pop_sfx_13, &80		; #9
	EQUW pop_sfx_14, &80		; #9
	EQUW pop_sfx_15, &80		; #9
	EQUW pop_sfx_16, &80		; #9
	EQUW pop_sfx_17, &80		; #9
	EQUW pop_sfx_18, &80		; #9
	EQUW pop_sfx_19, &80		; #9


; A contains music track - 0 to 8
.music_play_track
{
    asl a
    asl a
    tax
    ; get bank
    lda pop_music_tracks+2,x
    pha
    ; get address
    lda pop_music_tracks+1,x
    tay
    lda pop_music_tracks+0,x
    tax
    pla
    ; play the track
    jsr music_play
    rts 
}


; A contains sound effect id - 0 to 19
.music_play_sfx
{
    asl a
    asl a
    tax
    ; get bank
    lda pop_sound_fx+2,x
    pha
    ; get address
    lda pop_sound_fx+1,x
    tay
    lda pop_sound_fx+0,x
    tax
    pla
    ; play the track
    jsr vgm_sfx_play ;music_play
    rts 
}



.fx_music_addr  SKIP 2
.fx_music_on    EQUB 0
.fx_music_bank  EQUB 0

.music_on
{
    lda #1
    sta fx_music_on
    rts
}

.music_off
{
    lda #0
    sta fx_music_on
	rts
}

.music_stop
{
	jsr music_off
    jsr vgm_deinit_player    
    rts
}

; called by vsync handler
.audio_update
{
;    bra music_update_exit ; test code
    lda fx_music_on
    beq music_update_exit


    lda &f4
    pha

    ; page in the music bank
    lda fx_music_bank
    jsr swr_select_bank


	\\ Poll the music player
	jsr vgm_poll_player

    \\ Poll the SFX player
    jsr vgm_sfx_update
    
    ; restore previously paged ROM bank
    pla
    jsr swr_select_bank

.music_update_exit
    rts    
}

