; pop-beeb
; Prince of Persia
; Port to the BBC Master
; Shared header file

\*-------------------------------
; Defines
\*-------------------------------

CPU 1                       ; MASTER ONLY
_VERSION = $01              ; BCD version Demo.1

_DEBUG = TRUE               ; enable bounds checks and other debug fetures
_DEMO_BUILD = FALSE         ; restrict to just one level & watermark
_BOOT_ATTRACT = TRUE        ; boot to attract mode not straight into game
_START_LEVEL = 1            ; _DEBUG only start on a different level

_AUDIO = TRUE               ; enable Beeb audio code
_AUDIO_DEBUG = FALSE        ; enable audio debug text

_TODO = FALSE               ; code still to be ported
_NOT_BEEB = FALSE           ; Apple II code to remove

_IRQ_VSYNC = FALSE          ; remove irq code if doubtful
_RASTERS = FALSE            ; debug raster for timing
_JMP_TABLE = TRUE           ; use a single global jump table - BEEB REMOVE ME

REDRAW_FRAMES = 2           ; needs to be 2 if double-buffering

; Helpful MACROs

MACRO PAGE_ALIGN
    PRINT "ALIGN LOST ", ~LO(((P% AND &FF) EOR &FF)+1), " BYTES"
    ALIGN &100
ENDMACRO

MACRO RASTER_COL col
IF _RASTERS
    LDA #&00+col:STA &FE21
ENDIF
ENDMACRO

; FONT GLYPHS

HEART_GLYPH=41
EMPTY_GLYPH=42
BLANK_GLYPH=43
GLYPH_DOT=39

MACRO SMALL_FONT_MAPCHAR
    MAPCHAR '0','9',1
    MAPCHAR 'A','Z',11
    MAPCHAR 'a','z',11
    MAPCHAR '!',37
    MAPCHAR '?',38
    MAPCHAR '.',GLYPH_DOT
    MAPCHAR ',',40
    MAPCHAR ' ',0
    MAPCHAR '~',BLANK_GLYPH
    MAPCHAR ':',44
    MAPCHAR '/',45
ENDMACRO

; PALETTE DEFINITIONS

PAL_BRW=0
PAL_BCY=1
PAL_RYW=2
PAL_BMY=3           ; Dungeon guard regular
PAL_RMY=4           ; Dungeon guard special
PAL_BRY=5
PAL_CRY=6
PAL_BGY=7
PAL_BRC=8
PAL_BRG=9
PAL_RCW=10
PAL_YCW=11
PAL_CMW=12          ; player
PAL_BWC=13          ; Shadow
PAL_BMW=14          ; Palace guard regular
PAL_GMW=15          ; Palace guard special
PAL_RMC=16
PAL_RGY=17
RAL_YMW=18          ; font

PAL_FONT=RAL_YMW

; Original PoP global defines

EditorDisk = 0 ;1 = dunj, 2 = palace
CopyProtect = 0
DemoDisk = 0
FinalDisk = 1
ThreeFive = 0 ;3.5" disk?

; Platform includes

INCLUDE "lib/bbc.h.asm"
INCLUDE "lib/bbc_utils.h.asm"

\*-------------------------------
; POP BEEB screen defines
\*-------------------------------

BEEB_SCREEN_MODE = 2
BEEB_SCREEN_WIDTH = 160
BEEB_PIXELS_PER_BIT = 2
BEEB_SCREEN_HEIGHT = 200
BEEB_SCREEN_CHARS = (BEEB_SCREEN_WIDTH / BEEB_PIXELS_PER_BIT)
BEEB_SCREEN_ROWS = (BEEB_SCREEN_HEIGHT / 8)
BEEB_SCREEN_SIZE = HI((BEEB_SCREEN_CHARS * BEEB_SCREEN_ROWS * 8) + &FF) * &100
BEEB_SCREEN_ROW_BYTES = (BEEB_SCREEN_CHARS * 8)
BEEB_SCREEN_VPOS = 32

beeb_screen_addr = &8000 - BEEB_SCREEN_SIZE

\*-------------------------------
; POP BEEB status defines
\*-------------------------------

BEEB_STATUS_ROW = 24

beeb_status_addr = beeb_screen_addr + BEEB_STATUS_ROW * BEEB_SCREEN_ROW_BYTES

\*-------------------------------
; POP BEEB attract screen aka double hires
\*-------------------------------

BEEB_DOUBLE_HIRES_ROWS = 28     ; 28*8 = 224
BEEB_DOUBLE_HIRES_SIZE = (BEEB_SCREEN_CHARS * BEEB_DOUBLE_HIRES_ROWS * 8)
BEEB_DOUBLE_HIRES_VPOS = 34

beeb_double_hires_addr = &8000 - BEEB_DOUBLE_HIRES_SIZE

\*-------------------------------
; POP BEEB peel buffers
\*-------------------------------

BEEB_PEEL_BUFFER_SIZE = &C00

\*-------------------------------
; SWRAM allocations
\*-------------------------------

BEEB_SWRAM_SLOT_BGTAB1_B = 5    ; alongside code
BEEB_SWRAM_SLOT_BGTAB1_A = 4
BEEB_SWRAM_SLOT_BGTAB2 = 4
BEEB_SWRAM_SLOT_CHTAB1 = 5
BEEB_SWRAM_SLOT_CHTAB2 = 5
BEEB_SWRAM_SLOT_CHTAB3 = 5
BEEB_SWRAM_SLOT_CHTAB4 = 4
BEEB_SWRAM_SLOT_CHTAB5 = 6      ; shared with code
BEEB_SWRAM_SLOT_CHTAB678 = 4    ; blat BGTAB1
BEEB_SWRAM_SLOT_CHTAB9 = 5      ; blat CHTAB1325 (player)
BEEB_SWRAM_SLOT_AUX_B = 6       ; some code
BEEB_SWRAM_SLOT_AUX_HIGH = 7    ; all code

BEEB_AUDIO_SFX_BANK=5           ; BANK1==ROM5
PUCRUNCH_BANK=7                 ; be careful here!

\*-------------------------------
; POP defines
\*-------------------------------

INCLUDE "game/soundnames.h.asm"
INCLUDE "game/seqdata.h.asm"
