; core_data.asm
; Misc data bumped out of Hazel

\*-------------------------------
; Expanded palette table going from 2bpp data directly to MODE 2 bytes
\*-------------------------------

.palette_addr_LO
{
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_1)
    EQUB LO(fast_palette_lookup_2)
    EQUB LO(fast_palette_lookup_3)
    EQUB LO(fast_palette_lookup_4)
    EQUB LO(fast_palette_lookup_5)
    EQUB LO(fast_palette_lookup_6)
    EQUB LO(fast_palette_lookup_7)
    EQUB LO(fast_palette_lookup_8)
    EQUB LO(fast_palette_lookup_9)
    EQUB LO(fast_palette_lookup_10)
    EQUB LO(fast_palette_lookup_11)
    EQUB LO(fast_palette_lookup_12)
    EQUB LO(fast_palette_lookup_13)
    EQUB LO(fast_palette_lookup_14)
    EQUB LO(fast_palette_lookup_15)
    EQUB LO(fast_palette_lookup_16)
}

.palette_addr_HI
{
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_1)
    EQUB HI(fast_palette_lookup_2)
    EQUB HI(fast_palette_lookup_3)
    EQUB HI(fast_palette_lookup_4)
    EQUB HI(fast_palette_lookup_5)
    EQUB HI(fast_palette_lookup_6)
    EQUB HI(fast_palette_lookup_7)
    EQUB HI(fast_palette_lookup_8)
    EQUB HI(fast_palette_lookup_9)
    EQUB HI(fast_palette_lookup_10)
    EQUB HI(fast_palette_lookup_11)
    EQUB HI(fast_palette_lookup_12)
    EQUB HI(fast_palette_lookup_13)
    EQUB HI(fast_palette_lookup_14)
    EQUB HI(fast_palette_lookup_15)
    EQUB HI(fast_palette_lookup_16)
}


\*-------------------------------
; Audio tables map sfx / music enums to data address
\*-------------------------------

; format is: address, bank, indexed by POP source sound id as per soundnames.h.asm
.pop_game_music
{
    EQUW 0 ;, &8080
    EQUW pop_music_death;, &8080 ; s_Accid = 1 ; "accidental death" music
    EQUW pop_music_heroic;, &8080 ; s_Heroic = 2 ; "heroic death" music
    EQUW pop_music_start;, &8080 ; s_Danger = 3
    EQUW pop_music_sword;, &8080 ; s_Sword = 4
    EQUW pop_music_rejoin;, &8080 ; s_Rejoin = 5
    EQUW pop_music_shadow;, &8080 ; s_Shadow = 6
    EQUW pop_music_sword;, &8080 ; s_Vict = 7
    EQUW pop_music_beatjaffar ;, &8080 ; s_Stairs = 8
    EQUW pop_music_rejoin;, &8080 ; s_Upstairs = 9
    EQUW pop_music_jaffar;, &8080 ; s_Jaffar = 10
    EQUW pop_music_lifepotion;, &8080 ; s_Potion = 11
    EQUW pop_music_potion;, &8080 ; s_ShortPot = 12
    EQUW pop_music_timer;, &8080 ; s_Timer = 13           **BANK 4**
    EQUW pop_music_tragic;, &8080 ; s_Tragic = 14         **BANK 4**
    EQUW pop_music_embrace;, &8080 ; s_Embrace = 15       **BANK 4**
    EQUW pop_music_heartbeat;, &8080 ; s_Heartbeat = 16   **BANK 4**
}

; as per 
.pop_title_music
{
    EQUW 0;, &8080
    EQUW pop_music_intro;, &8080 ; s_Presents = 1       **BANK 0**
    EQUW 0;, &8080 ; s_Byline = 2
    EQUW 0;, &8080 ; s_Title = 3
    EQUW pop_music_prolog;, &8080 ; s_Prolog = 4        **BANK 0**
    EQUW pop_music_sumup;, &8080 ; s_Sumup = 5          **BANK 0**
    EQUW 0; there is no 6
    EQUW pop_music_princess;, &8080 ; s_Princess = 7    **STORY**
    EQUW pop_music_creak;, &8080 ; s_Squeek = 8         **STORY**
    EQUW pop_music_enters;, &8080 ; s_Vizier = 9        **STORY**
    EQUW 0;, &8080 ; s_Buildup = 10
    EQUW pop_music_leaves;, &8080 ; s_Magic = 11        **STORY**
    EQUW 0;, &8080 ; s_StTimer = 12
    EQUW pop_music_epilog;, &8080 ; s_Epilog = 13       **BANK 2**
    EQUW 0;, &8080 ; s_Curtain = 14
}

; These sounds map to the sound triggers named in soundnames.h.asm
.pop_sound_fx
{
	EQUW pop_sfx_00;, &8080		; PlateDown
	EQUW pop_sfx_01;, &8080		; PlateUp
	EQUW pop_sfx_02;, &8080		; GateDown
	EQUW pop_sfx_03;, &8080		; SpecialKey1 - dont think this is used
	EQUW pop_sfx_04;, &8080		; SpecialKey2 - dont think this is used
	EQUW pop_sfx_05;, &8080		; Splat
	EQUW pop_sfx_06;, &8080		; MirrorCrack
	EQUW pop_sfx_07;, &8080		; LooseCrash
	EQUW pop_sfx_08;, &8080		; GotKey - dont think this is used
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
    EQUW pop_music_glug; s_Glug = 17
}
