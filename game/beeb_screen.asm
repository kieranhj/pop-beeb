; beeb_screen.asm
; Beeb screen specific routines that need to be in Core memory

.beeb_screen_start

\*-------------------------------
; "Double Hires" FX for Attract
\*-------------------------------

; X=column [0-79]
; A=offset [0-1]
.beeb_dhires_copy_column
{
    CLC
    ADC Mult8_LO, X
    STA beeb_writeptr
    LDA #HI(beeb_double_hires_addr)
    ADC Mult8_HI, X
    STA beeb_writeptr+1

    LDX #BEEB_DOUBLE_HIRES_ROWS
    .row_loop

    LDY #0
    .char_loop
    LDA (beeb_writeptr), Y
    PHA

    \\ Write to visible screen
    LDA &FE34:EOR #&4:STA &FE34

    PLA
    STA (beeb_writeptr), Y

    \\ Read from invisible screen
    LDA &FE34:EOR #&4:STA &FE34

    INY:INY
    CPY #8
    BCC char_loop

    CLC
    LDA beeb_writeptr
    ADC #LO(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    ADC #HI(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr+1
    
    DEX
    BNE row_loop

    .return
    RTS
}

.BEEB_DHIRES_WIPE
{
    LDX #0
    .loop
    STX beeb_temp

    LDA #0
    JSR beeb_dhires_copy_column

    LDA #1
    LDX beeb_temp
    JSR beeb_dhires_copy_column

    LDX beeb_temp
    INX
    CPX #80
    BCC loop

    RTS
}

\*-------------------------------
; Copy SHADOW
; A=Start address PAGE
\*-------------------------------

.BEEB_COPY_SHADOW
{
    STA smRead+2
    STA smWrite+2

    LDX #0
    
    .next_page
    \\ Read from visible screen
    LDA &FE34:EOR #&4:STA &FE34

    .read_page_loop
    .smRead
    LDA &FF00, X
    STA DISKSYS_BUFFER_ADDR, X
    INX
    BNE read_page_loop

    \\ Copy to alternate screen
    LDA &FE34:EOR #&4:STA &FE34

    .write_page_loop
    LDA DISKSYS_BUFFER_ADDR, X
    .smWrite
    STA &FF00, X
    INX
    BNE write_page_loop

    INC smRead+2
    INC smWrite+2

    BPL next_page

    RTS
}

.beeb_screen_end
