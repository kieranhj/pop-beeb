; pop-beeb

ORG &70
GUARD &8F

.readptr    SKIP 2
.writeptr   SKIP 2

.numimages  SKIP 1
.width      SKIP 1
.height     SKIP 1

.yoffset    SKIP 1
.yindex     SKIP 1

.apple_count    SKIP 1
.apple_byte     SKIP 1

.beeb_byte  SKIP 1
.beeb_count SKIP 1

.bit_count  SKIP 1
.pal_index  SKIP 1
.pal_jump   SKIP 1

ORG &E00
GUARD &3000

PLOT_MODE = 1

.start

.main
{
    \\ MODE 4
    LDA #22
    JSR &ffee
    LDA #PLOT_MODE
    JSR &ffee

    \\ Parse chtab header
    LDA #LO(chtab1)
    STA readptr
    LDA #HI(chtab1)
    STA readptr+1

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

IF PLOT_MODE=4
    \\ Sprite plot
    LDA #LO(&6500)
    STA writeptr
    LDA #HI(&6500)
    STA writeptr+1

    LDA #0
    JSR apple_plot_mode_4
ENDIF

IF PLOT_MODE=1
    \\ Sprite plot
    LDA #LO(&4A00)
    STA writeptr
    LDA #HI(&4A00)
    STA writeptr+1

    LDA #1
    JSR apple_plot_mode_1
ENDIF

    .return
    RTS
}

.apple_plot_mode_4
{
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

.apple_plot_mode_1
{
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
    STA init_addr + 1
    STA sprite_addr + 1
    LDA readptr+1
    ADC #0
    STA init_addr + 2
    STA sprite_addr + 2


    LDX #0          ; data index
    LDY #7          ; yoffset

    .yloop
    STY yoffset
    STY yindex

    LDA width
    STA apple_count

    LDA #0
    STA beeb_byte
    STA pal_index
    STA pal_jump

    LDA #4
    STA beeb_count

    \\ Initialise palindex
    .init_addr
    LDA &FFFF, X
    STA apple_byte

    LSR apple_byte
    ROL pal_index

    LDA #6              ; we just consumed one
    STA bit_count

    .xloop

    .bit_loop    
    LSR apple_byte       ; rotate bottom bit into Carry
    ROL pal_index        ; rotate carry into palette index

    ; look up colour pixel
    LDA pal_index
    AND #&7
    STA pal_index
    ORA pal_jump
    TAY
    LDA pal_table,Y
    ORA beeb_byte
    STA beeb_byte

    LDA pal_jump
    CLC
    ADC #8
    STA pal_jump

    DEC beeb_count
    BNE next_bit

    \\ Write byte to screen
    LDY yindex
    LDA beeb_byte
    STA (writeptr), Y

    \\ Next screen column
    TYA
    CLC
    ADC #8
    STA yindex

    LDA #0
    STA beeb_byte
    STA pal_jump

    LDA #4
    STA beeb_count

    .next_bit
    DEC bit_count
    BNE bit_loop

    \\ Next apple byte

    INX                 ; next apple byte

    .sprite_addr
    LDA &FFFF, X
    STA apple_byte

    LDA #7
    STA bit_count

    DEC apple_count
    BNE xloop

    \\ Flush Beeb byte to screen if needed
    LDA beeb_count
    CMP #4
    BEQ done_row

    .flushloop
    ASL pal_index        ; rotate zero into palette index

    ; look up colour pixel
    LDA pal_index
    AND #&7
    STA pal_index
    ORA pal_jump
    TAY
    LDA pal_table,Y
    ORA beeb_byte
    STA beeb_byte

    LDA pal_jump
    CLC
    ADC #8
    STA pal_jump

    DEC beeb_count
    BNE flushloop

    LDY yindex
    LDA beeb_byte
    STA (writeptr), Y
    
    .done_row
    DEC height
    BEQ done

    LDY yoffset
    DEY
    BPL jump_yloop
    
    \\ Next char row

    SEC
    LDA writeptr
    SBC #LO(640)
    STA writeptr
    LDA writeptr+1
    SBC #HI(640)
    STA writeptr+1

    LDY #7
    .jump_yloop
    JMP yloop

    .done

    .return
    RTS
}

MACRO MODE1_PIXEL colour, shift
    EQUB (((colour AND 2) * 8) OR (colour AND 1)) << shift
ENDMACRO

.pal_table
.pal_table_even3
{
    MODE1_PIXEL 0, 3
    MODE1_PIXEL 0, 3
    MODE1_PIXEL 2, 3
    MODE1_PIXEL 3, 3
    MODE1_PIXEL 0, 3
    MODE1_PIXEL 1, 3
    MODE1_PIXEL 3, 3
    MODE1_PIXEL 3, 3
}

.pal_table_odd2
{
    MODE1_PIXEL 0, 2
    MODE1_PIXEL 0, 2
    MODE1_PIXEL 1, 2
    MODE1_PIXEL 3, 2
    MODE1_PIXEL 0, 2
    MODE1_PIXEL 2, 2
    MODE1_PIXEL 3, 2
    MODE1_PIXEL 3, 2
}

.pal_table_even1
{
    MODE1_PIXEL 0, 1
    MODE1_PIXEL 0, 1
    MODE1_PIXEL 2, 1
    MODE1_PIXEL 3, 1
    MODE1_PIXEL 0, 1
    MODE1_PIXEL 1, 1
    MODE1_PIXEL 3, 1
    MODE1_PIXEL 3, 1
}

.pal_table_odd0
{
    MODE1_PIXEL 0, 0
    MODE1_PIXEL 0, 0
    MODE1_PIXEL 1, 0
    MODE1_PIXEL 3, 0
    MODE1_PIXEL 0, 0
    MODE1_PIXEL 2, 0
    MODE1_PIXEL 3, 0
    MODE1_PIXEL 3, 0
}


.chtab1
INCBIN "Images/IMG.CHTAB7.bin"

.end

SAVE "Main", start, end, main
