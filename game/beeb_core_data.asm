; beeb_core_data.asm
; Beeb specific data for Core RAM
; from beeb_core.asm

.beeb_core_data_start

\*-------------------------------
; Very lazy table for turning MODE 2 black pixels into MASK
; Could / should be in MAIN
; Used by LAYMASK and MLAYMASK (characters)

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

\*-------------------------------
; Expanded palette table going from 2bpp data directly to MODE 2 bytes
; Could / should be in MAIN

PAGE_ALIGN
.fast_palette_lookup_0
;MAP_2BPP_TO_MODE2 MODE2_CYAN_PAIR, MODE2_GREEN_PAIR, MODE2_WHITE_PAIR
SKIP &CD

\*-------------------------------
; Multipliction table squeezed in from PAGE_ALIGN
; Could / should be in MAIN
.Mult16_HI          ; or shift...
FOR n,0,39,1
EQUB HI(n*16)
NEXT

\*-------------------------------
; Expanded palette table going from 2bpp data directly to MODE 2 bytes
; For torches and blades etc.
PAGE_ALIGN
.fast_palette_lookup_1
;MAP_2BPP_TO_MODE2 MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_WHITE_PAIR
SKIP &CD

\*-------------------------------
; Multipliction table squeezed in from PAGE_ALIGN
; Could / should be in MAIN
.Mult16_LO
FOR n,0,39,1
EQUB LO(n*16)
NEXT

\*-------------------------------
; Compressed (Exile) palette table going from 2bpp data to MODE 2 bytes
; Could / should be in MAIN
; Used by full pixel plot fns (LAY, LAYMASK) i.e. characters

PAGE_ALIGN
.map_2bpp_to_mode2_pixel            ; background
{
    EQUB &00                        ; +$00 00000000 either pixel logical 0
    EQUB &10                        ; +$01 000A000a right pixel logical 1
    EQUB &20                        ; +$02 00B000b0 left pixel logical 1

    skip &0D

    EQUB &40                        ; +$10 000A000a right pixel logical 2
    EQUB &50                        ; +$11 000A000a right pixel logical 3

    skip &0E

    EQUB &80                        ; +$20 00B000b0 left pixel logical 2
    skip 1
    EQUB &A0                        ; +$22 00B000b0 left pixel logical 3
}
\\ Flip entries in this table when parity changes

.fast_palette_lookup_2
SKIP &CD

PAGE_ALIGN
.fast_palette_lookup_3
SKIP &CD

.palette_addr_LO
{
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_1)
    EQUB LO(fast_palette_lookup_2)
    EQUB LO(fast_palette_lookup_3)
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_1)
    EQUB LO(fast_palette_lookup_2)
    EQUB LO(fast_palette_lookup_3)
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_1)
    EQUB LO(fast_palette_lookup_2)
    EQUB LO(fast_palette_lookup_3)
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_1)
    EQUB LO(fast_palette_lookup_2)
    EQUB LO(fast_palette_lookup_3)
}

.palette_addr_HI
{
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_1)
    EQUB HI(fast_palette_lookup_2)
    EQUB HI(fast_palette_lookup_3)
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_1)
    EQUB HI(fast_palette_lookup_2)
    EQUB HI(fast_palette_lookup_3)
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_1)
    EQUB HI(fast_palette_lookup_2)
    EQUB HI(fast_palette_lookup_3)
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_1)
    EQUB HI(fast_palette_lookup_2)
    EQUB HI(fast_palette_lookup_3)
}

\\ Apple II = black / blue / orange / white 
.palette_table
{
    EQUB 0, MODE2_YELLOW_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR     ; player
    EQUB 0, MODE2_BLUE_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR       ; guard blue
    EQUB 0, MODE2_GREEN_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR      ; guard green
    EQUB 0, MODE2_RED_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR        ; guard red

    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_WHITE_PAIR           ; background dun 0 (flask, slicer, energy)
    EQUB 0, MODE2_BLUE_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR          ; background dun 1
    EQUB 0, MODE2_YELLOW_PAIR, MODE2_WHITE_PAIR, MODE2_RED_PAIR         ; background dun 2 (flame)
    EQUB 0, MODE2_MAGENTA_PAIR, MODE2_MAGENTA_PAIR, MODE2_MAGENTA_PAIR  ; background dun 3

    EQUB 0, MODE2_YELLOW_PAIR, MODE2_MAGENTA_PAIR, MODE2_BLUE_PAIR      ; shadow
    EQUB 0, MODE2_GREEN_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR      ; alt guard blue (green)
    EQUB 0, MODE2_RED_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR        ; alt guard green (red)
    EQUB 0, MODE2_BLUE_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR       ; alt guard red (blue)

    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_WHITE_PAIR           ; background pal 0
    EQUB 0, MODE2_CYAN_PAIR, MODE2_GREEN_PAIR, MODE2_WHITE_PAIR         ; background pal 1
    EQUB 0, MODE2_YELLOW_PAIR, MODE2_WHITE_PAIR, MODE2_RED_PAIR         ; background pal 2 (flame)
    EQUB 0, MODE2_MAGENTA_PAIR, MODE2_MAGENTA_PAIR, MODE2_MAGENTA_PAIR  ; background pal 3
}

.bgimg1pal
EQUB &5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5        ; 1-20
EQUB &5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5        ; 21-40
EQUB &5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5        ; 41-60
EQUB &5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5        ; 61-80
EQUB &5,&6,&6,&6,&6,&6,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&6,&6,&6,&6        ; 81-100
EQUB &5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5                                   ; 101-111

.bgimg2pal
EQUB &5,&5,&5,&5,&5,&5,&4,&4,&4,&4,&4,&4,&5,&4,&4,&4,&5,&5,&5,&5        ; 1-20
EQUB &4,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5        ; 21-40
EQUB &5,&5,&5,&5,&5,&5,&5,&5,&5,&5,&5                                   ; 41-51

.beeb_core_data_end
