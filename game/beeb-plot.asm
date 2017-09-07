; beeb-plot
; BBC Micro plot functions
; Works directly on Apple II sprite data

; need to know where we're locating this code!

\*-------------------------------
\*
\*  Parameters passed to hires routines:
\*
\*  PAGE        $00 = hires page 1, $20 = hires page 2          - NOT BEEB
\*  XCO         Screen X-coord (0=left, 39=right)
\*  YCO         Screen Y-coord (0=top, 191=bottom)
\*  OFFSET      # of bits to shift image right (0-6)
\*  IMAGE       Image # in table (1-127)
\*  TABLE       Starting address of image table (2 bytes)
\*  BANK        Memory bank of table (2 = main, 3 = aux)        - NOT BEEB (YET - WILL BE SWRAM BANK)
\*  OPACITY     Bits 0-6:
\*                0    AND
\*                1    OR
\*                2    STA
\*                3    special XOR (OR/shift/XOR)
\*                4    mask/OR
\*              Bit 7: 0 = normal, 1 = mirror
\*  LEFTCUT     Left edge of usable screen area
\*                (0 for full screen)
\*  RIGHTCUT    Right edge +1 of usable screen area
\*                (40 for full screen)
\*  TOPCUT      Top edge of usable screen area
\*                (0 for full screen)
\*  BOTCUT      Bottom edge +1 of usable screen area
\*                (192 for full screen)
\*
\*-------------------------------
\*
\*  Image table format:
\*
\*  Byte 0:    width (# of bytes)
\*  Byte 1:    height (# of lines)
\*  Byte 2-n:  image bytes (read left-right, top-bottom)
\*
\*-------------------------------

\ BEEB TO DO
\ Use original game ZP variables
\ Implement offset and clipping etc.

.beeb_plot_start

IF BEEB_SCREEN_MODE == 4
.beeb_plot_apple_mode_4
{
    \\ From hires_LAY
    lda OPACITY
    bpl notmirr

    and #$7f
    sta OPACITY
;    jmp MLAY
;
    .notmirr
;    cmp #enum_eor
;    bne label_1
;    jmp LayXOR
;
;    .label_1 cmp #enum_mask
;    bcc label_2
;    jmp LayMask
;
;    .label_2 jmp LayGen

    \\ Must have a swram bank to select or assert
    LDA BANK
    CMP #4
    BCC slot_set
    BRK                 ; swram slot for sprite not set!
    .slot_set
    JSR swr_select_slot

    \ Turns TABLE & IMAGE# into IMAGE ptr
    \ Obtains WIDTH & HEIGHT
    
    JSR PREPREP

    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)

    \ Convert to Beeb screen layout

    \ Y offset into character row

    LDA YCO
    AND #&7
    STA beeb_yoffset

    \ Mask off Y offset

    LDA YCO
    AND #&F8
    TAY    
    
    \ Look up Beeb screen address

    LDX XCO
    CLC
    LDA Mult8_LO,X
    ADC YLO, Y
    STA beeb_writeptr
    LDA Mult8_HI,X
    ADC YHI, Y
    STA beeb_writeptr+1

    \ Look up Beeb shift start

    LDA Mult8_REM,X
    STA beeb_rem

    \ Store height

    LDA HEIGHT
    STA beeb_height

    \ Switch blend mode

    ldx OPACITY ;hi bit off!
    cpx #5
    bcc in_range
    BRK                 ; means our OPACITY is out of range
    .in_range
    cpx #enum_sta
; BEEB TEMP always ORA
;    bne not_sta

    \ Force hack ORA for MODE 4
    ldx #enum_ora
    .not_sta

    \ Self-mod code

    lda OPCODE,x
    sta  smod
    sta  smod2

    \ Set sprite data address 

    LDA IMAGE
    STA sprite_addr+1
    LDA IMAGE+1
    STA sprite_addr+2

    \ Plot loop

    LDX #0          ; data index
    LDY beeb_yoffset          ; yoffset

    .yloop
    STY beeb_yoffset

    LDA WIDTH
    STA beeb_apple_count

    LDA #0
    STA beeb_byte

    LDA beeb_rem
    STA beeb_count

    .xloop

    .sprite_addr
    LDA &FFFF, X
    STA beeb_apple_byte

    LDA #7
    STA beeb_bit_count

    .bit_loop    
    LSR beeb_apple_byte       ; rotate bottom bit into Carry
    ROL beeb_byte        ; rotate carry into Beeb byte

    DEC beeb_count
    BNE next_bit

    \\ Write byte to screen
    LDA beeb_byte
 .smod ora (beeb_writeptr),y
   STA (beeb_writeptr), Y

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
    DEC beeb_bit_count
    BNE bit_loop

    \\ Next apple byte

    INX                 ; next apple byte
    DEC beeb_apple_count
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
 .smod2 ora (beeb_writeptr),y
    STA (beeb_writeptr), Y
    
    .done_row
    DEC beeb_height
    BEQ done

    LDY beeb_yoffset
    DEY
    BPL yloop

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_WIDTH)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_WIDTH)
    STA beeb_writeptr+1

    LDY #7
    BNE yloop
    .done

    .return
    RTS
}
ENDIF

IF BEEB_SCREEN_MODE == 1
.beeb_plot_apple_mode_1
{
    ASL A
    TAX
    LDA bgtable1+1, X           \ WRONG
    STA beeb_readptr
    LDA bgtable1+2, X           \ WRONG
    STA beeb_readptr+1

    LDY #0
    LDA (beeb_readptr), Y
    STA beeb_width
    INY
    LDA (beeb_readptr), Y
    STA beeb_height

    CLC
    LDA beeb_readptr
    ADC #2
    STA init_addr + 1
    STA sprite_addr + 1
    LDA beeb_readptr+1
    ADC #0
    STA init_addr + 2
    STA sprite_addr + 2


    LDX #0          ; data index
    LDY #7          ; yoffset

    .yloop
    STY beeb_yoffset
    STY beeb_yindex

    LDA beeb_width
    STA beeb_apple_count

    LDA #0
    STA beeb_pal_index

    LDA #4
    STA beeb_count

    \\ Initialise palindex
    .init_addr
    LDA &FFFF, X
    STA beeb_apple_byte

    LSR beeb_apple_byte
    ROL beeb_pal_index

    LDA #6              ; we just consumed one
    STA beeb_bit_count

    .xloop

    .bit_loop    
    LSR beeb_apple_byte       ; rotate bottom bit into Carry
    ROL beeb_pal_index        ; rotate carry into palette index

    DEC beeb_count
    BNE next_bit

    \\ Write byte to screen
    LDA beeb_pal_index
    AND #&3F
    TAY
    LDA beeb_plot_pal_table_6_to_4, Y

    LDY beeb_yindex
    STA (beeb_writeptr), Y

    \\ Next screen column
    TYA
    CLC
    ADC #8
    STA beeb_yindex

    LDA #4
    STA beeb_count

    .next_bit
    DEC beeb_bit_count
    BNE bit_loop

    \\ Next apple byte

    INX                 ; next apple byte

    .sprite_addr
    LDA &FFFF, X
    STA beeb_apple_byte

    LDA #7
    STA beeb_bit_count

    DEC beeb_apple_count
    BNE xloop

    \\ Flush Beeb byte to screen if needed
    LDA beeb_count
    CMP #4
    BEQ done_row

    .flushloop
    ASL beeb_pal_index        ; rotate zero into palette index

    DEC beeb_count
    BNE flushloop

    LDA beeb_pal_index
    AND #&3F
    TAY
    LDA beeb_plot_pal_table_6_to_4, Y

    LDY beeb_yindex
    STA (beeb_writeptr), Y
    
    .done_row
    DEC beeb_height
    BEQ done

    LDY beeb_yoffset
    DEY
    BPL jump_yloop
    
    \\ Next char row

    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES)
    STA beeb_writeptr+1

    LDY #7
    .jump_yloop
    JMP yloop

    .done

    .return
    RTS
}


.beeb_plot_pal_table_6_to_4
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


.beeb_set_screen_mode
{
    \\ Set CRTC registers
    LDX #13
    .crtcloop
    STX &FE00
    LDA beeb_crtcregs, X
    STA &FE01
    DEX
    BPL crtcloop

    \\ Set ULA
    LDA #&88            ; MODE 4
    STA &FE20

    \\ Set Palette
    CLC
    LDA #7              ; PAL_black
    .palloop1
    STA &FE21
    ADC #&10
    BPL palloop1  
    EOR #7              ; PAL_white
    .palloop2
    STA &FE21
    ADC #&10
    BMI palloop2

    RTS
}


.beeb_plot_reloc_img
{
    LDY #0
    LDA (beeb_readptr), Y
    STA beeb_numimages              \ can get rid of this var

    \\ Relocate pointers to image data
    LDX #0
    .loop
    INY
    CLC
\    LDA (beeb_readptr), Y
\    ADC #LO(bgtable1)
\    STA (beeb_readptr), Y

    INY
    LDA (beeb_readptr), Y
    SEC
    SBC beeb_writeptr+1
    CLC
    ADC beeb_readptr+1
    STA (beeb_readptr), Y

    INX
    CPX beeb_numimages
    BCC loop

    .return
    RTS
}


.beeb_shadow_select_main
{
    LDA &FE34
    AND #&FB            ; mask out bit 2
    STA &FE34
    RTS
}

.beeb_shadow_select_aux
{
    LDA &FE34
    ORA #4
    STA &FE34
    RTS
}


.Mult8_LO
FOR n,0,39,1
x=(n * 7) DIV 8
EQUB LO(x*8)
NEXT
.Mult8_HI
FOR n,0,39,1
x=(n * 7) DIV 8
EQUB HI(x*8)
NEXT
.Mult8_REM
FOR n,0,39,1
x=(n * 7) MOD 8
EQUB 8 - x
NEXT

.beeb_plot_end
