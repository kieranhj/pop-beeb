; pop-beeb
; Prince of Persia
; Port to the BBC Master
; Main build file


; Defines

_DEBUG = FALSE
_EDITOR = FALSE
_TODO = FALSE

; Platform includes

INCLUDE "lib/bbc.h.asm"
INCLUDE "lib/bbc_utils.h.asm"

; POP includes

ORG &0
GUARD &100
INCLUDE "game/eq.h.asm"
INCLUDE "game/gameeq.h.asm"
INCLUDE "game/beeb-plot.h.asm"

; Main RAM

ORG &E00
GUARD &4B80

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

    ; SWR 0
    MPRINT loading_bank_text  
    lda #0
    jsr swr_select_slot
    lda #&80
    ldx #LO(bank_file0)
    ldy #HI(bank_file0)
    jsr disksys_load_file
    MPRINT loading_bank_text2   

    \\ MODE
    LDA #22
    JSR &ffee
    LDA #PLOT_MODE
    JSR &ffee

    \\ Select slot 0
    LDA #0
    JSR swr_select_slot

    \\ Relocate sprite data
    LDA #LO(chtab1)
    STA readptr
    LDA #HI(chtab1)
    STA readptr+1
    JSR pop_relocate_chtab

    LDX #0

    .plot_loop
    STX sprite_no
    
    \\ Sprite plot
    LDA #LO(&4A00)
    STA writeptr
    LDA #HI(&4A00)
    STA writeptr+1

    TXA
    JSR apple_plot_mode_1

    ldx#10:ldy#0:lda#&81:jsr osbyte	

    LDX sprite_no
    INX
    CPX numimages
    BCC plot_loop

    .return
    RTS
}

.pop_relocate_chtab
{
    LDY #0
    LDA (readptr), Y
    STA numimages

    \\ Relocate pointers to image data
    LDX #0
    .loop
    INY
    CLC
    LDA (readptr), Y
    ADC #LO(chtab1)
    STA (readptr), Y

    INY
    LDA (readptr), Y
    ADC #LO(HI(chtab1) - &60)
    STA (readptr), Y

    INX
    CPX numimages
    BCC loop

    .return
    RTS
}

INCLUDE "game/beeb-plot.asm"

.pop_beeb_end

SAVE "Main", pop_beeb_start, pop_beeb_end, pop_beeb_main


; Construct SHADOW RAM

CLEAR 0, &FFFF


; Construct MOS RAM

CLEAR 0, &FFFF


; Construct ROMS

CLEAR 0, &FFFF
ORG &8000

.bank0_start
.chtab1
INCBIN "Images/IMG.CHTAB1.bin"
.bank0_end

SAVE "Bank0", bank0_start, bank0_end, &8000, &8000


; Construct overlay files

CLEAR 0, &FFFF
