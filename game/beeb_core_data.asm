; beeb_core_data.asm
; Beeb specific data for Core RAM
; from beeb_core.asm

.beeb_core_data_start

\*-------------------------------
; Exile palette tables
; Could / should be in MAIN

.palette_value_to_pixel_lookup
{
    MODE2_PIXELS    MODE2_RED_PAIR, MODE2_YELLOW_PAIR
    MODE2_PIXELS    MODE2_BLUE_PAIR, MODE2_CYAN_PAIR
    MODE2_PIXELS    MODE2_MAGENTA_PAIR, MODE2_RED_PAIR
    MODE2_PIXELS    MODE2_MAGENTA_PAIR, MODE2_BLUE_PAIR
    equb $EB                        ; white bg, red bg
    equb $CE                        ; yellow bg, green bg
    equb $F8                        ; cyan bg, blue bg
    equb $E6                        ; magenta bg, green bg
    equb $CC                        ; green bg, green bg
    equb $EE                        ; white bg, green bg
    equb $30                        ; blue fg, blue fg
    equb $DE                        ; yellow bg, cyan bg
    equb $EF                        ; white bg, yellow bg
    equb $CB                        ; yellow bg, red bg
    equb $FB                        ; white bg, magenta bg
    equb $FE                        ; white bg, cyan bg
}

.pixel_table
{
    ;                                 ABCDEFGH
    equb $00                        ; 00000000 0  0  
    equb $03                        ; 00000011 1  1  
    equb $0C                        ; 00001100 2  2  
    equb $0F                        ; 00001111 3  3  
    equb $30                        ; 00110000 4  4  
    equb $33                        ; 00110011 5  5  
    equb $3C                        ; 00111100 6  6  
    equb $3F                        ; 00111111 7  7  
    equb $C0                        ; 11000000 8  8  
    equb $C3                        ; 11000011 9  9  
    equb $CC                        ; 11001100 10 10
    equb $CF                        ; 11001111 11 11
    equb $F0                        ; 11110000 12 12
    equb $F3                        ; 11110011 13 13
    equb $FC                        ; 11111100 14 14
    equb $FF                        ; 11111111 15 15
}

.beeb_palette
{
    EQUB PAL_black
    EQUB PAL_red
    EQUB PAL_green
    EQUB PAL_yellow
    EQUB PAL_blue
    EQUB PAL_magenta
    EQUB PAL_cyan
    EQUB PAL_white

    EQUB PAL_black
    EQUB PAL_red
    EQUB PAL_green
    EQUB PAL_yellow
    EQUB PAL_blue
    EQUB PAL_magenta
    EQUB PAL_cyan
    EQUB PAL_white
}

\*-------------------------------
; Very lazy table for turning MODE 2 black pixels into MASK
; Could / should be in MAIN

PAGE_ALIGN
.mask_table
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
.map_2bpp_to_mode2_palN
MAP_2BPP_TO_MODE2 MODE2_CYAN_PAIR, MODE2_GREEN_PAIR, MODE2_WHITE_PAIR

\*-------------------------------
; Multipliction table squeezed in from PAGE_ALIGN
; Could / should be in MAIN
.Mult16_HI          ; or shift...
FOR n,0,39,1
EQUB HI(n*16)
NEXT

\*-------------------------------
; This table turns MODE 5 2bpp packed data directly into MODE 2 mask bytes
; Could / should be in MAIN

PAGE_ALIGN
.map_2bpp_to_mask
FOR byte,0,&CC,1
left=(byte AND &88) OR (byte AND &22)
right=(byte AND &44) OR (byte AND &11)

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
; Multipliction table squeezed in from PAGE_ALIGN
; Could / should be in MAIN
.Mult16_LO
FOR n,0,39,1
EQUB LO(n*16)
NEXT

\*-------------------------------
; Compressed (Exile) palette table going from 2bpp data to MODE 2 bytes
; Could / should be in MAIN

PAGE_ALIGN
.map_2bpp_to_mode2_pixel            ; background
{
    EQUB &00                        ; 00000000 either pixel logical 0
    EQUB &10                        ; 000A000a right pixel logical 1
    EQUB &20                        ; 00B000b0 left pixel logical 1

    skip &0D

    EQUB &40                        ; 000A000a right pixel logical 2
    EQUB &50                        ; 000A000a right pixel logical 3

    skip &0E

    EQUB &80                        ; 00B000b0 left pixel logical 2
    skip 1
    EQUB &A0                        ; 00B000b0 left pixel logical 3
}
\\ Flip entries in this table when parity changes

\*-------------------------------
; Set palette per swram bank
; Needs to be a palette per image bank
; Or even better per sprite
; Could / should be in MAIN

.bank_to_palette_temp
{
    EQUB &71            \ bg
    EQUB &72            \ chtab13
    EQUB &72            \ chtab25
    EQUB &73            \ chtab467
}

\*-------------------------------
; CRTC & ULA data required to configure out special MODE 2
; Following data could be dumped after boot!

.beeb_crtcregs
{
	EQUB 127 			; R0  horizontal total
	EQUB BEEB_SCREEN_CHARS				; R1  horizontal displayed
	EQUB 98				; R2  horizontal position
	EQUB &28			; R3  sync width
	EQUB 38				; R4  vertical total
	EQUB 0				; R5  vertical total adjust
	EQUB BEEB_SCREEN_ROWS				; R6  vertical displayed
	EQUB 34				; R7  vertical position; 35=top of screen
	EQUB 0				; R8  interlace
	EQUB 7				; R9  scanlines per row
	EQUB 32				; R10 cursor start
	EQUB 8				; R11 cursor end
	EQUB HI(beeb_screen_addr/8)		; R12 screen start address, high
	EQUB LO(beeb_screen_addr/8)		; R13 screen start address, low
}

.beeb_core_data_end
