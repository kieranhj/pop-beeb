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
    EQUB LO(fast_palette_lookup_4)
    EQUB LO(fast_palette_lookup_5)
    EQUB LO(fast_palette_lookup_6)
    EQUB LO(fast_palette_lookup_7)
    EQUB LO(fast_palette_lookup_8)
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_0)
    EQUB LO(fast_palette_lookup_0)
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
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_0)
}

\\ Apple II = black / blue / orange / white 
.palette_table
{
    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_WHITE_PAIR           ; BRW
    EQUB 0, MODE2_BLUE_PAIR, MODE2_CYAN_PAIR, MODE2_YELLOW_PAIR         ; BCY
    EQUB 0, MODE2_BLUE_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR          ; BCW
    EQUB 0, MODE2_BLUE_PAIR, MODE2_MAGENTA_PAIR, MODE2_YELLOW_PAIR      ; BMY

    EQUB 0, MODE2_RED_PAIR, MODE2_YELLOW_PAIR, MODE2_WHITE_PAIR         ; RYW
    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_YELLOW_PAIR          ; BRY
    EQUB 0, MODE2_CYAN_PAIR, MODE2_RED_PAIR, MODE2_YELLOW_PAIR          ; CRY
    EQUB 0, MODE2_BLUE_PAIR, MODE2_GREEN_PAIR, MODE2_YELLOW_PAIR        ; BGY

    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_CYAN_PAIR            ; BRC
    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_GREEN_PAIR           ; BRG
    EQUB 0, MODE2_MAGENTA_PAIR, MODE2_MAGENTA_PAIR, MODE2_MAGENTA_PAIR  ; UNUSED
    EQUB 0, MODE2_MAGENTA_PAIR, MODE2_MAGENTA_PAIR, MODE2_MAGENTA_PAIR  ; UNUSED

    EQUB 0, MODE2_YELLOW_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR     ; player
    EQUB 0, MODE2_BLUE_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR       ; guard blue
    EQUB 0, MODE2_GREEN_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR      ; guard green
    EQUB 0, MODE2_RED_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR        ; guard red
}

.bgimg1pal
EQUB 0,0,0,0,1,1,2,2,2,3,3,3,3,0,3,0                    ; 1-16 = $01 - $10
EQUB 0,0,1,3,1,1,1,1,1,0,0,0,0,1,1,1                    ; 17-32 = $11 - $20
EQUB 1,0,0,0,0,0,0,0,0,0,0,1,1,1,2,2                    ; 33-48 = $21 - $30
EQUB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2                    ; 49-64 = $31 - $40
EQUB 2,2,2,2,0,0,0,4,4,0,1,1,0,0,0,0                    ; 65-80 = $41 - $50
EQUB 3,4,4,4,4,4,2,2,2,2,2,2,2,2,2,0                    ; 81-96 = $51 - $60
EQUB 4,4,4,4,2,2,2,2,2,0,5,0,0,0,0                       ; 97-111 = $61 - $6F

.bgimg2pal
EQUB 6,6,1,1,1,1,7,0,0,0,0,0,0,8,8,8                    ; 1-16 = $81 - $90
EQUB 0,0,0,0,4,0,2,2,2,9,9,0,2,4,4,2                    ; 17-32 = $91 - $A0
EQUB 0,2,2,2,2,5,0,0,0,0,0,0,0,0,4,4                    ; 33-48 = $A1 - $B0
EQUB 4,4,2                                              ; 49-51 = $B1 - $B3

.fast_palette_lookup_4
SKIP &CD

.fast_palette_lookup_5
SKIP &CD

.fast_palette_lookup_6
SKIP &CD

.fast_palette_lookup_7
SKIP &CD

.fast_palette_lookup_8
SKIP &CD

.fast_palette_lookup_9
SKIP &CD

.beeb_core_data_end
