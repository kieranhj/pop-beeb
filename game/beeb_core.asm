; beeb_core.asm
; Beeb specific routines that need to be in Core memory

.beeb_core_start

\*-------------------------------
; Set custom CRTC mode
\*-------------------------------

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
    LDA #&F4            ; MODE 2
    STA &FE20

    \\ Set Palette
    CLC
    LDX #0
    LDA #0
    .palloop
    ORA beeb_palette,X
    INX
    STA &FE21
    AND #&F0
    ADC #&10
    BCC palloop

    RTS
}

\*-------------------------------
; Relocate image tables
\*-------------------------------

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
\ Now at &0000 for BEEB data
\    SEC
\    SBC beeb_writeptr+1
    CLC
    ADC beeb_readptr+1
    STA (beeb_readptr), Y

    INX
    CPX beeb_numimages
    BCC loop

    .return
    RTS
}


\*-------------------------------
; SHADOW RAM select
\*-------------------------------

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

.beeb_core_end
