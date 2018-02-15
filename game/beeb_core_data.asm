; beeb_core_data.asm
; Beeb specific data for Core RAM
; from beeb_core.asm

.beeb_core_data_start

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
; Compressed (Exile) palette table going from 2bpp data to MODE 2 bytes
; Used by full pixel plot fns (LAY, LAYMASK) i.e. characters
\*-------------------------------

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
    EQUB HI(fast_palette_lookup_9)
    EQUB HI(fast_palette_lookup_10)
    EQUB HI(fast_palette_lookup_11)
    EQUB HI(fast_palette_lookup_12)
    EQUB HI(fast_palette_lookup_13)
    EQUB HI(fast_palette_lookup_0)
    EQUB HI(fast_palette_lookup_0)
}

\\ Apple II = black / blue / orange / white 
.palette_table
{
    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_WHITE_PAIR           ; 0=BRW
    EQUB 0, MODE2_BLUE_PAIR, MODE2_CYAN_PAIR, MODE2_YELLOW_PAIR         ; 1=BCY
    EQUB 0, MODE2_BLUE_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR          ; 2=BCW
    EQUB 0, MODE2_BLUE_PAIR, MODE2_MAGENTA_PAIR, MODE2_YELLOW_PAIR      ; 3=BMY

    EQUB 0, MODE2_RED_PAIR, MODE2_YELLOW_PAIR, MODE2_WHITE_PAIR         ; 4=RYW
    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_YELLOW_PAIR          ; 5=BRY
    EQUB 0, MODE2_CYAN_PAIR, MODE2_RED_PAIR, MODE2_YELLOW_PAIR          ; 6=CRY
    EQUB 0, MODE2_BLUE_PAIR, MODE2_GREEN_PAIR, MODE2_YELLOW_PAIR        ; 7=BGY

    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_CYAN_PAIR            ; 8=BRC
    EQUB 0, MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_GREEN_PAIR           ; 9=BRG
    EQUB 0, MODE2_RED_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR           ; 10=RCW
    EQUB 0, MODE2_YELLOW_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR        ; 11=YCW

    EQUB 0, MODE2_RED_PAIR, MODE2_YELLOW_PAIR, MODE2_MAGENTA_PAIR       ; 12=RYM
    EQUB 0, MODE2_YELLOW_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR     ; 13=YMW (player)
    EQUB 0, MODE2_BLUE_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR       ; 14=BMW (guard blue)
    EQUB 0, MODE2_GREEN_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR      ; 15=GMW (guard green)

    EQUB 0, MODE2_RED_PAIR, MODE2_MAGENTA_PAIR, MODE2_CYAN_PAIR         ; 16=RMC (cutscene)
}

BEEB_PALETTE_MAX=16

\*-------------------------------
; Expanded palette table going from 2bpp data directly to MODE 2 bytes
\*-------------------------------

.fast_palette_lookup_0
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_WHITE_PAIR           ; 0=BRW

.fast_palette_lookup_1
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_CYAN_PAIR, MODE2_YELLOW_PAIR         ; 1=BCY

PAGE_ALIGN
.fast_palette_lookup_2
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR          ; 2=BCW

.fast_palette_lookup_3
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_MAGENTA_PAIR, MODE2_YELLOW_PAIR      ; 3=BMY

.fast_palette_lookup_4
MAP_PAIR_TO_MODE2 MODE2_RED_PAIR, MODE2_YELLOW_PAIR, MODE2_WHITE_PAIR         ; 4=RYW

.fast_palette_lookup_5
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_YELLOW_PAIR          ; 5=BRY

\*-------------------------------
; Multipliction table squeezed in from PAGE_ALIGN
\*-------------------------------
.Mult16_HI          ; or shift...
FOR n,0,39,1
EQUB HI(n*16)
NEXT

PAGE_ALIGN
.fast_palette_lookup_6
MAP_PAIR_TO_MODE2 MODE2_CYAN_PAIR, MODE2_RED_PAIR, MODE2_YELLOW_PAIR          ; 6=CRY

.fast_palette_lookup_7
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_GREEN_PAIR, MODE2_YELLOW_PAIR        ; 7=BGY

.fast_palette_lookup_8
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_CYAN_PAIR            ; 8=BRC

.fast_palette_lookup_9
MAP_PAIR_TO_MODE2 MODE2_BLUE_PAIR, MODE2_RED_PAIR, MODE2_GREEN_PAIR           ; 9=BRG

\*-------------------------------
; Multipliction table squeezed in from PAGE_ALIGN
\*-------------------------------
.Mult16_LO
FOR n,0,39,1
EQUB LO(n*16)
NEXT

PAGE_ALIGN
.fast_palette_lookup_10
MAP_PAIR_TO_MODE2 MODE2_RED_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR           ; 1=RCW

.fast_palette_lookup_11
MAP_PAIR_TO_MODE2 MODE2_YELLOW_PAIR, MODE2_CYAN_PAIR, MODE2_WHITE_PAIR        ; 11=YCW

.fast_palette_lookup_12
MAP_PAIR_TO_MODE2 MODE2_RED_PAIR, MODE2_YELLOW_PAIR, MODE2_MAGENTA_PAIR       ; 12=RYM

.fast_palette_lookup_13
MAP_PAIR_TO_MODE2 MODE2_YELLOW_PAIR, MODE2_MAGENTA_PAIR, MODE2_WHITE_PAIR       ; 12=

\*-------------------------------
; Hmm, these multiplication tables include all Mult16 entries.. combine?
\*-------------------------------
.Mult8_LO
FOR n,0,79,1
EQUB LO(n*8)
NEXT

.Mult8_HI
FOR n,0,79,1
EQUB HI(n*8)
NEXT

.beeb_core_data_end
