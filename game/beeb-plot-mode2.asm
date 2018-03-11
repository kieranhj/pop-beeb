; beeb-plot-mode2
; BBC Micro plot functions
; Full fat MODE 2 plot routine
; Surgically adapted from LayMASK

.beeb_plot_mode2_start

\ MLAY beeb_mirror = 1
.beeb_plot_sprite_MLayMode2
{
    LDA #1
    EQUB &2C        ; BIT = skip next two bytes
}
\\ Fall through
.beeb_plot_sprite_LayMode2
{
    LDA #0
    STA beeb_mirror
}
.beeb_plot_sprite_LayMode2BM
{
    LDA #NOP_OP
    STA smParity1
    STA smParity2

    \ Beeb screen address
    JSR beeb_plot_calc_screen_addr

    \ Parity inverted by Mirror
    LDA beeb_parity
    EOR beeb_mirror
    BEQ no_swap

    LDA #OPCODE_LSRA:STA smParity1
    LDA #OPCODE_ASLA:STA smParity2

    .no_swap

    \ Do we have a partial clip on left side?
    LDX OFFLEFT
    BEQ no_partial_left
    LDA OFFSET:LSR A:TAX
    BEQ no_partial_left
    DEC OFFLEFT
    .no_partial_left

    \ Calculate how many bytes of sprite data to unroll

    LDA VISWIDTH
    {
        CPX #0:BEQ no_partial_left
        INC A                   ; need extra byte of sprite data for left clip
        .no_partial_left
    }
    ; A = bytes_per_line_in_sprite
    CMP #0                      ; zero flag already set from CPX
    BNE something_to_do         ; nothing to plot

    JMP DONE
    .something_to_do

    \ Self-mod code to save a cycle per line
    ASL A                       ; twice as many sprite bytes in full fat MODE 2
    TAY
    DEC A
    STA smSpriteBytes+1

    \ Calculate how deep our stack will be

    TYA
    ; A = bytes_per_line_in_sprite * 2
    ASL A                       ; we have W*4 pixels to unroll
    INC A
    STA beeb_stack_depth        ; stack will end up this many bytes lower than now

    \ Calculate number of pixels visible on screen

    LDA VISWIDTH
    ASL A: ASL A
    {
        CPX #0:BEQ no_partial_left
        CLC
        ADC beeb_mode2_offset   ; have this many extra pixels on left side
        .no_partial_left
        LDY OFFRIGHT:BEQ no_partial_right
        SEC
        SBC beeb_mode2_offset
        .no_partial_right
    }
    ; A = number of visible pixels

    \ Calculate how many bytes we'll need to write to the screen

    LSR A
    CLC
    ADC beeb_parity             ; vispixels/2 + parity
    ; A = bytes_per_line_on_screen

    \ Self-mod code to save a cycle per line
    ASL A: ASL A: ASL A         ; x8
    STA smYMAX+1

    \ Calculate where to start reading data from stack
    {
        CPX #0:BEQ no_partial_left        ; left partial clip

        \ If clipping left start a number of bytes into the stack

        LDA beeb_mirror
        BEQ regular_clip

        \ MIRROR clip
        \ If mode2_offset then can see upto 3 more pixels
        \ pixels clipped = 4 - offset
        \ stack start = stack_depth + 1 - pixels clipped

        SEC
        LDA beeb_stack_depth
        SBC #3
        CLC
        ADC beeb_mode2_offset
        STA smStackStart+1
        BNE same_char_column

        .regular_clip

        \ Regular plot start [2-5] depending on mode2_offset
        SEC
        LDA #5
        SBC beeb_mode2_offset
        \ Self-mod code to save a cycle per line
        STA smStackStart+1
        BNE same_char_column

        .no_partial_left

        \ If not clipping left then stack start is based on parity

        LDA beeb_mirror
        BEQ regular_plot

        \ MIRROR plot
        \ MIRROR = beeb_stack_depth+2 for parity or beeb_stack_depth+1 if even

        CLC
        LDA beeb_parity
        INC A
        ADC beeb_stack_depth
        STA smStackStart+1
        BNE check_offset

        .regular_plot
        LDA beeb_parity
        EOR #1
        \ Self-mod code to save a cycle per line
        STA smStackStart+1

        .check_offset
        \ If we're on the next character column, move our write pointer

        LDA beeb_mode2_offset
        AND #&2
        BEQ same_char_column

        CLC
        LDA beeb_writeptr
        ADC #8
        STA beeb_writeptr
        BCC same_char_column
        INC beeb_writeptr+1
        .same_char_column
    }

    \ Set sprite data address skipping any bytes clipped off left
    {
        LDA beeb_mirror
        BEQ regular_plot

        \ Add RMOST to IMAGE for MIRROR case

        LDA RMOST
        ASL A           ; don't forget this is in 2bpp bytes
        CLC
        ADC IMAGE
        STA sprite_addr+1
        LDA IMAGE+1
        ADC #0
        STA sprite_addr+2

        LDA #OPCODE_DEX
        STA smDIR1
        STA smDIR2
        BNE done_check

        .regular_plot        
        LDA OFFLEFT
        ASL A           ; don't forget this is in 2bpp bytes
        CLC
        ADC IMAGE
        STA sprite_addr+1
        LDA IMAGE+1
        ADC #0
        STA sprite_addr+2

        LDA #OPCODE_INX
        STA smDIR1
        STA smDIR2

        .done_check
    }

    \ Save a cycle per line - player typically min 24 lines

    LDA WIDTH
    ASL A               ; twice as many sprite bytes in full fat MODE 2
    STA smWIDTH+1

    LDA TOPEDGE
    STA smTOPEDGE+1

    \ Push a zero on the top of the stack in case of parity

    LDA #0
    PHA

    \ Remember where the stack is now
    
    TSX
    STX smSTACKTOP+1          ; use this to reset stack

    \ Calculate bottom of the stack and self-mod read address

    TXA
    SEC
    SBC beeb_stack_depth
    STA smSTACK1+1
    STA smSTACK2+1

.plot_lines_loop

RASTER_COL PAL_cyan

\ Start at the end of the sprite data

    .smSpriteBytes
    LDY #0      ;beeb_bytes_per_line_in_sprite-1

\ Decode a line of sprite data using Exile method!
\ Current per pixel decode: STA ZP 3c+ TAX 2c+ LDA,X 4c=9c
\ Exile ZP: TAX 2c+ STA 4c+ LDA zp 3c=9c am I missing something?
\ Save 2 cycles per loop when shifting bytes down TXA vs LDA zp

    .line_loop

\\ This is 4bpp data

    .sprite_addr
    LDA &FFFF, Y
    TAX

\\ Take right hand pixel first

    AND #&55

\\ Swap it to left if parity

    .smParity2
    NOP ; swap for parity here LSR A or NOP

\\ Push onto stack

    PHA                                 ; [3c]

\\ Take left hand pixel next

    TXA
    AND #&AA

\\ Swap it to right if parity

    .smParity1
    NOP ; swap for parity here ASL A or NOP

\\ Push onto stack

    PHA

\ Stop when we reach the left edge of the sprite data

    .done_sprite_data_byte
    DEY
    BPL line_loop

\ Always push the extra zero
\ Can't set it directly in case the loop gets interrupted and a return value pushed onto stack

    LDA #0
    PHA

RASTER_COL PAL_yellow

\ Sort out where to start in the stack lookup

    .smStackStart
    LDX #0  ;beeb_stack_start

\ Now plot that data to the screen left to right

    LDY #0
    CLC

.plot_screen_loop

\ MIRROR = DEX
.smDIR1
    INX
.smSTACK1
    LDA &100,X

\ MIRROR = DEX
.smDIR2
    INX
.smSTACK2
    ORA &100,X

\ Skip zero data

    BEQ skip_zero               ; BEEB really need to check this is faster in the general case!

\ Convert pixel data to mask

    STA load_mask+1             \ 4c not storing in a register
    .load_mask
    LDA mask_table              ; 4c

\ AND mask with screen

    AND (beeb_writeptr), Y

\ OR in sprite byte

    ORA load_mask+1             ; 4c

\ Write to screen

    STA (beeb_writeptr), Y

\ Next screen byte across

    .skip_zero
    TYA
    ADC #8
    TAY                         ; do it all backwards?!

    .smYMAX
    CPY #0
    BCC plot_screen_loop

\ Reset the stack pointer

    .smSTACKTOP
    LDX #0                 ; beeb_stack_ptr
    TXS

\ Have we completed all rows?

    LDY YCO
    DEY
    .smTOPEDGE
    CPY #0                 ; TOPEDGE
    STY YCO
    BEQ done_y

\ Move to next sprite data row

    CLC
    LDA sprite_addr+1
    .smWIDTH
    ADC #0                  ; WIDTH
    STA sprite_addr+1
    BCC no_carry
    INC sprite_addr+2
    .no_carry

\ Next scanline

    LDA beeb_writeptr
    AND #&07
    BEQ next_char_row

    DEC beeb_writeptr
    JMP plot_lines_loop

\ Need to move up a screen char row

    .next_char_row
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    JMP plot_lines_loop

    .done_y

\ Reset stack before we leave

    PLA
;RASTER_COL PAL_black
    JMP DONE
}

IF 0
.beeb_plot_sprite_MLayMode2
{
    LDA #NOP_OP
    STA smParity1
    STA smParity2

    \ Beeb screen address

    JSR beeb_plot_calc_screen_addr

    \ Returns parity in Carry
    BCS no_swap     ; mirror reverses parity

    LDA #OPCODE_LSRA:STA smParity1
    LDA #OPCODE_ASLA:STA smParity2

    .no_swap

    \ Do we have a partial clip on left side?
    LDX #0
    LDA OFFLEFT
    BEQ no_partial_left
    LDA OFFSET:LSR A
    BEQ no_partial_left
    INX
    DEC OFFLEFT
    .no_partial_left

    \ Calculate how many bytes of sprite data to unroll

    LDA VISWIDTH
    {
        CPX #0:BEQ no_partial_left
        INC A                   ; need extra byte of sprite data for left clip
        .no_partial_left
    }
    STA beeb_bytes_per_line_in_sprite       ; unroll all bytes
    CMP #0                      ; zero flag already set from CPX
    BNE something_to_do        ; nothing to plot

    JMP DONE
    .something_to_do

    \ Self-mod code to save a cycle per line
    ASL A                   ; twice as many sprite bytes in full fat MODE 2
    STA smSpriteBytes+1

    \ Calculate number of pixels visible on screen

    LDA VISWIDTH
    ASL A: ASL A
    {
        CPX #0:BEQ no_partial_left
        CLC
        ADC beeb_mode2_offset   ; have this many extra pixels on left side
        .no_partial_left
        LDY OFFRIGHT:BEQ no_partial_right
        SEC
        SBC beeb_mode2_offset
        .no_partial_right
    }
    ; A contains number of visible pixels

    \ Calculate how many bytes we'll need to write to the screen

    LSR A
    CLC
    ADC beeb_parity             ; vispixels/2 + parity
    ; A contains beeb_bytes_per_line_on_screen

    \ Self-mod code to save a cycle per line
    ASL A: ASL A: ASL A         ; x8
    STA smYMAX+1

    \ Calculate how deep our stack will be

    LDA beeb_bytes_per_line_in_sprite
    ASL A: ASL A                  ; we have W*4 pixels to unroll
    INC A
    STA beeb_stack_depth        ; stack will end up this many bytes lower than now

    {
        CPX #0:BEQ no_partial_left        ; left partial clip

        \ Left clip special stack start

        SEC
        LDA #5
        SBC beeb_mode2_offset
        \ Self-mod code to save a cycle per line
        STA smStackStart+1
        BNE same_char_column

        .no_partial_left
        LDA beeb_parity
        EOR #1
        \ Self-mod code to save a cycle per line
        STA smStackStart+1

        \ If we're on the next character column, move our write pointer

        LDA beeb_mode2_offset
        AND #&2
        BEQ same_char_column

        CLC
        LDA beeb_writeptr
        ADC #8
        STA beeb_writeptr
        BCC same_char_column
        INC beeb_writeptr+1
        .same_char_column
    }

    \ Set sprite data address 

    CLC
    LDA IMAGE
    ADC RMOST              ; NOT OFFLEFT because actually we want to lose our right-hand pixels
    STA sprite_addr+1
    LDA IMAGE+1
    ADC #0
    STA sprite_addr+2

    \ Save a cycle per line - player typically min 24 lines

    LDA WIDTH
    ASL A                   ; twice as many sprite bytes in full fat MODE 2
    STA smWIDTH+1

    LDA TOPEDGE
    STA smTOPEDGE+1

    \ Push a zero on the end in case of parity

    LDA #0
    PHA

    \ Remember where the stack is now
    
    TSX
    STX smSTACKTOP+1          ; use this to reset stack

    \ Calculate bottom of the stack and self-mod read address

    TXA
    SEC
    SBC beeb_stack_depth
    STA smSTACK1+1
    STA smSTACK2+1

.plot_lines_loop

RASTER_COL PAL_cyan

    LDY #0                  ; bytes_per_line_in_sprite

\ Decode a line of sprite data using Exile method!

    .line_loop

\\ This is 4bpp data

    .sprite_addr
    LDA &FFFF, Y
\ For mirror sprites we decode pixels left to right and push them onto the stack
\ Therefore bottom of the stack will be the right-most pixel to be drawn on left hand side

    TAX

\\ Take left hand pixel fist

    AND #&AA

\\ Swap it to right if parity

    .smParity1
    NOP

\\ Push onto stack

    PHA

\\ Take right hand pixel next

    TXA
    AND #&55

\\ Swap it to left if parity

    .smParity2
    NOP

\\ Push onto stack

    PHA

    .done_sprite_data_byte
    INY
    .smSpriteBytes
    CPY #0              ; beeb_bytes_per_line_in_sprite

\ Stop when we reach the left edge of the sprite data

    BNE line_loop

\ Always push the extra zero - can't set directly in case of interrupts

    LDA #0
    PHA

RASTER_COL PAL_yellow

\ Sort out where to start in the stack lookup

    .smStackStart
    LDX #0  ;beeb_stack_start

\ Now plot that data to the screen

    LDY #0
    CLC

.plot_screen_loop

    INX
.smSTACK1
    LDA &100,X

    INX
.smSTACK2
    ORA &100,X

\ Don't plot blank bytes

    BEQ skip_zero

\ Convert sprite pixels to mask

    STA load_mask+1
    .load_mask
    LDA mask_table
    
\ AND mask with screen

    AND (beeb_writeptr), Y

\ OR in sprite byte

    ORA load_mask+1

\ Write to screen

    STA (beeb_writeptr), Y

    .skip_zero

\ Next screen byte across

    TYA
    ADC #8
    TAY

    .smYMAX
    CPY #0
    BCC plot_screen_loop

\ Reset the stack pointer

    .smSTACKTOP
    LDX #0                      ; beeb_stack_ptr
    TXS

\ Have we completed all rows?

    LDY YCO
    DEY
    .smTOPEDGE
    CPY #0                      ; TOPEDGE
    STY YCO
    BEQ done_y

\ Move to next sprite data row

    CLC
    LDA sprite_addr+1
    .smWIDTH
    ADC #0                      ; WIDTH
    STA sprite_addr+1
    BCC no_carry
    INC sprite_addr+2
    .no_carry

\ Next scanline

    LDA beeb_writeptr
    AND #&07
    BEQ next_char_row

    DEC beeb_writeptr
    JMP plot_lines_loop

\ Need to move up a screen char row

    .next_char_row
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    JMP plot_lines_loop

    .done_y

\ Reset stack before we leave

    PLA
;RASTER_COL PAL_black
    JMP DONE
}
ENDIF

.beeb_plot_sprite_FastLaySTAMode2
.beeb_plot_sprite_FastMaskMode2
{
    LDA OPACITY 
    CMP #enum_sta
    BNE is_mask

    \\ Convert this routine into a STA version :)
    LDA #OPCODE_BRA
    STA smSTA
    LDA #LO(skip_mask - smSTA - 2)
    STA smSTA+1

    .is_mask

    \ Beeb screen address

    JSR beeb_plot_calc_screen_addr      ; can still lose OFFSET calcs

    \ Don't carry about Carry

    \ Calculate how many bytes of sprite data to unroll

    LDA WIDTH
    ASL A                   ; x2 for full fat 4bpp data
    STA smWIDTH+1
    STA smXMAX+1

    \ Set sprite data address skipping any bytes NO CLIP

    LDA IMAGE
    STA sprite_addr1+1
    LDA IMAGE+1
    STA sprite_addr1+2

\ Simple Y clip

    SEC
    LDA YCO
    SBC HEIGHT
    BCS no_yclip
    LDA #LO(-1)
    .no_yclip
    STA smTOPEDGE+1

.plot_lines_loop

\ Start at the end of the sprite data

    LDY #0
    LDX #0
    CLC

    .line_loop

\ Load 2 pixels of sprite data

    .sprite_addr1
    LDA &FFFF, X            ; 4c

    .smSTA
    STA smMask1+1           ; 4c

    .smMask1
    LDA map_2bpp_to_mask    ; 4c

\ AND mask with screen

    AND (beeb_writeptr), Y  ; 5c

\ OR in sprite byte

    ORA smMask1+1           ; 4c

\ Write to screen

    .skip_mask
    STA (beeb_writeptr), Y  ; 6c

\ Increment write pointer

    TYA:ADC #8:TAY

\ Increment sprite index

    INX

    .smXMAX
    CPX #0
    BCC line_loop

\ Have we completed all rows?

    LDY YCO
    DEY
    .smTOPEDGE
    CPY #0                 ; TOPEDGE
    STY YCO
    BEQ done_y

\ Move to next sprite data row

    CLC
    LDA sprite_addr1+1
    .smWIDTH
    ADC #0                  ; WIDTH
    STA sprite_addr1+1
    BCC no_carry
    INC sprite_addr1+2
    .no_carry

\ Next scanline

    LDA beeb_writeptr
    AND #&07
    BEQ next_char_row

    DEC beeb_writeptr
    BRA plot_lines_loop

\ Need to move up a screen char row

    .next_char_row
    SEC
    LDA beeb_writeptr
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    BRA plot_lines_loop

    .done_y

    LDA OPACITY 
    CMP #enum_sta
    BNE done

    \\ Convert this routine back into MASK version :)
    LDA #OPCODE_STAabs
    STA smSTA
    LDA #LO(smMask1+1)
    STA smSTA+1

\ Reset stack before we leave

    .done
    JMP DONE
}

.beeb_plot_mode2_end
