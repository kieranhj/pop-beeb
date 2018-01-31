; pop-beeb
; Prince of Persia
; Port to the BBC Master
; Main build file

\*-------------------------------
; Defines
\*-------------------------------

CPU 1                       ; MASTER ONLY
_TODO = FALSE               ; code still to be ported
_DEBUG = TRUE               ; enable bounds checks
_NOT_BEEB = FALSE           ; Apple II code to remove
_IRQ_VSYNC = FALSE          ; remove irq code if doubtful
_ALL_LEVELS = TRUE          ; allow user to play all levels
_RASTERS = FALSE            ; debug raster for timing
_HALF_PLAYER = TRUE         ; use half-height player sprites for RAM :(
_JMP_TABLE = TRUE           ; use a single global jump table - BEEB REMOVE ME
_BOOT_ATTRACT = FALSE       ; boot to attract mode not straight into game
_PEEL_IN_ANDY = FALSE       ; store peel buffers in ANDY 4K RAM - BEEB REMOVE ME

_COULD_BE_OVERLAID_IN_THEORY = FALSE     ; save the memory for now!

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

; Original PoP global defines

EditorDisk = 0 ;1 = dunj, 2 = palace
CopyProtect = 0
DemoDisk = 0
FinalDisk = 1
ThreeFive = 0 ;3.5" disk?

; Platform includes

INCLUDE "lib/bbc.h.asm"
INCLUDE "lib/bbc_utils.h.asm"

; POP includes

locals = $d0                    ; VDU workspace
locals_top = $e3

zp_top = &a0

ORG &0
GUARD locals

.DLL_REG_A skip 1
.DLL_REG_X skip 1

INCLUDE "game/eq.h.asm"
INCLUDE "game/gameeq.h.asm"

; POP defines

INCLUDE "game/soundnames.h.asm"
INCLUDE "game/seqdata.h.asm"

\*-------------------------------
; BEEB headers
\*-------------------------------

BEEB_SCREEN_MODE = 2
BEEB_SCREEN_WIDTH = 160
BEEB_PIXELS_PER_BIT = 2
BEEB_SCREEN_HEIGHT = 192
BEEB_SCREEN_CHARS = (BEEB_SCREEN_WIDTH / BEEB_PIXELS_PER_BIT)
BEEB_SCREEN_ROWS = (BEEB_SCREEN_HEIGHT / 8)
BEEB_SCREEN_SIZE = (BEEB_SCREEN_CHARS * BEEB_SCREEN_ROWS * 8)
BEEB_SCREEN_ROW_BYTES = (BEEB_SCREEN_CHARS * 8)

beeb_screen_addr = &8000 - BEEB_SCREEN_SIZE

BEEB_DOUBLE_HIRES_ROWS = 28     ; 28*8 = 224
BEEB_DOUBLE_HIRES_SIZE = (BEEB_SCREEN_CHARS * BEEB_DOUBLE_HIRES_ROWS * 8)

beeb_double_hires_addr = &8000 - BEEB_DOUBLE_HIRES_SIZE

BEEB_SWRAM_SLOT_BGTAB1_B = 2    ; alongside code
BEEB_SWRAM_SLOT_BGTAB1_A = 0
BEEB_SWRAM_SLOT_BGTAB2 = 0
BEEB_SWRAM_SLOT_CHTAB13 = 1
BEEB_SWRAM_SLOT_CHTAB25 = 1
BEEB_SWRAM_SLOT_CHTAB4 = 0
BEEB_SWRAM_SLOT_CHTAB67 = 0     ; blat BGTAB1
BEEB_SWRAM_SLOT_AUX_HIGH = 3

INCLUDE "game/beeb-plot.h.asm"

PRINT "--------"
PRINT "ZERO PAGE"
PRINT "--------"
PRINT "Zero page high watermark = ", ~P%
PRINT "Zero page free = ", ~(zp_top - P%)
PRINT "--------"

; Local ZP variables only

INCLUDE "game/frameadv.h.asm"
INCLUDE "game/hires.h.asm"
INCLUDE "game/master.h.asm"
INCLUDE "game/mover.h.asm"
INCLUDE "game/ctrl.h.asm"
INCLUDE "game/grafix.h.asm"
INCLUDE "game/coll.h.asm"
INCLUDE "game/auto.h.asm"
INCLUDE "game/ctrlsubs.h.asm"
INCLUDE "game/misc.h.asm"
INCLUDE "game/specialk.h.asm"

\*-------------------------------
; BSS data in lower RAM
\*-------------------------------

LANG_START=&300
LANG_TOP=&800

ORG LANG_START              ; VDU and language workspace
GUARD LANG_TOP              ; sound workspace

INCLUDE "game/beeb_lang.asm"

PRINT "--------"
PRINT "LANGUAGE Workspace"
PRINT "--------"
PRINT "Language workspace high watermark = ", ~P%
PRINT "Language workspace RAM free = ", ~(LANG_TOP - P%)
PRINT "--------"

\\ What about PAGE &800 = sound workspace?!

LOWER_START=&900
LOWER_TOP=&D00

ORG LOWER_START                ; envelope / speech / CFS / soft key / char defs
GUARD LOWER_TOP                ; NMI workspace

INCLUDE "game/beeb_lower.asm"

PRINT "--------"
PRINT "LOWER Workspace"
PRINT "--------"
PRINT "Lower workspace high watermark = ", ~P%
PRINT "Lower workspace RAM free = ", ~(LOWER_TOP - P%)
PRINT "--------"

\ Should be OK for disk scratch RAM to overlap run time workspace
\ Need to be aware of disc catalogue caching though
SCRATCH_RAM_ADDR = &300

\*-------------------------------
; CORE RAM
\*-------------------------------

CORE_START=&E00
CORE_TOP=&3000

ORG CORE_START
GUARD CORE_TOP             ; bottom of SHADOW RAM

.pop_beeb_start

.pop_beeb_core_start

INCLUDE "lib/disksys.asm"
INCLUDE "lib/swr.asm"
INCLUDE "lib/print.asm"

.beeb_boot_start

.swr_fail_text EQUS "Requires Master w/ 4x SWRAM banks.", 13, 0

.main_filename  EQUS "Main   $"
.aux_filename   EQUS "Aux    $"
.high_filename  EQUS "High   $"
.hazel_filename EQUS "Hazel  $"
.auxb_filename  EQUS "AuxB   $"

.pop_beeb_entry
{
    \\ Should be MASTER test and exit with nice message

    \\ SWRAM init
    jsr swr_init
    cmp #4
    bcs swr_ok

    MPRINT swr_fail_text
    rts

.swr_ok

    \\ Early system init

    LDX #&FF:TXS                ; reset stack
    SEI
    LDA #&7F:STA &FE4E          ; disable all interupts
    LDA #&82:STA &FE4E          ; enable vsync interupt
    CLI

    \\ MODE 2 is the base mode
    LDA #22
    JSR oswrch
    LDA #2
    JSR oswrch

    \\ Set smallest mode right away so we don't see any data loading
    JSR beeb_set_game_screen

    \\ Could put a loading screen here?
    \\ Or just beeb_hide_screen

    \\ Load executable overlays

    \\ Load Main

\ Ensure MAIN RAM is writeable

    LDA &FE34:AND #&FB:STA &FE34

    LDX #LO(main_filename)
    LDY #HI(main_filename)
    LDA #HI(pop_beeb_main_start)
    JSR disksys_load_file

\ Ensure SHADOW RAM is writeable

    LDA &FE34:ORA #&4:STA &FE34

    LDX #LO(main_filename)
    LDY #HI(main_filename)
    LDA #HI(pop_beeb_main_start)
    JSR disksys_load_file

\ Setup SHADOW buffers

    JSR shadow_init_buffers

    \\ Load Aux
    \\ BEEB TODO tidy up swram slots vs banks

    \\ And Aux High (SWRAM)

    LDA #2      ; hard code - assuming this goes to 6
    JSR swr_select_slot

    LDX #LO(auxb_filename)
    LDY #HI(auxb_filename)
    LDA #HI(pop_beeb_aux_b_start)
    JSR disksys_load_file

    LDA #BEEB_SWRAM_SLOT_AUX_HIGH   \\ assuming this goes to 7
    JSR swr_select_slot

\\ AUX (Deprecated)
\    LDX #LO(aux_filename)
\    LDY #HI(aux_filename)
\    LDA #HI(pop_beeb_aux_start)
\    JSR disksys_load_file

    \\ And Aux High (SWRAM)

    LDX #LO(high_filename)
    LDY #HI(high_filename)
    LDA #HI(pop_beeb_aux_high_start)
    JSR disksys_load_file

\ Ensure HAZEL RAM is writeable - assume this says writable throughout?

    LDA &FE34:ORA #&8:STA &FE34

    \\ And Aux HAZEL

    LDX #LO(hazel_filename)
    LDY #HI(hazel_filename)
    LDA #HI(pop_beeb_aux_hazel_data_start)
    JSR disksys_load_file

    \\ Remain in AUX...doesn't mean anything anymore as AUX = SWRAM x2

    LDA #0
    STA beeb_vsync_count
    IF _DEBUG
    STA bgTOP
    STA fgTOP
    STA wipeTOP
    STA peelTOP
    STA midTOP
    STA objTOP
    STA msgTOP
    ENDIF

    IF _IRQ_VSYNC
    JSR beeb_irq_init
    ENDIF

IF _DEBUG
\    JMP beeb_test_load_all_levels
\    JMP beeb_test_sprite_plot
ENDIF

    \\ Actual POP
    \\ Would have been entered directly by the boot loader on Apple II

    JMP firstboot
}

.beeb_boot_end

; Global jump table

IF _JMP_TABLE
INCLUDE "game/aux_core.asm"
ENDIF

; Beeb source in CORE

INCLUDE "game/beeb_core.asm"

; PoP source in CORE memory (always present)

INCLUDE "game/master.asm"
master_end=P%
INCLUDE "game/topctrl.asm"
topctrl_end=P%
INCLUDE "game/grafix.asm"
grafix_end=P%
INCLUDE "game/hires_core.asm"
hires_core_end=P%
INCLUDE "game/audio.asm"
audio_end=P%

; Used to be in Main but unrolled code pushed it out

; PoP gameplay code moved from AUX memory

.pop_beeb_core_end

.pop_beeb_data_start

; Data in CORE memory (always present)

; PoP gameplay data moved from AUX memory

.pop_beeb_data_end
.pop_beeb_end

; Save Core executable

SAVE "Core", pop_beeb_start, pop_beeb_end, pop_beeb_entry

; Run time initalised data in Core

.pop_beeb_bss_start

INCLUDE "game/eq.asm"
INCLUDE "game/gameeq.asm"

.pop_beeb_bss_end

; Core RAM stats

PRINT "--------"
PRINT "CORE Modules"
PRINT "--------"
PRINT "DISKSYS size = ", ~(beeb_disksys_end - beeb_disksys_start)
PRINT "SWR size = ", ~(beeb_swr_end - beeb_swr_start)
PRINT "PRINT size = ", ~(beeb_print_end - beeb_print_start)
PRINT "BEEB BOOT size = ", ~(beeb_boot_end - beeb_boot_start)
PRINT "AUX CORE (jump table) size = ", ~(aux_core_end - aux_core_start)
PRINT "BEEB CORE size = ", ~(beeb_core_end - beeb_core_start)
PRINT "MASTER size = ", ~(master_end - master)
PRINT "TOPCTRL size = ", ~(topctrl_end - topctrl)
PRINT "GRAFIX size = ", ~(grafix_end - grafix)
PRINT "HIRES (CORE) size = ", ~(hires_core_end - hires_core)
PRINT "AUDIO size = ", ~(audio_end - audio)
PRINT "--------"
PRINT "Core code size = ", ~(pop_beeb_core_end - pop_beeb_core_start)
PRINT "Core data size = ", ~(pop_beeb_data_end - pop_beeb_data_start)
PRINT "Core BSS size = ", ~(pop_beeb_bss_end - pop_beeb_bss_start)
PRINT "Core high watermark = ", ~P%
PRINT "Core RAM free = ", ~(CORE_TOP - P%)
PRINT "--------"

\*-------------------------------
; Construct MAIN RAM (video & screen)
\*-------------------------------

MAIN_START=&3000
MAIN_TOP=beeb_screen_addr 

CLEAR 0, &FFFF
ORG MAIN_START
GUARD MAIN_TOP

.pop_beeb_main_start

; Code & data in MAIN RAM (rendering)

INCLUDE "game/hires.asm"
hires_end=P%

INCLUDE "game/beeb-plot.asm"
INCLUDE "game/beeb-plot-wipe.asm"
INCLUDE "game/beeb-plot-layrsave.asm"
INCLUDE "game/beeb-plot-peel.asm"
INCLUDE "game/beeb-plot-fastlay.asm"
INCLUDE "game/beeb-plot-lay.asm"

.pop_beeb_main_end

; Save executable code for Main RAM

SAVE "Main", pop_beeb_main_start, pop_beeb_main_end, 0

PRINT "--------"
PRINT "MAIN Modules"
PRINT "--------"
PRINT "HIRES size = ", ~(hires_end - hires)
PRINT "BEEB PLOT size = ", ~(beeb_plot_end - beeb_plot_start)
PRINT "BEEB PLOT WIPE size = ", ~(beeb_plot_wipe_end - beeb_plot_wipe_start)
PRINT "BEEB PLOT LAYRSAVE size = ", ~(beeb_plot_layrsave_end - beeb_plot_layrsave_start)
PRINT "BEEB PLOT PEEL size = ", ~(beeb_plot_peel_end - beeb_plot_peel_start)
PRINT "BEEB PLOT FASTLAY size = ", ~(beeb_plot_fastlay_end - beeb_plot_fastlay_start)
PRINT "BEEB PLOT LAY size = ", ~(beeb_plot_lay_end - beeb_plot_lay_start)
PRINT "--------"
PRINT "Main code size = ", ~(pop_beeb_main_end - pop_beeb_main_start)
PRINT "Main high watermark = ", ~P%

; BSS in MAIN RAM

IF _PEEL_IN_ANDY = FALSE
SKIP (MAIN_TOP - P%) - &A00

.peelbuf1
.peelbuf2
SKIP &A00       ; was &800
.peelbuf_top
ENDIF

; (screen buffers)

; Main RAM stats
PRINT "Screen buffer address = ", ~beeb_screen_addr
PRINT "Screen buffer size = ", ~BEEB_SCREEN_SIZE
PRINT "Main RAM free = ", ~(MAIN_TOP - pop_beeb_main_end - &A00)
PRINT "--------"

\*-------------------------------
; Construct  AUX (SHADOW) RAM
\*-------------------------------

AUX_START=&3000
AUX_TOP=&8000

CLEAR 0, &FFFF
ORG AUX_START
GUARD AUX_TOP

.pop_beeb_aux_start
.pop_beeb_aux_code_start

; Code in AUX RAM (gameplay)

.pop_beeb_aux_code_end

; Data in AUX RAM (gameplay)

.pop_beeb_aux_data_start

.pop_beeb_aux_data_end
.pop_beeb_aux_end

; Save executable code for Aux RAM

; SAVE "Aux", pop_beeb_aux_start, pop_beeb_aux_end, 0

; BSS in AUX RAM (gameplay)

.pop_beeb_aux_bss_start

.pop_beeb_aux_bss_end

PRINT "--------"
PRINT "AUX (Deprecated)"
PRINT "--------"
PRINT "Aux code size = ", ~(pop_beeb_aux_code_end - pop_beeb_aux_code_start)
PRINT "Aux data size = ", ~(pop_beeb_aux_data_end - pop_beeb_aux_data_start)
PRINT "Aux BSS size = ", ~(pop_beeb_aux_bss_end - pop_beeb_aux_bss_start)
PRINT "--------"
PRINT "Aux high watermark = ", ~P%
PRINT "Aux RAM free = ", ~(AUX_TOP - P%)
PRINT "--------"


\*-------------------------------
; Construct HAZEL RAM
\*-------------------------------

HAZEL_START=&C300       ; looks like first two pages are DFS catalog + scratch
HAZEL_TOP=&DF00         ; looks like last page is FS control data

CLEAR 0, &FFFF
ORG HAZEL_START
GUARD HAZEL_TOP

PAGE_ALIGN
.blueprnt
SKIP &900

.pop_beeb_aux_hazel_data_start

INCLUDE "game/tables.asm"
tables_end=P%
INCLUDE "game/bgdata.asm"
bgdata_end=P%
INCLUDE "game/bgdata_high.asm"
bgdata_high_end=P%
INCLUDE "game/hrtables.asm"
hrtables_end=P%

; Beeb specific data
INCLUDE "game/beeb_core_data.asm"

.pop_beeb_aux_hazel_data_end

; Save data for Aux HAZEL RAM

SAVE "Hazel", pop_beeb_aux_hazel_data_start, pop_beeb_aux_hazel_data_end, 0

PRINT "--------"
PRINT "HAZEL Modules"
PRINT "--------"
PRINT "TABLES size = ", ~(tables_end-tables)
PRINT "BGDATA (formerly CORE) size = ", ~(bgdata_end-bgdata)
PRINT "BGDATA (formerly HIGH now HAZEL) size = ", ~(bgdata_high_end-bgdata_end)
PRINT "HRTABLES size = ", ~(hrtables_end-hrtables)
PRINT "BEEB (formerly) CORE DATA size = ", ~(beeb_core_data_end-beeb_core_data_start)
PRINT "--------"
PRINT "HAZEL data size = ", ~(pop_beeb_aux_hazel_data_end - pop_beeb_aux_hazel_data_start)
PRINT "HAZEL BSS (blueprint) size = ", ~(pop_beeb_aux_hazel_data_start - blueprnt)
PRINT "HAZEL high watermark = ", ~P%
PRINT "HAZEL RAM free = ", ~(HAZEL_TOP - P%)
PRINT "--------"


\*-------------------------------
; Construct ANDY RAM
\*-------------------------------

ANDY_START=&8000
ANDY_TOP=&9000

CLEAR 0, &FFFF
ORG ANDY_START
GUARD ANDY_TOP

IF _PEEL_IN_ANDY
.peelbuf1
SKIP &800
.peelbuf2
SKIP &800
.peelbuf_top
ENDIF

PRINT "--------"
PRINT "ANDY Modules"
PRINT "--------"
PRINT "ANDY high watermark = ", ~P%
PRINT "ANDY RAM free = ", ~(ANDY_TOP - P%)
PRINT "--------"


\*-------------------------------
; Construct ROMS
\*-------------------------------

SWRAM_START = &8000
SWRAM_TOP = &C000

CLEAR 0, &FFFF
ORG SWRAM_START
GUARD SWRAM_TOP

; BANK 0

.bank0_start

PAGE_ALIGN
.bgtable1a
INCBIN "Images/BEEB.IMG.BGTAB1.PALA.bin"            ; larger than DUNA

PAGE_ALIGN
.bgtable2
INCBIN "Images/BEEB.IMG.BGTAB2.PAL.bin"            ; larger than DUN

PAGE_ALIGN
.chtable4
INCBIN "Images/BEEB.IMG.CHTAB4.GD.bin"              ; largest of CHTAB4.X

.bank0_end

PRINT "--------"
PRINT "BANK 0 size = ", ~(bank0_end - bank0_start)
PRINT "BANK 0 free = ", ~(SWRAM_TOP - bank0_end)
PRINT "--------"

; BANK 1

CLEAR 0, &FFFF
ORG SWRAM_START
GUARD SWRAM_TOP

.bank1_start

PAGE_ALIGN
.chtable1
IF _HALF_PLAYER
INCBIN "Images/BEEB.IMG.CHTAB1.HALF.bin"
ELSE
INCBIN "Images/BEEB.IMG.CHTAB1.bin"
ENDIF

PAGE_ALIGN
.chtable2
IF _HALF_PLAYER
INCBIN "Images/BEEB.IMG.CHTAB2.HALF.bin"
ELSE
INCBIN "Images/BEEB.IMG.CHTAB2.bin"
ENDIF

PAGE_ALIGN
.chtable3
IF _HALF_PLAYER
INCBIN "Images/BEEB.IMG.CHTAB3.HALF.bin"
ELSE
INCBIN "Images/BEEB.IMG.CHTAB3.bin"
ENDIF

PAGE_ALIGN
.chtable5
IF _HALF_PLAYER
INCBIN "Images/BEEB.IMG.CHTAB5.HALF.bin"
ELSE
INCBIN "Images/BEEB.IMG.CHTAB5.bin"
ENDIF

.bank1_end

PRINT "--------"
PRINT "BANK 1 size = ", ~(bank1_end - bank1_start)
PRINT "BANK 1 free = ", ~(SWRAM_TOP - bank1_end)
PRINT "--------"

SAVE "BANK1", bank1_start, bank1_end, 0

; BANK 2

CLEAR 0, &FFFF
ORG SWRAM_START
GUARD SWRAM_TOP

.bank2_start

PAGE_ALIGN
.bgtable1b
INCBIN "Images/BEEB.IMG.BGTAB1.DUNB.bin"    ; larger than PALB

\\ Code + data doesn't technically have to be page aligned...
PAGE_ALIGN
.pop_beeb_aux_b_start

INCLUDE "game/seqtable.asm"
seqtab_end=P%
INCLUDE "game/framedefs.asm"
framedef_end=P%
INCLUDE "game/ctrlsubs.asm"
ctrlsubs_end=P%
INCLUDE "game/coll.asm"
coll_end=P%
INCLUDE "game/auto.asm"
auto_end=P%

.pop_beeb_aux_b_end

.bank2_end

; Save executable code for Aux B RAM

SAVE "AuxB", pop_beeb_aux_b_start, pop_beeb_aux_b_end, 0

PRINT "--------"
PRINT "AUX B Modules"
PRINT "--------"
PRINT "SEQTABLE size = ", ~(seqtab_end-seqtab)
PRINT "FRAMEDEFS size = ", ~(framedef_end-framedef)
PRINT "CTRLSUBS size = ", ~(ctrlsubs_end-ctrlsubs)
PRINT "COLL size = ", ~(coll_end-coll)
PRINT "AUTO size = ", ~(auto_end-auto)
PRINT "--------"
PRINT "Aux B code+data size = ", ~(pop_beeb_aux_b_end - pop_beeb_aux_b_start)
PRINT "Aux B high watermark = ", ~P%
PRINT "--------"
PRINT "BANK 2 size = ", ~(bank2_end - bank2_start)
PRINT "BANK 2 free = ", ~(SWRAM_TOP - bank2_end)
PRINT "--------"


; BANK 3

CLEAR 0, &FFFF
ORG SWRAM_START
GUARD &FFFF; SWRAM_TOP

.bank3_start

; Additional AUX code located higher up in SWRAM

.pop_beeb_aux_high_start

INCLUDE "game/ctrl.asm"
ctrl_end=P%
INCLUDE "game/frameadv.asm"
frameadv_end=P%
INCLUDE "game/gamebg.asm"
gamebg_end=P%
INCLUDE "game/subs.asm"
subs_end=P%
INCLUDE "game/mover.asm"
mover_end=P%
INCLUDE "game/misc.asm"
misc_end=P%
INCLUDE "game/specialk.asm"
specialk_end=P%

.pop_beeb_aux_high_end

.bank3_end

; Save executable code for Aux High RAM

SAVE "High", pop_beeb_aux_high_start, pop_beeb_aux_high_end, 0

PRINT "--------"
PRINT "AUX High Modules"
PRINT "--------"
; High watermark for Main RAM
PRINT "CTRL size = ", ~(ctrl_end-ctrl)
PRINT "FRAMEADV size = ", ~(frameadv_end-frameadv)
PRINT "GAMEBG size = ", ~(gamebg_end-gamebg)
PRINT "SUBS size = ", ~(subs_end-subs)
PRINT "MOVER size = ", ~(mover_end-mover)
PRINT "MISC size = ", ~(misc_end-misc)
PRINT "SPECIALK size = ", ~(specialk_end-specialk)
PRINT "--------"
PRINT "Aux High code size = ", ~(pop_beeb_aux_high_end - pop_beeb_aux_high_start)
PRINT "Aux High high watermark = ", ~P%
PRINT "--------"
PRINT "BANK 3 size = ", ~(bank3_end - bank3_start)
PRINT "BANK 3 free = ", ~(SWRAM_TOP - bank3_end)
PRINT "--------"


\*-------------------------------
; Construct overlay files
; Not sure what this is going to overlay yet!
\*-------------------------------

CLEAR 0, &FFFF
ORG SWRAM_START
GUARD SWRAM_TOP

.overlay_start
.chtable6
INCBIN "Images/BEEB.IMG.CHTAB6.A.bin"           ; largest CHTAB6.X

ALIGN &100
.chtable7
INCBIN "Images/BEEB.IMG.CHTAB7.bin"

.overlay_end

PRINT "--------"
PRINT "OVERLAY size = ", ~(overlay_end - overlay_start)
PRINT "OVERLAY free = ", ~(SWRAM_TOP - overlay_end)
PRINT "--------"


\*-------------------------------
\*
\*  Blueprint info
\*
\*-------------------------------

ORG blueprnt
.BLUETYPE skip 24*30
.BLUESPEC skip 24*30
.LINKLOC skip 256
.LINKMAP skip 256
.MAP skip 24*4
.INFO
 skip 64                ; not sure why this is skipped, unused?
.KidStartScrn skip 1
.KidStartBlock skip 1
.KidStartFace skip 1
 skip 1
.SwStartScrn skip 1
.SwStartBlock skip 1
 skip 1
.GdStartBlock skip 24
.GdStartFace skip 24
.GdStartX skip 24
.GdStartSeqL skip 24
.GdStartProg skip 24
.GdStartSeqH skip 24
PAGE_ALIGN


\*-------------------------------
; Put files on SIDE A of the disk
\*-------------------------------

PUTFILE "Levels/LEVEL0", "LEVEL0", 0, 0

\ Now on SIDE B
;PUTFILE "Levels/LEVEL1", "LEVEL1", 0, 0
;PUTFILE "Levels/LEVEL2", "LEVEL2", 0, 0
;PUTFILE "Levels/LEVEL3", "LEVEL3", 0, 0
;PUTFILE "Levels/LEVEL4", "LEVEL4", 0, 0
;PUTFILE "Levels/LEVEL5", "LEVEL5", 0, 0
;PUTFILE "Levels/LEVEL6", "LEVEL6", 0, 0
;PUTFILE "Levels/LEVEL7", "LEVEL7", 0, 0
;PUTFILE "Levels/LEVEL8", "LEVEL8", 0, 0
;PUTFILE "Levels/LEVEL9", "LEVEL9", 0, 0
;PUTFILE "Levels/LEVEL10", "LEVEL10", 0, 0
;PUTFILE "Levels/LEVEL11", "LEVEL11", 0, 0
;PUTFILE "Levels/LEVEL12", "LEVEL12", 0, 0
;PUTFILE "Levels/LEVEL13", "LEVEL13", 0, 0
;PUTFILE "Levels/LEVEL14", "LEVEL14", 0, 0

\ Now split into A&B (not C)
PUTFILE "Images/BEEB.IMG.BGTAB1.DUNA.bin", "DUN1A", 0, 0
PUTFILE "Images/BEEB.IMG.BGTAB1.DUNB.bin", "DUN1B", 0, 0
PUTFILE "Images/BEEB.IMG.BGTAB2.DUN.bin", "DUN2", 0, 0
\PUTFILE "Images/BEEB.IMG.BGTAB1.DUN.bin", "DUN1", 0, 0
\PUTFILE "Images/BEEB.IMG.BGTAB1.DUNC.bin", "DUN1C", 0, 0

\ Now split into A&B (not C)
\ Not needed on SIDE A
;PUTFILE "Images/BEEB.IMG.BGTAB1.PALA.bin", "PAL1A", 0, 0
;PUTFILE "Images/BEEB.IMG.BGTAB1.PALB.bin", "PAL1B", 0, 0
;PUTFILE "Images/BEEB.IMG.BGTAB2.PAL.bin", "PAL2", 0, 0
\PUTFILE "Images/BEEB.IMG.BGTAB1.PAL.bin", "PAL1", 0, 0
\PUTFILE "Images/BEEB.IMG.BGTAB1.PALC.bin", "PAL1C", 0, 0

\ Only need regular Guard for SIDE A
PUTFILE "Images/BEEB.IMG.CHTAB4.GD.bin", "GD", 0, 0
;PUTFILE "Images/BEEB.IMG.CHTAB4.FAT.bin", "FAT", 0, 0
;PUTFILE "Images/BEEB.IMG.CHTAB4.SHAD.bin", "SHAD", 0, 0
;PUTFILE "Images/BEEB.IMG.CHTAB4.SKEL.bin", "SKEL", 0, 0
;PUTFILE "Images/BEEB.IMG.CHTAB4.VIZ.bin", "VIZ", 0, 0

IF _HALF_PLAYER
; All saved into single file for BANK1
;PUTFILE "Images/BEEB.IMG.CHTAB1.HALF.bin", "CHTAB1", 0, 0
;PUTFILE "Images/BEEB.IMG.CHTAB2.HALF.bin", "CHTAB2", 0, 0
;PUTFILE "Images/BEEB.IMG.CHTAB3.HALF.bin", "CHTAB3", 0, 0
;PUTFILE "Images/BEEB.IMG.CHTAB5.HALF.bin", "CHTAB5", 0, 0
ELSE
PUTFILE "Images/BEEB.IMG.CHTAB1.bin", "CHTAB1", 0, 0
PUTFILE "Images/BEEB.IMG.CHTAB2.bin", "CHTAB2", 0, 0
PUTFILE "Images/BEEB.IMG.CHTAB3.bin", "CHTAB3", 0, 0
PUTFILE "Images/BEEB.IMG.CHTAB5.bin", "CHTAB5", 0, 0
ENDIF

PUTFILE "Images/BEEB.IMG.CHTAB6.A.bin", "CHTAB6A", 0, 0
\ 6.B used on SIDE B
;PUTFILE "Images/BEEB.IMG.CHTAB6.B.bin", "CHTAB6B", 0, 0
PUTFILE "Images/BEEB.IMG.CHTAB7.bin", "CHTAB7", 0, 0

\ Cutscene files
PUTFILE "Other/BEEB.PRINCESS.mode2.bin", "PRIN", &3000, 0

\ Attract files
PUTFILE "Other/john.Splash.mode2.bin", "SPLASH", &3000, 0
PUTFILE "Other/applewin.Title.mode2.bin", "TITLE", &3000, 0
PUTFILE "Other/applewin.Presents.mode2.bin", "PRESENT", &3000, 0
PUTFILE "Other/applewin.Byline.mode2.bin", "BYLINE", &3000, 0
PUTFILE "Other/applewin.Prolog.mode2.bin", "PROLOG", &3000, 0
PUTFILE "Other/applewin.Sumup.mode2.bin", "SUMUP", &3000, 0
