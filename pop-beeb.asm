; pop-beeb
; Prince of Persia
; Port to the BBC Master
; Main build file

\*-------------------------------
; GLOBAL DEFINES
\*-------------------------------

INCLUDE "pop-beeb.h.asm"

\*-------------------------------
; CALCULATE FILESIZES
\*-------------------------------

INCLUDE "lib/filesizes.asm"

\*-------------------------------
; ZERO PAGE
\*-------------------------------

locals = $d0                    ; VDU workspace
locals_top = $e3

zp_top = &a0

ORG &0
GUARD locals

map_2bpp_to_mode2_pixel=&0
.RESERVE_00 skip 1
.RESERVE_01 skip 1
.RESERVE_02 skip 1
.DLL_REG_A skip 1
.DLL_REG_X skip 1

INCLUDE "game/eq.h.asm"
INCLUDE "game/gameeq.h.asm"
INCLUDE "game/beeb-plot.h.asm"

; Music Libraries
INCLUDE "lib/exomiser.h.asm"
INCLUDE "lib/vgmplayer.h.asm"

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
LOWER_TOP=&D00

ORG LANG_START              ; VDU and language workspace
GUARD LOWER_TOP              ; sound workspace

INCLUDE "game/beeb_lang.asm"
INCLUDE "game/gameeq.asm"

INCLUDE "game/beeb_lower.asm"
INCLUDE "game/eq.asm"

PRINT "--------"
PRINT "LANG + LOWER Workspace"
PRINT "--------"
PRINT "Lower workspace high watermark = ", ~P%
PRINT "Lower workspace RAM free = ", ~(LOWER_TOP - P%)
PRINT "--------"

SAVE "Lower", &C00, &D00,0


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

.beeb_boot_start

INCLUDE "lib/print.asm"

.swr_fail_text EQUS "Requires Master w/ 4x SWRAM banks.", 13, 0

.main_filename  EQUS "Main   $"
.high_filename  EQUS "High   $"
.hazel_filename EQUS "Hazel  $"
.auxb_filename  EQUS "AuxB   $"
.load_filename  EQUS "BITS   $"
.lower_filename EQUS "Lower  $"

.pop_beeb_entry
{
    \\ Test for MASTER
    LDA #0
    LDX #1
    JSR osbyte
    CPX #3
    BCC fail
    CPX #6
    BCS fail

    \\ SWRAM init
    jsr swr_init
    cmp #4
    bcs swr_ok

.fail
    MPRINT swr_fail_text
    rts

.swr_ok

    \\ Early system init

    LDX #&FF:TXS                ; reset stack

    SEI
    LDA #&7F:STA &FE4E          ; disable all interupts
    LDA #&82:STA &FE4E          ; enable vsync interupt
    CLI

    \\ MODE 7 during initialise

    LDA #22:JSR oswrch
    LDA #7:JSR oswrch

    \\ Turn off cursor

    LDA #8:STA &FE00
    LDA #&D3:STA &FE01

    \\ Hard reset on break
    LDA #200:LDX #3:JSR &FFF4

    \\ Clear larger frame buffer (MODE 2)

    JSR beeb_CLS

    \\ Loading screen

    LDX #LO(load_filename)
    LDY #HI(load_filename)
    LDA #HI(&7C00)
    JSR disksys_load_file

    \\ Load executable overlays

    LDX #LO(lower_filename)
    LDY #HI(lower_filename)
    LDA #&0C
    JSR disksys_load_file

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

\ Setup SHADOW buffers for double buffering

    ; we set bits 0 and 2 of ACCCON, so that display=Main RAM, and shadow ram is selected as main memory
    lda &fe34
    and #255-1  ; set D to 0
    ora #4    	; set X to 1
    sta &fe34

    \\ Load Aux

    \\ And Aux B (SWRAM)

    LDA #BEEB_SWRAM_SLOT_AUX_B
    JSR swr_select_slot

    LDX #LO(auxb_filename)
    LDY #HI(auxb_filename)
    LDA #HI(pop_beeb_aux_b_start)
    JSR disksys_load_file

    LDA #BEEB_SWRAM_SLOT_AUX_HIGH
    JSR swr_select_slot

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

IF _AUDIO
    ; initialize the music system
    jsr audio_init
ENDIF

    ; initialise the vsync irq
    {
        \\ Start our event driven fx
        ldx #LO(event_handler)
        ldy #HI(event_handler)
        jsr start_eventv
    }

IF _DEBUG
\    JMP beeb_test_load_all_levels
\    JMP beeb_test_sprite_plot
ENDIF

    \\ Actual POP
    \\ Would have been entered directly by the boot loader on Apple II

;   JMP firstboot
}
\ Just drop through!

\*-------------------------------
\*
\*  F I R S T B O O T - moved from master.asm
\*
\*-------------------------------

.FIRSTBOOT
{
\* Load as much of Stage 3 as we can keep

    LDA #0
    JSR disksys_set_drive

    \ Relocate font (in SWRAM)
    \ Relocate the FONT file
    {
        LDA #LO(small_font)
        STA beeb_readptr
        LDA #HI(small_font)
        STA beeb_readptr+1

        LDY #1      ; not 0!
        LDA (beeb_readptr), Y
        TAX

        JSR beeb_plot_reloc_img_loop
    }

 STZ map_2bpp_to_mode2_pixel+&00         ; left + right 0

\* Start attract loop

 jsr initsystem ;in topctrl

 lda #0
 sta invert ;rightside up Y tables

 lda #1
 sta soundon ;Sound on

 lda #$ff   ; no level sprites cached
 sta CHset
 sta BGset1
 sta BGset2

 JSR beeb_set_mode2_no_clear

    \\ Own error handler now we're fully initialised
    SEI
    LDX #LO(error_handler)
    LDY #HI(error_handler)
    STX BRKV
    STY BRKV+1
    CLI

IF _BOOT_ATTRACT
 jmp AttractLoop
ELSE
 jmp DOSTARTGAME
ENDIF
}

\*-------------------------------
; Set custom CRTC mode for game
\*-------------------------------

.beeb_set_mode2_no_clear
{
    \\ Wait vsync
    LDA #19
    JSR osbyte

    \\ Set CRTC registers
    LDX #13
    .crtcloop
    STX &FE00
    LDA beeb_crtcregs, X
    STA &FE01
    DEX
    BPL crtcloop

    \\ Set ULA
    LDA #&F4            ; MODE 2
    STA &248            ; Tell the OS or it will mess with ULA settings at vsync
    STA &FE20

    JMP beeb_set_default_palette
}

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

EXO_pad=(EXO_buffer_len+EXO_TABL_SIZE)-(P%-beeb_boot_start)

IF EXO_pad > 0
    PRINT "PAD LOST", ~EXO_pad, " BYTES"
    SKIP EXO_pad
ENDIF

.beeb_boot_end

; Global jump table

IF _JMP_TABLE
INCLUDE "game/aux_jump.asm"
ENDIF

; Beeb source in CORE

INCLUDE "lib/disksys.asm"
INCLUDE "lib/swr.asm"

INCLUDE "game/beeb_test.asm"
INCLUDE "game/beeb_platform.asm"

; PoP source in CORE memory (always present)

; Vsync handler code
INCLUDE "lib/vsync.asm"

INCLUDE "game/master.asm"
master_end=P%
INCLUDE "game/topctrl.asm"
topctrl_end=P%
INCLUDE "game/audio.asm"            ; this can go eventually
audio_end=P%
INCLUDE "lib/unpack.asm"

; Code moved back into Core from Main

INCLUDE "game/hires.asm"
hires_end=P%
INCLUDE "game/beeb-plot-font.asm"

; Used to be in Main but unrolled code pushed it out

_UNROLL_FASTLAY = TRUE      ; unrolled versions of FASTLAY(STA) function
_UNROLL_LAYRSAVE = TRUE     ; unrolled versions of layrsave & peel function
_UNROLL_WIPE = TRUE         ; unrolled versions of wipe function
_UNROLL_LAYMASK = FALSE     ; unrolled versions of LayMask full-fat sprite plot

; If you move a plot function back into Main must update self-mod code in
; beeb_plot_invert_code_in_main in beeb_core.asm for inverting screen!!
INCLUDE "game/beeb-plot-fastlay.asm"
INCLUDE "game/beeb-plot-layrsave.asm"

; PoP gameplay code moved from AUX memory

.pop_beeb_core_end

.pop_beeb_data_start

; Data in CORE memory (always present)

.pop_beeb_data_end
.pop_beeb_end

; Save Core executable

SAVE "Core", pop_beeb_start, pop_beeb_end, pop_beeb_entry

; Core RAM stats

PRINT "--------"
PRINT "CORE Modules"
PRINT "--------"
PRINT "DISKSYS size = ", ~(beeb_disksys_end - beeb_disksys_start)
PRINT "SWR size = ", ~(beeb_swr_end - beeb_swr_start)
;PRINT "PRINT size = ", ~(beeb_print_end - beeb_print_start)
PRINT "BEEB BOOT size = ", ~(beeb_boot_end - beeb_boot_start)
PRINT "AUX JUMP TABLES size = ", ~(aux_jump_end - aux_jump_start)
PRINT "BEEB TEST size = ", ~(beeb_test_end - beeb_test_start)
PRINT "BEEB PLATFORM size = ", ~(beeb_platform_end - beeb_platform_start)
PRINT "MASTER size = ", ~(master_end - master)
PRINT "TOPCTRL size = ", ~(topctrl_end - topctrl)
PRINT "AUDIO (LEGACY) size = ", ~(audio_end - audio)
PRINT "PUCRUNCH size = ", ~(pucrunch_end-pucrunch_start)
PRINT "HIRES size = ", ~(hires_end - hires)
PRINT "BEEB PLOT FONT size = ", ~(beeb_plot_font_end - beeb_plot_font_start)
PRINT "BEEB PLOT FASTLAY size = ", ~(beeb_plot_fastlay_end - beeb_plot_fastlay_start)
PRINT "BEEB PLOT LAYRSAVE size = ", ~(beeb_plot_layrsave_end - beeb_plot_layrsave_start)
PRINT "--------"
PRINT "Core code size = ", ~(pop_beeb_core_end - pop_beeb_core_start)
PRINT "Core data size = ", ~(pop_beeb_data_end - pop_beeb_data_start)
PRINT "Core high watermark = ", ~P%
PRINT "Core RAM free = ", ~(CORE_TOP - P%)
PRINT "--------"

; Run time initalised data in Core can overlay boot

CLEAR &E00, &3000
ORG beeb_boot_start
GUARD beeb_boot_end

.pop_beeb_bss_start

PAGE_ALIGN
.EXO_buffer SKIP EXO_buffer_len
.exo_tabl_bi SKIP EXO_TABL_SIZE

.pop_beeb_bss_end

PRINT "--------"
PRINT "Core BSS size = ", ~(pop_beeb_bss_end - pop_beeb_bss_start)
PRINT "Core BSS free = ", ~(beeb_boot_end - pop_beeb_bss_end)
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

.pop_beeb_version
EQUB _VERSION
.pop_beeb_build
INCLUDE "version.txt"       ; generated by make.bat

; Code & data in MAIN RAM (rendering)

; If you move a plot function out of Main must update self-mod code in
; beeb_plot_invert_code_in_main in beeb_core.asm for inverting screen!!
INCLUDE "game/beeb-plot.asm"
INCLUDE "game/beeb-plot-wipe.asm"
INCLUDE "game/beeb-plot-lay.asm"
INCLUDE "game/beeb-plot-peel.asm"

.pop_beeb_main_end

; Save executable code for Main RAM

SAVE "Main", pop_beeb_main_start, pop_beeb_main_end, 0

PRINT "--------"
PRINT "MAIN Modules"
PRINT "--------"
PRINT "BEEB PLOT size = ", ~(beeb_plot_end - beeb_plot_start)
PRINT "BEEB PLOT WIPE size = ", ~(beeb_plot_wipe_end - beeb_plot_wipe_start)
PRINT "BEEB PLOT LAY size = ", ~(beeb_plot_lay_end - beeb_plot_lay_start)
PRINT "BEEB PLOT PEEL size = ", ~(beeb_plot_peel_end - beeb_plot_peel_start)
PRINT "--------"
PRINT "Main code size = ", ~(pop_beeb_main_end - pop_beeb_main_start)
PRINT "Main high watermark = ", ~P%

; BSS in MAIN RAM

SKIP (MAIN_TOP - P%) - BEEB_PEEL_BUFFER_SIZE

.peelbuf1
.peelbuf2
SKIP BEEB_PEEL_BUFFER_SIZE       ; was &800
.peelbuf_top

; (screen buffers)

; Main RAM stats
PRINT "Screen buffer address = ", ~beeb_screen_addr
PRINT "Screen buffer size = ", ~BEEB_SCREEN_SIZE
PRINT "Main RAM free = ", ~(MAIN_TOP - pop_beeb_main_end - BEEB_PEEL_BUFFER_SIZE)
PRINT "--------"

\*-------------------------------
; Construct MAIN Cutscene Overlay
\*-------------------------------

PRIN2_START=beeb_screen_addr-&200       ; magically size of PLOT_MODE2
\ This eats into peelbuf but we don't care as only in cutscene

CLEAR &3000, &8000
ORG PRIN2_START
GUARD &8000

.pop_beeb_prin2_start
INCLUDE "game/beeb-plot-mode2.asm"
PAGE_ALIGN
.pop_beeb_prin2_screen
INCBIN "Other/john.PRINCESS.SCENE.mode2.bin"
.pop_beeb_prin2_end

SAVE "PRIN2", pop_beeb_prin2_start, pop_beeb_prin2_end, 0

PRINT "--------"
PRINT "MAIN Cutscene Overlay"
PRINT "--------"
PRINT "BEEB PLOT MODE2 size = ", ~(beeb_plot_mode2_end - beeb_plot_mode2_start)
PRINT "PRINCESS screen address = ", ~pop_beeb_prin2_screen
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
INCLUDE "game/hrtables.asm"
hrtables_end=P%

; Beeb specific data
INCLUDE "game/beeb_palette.asm"

.small_font
INCBIN "Other/small_font.bin"

.pop_beeb_aux_hazel_data_end

.pop_beeb_aux_hazel_code_start

; Music & Audio routines crammed in here
INCLUDE "lib/exomiser.asm"
INCLUDE "lib/vgmplayer.asm"
INCLUDE "lib/beeb_audio.asm"

.pop_beeb_aux_hazel_code_end

; Save data & code for Aux HAZEL RAM

SAVE "Hazel", pop_beeb_aux_hazel_data_start, pop_beeb_aux_hazel_code_end, 0

PRINT "--------"
PRINT "HAZEL Modules"
PRINT "--------"
PRINT "TABLES size = ", ~(tables_end-tables)
PRINT "BGDATA size = ", ~(bgdata_end-bgdata)
PRINT "HRTABLES size = ", ~(hrtables_end-hrtables)
PRINT "BEEB PALETTE DATA size = ", ~(beeb_palette_end-beeb_palette_start)
PRINT "EXO size = ", ~(exo_end-exo_start)
PRINT "VGMPLAYER size = ", ~(vgm_player_end-vgm_player_start)
PRINT "BEEB AUDIO size = ", ~(beeb_audio_end-beeb_audio)
PRINT "--------"
PRINT "HAZEL data size = ", ~(pop_beeb_aux_hazel_data_end - pop_beeb_aux_hazel_data_start)
PRINT "HAZEL code size = ", ~(pop_beeb_aux_hazel_code_end - pop_beeb_aux_hazel_code_start)
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

; ANDY is used primarily to store banked Audio data.

PRINT "--------"
PRINT "ANDY Modules"
PRINT "--------"
PRINT "ANDY high watermark = ", ~P%
PRINT "ANDY RAM free = ", ~(ANDY_TOP - P%)
PRINT "--------"

; Create the music banks and save them to disk
INCLUDE "lib/beeb_audio_banks.asm"



\*-------------------------------
; Construct ROMS
\*-------------------------------

SWRAM_START = &8000
SWRAM_TOP = &C000

CLEAR 0, &FFFF
ORG SWRAM_START
GUARD SWRAM_TOP

\*-------------------------------
; BANK 0
\*-------------------------------

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

\*-------------------------------
; BANK 1
\*-------------------------------

CLEAR 0, &FFFF
ORG SWRAM_START
GUARD SWRAM_TOP

.bank1_start

PAGE_ALIGN
.bgtable1b
INCBIN "Images/BEEB.IMG.BGTAB1.DUNB.bin"    ; larger than PALB

PAGE_ALIGN
.chtable1
INCBIN "Images/BEEB.IMG.CHTAB1.bin"

.chtable2
INCBIN "Images/BEEB.IMG.CHTAB2.bin"

.chtable3
INCBIN "Images/BEEB.IMG.CHTAB3.bin"

PAGE_ALIGN                                  ; technically no reason to be PAGE ALIGNED
INCLUDE "lib/beeb_sfx_bank.asm"

.bank1_end

PRINT "--------"
PRINT "AUDIO SFX size = ", ~(pop_sfx_end - pop_sfx_start)
PRINT "BANK 1 size = ", ~(bank1_end - bank1_start)
PRINT "BANK 1 free = ", ~(SWRAM_TOP - bank1_end)
PRINT "--------"

SAVE "BANK1", chtable1, bank1_end, 0

\*-------------------------------
; BANK 2
\*-------------------------------

CLEAR 0, &FFFF
ORG SWRAM_START
GUARD SWRAM_TOP

.bank2_start

PAGE_ALIGN
.chtable5
INCBIN "Images/BEEB.IMG.CHTAB5.bin"

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
INCLUDE "game/inverty.asm"
inverty_end=P%
INCLUDE "game/beeb_master.asm"

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
PRINT "INVERTY size = ", ~(inverty_end-INVERTY)
PRINT "BEEB MASTER size = ", ~(beeb_master_end-beeb_master_start)
PRINT "--------"
PRINT "Aux B code+data size = ", ~(pop_beeb_aux_b_end - pop_beeb_aux_b_start)
PRINT "Aux B high watermark = ", ~P%
PRINT "--------"
PRINT "BANK 2 size = ", ~(bank2_end - bank2_start)
PRINT "BANK 2 free = ", ~(SWRAM_TOP - bank2_end)
PRINT "--------"

\*-------------------------------
; BANK 3
\*-------------------------------

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
INCLUDE "game/grafix.asm"
grafix_end=P%
INCLUDE "game/subs.asm"
subs_end=P%
INCLUDE "game/mover.asm"
mover_end=P%
INCLUDE "game/misc.asm"
misc_end=P%
INCLUDE "game/specialk.asm"
specialk_end=P%
INCLUDE "game/beeb_screen.asm"

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
PRINT "GRAFIX size = ", ~(grafix_end-grafix)
PRINT "SUBS size = ", ~(subs_end-subs)
PRINT "MOVER size = ", ~(mover_end-mover)
PRINT "MISC size = ", ~(misc_end-misc)
PRINT "SPECIALK size = ", ~(specialk_end-specialk)
PRINT "BEEB SCREEN size = ", ~(beeb_screen_end - beeb_screen_start)
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
.chtable8
.chtable9
INCBIN "Images/BEEB.IMG.CHTAB8.mode2.bin"

ALIGN &100
.chtable7
INCBIN "Images/BEEB.IMG.CHTAB7.mode2.bin"

; Actually CHTAB6 and CHTAB9 goes over all of this!

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

\ All game levels on SIDE B
\ All background sprites on SIDE B
\ All character sprites on SIDE B

\ Loading screen
PUTFILE "Other/bitshifters.mode7.bin", "BITS", &7C00, 0

\ Attract files
PUTFILE "Other/splash.pu.bin", "SPLASH", &3000, 0
PUTFILE "Other/title.pu.bin", "TITLE", &3000, 0
PUTFILE "Other/presents.pu.bin", "PRESENT", &3000, 0
PUTFILE "Other/byline.pu.bin", "BYLINE", &3000, 0
PUTFILE "Other/prolog.pu.bin", "PROLOG", &3000, 0

\ Cutscene files
PUTFILE "Images/BEEB.IMG.CHTAB9.mode2.bin", "CHTAB9", 0, 0
PUTFILE "Images/BEEB.IMG.CHTAB7.mode2.bin", "CHTAB7", 0, 0
PUTFILE "Images/BEEB.IMG.CHTAB8.mode2.bin", "CHTAB8", 0, 0
;PUTFILE "Other/john.PRINCESS.SCENE.mode2.bin", "PRIN", &3000, 0

PUTFILE "Other/sumup.pu.bin", "SUMUP", &3000, 0

; All saved into single file for BANK1
;PUTFILE "Images/BEEB.IMG.CHTAB1.bin", "CHTAB1", 0, 0
;PUTFILE "Images/BEEB.IMG.CHTAB2.bin", "CHTAB2", 0, 0
;PUTFILE "Images/BEEB.IMG.CHTAB3.bin", "CHTAB3", 0, 0
PUTFILE "Images/BEEB.IMG.CHTAB5.bin", "CHTAB5", 0, 0

; Want to put this here but disc full...
PUTFILE "Other/credits.pu.bin", "CREDITS", &3000, 0
PUTFILE "Other/epilog.pu.bin", "EPILOG", &3000, 0
