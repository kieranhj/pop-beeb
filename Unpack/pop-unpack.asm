\* unpack.asm

IF 0
 jmp SNGEXPAND
 jmp DBLEXPAND
 jmp DELTAEXPPOP
 jmp INVERTY
 jmp DELTAEXPWIPE

 jmp PURPLE
 jmp PROMPT
 jmp BLACKOUT
 jmp CLR
 jmp TEXT

 jmp SETDHIRES
 jmp FADEIN
 jmp LOADSUPER
 jmp FADEOUT
ENDIF

\*-------------------------------

IF 0
IOUDISoff = $c07f
IOUDISon = $c07e
DHIRESoff = $c05f
DHIRESon = $c05e
HIRESon = $c057
HIRESoff = $c056
PAGE2on = $c055
PAGE2off = $c054
MIXEDon = $c053
MIXEDoff = $c052
TEXTon = $c051
TEXToff = $c050
ALTCHARon = $c00f
ALTCHARoff = $c00e
ADCOLon = $c00d
ADCOLoff = $c00c
ALTZPon = $c009
ALTZPoff = $c008
RAMWRTaux = $c005
RAMWRTmain = $c004
RAMRDaux = $c003
RAMRDmain = $c002
ADSTOREon = $c001
ADSTOREoff = $c000

RWBANK2 = $c083
RWBANK1 = $c08b
ENDIF

IF 0
\*-------------------------------
\* RW18 ID bytes

POPside1 = $a9
POPside2 = $ad

\* RW18 zero page vars

slot = $fd
track = $fe
lastrack = $ff

\* RW18 commands

DrvOn = $00
DrvOff = $01
Seek = $02
RdSeqErr = $03
RdGrpErr = $04
WrtSeqErr = $05
WrtGrpErr = $06
ModID = $07
RdSeq = $83
RdGrp = $84
WrtSeq = $85
WrtGrp = $86
Inc = $40 ;.Inc to inc track
ENDIF

\*-------------------------------
\*
\*  Unpack single hi-res screen into page 1
\*  (Sorry about the code--it's lifted directly from DRAZ)
\*
\*-------------------------------

ORG &70

.unpack_readptr skip 2
.unpack_writeptr skip 2
.endline_ptr skip 2
.nextline_ptr skip 2

.rle_token skip 1
.rle_count skip 1
.rle_flag skip 1
.packed_byte skip 1

.beeb_readptr SKIP 2
.beeb_writeptr SKIP 2
.beeb_y SKIP 1

\*-------------------------------

.CrnDatPtr SKIP 2
.XClmPos SKIP 1
.YScrPos SKIP 1
.ByteHld SKIP 1
.RepeatCdn SKIP 1
.ScrBasPtr SKIP 2

\*-------------------------------

screen_addr = &6200

ORG &E00
GUARD &2000

.main
{
    LDA #HI(&6000)
    JSR SNGEXPAND

\\    JSR convert_to_beeb

    RTS
}

.SNGEXPAND
{
 STA unpack_readptr+1 ;org addr

 LDA #$20
 STA unpack_writeptr+1 ;dest addr

 LDA #0
 STA unpack_readptr
 STA unpack_writeptr

 LDA #$FE
 STA rle_token
 LDA #0
 STA rle_flag

 LDY #$27           ; 40 columns

.column_loop
 LDA #$78
 STA endline_ptr
 LDA #$20
 STA endline_ptr+1

 .set_start_of_line
 {
  LDA endline_ptr
  SEC
  SBC #$28
  STA endline_ptr
  BCS no_carry
  DEC endline_ptr+1
  .no_carry
 }

 LDA endline_ptr
 STA nextline_ptr
 LDA endline_ptr+1
 CLC
 ADC #4
 STA nextline_ptr+1

 .label_2
 {
  LDA nextline_ptr
  SEC
  SBC #$80
  STA nextline_ptr
  BCS no_carry
  DEC nextline_ptr+1
  .no_carry
 }

 LDA nextline_ptr
 STA unpack_writeptr

 LDA nextline_ptr+1
 CLC
 ADC #$20
 STA unpack_writeptr+1

.unpack_next_line
 LDA unpack_writeptr+1
 SEC
 SBC #4
 STA unpack_writeptr+1
 CLC
 BCC read_packed_byte

.inner_loop
 LDA unpack_writeptr+1
 CMP nextline_ptr+1
 BNE unpack_next_line

 LDA nextline_ptr
 CMP endline_ptr
 BNE label_2

 LDA nextline_ptr+1
 CMP endline_ptr+1
 BNE label_2

 LDA endline_ptr
 BNE set_start_of_line

 DEY
 BPL column_loop
 RTS

.read_packed_byte
 BIT rle_flag
 BMI write_byte_rle

 LDX #0
 LDA (unpack_readptr,X)
 STA packed_byte
 CMP rle_token
 BNE write_byte_literal

 {
  INC unpack_readptr
  BNE no_carry
  INC unpack_readptr+1
  .no_carry
 }

 LDA (unpack_readptr,X)
 STA rle_count

 {
  INC unpack_readptr
  BNE no_carry
  INC unpack_readptr+1
  .no_carry
 }

 LDA (unpack_readptr,X)
 STA packed_byte

 {
  INC unpack_readptr
  BNE no_carry
  INC unpack_readptr+1
  .no_carry
 }

 LDA #$80
 STA rle_flag
 CLC
 BCC write_byte_rle

.write_byte_literal
 LDA packed_byte
 ORA #$80
 STA (unpack_writeptr),Y

 {
    INC unpack_readptr
    BNE no_carry
    INC unpack_readptr+1
    .no_carry
 }
 CLC
 BCC inner_loop

.write_byte_rle
 LDA packed_byte
 ORA #$80
 STA (unpack_writeptr),Y

 DEC rle_count
 BNE inner_loop

 LDA #0
 STA rle_flag
 BEQ inner_loop
}

IF 0        ; maths currently wrong!
.convert_to_beeb
{
    LDA #0
    STA beeb_y

    .y_loop

    LDA #LO(&2000)
    STA beeb_readptr
    LDA #HI(&2000)
    STA beeb_readptr+1

    LDA beeb_y
    LSR A:LSR A:LSR A   ; DIV 8
    TAX

    ; + (y DIV 8) * $80
    CLC
    LDA mult_LO, X
    ADC beeb_readptr
    STA beeb_readptr
    LDA mult_HI, X
    ADC beeb_readptr+1
    STA beeb_readptr+1

    LDA beeb_y
    AND #&7             ; MOD 8
    ASL A: ASL A        ; * $400

    ; + (y MOD 8) * $400
    CLC
    ADC beeb_readptr+1
    STA beeb_readptr+1

    LDA #LO(screen_addr)
    STA beeb_writeptr
    LDA #HI(screen_addr)
    STA beeb_writeptr+1

    LDA beeb_y
    LSR A:LSR A:LSR A   ; DIV 8
    TAX

    CLC
    LDA beeb_LO, X
    ADC beeb_writeptr
    STA beeb_writeptr
    LDA beeb_HI, X
    ADC beeb_writeptr+1
    STA beeb_writeptr+1

    LDA beeb_y
    AND #&7
    CLC
    ADC beeb_writeptr
    STA beeb_writeptr
    LDA beeb_writeptr+1
    ADC #0
    STA beeb_writeptr+1

    LDY #0
    LDX #0
    .x_loop

    LDA (beeb_readptr), Y
    STA (beeb_writeptr), Y

    INC beeb_readptr
    BCC no_carry
    INC beeb_readptr+1
    .no_carry

    CLC
    LDA beeb_writeptr
    ADC #8
    STA beeb_writeptr
    LDA beeb_writeptr+1
    ADC #0
    STA beeb_writeptr+1

    INX
    CPX #40
    BCC x_loop

    LDY beeb_y
    INY
    STY beeb_y
    CPY #192
    BCC y_loop

    RTS
}

.mult_LO
FOR y,0,23,1
EQUB LO(y*$80)
NEXT

.mult_HI
FOR y,0,23,1
EQUB HI(y*$80)
NEXT

.beeb_LO
FOR y,0,23,1
EQUB LO(y*320)
NEXT

.beeb_HI
FOR y,0,23,1
EQUB HI(y*320)
NEXT
ENDIF

\*-------------------------------
\*
\*  Unpack crunched double hi-res screen
\*
\*  Robert A. Cook 3/89
\*
\*  In: A = hi byte of crunched data address
\*      RAMRD set to main/aux depending on where crunched
\*        data is stored
\*
\*-------------------------------

.DBLEXPAND
{
 sta CrnDatPtr+1

 lda #1
 sta CrnDatPtr
;(CrnDatPtr),0 is crunch type (unused)
 jmp WipeRgtExp
}

\*-------------------------------
\*
\*  Wipe Right Expand
\*
\*-------------------------------

.WipeRgtExp
{
 lda #0
 sta XClmPos

.Loop lda #0
 sta YScrPos
 jsr ExpandClm

 lda #1
 sta YScrPos
 jsr ExpandClm

 inc XClmPos

 lda XClmPos
 cmp #80
 bne Loop

.return
 rts
}

IF 0
*-------------------------------
*
*  Delta Expand
*
*  In: A = hi byte of crunched data address (in auxmem)
*
*-------------------------------
DeltaExp
 sta RAMRDaux

 sta CrnDatPtr+1

 lda #0
 sta CrnDatPtr

 sta XClmPos

:Loop ldy #0
 lda (CrnDatPtr),y
 cmp #-1
 beq :Done

 sta ByteHld
 and #$80
 beq :ExpandOne

 lda ByteHld
 and #$7f
 beq :NewCoord

 tax

 ldy #1
 lda (CrnDatPtr),y
 jsr ExpClmSeq1

 clc
 lda CrnDatPtr
 adc #2
 sta CrnDatPtr
 bcc :a4
 inc CrnDatPtr+1
:a4
 jmp :Next

:NewCoord
 ldy #1
 lda (CrnDatPtr),y
 sta XClmPos

 ldy #2
 lda (CrnDatPtr),y
 sta YScrPos

 clc
 lda CrnDatPtr
 adc #3
 sta CrnDatPtr
 bcc :a7
 inc CrnDatPtr+1
:a7
 jmp :Next

:ExpandOne
 lda ByteHld
 ldx #1
 jsr ExpClmSeq1

 inc CrnDatPtr
 bne :sysi8
 inc CrnDatPtr+1
:sysi8

:Next lda XClmPos
 cmp #$80
 bne :Loop

:Done sta RAMRDmain
]rts rts
ENDIF

\*-------------------------------
\*
\*  Expand Column
\*
\*-------------------------------

.ExpandClm
{
.Loop ldy #0
 lda (CrnDatPtr),y
 sta ByteHld
 and #$80
 beq ExpandOne

 ldy #1
 lda (CrnDatPtr),y
 tax
 lda ByteHld
 and #$7f
 jsr ExpClmSeq

 clc
 lda CrnDatPtr
 adc #2
 sta CrnDatPtr
 bcc a4
 inc CrnDatPtr+1
.a4
 jmp Next

.ExpandOne
 lda ByteHld
 ldx #1
 jsr ExpClmSeq

 inc CrnDatPtr
 bne sysi5
 inc CrnDatPtr+1
.sysi5

.Next lda YScrPos
 cmp #192
 bcc Loop

 rts
}

\*-------------------------------
\*
\*  Expand Column Sequence
\*
\*-------------------------------
\*
\*  In: XClmPos
\*      YScrPos
\*      A (byte pattern)
\*      X (repeat rle_count)
\*
\*  Out: YScrPos (modified)
\*
\*-------------------------------

.ExpClmSeq
{
 sta ByteHld
 stx RepeatCdn

.Loop ldx XClmPos
 ldy YScrPos
 lda ByteHld
 jsr PutScrByte

 lda YScrPos
 clc
 adc #2
 sta YScrPos

 dec RepeatCdn
 bne Loop

 rts
}

\*-------------------------------
\*
\* Expand Column Sequence 1
\*
\*-------------------------------
.ExpClmSeq1
{
 sta ByteHld
 stx RepeatCdn

.Loop ldx XClmPos
 ldy YScrPos
 lda ByteHld
 bmi Next

 jsr PutScrByte

.Next inc YScrPos

 lda YScrPos
 cmp #192
 bne SkipXInc

 lda #0
 sta YScrPos

 inc XClmPos

.SkipXInc
 dec RepeatCdn
 bne Loop

 rts
}

\*-------------------------------
\*
\*  Put DHires Byte Value
\*
\*-------------------------------
\*
\*  In:  X (XClmPos)
\*       Y (YScrPos)
\*       A (Byte value)
\*
\*-------------------------------

.PutScrByte
{
 sta ByteHld
 ;YScrPos in Y
 lda YLO,y
 sta ScrBasPtr
 lda YHI,y
 ora #$20 ;DHires page 1
 sta ScrBasPtr+1

 txa ;XClmPos in X
 lsr A
 tay
 bcs NoAuxSet

\ sta RAMWRTaux

.NoAuxSet lda ByteHld
 sta (ScrBasPtr),y

\ sta RAMWRTmain

.return
 rts
}

IF 0
*-------------------------------
*
*  Delta Expand (Pop or Wipe)
*
*  In: A = hi byte of crunched data address (in auxmem)
*
*-------------------------------
DELTAEXPPOP
 sta PAGE2on
]DE jsr DeltaExp
 sta PAGE2off
 sta RAMRDaux
 sta RAMWRTaux
]rts rts

DELTAEXPWIPE
 sta PAGE2off
 jmp ]DE

*-------------------------------
*
* Invert Y-tables
*
*-------------------------------
INVERTY
 ldx #191 ;low line
 ldy #0 ;high line

* Switch low & high lines

:loop lda YLO,x
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

* Move 1 line closer to ctr

 dex
 iny
 cpy #96
 bcc :loop
]rts rts

msg1 asc "Insert Prince of Persia Disk, Side "
msg2 asc "C@"

*-------------------------------
PROMPT
 lda #"A"
 ldx BBundID
 cpx #POPside1
 beq :1
 lda #"B"
:1 sta msg2 ;side A or B?

 jsr blackout

 sta RAMWRTmain

 ldx #0
:loop lda msg1,x
 cmp #"@"
 beq :done
 sta $528+2,x ;midscrn
 inx
 bpl :loop

:done sta RAMWRTaux
 jsr whoop ;whoop spkr

:wloop lda $c000
 ora $c061
 ora $c062
 bpl :wloop
 sta $c010

 jmp clr ;clear screen

*-------------------------------
CLR bit RWBANK2
 bit RWBANK2

 sta $c010

 lda #" "
 jmp _lrcls ;in hires

*-------------------------------
*
* Show black screen (text page 1)
*
*-------------------------------
BLACKOUT
 jsr CLR

TEXT sta RAMRDaux
 jsr vblank
 sta TEXTon
 sta ADCOLoff
 sta PAGE2off
]rts rts

*-------------------------------
* Set dbl hires
*-------------------------------
SETDHIRES
 sta RAMRDaux
 sta RAMWRTaux
 jsr vblank
 sta ADCOLon
 bit HIRESon

 bit DHIRESon
 bit DHIRESoff
 bit DHIRESon
 bit DHIRESoff
 bit DHIRESon ;for old Apple RGB card

 sta TEXToff
 rts

**************************************************
**************************************************
**************************************************
 xc
 xc

stlx mac bank;addr
 hex 9f
 da ]2
 db ]1
 <<<
ldlx mac bank;addr
 hex bf
 da ]2
 db ]1
 <<<

*-------------------------------
*
* FADE IN
*
* In: s-hires data in $2000.9FFF
*     A = 0 main, 1 aux
*
*-------------------------------
FADEIN
 sta RAMRDmain
 sta :sm1+2
 sta :sm2+2

 clc
 xce

 sep $30 ;axy

 lda #%00011110
 sta $C035 ;shadow reg
 lda #$41
 sta $C029 ;SH reg

 rep $30 ;AXY

* Clear scan line control byte table
* and palette 0 to black

 lda #$0000
 ldx #$011E
:scbclr dex
 dex
 stlx $E1;$9D00
 bne :scbclr

* Now move data over

 ldx #$2000
 ldy #$2000
 lda #32000-1
 phb
:sm1 mvn $E1,1 ;main/aux
 plb

* Turn on Super Hires mode

 sep $20
 lda #$C1
 sta $C029
 rep $20

* Move desired palette over to PalFade area

 ldx #$9D00 ;aux mem
 ldy #new_palette
 lda #32-1
 phb
:sm2 mvn 0,1 ;aux to main/aux
 plb

* Now fade in the picture

 bra PalFade ;switches back to e-mode

*-------------------------------
*
* FADE OUT
*
*-------------------------------
FADEOUT
 mx 3

* Clear the "destination" palette back to zero

 ldx #31
 lda #$00
:palclr sta new_palette,x
 dex
 bpl :palclr

* Now fade out

 bra PalFade ;switches back to e-mode

*------------------------------------------------- PalFade
*
* Given current palette at $E19E00.1F, fade to
* new palette given in new_palette
*

new_palette ds 32

PalFade dum 0
:green ds 1
:blue ds 1
 dend

 sec
 xce

 bit $C019
 bmi *-3

 ldy #16

:fadein ldx #3

:fadein2 bit $C019
 bpl *-3

 bit $C019
 bmi *-3

 dex
 bne :fadein2

 ldx #30
:palloop ldlx $E1;$9E01
 and #$0f
 cmp new_palette+1,x
 beq :red_ok
 inc
 blt :red_ok
 dec
 dec

:red_ok stlx $E1;$9E01

 lda new_palette,x
 and #$F0
 sta :green

 ldlx $E1;$9E00
 and #$F0
 cmp :green
 beq :green_ok
 blt :grn_add
 sbc #$20
:grn_add clc
 adc #$10

:green_ok sta :green

 lda new_palette,x
 and #$0F
 sta :blue

 ldlx $E1;$9E00
 and #$0F
 cmp :blue
 beq :blue_ok
 inc
 blt :blue_ok
 dec
 dec

:blue_ok ora :green
 stlx $E1;$9E00

 dex
 dex
 bpl :palloop

 dey
 bpl :fadein

 rts

 xc off
 mx 3

*===============================
*
* Load super hi-res data
*
*-------------------------------
LOADSUPER
 jsr rw18
 db ModID,$79 ;set "side C"

 lda #0
 sta track
 sta RAMWRTmain
 jsr loadscrn ;"Tracks" 0-6: palace (mainmem)

 sta RAMWRTaux
 jmp loadscrn ;"Tracks" 7-13: epilog (auxmem)

*-------------------------------
*
* Load super hi-res screen into $2000.9FFF
*
*-------------------------------
loadscrn
 lda #$20
:loop sta :sm
 jsr rw18
 db RdSeq.Inc
:sm db $20
 lda :sm
 clc
 adc #$12
 cmp #$9e
 bcc :loop ;load 7 tracks
]rts rts
ENDIF

.YLO
FOR Y%,0,191,1
address=&2000 + (((Y% MOD 64) DIV 8) * &80) + ((Y% MOD 8) * &400) + ((Y% DIV 64) * &28)
EQUB LO(address)
NEXT
\ hex 00000000000000008080808080808080
\ hex 00000000000000008080808080808080
\ hex 00000000000000008080808080808080
\ hex 00000000000000008080808080808080

\ hex 2828282828282828A8A8A8A8A8A8A8A8
\ hex 2828282828282828A8A8A8A8A8A8A8A8
\ hex 2828282828282828A8A8A8A8A8A8A8A8
\ hex 2828282828282828A8A8A8A8A8A8A8A8

\ hex 5050505050505050D0D0D0D0D0D0D0D0
\ hex 5050505050505050D0D0D0D0D0D0D0D0
\ hex 5050505050505050D0D0D0D0D0D0D0D0
\ hex 5050505050505050D0D0D0D0D0D0D0D0

; Would ideally be PAGE_ALIGN
.YHI
FOR Y%,0,191,1
address=&2000 + (((Y% MOD 64) DIV 8) * &80) + ((Y% MOD 8) * &400) + ((Y% DIV 64) * &28)
EQUB HI(address)
NEXT
\ hex 2024282C3034383C2024282C3034383C
\ hex 2125292D3135393D2125292D3135393D
\ hex 22262A2E32363A3E22262A2E32363A3E
\ hex 23272B2F33373B3F23272B2F33373B3F

\ hex 2024282C3034383C2024282C3034383C
\ hex 2125292D3135393D2125292D3135393D
\ hex 22262A2E32363A3E22262A2E32363A3E
\ hex 23272B2F33373B3F23272B2F33373B3F

\ hex 2024282C3034383C2024282C3034383C
\ hex 2125292D3135393D2125292D3135393D
\ hex 22262A2E32363A3E22262A2E32363A3E
\ hex 23272B2F33373B3F23272B2F33373B3F

ALIGN &100
.pacRoomData
PUTFILE "Other/PRINCESS.SIDEA.SCENE", "PRINA", 0, 0
PUTFILE "Other/PRINCESS.SIDEB.SCENE", "PRINB", 0, 0
PUTFILE "Other/STAGE1.SIDEA.DATA", "SIDEA", 0, 0
PUTFILE "Other/STAGE1.SIDEB.DATA", "SIDEB", 0, 0

PUTBASIC "convpac.bas", "convpac"

SAVE "unpack", main, P%, main