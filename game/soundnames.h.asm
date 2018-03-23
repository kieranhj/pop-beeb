; soundnames.h.asm
; Originally SOUNDNAMES.S
; Defines for audio system

\ tr on
\ lst off

\* sound names

PlateDown = 0
PlateUp = 1
GateDown = 2
SpecialKey1 = 3
SpecialKey2 = 4
Splat = 5
MirrorCrack = 6
LooseCrash = 7
GotKey = 8
Footstep = 9
RaisingExit = 10
RaisingGate = 11
LoweringGate = 12
SmackWall = 13
Impaled = 14
GateSlam = 15
FlashMsg = 16
SwordClash1 = 17
SwordClash2 = 18
JawsClash = 19
s_Glug = 20         ; Added for drinking a potion

\*-------------------------------
\* game music
\* Music song #s

s_Accid = 1         ; accidental death
s_Heroic = 2        ; 'heroic' death
s_Danger = 3        ; danger theme for mirror (level 4)
s_Sword = 4         ; got sword
s_Rejoin = 5        ; Kid & shadow reunite
s_Shadow = 6        ; death if opponent was shadowman
s_Vict = 7          ; killed an enemy
s_Stairs = 8        ; stairs have appeared - BEEB only after beating Jaffar
s_Upstairs = 9      ; player has won level
s_Jaffar = 10       ; Play Jaffar's Theme (Level 13)
s_Potion = 11       ; Drunk potion
s_ShortPot = 12     ; Small potion used

s_Timer = 13        ; Cut scene timer music
s_Tragic = 14       ; Tragic ending cut scene (out of time I think)
s_Embrace = 15      ; Happy ending cut scene
s_Heartbeat = 16    ; Princess cut scene 2/5/8

\* title music
\* Set 1 (title)

s_Presents = 1
s_Byline = 2
s_Title = 3
s_Prolog = 4
s_Sumup = 5
s_Princess = 7
s_Squeek = 8
s_Vizier = 9
s_Buildup = 10
s_Magic = 11
s_StTimer = 12

\* Set 2 (epilog)

s_Epilog = 13
s_Curtain = 14

\ lst off
