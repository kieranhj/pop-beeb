; specialk.asm
; Originally SPECIALK.S
; Keyboard handling

.specialk
\EditorDisk = 0
NoCheatKeys = 0 ;removes all cheat keys
DebugKeys = 0
\ tr on
\ lst off
\org = $d900
\*-------------------------------
\*
\*  PRINCE OF PERSIA
\*  Copyright 1989 Jordan Mechner
\*
\*-------------------------------
\ org org

 .keys jmp KEYS
 .clrjstk jmp CLRJSTK
 .zerosound RTS ;jmp ZEROSOUND          BEEB TO DO SOUND
 .addsound RTS  ;jmp ADDSOUND           BEEB TO DO SOUND
 .facejstk jmp FACEJSTK

 .SaveSelect jmp SAVESELECT
 .LoadSelect jmp LOADSELECT
 .SaveDesel jmp SAVEDESEL
 .LoadDesel jmp LOADDESEL
 .initinput jmp INITINPUT

 .demokeys jmp DEMOKEYS
 .listtorches BRK ;jmp LISTTORCHES
 .burn BRK        ;jmp BURN
 .getminleft BRK  ;jmp GETMINLEFT
 .keeptime RTS    ;jmp KEEPTIME         BEEB TO DO

 .shortentime BRK ;jmp SHORTENTIME
 .cuesong RTS     ;jmp CUESONG          BEEB TO DO SOUND
 \jmp DoSaveGame
 \jmp LoadLevelX
 \jmp decstr

 .dloop BRK       ;jmp DLOOP
 .strobe jmp STROBE

\*-------------------------------
\ lst
\ put eq
\ lst
\ put gameeq
\ lst
\ put soundnames
\ lst
\ put movedata
\ lst off

\*-------------------------------
initAMtimer = 10 ;antimatter cheat key timer

\ dum locals
\]temp ds 1
\]count ds 2
\ dend

\POPside1 = $a9
\POPside2 = $ad

\FirstSideB = 3

\*-------------------------------
game_time_min = 725 ;# frames per "minute"
  ;(actual frame rate approx. 11 fps)
game_time_sec = game_time_min/60
game_time_limit = 60 ;game time limit

\*-------------------------------
\*  Key equates
\ Already defined in grafix.sam
\CTRL = $60
\ESC = $9b
\DELETE = $7f
\SHIFT = $20

\*  Player control keys

;kleft = 'j'+&80
;kdown = 'k'+&80
;kright = 'l'+&80
;kupleft = 'u'+&80
;kup = 'i'+&80
;kupright = 'o'+&80

kleft = 'z'+&80
kdown = '/'+&80
kright = 'x'+&80
kupleft = ';'+&80
kup = ':'+&80
kupright = ']'+&80

\*  Special keys (legit)

kfreeze = ESC
krestart = 'r'-CTRL
kabort = 'a'-CTRL
\ksound = 's'-CTRL
\kmusic = 'n'-CTRL
ksetkbd = 'k'-CTRL
ksetjstk = 'j'-CTRL
ksavegame = 'g'-CTRL
kversion = 'v'-CTRL
kreturn = 'm'-CTRL ;editor disk only
kshowtime = ' '
kflipx = 'x'-CTRL
kflipy = 'y'-CTRL

\*  Special keys (development)

knextlevel = ')'
kclean = 'm'-CTRL
kscreendump = '@'
kreload = 'c'-CTRL
kreboot = 'z'-CTRL
kforceredraw = 'f'-CTRL
kblackout = 'B'
kspeedup = ']'
kslowdown = '['
kantimatter = 'q'-CTRL
kupone = 'e'-CTRL
kautoman = 'A'
kincstr = 'S'
kdecstr = 'D'
kincmax = 'F'
kzapgard = 'Z'
kplayback = 'p'-CTRL
kskip5 = '+'
ktimeback = '<'
ktimefwd = '>'
ktimeup = 'M'
kerasegame = '*'

\*-------------------------------
\*
\*  K E Y S
\*
\*  Detect & respond to keypresses
\*
\*-------------------------------
.KEYS
{
 lda SINGSTEP
 beq KEYS1
}
.freeze
{
 lda $C000
 bpl freeze

 cmp #kfreeze
 beq fradv

 ldx #0
 stx SINGSTEP

 lda #0 ;ignore the keypress that breaks ESC
 beq KEYS2

.fradv lda #1
 sta SINGSTEP
 sta $C010
 sta keypress
}
.return_35
 rts

.beeb_strobe EQUB 0

.KEYS1
{
\ NOT BEEB
\lda $C000 ;ASCII value of last keypress
 ;(Hibit is keyboard strobe)

\ BEEB
 LDA #&81
 LDX #0
 LDY #0
 JSR osbyte
\ X=ASCII value if pressed
 BCC key_pressed 

\ No key pressed
 LDA #0
 STA beeb_strobe
 JMP KEYS2

.key_pressed

  TXA
  AND #&7F

  LDY beeb_strobe
  BNE stale_press

  LDY #&80
  STY beeb_strobe

  \ If strobe 0 then fresh press
  ORA #&80
  .stale_press
}
.KEYS2
{
 sta keypress

\ NOT BEEB
\ lda $C010 ;Hibit is any-key-down flag
 ;(Clears keyboard strobe)
 LDA beeb_strobe
 sta keydown

 jsr KREAD ;Keyboard control

 lda keypress
 bpl return_35

 IF DebugKeys

 ldx develment
 beq nogo ;GO codes work only in cheat mode
 cmp #"0"
 bcc :nogo
 cmp #"9"+1
 bcs :nogo

\* We have a keypress 0-9
\* Check if it follows a "GO" key sequence

 lda #LO(C_go0)
 ldx #HI(C_go0)
 jsr checkcode
 bne nogo0
 lda #0 ;1st digit
.golevel clc
 adc keypress
 sec
 sbc #"0" ;2-key value

 cmp #4 ;only levels 4-12 accessible
 bcc return
 cmp #13
 bcs return
 sta NextLevel
 jsr shortentime
.return
 rts

.nogo0 lda #LO(C_go1)
 ldx #HI(C_go1)
 jsr checkcode
 bne nogo
 lda #10
 bne golevel

 ENDIF

\* Normal key handling

.nogo lda keypress
 jsr addkey ;Add key to kbd buffer

 IF NoCheatKeys
 ELSE

\* Set development flag?

 lda #LO(C_devel)
 ldx #HI(C_devel)
 jsr checkcode
 bne label_1
 lda #1
 sta develment
 jmp gtone
.label_1
 ENDIF

\* Skip to next level?

 lda #LO(C_skip)
 ldx #HI(C_skip)
 jsr checkcode
 bne label_2
 lda #3 ;up to level 4
 ldx develment
 beq limit
 lda #11 ;or level 12 in cheat mode
.limit cmp level
 bcc label_2
 inc NextLevel

 jsr shortentime
.label_2

\* Special keys

 jsr LegitKeys

 jsr DevelKeys

 jsr TempDevel

 rts
}

\*-------------------------------
\*
\*  L E G I T   K E Y S
\*
\*-------------------------------

.LegitKeys
{
 lda keypress
 cmp #kfreeze
 bne label_1
 jmp freeze

.label_1 cmp #krestart
 bne label_1a
 jmp goattract ;in topctrl

.label_1a cmp #kabort
 bne label_1b
 jmp restart

.label_1b
 IF EditorDisk
 cmp #kreturn
 bne label_2
 jmp gobuild
 ENDIF

\* Keyboard/joystick

.label_2 cmp #ksetkbd
 bne label_30
 lda #0
 sta joyon
.label_sk1 jmp gtone

.label_30 cmp #ksetjstk
 bne label_31
 jsr setcenter
 jmp label_sk1

.label_31 cmp #kflipx
 bne label_32
 lda jhoriz
 eor #1
 sta jhoriz
 bpl label_sk1

.label_32 cmp #kflipy
 bne label_3
 lda jvert
 eor #1
 sta jvert
 bpl label_sk1

\* Sound on/off

.label_3 cmp #ksound
 bne label_16
.togsound
 jsr zerosound
 lda soundon
 eor #1
 sta soundon
 bne label_sk1
 rts

.label_16 cmp #kmusic
 bne label_26
 lda musicon
 eor #1
 sta musicon
 bne label_sk1
 rts

.label_26 cmp #kversion
 bne label_17
 jmp dispversion ;display version #

\* Save/load game

.label_17 cmp #ksavegame
 bne label_18
\ BEEB TEMP SAVE GAMEs
\ lda level
\ sta SavLevel
\ jmp DoSaveGame

\* Show time left

.label_18 cmp #kshowtime
 bne label_19
 lda #3
 sta timerequest
 rts

.label_19
.return
 rts
}

\*-------------------------------
\*
\*  D E V E L O P M E N T - O N L Y   K E Y S
\*
\*-------------------------------

.DevelKeys
{
 lda develment ;development flag
 beq return

 jsr checkcodes ;secret codes

 lda keypress
 cmp #kclean
 bne label_1
 lda #0
 sta develment
 rts
.label_1
.return
 rts
}

\*-------------------------------
\* Temp development keys
\* (remove for final version)
\*-------------------------------

.TempDevel
{
 IF DebugKeys

 lda develment ;development flag
 beq ]rts

 lda keypress
 cmp #kforceredraw
 bne :10
 lda #2
 sta redrawflg
 lda #0
 sta blackflag
 rts

:10 cmp #kblackout
 bne :9
 lda blackflag
 eor #$ff
 sta blackflag
]rts rts

:9 cmp #kantimatter
 bne :17
 lda #initAMtimer
 sta AMtimer
 rts

:17 cmp #kincstr
 bne :20
 inc ChgKidStr
 inc ChgOppStr
 rts

:20 cmp #kincmax
 bne :36
 jmp boostmeter

:36 cmp #knextlevel
 bne :28
 inc NextLevel
 rts

:28 cmp #kskip5
 bne :30
 lda level
 clc
 adc #5
 sta NextLevel
 rts
:30

* keys 0-9

 lda keypress
 cmp #"0"
 bcc :non
 cmp #"9"+1
 bcs :non
 sec
 sbc #"0"
 sta guardprog
]sk1 jmp gtone

* non-numeric keys

:non cmp #kreload
 bne :8
 jsr preload
 lda #2
 sta redrawflg
 jsr reload
 jmp postload

* speed up/slow down delay loop

:8 cmp #kspeedup
 bne :13
 lda SPEED
 cmp #5
 bcc :12
 sec
 sbc #4
 sta SPEED
 jmp ]sk1
:12 lda #1 ;fastest
 sta SPEED
]rts rts

:13 cmp #kslowdown
 bne :14
 jsr gtone
 lda SPEED
 clc
 adc #4
 sta SPEED
 rts

* Screen dump

:14 cmp #kscreendump
 bne :15
 lda PAGE
 jmp screendump

:15 cmp #kupone
 bne :19
 lda KidY
 sec
 sbc #63 ;BlockHeight
 sta KidY
 dec KidBlockY
 rts

:19 cmp #kdecstr
 bne :21
 dec ChgKidStr
]rts rts

:21 cmp #kautoman
 bne :23
 lda ManCtrl
 eor #$ff
 sta ManCtrl
 rts

* Change levels

:23
 cmp #kplayback
 bne :24
 lda #1
 sta level
 lda #2
 sta NextLevel
 rts

:24 cmp #ktimeback
 bne :31
 lda #-2
:chgtime clc
 adc FrameCount+1
 sta FrameCount+1
 rts

:31 cmp #ktimefwd
 bne :32
 lda #2
 bne :chgtime

:32 cmp #kerasegame
 bne :33
 lda #$ff
 sta SavLevel
 jmp DoSaveGame

:33 cmp #ktimeup
 bne :34
 lda #$ff
 sta FrameCount+1
 rts

:34
 ENDIF
.return
 rts
}

IF _TODO
*-------------------------------
* Temporarily change BBundID to reload code & data from side 1

postload
]sm lda #$a9
 sta BBundID
 rts

preload
 lda BBundID
 sta ]sm+1
 lda #POPside1
 sta BBundID
 rts
ENDIF

\*-------------------------------
\*
\* A D D K E Y
\*
\* In: A = key value
\*
\*-------------------------------

.addkey
{
 ldx keybufptr ;index to last key entry
 inx
 cpx #keybuflen
 bcc ok
 ldx #0 ;wrap around
.ok stx keybufptr

 sta keybuf,x
.return
 rts
}

\*-------------------------------
\*
\*  C H E C K   C O D E S
\*
\*  Only work in devel mode
\*
\*-------------------------------
.checkcodes
{
 IF NoCheatKeys
 rts
 ELSE

 lda #LO(C_boost)
 ldx #HI(C_boost)
 jsr checkcode
 bne label_1
 jsr boostmeter
 lda MaxKidStr
 sta origstrength
 rts

.label_1 lda #LO(C_restore)
 ldx #HI(C_restore)
 jsr checkcode
 bne label_2
 jmp rechargemeter

.label_2 lda #LO(C_zap2)
 ldx #HI(C_zap2)
 jsr checkcode
 bne label_3
;zap guard down to 0
 lda #0
 sec
 sbc OppStrength
 sta ChgOppStr
 rts

.label_3 lda #LO(C_zap1)
 ldx #HI(C_zap1)
 jsr checkcode
 bne label_4
 ;zap guard down to 1
 lda #1
 sec
 sbc OppStrength
 sta ChgOppStr
 rts

.label_4 lda #LO(C_tina)
 ldx #HI(C_tina)
 jsr checkcode
 bmi label_5
 lda #14
 sta NextLevel
 jsr shortentime
 rts
.label_5
.return
 rts
 ENDIF
}

\*-------------------------------
\*
\* Compare keybuf sequence against code sequence
\*
\* In: A-X = code sequence address lo-hi
\* Return A = 0 if it matches, else ff
\*
\*-------------------------------

.checkcode
{
 sta smod+1
 stx smod+2

 ldx keybufptr ;last key entry
 ldy #0 ;last char of code seq
.loop
.smod lda $ffff,y ;smod
 beq return ;0 = code seq delimiter
 cmp keybuf,x
 beq match
 cmp #'A' ;alpha?
 bcc fail
 cmp #'Z'+1
 bcs fail
 ora #$20 ;yes--try LC too
 cmp keybuf,x
 bne fail

.match iny
 dex
 bpl loop
 ldx #keybuflen-1 ;wrap around
 bpl loop

.fail lda #$ff
.return
 rts
}

\*-------------------------------
\*
\* Key sequence codes
\*
\* Use all caps; LC will be accepted too
\*
\*-------------------------------
.C_skip EQUS "SKIP", 0

 IF NoCheatKeys
 ELSE

.C_devel EQUS "POP", 0
.C_go0 EQUS "GO0", 0
.C_go1 EQUS "GO1", 0
.C_zap2 EQUS "ZAP", 0
.C_boost EQUS "BOOST", 0
.C_restore EQUS "R", 0
.C_zap1 EQUS "Z", 0
.C_tina EQUS "TINA", 0

 ENDIF

\*-------------------------------
\*
\*  K R E A D
\*
\*  Keyboard player control
\*
\*  (Register a keypress for as long as key is held down)
\*
\*  Out: kbdX, kbdY
\*
\*-------------------------------

.KREAD
{
 lda #0
 sta kbdX
 sta kbdY

 lda keypress
 bmi cont ;fresh press

 ldx keydown
 bpl return ;No fresh press & no key down

 ora #$80 ;stale press, key still down
.cont
 cmp #kleft
 beq local_left
 cmp #kleft-SHIFT
 bne label_1

.local_left lda #LO(-1)
.local_setx sta kbdX
 rts

.label_1 cmp #kright
 beq local_right
 cmp #kright-SHIFT
 bne label_2

.local_right lda #1
 bne local_setx

.label_2 cmp #kup
 beq local_up
 cmp #kup-SHIFT
 bne label_3

.local_up lda #LO(-1)
.local_sety sta kbdY
 rts

.label_3 cmp #kdown
 beq local_down
 cmp #kdown-SHIFT
 bne label_4

.local_down lda #1
 bne local_sety

.label_4 cmp #kupleft
 beq local_ul
 cmp #kupleft-SHIFT
 bne label_5

.local_ul lda #LO(-1)
 sta kbdX
 bne local_sety

.label_5 cmp #kupright
 beq local_ur
 cmp #kupright-SHIFT
 bne label_6

.local_ur lda #1
 sta kbdX
 lda #LO(-1)
 sta kbdY
 bne local_sety
.label_6

.return
 rts
}

\*-------------------------------
.FACEJSTK
{
 lda #0
 sec
 sbc JSTKX
 sta JSTKX ;reverse jstk x

 ldx clrF
 lda clrB
 sta clrF
 stx clrB ;& switch clrF/clrB

.return
 rts
}

\*-------------------------------
\*
\*  Note: Jstk-push flags are saved as if back = R, fwd = L
\*  (i.e., char is facing L)
\*
\*-------------------------------

.SAVESELECT
{
 ldx #4
.loop lda clrF,x
 sta clrSEL,x
 dex
 bpl loop
 rts
}

\*-------------------------------

.LOADSELECT
{
 ldx #4
.loop lda clrSEL,x
 sta clrF,x
 dex
 bpl loop
 rts
}

\*-------------------------------

.SAVEDESEL
{
 ldx #4
.loop lda clrF,x
 sta clrDESEL,x
 dex
 bpl loop
 rts
}

\*-------------------------------

.LOADDESEL
{
 ldx #4
.loop lda clrDESEL,x
 sta clrF,x
 dex
 bpl loop
 rts
}

\*-------------------------------

.INITINPUT
{
 lda #0

 ldx #4
.loop sta clrDESEL,x
 sta clrSEL,x
 dex
 bpl loop
.return
 rts
}

\*-------------------------------
\*
\*  C L E A R   J O Y S T I C K
\*
\*  In/out: JSTKX, JSTKY, btn
\*          clrF-B-U-D-btn
\*
\*  clr = 0: no press
\*  clr = 1: used press
\*  clr = -1: unused press
\*
\*  Assume char is facing L
\*
\*-------------------------------
\*
\*  Input consists of 5 "buttons": forward, back, up, down,
\*  and the real button.  Each button has its own "clr" flag:
\*  clrF,B,U,D & btn.
\*
\*  When ClrJstk sees a button down:
\*    If clr = 1 or -1... leave it alone
\*    If clr = 0... set clr = -1
\*
\*  When ClrJstk sees a button up:
\*    If clr = 0 or -1... leave it alone
\*    If clr = 1... set clr = 0
\*
\*  When GenCtrl acts on a button press, it sets clr = 1.
\*
\*-------------------------------

.CLRJSTK
{
 lda clrF
 bmi label_1 ;leave it set at -1

 ldx JSTKX ;jstk fwd?
 bmi yesF ;yes--if clr = 0, set clr = -1
;no--set clr = 0
 lda #0
 beq staF

.yesF cmp #0
 bne label_1

 lda #LO(-1)
.staF sta clrF

\*-------------------------------
.label_1 lda clrB
 bmi label_2

 ldx JSTKX
 cpx #1
 beq yesB

 lda #0
 beq staB

.yesB cmp #0
 bne label_2

 lda #LO(-1)
.staB sta clrB

\*-------------------------------
.label_2 lda clrU
 bmi label_3

 ldx JSTKY
 bmi yesU

 lda #0
 beq staU

.yesU cmp #0
 bne label_3

 lda #LO(-1)
.staU sta clrU

\*-------------------------------
.label_3 lda clrD
 bmi label_4

 ldx JSTKY
 cpx #1
 beq yesD

 lda #0
 beq staD

.yesD cmp #0
 bne label_4

 lda #LO(-1)
.staD sta clrD

\*-------------------------------
.label_4 lda clrbtn
 bmi label_5

 ldx btn
 bmi yesbtn

 lda #0
 beq stabtn

.yesbtn cmp #0
 bne label_5

 lda #LO(-1)
.stabtn sta clrbtn

.label_5
.return
 rts
}

IF _TODO
*-------------------------------
*
*  Z E R O S O U N D
*
*  Zero sound table
*
*-------------------------------
ZEROSOUND
 lda #0 ;# sounds in table
 sta soundtable
 rts

*-------------------------------
*
*  A D D S O U N D
*
*  Add sound to sound table
*  (preserve registers)
*
*  In: A = sound #
*
*-------------------------------
]temp1 ds 1

ADDSOUND
 stx ]temp1

 ldx soundtable
 cpx #maxsfx
 bcs :rts ;sound table full

 inx
 sta soundtable,x
 stx soundtable ;# sounds in table

:rts ldx ]temp1
 rts
ENDIF

\*-------------------------------
\*
\*  Demo keys (Call immediately after regular KEYS routine)
\*
\*  All keys interrupt demo except ESC and CTRL-S
\*
\*  Out: FF if interrupt, else 00
\*
\*-------------------------------

.DEMOKEYS
{
 lda level
 bne cont ;not in demo

\ BEEB
 LDA BTN0
 ORA BTN1
\ lda $c061
\ ora $c062 ;button?
 bmi interrupt
 lda keypress
 bpl cont
 cmp #ESC
 beq cont
 cmp #ksound
 beq cont
.interrupt
 lda #$ff
 rts
.cont lda #0
 rts
}

IF _TODO
*-------------------------------
*
* Special routine for use by BURN
*
* Make a list of visible torches--don't disturb trans list
*
*-------------------------------
maxtorches = 8

torchx ds maxtorches+1
torchy ds maxtorches+1
torchstate ds maxtorches+1
torchclip ds maxtorches+1

]numtorches = locals

torchcount ds 1

LISTTORCHES
 lda #0
 sta ]numtorches

 lda VisScrn
 jsr calcblue

 ldy #29

:loop jsr :sub

 ldx ]numtorches
 cpx #maxtorches
 bcs :max

 dey
 bpl :loop

 ldx ]numtorches
:max lda #$ff
 sta torchx,x
 sta torchcount ;start BURNing with torch #0
]rts rts

:sub lda (BlueType),y
 and #idmask
 cmp #torch
 bne ]rts
 lda fredbuf+1,y
 sta BOTCUT ;temp

 tya
 pha
 jsr unindex
;Out: A = tempblockx, X = tempblocky
 pha
 txa
 ldx ]numtorches
 tay
 lda BlockBot+1,y
 sec
 sbc #3
 sta torchy,x
 lda BOTCUT ;0 or non0
 sta torchclip,x
 pla
 clc
 adc #1
 cmp #10
 bcs ]rts
 asl
 asl
 sta torchx,x

 pla
 tay
 lda (BlueSpec),y
 sta torchstate,x

 inc ]numtorches
]rts rts

*-------------------------------
*
* B U R N
*
* Animate torch flames (for use while music is playing)
*
* NOTE--this routine bypasses normal graphics system
* and draws directly on the displayed page
* Leaves trans list, redraw buffers, etc. undisturbed
*
*-------------------------------
BURN
 lda torchx
 bmi ]rts ;no torches on this screen

 ldx torchcount ;last torch burned
 inx
 lda torchx,x
 bpl :ok ;torchx = $ff means "end of torch list"
 ldx #0 ;start again at beginning of list
:ok stx torchcount
 lda torchx,x
 sta XCO
 lda torchy,x
 sta YCO
 lda torchclip,x
 sta BOTCUT
 lda torchstate,x
 jsr getflameframe
 sta torchstate,x
 tax
 jsr setupflame
 lda BOTCUT
 bne :partial
:whole jmp fastlay  ;<---DIRECT HIRES CALL
]rts rts

* If bottom portion of flame would overlap with someone's
* head, clip it (use LAY)

:partial
 jsr initlay
 lda #0
 sta OFFSET
 lda YCO
 sec
 sbc #4
 sta BOTCUT
 jmp lay ;<---DIRECT HIRES CALL

*-------------------------------
*
* Get # of minutes (or seconds) left
*
* In: FrameCount (0-65535)
* Out: MinLeft (BCD byte: $00-99) = # of minutes left
*      SecLeft = # of seconds left (during final minute)
*
*-------------------------------
GETMINLEFT
 lda #0
 sta ]count
 sta ]count+1

 lda #min
 sta :sm1+1
 lda #>min
 sta :sm2+1
 jsr :sub ;get MinLeft
 sty MinLeft
 cpy #2
 bcs ]rts

* Final minute only: count seconds

 lda #59*min
 sta ]count
 lda #>59*min
 sta ]count+1

 lda #sec
 sta :sm1+1
 lda #>sec
 sta :sm2+1
 jsr :sub ;get SecLeft
 sty SecLeft
 rts

* Sub returns min/sec left

:sub ldy #$61 ;counter

:loop lda ]count+1
 cmp FrameCount+1
 bcc :1
 bne ]rts
 lda ]count
 cmp FrameCount
 bcs ]rts
:1
 lda ]count
 clc
:sm1 adc #min
 sta ]count
 lda ]count+1
:sm2 adc #>min
 sta ]count+1

 sed
 tya
 sec
 sbc #1
 cld
 tay
 bpl :loop
 ldy #0
]rts rts

*-------------------------------
timetable
:0 dw t-60*min
 dw t-55*min
 dw t-50*min
 dw t-45*min
 dw t-40*min
 dw t-35*min
 dw t-30*min
 dw t-25*min
 dw t-20*min
 dw t-15*min
:20 dw t-10*min
 dw t-5*min
 dw t-4*min
 dw t-3*min
 dw t-2*min
 dw t-1*min+1
 dw t*min+5 ;5 frames after t=0: game over
 dw 65535

nummsg = *-timetable

*-------------------------------
*
* Keep track of time remaining
*
*-------------------------------
]rts rts
KEEPTIME
; lda autopilot
; bne ]rts
 lda level
 beq ]rts ;not in demo or during playback

 lda KidLife
 bpl ]rts ;clock stops when kid is dead

* Inc frame counter

 inc FrameCount
 bne :1
 inc FrameCount+1
:1 bne :2
 lda #$ff
 sta FrameCount
 sta FrameCount+1 ;don't wrap around

* time for next message yet?

:2 ldy NextTimeMsg ;0-2-4 for 1st, 2nd, 3rd msgs
 cpy #nummsg
 bcs ]rts ;no more msgs
 lda FrameCount+1
 cmp timetable+1,y
 bcc ]rts ;not yet
 lda FrameCount
 cmp timetable,y
 bcc ]rts

* Yes--is this a convenient time to show msg?

 lda msgtimer
 bne ]rts ;wait till other msgs are gone

* Yes--show msg (& inc NextTimeMsg)

 inc NextTimeMsg
 inc NextTimeMsg

 lda #2
 sta timerequest
]rts rts

*-------------------------------
*
* Shorten remaining time to 15 minutes
* (e.g., 1st time player cheats by skipping a level)
*
*-------------------------------
SHORTENTIME
 ldy NextTimeMsg
 cpy #20
 bcs ]rts ;time is already short enough
 ldy #18
 sty NextTimeMsg
 lda timetable,y
 sta FrameCount
 lda timetable+1,y
 sta FrameCount+1
]rts rts

*-------------------------------
*
* Cue song
*
* In: A = song #
*     X = # of cycles within which song must be played
*
*-------------------------------
CUESONG
 sta SongCue
 stx SongCount
 rts
ENDIF

\*-------------------------------
\*
\*  Strobe keyboard
\*
\*-------------------------------
.DLOOP
.STROBE
{
 jsr keys ;Detect & respond to keypresses
 jsr controller
 rts
}

\*-------------------------------
\ lst
\eof ds 1
\  usr $a9,19,$b00,*-org
\ lst off
