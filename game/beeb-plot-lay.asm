; beeb-plot-lay
; BBC Micro plot functions
; Specialisations of lay permutations

.beeb_plot_lay_start

IF _UNROLL_LAYMASK

ERROR

BEEB_MAX_LAY_WIDTH=10

MACRO BEEB_PLOT_LAYMASK_BYTES x_byte
{
    INX:LDA &100,X              ; 4b
    INX:ORA &100,X              ; 4b
    STA load_mask+1             ; 3b
    .load_mask LDA mask_table   ; 3b
    LDY #(x_byte * 8)           ; 2b
    AND (beeb_writeptr), Y      ; 2b
    ORA load_mask+1             ; 3b
    STA (beeb_writeptr), Y      ; 2b
}                               ; 23b=&17
ENDMACRO

BEEB_PLOT_LAYMASK_UNROLL_SIZE=&17

.beeb_plot_sprite_LayMask
{
    \ Get sprite data address 

    JSR beeb_PREPREP

    \ CLIP here

    JSR CROP
    bpl cont
    .nothing_to_do
    jmp DONE
    .cont

    LDA PALETTE
    JSR beeb_plot_sprite_setpalette

    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)
    \ OFFSET (0-3) - maybe 0,1 or 8,9?

    LDY YCO
    LDX XCO

    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16_HI,X
    ADC YHI,Y
    STA beeb_writeptr+1

    \ Handle OFFSET

    LDA OFFSET
    LSR A
    STA beeb_mode2_offset

    AND #&1
    STA beeb_parity             ; this is parity

    \ Returns parity in Carry
    BEQ no_swap

\ L&R pixels need to be swapped over

    JSR beeb_plot_sprite_FlipPalette

    .no_swap

    \ Do we have a partial clip on left side?
    LDX #0
    LDA OFFLEFT
    BEQ no_partial_left
    LDA OFFSET
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
    BEQ nothing_to_do        ; nothing to plot

    \ Self-mod code to save a cycle per line
    DEC A
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

    \ Look up end of that bit of code
    TAY
    CPY #BEEB_MAX_LAY_WIDTH*2
    BCS no_jump
    LDA laymask_unrolled_LO, Y
    STA beeb_readptr
    LDA laymask_unrolled_HI, Y
    STA beeb_readptr+1
    .no_jump

    \ Poke in JMP instuction
    LDY #0
    LDA #OPCODE_JMP
    STA (beeb_readptr), Y
    INY
    LDA #LO(laymask_unrolled_end)
    STA (beeb_readptr), Y
    INY
    LDA #HI(laymask_unrolled_end)
    STA (beeb_readptr), Y

    \ Calculate how deep our stack will be

    LDA beeb_bytes_per_line_in_sprite
    ASL A: ASL A                  ; we have W*4 pixels to unroll
    INC A
    STA beeb_stack_depth        ; stack will end up this many bytes lower than now

    \ Calculate where to start reading data from stack
    {
        CPX #0:BEQ no_partial_left        ; left partial clip

        \ If clipping left start a number of bytes into the stack

        SEC
        LDA #5
        SBC beeb_mode2_offset
        \ Self-mod code to save a cycle per line
        STA beeb_temp       ;smStackStart+1
        BNE same_char_column

        .no_partial_left

        \ If not clipping left then stack start is based on parity

        LDA beeb_parity
        EOR #1
        \ Self-mod code to save a cycle per line
        STA beeb_temp       ;smStackStart+1

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

    CLC
    LDA IMAGE
    ADC OFFLEFT
    STA sprite_addr+1
    LDA IMAGE+1
    ADC #0
    STA sprite_addr+2

    \ Save a cycle per line - player typically min 24 lines
    LDA WIDTH
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
    CLC
    ADC beeb_temp           ; beeb_stack_start
    STA smStackStart+1

;    STA smSTACK1+1
;    STA smSTACK2+1

.plot_lines_loop

\ Start at the end of the sprite data

RASTER_COL PAL_cyan

    .smSpriteBytes
    LDY #0      ;beeb_bytes_per_line_in_sprite-1

\ Decode a line of sprite data using Exile method!
\ Current per pixel decode: STA ZP 3c+ TAX 2c+ LDA,X 4c=9c
\ Exile ZP: TAX 2c+ STA 4c+ LDA zp 3c=9c am I missing something?
\ Save 2 cycles per loop when shifting bytes down TXA vs LDA zp
\ For player could be 2c x 8 bytes x 35 lines = 560c = 1.4% frame!

    .line_loop

    .sprite_addr
    LDA &FFFF, Y
    STA beeb_data

    AND #&11
    TAX
.smPIXELD
    LDA map_2bpp_to_mode2_pixel,X       ; could be in ZP ala Exile to save 2cx4=8c per sprite byte
    PHA                                 ; [3c]

    LDA beeb_data
    AND #&22
    TAX
.smPIXELC
    LDA map_2bpp_to_mode2_pixel,X
    PHA

    LDA beeb_data                       ; +1c
    LSR A
    LSR A
    STA beeb_data                       ; +1c

    AND #&11
    TAX
.smPIXELB
    LDA map_2bpp_to_mode2_pixel,X
    PHA

    LDA beeb_data
    AND #&22
    TAX
.smPIXELA
    LDA map_2bpp_to_mode2_pixel,X
    PHA

\ Stop when we reach the left edge of the sprite data

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

\ Maximum possible pixels / bytes written:

    .laymask_unrolled_start
    FOR bytes,0,(2*BEEB_MAX_LAY_WIDTH)-1,1
    BEEB_PLOT_LAYMASK_BYTES bytes
    NEXT
    .laymask_unrolled_end

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

    \ Poke in JMP instuction
    LDY #0
    LDA #&E8        ; INX
    STA (beeb_readptr), Y
    INY
    LDA #&BD        ; LDA abs, X
    STA (beeb_readptr), Y
    INY
    LDA #0          ;
    STA (beeb_readptr), Y

    JMP DONE

.laymask_unrolled_LO
FOR n,0,BEEB_MAX_LAY_WIDTH*2,1
EQUB LO(laymask_unrolled_start + n*&17)
NEXT

.laymask_unrolled_HI
FOR n,0,BEEB_MAX_LAY_WIDTH*2,1
EQUB HI(laymask_unrolled_start + n*&17)
NEXT
}

.beeb_plot_sprite_MLayMask
{
    \ Get sprite data address 

    JSR beeb_PREPREP

    \  Check we're in the right function :)

    LDA XCO
    SEC
    SBC WIDTH
    STA XCO

    \ CLIP here

    JSR CROP
    bpl cont
    .nothing_to_do
    jmp DONE
    .cont

    LDA PALETTE
    JSR beeb_plot_sprite_setpalette

    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)
    \ OFFSET (0-3) - maybe 0,1 or 8,9?

    \ Mask off Y offset to get character row

    LDY YCO
    LDX XCO
    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16_HI,X
    ADC YHI,Y
    STA beeb_writeptr+1

    \ Handle OFFSET

    LDA OFFSET
    LSR A
    STA beeb_mode2_offset

    AND #&1
    STA beeb_parity             ; this is parity

    BNE no_swap     ; mirror reverses parity

\ L&R pixels need to be swapped over

    JSR beeb_plot_sprite_FlipPalette

    .no_swap

    \ Do we have a partial clip on left side?
    LDX #0
    LDA OFFLEFT
    BEQ no_partial_left
    LDA OFFSET
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
    BEQ nothing_to_do        ; nothing to plot

    \ Self-mod code to save a cycle per line
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

    \ Look up end of that bit of code
    TAY
    CPY #BEEB_MAX_LAY_WIDTH*2
    BCS no_jump
    LDA mlaymask_unrolled_LO, Y
    STA beeb_readptr
    LDA mlaymask_unrolled_HI, Y
    STA beeb_readptr+1
    .no_jump

    \ Poke in JMP instuction
    LDY #0
    LDA #OPCODE_JMP
    STA (beeb_readptr), Y
    INY
    LDA #LO(mlaymask_unrolled_end)
    STA (beeb_readptr), Y
    INY
    LDA #HI(mlaymask_unrolled_end)
    STA (beeb_readptr), Y

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
        STA beeb_temp       ;smStackStart+1
        BNE same_char_column

        .no_partial_left
        LDA beeb_parity
        EOR #1
        \ Self-mod code to save a cycle per line
        STA beeb_temp       ;smStackStart+1

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
    CLC
    ADC beeb_temp           ; beeb_stack_start
    STA smStackStart+1

;    STA smSTACK1+1
;    STA smSTACK2+1

.plot_lines_loop

RASTER_COL PAL_cyan

    LDY #0                  ; bytes_per_line_in_sprite

\ Decode a line of sprite data using Exile method!

    .line_loop

    .sprite_addr
    LDA &FFFF, Y
    STA beeb_data

\ For mirror sprites we decode pixels left to right and push them onto the stack
\ Therefore bottom of the stack will be the right-most pixel to be drawn on left hand side

    LSR A
    LSR A
    STA beeb_temp

    AND #&22
    TAX
.smPIXELA
    LDA map_2bpp_to_mode2_pixel,X
    PHA

    LDA beeb_temp
    AND #&11
    TAX
.smPIXELB
    LDA map_2bpp_to_mode2_pixel,X
    PHA

    LDA beeb_data
    AND #&22
    TAX
.smPIXELC
    LDA map_2bpp_to_mode2_pixel,X
    PHA

    LDA beeb_data
    AND #&11
    TAX
.smPIXELD
    LDA map_2bpp_to_mode2_pixel,X         ; could be in ZP ala Exile to save 2cx4=8c per sprite byte
    PHA                                 ; [3c]

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

\ Now plot that data to the screen left to right

\ Maximum possible pixels / bytes written:

    .mlaymask_unrolled_start
    FOR bytes,0,(2*BEEB_MAX_LAY_WIDTH)-1,1
    BEEB_PLOT_LAYMASK_BYTES bytes
    NEXT
    .mlaymask_unrolled_end

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

    \ Poke in JMP instuction
    LDY #0
    LDA #&E8        ; INX
    STA (beeb_readptr), Y
    INY
    LDA #&BD        ; LDA abs, X
    STA (beeb_readptr), Y
    INY
    LDA #0          ;
    STA (beeb_readptr), Y

    JMP DONE

.mlaymask_unrolled_LO
FOR n,0,BEEB_MAX_LAY_WIDTH*2,1
EQUB LO(mlaymask_unrolled_start + n*BEEB_PLOT_LAYMASK_UNROLL_SIZE)
NEXT

.mlaymask_unrolled_HI
FOR n,0,BEEB_MAX_LAY_WIDTH*2,1
EQUB HI(mlaymask_unrolled_start + n*BEEB_PLOT_LAYMASK_UNROLL_SIZE)
NEXT
}

ENDIF

.beeb_plot_lay_end
