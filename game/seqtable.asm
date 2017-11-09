; seqtable.asm
; Originally SEQTABLE.S
; All animation state tables and data

_COULD_BE_OVERLAID_IN_THEORY = TRUE

.seqtab
\org = $3000
\ tr on ;TABS 15,20,40
\ lst off
\ lstdo off

\*-------------------------------
\* Seq table instructions:

\ Already defined in seqdata.h.asm
\goto = -1
\aboutface = -2
\up = -3
\down = -4
\chx = -5
\chy = -6
\act = -7
\setfall = -8
\ifwtless = -9
\die = -10
\jaru = -11
\jard = -12
\effect = -13
\tap = -14
\nextlevel = -15

\*-------------------------------
\*
\*  S E Q U E N C E   T A B L E
\*
\*-------------------------------
\ org org

.seqtable_1 EQUW seqtable_startrun
.seqtable_2 EQUW seqtable_stand
.seqtable_3 EQUW seqtable_standjump
.seqtable_4 EQUW seqtable_runjump
.seqtable_5 EQUW seqtable_turn
.seqtable_6 EQUW seqtable_runturn
.seqtable_7 EQUW seqtable_stepfall
.seqtable_8 EQUW seqtable_jumphangMed
.seqtable_9 EQUW seqtable_hang
.seqtable_10 EQUW seqtable_climbup
.seqtable_11 EQUW seqtable_hangdrop
.seqtable_12 EQUW seqtable_freefall
.seqtable_13 EQUW seqtable_runstop
.seqtable_14 EQUW seqtable_jumpup
.seqtable_15 EQUW seqtable_fallhang
.seqtable_16 EQUW seqtable_jumpbackhang
.seqtable_17 EQUW seqtable_softland
.seqtable_18 EQUW seqtable_jumpfall
.seqtable_19 EQUW seqtable_stepfall2
.seqtable_20 EQUW seqtable_medland
.seqtable_21 EQUW seqtable_rjumpfall
.seqtable_22 EQUW seqtable_hardland
.seqtable_23 EQUW seqtable_hangfall
.seqtable_24 EQUW seqtable_jumphangLong
.seqtable_25 EQUW seqtable_hangstraight
.seqtable_26 EQUW seqtable_rdiveroll
.seqtable_27 EQUW seqtable_sdiveroll
.seqtable_28 EQUW seqtable_highjump
.seqtable_29 EQUW seqtable_step1
.seqtable_30 EQUW seqtable_step2
.seqtable_31 EQUW seqtable_step3
.seqtable_32 EQUW seqtable_step4
.seqtable_33 EQUW seqtable_step5
.seqtable_34 EQUW seqtable_step6
.seqtable_35 EQUW seqtable_step7
.seqtable_36 EQUW seqtable_step8
.seqtable_37 EQUW seqtable_step9
.seqtable_38 EQUW seqtable_step10
.seqtable_39 EQUW seqtable_step11
.seqtable_40 EQUW seqtable_step12
.seqtable_41 EQUW seqtable_step13
.seqtable_42 EQUW seqtable_fullstep
.seqtable_43 EQUW seqtable_turnrun
.seqtable_44 EQUW seqtable_testfoot
.seqtable_45 EQUW seqtable_bumpfall
.seqtable_46 EQUW seqtable_hardbump
.seqtable_47 EQUW seqtable_bump
.seqtable_48 EQUW seqtable_superhijump
.seqtable_49 EQUW seqtable_standup
.seqtable_50 EQUW seqtable_stoop
.seqtable_51 EQUW seqtable_impale
.seqtable_52 EQUW seqtable_crush
.seqtable_53 EQUW seqtable_deadfall
.seqtable_54 EQUW seqtable_halve
.seqtable_55 EQUW seqtable_engarde
.seqtable_56 EQUW seqtable_advance
.seqtable_57 EQUW seqtable_retreat
.seqtable_58 EQUW seqtable_strike
.seqtable_59 EQUW seqtable_flee
.seqtable_60 EQUW seqtable_turnengarde
.seqtable_61 EQUW seqtable_strikeblock
.seqtable_62 EQUW seqtable_readyblock
.seqtable_63 EQUW seqtable_landengarde
.seqtable_64 EQUW seqtable_bumpengfwd
.seqtable_65 EQUW seqtable_bumpengback
.seqtable_66 EQUW seqtable_blocktostrike
.seqtable_67 EQUW seqtable_strikeadv
.seqtable_68 EQUW seqtable_climbdown
.seqtable_69 EQUW seqtable_blockedstrike
.seqtable_70 EQUW seqtable_climbstairs
.seqtable_71 EQUW seqtable_dropdead
.seqtable_72 EQUW seqtable_stepback
.seqtable_73 EQUW seqtable_climbfail
.seqtable_74 EQUW seqtable_stabbed
.seqtable_75 EQUW seqtable_faststrike
.seqtable_76 EQUW seqtable_strikeret
.seqtable_77 EQUW seqtable_alertstand
.seqtable_78 EQUW seqtable_drinkpotion
.seqtable_79 EQUW seqtable_crawl
.seqtable_80 EQUW seqtable_alertturn
.seqtable_81 EQUW seqtable_fightfall
.seqtable_82 EQUW seqtable_efightfall
.seqtable_83 EQUW seqtable_efightfallfwd
.seqtable_84 EQUW seqtable_running
.seqtable_85 EQUW seqtable_stabkill
.seqtable_86 EQUW seqtable_fastadvance
.seqtable_87 EQUW seqtable_goalertstand
.seqtable_88 EQUW seqtable_arise
.seqtable_89 EQUW seqtable_turndraw
.seqtable_90 EQUW seqtable_guardengarde
.seqtable_91 EQUW seqtable_pickupsword
.seqtable_92 EQUW seqtable_resheathe
.seqtable_93 EQUW seqtable_fastsheathe

IF _COULD_BE_OVERLAID_IN_THEORY = FALSE
.seqtable_94 EQUW seqtable_Pstand
.seqtable_95 EQUW seqtable_Vstand
.seqtable_96 EQUW seqtable_Vwalk
.seqtable_97 EQUW seqtable_Vstop
.seqtable_98 EQUW seqtable_Palert
.seqtable_99 EQUW seqtable_Pback
.seqtable_100 EQUW seqtable_Vexit
.seqtable_101 EQUW seqtable_Mclimb
.seqtable_102 EQUW seqtable_Vraise
.seqtable_103 EQUW seqtable_Plie
.seqtable_104 EQUW seqtable_patchfall
.seqtable_105 EQUW seqtable_Mscurry
.seqtable_106 EQUW seqtable_Mstop
.seqtable_107 EQUW seqtable_Mleave
.seqtable_108 EQUW seqtable_Pembrace
.seqtable_109 EQUW seqtable_Pwaiting
.seqtable_110 EQUW seqtable_Pstroke
.seqtable_111 EQUW seqtable_Prise
.seqtable_112 EQUW seqtable_Pcrouch
.seqtable_113 EQUW seqtable_Pslump
.seqtable_114 EQUW seqtable_Mraise
ENDIF

\*-------------------------------
\* r u n n i n g
\*-------------------------------
.seqtable_running
 EQUB act,1
 EQUB goto
 EQUW seqtable_runcyc1

\*-------------------------------
\* s t a r t r u n
\*-------------------------------
.seqtable_startrun
 EQUB act,1
.seqtable_runstt1 EQUB 1
.seqtable_runstt2 EQUB 2
.seqtable_runstt3 EQUB 3
.seqtable_runstt4 EQUB 4,chx,8
.seqtable_runstt5 EQUB 5,chx,3
.seqtable_runstt6 EQUB 6,chx,3

.seqtable_runcyc1 EQUB 7,chx,5
.seqtable_runcyc2 EQUB 8,chx,1
.seqtable_runcyc3 EQUB tap,1,9,chx,2
.seqtable_runcyc4 EQUB 10,chx,4
.seqtable_runcyc5 EQUB 11,chx,5
.seqtable_runcyc6 EQUB 12,chx,2
.seqtable_runcyc7 EQUB tap,1,13,chx,3
.seqtable_runcyc8 EQUB 14,chx,4
 EQUB goto
 EQUW seqtable_runcyc1

\*-------------------------------
\*  s t a n d
\*-------------------------------
.seqtable_stand
 EQUB act,0
 EQUB 15
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\* a l e r t   s t a n d
\*-------------------------------
.seqtable_goalertstand
 EQUB act,1
.seqtable_alertstand
.seqtable_alertstand_loop EQUB 166
 EQUB goto
 EQUW seqtable_alertstand_loop

\*-------------------------------
\* a r i s e (skeleton)
\*-------------------------------
.seqtable_arise
 EQUB act,5
 EQUB chx,10,177
 EQUB 177
 EQUB chx,-7,chy,-2,178
 EQUB chx,5,chy,2,166
 EQUB chx,-1
 EQUB goto
 EQUW seqtable_ready

\*-------------------------------
\* g u a r d e n g a r d e
\*-------------------------------
.seqtable_guardengarde
 EQUB goto
 EQUW seqtable_ready

\*-------------------------------
\* e n  g a r d e
\*-------------------------------
.seqtable_engarde
 EQUB act,1
 EQUB chx,2
 EQUB 207
 EQUB 208,chx,2
 EQUB 209,chx,2
 EQUB 210,chx,3
.seqtable_ready
 EQUB act,1
 EQUB tap,0
 EQUB 158
 EQUB 170
.seqtable_ready_loop EQUB 171

 EQUB goto
 EQUW seqtable_ready_loop

\*-------------------------------
\* s t a b b e d
\*-------------------------------
.seqtable_stabbed
 EQUB act,5
 EQUB setfall,-1,0
 EQUB 172,chx,-1,chy,1
 EQUB 173,chx,-1
 EQUB 174,chx,-1,chy,2
; EQUB 175
 EQUB chx,-2,chy,1
 EQUB chx,-5,chy,-4
 EQUB goto
 EQUW seqtable_guy8

\*-------------------------------
\* s t r i k e - a d v a n c e
\*-------------------------------
;from guy6 (154)
.seqtable_strikeadv
 EQUB act,1
 EQUB setfall,1,0
 EQUB 155
 EQUB chx,2,165
 EQUB chx,-2
 EQUB goto
 EQUW seqtable_ready

\*-------------------------------
\* s t r i k e - r e t r e a t
\*-------------------------------
 ;from guy6 (154)
.seqtable_strikeret
 EQUB act,1
 EQUB setfall,-1,0
 EQUB 155,156,157
 EQUB 158
 EQUB goto
 EQUW seqtable_retreat

\*-------------------------------
\* a d v a n c e
\*-------------------------------
.seqtable_advance
 EQUB act,1
 EQUB setfall,1,0
 EQUB chx,2,163
 EQUB chx,4,164
 EQUB 165

 EQUB goto
 EQUW seqtable_ready

\*-------------------------------
\* f a s t   a d v a n c e
\*-------------------------------
.seqtable_fastadvance
 EQUB act,1
 EQUB setfall,1,0
 EQUB chx,6,164
 EQUB 165

 EQUB goto
 EQUW seqtable_ready

\*-------------------------------
\* r e t r e a t
\*-------------------------------
.seqtable_retreat
 EQUB act,1
 EQUB setfall,-1,0
 EQUB chx,-3,160
 EQUB chx,-2,157

 EQUB goto
 EQUW seqtable_ready

\*-------------------------------
\* s t r i k e
\*-------------------------------
.seqtable_strike
 EQUB act,1
 EQUB setfall,-1,0
 EQUB 168

.seqtable_faststrike
 EQUB act,1
.seqtable_guy3 EQUB 151
.seqtable_guy4 EQUB act,1
 EQUB 152
;-->blockedstrike
.seqtable_guy5 EQUB 153
.seqtable_guy6 EQUB 154
.seqtable_guy7 EQUB act,5 ;clr flags to avoid repeat strike
 EQUB 155
.seqtable_guy8 EQUB act,1
 EQUB 156
.seqtable_guy9 EQUB  157

 EQUB goto
 EQUW seqtable_ready

\*-------------------------------
\* b l o c k e d   s t r i k e
\*-------------------------------
.seqtable_blockedstrike
 EQUB act,1
 EQUB 167
;--> strikeblock
 EQUB goto
 EQUW seqtable_guy7

\*-------------------------------
\* b l o c k   t o   s t r i k e
\*-------------------------------
.seqtable_blocktostrike
 EQUB 162
 EQUB goto
 EQUW seqtable_guy4

\*-------------------------------
\* r e a d y   b l o c k
\*-------------------------------
.seqtable_readyblock
 EQUB 169
.seqtable_blocking
 EQUB 150
 ;--> blocktostrike/retreat
 EQUB goto
 EQUW seqtable_ready

\*-------------------------------
\* s t r i k e   t o   b l o c k
\*-------------------------------
.seqtable_strikeblock
 EQUB 159
 EQUB 160
 EQUB goto
 EQUW seqtable_blocking

\*-------------------------------
\* l a n d   e n   g a r d e
\*-------------------------------
.seqtable_landengarde
 EQUB act,1
 EQUB jard

 EQUB goto
 EQUW seqtable_ready

\*-------------------------------
\* b u m p   e n   g a r d e   ( f o r w a r d )
\*-------------------------------
.seqtable_bumpengfwd
 EQUB act,5
 EQUB chx,-8

 EQUB goto
 EQUW seqtable_ready

\*-------------------------------
\* b u m p   e n   g a r d e   ( b a c k )
\*-------------------------------
.seqtable_bumpengback
 EQUB act,5
 EQUB 160
 EQUB 157
 EQUB goto
 EQUW seqtable_ready

\*-------------------------------
\* f l e e
\*-------------------------------
.seqtable_flee
 EQUB act,7
 EQUB chx,-8

 EQUB goto
 EQUW seqtable_turn

\*-------------------------------
\* t u r n   e n   g a r d e
\*-------------------------------
.seqtable_turnengarde
 EQUB act,5
 EQUB aboutface,chx,5

 EQUB goto
 EQUW seqtable_retreat

\*-------------------------------
\*  a l e r t  t u r n (for enemies)
\*-------------------------------
.seqtable_alertturn
 EQUB act,5

 EQUB aboutface,chx,18

 EQUB goto
 EQUW seqtable_goalertstand

\*-------------------------------
\*  s t a n d j u m p
\*-------------------------------
.seqtable_standjump
 EQUB act,1
 EQUB 16
 EQUB 17,chx,2
 EQUB 18,chx,2
 EQUB 19,chx,2
 EQUB 20,chx,2
 EQUB 21,chx,2
 EQUB 22,chx,7
 EQUB 23,chx,9
 EQUB 24,chx,5,chy,-6 ;chx 6?
.seqtable_sjland EQUB 25,chx,1,chy,6
 EQUB 26,chx,4
 EQUB jard
 EQUB tap,1,27,chx,-3
 EQUB 28,chx,5
 EQUB 29
 EQUB tap,1,30
 EQUB 31
 EQUB 32
 EQUB 33,chx,1
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  r u n j u m p
\*-------------------------------
.seqtable_runjump
 EQUB act,1
 EQUB tap,1,34,chx,5
 EQUB 35,chx,6
 EQUB 36,chx,3
 EQUB 37,chx,5
 EQUB tap,1,38,chx,7
 EQUB 39,chx,12,chy,-3
 EQUB 40,chx,8,chy,-9
 EQUB 41,chx,8,chy,-2
 EQUB 42,chx,4,chy,11
 EQUB 43,chx,4,chy,3
.seqtable_rjlandrun
 EQUB 44,chx,5
 EQUB jard,tap,1
 EQUB goto
 EQUW seqtable_runcyc1

\*-------------------------------
\*  r u n  d i v e  r o l l
\*-------------------------------
.seqtable_rdiveroll
 EQUB act,1

 EQUB chx,1
 EQUB 107,chx,2
 EQUB chx,2
 EQUB 108
 EQUB chx,2
 EQUB 109
 EQUB chx,2
 EQUB 109
 EQUB chx,2
.seqtable_rdiveroll_crouch EQUB 109
 EQUB goto
 EQUW seqtable_rdiveroll_crouch

\*-------------------------------
\*  s t a n d  d i v e  r o l l
\*-------------------------------
.seqtable_sdiveroll

\*-------------------------------
\*  c r a w l
\*-------------------------------
.seqtable_crawl
 EQUB act,1
 EQUB chx,1,110
 EQUB 111,chx,2
 EQUB 112

 EQUB chx,2
 EQUB 108
 EQUB chx,2
.seqtable_crawl_crouch EQUB 109
 EQUB goto
 EQUW seqtable_crawl_crouch

\*-------------------------------
\*  t u r n  d r a w
\*-------------------------------
.seqtable_turndraw
 EQUB act,7
 EQUB aboutface,chx,6
 EQUB 45,chx,1
 EQUB 46
 EQUB goto
 EQUW seqtable_engarde

\*-------------------------------
\*  t u r n
\*-------------------------------
.seqtable_turn
 EQUB act,7
 EQUB aboutface,chx,6
 EQUB 45,chx,1
 EQUB 46,chx,2
 EQUB 47,chx,-1
.seqtable_finishturn
 EQUB 48,chx,1
 EQUB 49,chx,-2
 EQUB 50,51,52
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  t u r n r u n
\*  (from frame 48)
\*-------------------------------
.seqtable_turnrun
 EQUB act,1
 EQUB chx,-1
 EQUB goto
 EQUW seqtable_runstt1

\*-------------------------------
\*  r u n t u r n
\*-------------------------------
.seqtable_runturn
 EQUB act,1
 EQUB chx,1
 EQUB  53,chx,1
 EQUB tap,1,54,chx,8
 EQUB 55
 EQUB tap,1,56,chx,7
 EQUB 57,chx,3
 EQUB 58,chx,1
 EQUB 59
 EQUB 60,chx,2
 EQUB 61,chx,-1
 EQUB 62
 EQUB 63
 EQUB 64,chx,-1
 EQUB 65,chx,-14
 EQUB aboutface,goto
 EQUW seqtable_runcyc7

\*-------------------------------
\*  f i g h t f a l l  (backward)
\*-------------------------------
.seqtable_fightfall
 EQUB act,3
 EQUB chy,-1

 EQUB 102,chx,-2,chy,6
 EQUB 103,chx,-2,chy,9
 EQUB 104,chx,-1,chy,12
 EQUB 105,chx,-3

 EQUB setfall,0,15
 EQUB goto
 EQUW seqtable_freefall

\*-------------------------------
\*  e n e m y  f i g h t  f a l l
\*-------------------------------
.seqtable_efightfall
 EQUB act,3
 EQUB chy,-1,chx,-2

 EQUB 102,chx,-3,chy,6
 EQUB 103,chx,-3,chy,9
 EQUB 104,chx,-2,chy,12
 EQUB 105,chx,-3
;for now--ultimately we want enemy
;shapes in here
 EQUB setfall,0,15
 EQUB goto
 EQUW seqtable_freefall

\*-------------------------------
\*  e n e m y  f i g h t  f a l l  f w d
\*-------------------------------
.seqtable_efightfallfwd
 EQUB act,3
 EQUB chx,1,chy,-1

 EQUB 102,chx,2,chy,6
 EQUB 103,chx,-1,chy,9
 EQUB 104,chy,12
 EQUB 105,chx,-2
;for now--ultimately we want enemy
;shapes in here
 EQUB setfall,1,15
 EQUB goto
 EQUW seqtable_freefall


\*-------------------------------
\*  s t e p f a l l
\*-------------------------------
.seqtable_stepfall ;from #8 (run-11)
 EQUB act,3
 EQUB chx,1,chy,3

 EQUB ifwtless
 EQUW seqtable_stepfloat
.seqtable_fall1
 EQUB 102,chx,2,chy,6
 EQUB 103,chx,-1,chy,9
 EQUB 104,chy,12
 EQUB 105,chx,-2

 EQUB setfall,1,15
 EQUB goto
 EQUW seqtable_freefall

\*-------------------------------
\* p a t c h f a l l
\*-------------------------------
.seqtable_patchfall
 EQUB chx,-1,chy,-3
 EQUB goto
 EQUW seqtable_fall1

\*-------------------------------
\* s t e p f a l l 2
\*-------------------------------
.seqtable_stepfall2 ;from #12 (run-15)
 EQUB chx,1
 EQUB goto
 EQUW seqtable_stepfall

\*-------------------------------
\*  s t e p f l o a t
\*-------------------------------
.seqtable_stepfloat
 EQUB 102,chx,2,chy,3
 EQUB 103,chx,-1,chy,4
 EQUB 104,chy,5
 EQUB 105,chx,-2

 EQUB setfall,1,6
 EQUB goto
 EQUW seqtable_freefall

\*-------------------------------
\*  j u m p  f a l l
\*-------------------------------
.seqtable_jumpfall ;from standjump-18
 EQUB act,3
 EQUB chx,1,chy,3
 EQUB 102,chx,2,chy,6
 EQUB 103,chx,1,chy,9
 EQUB 104,chx,2,chy,12
 EQUB 105

 EQUB setfall,2,15
 EQUB goto
 EQUW seqtable_freefall

\*-------------------------------
\*  r u n n i n g   j u m p   f a l l
\*-------------------------------
.seqtable_rjumpfall ;from runjump-43
 EQUB act,3
 EQUB chx,1,chy,3
 EQUB 102,chx,3,chy,6
 EQUB 103,chx,2,chy,9
 EQUB 104,chx,3,chy,12
 EQUB 105

 EQUB setfall,3,15
 EQUB goto
 EQUW seqtable_freefall

\*-------------------------------
\*  j u m p h a n g
\*-------------------------------
;Med: DX = 0
.seqtable_jumphangMed
 EQUB act,1
 EQUB 67,68,69,70,71,72,73,74,75,76,77
 EQUB act,2
 EQUB 78,79,80
 EQUB goto
 EQUW seqtable_hang

;Long: DX = +4
.seqtable_jumphangLong
 EQUB act,1
 EQUB 67,68,69,70,71,72,73,74,75,76,77
 EQUB act,2
 EQUB chx,1,78
 EQUB chx,2,79
 EQUB chx,1,80

 EQUB goto
 EQUW seqtable_hang

\*-------------------------------
\* j u m p b a c k h a n g
\*-------------------------------
.seqtable_jumpbackhang
 EQUB act,1
 EQUB 67,68,69,70,71,72,73,74,75,76
 EQUB chx,-1,77
 EQUB act,2
 EQUB chx,-2,78
 EQUB chx,-1,79
 EQUB chx,-1,80

 EQUB goto
 EQUW seqtable_hang

\*-------------------------------
\*  h a n g
\*-------------------------------
.seqtable_hang
 EQUB act,2
; EQUB jaru
 EQUB 91
.seqtable_hang1
 EQUB 90,89,88,87,87,87,88,89,90,91,92,93,94,95
 EQUB 96,97,98,99,97,96,95,94,93,92
 EQUB 91,90,89,88,87,88,89,90,91,92,93,94,95,96
 EQUB 95,94,93,92
 EQUB goto
 EQUW seqtable_hangdrop

\*-------------------------------
\*  h a n g s t r a i g h t
\*-------------------------------
.seqtable_hangstraight
 EQUB act,6
 EQUB tap,2
 EQUB 92,93,93,92,92
.seqtable_hangstraight_loop EQUB 91
 EQUB goto
 EQUW seqtable_hangstraight_loop

\*-------------------------------
\*  c l i m b f a i l
\*-------------------------------
.seqtable_climbfail
 EQUB 135
 EQUB 136
 EQUB 137,137
 EQUB 138,138,138,138
 EQUB 137,136,135
 EQUB chx,-7

 EQUB goto
 EQUW seqtable_hangdrop

\*-------------------------------
\*  c l i m b d o w n
\*-------------------------------
.seqtable_climbdown
 EQUB act,1

 EQUB 148
 EQUB 145,144,143,142,141

 EQUB chx,-5
 EQUB chy,63
 EQUB down
 EQUB act,3 ;to prevent a cut to scrn above

 EQUB 140,138,136
 EQUB 91
 EQUB goto
 EQUW seqtable_hang1

\*-------------------------------
\*  c l i m b u p
\*-------------------------------
.seqtable_climbup
 EQUB act,1

 EQUB 135
 EQUB 136
 EQUB 137
 EQUB 138
 EQUB 139
 EQUB 140

 EQUB chx,5
 EQUB chy,-63
 EQUB up

 EQUB 141
 EQUB 142
 EQUB 143
 EQUB 144
 EQUB 145
 EQUB 146
 EQUB 147
 EQUB  148
 EQUB act,5 ;to clr flags
 EQUB 149
 EQUB act,1

 EQUB 118,119
 EQUB chx,1
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  h a n g d r o p
\*-------------------------------
.seqtable_hangdrop ;1/2 story

 EQUB act,0 ;NOTE -- hangdrop is an action relating
;to the ground, not to the ledge
 EQUB 81,82
 EQUB act,5 ;to zero clrflags
 EQUB 83
 EQUB act,1
 EQUB jard,tap,0
 EQUB 84,85
 EQUB chx,3
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  h a n g f a l l
\*-------------------------------
.seqtable_hangfall ;1/2 story

 EQUB act,3
 EQUB 81,chy,6
 EQUB 81,chy,9
 EQUB 81,chy,12
 EQUB chx,2

 EQUB setfall,0,12
 EQUB goto
 EQUW seqtable_freefall

\*-------------------------------
\*  f r e e f a l l
\*-------------------------------
.seqtable_freefall
 EQUB act,4
.seqtable_freefall_loop EQUB 106
 EQUB goto
 EQUW seqtable_freefall_loop

\*-------------------------------
\*  r u n s t o p
\*-------------------------------
.seqtable_runstop
 EQUB act,1
 EQUB 53,chx,2
 EQUB tap,1,54,chx,7
 EQUB 55
 EQUB tap,1,56,chx,2
 EQUB 49,chx,-2
 EQUB 50,51,52
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  j u m p  u p  (& touch ceiling)
\*-------------------------------
.seqtable_jumpup
 EQUB act,1
 EQUB 67,68,69,70,71,72,73,74,75,76,77,78
 EQUB act,0 ;for cropchar
 EQUB jaru,79

 EQUB goto
 EQUW seqtable_hangdrop

\*-------------------------------
\*  h i g h j u m p  (no ceiling above)
\*-------------------------------
.seqtable_highjump
 EQUB act,1
 EQUB 67,68,69,70,71,72,73,74,75,76,77,78
 EQUB 79,chy,-4
 EQUB 79,chy,-2
 EQUB 79
 EQUB 79,chy,2
 EQUB 79,chy,4
 EQUB goto
 EQUW seqtable_hangdrop

\*-------------------------------
\*  s u p e r h i j u m p  (when weightless)
\*-------------------------------
.seqtable_superhijump
 EQUB 67,68,69,70,71,72,73,74,75,76
 EQUB chy,-1,77
 EQUB chy,-3,78
 EQUB chy,-4,79
 EQUB chy,-10,79
 EQUB chy,-9,79
 EQUB chy,-8,79
 EQUB chy,-7,79
 EQUB chy,-6,79
 EQUB chy,-5,79
 EQUB chy,-4,79
 EQUB chy,-3,79
 EQUB chy,-2,79
 EQUB chy,-2,79
 EQUB chy,-1,79
 EQUB chy,-1,79
 EQUB chy,-1,79
 EQUB 79,79,79
 EQUB chy,1,79
 EQUB chy,1,79
 EQUB chy,2,79
 EQUB chy,2,79
 EQUB chy,3,79
 EQUB chy,4,79
 EQUB chy,5,79
 EQUB chy,6,79

 EQUB setfall,0,6
 EQUB goto
 EQUW seqtable_freefall

\*-------------------------------
\*  f a l l  h a n g
\*-------------------------------
.seqtable_fallhang
 EQUB act,3
 EQUB 80
 EQUB tap,1
 EQUB goto
 EQUW seqtable_hang

\*-------------------------------
\*  b u m p
\*-------------------------------
.seqtable_bump
 EQUB act,5
 EQUB chx,-4

 EQUB 50,51,52
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  b u m p f a l l
\*-------------------------------
.seqtable_bumpfall
 EQUB act,5
 EQUB chx,1,chy,3

 EQUB ifwtless
 EQUW seqtable_bumpfloat

 EQUB 102,chx,2,chy,6
 EQUB 103,chx,-1,chy,9
 EQUB 104,chy,12
 EQUB 105,chx,-2

 EQUB setfall,0,15
 EQUB goto
 EQUW seqtable_freefall

\*-------------------------------
\*  b u m p f l o a t
\*-------------------------------
.seqtable_bumpfloat
 EQUB 102,chx,2,chy,3
 EQUB 103,chx,-1,chy,4
 EQUB 104,chy,5
 EQUB 105,chx,-2

 EQUB setfall,0,6
 EQUB goto
 EQUW seqtable_freefall

\*-------------------------------
\* h a r d   b u m p
\*-------------------------------
.seqtable_hardbump
 EQUB act,5

 EQUB chx,-1,chy,-4,102
 EQUB chx,-1,chy,3 ;,104
 EQUB chx,-3,chy,1

 EQUB jard
 EQUB chx,1
 EQUB tap,1
 EQUB 107,chx,2
 EQUB 108
 EQUB tap,1

 EQUB 109
 EQUB goto
 EQUW seqtable_standup

\*-------------------------------
\*  t e s t   f o o t
\*-------------------------------
.seqtable_testfoot
 EQUB 121,chx,1
 EQUB 122
 EQUB 123,chx,2
 EQUB 124,chx,4
 EQUB 125,chx,3
 EQUB 126

 EQUB chx,-4,86
 EQUB tap,1,jard
 EQUB chx,-4,116
 EQUB chx,-2
 EQUB 117,118,119
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  s t e p   b a c k
\*-------------------------------
.seqtable_stepback
 EQUB chx,-5
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  s t e p   f o r w a r d
\*
\*  (1 - 14 pixels)
\*-------------------------------
.seqtable_fullstep
.seqtable_step14
 EQUB act,1
 EQUB 121,chx,1
 EQUB 122,chx,1
 EQUB 123,chx,3
 EQUB 124,chx,4
 EQUB 125,chx,3
 EQUB 126,chx,-1

 EQUB chx,3

 EQUB 127,128,129,130,131,132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step13
 EQUB act,1
 EQUB 121,chx,1
 EQUB 122,chx,1
 EQUB 123,chx,3
 EQUB 124,chx,4
 EQUB 125,chx,3
 EQUB 126,chx,-1

 EQUB chx,2

 EQUB 127,128,129,130,131,132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step12
 EQUB act,1
 EQUB 121,chx,1
 EQUB 122,chx,1
 EQUB 123,chx,3
 EQUB 124,chx,4
 EQUB 125,chx,3
 EQUB 126,chx,-1

 EQUB chx,1

 EQUB 127,128,129,130,131,132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step11 ;corresponds directly to filmed sequence
 EQUB act,1
 EQUB 121,chx,1
 EQUB 122,chx,1
 EQUB 123,chx,3
 EQUB 124,chx,4
 EQUB 125,chx,3
 EQUB 126,chx,-1
 EQUB 127,128,129,130,131,132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step10
 EQUB act,1
 EQUB 121,chx,1
.seqtable_step10a EQUB 122,chx,1
 EQUB 123,chx,3
 EQUB 124,chx,4
 EQUB 125,chx,3
 EQUB 126,chx,-2
 EQUB 128,129,130,131,132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step9
 EQUB act,1
 EQUB 121
 EQUB goto
 EQUW seqtable_step10a

.seqtable_step8
 EQUB act,1
 EQUB 121,chx,1
 EQUB 122,chx,1
 EQUB 123,chx,3
 EQUB 124,chx,4
 EQUB 125,chx,-1
 EQUB 127,128,129,130,131,132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step7
 EQUB act,1
 EQUB 121,chx,1
 EQUB 122,chx,1
 EQUB 123,chx,3
 EQUB 124,chx,2

 EQUB 129,130,131,132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step6
 EQUB act,1
 EQUB 121,chx,1
 EQUB 122,chx,1
 EQUB 123,chx,2
 EQUB 124,chx,2

 EQUB 129,130,131,132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step5
 EQUB act,1
 EQUB 121,chx,1
 EQUB 122,chx,1
 EQUB 123,chx,2
 EQUB 124,chx,1

 EQUB 129,130,131,132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step4
 EQUB act,1
 EQUB 121,chx,1
 EQUB 122,chx,1
 EQUB 123,chx,2

 EQUB 131,132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step3
 EQUB act,1
 EQUB 121,chx,1
 EQUB 122,chx,1
 EQUB 123,chx,1

 EQUB 131,132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step2
 EQUB act,1
 EQUB 121,chx,1
 EQUB 122,chx,1
 EQUB 132
 EQUB goto
 EQUW seqtable_stand

.seqtable_step1
 EQUB act,1
 EQUB 121,chx,1
 EQUB 132
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  s t o o p
\*-------------------------------
.seqtable_stoop
 EQUB act,1

 EQUB chx,1
 EQUB 107,chx,2
 EQUB 108

.seqtable_stoop_crouch EQUB 109
 EQUB goto
 EQUW seqtable_stoop_crouch

\*-------------------------------
\*  s t a n d u p
\*-------------------------------
.seqtable_standup
 EQUB act,5
 EQUB chx,1,110
 EQUB 111,chx,2
 EQUB 112
 EQUB 113,chx,1
 EQUB 114
 EQUB 115
 EQUB 116,chx,-4
 EQUB 117,118,119

 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  p i c k  u p  s w o r d
\*-------------------------------
.seqtable_pickupsword
 EQUB act,1
 EQUB effect,1
 EQUB 229,229,229,229,229,229
 EQUB 230,231,232

 EQUB goto
 EQUW seqtable_resheathe

\*-------------------------------
\*  r e s h e a t h e
\*-------------------------------
.seqtable_resheathe
 EQUB act,1
 EQUB chx,-5
 EQUB 233,234,235
 EQUB 236,237,238,239,240,133,133
 EQUB 134,134,134
 EQUB 48,chx,1
 EQUB 49,chx,-2
 EQUB act,5,50,act,1
 EQUB 51,52
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  f a s t   s h e a t h e
\*-------------------------------
.seqtable_fastsheathe
 EQUB act,1
 EQUB chx,-5
 EQUB 234,236,238,240,134
 EQUB chx,-1
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  d r i n k   p o t i o n
\*-------------------------------
.seqtable_drinkpotion
 EQUB act,1
 EQUB chx,4
 EQUB 191,192,193,194,195,196,197,198,199,200
 EQUB 201,202,203,204
;if pressed for memory try
;cutting frames 202/204 or 201/203
 EQUB 205,205,205
 EQUB effect,1
 EQUB 205,205
 EQUB 201,198

 EQUB chx,-4
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  s o f t   l a n d
\*-------------------------------
.seqtable_softland ;1 story
 EQUB act,5

 EQUB jard
 EQUB chx,1
 EQUB tap,1,107,chx,2
 EQUB 108
 EQUB tap,1

 EQUB act,1
.seqtable_softland_crouch EQUB 109
 EQUB goto
 EQUW seqtable_softland_crouch

\*-------------------------------
\*  l a n d   r u n
\*-------------------------------
.seqtable_landrun
 EQUB act,1
 EQUB chy,-2,chx,1
 EQUB 107,chx,2
 EQUB 108
 EQUB 109,chx,1
 EQUB 110
 EQUB 111,chx,2
 EQUB 112
 EQUB 113,chx,1,chy,1
 EQUB 114,chy,1
 EQUB 115,chx,-2

 EQUB goto
 EQUW seqtable_runstt4

\*-------------------------------
\*  m e d i u m   l a n d
\*-------------------------------
.seqtable_medland ;1 1/2 - 2 stories
 EQUB act,5
 EQUB jard
 EQUB chy,-2,chx,1
; EQUB 107
 EQUB chx,2
 EQUB 108
 EQUB 109,109,109,109,109,109,109,109,109
 EQUB 109,109,109,109,109,109,109,109,109
 EQUB 109,109,109,109,109,109,109,109,109
 EQUB 109,109,chx,1
 EQUB 110,110,110
 EQUB 111,chx,2
 EQUB 112
 EQUB 113,chx,1,chy,1
 EQUB 114,chy,1
 EQUB 115
 EQUB 116,chx,-4
 EQUB 117
 EQUB 118
 EQUB 119
 EQUB goto
 EQUW seqtable_stand

\*-------------------------------
\*  h a r d   l a n d   (Splat!)
\*-------------------------------
.seqtable_hardland ;> 2 stories
 EQUB act,5
 EQUB jard
 EQUB chy,-2,chx,3
 EQUB 185
 EQUB die

.seqtable_hardland_dead EQUB 185
 EQUB goto
 EQUW seqtable_hardland_dead

\*-------------------------------
\*  s t a b k i l l
\*-------------------------------
.seqtable_stabkill
 EQUB act,5
 EQUB goto
 EQUW seqtable_dropdead

\*-------------------------------
\*  d r o p d e a d
\*-------------------------------
.seqtable_dropdead
 EQUB act,1
 EQUB die

 EQUB 179
 EQUB 180
 EQUB 181
 EQUB 182,chx,1
 EQUB 183,chx,-4
.seqtable_dropdead_dead EQUB 185
 EQUB goto
 EQUW seqtable_dropdead_dead

\*-------------------------------
\*  i m p a l e
\*-------------------------------
.seqtable_impale
 EQUB act,1
 EQUB jard

 EQUB chx,4
 EQUB 177
 EQUB die

.seqtable_impale_dead EQUB 177
 EQUB goto
 EQUW seqtable_impale_dead

\*-------------------------------
\*  h a l v e
\*-------------------------------
.seqtable_halve
 EQUB act,1

 EQUB 178
 EQUB die

.seqtable_halve_dead EQUB 178
 EQUB goto
 EQUW seqtable_halve_dead

\*-------------------------------
\*  c r u s h
\*-------------------------------
.seqtable_crush
 EQUB goto
 EQUW seqtable_medland

\*-------------------------------
\*  d e a d f a l l
\*-------------------------------
.seqtable_deadfall
 EQUB setfall,0,0
 EQUB act,4
.seqtable_deadfall_loop EQUB 185
 EQUB goto
 EQUW seqtable_deadfall_loop

\*-------------------------------
\*  c l i m b   s t a i r s
\*-------------------------------
;facing L
.seqtable_climbstairs
 EQUB act,5
 EQUB chx,-5,chy,-1
 EQUB tap,1,217
 EQUB 218
 EQUB 219,chx,1
 EQUB 220,chx,-4,chy,-3
 EQUB tap,1,221,chx,-4,chy,-2
 EQUB 222,222,chx,-2,chy,-3
 EQUB 223,223,chx,-3,chy,-8
 EQUB tap,1,224,224,chx,-1,chy,-1
 EQUB 225,225,chx,-3,chy,-4
 EQUB 226,226,chx,-1,chy,-5
 EQUB tap,1,227,227,chx,-2,chy,-1
 EQUB 228,228
 EQUB 0,tap,1
 EQUB 0,0,0,0,tap,1
 EQUB 0,0,0,0,tap,1
 EQUB 0,0,0,0,tap,1

IF 0
 EQUB chx,10,chy,28
 EQUB goto
 EQUW seqtable_stand
ENDIF

 EQUB nextlevel
.seqtable_climbstairs_loop EQUB 0,goto
 EQUW seqtable_climbstairs_loop

IF _COULD_BE_OVERLAID_IN_THEORY = FALSE

\*-------------------------------
\* Vizier: stand
\*-------------------------------
.seqtable_Vstand
 EQUB 54,goto
 EQUW seqtable_Vstand

\*-------------------------------
\* Vizier: raise arms
\*-------------------------------
.seqtable_Vraise
 EQUB 85,67,67,67,67,67,67
 EQUB 68,69,70,71,72,73,74,75,83,84
.seqtable_Vraise_loop EQUB 76
 EQUB goto
 EQUW seqtable_Vraise_loop

\*-------------------------------
\* Vizier: walk
\*-------------------------------
.seqtable_Vwalk
 EQUB chx,1
.seqtable_Vwalk1 EQUB 48,chx,2
.seqtable_Vwalk2 EQUB 49,chx,6
 EQUB 50,chx,1
 EQUB 51,chx,-1
 EQUB 52,chx,1
 EQUB 53,chx,1
 EQUB goto
 EQUW seqtable_Vwalk1

\*-------------------------------
\* Vizier: stop
\*-------------------------------
.seqtable_Vstop
 EQUB chx,1
 EQUB 55,56
 EQUB goto
 EQUW seqtable_Vstand

\*-------------------------------
\* Vizier: lower arms, turn & exit
\*-------------------------------
.seqtable_Vexit
 EQUB 77,78,79,80,81,82
 EQUB chx,1
 EQUB 54,54,54,54,54,54 ;standing
 EQUB 57
 EQUB 58
 EQUB 59
 EQUB 60
 EQUB 61,chx,2
 EQUB 62,chx,-1
 EQUB 63,chx,-3
 EQUB 64
 EQUB 65,chx,-1
 EQUB 66
 EQUB aboutface,chx,16
 EQUB chx,3
 EQUB goto
 EQUW seqtable_Vwalk2

\*-------------------------------
\* Princess: stand
\*-------------------------------
.seqtable_Pstand
 EQUB 11,goto
 EQUW seqtable_Pstand

\*-------------------------------
\* Princess: alert
\*-------------------------------
.seqtable_Palert
 EQUB 2,3,4,5,6,7,8,9
 EQUB aboutface,chx,9
 EQUB 11,goto
 EQUW seqtable_Pstand

\*-------------------------------
\* Princess: step back
\*-------------------------------
.seqtable_Pback
 EQUB aboutface,chx,11
 EQUB 12
 EQUB chx,1,13
 EQUB chx,1,14
 EQUB chx,3,15
 EQUB chx,1,16
.seqtable_Pback_loop EQUB 17
 EQUB goto
 EQUW seqtable_Pback_loop

\*-------------------------------
\* Princess lying on cushions
\*-------------------------------
.seqtable_Plie
 EQUB 19
 EQUB goto
 EQUW seqtable_Plie

\*-------------------------------
\* Princess: waiting
\*-------------------------------
.seqtable_Pwaiting
.seqtable_Pwaiting_loop EQUB 20
 EQUB goto
 EQUW seqtable_Pwaiting_loop

\*-------------------------------
\* Princess: embrace
\*-------------------------------
.seqtable_Pembrace
 EQUB 21
 EQUB chx,1,22
 EQUB 23
 EQUB 24
 EQUB chx,1,25
 EQUB chx,-3,26
 EQUB chx,-2,27
 EQUB chx,-4,28
 EQUB chx,-3,29
 EQUB chx,-2,30
 EQUB chx,-3,31
 EQUB chx,-1,32
.seqtable_Pembrace_loop EQUB 33
 EQUB goto
 EQUW seqtable_Pembrace_loop

\*-------------------------------
\* Princess: stroke mouse
\*-------------------------------
.seqtable_Pstroke
.seqtable_Pstroke_loop EQUB 37
 EQUB goto
 EQUW seqtable_Pstroke_loop

\*-------------------------------
\* Princess: rise
\*-------------------------------
.seqtable_Prise
 EQUB 37,38,39,40,41,42,43,44,45,46,47
 EQUB aboutface,chx,13
.seqtable_Prise_loop EQUB 11,goto
 EQUW seqtable_Prise_loop

\*-------------------------------
\* Princess: crouch & stroke mouse
\*-------------------------------
.seqtable_Pcrouch
 EQUB 11,11
 EQUB aboutface,chx,13
 EQUB 47,46,45,44,43,42,41,40,39,38,37
 EQUB 36,36,36,35,35,35
 EQUB 34,34,34,34,34,34,34
 EQUB 35,35,36,36,36,35,35,35
 EQUB 34,34,34,34,34,34,34
 EQUB 35,35,36,36,36,35,35,35
 EQUB 34,34,34,34,34,34,34,34,34
 EQUB 35,35,35
.seqtable_Pcrouch_loop EQUB 36
 EQUB goto
 EQUW seqtable_Pcrouch_loop

\*-------------------------------
\* Princess: slump shoulders
\*-------------------------------
.seqtable_Pslump
 EQUB 1
.seqtable_Pslump_loop EQUB 18
 EQUB goto
 EQUW seqtable_Pslump_loop

\*-------------------------------
\* Mouse: scurry
\*-------------------------------
.seqtable_Mscurry
 EQUB act,1
.seqtable_Mscurry1
.seqtable_Mscurry_loop EQUB 186,chx,5
 EQUB 186,chx,3
 EQUB 187,chx,4
 EQUB goto
 EQUW seqtable_Mscurry_loop

\*-------------------------------
\* Mouse: stop
\*-------------------------------
.seqtable_Mstop
.seqtable_Mstop_loop EQUB 186
 EQUB goto
 EQUW seqtable_Mstop_loop

\*-------------------------------
\* Mouse: raise head
\*-------------------------------
.seqtable_Mraise
.seqtable_Mraise_loop EQUB 188
 EQUB goto
 EQUW seqtable_Mraise_loop

\*-------------------------------
\* Mouse: leave
\*-------------------------------
.seqtable_Mleave
 EQUB act,0
 EQUB 186,186,186
 EQUB 188,188,188,188,188,188,188,188
 EQUB aboutface,chx,8
 EQUB goto
 EQUW seqtable_Mscurry1

\*-------------------------------
\* Mouse: climb
\*-------------------------------
.seqtable_Mclimb
 EQUB 186
 EQUB goto
 EQUW seqtable_Mclimb

ENDIF

\*-------------------------------
\ lst
\ ds 1
\ usr $a9,15,$800,\*-org
\ lst off
