; specialk.asm
; Originally SPECIALK.S
; Keyboard handling

.specialk
\EditorDisk = 0
NoCheatKeys = 1 ;removes all cheat keys
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

 IF _JMP_TABLE=FALSE
.keys jmp KEYS
.clrjstk jmp CLRJSTK
.zerosound RTS ;jmp ZEROSOUND          BEEB TODO SOUND
.addsound RTS  ;jmp ADDSOUND           BEEB TODO SOUND
.facejstk jmp FACEJSTK

.SaveSelect jmp SAVESELECT
.LoadSelect jmp LOADSELECT
.SaveDesel jmp SAVEDESEL
.LoadDesel jmp LOADDESEL
.initinput jmp INITINPUT

.demokeys jmp DEMOKEYS
.listtorches BRK ;jmp LISTTORCHES
.burn BRK        ;jmp BURN
.getminleft jmp GETMINLEFT
.keeptime jmp KEEPTIME

.shortentime BRK ;jmp SHORTENTIME
.cuesong RTS     ;jmp CUESONG          BEEB TODO MUSIC
\jmp DoSaveGame
\jmp LoadLevelX
\jmp decstr

.dloop BRK       ;jmp DLOOP
.strobe jmp STROBE
.controller jmp CONTROLLER
.setcenter RTS  ;jmp SETCENTER      BEEB TODO JOYSTICK
.pread BRK      ;jmp PREAD          JOYSTICK

.getselect jmp GETSELECT
.getdesel jmp GETDESEL
.musickeys jmp MUSICKEYS
ENDIF

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
\ Now defined in specialk.h.asm

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

\*  Player control keys (default)

kleft = IKN_z
kdown = IKN_slash
kright = IKN_x
kupleft = IKN_semi
kup = IKN_colon
kupright = IKN_rsb
kbutton = IKN_return

\*  Special keys (legit) - all require CTRL

kfreeze = IKN_p OR &80
krestart = IKN_r OR &80
kabort = IKN_a OR &80
\ksound = IKN_s OR &80    ; already defined
\kmusic = IKN_m OR &80
ksetkbd = IKN_k OR &80
ksavegame = IKN_g OR &80
kversion = IKN_v OR &80
;kreturn = IKN_e  OR &80;editor disk only
kshowtime = IKN_space OR &80

\\ NOT BEEB supported
;ksetjstk = IKN_j OR &80
;kflipx = IKN_x OR &80
;kflipy = IKN_y OR &80

\*  Special keys (development)
\* BEEB all required CTRL

knextlevel = IKN_n OR &80
;kclean = 'm'-CTRL
;kscreendump = '@'
;kreload = 'c'-CTRL
;kreboot = 'z'-CTRL
kforceredraw = IKN_f OR &80
kblackout = IKN_b OR &80
;kspeedup = ']'
;kslowdown = '['
kantimatter = IKN_q OR &80
kupone = IKN_e OR &80
;kautoman = 'A'
kincstr = IKN_s OR &80
kdecstr = IKN_d OR &80
kincmax = IKN_w OR &80
kzapgard = IKN_z OR &80
;kplayback = 'p'-CTRL
kskip5 = IKN_5 OR &80
ktimeback = IKN_1 OR &80
ktimefwd = IKN_2 OR &80
ktimeup = IKN_0 OR &80
kerasegame = IKN_9 OR &80

\*-------------------------------
; BEEB allow keys to be redefined
\*-------------------------------

.beeb_keydef_left EQUB kleft EOR &80
.beeb_keydef_right EQUB kright EOR &80
.beeb_keydef_up EQUB kup EOR &80
.beeb_keydef_down EQUB kdown EOR &80
.beeb_keydef_jumpleft EQUB kupleft EOR &80
.beeb_keydef_jumpright EQUB kupright EOR &80
.beeb_keydef_action EQUB kbutton EOR &80

\*-------------------------------
; BEEB support for multiple keypresses
\*-------------------------------

.beeb_keypress_left EQUB 0
.beeb_keypress_right EQUB 0
.beeb_keypress_up EQUB 0
.beeb_keypress_down EQUB 0
.beeb_keypress_jumpleft EQUB 0
.beeb_keypress_jumpright EQUB 0


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
; lda $C000
; bpl freeze

.wait_for_no_keys
 LDA #&79
 LDX #0
 JSR osbyte

 CPX #&FF
 BNE wait_for_no_keys

.wait_for_key
 LDA #&79
 LDX #0
 JSR osbyte
 CPX #&FF
 BEQ wait_for_key
 TXA
 ORA #&80

 cmp #kfreeze
 beq fradv

 ldx #0
 stx SINGSTEP

 lda #0 ;ignore the keypress that breaks ESC
 beq KEYS2

.fradv lda #1
 sta SINGSTEP
; sta $C010
 sta keypress
}
.return_35
 rts

.KEYS1
{
\ NOT BEEB
\lda $C000 ;ASCII value of last keypress
 ;(Hibit is keyboard strobe)

\ Check CTRL
 LDA #&79
 LDX #IKN_ctrl EOR &80
 JSR osbyte

 TXA
 AND #&80
 STA beeb_keypress_ctrl

\ Scan all main control keys

 LDA #&79
 LDX beeb_keydef_left
 JSR osbyte
 STX beeb_keypress_left

 LDA #&79
 LDX beeb_keydef_right
 JSR osbyte
 STX beeb_keypress_right
  
 LDA #&79
 LDX beeb_keydef_up
 JSR osbyte
 STX beeb_keypress_up

 LDA #&79
 LDX beeb_keydef_down
 JSR osbyte
 STX beeb_keypress_down

 LDA #&79
 LDX beeb_keydef_jumpleft
 JSR osbyte
 STX beeb_keypress_jumpleft

 LDA #&79
 LDX beeb_keydef_jumpright
 JSR osbyte
 STX beeb_keypress_jumpright

\ Scan all keys
 LDA #&79
 LDX #0
 JSR osbyte

 CPX #&FF
 BNE key_pressed 

\ No key pressed
 LDA #0
 STA keydown
 JMP KEYS2

.key_pressed

  TXA
  AND #&7F

  LDY keydown
  BNE stale_press

  LDY #&80
  STY keydown

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
\ sta keydown

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

\ BEEB doesn't suport keybuf codes
\.nogo lda keypress
\ jsr addkey ;Add key to kbd buffer

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
 ENDIF

\* Special keys

 jsr LegitKeys

\ NOT BEEB
\ jsr DevelKeys

IF _DEBUG
 jsr TempDevel
ENDIF
}
.return_51
 rts

\*-------------------------------
\*
\*  L E G I T   K E Y S
\*
\*-------------------------------

.LegitKeys
{
\* Show time left

 lda keypress
 cmp #kshowtime
 bne ctrl_keys
 lda #3
 sta timerequest
 rts

.ctrl_keys

\ BEEB must hold down CTRL
 LDA beeb_keypress_ctrl
 BEQ return_51

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
 bne label_3
 lda #0
 sta joyon

 JSR redefine_keys

.label_sk1 jmp gtone

IF _NOT_BEEB
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
ENDIF

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
 lda level
 sta SavLevel
 ;jmp DoSaveGame
 RTS  ; request save game in MainLoop

\* Show time left

.label_18
\ BEEB no CTRL so moved up
\ cmp #kshowtime
\ bne label_19
\ lda #3
\ sta timerequest
\ rts

.label_19
\ cmp #knext \\ BEEB TEMP
\ bne label_20
\ inc NextLevel
\ bne label_sk1

.label_20

.return
 rts
}

\*-------------------------------
\*
\*  D E V E L O P M E N T - O N L Y   K E Y S
\*
\*-------------------------------

IF _NOT_BEEB
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
ENDIF

\*-------------------------------
\* Temp development keys
\* (remove for final version)
\*-------------------------------

IF _DEBUG
.TempDevel
{
\ BEEB must hold down CTRL
 LDA beeb_keypress_ctrl
 BEQ return

 lda keypress
 cmp #kforceredraw
 bne label_10
 lda #2
 sta redrawflg
 lda #0
 sta blackflag
.return
 rts

.label_10 cmp #kblackout
 bne label_9
 lda blackflag
 eor #$ff
 sta blackflag
 rts

.label_9 cmp #kantimatter
 bne label_17
 lda #initAMtimer
 sta AMtimer
 rts

.label_17 cmp #kincstr
 bne label_20
 inc ChgKidStr
 inc ChgOppStr
 rts

.label_20 cmp #kincmax
 bne label_36
 jmp boostmeter

.label_36 cmp #knextlevel
 bne label_28
 inc NextLevel
 rts

.label_28 cmp #kskip5
 bne label_30
 lda level
 clc
 adc #5
 sta NextLevel
 rts
.label_30

IF _NOT_BEEB
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
ENDIF

.label_15 cmp #kupone
 bne label_19
 lda KidY
 sec
 sbc #63 ;BlockHeight
 sta KidY
 dec KidBlockY
 rts

.label_19 cmp #kdecstr
 bne label_24
 dec ChgKidStr
 rts

IF _NOT_BEEB
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
ENDIF

.label_24 cmp #ktimeback
 bne label_31
 lda #LO(-2)
.chgtime clc
 adc FrameCount+1
 sta FrameCount+1
 rts

.label_31 cmp #ktimefwd
 bne label_32
 lda #2
 bne chgtime

.label_32 cmp #kerasegame
 bne label_33
 lda #$ff
 sta SavLevel
; jmp DoSaveGame
 RTS  ; request save game in MainLoop

.label_33 cmp #ktimeup
 bne label_34
 lda #$ff
 sta FrameCount+1
 rts

.label_34 cmp #kzapgard
 bne label_35
;zap guard down to 0
 lda #0
 sec
 sbc OppStrength
 sta ChgOppStr

.label_35
 rts
}
ENDIF

IF _NOT_BEEB
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
ENDIF

\*-------------------------------
\*
\*  C H E C K   C O D E S
\*
\*  Only work in devel mode
\*
\*-------------------------------

 IF NoCheatKeys=FALSE
.checkcodes
{
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
}
ENDIF

\*-------------------------------
\*
\* Compare keybuf sequence against code sequence
\*
\* In: A-X = code sequence address lo-hi
\* Return A = 0 if it matches, else ff
\*
\*-------------------------------

IF _NOT_BEEB
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

.cont
 LDA beeb_keypress_left
 BPL label_1

.local_left lda #LO(-1)
.local_setx sta kbdX
; also check up
 bne label_2
; rts

.label_1
 LDA beeb_keypress_right
 BPL label_2

.local_right lda #1
 bne local_setx

.label_2
 LDA beeb_keypress_up
 BPL label_3

.local_up lda #LO(-1)
.local_sety sta kbdY
 rts

.label_3
 LDA beeb_keypress_down
 BPL label_4

.local_down lda #1
 bne local_sety

.label_4
 LDA beeb_keypress_jumpleft
 BPL label_5

.local_ul lda #LO(-1)
 sta kbdX
 bne local_sety

.label_5
 LDA beeb_keypress_jumpright
 BPL label_6

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
ENDIF

\*-------------------------------
\*
\* Get # of minutes (or seconds) left
\*
\* In: FrameCount (0-65535)
\* Out: MinLeft (BCD byte: $00-99) = # of minutes left
\*      SecLeft = # of seconds left (during final minute)
\*
\*-------------------------------

.GETMINLEFT
{
 lda #0
 sta specialk_count
 sta specialk_count+1

 lda #LO(game_time_min)
 sta sm1+1
 lda #HI(game_time_min)
 sta sm2+1
 jsr local_sub ;get MinLeft
 sty MinLeft
 cpy #2
 bcs return

\* Final minute only: count seconds

 lda #LO(59*game_time_min)
 sta specialk_count
 lda #HI(59*game_time_min)
 sta specialk_count+1

 lda #LO(game_time_sec)
 sta sm1+1
 lda #HI(game_time_sec)
 sta sm2+1
 jsr local_sub ;get SecLeft
 sty SecLeft
 rts

\* Sub returns min/sec left

.local_sub ldy #$61 ;counter

.loop lda specialk_count+1
 cmp FrameCount+1
 bcc label_1
 bne return
 lda specialk_count
 cmp FrameCount
 bcs return
.label_1
 lda specialk_count
 clc
.sm1 adc #LO(game_time_min)
 sta specialk_count
 lda specialk_count+1
.sm2 adc #HI(game_time_min)
 sta specialk_count+1

 sed
 tya
 sec
 sbc #1
 cld
 tay
 bpl loop
 ldy #0
.return
 rts
}

\*-------------------------------
.timetable
.timetable_0
 EQUW (game_time_limit-60)*game_time_min
 EQUW (game_time_limit-55)*game_time_min
 EQUW (game_time_limit-50)*game_time_min
 EQUW (game_time_limit-45)*game_time_min
 EQUW (game_time_limit-40)*game_time_min
 EQUW (game_time_limit-35)*game_time_min
 EQUW (game_time_limit-30)*game_time_min
 EQUW (game_time_limit-25)*game_time_min
 EQUW (game_time_limit-20)*game_time_min
 EQUW (game_time_limit-15)*game_time_min
.timetable_20
 EQUW (game_time_limit-10)*game_time_min
 EQUW (game_time_limit-5)*game_time_min
 EQUW (game_time_limit-4)*game_time_min
 EQUW (game_time_limit-3)*game_time_min
 EQUW (game_time_limit-2)*game_time_min
 EQUW (game_time_limit-1)*game_time_min+1
 EQUW (game_time_limit*game_time_min)+5 ;5 frames after t=0: game over
 EQUW 65535

nummsg = P%-timetable

\*-------------------------------
\*
\* Keep track of time remaining
\*
\*-------------------------------

.KEEPTIME
{
; lda autopilot
; bne ]rts
 lda level
 beq return ;not in demo or during playback

 lda KidLife
 bpl return ;clock stops when kid is dead

\* Inc frame counter

\\ BEEB TODO - use vsync counter to make this more accurate

 inc FrameCount
 bne label_1
 inc FrameCount+1
.label_1 bne label_2
 lda #$ff
 sta FrameCount
 sta FrameCount+1 ;don't wrap around

\* time for next message yet?

.label_2 ldy NextTimeMsg ;0-2-4 for 1st, 2nd, 3rd msgs
 cpy #nummsg
 bcs return ;no more msgs
 lda FrameCount+1
 cmp timetable+1,y
 bcc return ;not yet
 lda FrameCount
 cmp timetable,y
 bcc return

\* Yes--is this a convenient time to show msg?

 lda msgtimer
 bne return ;wait till other msgs are gone

\* Yes--show msg (& inc NextTimeMsg)

 inc NextTimeMsg
 inc NextTimeMsg

 lda #2
 sta timerequest
.return
 rts
}

IF _TODO
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

\*-------------------------------
\*
\*  Joystick/keyboard routines MOVED FROM GRAFIX.ASM
\*
\*-------------------------------
\*
\*  Get input from selected/deselected device
\*
\*  In: kbdX, kbdY, joyX, joyY, BTN0, BTN1, ManCtrl
\*
\*  Out: JSTKX, JSTKY, btn
\*
\*-------------------------------
.GETSELECT
 lda joyon ;joystick selected?
 bne getjoy ;yes--use jstk
 beq getkbd ;no--use kbd

.GETDESEL
 lda joyon
 bne getkbd
 beq getjoy

.getjoy
{
 lda joyX
 sta JSTKX
 lda joyY
 sta JSTKY

 lda BTN1
 ldx ManCtrl ;When manual ctrl is on, btn 0 belongs
 bmi label_1 ;to kbd and btn 1 to jstk.  With manual ctrl
 ora BTN0 ;off, btns can be used interchangeably.
.label_1 sta btn
 rts
}

.getkbd
{
 lda kbdX
 sta JSTKX
 lda kbdY
 sta JSTKY

 lda BTN0
 ldx ManCtrl
 bmi label_1
 ora BTN1
.label_1 sta btn
.return
 rts
}

\*-------------------------------
\*
\*  Read controller (jstk & buttons)
\*
\*  Out: joyX-Y, BTN0-1
\*
\*-------------------------------

.CONTROLLER
{
\ BEEB TEMP comment out JOYSTICK
\ jsr JREAD ;read jstk

 jmp BREAD ;& btns
}

\*-------------------------------
\*
\*  Read joystick
\*
\*  Out: joyX-Y
\*
\*  joyX: -1 = left, 0 = center, +1 = right
\*  joyY: -1 = up, 0 = center, +1 = down
\*
\*-------------------------------

IF  _TODO
.JREAD
{
 lda joyon
 beq return
 jsr PREAD ;read game pots

 ldx #0
 jsr cvtpdl
 inx
 jsr cvtpdl

\* Reverse joyY?

 lda jvert
 beq label_1

 lda #0
 sec
 sbc joyY
 sta joyY

\* Reverse joyX?

.label_1 lda jhoriz
 beq return

 lda #0
 sec
 sbc joyX
 sta joyX
.return
 rts
}
ENDIF

\*-------------------------------
\*
\*  Read buttons
\*
\*  Out: BTN0-1
\*
\*-------------------------------

.BREAD
{
\ lda jbtns
\ bne label_1 ;buttons switched

\ lda $c061
\ ldx $c062

 LDA #&79
 LDX beeb_keydef_action
 JSR osbyte

.label_2 stx BTN0
 stx BTN1
 rts

\.label_1
\ ldx $c062
\ lda $c061
\
\ LDA #&79
\ LDX #IKN_return EOR &80
\ JSR osbyte
\ TXA
\
\ jmp label_2
}

\*-------------------------------
\*
\*  (Temp routine--for builder only)
\*
\*-------------------------------

IF EditorDisk
.BUTTONS
{
 ldx BTN0 ;"raw"
 lda #0
 sta BUTT0
 lda b0down ;last button value
 stx b0down
 and #$80
 bne :rdbtn1
 stx BUTT0

:rdbtn1 ldx BTN1
 lda #0
 sta BUTT1
 lda b1down
 stx b1down
 and #$80
 bne :rdjup
 stx BUTT1

:rdjup lda joyY
 bmi return
 lda #0
 sta JSTKUP ;jstk is not up--clear JSTKUP
.return
 rts
}
ENDIF

IF _TODO
*-------------------------------
*
*  Convert raw counter value (approx. 0-70) to -1/0/1
*
*  In: X = paddle # (0 = horiz, 1 = vert)
*
*-------------------------------
cvtpdl
 lda joyX,x
 cmp jthres1x,x
 bcs :1
 lda #-1
 bne :3
:1 cmp jthres2x,x
 bcs :2
 lda #0
 beq :3
:2 lda #1
:3 sta joyX,x
return rts

*-------------------------------
*
*  Read game pots
*
*  Out: Raw counter values (approx. 0-70) in joyX-Y
*
*-------------------------------
PREAD
 lda #0
 sta joyX
 sta joyY

 lda $c070 ;Reset timers

:loop ldx #1
:1 lda $c064,x ;Check timer input
 bpl :beat
 inc joyX,x ;Still high; increment counter
:nextpdl dex
 bpl :1

 lda $C064
 ora $C065
 bpl return ;Both inputs low: we're done

 lda joyX
 ora joyY
 bpl :loop ;Do it again
return rts

:beat nop
 bpl :nextpdl ;Kill time

*-------------------------------
*
*  Select jstk & define current joystick posn as center
*
*  Out: jthres1-2x, jthres1-2y
*
*-------------------------------
SETCENTER
 jsr normspeed ;IIGS

 lda #$ff
 sta joyon ;Joystick on

 lda #0
 sta jvert
 sta jhoriz
 sta jbtns ;set normal params

 jsr PREAD ;get raw jstk values

 lda joyX
 ora joyY
 bmi :nojoy ;No joystick connected

 lda joyX
 sec
 sbc #cwidthx
 sta jthres1x
 lda joyX
 clc
 adc #cwidthx
 sta jthres2x

 lda joyY
 sec
 sbc #cwidthy
 sta jthres1y
 lda joyY
 clc
 adc #cwidthy
 sta jthres2y
 rts

:nojoy lda #0
 sta joyon
return rts
ENDIF

\*-------------------------------
\*
\*  M U S I C   K E Y S
\*
\*  Call while music is playing
\*
\*  Esc to pause, Ctrl-S to turn sound off
\*  Return A = ASCII value (FF for button)
\*  Clear hibit if it's a key we've handled
\*
\*-------------------------------

.MUSICKEYS
{
\ Check CTRL first
 LDA #&79
 LDX #IKN_ctrl EOR &80
 JSR osbyte

 TXA
 AND #&80
 STA beeb_keypress_ctrl

\ lda $c000
\ sta keypress
\ bpl nokey
\ sta $c010

\ Check keys above CTRL
 LDA #&79
 LDX #&2
 JSR osbyte

 CPX #&FF
 BEQ nokey

 TXA
 ORA #&80
 STA keypress

 CMP #IKN_esc OR &80
 bne cont

.froze
\ lda $c000
\ sta keypress
\ bpl froze
\ sta $c010

 LDA #&79
 LDX #IKN_esc EOR &80
 JSR osbyte

 TXA
 BPL froze

 and #$7f
 rts

.cont
 cmp #ksound
 bne label_3
 lda soundon
 eor #1
 sta soundon

.label_21
 beq label_2
 jsr gtone

.label_2
 lda #0
 rts

.label_3
 cmp #kmusic
 bne label_1
 lda musicon
 eor #1
 sta musicon
 jmp label_21

.label_1
.nobtn
 lda keypress
 rts

\ Check Apple / joystick button
\ lda $c061
\ ora $c062
\ bpl :nobtn
\ lda #$ff

.nokey
 LDA #0
 STA keypress

.return
 rts
}

SMALL_FONT_MAPCHAR
.redefine_string EQUS "REDEFINE~KEYS~PRESS", &FF
.redefine_left EQUS "LEFT", &FF
.redefine_right EQUS "RIGHT", &FF
.redefine_up EQUS "UP~JUMP", &FF
.redefine_down EQUS "DOWN~CROUCH", &FF
.redefine_jumpleft EQUS "JUMP~LEFT", &FF
.redefine_jumproght EQUS "JUMP~RIGHT", &FF
.redefine_action EQUS "ACTION", &FF
ASCII_MAPCHAR

.redefine_index EQUB 0

.redefine_keys
{
  \ Wait until next vsync frame swap so we know where we are
  .wait_vsync
  LDA vsync_swap_buffers
  BNE wait_vsync

  \ Put ourselves into single buffer mode
  JSR swpage    ; BEEB EXTRA CAUTION - DIRECT FN CALL INTO ANOTHER MODULE
  JSR beeb_clear_status_line

  \ Write initial string
  LDA #LO(redefine_string):STA beeb_readptr
  LDA #HI(redefine_string):STA beeb_readptr+1
  LDX #10
  LDY #BEEB_STATUS_ROW
  LDA #PAL_FONT
  JSR beeb_plot_font_string

  \ Wait until no keys are being pressed
  {
    .wait_for_no_keys
    LDA #&79
    LDX #0
    JSR osbyte

    CPX #&FF
    BNE wait_for_no_keys
  }

  \ Loop round all seven required keys
  LDX #0
  .loop  
  STX redefine_index
  
  \ Fortunately beeb_readptr increments after a string plot
  INC beeb_readptr
  BNE no_carry
  INC beeb_readptr+1
  .no_carry

  \ Clear the line
  LDY #49
  LDX #24
  JSR beeb_clear_status_X

  \ Write next key
  LDX #49
  LDY #BEEB_STATUS_ROW
  LDA #PAL_FONT
  JSR beeb_plot_font_string

  \ Wait for a keypress
  .wait_for_key
  LDA #&79
  LDX #IKN_shift EOR &80
  JSR osbyte
  TXA
  BMI found_key

  .not_shift
  LDA #&79
  LDX #0
  JSR osbyte
  CPX #&FF
  BEQ wait_for_key

  \ Escape will terminate process
  CPX #IKN_esc
  BEQ done

  \ Store the key
  TXA
  EOR #&80
  .found_key

  \ See if we already have this one
  LDX #0
  .check
  CPX redefine_index
  BCS done_check

  \ If so try again
  CMP beeb_keydef_left, X
  BEQ wait_for_key

  INX
  BNE check

  \ If not then store
  .done_check
  STA beeb_keydef_left, X

  \ Wait for no keys pressed
  .wait_for_no_keys
  LDA #&79
  LDX #0
  JSR osbyte

  CPX #&FF
  BNE wait_for_no_keys

  \ Next key in the list
  LDX redefine_index
  INX
  CPX #7
  BNE loop

  .done
  \ Clear the status line and reset to double buffering

  JSR beeb_clear_status_line
  JSR swpage    ; BEEB EXTRA CAUTION - DIRECT FN CALL INTO ANOTHER MODULE

  \ Mark energy meters to be redrawn
  JMP markmeters
}
