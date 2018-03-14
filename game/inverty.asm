; inverty.asm
; INVERTY

\*-------------------------------
\* Invert Y-tables
\*-------------------------------

.INVERTY
{
 ldx #191 ;low line
 ldy #0 ;high line

\* Switch low & high lines

.loop lda YLO,x
 pha
 lda YLO,y
 sta YLO,x
 pla
 sta YLO,y

 lda YHI,x
 pha
 lda YHI,y
 sta YHI,x
 pla
 sta YHI,y

\* Move 1 line closer to ctr

 dex
 iny
 cpy #96
 bcc loop

\\ Now self-mode code to invert usage
\\ This code is currently in Core

    \ CMP #&00 <> CMP #&07
    LDA beeb_plot_sprite_FASTLAYSTA_PP_smCMP+1
    EOR #&07
    STA beeb_plot_sprite_FASTLAYSTA_PP_smCMP+1
    STA beeb_plot_layrsave_smCMP+1

    \ DEC zp <> INC zp
    LDA beeb_plot_sprite_FASTLAYSTA_PP_smDEC
    EOR #(OPCODE_DECzp EOR OPCODE_INCzp)
    STA beeb_plot_sprite_FASTLAYSTA_PP_smDEC
    STA beeb_plot_layrsave_smDEC

    \ SEC <> CLC
    LDA beeb_plot_sprite_FASTLAYSTA_PP_smSEC
    EOR #(OPCODE_SEC EOR OPCODE_CLC)
    STA beeb_plot_sprite_FASTLAYSTA_PP_smSEC
    STA beeb_plot_layrsave_smSEC

    \ SBC #imm <> ADC #imm
    LDA beeb_plot_sprite_FASTLAYSTA_PP_smSBC1
    EOR #(OPCODE_SBCimm EOR OPCODE_ADCimm)
    STA beeb_plot_sprite_FASTLAYSTA_PP_smSBC1
    STA beeb_plot_sprite_FASTLAYSTA_PP_smSBC2
    STA beeb_plot_layrsave_smSBC1
    STA beeb_plot_layrsave_smSBC2

    \ EOR #&07 <> EOR #&00
    LDA beeb_plot_layrsave_smEOR+1
    EOR #&07
    STA beeb_plot_layrsave_smEOR+1

\\ Any code in Main has to be modded twice

    \ Invert code in current RAM
    JSR beeb_plot_invert_code_in_main
 
    \ Make other buffer writable
    lda &fe34
    eor #4	; invert bits 0 (CRTC) & 2 (RAM)
    sta &fe34

    \ Invert code in SHADOW RAM
    JSR beeb_plot_invert_code_in_main

    \ Switch back to double buffer
    lda &fe34
    eor #4	; invert bits 0 (CRTC) & 2 (RAM)
    sta &fe34

    RTS
}

.beeb_plot_invert_code_in_main
{
    \ CMP #&00 <> CMP #&07
    LDA beeb_plot_wipe_smCMP+1
    EOR #&07
    STA beeb_plot_wipe_smCMP+1
    STA beeb_plot_sprite_LayMask_smCMP+1
    STA beeb_plot_sprite_FASTMASK_smCMP+1
    STA beeb_plot_sprite_FASTLAYAND_PP_smCMP+1
    STA beeb_plot_peel_smCMP+1

    \ DEC zp <> INC zp
    LDA beeb_plot_wipe_smDEC
    EOR #(OPCODE_DECzp EOR OPCODE_INCzp)
    STA beeb_plot_wipe_smDEC
    STA beeb_plot_sprite_LayMask_smDEC
    STA beeb_plot_sprite_FASTMASK_smDEC
    STA beeb_plot_sprite_FASTLAYAND_PP_smDEC
    STA beeb_plot_peel_smDEC

    \ SEC <> CLC
    LDA beeb_plot_wipe_smSEC
    EOR #(OPCODE_SEC EOR OPCODE_CLC)
    STA beeb_plot_wipe_smSEC
    STA beeb_plot_sprite_LayMask_smSEC
    STA beeb_plot_sprite_FASTMASK_smSEC
    STA beeb_plot_sprite_FASTLAYAND_PP_smSEC
    STA beeb_plot_peel_smSEC

    \ SBC #imm <> ADC #imm
    LDA beeb_plot_wipe_smSBC1
    EOR #(OPCODE_SBCimm EOR OPCODE_ADCimm)
    STA beeb_plot_wipe_smSBC1
    STA beeb_plot_wipe_smSBC2
    STA beeb_plot_sprite_LayMask_smSBC1
    STA beeb_plot_sprite_LayMask_smSBC2
    STA beeb_plot_sprite_FASTMASK_smSBC1
    STA beeb_plot_sprite_FASTMASK_smSBC2
    STA beeb_plot_sprite_FASTLAYAND_PP_smSBC1
    STA beeb_plot_sprite_FASTLAYAND_PP_smSBC2
    STA beeb_plot_peel_smSBC1
    STA beeb_plot_peel_smSBC2

    \ EOR #&07 <> EOR #&00
    LDA beeb_plot_peel_smEOR+1
    EOR #&07
    STA beeb_plot_peel_smEOR+1

    RTS  
}
