; pop-beeb

ORG &70
GUARD &8F

.readptr    SKIP 2
.writeptr   SKIP 2

.numimages  SKIP 1
.width      SKIP 1
.height     SKIP 1

.yoffset    SKIP 1

.apple_count    SKIP 1
.apple_byte     SKIP 1

.beeb_byte  SKIP 1
.beeb_count SKIP 1

.bit_count  SKIP 1

ORG &E00
GUARD &3000

.start

.main
{
    LDA #22
    JSR &ffee
    LDA #4
    JSR &ffee

    LDA #LO(chtab1)
    STA readptr
    LDA #HI(chtab1)
    STA readptr+1

    LDY #0
    LDA (readptr), Y
    STA numimages

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

    LDA #1
    ASL A
    TAX
    LDA chtab1+1, X
    STA readptr
    LDA chtab1+2, X
    STA readptr+1

    LDY #0
    LDA (readptr), Y
    STA width
    INY
    LDA (readptr), Y
    STA height

    CLC
    LDA readptr
    ADC #2
    STA sprite_addr + 1
    LDA readptr+1
    ADC #0
    STA sprite_addr + 2

    LDA #LO(&6500)
    STA writeptr
    LDA #HI(&6500)
    STA writeptr+1


    LDX #0          ; data index
    LDY #7          ; yoffset

    .yloop
    STY yoffset

    LDA width
    STA apple_count

    LDA #0
    STA beeb_byte

    LDA #8
    STA beeb_count

    .xloop

    .sprite_addr
    LDA &FFFF, X
    STA apple_byte

    LDA #7
    STA bit_count

    .bit_loop    
    LSR apple_byte       ; rotate bottom bit into Carry
    ROL beeb_byte        ; rotate carry into Beeb byte

    DEC beeb_count
    BNE next_bit

    \\ Write byte to screen
    LDA beeb_byte
    STA (writeptr), Y

    \\ Next screen column
    TYA
    CLC
    ADC #8
    TAY

    LDA #0
    STA beeb_byte

    LDA #8
    STA beeb_count

    .next_bit
    DEC bit_count
    BNE bit_loop

    \\ Next apple byte

    INX                 ; next apple byte
    DEC apple_count
    BNE xloop

    \\ Flush Beeb byte to screen if needed
    LDA beeb_count
    CMP #8
    BEQ done_row

    .flushloop
    ASL beeb_byte
    DEC beeb_count
    BNE flushloop

    LDA beeb_byte
    STA (writeptr), Y
    
    .done_row
    DEC height
    BEQ done

    LDY yoffset
    DEY
    BPL yloop

    SEC
    LDA writeptr
    SBC #LO(320)
    STA writeptr
    LDA writeptr+1
    SBC #HI(320)
    STA writeptr+1

    LDY #7
    BNE yloop
    .done

    .return
    RTS
}

.chtab1
INCBIN "Images/IMG.CHTAB7.bin"

.end

SAVE "Main", start, end, main
