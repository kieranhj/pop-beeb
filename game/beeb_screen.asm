; beeb_screen.asm
; Beeb screen specific routines that need to be in Core memory

.beeb_screen_start

\*-------------------------------
; Clear status line characters
\*-------------------------------

; Y=start character [0-79]
; X=number of characters to clear
.BEEB_CLEAR_STATUS_X
{
    CLC
    LDA Mult8_LO,Y
    ADC #LO(beeb_status_addr)
    STA beeb_writeptr
    LDA Mult8_HI,Y
    ADC #HI(beeb_status_addr)
    STA beeb_writeptr+1

    .loop
    LDA #0

    LDY #0
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y
    INY
    STA (beeb_writeptr), Y

    DEX
    BEQ done_loop

    CLC
    LDA beeb_writeptr
    ADC #8
    STA beeb_writeptr
    BCC no_carry
    INC beeb_writeptr+1
    .no_carry
    BNE loop

    .done_loop
    RTS
}

.BEEB_CLEAR_STATUS_LINE
{
    LDY #0
    LDX #80
    JMP BEEB_CLEAR_STATUS_X
}

.BEEB_CLEAR_TEXT_AREA
{
    LDY #20
    LDX #40
    JMP BEEB_CLEAR_STATUS_X
}

.BEEB_CLEAR_PLAYER_ENERGY
{
    LDY #0
    LDX #20
    JMP BEEB_CLEAR_STATUS_X
}

.BEEB_CLEAR_OPP_ENERGY
{
    LDY #68
    LDX #12
    JMP BEEB_CLEAR_STATUS_X
}

.BEEB_CLEAR_DHIRES_LINE
{
    LDY #&80/8
    LDX #80
    JMP BEEB_CLEAR_STATUS_X
}

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
