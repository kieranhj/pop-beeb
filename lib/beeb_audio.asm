; POP - BBC MICRO - AUDIO ROUTINES
; Very much a WIP atm

IF _AUDIO

; all filenames are 8 characters in length
.audio0_filename EQUS "Audio0 $"    ; title music
.audio1_filename EQUS "Audio1 $"    ; intro music
.audio2_filename EQUS "Audio2 $"    ; grand vizier music
.audio3_filename EQUS "Audio3 $"    ; game audio - sfx & music jingles


; POP BBC PORT - Music player hook
; See aux_core.asm for the jump tables
; See soundnames.h.asm for the various effects & music enums

; Start playing a game music track
; A contains song to play (1-16), and assumes correct audio bank has been loaded.
; Note that our song IDs dont match the Apple ones since we nicked them from the Master system version.
.BEEB_CUESONG
{
    ;asl a
    asl a
    tax
    ; get bank
    lda #&80 ;lda pop_game_music+2,x
    pha
    ; get address
    lda pop_game_music+1,x
    beq no_track    ; dont play if entry is 0
    tay
    lda pop_game_music+0,x
    tax
    pla
    ; play the track
    jsr music_play
.no_track
	rts
}

; Start playing an intro music track
; A contains song to play (1-16), and assumes correct audio bank has been loaded.

.BEEB_INTROSONG
{
    ;asl a
    asl a
    tax
    ; get bank
    lda #&80 ;lda pop_title_music+2,x
    pha
    ; get address
    lda pop_title_music+1,x
    beq no_track    ; dont play if entry is 0
    tay
    lda pop_title_music+0,x
    tax
    pla
    ; play the track
    jsr music_play    
.no_track
    rts
}

; A is audio bank number (0-2)
; Does not currently save SWR bank selection - this might need looking at.
.BEEB_LOAD_AUDIO_BANK
{
    pha
    jsr music_stop
    pla

    asl a:asl a:asl a   ; *8
    clc
    adc #LO(audio0_filename)
    tax
    lda #HI(audio0_filename)
    adc #0
    tay

    lda #&80                ; select ANDY
    jsr swr_select_bank


    \\ Load audio bank into ANDY
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



; format is: address, bank, indexed by POP source sound id as per soundnames.h.asm
.pop_game_music
    EQUW 0 ;, &8080
    EQUW pop_music_death;, &8080 ; s_Accid = 1
    EQUW pop_music_start;, &8080 ; s_Heroic = 2
    EQUW pop_music_start;, &8080 ; s_Danger = 3
    EQUW pop_music_sword;, &8080 ; s_Sword = 4
    EQUW pop_music_start;, &8080 ; s_Rejoin = 5
    EQUW pop_music_start;, &8080 ; s_Shadow = 6
    EQUW pop_music_sword;, &8080 ; s_Vict = 7
    EQUW pop_music_sword;, &8080 ; s_Stairs = 8
    EQUW pop_music_sword;, &8080 ; s_Upstairs = 9
    EQUW pop_music_start;, &8080 ; s_Jaffar = 10
    EQUW pop_music_potion;, &8080 ; s_Potion = 11
    EQUW pop_music_start;, &8080 ; s_ShortPot = 12
    EQUW pop_music_start;, &8080 ; s_Timer = 13
    EQUW pop_music_death;, &8080 ; s_Tragic = 14
    EQUW pop_music_start;, &8080 ; s_Embrace = 15
    EQUW pop_music_start;, &8080 ; s_Heartbeat = 16

; as per 
.pop_title_music
    EQUW 0;, &8080
    EQUW pop_music_title;, &8080 ; s_Presents = 1
    EQUW 0;, &8080 ; s_Byline = 2
    EQUW pop_music_mirror;, &8080 ; s_Title = 3
    EQUW pop_music_intro;, &8080 ; s_Prolog = 4
    EQUW 0;, &8080 ; s_Sumup = 5
    EQUW 0; there is no 6
    EQUW pop_music_intro;, &8080 ; s_Princess = 7
    EQUW 0;, &8080 ; s_Squeek = 8
    EQUW 0;, &8080 ; s_Vizier = 9
    EQUW 0;, &8080 ; s_Buildup = 10
    EQUW 0;, &8080 ; s_Magic = 11
    EQUW 0;, &8080 ; s_StTimer = 12

; These sounds map to the sound triggers named in soundnames.h.asm
.pop_sound_fx
	EQUW pop_sfx_00;, &8080		; PlateDown
	EQUW pop_sfx_01;, &8080		; PlateUp
	EQUW pop_sfx_02;, &8080		; GateDown
	EQUW pop_sfx_03;, &8080		; SpecialKey1
	EQUW pop_sfx_04;, &8080		; SpecialKey2
	EQUW pop_sfx_05;, &8080		; Splat
	EQUW pop_sfx_06;, &8080		; MirrorCrack
	EQUW pop_sfx_07;, &8080		; LooseCrash
	EQUW pop_sfx_08;, &8080		; GotKey
	EQUW pop_sfx_09;, &8080		; Footstep
	EQUW pop_sfx_10;, &8080		; RaisingExit
	EQUW pop_sfx_11;, &8080		; RaisingGate
	EQUW pop_sfx_12;, &8080		; LoweringGate
	EQUW pop_sfx_13;, &8080		; SmackWall
	EQUW pop_sfx_14;, &8080		; Impaled
	EQUW pop_sfx_15;, &8080		; GateSlam
	EQUW pop_sfx_16;, &8080		; FlashMsg
	EQUW pop_sfx_17;, &8080		; SwordClash1
	EQUW pop_sfx_18;, &8080		; SwordClash2
	EQUW pop_sfx_19;, &8080		; JawsClash

IF FALSE
; A contains music track - 0 to 8
.music_play_track
{
;    asl a
    asl a
    tax
    ; get bank
    lda #&80 ;lda pop_music_tracks+2,x
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
ENDIF

; A contains sound effect id - 0 to 19
.music_play_sfx
{
 ;   asl a
    asl a
    tax
    ; get bank
    lda #&80 ; lda pop_sound_fx+2,x
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

; Enable music updates
.music_on
{
    lda #1
    sta fx_music_on
    rts
}

; Disable music updates
.music_off
{
    lda #0
    sta fx_music_on
	rts
}

; Stop any currently playing music and silence chip
.music_stop
{
	jsr music_off
    jsr vgm_deinit_player    
    rts
}



;------------------------------------------------------
; called by vsync handler, updates audio playback
;------------------------------------------------------
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

ENDIF