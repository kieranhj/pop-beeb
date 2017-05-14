; pop-beeb

INCLUDE "lib/bbc.h.asm"
INCLUDE "lib/bbc_utils.h.asm"

\* movedata
\*-------------------------------
\* objnames

space = 0
floor = 1
spikes = 2
posts = 3
gate = 4
dpressplate = 5 ;down
pressplate = 6 ;up
panelwif = 7 ;w/floor
pillarbottom = 8
pillartop = 9
flask = 10
loose = 11
panelwof = 12 ;w/o floor
mirror = 13
rubble = 14
upressplate = 15
exit = 16
exit2 = 17
slicer = 18
torch = 19
block = 20
bones = 21
sword = 22
window = 23
window2 = 24
archbot = 25
archtop1 = 26
archtop2 = 27
archtop3 = 28
archtop4 = 29

\*-------------------------------
\*
\*  Misc. constants
\*
\*-------------------------------
ScrnWidth = 140
ScrnHeight = 192

ScrnLeft = 58
ScrnRight = ScrnLeft+ScrnWidth-1
ScrnTop = 0
ScrnBottom = ScrnTop+ScrnHeight-1

secmask = %11000000
reqmask = %00100000
idmask = %00011111

and = 0
ora = 1
sta = 2
eor = 3
mask = 4


\*-------------------------------
\*  $00-17: Hires parameters
\*-------------------------------
ORG $00

.PAGE skip 1
.XCO skip 1
.YCO skip 1
.OFFSET skip 1
.IMAGE skip 2
.OPACITY skip 1
.TABLE skip 2
.PEELBUF skip 2
.PEELIMG skip 2
.PEELXCO skip 1
.PEELYCO skip 1
.TOPCUT skip 1
.LEFTCUT skip 1
.RIGHTCUT skip 1
.BANK skip 1
.BOTCUT skip 1

height = IMAGE
width = IMAGE+1


\*-------------------------------
\*  $18-3f: Global vars
\*-------------------------------
 ORG $18

.SCRNUM skip 1
.BlueType skip 2
.BlueSpec skip 2
.PRECED skip 1
.spreced skip 1
.PREV skip 3
.sprev skip 3
.scrnLeft skip 1
.scrnAbove skip 1
.scrnBelow skip 1
.scrnBelowL skip 1


ORG &70
GUARD &8F

.readptr    SKIP 2
.writeptr   SKIP 2

.numimages  SKIP 1
.beeb_width      SKIP 1
.beeb_height     SKIP 1

.yoffset    SKIP 1
.beeb_yindex     SKIP 1

.apple_count    SKIP 1          ; width in bytes
.apple_byte     SKIP 1          ; sprite data

.beeb_byte  SKIP 1              ; no lookup for screen byte
.beeb_count SKIP 1              ; beeb bits (8/4)

.bit_count  SKIP 1              ; apple bits (7)
.pal_index  SKIP 1              ; lookup for screen byte

.sprite_no  SKIP 1


; dum locals
ORG $e8
GUARD &fa
.index skip 1
.rowno skip 1
.colno skip 1
.yindex skip 1
.objid skip 1
.state skip 1
.Ay skip 1
.Dy skip 1
.gateposn skip 1
.gatebot skip 1
.xsave skip 1
.blockxco skip 1
.switches skip 1
.obj1 skip 1
.obj2 skip 1
.blockthr skip 1
; dend

ORG &E00
GUARD &3000

PLOT_MODE = 1

.start

; Master 128 PAGE is &0E00 since MOS uses other RAM buffers for DFS workspace
SCRATCH_RAM_ADDR = &0400

INCLUDE "lib/disksys.asm"
INCLUDE "lib/swr.asm"
INCLUDE "lib/print.asm"

; disk loader uses hacky filename format (same as catalogue) 
; we use disk loader for SWR banks only
.bank_file0   EQUS "Bank0  $"
.bank_file1   EQUS "Bank1  $"
.bank_file2   EQUS "Bank2  $"
.bank_file3   EQUS "Bank3  $"

.screen_file  EQUS "LOAD Page", 13

.swr_fail_text EQUS "No SWR banks found.", 13, 10, 0
.swr_bank_text EQUS "Found %b", LO(swr_ram_banks_count), HI(swr_ram_banks_count), " SWR banks.", 13, 10, 0
.swr_bank_text2 EQUS " Bank %a", 13, 10, 0

.loading_bank_text EQUS "Loading bank... ", 0
.loading_bank_text2 EQUS "OK", 13, 10, 0

.main
{
    \\ SWRAM init
    jsr swr_init
    bne swr_ok

    MPRINT swr_fail_text
    rts

.swr_ok

    MPRINT    swr_bank_text
    ldx #0
.swr_print_loop
    lda swr_ram_banks,x
    MPRINT    swr_bank_text2
    inx
    cpx swr_ram_banks_count
    bne swr_print_loop

	\\ load all SWR banks

    ; SWR 0
    MPRINT loading_bank_text  
    lda #0
    jsr swr_select_slot
    lda #&80
    ldx #LO(bank_file0)
    ldy #HI(bank_file0)
    jsr disksys_load_file
    MPRINT loading_bank_text2   

    \\ MODE
    LDA #22
    JSR &ffee
    LDA #PLOT_MODE
    JSR &ffee

    \\ Select slot 0
    LDA #0
    JSR swr_select_slot

    \\ Relocate sprite data
    LDA #LO(chtab1)
    STA readptr
    LDA #HI(chtab1)
    STA readptr+1
    JSR pop_relocate_chtab

    LDX #0

    .plot_loop
    STX sprite_no
    
IF PLOT_MODE=4
    \\ Sprite plot
    LDA #LO(&6500)
    STA writeptr
    LDA #HI(&6500)
    STA writeptr+1

    TXA
    JSR apple_plot_mode_4
ENDIF

IF PLOT_MODE=1
    \\ Sprite plot
    LDA #LO(&4A00)
    STA writeptr
    LDA #HI(&4A00)
    STA writeptr+1

    TXA
    JSR apple_plot_mode_1
ENDIF

    ldx#10:ldy#0:lda#&81:jsr osbyte	

    LDX sprite_no
    INX
    CPX numimages
    BCC plot_loop

    .return
    RTS
}

.pop_relocate_chtab
{
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
    STA beeb_width
    INY
    LDA (readptr), Y
    STA beeb_height

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

    LDA beeb_width
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
    DEC beeb_height
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
    STA beeb_width
    INY
    LDA (readptr), Y
    STA beeb_height

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
    STY beeb_yindex

    LDA beeb_width
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

    LDY beeb_yindex
    STA (writeptr), Y

    \\ Next screen column
    TYA
    CLC
    ADC #8
    STA beeb_yindex

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

    LDY beeb_yindex
    STA (writeptr), Y
    
    .done_row
    DEC beeb_height
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

\\.chtab7
\\INCBIN "Images/IMG.CHTAB7.bin"


\*-------------------------------
\*
\*  Fast screen redraw
\*
\*  Same general structure as SURE, but redraws only those
\*  blocks specified by redraw buffers.
\*
\*-------------------------------
.FAST
{
 jsr getprev

 lda SCRNUM
 jsr calcblue

\\ lda #0
\\ ldy #20
\\ jsr metbufs3 ;If strength meter is in danger of
\\ sta redkidmeter ;being overwritten, mark it for redraw

\\ lda #0
\\ ldy #28
\\ jsr metbufs2
\\ sta redoppmeter ;opponent meter too

\\ lda #30
\\ sta yindex
\\ jsr drawobjs ;Draw o.s. characters first

\*  Draw 3 rows of 10 blocks (L-R, T-B)

 ldy #2
.row sty rowno

 lda BlockBot+1,y
 sta Dy
 sec
 sbc #3
 sta Ay

 lda Mult10,y
 sta yindex

 lda PREV,y
 sta PRECED
 lda sprev,y
 sta spreced

 jsr getbelow

 lda #0
 sta colno

.loop asl a
 asl a
 sta XCO
 sta blockxco

 ldy yindex
 jsr getobjid
 sta objid

 jsr RedBlockFast

 lda objid
 sta PRECED
 lda state
 sta spreced

 inc yindex
 inc colno

 lda colno
 cmp #10
 bcs nextln
 jmp loop

.nextln ldy rowno
 beq cont
 dey
 jmp row

\* Now draw bottom row of screen above (D-sections only)

.cont jsr setback

 ldy #2
 sty rowno

 lda #2
 sta Dy
 lda #&FF
 sta Ay

 lda Mult10,y
 sta yindex

 lda #0
 sta PRECED

 lda scrnBelow
 pha
 lda scrnBelowL
 pha

 lda SCRNUM
 sta scrnBelow
 lda scrnLeft
 sta scrnBelowL

 jsr getbelow

 lda scrnAbove
 beq done
 jsr calcblue

 lda #0
 sta colno
.dloop
 asl a
 asl a
 sta blockxco
 sta XCO

 ldy yindex
 jsr getobjid1
 sta objid

 jsr RedDFast

 lda objid
 sta PRECED
 lda state
 sta spreced

 inc yindex
 inc colno

 lda colno
 cmp #10
 bcc dloop

.done
 pla
 sta scrnBelowL
 pla
 sta scrnBelow

\* Now draw comix (impact stars) & strength meters

\\ lda #$ff
\\ sta yindex
\\ jsr drawobjs ;draw comix (index = -1)

\\ jmp updatemeters
 RTS
}

\*-------------------------------
\*
\*  Get objids & states of 3 rightmost blocks
\*  of left-neighboring screen
\*
\*  Out: PREV/sprev [0-2]
\*
\*-------------------------------
.getprev
{
 lda SCRNUM
 beq null

 lda scrnLeft
 beq blackscrn

.cont jsr calcblue ;screen to left

 ldy #9
 jsr getobjid1
 sta PREV
 lda state
 sta sprev

 ldy #19
 jsr getobjid1
 sta PREV+1
 lda state
 sta sprev+1

 ldy #29
 jsr getobjid1
 sta PREV+2
 lda state
 sta sprev+2

 rts

.null ;this scrn is null screen
 lda scrnLeft
 bne cont

.blackscrn ;screen to left is null scrn
 lda #block
 sta PREV
 sta PREV+1
 sta PREV+2
 lda #0
 sta sprev
 sta sprev+1
 sta sprev+2
 rts
}

\*-------------------------------
\* The following routines properly belong to FRAMEADV
\* but have been moved here for lack of space
\*-------------------------------
\*
\*  C A L C   B L U E
\*
\*  Given:  screen #, 1-24 (in acc)
\*  Return: start of BLUETYPE table (in BlueType)
\*          start of BLUESPEC table (in BlueSpec)
\*
\*  If A = 0...
\*    In game: returns garbage
\*    In builder: returns menu data
\*
\*-------------------------------
.calcblue       ; CALCBLUE
{
\\ cmp #0
\\ beq calcmenu

 sec
 sbc #1 ;reduce to 0-23
 asl a
 tax ;x2

 lda Mult30,x
 clc
 adc #LO(blueprnt)
 sta BlueType

 lda Mult30+1,x
 adc #HI(blueprnt)
 sta BlueType+1

 lda BlueType
 clc
 adc #LO(24*30)
 sta BlueSpec

 lda BlueType+1
 adc #HI(24*30)
 sta BlueSpec+1

.rts rts
}

\*-------------------------------
\*
\*  Get objids & states of 10 blocks in row below,
\*  1 block to left
\*
\*  In:  rowno
\*  Out: BELOW/SBELOW [0-9]
\*
\*  Use getbelow1 to look at screens other than scrnBelow
\*  (In: A = scrn #)
\*
\*-------------------------------
.getbelow
{
 ldx rowno
 cpx #2
 bcc onscr

\* Looking below bottom row

 lda scrnBelow
 beq belowblack ;screen below is black
 jsr calcblue

 ldy #8 ;skip rmost
.loop
 jsr getobjid

 sta BELOW+1,y
 lda state
 sta SBELOW+1,y
 dey
 bpl loop
.cont1
 lda scrnBelowL
 beq llblack ;screen to l.l. is black
 jsr calcblue

 ldy #9 ;u.r. block
 jsr getobjid
 sta BELOW
 lda state
 sta SBELOW
.done
 lda SCRNUM
 jsr calcblue ;restore SCRNUM
 rts

\* "ONSCREEN": Looking below top or middle row

.onscr lda PREV+1,x
 sta BELOW
 lda sprev+1,x
 sta SBELOW

 lda yindex
 clc
 adc #10
 tay

 ldx #1

.loop1 stx xsave
 jsr getobjid
 ldx xsave

 sta BELOW,x

 lda state
 sta SBELOW,x

 iny
 inx
 cpx #10
 bcc loop1

 rts

\* Look below null screen

.belowblack
 lda #1
 tax
.loop2 sta BELOW,x
 inx
 cpx #10
 bcc loop2
 bcs cont1

.llblack
 lda level
 cmp #12
 beq label2 ;sorry Lance!
 lda #block
.label1 sta BELOW
 bpl done
.label2 lda #space
 bpl label1
}

\*-------------------------------
\*
\*  Get objid & state
\*
\*  In: BlueType/Spec,Y
\*
\*  Out: A = objid
\*       state = state
\*
\*  Preserves X & Y
\*
\*-------------------------------
.getobjid

 lda SCRNUM
 beq GOnull ;null scrn has no blueprint

\* Use getobjid1 for screen #s other than SCRNUM

.getobjid1
{
\\ do EditorDisk
\\ lda inbuilder
\\ bne getobjbldr
\ fin

 lda (BlueSpec),y
 sta state

 lda (BlueType),y
 and #idmask

 cmp #pressplate
 beq plate

 cmp #upressplate
 beq upp

 rts

\* Handle depressed pressplate

.plate lda state ;LINKLOC index
 tax
 lda LINKMAP,x

 and #%00011111 ;bits 0-4
 cmp #2
 bcc up

 lda #dpressplate ;plate depressed
 rts

.up lda #pressplate ;plate up
 rts

\* Handle depressed upressplate

.upp lda state
 tax
 lda LINKMAP,x
 and #%00011111
 cmp #2
 bcc up1

 lda #0
 sta state
 lda #floor ;depressed upp looks just like floor
 rts

.up1 lda #upressplate
 rts
}

\* Null screen is black

.GOnull
{
\\ do EditorDisk
\\ lda inmenu
\\ bne getobjbldr
\\ fin

 lda #space
 rts
}

\*-------------------------------
\*
\*  Partial block redraw (as specified by redraw buffers)
\*
\*-------------------------------
.RedBlockFast
{
 lda wipebuf,y ;is wipebuf marked?
 beq skipwipe ;no--skip it
 sec
 sbc #1
 sta wipebuf,y ;decrement wipebuf

 jsr wipesq ;& wipe this block!

 ldy yindex

.skipwipe
 lda redbuf,y
 beq skipred
 sec
 sbc #1
 sta redbuf,y

 jsr setback
 jsr RedBlockSure

 ldy yindex
 bpl skipmove

.skipred
 lda movebuf,y
 beq skipmove
 sec
 sbc #1
 sta movebuf,y

 jsr setback
 jsr drawmc
 jsr drawmb
 jsr drawma

 ldy yindex

.skipmove
 lda floorbuf,y
 beq skipfloor
 sec
 sbc #1
 sta floorbuf,y

 jsr setmid
 jsr drawfloor

 ldy yindex
 bpl skiphalf

.skipfloor
 lda halfbuf,y
 beq skiphalf
 sec
 sbc #1
 sta halfbuf,y

 jsr setmid
 jsr drawhalf

 ldy yindex

.skiphalf
 lda objbuf,y
 beq skipobj

 lda #0
 sta objbuf,y

 jsr drawobjs ;draw all objects in this block

 lda blockxco
 sta XCO

 ldy yindex

.skipobj
 lda fredbuf,y
 beq skipfred
 sec
 sbc #1
 sta fredbuf,y

 jsr drawfrnt

 ldy yindex

.skipfred
.rts rts
}

.add
 jmp addback ;self-mod

.setback
{ lda #LO(addback)
 sta add+1
 lda #HI(addback)
 sta add+2
 rts
}

\*-------------------------------
\*
\*  Partial D-section redraw
\*
\*-------------------------------
.RedDFast
{
 ldy colno
 lda topbuf,y ;is topbuf marked?
 beq skip ;no--skip it
 sec
 sbc #1
 sta topbuf,y

 jsr wiped
 jsr drawc
 jsr drawmc
 jsr drawb
 jsr redrawd ;(both bg and fg)
 jsr drawmd
 jsr drawfrnt
.skip
 rts
}

\*-------------------------------
\*
\*  S H O R T   W I P E
\*
\*  In: Y = buffer index
\*
\*-------------------------------
.wipesq
{
 lda whitebuf,y
.wipe sta height

 lda #4
 sta width

 lda blockxco
 sta XCO

 lda Dy
 sta YCO

 lda #$80
 jmp addwipe
 rts
}

\*-------------------------------
\*
\*  Redraw entire block
\*
\*-------------------------------
.RedBlockSure
{
 jsr drawc ;C-section of piece below & to left
 jsr drawmc

 jsr drawb ;B-section of piece to left
 jsr drawmb

 jsr drawd ;D-section
 jsr drawmd

 jsr drawa ;A-section
 jsr drawma

 jmp drawfrnt ;A-section frontpiece
;(Note: This is necessary in case we do a
;layersave before we get to f.g. plane)
}

\*-------------------------------
\*
\*  D R A W   M O V A B L E   ' B '
\*
\*-------------------------------
.drawmb
{
 lda PRECED

 cmp #gate ;check for special cases
 bne label_1
 jmp drawgateb ;draw B-section of moving gate

.label_1 cmp #spikes
 bne label_2
 jmp drawspikeb

.label_2 cmp #loose
 bne label_3
 jmp drawlooseb

.label_3 cmp #torch
 bne label_4
 jmp drawtorchb
.label_4
.label_5 cmp #exit
 bne label_6
 jmp drawexitb

.label_6
.^drawmb_rts
 rts
}

\*-------------------------------
\*
\*  D R A W  M O V A B L E  ' C '
\*
\*-------------------------------
.drawmc
{
 lda objid ;is there a piece here?
 cmp #space
 beq ok
 cmp #panelwof
 beq ok
 cmp #pillartop
 beq ok

 bne drawmb_rts ;if yes, its A-section will cover up
;the C-section of the piece below
.ok
 ldx colno
 lda BELOW,x ;objid of piece below & to left

 cmp #gate
 bne drawmb_rts

 ;That piece is a gate--
 jmp drawgatec ;special case (movable c)
}

\*-------------------------------
\*
\*  Draw C-section (if visible)
\*
\*-------------------------------
.drawc
{
 jsr checkc
 bcc local_rts
 jsr dodrawc ;OR C-section of piece below & to left
 jmp domaskb ;Mask B-section of piece to left
}

\*-------------------------------
\*
\*  Return cs if C-section is visible, cc if hidden
\*
\*-------------------------------
.checkc
{
 lda objid ;Does this space contain solid floorpiece?
 beq vis
 cmp #pillartop
 beq vis
 cmp #panelwof
 beq vis
 cmp #archtop1
 bcs vis
 bcc rts ;C-section is hidden
.vis sec ;C-section is visible
.local_rts rts
}

\*-------------------------------
\*
\*  Draw C-section of piece below & to left
\*
\*-------------------------------
.dodrawc
{
 ldx colno
 lda BELOW,x ;objid of piece below & to left
 tax
 cpx #block
 beq block
 lda piecec,x
 beq local_rts ;piece has no c-section
 cmp #panelc0
 beq panel ;special panel handling
.cont sta IMAGE
 lda blockxco
 sta XCO
 lda Dy
 sta YCO
 lda #ora
 sta OPACITY
 jmp add

\* Special panel handling

.panel ldx colno
 lda SBELOW,x
 tay
 cpy #numpans ;# of different panels
 bcs local_rts
 lda panelc,y
 bne cont
 rts

.block ldx colno
 lda SBELOW,x
 tay
 cpy #numblox
 bcc label_1
 ldy #0
.label_1 lda blockc,y
 bne cont
.local_rts rts
}

\*-------------------------------
\*
\*  Mask B-section of piece to left
\*
\*-------------------------------
.domaskb
{
 ldx PRECED
 lda maskb,x
 beq label_rts
 sta IMAGE

 lda Dy
 sta YCO
 lda #and
 sta OPACITY
 jmp add
}

\*-------------------------------
\*
\*  Draw B-section of piece to left
\*
\*-------------------------------
.drawb
{
 lda objid
 cmp #block
 beq label_rts ;B-section hidden by solid block

 ldx PRECED
 cpx #space
 beq space
 cpx #floor
 beq floor
 cpx #block
 beq block
 lda pieceb,x
 beq stripe
 cmp #panelb0
 beq panel ;special panel handling

\* draw regular B-section

 jsr cont1

\* Add stripe (palace bg set only)

.stripe
\\ do EditorDisk
\\ lda #EditorDisk
\\ cmp #2
\\ beq :stripe
\\ fin

 lda BGset1
 cmp #1 ;pal
 bne label_rts

.str1 ldx PRECED
 lda bstripe,x
 beq local_rts
 sta IMAGE
 lda Ay
 sec
 sbc #32
 jmp cont2

\* Special panel handling

.panel ldy spreced
 cpy #numpans
 bcs local_rts
 lda panelb,y
 bne cont1
 rts

.block ldy spreced
 cpy #numblox
 bcc label_1
 ldy #0
.label_1 lda blockb,y
 bne cont1

.floor ldy spreced
 cpy #numbpans+1
 bcc label_3
 ldy #0
.label_3 lda floorb,y
 beq rts
 sta IMAGE
 lda floorby,y
 jmp cont

.space ldy spreced
 cpy #numbpans+1
 bcs local_rts
 lda spaceb,y
 beq local_rts
 sta IMAGE
 lda spaceby,y
 jmp cont

\* Draw regular B-section

.cont1 sta IMAGE
 lda pieceby,x
.cont clc
 adc Ay
.cont2 sta YCO
 lda blockxco
 sta XCO
 lda #ora
 sta OPACITY
 jmp add
}

\*-------------------------------
\*
\*  Draw D-section
\*
\*-------------------------------
.redrawd
{
 jsr drawd
 beq local_rts
 jmp addfore
}

.drawd
{
 lda #sta
 sta OPACITY
 ldx objid
 cpx #block
 beq block
 cpx #panelwof ;Do we need to mask this D-section?
 bne cont ;no
.mask lda #ora
 sta OPACITY
.cont lda pieced,x
 beq local_rts
.cont1 sta IMAGE
 lda blockxco
 sta XCO
 lda Dy
 sta YCO
 jsr add
 lda #$ff
.local_rts rts


\* Block handling

.block ldy state
 cpy #numblox
 bcc label_1
 ldy #0
.label_1 lda blockd,y
 bne label_cont1
}

\*-------------------------------
\*
\*  D R A W   ' A '
\*
\*  (1) If piece to left has intrusive B-section (e.g., panel):
\*      MASK A-section
\*  (2) OR A-section
\*
\*-------------------------------
.drawa
{
 lda PRECED
 cmp #archtop1
 beq special
 cmp #panelwif
 beq needmask
 cmp #panelwof
 beq needmask
 cmp #pillartop
 beq needmask
 cmp #block
 bne nomask

.needmask jsr addamask

.nomask jmp adda

.special ldx objid
 cpx #panelwof
 bne nomask
 lda #archpanel ;arch ends to L of panel
 jmp adda1
}

\*-------------------------------
\* EQ.S
\*-------------------------------

; dum redbufs
.redbuf skip 30
.wipebuf skip 30
.movebuf skip 30

; dum tables
;ByteTable ds $100
;OffsetTable ds $100
;BlockTable ds $100
;PixelTable ds $100
.Mult10 skip $10
;Mult7 ds $10
.Mult30 skip $40
;BlockEdge ds 20
;BlockTop ds 5
.BlockBot skip 5
;FloorY ds 5
;BlockAy ds 5

\\ Supposed to be somewhere else!
; dum $3c0
.BELOW skip $10
.SBELOW skip $10

; dum $3f0
.level skip 1


.blueprnt
INCBIN "Levels\LEVEL1"

BLUETYPE = blueprnt
BLUESPEC = BLUETYPE + 24*30
LINKLOC = BLUESPEC +  24*30
LINKMAP = LINKLOC + 256
MAP = LINKMAP + 256
INFO = MAP + 24*4


.end

SAVE "Main", start, end, main


; Construct roms

CLEAR 0, &FFFF
ORG &8000

.bank0_start
.chtab1
INCBIN "Images\IMG.CHTAB1.bin"
.bank0_end

SAVE "Bank0", bank0_start, bank0_end, &8000, &8000
