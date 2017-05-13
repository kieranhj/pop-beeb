
.print_temp EQUB 0

; print given string with one argument value supplied in A
; preserves all registers
MACRO MPRINT    stringaddr
    sta print_temp:txa:pha:tya:pha
    ldx #LO(stringaddr)
    ldy #HI(stringaddr)
    lda print_temp
    jsr print
    pla:tay:pla:tax:lda print_temp
ENDMACRO

MACRO MPRINTMEM stringaddr, bufferaddr
    sta print_temp:txa:pha:tya:pha
    ldx #LO(bufferaddr)
    ldy #HI(bufferaddr)
    jsr print_set_output_buffer
    ldx #LO(stringaddr)
    ldy #HI(stringaddr)
    lda print_temp
    jsr print
    jsr print_set_output_os
    pla:tay:pla:tax:lda print_temp
ENDMACRO




; Select OSWRCH as the output stream
.print_set_output_os
{
    lda #LO(oswrch)
    sta print_char+1
    lda #HI(oswrch)
    sta print_char+2
    rts
}

; Select a memory buffer as the output stream
; X,Y is the output buffer address LSB/MSB
.print_set_output_buffer
{
    lda #LO(render_char)
    sta print_char+1
    lda #HI(render_char)
    sta print_char+2
    stx render_char+1
    sty render_char+2
    rts
}



; X/Y address of ZT string to print 
; Strings may contain embedded %a which is replaced by value of A 
; Strings may contain embedded %w which must be followed by a 16-bit address containing the 16-bit word value to be printed 
; Strings may contain %b which must be followed by a 16-bit address containing the 8-bit value to be printed 
; Strings may contain %v which must be followed by a 16-bit number to be printed
; Strings may contain %% to print a % character
; 
; eg.
; EQUS "text %a", 0
; EQUS "memory address value is %w", memory_address_lsb, memory_address_msb, ".", 0
.print
{
    stx print_fetch_char+1
    sty print_fetch_char+2
    tay

.loop
    jsr print_fetch_char

    cmp #0
    bne continue
    rts

.continue
    cmp #'%'
    beq check_arg

    jsr print_char
    jmp loop

.check_arg

    jsr print_fetch_char
    cmp #'%'
    bne check_arg_h

    jsr print_char
    jmp loop

.check_arg_h
    cmp #'h'
    bne check_arg_v

    ; todo

    jmp loop

.hex2ascii EQUS "0123456789ABCDEF"


.check_arg_v
    cmp #'v'
    bne check_arg_a

    jsr print_fetch_char
    sta binary_in+0
    jsr print_fetch_char
    sta binary_in+1

    jsr bin2bcd16
    jmp output_ascii

    jmp loop


.check_arg_a
    cmp #'a'
    bne check_arg_b

    ; single byte argument
    ; convert binary number to decimal
    tya
    jsr bin2bcd8
    jmp output_ascii

.check_arg_b
    cmp #'b'
    bne check_arg_w


    ; word address argument
    ; convert binary number to decimal
    jsr print_fetch_char
    sta arg_addr8+1
    jsr print_fetch_char
    sta arg_addr8+2

    ; copy 8-bit value stored at word address cont
.arg_addr8
    lda &FFFF
    jsr bin2bcd8
    jmp output_ascii



.check_arg_w
    cmp #'w'
    bne loop    ; unknown so ignore and continue

    ; word address argument
    ; convert binary number to decimal
    jsr print_fetch_char
    sta arg_addr16+1
    jsr print_fetch_char
    sta arg_addr16+2

    ; copy 16-bit value stored at word address cont
    ldx #0
.arg_addr16
    lda &FFFF,x
    sta binary_in,x
    inx
    cpx #2
    bne arg_addr16

    jsr bin2bcd16
    ; 16 bit bcd_out result
    ; 16 bit value generates max 5 decimal chars

    ; falls through to output_ascii

.output_ascii

    ; 16 bit bcd_out result
    ; 8 bit value generates max 3 decimal chars
    jsr bcd2ascii

    ldx #0
.ascii_loop
    lda ascii_out,x
    beq ascii_done
    jsr print_char
    inx
    bne ascii_loop  
.ascii_done    
    jmp loop
}

     
.binary_in      EQUW 0 ; value to convert (LSB first) 65536
.bcd_out        SKIP 3 ; bcd_out output, input of 0xffff will become $36, $55, $06
.ascii_out      SKIP 7 ; zero terminated ascii string output

; A contains 8-bit value to convert
.bin2bcd8
{
    sta binary_in+0
    lda #0
    sta binary_in+1
}
.bin2bcd16
{
    TXA
    PHA

    SED         ; Switch to decimal mode
    LDA #0      ; Ensure the result is clear
    STA bcd_out+0
    STA bcd_out+1
    STA bcd_out+2
    LDX #16     ; The number of source bits
        
.CNVBIT     
    ASL binary_in+0   ; Shift out one bit
    ROL binary_in+1
    LDA bcd_out+0   ; And add into result
    ADC bcd_out+0
    STA bcd_out+0
    LDA bcd_out+1   ; propagating any carry
    ADC bcd_out+1
    STA bcd_out+1
    LDA bcd_out+2   ; ... thru whole result
    ADC bcd_out+2
    STA bcd_out+2
    DEX         ; And repeat for next bit
    BNE CNVBIT
    CLD         ; Back to binary
    PLA
    TAX
    rts
}
; take a 3-byte bcd encoded number and convert to an ascii zero terminated string
; with leading zeros stripped 
; result placed into 'ascii_out'
; preserves X,Y
.bcd2ascii
{
    txa
    pha
    tya
    pha

    ; convert each BCD byte to two ascii bytes
    ldx #0
    ldy #2
.bcd_loop
    lda bcd_out,y
    and #&f0
    lsr a
    lsr a
    lsr a
    lsr a   
    clc
    adc #48
    sta ascii_out,x
    inx

    lda bcd_out,y
    and #&0f
    clc
    adc #48
    sta ascii_out,x
    inx    

    dey
    bpl bcd_loop

    ; zero terminate
    lda #0
    sta ascii_out,x

    ; strip leading zeros by copying numeric part of string
    ; to the front of the ascii_out array
    ldx #0
.lz_loop
    lda ascii_out,x
    cmp #48
    bne lz_out
    inx
    cpx #6
    bne lz_loop

; all zeros, so make sure at least one zero is emitted
    dex

.lz_out
    ldy #0
.lz_loop2
    lda ascii_out,x
    sta ascii_out,y
    beq lz_done
    inx
    iny
    cpx #6
    bne lz_loop2
.lz_done

    ; ??? not sure why I need this, above code should copy the ZT byte also.
    lda #0
    sta ascii_out,y

    pla
    tay
    pla
    tax
    rts
}


; send A to currently selected output stream
; set by print_set_output_buffer or print_set_output_os, defaults to OSWRCH
.print_char
{
    jsr oswrch      ; MODIFIED   
    rts
}

; send the byte in A to the current output buffer
.render_char
{
    sta &FFFF         ; MODIFIED
    inc render_char+1
    bne done
    inc render_char+2
.done
    rts
}

; fetch the next byte from the current input stream
.print_fetch_char
{
    lda &FFFF       ; MODIFIED
    inc print_fetch_char+1
    bne done
    inc print_fetch_char+2
.done
    rts
}