; beeb-plot-wipe
; BBC Micro plot functions
; Specialisations of wipe permutations

\*-------------------------------
\*
\*  F A S T B L A C K
\*
\*  Wipe a rectangular area to black2
\*
\*  Width/height passed in IMAGE/IMAGE+1
\*  (width in bytes, height in pixels)
\*
\*-------------------------------

.beeb_plot_wipe_start

IF _UNROLL_WIPE

.beeb_plot_wipe
{
    LDY YCO
    LDX XCO

    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA beeb_writeptr
    LDA Mult16_HI,X
    ADC YHI,Y
    STA beeb_writeptr+1
    
    \\ Jump to function
IF 0;_DEBUG
    LDX width
    CPX #4
    BEQ width_ok
    BRK
.width_ok
ENDIF

    LDA YCO
    TAX
    SBC height
    BCS no_yclip
    LDA #LO(-1)
    .no_yclip
    STA beeb_plot_wipe_y_loop_smTop+1
}
\\ Fall through!
.beeb_plot_wipe_4bytes   ; 34 Apple bytes = 8 Beeb bytes

.beeb_plot_wipe_y_loop

    LDA #0

    LDY #0
    STA (beeb_writeptr), Y

    LDY #8
    STA (beeb_writeptr), Y

    LDY #16
    STA (beeb_writeptr), Y

    LDY #24
    STA (beeb_writeptr), Y

    LDY #32
    STA (beeb_writeptr), Y

    LDY #40
    STA (beeb_writeptr), Y

    LDY #48
    STA (beeb_writeptr), Y

    LDY #56
    STA (beeb_writeptr), Y

    DEX
.beeb_plot_wipe_y_loop_smTop
    CPX #&FF
    BEQ beeb_plot_wipe_done_y

    LDA beeb_writeptr
    AND #&07

.beeb_plot_wipe_smCMP
    CMP #&00
    BEQ beeb_plot_wipe_smSEC

.beeb_plot_wipe_smDEC
    DEC beeb_writeptr
    BRA beeb_plot_wipe_y_loop

.beeb_plot_wipe_smSEC
    SEC
    LDA beeb_writeptr
.beeb_plot_wipe_smSBC1
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr
    LDA beeb_writeptr+1
.beeb_plot_wipe_smSBC2
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA beeb_writeptr+1

    BRA beeb_plot_wipe_y_loop

.beeb_plot_wipe_done_y
    RTS    


ELSE

\*-------------------------------
\*
\*  F A S T B L A C K
\*
\*  Wipe a rectangular area to black2
\*
\*  Width/height passed in IMAGE/IMAGE+1
\*  (width in bytes, height in pixels)
\*
\*-------------------------------

.beeb_plot_wipe
{
    \ OFFSET IGNORED
    \ OPACITY IGNORED
    \ MIRROR IGNORED
    \ CLIPPING IGNORED
    
    \ XCO & YCO are screen coordinates
    \ XCO (0-39) and YCO (0-191)

    \ Convert to Beeb screen layout

    \ Mask off Y offset

    LDY YCO
\ Bounds check YCO
IF _DEBUG
    CPY #192
    BCC y_ok
    BRK
    .y_ok
ENDIF

    LDX XCO
\ Bounds check XCO
IF _DEBUG
    CPX #70
    BCC x_ok
    BRK
    .x_ok
ENDIF

    \ Look up Beeb screen address

    CLC
    LDA Mult16_LO,X
    ADC YLO,Y
    STA scrn_addr+1
    LDA Mult16_HI,X
    ADC YHI,Y
    STA scrn_addr+2
    
    \ Set opacity

IF _DEBUG
    LDA OPACITY
;   STA smOPACITY+1
    BEQ is_black
    BRK
    .is_black
ENDIF

    \ Plot loop

    LDA width
    ASL A
    ASL A:ASL A: ASL A      ; x8
    SEC
    SBC #8
    STA smXMAX+1

    LDY height

    .y_loop

;    .smOPACITY
;    LDA #0                  ; OPACITY
\ ONLY BLACK

    .smXMAX
    LDX #0                          ; 2c
    SEC

    .x_loop

    .scrn_addr
    STZ &FFFF, X

    TXA                     ; next char column [6c]
    SBC #8    
    TAX                     ; 6c

    BCS x_loop               ; 3c

    DEY                             ; 2c
    BEQ done_y                      ; 2c

    LDA scrn_addr+1               ; 3c
    AND #&07                        ; 2c
    BEQ one_row_up                  ; 2c

    DEC scrn_addr+1               ; 5c
    BRA y_loop                      ; 3c

    .one_row_up
    SEC
    LDA scrn_addr+1
    SBC #LO(BEEB_SCREEN_ROW_BYTES-7)
    STA scrn_addr+1
    LDA scrn_addr+2
    SBC #HI(BEEB_SCREEN_ROW_BYTES-7)
    STA scrn_addr+2

    BRA y_loop

    .done_y

    RTS
}
\\ 5+6+2+5=18c*2=36c per abyte + 6+7=13c per line
ENDIF

.beeb_plot_wipe_end
