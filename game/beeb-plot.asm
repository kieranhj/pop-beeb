; beeb-plot
; BBC Micro plot functions
; Works directly on Apple II sprite data

; need to know where we're locating this code!

.start_beeb_plot

IF PLOT_MODE == 4
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
ENDIF

IF PLOT_MODE == 1
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
    STA pal_index

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

    DEC beeb_count
    BNE next_bit

    \\ Write byte to screen
    LDA pal_index
    AND #&3F
    TAY
    LDA pal_table_6_to_4, Y

    LDY yindex
    STA (writeptr), Y

    \\ Next screen column
    TYA
    CLC
    ADC #8
    STA yindex

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

    DEC beeb_count
    BNE flushloop

    LDA pal_index
    AND #&3F
    TAY
    LDA pal_table_6_to_4, Y

    LDY yindex
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

.pal_table_6_to_4
FOR n,0,63,1

abc=(n >> 3) AND 7
bcd=(n >> 2) AND 7
cde=(n >> 1) AND 7
def=(n) AND 7

\\ even3
IF abc=3 OR abc=6 OR abc=7
    pixel3=&88          ; white3
ELIF abc=2
    pixel3=&80          ; yellow3
ELIF abc=5
    pixel3=&08          ; red3
ELSE
    pixel3=0
ENDIF

IF bcd=3 OR bcd=6 OR bcd=7
    pixel2=&44          ; white2
ELIF bcd=5
    pixel2=&40          ; yellow2
ELIF bcd=2
    pixel2=&04          ; red2
ELSE
    pixel2=0
ENDIF

IF cde=3 OR cde=6 OR cde=7
    pixel1=&22          ; white1
ELIF cde=2
    pixel1=&20          ; yellow1
ELIF cde=5
    pixel1=&02          ; red1
ELSE
    pixel1=0
ENDIF

IF def=3 OR def=6 OR def=7
    pixel0=&11          ; white0
ELIF def=5
    pixel0=&10          ; yellow0
ELIF def=2
    pixel0=&01          ; red0
ELSE
    pixel0=0
ENDIF

EQUB pixel3 OR pixel2 OR pixel1 OR pixel0

NEXT
ENDIF

.end_plot_beeb
