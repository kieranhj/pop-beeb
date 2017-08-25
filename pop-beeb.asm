; pop-beeb
; Prince of Persia
; Port to the BBC Master
; Main build file


; Defines

_TODO = FALSE

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

ORG &0
GUARD locals
INCLUDE "game/eq.h.asm"
INCLUDE "game/gameeq.h.asm"

; POP defines

INCLUDE "game/soundnames.h.asm"
INCLUDE "game/seqdata.h.asm"

; BEEB headers

INCLUDE "game/beeb-plot.h.asm"

; Local ZP variables only

INCLUDE "game/frameadv.h.asm"
INCLUDE "game/hires.h.asm"
INCLUDE "game/master.h.asm"
INCLUDE "game/mover.h.asm"

; Main RAM

ORG &E00
;GUARD &4B80            ; eventually shrunk MODE 1
GUARD &5800             ; currently in full MODE 4

.pop_beeb_start

; Master 128 PAGE is &0E00 since MOS uses other RAM buffers for DFS workspace
SCRATCH_RAM_ADDR = &0400

INCLUDE "lib/disksys.asm"
INCLUDE "lib/swr.asm"
INCLUDE "lib/print.asm"

; move all this to beeb-loader in due course

; disk loader uses hacky filename format (same as catalogue) 
; we use disk loader for SWR banks only
.bank_file0   EQUS "Bank0  $"
.bank_file1   EQUS "Bank1  $"
.bank_file2   EQUS "Bank2  $"
.bank_file3   EQUS "Bank3  $"

.screen_file  EQUS "LOAD Page", 13

.swr_fail_text EQUS "No SWR banks found.", 13, 10, 0
.swr_bank_text EQUS "Found %b", LO(swr_ram_banks_count), HI(swr_ram_banks_count), " SWR banks.", 13, 10, 0
.swr_bank_text2 EQUS " Bank %a", 13, 10, 0

.loading_bank_text EQUS "Loading bank... ", 0
.loading_bank_text2 EQUS "OK", 13, 10, 0

.pop_beeb_main
{
    \\ SWRAM init
    jsr swr_init
    bne swr_ok

    MPRINT swr_fail_text
    rts

.swr_ok

    MPRINT    swr_bank_text
    ldx #0
.swr_print_loop
    lda swr_ram_banks,x
    MPRINT    swr_bank_text2
    inx
    cpx swr_ram_banks_count
    bne swr_print_loop

	\\ load all SWR banks
IF 0
    ; SWR 0
    MPRINT loading_bank_text  
    lda #0
    jsr swr_select_slot
    lda #&80
    ldx #LO(bank_file0)
    ldy #HI(bank_file0)
    jsr disksys_load_file
    MPRINT loading_bank_text2   
ENDIF

    \\ MODE
    LDA #22
    JSR oswrch
    LDA #BEEB_SCREEN_MODE
    JSR oswrch

    \\ Level load & plot test
    LDX #1

    .level_loop
    STX level
    JSR LoadLevelX

    LDX #1
    STX VisScrn

    .scrn_loop
    \\ Select slot 0
    LDA #BEEB_SWRAM_SLOT_LEVELBG
    JSR swr_select_slot

    JSR DoSure

    ldx#100:ldy#0:lda#&81:jsr osbyte	

    LDX VisScrn
    INX
    CPX #25
    STX VisScrn
    BNE scrn_loop

    LDX level
    INX
    CPX #15
    BNE level_loop

    .return
    RTS
}

; Beeb source

INCLUDE "game/beeb-plot.asm"

; PoP source

INCLUDE "game/frameadv.asm"
INCLUDE "game/grafix.asm"
INCLUDE "game/tables.asm"
INCLUDE "game/bgdata.asm"
INCLUDE "game/gamebg.asm"
INCLUDE "game/hires.asm"
INCLUDE "game/hrtables.asm"
INCLUDE "game/master.asm"
INCLUDE "game/topctrl.asm"
INCLUDE "game/specialk.asm"
INCLUDE "game/subs.asm"
INCLUDE "game/mover.asm"
INCLUDE "game/misc.asm"
INCLUDE "game/auto.asm"
INCLUDE "game/ctrlsubs.asm"
INCLUDE "game/ctrl.asm"
INCLUDE "game/coll.asm"

.pop_beeb_end

SAVE "Main", pop_beeb_start, pop_beeb_end, pop_beeb_main

; Run time initalised data

INCLUDE "game/eq.asm"
INCLUDE "game/gameeq.asm"

; Construct SHADOW RAM

CLEAR 0, &FFFF


; Construct MOS RAM

CLEAR 0, &FFFF
ORG &8000
GUARD &9000
.peelbuf1
SKIP &800
.peelbuf2
SKIP &800

; Construct ROMS

CLEAR 0, &FFFF
ORG &8000
GUARD &C000

BEEB_BUFFER_RAM_SOCKET = &80            ; 4K MOS RAM used for buffers

BEEB_SWRAM_SLOT_LEVELBG = 0
BEEB_SWRAM_SLOT_CHTAB13 = 1
BEEB_SWRAM_SLOT_CHTAB25 = 2
BEEB_SWRAM_SLOT_CHTAB4 = 3

.bank0_start
.bgtable1
SKIP 9185           ; max size of IMG.BGTAB1.XXX
;INCBIN "Images/IMG.BGTAB1.DUN.bin"
;INCBIN "Images/IMG.BGTAB1.PAL.bin"
ALIGN &100
.bgtable2
SKIP 4593           ; max size of IMG.BGTAB2.XXX
;INCBIN "Images/IMG.BGTAB2.DUN.bin"
;INCBIN "Images/IMG.BGTAB2.PAL.bin"
ALIGN &100
.blueprnt
SKIP &900           ; all blueprints same size
;INCBIN "Levels/Level1"
.bank0_end

;SAVE "Bank0", bank0_start, bank0_end, &8000, &8000

CLEAR 0, &FFFF
ORG &8000
GUARD &C000

.bank1_start
.chtable1
SKIP 9165           ; size of IMG.CHTAB1
ALIGN &100
.chtable3
SKIP 5985           ; size of IMG.CHTAB3
ALIGN &100
.bank1_end

CLEAR 0, &FFFF
ORG &8000
GUARD &C000

.bank2_start
.chtable2
SKIP 9189           ; size of IMG.CHTAB2
ALIGN &100
.chtable5
SKIP 6134           ; size of IMG.CHTAB5
ALIGN &100
.bank2_end

CLEAR 0, &FFFF
ORG &8000
GUARD &C000

.bank3_start
.chtable4
SKIP 5281           ; size of largest IMG.CHTAB4.X internal file pointer - file size 8999b?
ALIGN &100
.chtable6
SKIP 9201           ; size of largest IMG.CHTAB6.X
ALIGN &100
.chtable7
SKIP 1155           ; size of IMG.CHTAB7
ALIGN &100
.bank3_end

; Construct overlay files

CLEAR 0, &FFFF

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

; Put files on the disk

PUTFILE "Levels/LEVEL0", "LEVEL0", 0, 0
PUTFILE "Levels/LEVEL1", "LEVEL1", 0, 0
PUTFILE "Levels/LEVEL2", "LEVEL2", 0, 0
PUTFILE "Levels/LEVEL3", "LEVEL3", 0, 0
PUTFILE "Levels/LEVEL4", "LEVEL4", 0, 0
PUTFILE "Levels/LEVEL5", "LEVEL5", 0, 0
PUTFILE "Levels/LEVEL6", "LEVEL6", 0, 0
PUTFILE "Levels/LEVEL7", "LEVEL7", 0, 0
PUTFILE "Levels/LEVEL8", "LEVEL8", 0, 0
PUTFILE "Levels/LEVEL9", "LEVEL9", 0, 0
PUTFILE "Levels/LEVEL10", "LEVEL10", 0, 0
PUTFILE "Levels/LEVEL11", "LEVEL11", 0, 0
PUTFILE "Levels/LEVEL12", "LEVEL12", 0, 0
PUTFILE "Levels/LEVEL13", "LEVEL13", 0, 0
PUTFILE "Levels/LEVEL14", "LEVEL14", 0, 0
PUTFILE "Images/IMG.BGTAB1.DUN.bin", "DUN1", 0, 0
PUTFILE "Images/IMG.BGTAB2.DUN.bin", "DUN2", 0, 0
PUTFILE "Images/IMG.BGTAB1.PAL.bin", "PAL1", 0, 0
PUTFILE "Images/IMG.BGTAB2.PAL.bin", "PAL2", 0, 0
PUTFILE "Images/IMG.CHTAB4.FAT.bin", "FAT", 0, 0
PUTFILE "Images/IMG.CHTAB4.GD.bin", "GD", 0, 0
PUTFILE "Images/IMG.CHTAB4.SHAD.bin", "SHAD", 0, 0
PUTFILE "Images/IMG.CHTAB4.SKEL.bin", "SKEL", 0, 0
PUTFILE "Images/IMG.CHTAB4.VIZ.bin", "VIZ", 0, 0
PUTFILE "Images/IMG.CHTAB1.bin", "CHTAB1", 0, 0
PUTFILE "Images/IMG.CHTAB2.bin", "CHTAB2", 0, 0
PUTFILE "Images/IMG.CHTAB3.bin", "CHTAB3", 0, 0
PUTFILE "Images/IMG.CHTAB5.bin", "CHTAB4", 0, 0
;PUTFILE "Images/IMG.CHTAB6.A.bin", "CHTAB6A", 0, 0
;PUTFILE "Images/IMG.CHTAB6.B.bin", "CHTAB6B", 0, 0
;PUTFILE "Images/IMG.CHTAB7.bin", "CHTAB7", 0, 0
