; beeb_palette.asm
; Beeb specific palette data for sprite plot
; from beeb_core.asm

.beeb_palette_start

\*-------------------------------
; Very lazy table for turning MODE 2 black pixels into MASK
; Used by LAYMASK and MLAYMASK (characters)
\*-------------------------------

PAGE_ALIGN
.mask_table
.map_2bpp_to_mask
; This table turns MODE 5 2bpp packed data directly into MODE 2 mask bytes
; Used by FASTMASK (background plot)
FOR byte,0,255,1
left=byte AND &AA
right=byte AND &55

IF left = 0

    IF right = 0
        EQUB &FF
    ELSE
        EQUB &AA
    ENDIF

ELSE

    IF right = 0
        EQUB &55
    ELSE
        EQUB &00
    ENDIF

ENDIF

NEXT

\*-------------------------------
; MACROs that map MODE5 2bpp data into MODE2 pixels
\*-------------------------------

MACRO MAP_2BPP_TO_MODE2 col1, col2, col3
    FOR byte,0,&CC,1
        D=(byte AND &80)>>6 OR (byte AND &8)>>3
        C=(byte AND &40)>>5 OR (byte AND &4)>>2
        B=(byte AND &20)>>4 OR (byte AND &2)>>1
        A=(byte AND &10)>>3 OR (byte AND &1)>>0
        ; Pixels DCBA (0,3)
        ; Map pairs DC and BA of left & right pixels
        IF D=0
            pD=0
        ELIF D=1
            pD=col1 AND MODE2_LEFT_MASK
        ELIF D=2
            pD=col2 AND MODE2_LEFT_MASK
        ELSE
            pD=col3 AND MODE2_LEFT_MASK
        ENDIF

        IF C=0
            pC=0
        ELIF C=1
            pC=col1 AND MODE2_RIGHT_MASK
        ELIF C=2
            pC=col2 AND MODE2_RIGHT_MASK
        ELSE
            pC=col3 AND MODE2_RIGHT_MASK
        ENDIF

        IF B=0
            pB=0
        ELIF B=1
            pB=col1 AND MODE2_LEFT_MASK
        ELIF B=2
            pB=col2 AND MODE2_LEFT_MASK
        ELSE
            pB=col3 AND MODE2_LEFT_MASK
        ENDIF

        IF A=0
            pA=0
        ELIF A=1
            pA=col1 AND MODE2_RIGHT_MASK
        ELIF A=2
            pA=col2 AND MODE2_RIGHT_MASK
        ELSE
            pA=col3 AND MODE2_RIGHT_MASK
        ENDIF

        EQUB pA OR pB OR pC OR pD
    NEXT
ENDMACRO

MACRO MAP_PAIR_TO_MODE2 col1, col2, col3
    FOR byte,0,&33,1
        B=(byte AND &20)>>4 OR (byte AND &2)>>1
        A=(byte AND &10)>>3 OR (byte AND &1)>>0
        ; Pixels DCBA (0,3)
        ; Map pairs DC and BA of left & right pixels
        IF B=0
            pB=0
        ELIF B=1
            pB=col1 AND MODE2_LEFT_MASK
        ELIF B=2
            pB=col2 AND MODE2_LEFT_MASK
        ELSE
            pB=col3 AND MODE2_LEFT_MASK
        ENDIF

        IF A=0
            pA=0
        ELIF A=1
            pA=col1 AND MODE2_RIGHT_MASK
        ELIF A=2
            pA=col2 AND MODE2_RIGHT_MASK
        ELSE
            pA=col3 AND MODE2_RIGHT_MASK
        ENDIF

        EQUB pA OR pB
    NEXT
ENDMACRO

\*-------------------------------
; Palette table maps index to our 4 colours
; Apple II = black / blue / orange / white 
\*-------------------------------

.palette_table
{
    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_WHITE_PAIR           ; 0=BRW
    EQUB 0, MODE2_BLUE_PAIR, MODE2_CYAN_PAIR, MODE2_YELLOW_PAIR         ; 1=BCY
    EQUB 0, MODE2_RED_PAIR, MODE2_YELLOW_PAIR, MODE2_WHITE_PAIR         ; 2=RYW
    EQUB 0, MODE2_BLUE_PAIR, MODE2_MAGENTA_PAIR, MODE2_YELLOW_PAIR      ; 3=BMY (Dungeon guard regular)

    EQUB 0, MODE2_RED_PAIR, MODE2_MAGENTA_PAIR, MODE2_YELLOW_PAIR       ; 4=RMY (Dungeon guard special)
    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_YELLOW_PAIR          ; 5=BRY
    EQUB 0, MODE2_CYAN_PAIR, MODE2_RED_PAIR, MODE2_YELLOW_PAIR          ; 6=CRY
    EQUB 0, MODE2_BLUE_PAIR, MODE2_GREEN_PAIR, MODE2_YELLOW_PAIR        ; 7=BGY

    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_CYAN_PAIR            ; 8=BRC
    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_GREEN_PAIR           ; 9=BRG
    EQUB 0, MODE2_RED_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR           ; 10=RCW
    EQUB 0, MODE2_YELLOW_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR        ; 11=YCW

    EQUB 0, MODE2_CYAN_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR       ; 12=CMW (player)
    EQUB 0, MODE2_BLUE_PAIR, MODE2_WHITE_PAIR, MODE2_CYAN_PAIR          ; 13=BWC (Shadow)
    EQUB 0, MODE2_YELLOW_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR     ; 14=YMW (font)
    EQUB 0, MODE2_BLUE_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR       ; 15=BMW (Palace guard regular)
    EQUB 0, MODE2_GREEN_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR      ; 16=GMW (Palace guard special)

; No longer used?
;    EQUB 0, MODE2_RED_PAIR, MODE2_MAGENTA_PAIR, MODE2_CYAN_PAIR         ; 16=RMC
;    EQUB 0, MODE2_RED_PAIR, MODE2_GREEN_PAIR, MODE2_YELLOW_PAIR         ; 17=RGY

}

BEEB_PALETTE_MAX=16

\*-------------------------------
; Expanded palette table going from 2bpp data directly to MODE 2 bytes
\*-------------------------------

.fast_palette_lookup_0
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_WHITE_PAIR           ; 0=BRW

.fast_palette_lookup_1
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_CYAN_PAIR, MODE2_YELLOW_PAIR         ; 1=BCY

.fast_palette_lookup_2
MAP_PAIR_TO_MODE2 MODE2_RED_PAIR, MODE2_YELLOW_PAIR, MODE2_WHITE_PAIR         ; 12=RYW

.fast_palette_lookup_3
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_MAGENTA_PAIR, MODE2_YELLOW_PAIR      ; 3=BMY

.fast_palette_lookup_4
MAP_PAIR_TO_MODE2 MODE2_RED_PAIR, MODE2_MAGENTA_PAIR, MODE2_YELLOW_PAIR       ; 4=RMY

.fast_palette_lookup_5
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_YELLOW_PAIR          ; 5=BRY

.fast_palette_lookup_6
MAP_PAIR_TO_MODE2 MODE2_CYAN_PAIR, MODE2_RED_PAIR, MODE2_YELLOW_PAIR          ; 6=CRY

.fast_palette_lookup_7
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_GREEN_PAIR, MODE2_YELLOW_PAIR        ; 7=BGY

.fast_palette_lookup_8
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_CYAN_PAIR            ; 8=BRC

.fast_palette_lookup_9
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_GREEN_PAIR           ; 9=BRG

.fast_palette_lookup_10
MAP_PAIR_TO_MODE2 MODE2_RED_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR           ; 10=RCW

.fast_palette_lookup_11
MAP_PAIR_TO_MODE2 MODE2_YELLOW_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR        ; 11=YCW

.fast_palette_lookup_12
MAP_PAIR_TO_MODE2 MODE2_CYAN_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR       ; 12=CMW

.fast_palette_lookup_13
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_WHITE_PAIR, MODE2_CYAN_PAIR          ; 13=BWC

.fast_palette_lookup_14
MAP_PAIR_TO_MODE2 MODE2_YELLOW_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR     ; 18=YMW

.fast_palette_lookup_15
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR       ; 15=BMW

.fast_palette_lookup_16
MAP_PAIR_TO_MODE2 MODE2_GREEN_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR       ; 16=GMW

.beeb_palette_end
