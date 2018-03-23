.beeb_swr_start

IF 0
SWR_TOP_BANK=7
SWR_BOTTOM_BANK=4

; scan for SWR banks
; mark swr_rom_banks as 0 if SWR or non-zero if ROM
; on exit A contains number of SWR banks, Z=1 if no SWR, or Z=0 if SWR
.swr_init
{
    sei
    lda &f4:pha

    ; scan for roms
    ldx #SWR_TOP_BANK
    ldy #0
.rom_loop
    stx &f4:stx &fe30   ; select rom bank
    lda &8008   ; read byte
    eor #&AA    ; invert, so that we are know we are writing a different value 
    sta &8008   ; write byte
    cmp &8008   ; check that byte was written by comparing what we wrote with what we read back
    bne no_ram
    eor #&AA
    sta &8008
    iny         ; found a RAM
    .no_ram
    dex
    cpx #SWR_BOTTOM_BANK
    bcs rom_loop

    ; restore previous bank
    pla
    sta &f4
    sta &fe30
    cli

    ; return #banks
    tya
    rts
}
ENDIF

; A contains ROM bank to be selected
.swr_select_slot
.swr_select_bank
{
;    sei
    sta &f4
    sta &fe30
;    cli
    rts
}

.beeb_swr_end
