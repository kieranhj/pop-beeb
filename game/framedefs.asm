; framedefs.asm
; Originally FRAMEDEFS.S
; Animation frame definitions

.framedef
.seqtable
\bof = $2800
\ tr on ;TABS 15,20,40
\ lst off
\ lstdo off

\*-------------------------------
\ dum bof

\org ds 1200
\altset1 ds 200
\altset2 ds 450
\swordtab ds 192

\ dend

\*-------------------------------
\ org org
.Fdef

\*  Fimage, Fsword, Fdx, Fdy, Fcheck

.Fdef_1 EQUB $01,0,1,0,$c0+4 ;run-4
.Fdef_2 EQUB $02,0,1,0,$40+4 ;run-5
.Fdef_3 EQUB $03,0,3,0,$40+7 ;run-6
.Fdef_4 EQUB $04,0,4,0,$40+8 ;run-7
.Fdef_5 EQUB $05,0,0,0,$c0+$20+6 ;run-8
.Fdef_6 EQUB $06,0,0,0,$40+9 ;run-9
.Fdef_7 EQUB $07,0,0,0,$40+10 ;run-10
.Fdef_8 EQUB $08,0,0,0,$c0+5 ;run-11
.Fdef_9 EQUB $09,0,0,0,$40+4 ;run-12
.Fdef_10 EQUB $0a,0,0,0,$40+7 ;run-13
.Fdef_11 EQUB $0b,0,0,0,$40+11 ;run-14
.Fdef_12 EQUB $0c,0,0,0,$40+3 ;run-15
.Fdef_13 EQUB $0d,0,0,0,$c0+3 ;run-16
.Fdef_14 EQUB $0e,0,0,0,$40+7 ;run-17
.Fdef_15 EQUB $0f,9,0,0,$40+3 ;stand
.Fdef_16 EQUB $10,0,0,0,$c0+3 ;standjump-9
.Fdef_17 EQUB $11,0,0,0,$40+4 ;standjump-10
.Fdef_18 EQUB $12,0,0,0,$40+6 ;standjump-11
.Fdef_19 EQUB $13,0,0,0,$40+8 ;standjump-12
.Fdef_20 EQUB $14,0,0,0,$80+9 ;standjump-13
.Fdef_21 EQUB $15,0,0,0,$00+11 ;standjump-14
.Fdef_22 EQUB $16,0,0,0,$80+11 ;standjump-15
.Fdef_23 EQUB $17,0,0,0,$00+17 ;standjump-16
.Fdef_24 EQUB $18,0,0,0,$00+7 ;standjump-17
.Fdef_25 EQUB $19,0,0,0,$00+5 ;standjump-18
.Fdef_26 EQUB $1a,0,0,0,$c0+1 ;standjump-19
.Fdef_27 EQUB $1b,0,0,0,$c0+6 ;standjump-20
.Fdef_28 EQUB $1c,0,0,0,$40+3 ;standjump-21
.Fdef_29 EQUB $1d,0,0,0,$40+8 ;standjump-22
.Fdef_30 EQUB $1e,0,0,0,$40+2 ;standjump-23
.Fdef_31 EQUB $1f,0,0,0,$40+2 ;standjump-24
.Fdef_32 EQUB $20,0,0,0,$c0+2 ;standjump-25
.Fdef_33 EQUB $21,0,0,0,$c0+2 ;standjump-26
.Fdef_34 EQUB $22,0,0,0,$40+3 ;runjump-1
.Fdef_35 EQUB $23,0,0,0,$40+8 ;runjump-2
.Fdef_36 EQUB $24,0,0,0,$c0+14 ;runjump-3
.Fdef_37 EQUB $25,0,0,0,$c0+1 ;runjump-4
.Fdef_38 EQUB $26,0,0,0,$40+5 ;runjump-5
.Fdef_39 EQUB $27,0,0,0,$80+14 ;runjump-6
.Fdef_40 EQUB $28,0,0,0,$00+11 ;runjump-7
.Fdef_41 EQUB $29,0,0,0,$80+11 ;runjump-8
.Fdef_42 EQUB $2a,0,0,0,$80+10 ;runjump-9
.Fdef_43 EQUB $2b,0,0,0,$00+1 ;runjump-10
.Fdef_44 EQUB $2c,0,0,0,$c0+4 ;runjump-11
.Fdef_45 EQUB $2d,0,0,0,$c0+3 ;turn-2
.Fdef_46 EQUB $2e,0,0,0,$c0+3 ;turn-3
.Fdef_47 EQUB $2f,0,0,0,$80+$20+5 ;turn-4
.Fdef_48 EQUB $30,0,0,0,$80+$20+4 ;turn-5
.Fdef_49 EQUB $31,0,0,0,$40+$20+6 ;turn-6
.Fdef_50 EQUB $32,0,4,0,$40+$20+7 ;turn-7
.Fdef_51 EQUB $33,0,3,0,$40+$20+6 ;turn-8
.Fdef_52 EQUB $34,0,1,0,$40+4 ;turn-10
.Fdef_53 EQUB $01,$40,0,0,$c0+2 ;runturn-8
.Fdef_54 EQUB $02,$40,0,0,$40+1 ;runturn-9
.Fdef_55 EQUB $03,$40,0,0,$40+2 ;runturn-10
.Fdef_56 EQUB $04,$40,0,0,$00 ;runturn-11
.Fdef_57 EQUB $05,$40,0,0,$00 ;runturn-12
.Fdef_58 EQUB $06,$40,0,0,$80 ;runturn-13
.Fdef_59 EQUB $07,$40,0,0,$00 ;runturn-14
.Fdef_60 EQUB $08,$40,0,0,$80 ;runturn-15
.Fdef_61 EQUB $09,$40,0,0,$00 ;runturn-16
.Fdef_62 EQUB $0a,$40,0,0,$80 ;runturn-17
.Fdef_63 EQUB $0b,$40,0,0,$00 ;runturn-18
.Fdef_64 EQUB $0c,$40,0,0,$00 ;runturn-19
.Fdef_65 EQUB $0d,$40,0,0,$80 ;runturn-20
.Fdef_66 EQUB 0,0,0,0,0
.Fdef_67 EQUB $11,$40,-2,0,$40+1 ;jumphang-2
.Fdef_68 EQUB $12,$40,-2,0,$40+1 ;jumphang-3
.Fdef_69 EQUB $13,$40,-1,0,$c0+2 ;jumphang-4
.Fdef_70 EQUB $14,$40,-2,0,$40+2 ;jumphang-5
.Fdef_71 EQUB $15,$40,-2,0,$40+1 ;jumphang-6
.Fdef_72 EQUB $16,$40,-2,0,$40+1 ;jumphang-7
.Fdef_73 EQUB $17,$40,-2,0,$40+1 ;jumphang-8
.Fdef_74 EQUB $18,$40,-1,0,$00+7 ;jumphang-9
.Fdef_75 EQUB $19,$40,-1,0,$00+5 ;jumphang-10
.Fdef_76 EQUB $1a,$40,2,0,$00+7 ;jumphang-11
.Fdef_77 EQUB $1b,$40,2,0,$00+7 ;jumphang-12
.Fdef_78 EQUB $1c,$40,2,-3,$00 ;jumphang-13
.Fdef_79 EQUB $1d,$40,2,-10,$00 ;jumphang-14
.Fdef_80 EQUB $1e,$40,2,-11,$80 ;jumphang-15
.Fdef_81 EQUB $1f,$40,3,-2,$40+3 ;hangdrop-4
.Fdef_82 EQUB $20,$40,3,0,$c0+3 ;hangdrop-5
.Fdef_83 EQUB $21,$40,3,0,$c0+3 ;hangdrop-6
.Fdef_84 EQUB $22,$40,3,0,$40+$20+3 ;hangdrop-7
.Fdef_85 EQUB $23,$40,4,0,$c0+$20+3 ;hangdrop-8
.Fdef_86 EQUB $1d,0,0,0,$00  ;test w/foot
.Fdef_87 EQUB $25,$40,7,-14,$80 ;jumphang-22
.Fdef_88 EQUB $26,$40,7,-12,$80 ;jumphang-23
.Fdef_89 EQUB $27,$40,4,-12,$00 ;jumphang-24
.Fdef_90 EQUB $28,$40,3,-10,$80 ;jumphang-25
.Fdef_91 EQUB $29,$40,2,-10,$80 ;jumphang-26
.Fdef_92 EQUB $2a,$40,1,-10,$80 ;jumphang-27
.Fdef_93 EQUB $2b,$40,0,-11,$00 ;jumphang-28
.Fdef_94 EQUB $2c,$40,-1,-12,$00 ;jumphang-29
.Fdef_95 EQUB $2d,$40,-1,-14,$00 ;jumphang-30
.Fdef_96 EQUB $2e,$40,-1,-14,$00 ;jumphang-31
.Fdef_97 EQUB $2f,$40,-1,-15,$80 ;jumphang-32
.Fdef_98 EQUB $30,$40,-1,-15,$80 ;jumphang-33
.Fdef_99 EQUB $31,$40,0,-15,$00 ;jumphang-34
.Fdef_100 EQUB 0,0,0,0,0
.Fdef_101 EQUB 0,0,0,0,0
.Fdef_102 EQUB $32,$40,0,0,$c0+6 ;jumpfall-2
.Fdef_103 EQUB $33,$40,0,0,$40+6 ;jumpfall-3
.Fdef_104 EQUB $34,$40,0,0,$c0+5 ;jumpfall-4
.Fdef_105 EQUB $35,$40,0,0,$40+5 ;jumpfall-5
.Fdef_106 EQUB $36,$40,0,0,$c0+2 ;jumpfall-6
.Fdef_107 EQUB $37,$40,0,0,$c0+4 ;jumpfall-7
.Fdef_108 EQUB $38,$40,0,0,$c0+5 ;jumpfall-8
.Fdef_109 EQUB $39,$40,0,0,$40+6 ;jumpfall-9
.Fdef_110 EQUB $3a,$40,0,0,$40+7 ;jumpfall-10
.Fdef_111 EQUB $3b,$40,0,0,$40+7 ;jumpfall-11
.Fdef_112 EQUB $3c,$40,0,0,$40+9 ;jumpfall-12
.Fdef_113 EQUB $3d,$40,0,0,$c0+8 ;jumpfall-13
.Fdef_114 EQUB $3e,$40,0,0,$c0+9 ;jumpfall-14
.Fdef_115 EQUB $3f,$40,0,0,$40+9 ;jumpfall-15
.Fdef_116 EQUB $40,$40,0,0,$40+5 ;jumpfall-16
.Fdef_117 EQUB $41,$40,2,0,$40+5 ;jumpfall-17
.Fdef_118 EQUB $42,$40,2,0,$c0+5 ;jumpfall-18
.Fdef_119 EQUB $43,$40,0,0,$c0+3 ;jumpfall-19
.Fdef_120 EQUB 0,0,0,0,0
.Fdef_121 EQUB $01,$80,0,0,$40+3 ;stepfwd-1
.Fdef_122 EQUB $02,$80,0,0,$c0+4 ;stepfwd-2
.Fdef_123 EQUB $03,$80,0,0,$c0+5 ;stepfwd-3
.Fdef_124 EQUB $04,$80,0,0,$40+8 ;stepfwd-4
.Fdef_125 EQUB $05,$80,0,0,$40+$20+12 ;stepfwd-5
.Fdef_126 EQUB $06,$80,0,0,$c0+$20+15 ;stepfwd-6
.Fdef_127 EQUB $07,$80,0,0,$40+$20+3 ;stepfwd-7
.Fdef_128 EQUB $08,$80,0,0,$c0+3 ;stepfwd-8
.Fdef_129 EQUB $09,$80,0,0,$40+3 ;stepfwd-9
.Fdef_130 EQUB $0a,$80,0,0,$40+3 ;stepfwd-10
.Fdef_131 EQUB $0b,$80,0,0,$40+4 ;stepfwd-11
.Fdef_132 EQUB $0c,$80,0,0,$40+4 ;stepfwd-12
.Fdef_133 EQUB $3e,$80,00,1,$c0+1 ;sheathe34
.Fdef_134 EQUB $3f,$80,00,1,$c0+7 ;sheathe37
.Fdef_135 EQUB $0d,$80,-5+5,51-63,$00+1 ;climbup-int1
.Fdef_136 EQUB $0e,$80,-5+5,42-63,$00 ;climbup-int2
.Fdef_137 EQUB $0f,$80,-4+5,37-63,$80 ;climbup-8
.Fdef_138 EQUB $10,$80,-1+5,31-63,$80 ;climbup-10
.Fdef_139 EQUB $11,$80,1+5,27-63,$80+1 ;climbup-14
.Fdef_140 EQUB $12,$80,2+5,22-63,$80+2 ;climbup-16
.Fdef_141 EQUB $13,$80,2,17,$40+2 ;climbup-22
.Fdef_142 EQUB $14,$80,4,9,$c0+4 ;climbup-28
.Fdef_143 EQUB $15,$80,4,5,$c0+9 ;climbup-30
.Fdef_144 EQUB $16,$80,4,4,$c0+8 ;climbup-32
.Fdef_145 EQUB $17,$80,5,0,$40+$20+9 ;climbup-34
.Fdef_146 EQUB $18,$80,5,0,$c0+$20+9 ;climbup-35
.Fdef_147 EQUB $19,$80,5,0,$c0+$20+8 ;climbup-36
.Fdef_148 EQUB $1a,$80,5,0,$40+$20+9 ;climbup-37
.Fdef_149 EQUB $1b,$80,5,0,$40+$20+9 ;climbup-38
.Fdef_150 EQUB $8b,16,0,2,$80 ;missed block
.Fdef_151 EQUB $81,26,0,2,$80
.Fdef_152 EQUB $82,18,3,2,$00 ;guy4/rob20
.Fdef_153 EQUB $83,22,7,2,$c0+4
.Fdef_154 EQUB $84,21,10,2,$00 ;full ext.
.Fdef_155 EQUB $85,23,7,2,$80 ;guy-7
.Fdef_156 EQUB $86,25,4,2,$80 ;guy-8
.Fdef_157 EQUB $87,24,0,2,$c0+14 ;guy-9
.Fdef_158 EQUB $88,15,0,2,$c0+13 ;guy10/rob15 (ready)
.Fdef_159 EQUB $89,20,3,2,$00 ;guy19/rob22
.Fdef_160 EQUB $8a,31,3,2,$00 ;guy20/rob23
.Fdef_161 EQUB $8b,16,0,2,$80 ;guy21/rob18 (blocking)
.Fdef_162 EQUB $8c,17,0,2,$80 ;guy22/rob19 (block-to-strike)
.Fdef_163 EQUB $8d,32,0,2,$00 ;guy-31 (advance)
.Fdef_164 EQUB $8e,33,0,2,$80 ;guy-32
.Fdef_165 EQUB $8f,34,2,2,$c0+3 ;guy-33
.Fdef_166 EQUB $0f,0,0,0,$40+3 ;stand
.Fdef_167 EQUB $91,19,7,2,$80 ;guy18/rob21 (blocked)
.Fdef_168 EQUB $92,14,1,2,$80 ;pre-strike
.Fdef_169 EQUB $93,27,0,2,$80 ;rob17 (begin block)
.Fdef_170 EQUB $88,15,0,2,$c0+13 ;guy10/rob15 (ready)
.Fdef_171 EQUB $88,15,0,2,$c0+13 ;guy10/rob15 (ready)
.Fdef_172 EQUB $32,$40+43,0,0,$c0+6 ;jumpfall-2
.Fdef_173 EQUB $33,$40+44,0,0,$40+6 ;jumpfall-3
.Fdef_174 EQUB $34,$40+45,0,0,$c0+5 ;jumpfall-4
.Fdef_175 EQUB $35,$40+46,0,0,$40+5 ;jumpfall-5
.Fdef_176 EQUB $34,$40,0,0,$c0+5
.Fdef_177 EQUB $0f,$40,0,3,$80+10 ;impaled
.Fdef_178 EQUB $0e,$40,4,3,$80+7 ;halves
.Fdef_179 EQUB $a8,0,0,1,$40+4 ;collapse15
.Fdef_180 EQUB $a9,0,0,1,$40+4 ;collapse16
.Fdef_181 EQUB $aa,0,0,1,$40+4 ;collapse17
.Fdef_182 EQUB $ab,0,0,1,$40+7 ;collapse18
.Fdef_183 EQUB $ac,0,0,7,$40+11 ;collapse19
.Fdef_184 EQUB 0,0,0,0,0
.Fdef_185 EQUB $10,$40,4,7,$40+9 ;dead
.Fdef_186 EQUB $44,$40,0,0,$40+4 ;mouse-1
.Fdef_187 EQUB $45,$40,0,0,$40+4 ;mouse-2
.Fdef_188 EQUB $46,$40,0,2,$40+4 ;mouse crouch
.Fdef_189 EQUB 0,0,0,0,0
.Fdef_190 EQUB 0,0,0,0,0
.Fdef_191 EQUB $94,0,0,0,$00 ;drink4
.Fdef_192 EQUB $95,0,0,1,$00 ;drink5
.Fdef_193 EQUB $96,0,0,0,$80 ;drink6
.Fdef_194 EQUB $97,0,0,0,$00 ;drink7
.Fdef_195 EQUB $98,0,-1,0,$00 ;drink8
.Fdef_196 EQUB $99,0,-1,0,$00 ;drink9
.Fdef_197 EQUB $9a,0,-1,0,$00 ;drink10
.Fdef_198 EQUB $9b,0,-4,0,$00 ;drink11
.Fdef_199 EQUB $9c,0,-4,0,$80 ;drink12
.Fdef_200 EQUB $9d,0,-4,0,$00 ;drink13
.Fdef_201 EQUB $9e,0,-4,0,$00 ;drink14
.Fdef_202 EQUB $9f,0,-4,0,$00 ;drink15
.Fdef_203 EQUB $a0,0,-4,0,$00 ;drink16
.Fdef_204 EQUB $a1,0,-5,0,$00 ;drink17
.Fdef_205 EQUB $a2,0,-5,0,$00 ;drink18
.Fdef_206 EQUB $a3,0,0,0,0 ;unused
.Fdef_207 EQUB $a4,0,0,1,$40+6 ;draw5
.Fdef_208 EQUB $a5,0,0,1,$c0+6 ;draw6
.Fdef_209 EQUB $a6,0,0,1,$c0+8 ;draw7
.Fdef_210 EQUB $a7,0,0,1,$40+10 ;draw8
.Fdef_211 EQUB 0,0,0,0,$00
.Fdef_212 EQUB 0,0,0,0,$00
.Fdef_213 EQUB 0,0,0,0,$00
.Fdef_214 EQUB 0,0,0,0,$00
.Fdef_215 EQUB 0,0,0,0,$00
.Fdef_216 EQUB 0,0,0,0,$00
.Fdef_217 EQUB $35,0,0,0,$80 ;climbst2
.Fdef_218 EQUB $36,0,0,0,$00 ;climbst3
.Fdef_219 EQUB $37,0,0,0,$00 ;climbst4
.Fdef_220 EQUB $38,0,0,0,$00 ;climbst5
.Fdef_221 EQUB $39,0,0,0,$80 ;climbst6
.Fdef_222 EQUB $3a,0,0,0,$00 ;climbst7
.Fdef_223 EQUB $3b,0,0,0,$00 ;climbst8
.Fdef_224 EQUB $3c,0,0,0,$00 ;climbst9
.Fdef_225 EQUB $3d,0,0,0,$80 ;climbst10
.Fdef_226 EQUB $3e,0,0,0,$00 ;climbst11
.Fdef_227 EQUB $3f,0,0,0,$80 ;climbst12
.Fdef_228 EQUB $40,0,0,0,$00 ;climbst13
.Fdef_229 EQUB $32,$80+35,1,1,$c0+3 ;sheathe22
.Fdef_230 EQUB $33,$80+36,0,1,$40+9 ;sheathe23
.Fdef_231 EQUB $34,$80+37,0,1,$c0+3 ;sheathe24
.Fdef_232 EQUB $35,$80+38,0,1,$40+9 ;sheathe25
.Fdef_233 EQUB $36,$80+39,0,1,$c0+3 ;sheathe26
.Fdef_234 EQUB $37,$80+40,1,1,$40+9 ;sheathe27
.Fdef_235 EQUB $38,$80+41,1,1,$40+3 ;sheathe28
.Fdef_236 EQUB $39,$80+42,1,1,$c0+9 ;sheathe29
.Fdef_237 EQUB $3a,$80,4,1,$c0+6 ;sheathe30
.Fdef_238 EQUB $3b,$80,3,1,$c0+10 ;sheathe31
.Fdef_239 EQUB $3c,$80,1,1,$40+3 ;sheathe32
.Fdef_240 EQUB $3d,$80,1,1,$c0+8 ;sheathe33 (-->133)

\*-------------------------------
\*
\*  Alternate character set 1 (chtable4)
\*
\*  200 bytes allocated -- 40 frames (150-189)
\*
\*  Frame def list shows kid, sword in RIGHT hand
\*  Altset1 shows enemy, sword in LEFT hand (to be mirrored)
\*  (Image tables always show character facing LEFT)
\*
\*-------------------------------
\ ds altset1-*

.altset1

.ALTSET1_150 EQUB $0b,$c0+13,2,1,$00 ;missed block
.ALTSET1_151 EQUB $01,$c0+1,3,1,$00 ;guy-3
.ALTSET1_152 EQUB $02,$c0+2,4,1,$00 ;guy-4
.ALTSET1_153 EQUB $03,$c0+3,7,1,$40+4 ;guy-5
.ALTSET1_154 EQUB $04,$c0+4,10,1,$00 ;guy-6 (full ext)
.ALTSET1_155 EQUB $05,$c0+5,7,1,$80 ;guy-7
.ALTSET1_156 EQUB $06,$c0+6,4,1,$80 ;guy-8
.ALTSET1_157 EQUB $07,$c0+7,0,1,$80 ;guy-9
.ALTSET1_158 EQUB $08,$c0+8,0,1,$c0+13 ;guy-10 (ready)
.ALTSET1_159 EQUB $09,$c0+11,7,1,$80 ;guy-19
.ALTSET1_160 EQUB $0a,$c0+12,3,1,$00 ;guy-20
.ALTSET1_161 EQUB $0b,$c0+13,2,1,$00 ;guy-21 (blocking)
.ALTSET1_162 EQUB $0c,$c0,2,1,$00 ;guy-22
.ALTSET1_163 EQUB $0d,$c0+28,0,1,$00 ;guy-31 (advance)
.ALTSET1_164 EQUB $0e,$c0+29,0,1,$80 ;guy-32
.ALTSET1_165 EQUB $0f,$c0+30,2,1,$c0+3 ;guy-33
.ALTSET1_166 EQUB $10,$c0+9,-1,1,$40+8 ;alertstand
.ALTSET1_167 EQUB $11,$c0+10,7,1,$80 ;guy-18 (blocked)
.ALTSET1_168 EQUB $12,$c0+14,3,1,$80 ;guy-15
.ALTSET1_169 EQUB $08,$c0+8,0,1,$80 ;?? (ready-->block)
.ALTSET1_170 EQUB $13,$c0+8,0,1,$c0+13 ;guy-11/12 (ready)
.ALTSET1_171 EQUB $14,$c0+8,0,1,$c0+13 ;guy-13/14 (ready)
.ALTSET1_172 EQUB $15,$c0+47,0,0,$c0+6 ;jumpfall-2 (stabbed)
.ALTSET1_173 EQUB $16,$c0+48,0,0,$40+6 ;jumpfall-3
.ALTSET1_174 EQUB $17,$c0+49,0,0,$c0+5 ;jumpfall-4
.ALTSET1_175 EQUB $17,$c0+49,0,0,$c0+5 ;for jumpfall-5
.ALTSET1_176 EQUB $17,$c0+49,0,0,$c0+5 ;for jumpfall-6
.ALTSET1_177 EQUB $19,$c0,0,3,$80+10 ;impaled
.ALTSET1_178 EQUB $1a,$c0,4,4,$80+7 ;halves
.ALTSET1_179 EQUB $1b,$c0,-2,1,$40+4 ;collapse15
.ALTSET1_180 EQUB $1c,$c0,-2,1,$40+4 ;collapse16
.ALTSET1_181 EQUB $1d,$c0,-2,1,$40+4 ;collapse17
.ALTSET1_182 EQUB $1e,$c0,-2,2,$40+7 ;collapse18
.ALTSET1_183 EQUB $1f,$c0,-2,2,$40+10 ;collapse19
.ALTSET1_184 EQUB 0,0,0,0,0
.ALTSET1_185 EQUB $20,$c0,3,4,$c0+9 ;dead
.ALTSET1_186 EQUB 0,0,0,0,0
.ALTSET1_187 EQUB 0,0,0,0,0
.ALTSET1_188 EQUB 0,0,0,0,0
.ALTSET1_189 EQUB 0,0,0,0,0

\*-------------------------------
\*
\*  Alternate character set 2 (chtable6)
\*
\*  (450 bytes allocated -- 90 frames)
\*
\*-------------------------------
\ ds altset2-*

.altset2

.ALTSET2_1 EQUB $8a,$40,0,0,$00 ;pslump-1
.ALTSET2_2 EQUB $9a,$40,0,0,$80 ;pturn-4
.ALTSET2_3 EQUB $9b,$40,0,0,$80 ;pturn-5
.ALTSET2_4 EQUB $9c,$40,0,0,$80 ;pturn-6
.ALTSET2_5 EQUB $9d,$40,-1,0,$00 ;pturn-7
.ALTSET2_6 EQUB $9e,$40,2,0,$80 ;pturn-8
.ALTSET2_7 EQUB $9f,$40,2,0,$00 ;pturn-9
.ALTSET2_8 EQUB $a0,$40,0,0,$80 ;pturn-10
.ALTSET2_9 EQUB $a1,$40,1,0,$80 ;pturn-11
.ALTSET2_10 EQUB $a2,$40,2,0,$80 ;unused
.ALTSET2_11 EQUB $99,$40,0,0,$80 ;pturn-15 (stand)
.ALTSET2_12 EQUB $a3,$40,0,0,$80 ;pback-3
.ALTSET2_13 EQUB $a4,$40,0,0,$00 ;pback-5
.ALTSET2_14 EQUB $a5,$40,0,0,$80 ;pback-7
.ALTSET2_15 EQUB $a6,$40,0,0,$80 ;pback-9
.ALTSET2_16 EQUB $a7,$40,0,0,$80 ;pback-11
.ALTSET2_17 EQUB $a8,$40,0,0,$00 ;pback-13 (stand)
.ALTSET2_18 EQUB $8b,$40,0,0,$00 ;pslump-1
.ALTSET2_19 EQUB $a9,$40,0,0,$00 ;plie
.ALTSET2_20 EQUB $ad,$40,0,0,$00 ;embrace-1
.ALTSET2_21 EQUB $ae,$40,0,0,$00 ;embrace-2
.ALTSET2_22 EQUB $af,$40,0,0,$80 ;embrace-3
.ALTSET2_23 EQUB $b0,$40,0,0,$00 ;embrace-4
.ALTSET2_24 EQUB $b1,$40,0,0,$80 ;embrace-5
.ALTSET2_25 EQUB $b2,$40,0,0,$80 ;embrace-6
.ALTSET2_26 EQUB $b3,$40,0,0,$00 ;embrace-7
.ALTSET2_27 EQUB $b4,$40,0,0,$00 ;embrace-8
.ALTSET2_28 EQUB $b5,$40,0,0,$00 ;embrace-9
.ALTSET2_29 EQUB $b6,$40,0,0,$00 ;embrace-10
.ALTSET2_30 EQUB $b7,$40,0,0,$00 ;embrace-11
.ALTSET2_31 EQUB $b8,$40,0,0,$00 ;embrace-12
.ALTSET2_32 EQUB $b9,$40,0,0,$00 ;embrace-13
.ALTSET2_33 EQUB $ba,$40,0,0,$00 ;embrace-14
.ALTSET2_34 EQUB $bb,$40,0,0,$00 ;prise-1
.ALTSET2_35 EQUB $bc,$40,0,0,$00 ;prise-2
.ALTSET2_36 EQUB $bd,$40,0,0,$00 ;prise-3
.ALTSET2_37 EQUB $be,$40,0,0,$00 ;prise-4
.ALTSET2_38 EQUB $bf,$40,0,0,$80 ;prise-5
.ALTSET2_39 EQUB $bf,$40,0,0,$80 ;prise-6
.ALTSET2_40 EQUB $c1,$40,1,0,$00 ;prise-7
.ALTSET2_41 EQUB $c2,$40,-1,0,$00 ;prise-8
.ALTSET2_42 EQUB $c3,$40,2,0,$00 ;prise-9
.ALTSET2_43 EQUB $c4,$40,1,0,$80 ;prise-10
.ALTSET2_44 EQUB $c5,$40,0,0,$80 ;prise-11
.ALTSET2_45 EQUB $c6,$40,0,0,$80 ;prise-12
.ALTSET2_46 EQUB $c7,$40,0,0,$80 ;prise-13
.ALTSET2_47 EQUB $c8,$40,-1,0,$00 ;prise-14
.ALTSET2_48 EQUB $ca,$40,0,0,$80 ;vwalk-8
.ALTSET2_49 EQUB $cb,$40,0,0,$80 ;vwalk-9
.ALTSET2_50 EQUB $cc,$40,0,0,$80 ;vwalk-10
.ALTSET2_51 EQUB $cd,$40,0,0,$00 ;vwalk-11
.ALTSET2_52 EQUB $ce,$40,0,0,$00 ;vwalk-12
.ALTSET2_53 EQUB $cf,$40,0,0,$80 ;vwalk-13
.ALTSET2_54 EQUB $d0,$40,0,0,$80 ;vstand-3
.ALTSET2_55 EQUB $d1,$40,0,0,$80 ;vstand-2
.ALTSET2_56 EQUB $d2,$40,0,0,$80 ;vstand-1
.ALTSET2_57 EQUB $d3,$40,0,0,$80 ;vturn-5
.ALTSET2_58 EQUB $d4,$40,0,0,$80 ;vturn-6
.ALTSET2_59 EQUB $d5,$40,0,0,$80 ;vturn-7
.ALTSET2_60 EQUB $d6,$40,0,0,$80 ;vturn-8
.ALTSET2_61 EQUB $d7,$40,0,0,$00 ;vturn-9
.ALTSET2_62 EQUB $d8,$40,0,0,$80 ;vturn-10
.ALTSET2_63 EQUB $d9,$40,0,0,$00 ;vturn-11
.ALTSET2_64 EQUB $da,$40,0,0,$00 ;vturn-12
.ALTSET2_65 EQUB $db,$40,0,0,$80 ;vturn-13
.ALTSET2_66 EQUB $dc,$40,0,0,$00 ;vturn-14
.ALTSET2_67 EQUB $dd,$40,3,0,$00 ;vcast-2
.ALTSET2_68 EQUB $de,$40,3,0,$00 ;vcast-3
.ALTSET2_69 EQUB $df,$40,3,0,$00 ;vcast-4
.ALTSET2_70 EQUB $e0,$40,2,0,$00 ;vcast-5
.ALTSET2_71 EQUB $e1,$40,3,0,$80 ;vcast-6
.ALTSET2_72 EQUB $e2,$40,5,0,$00 ;vcast-7
.ALTSET2_73 EQUB $e3,$40,5,0,$00 ;vcast-8
.ALTSET2_74 EQUB $e4,$40,1,0,$80 ;vcast-9
.ALTSET2_75 EQUB $e5,$40,2,0,$80 ;vcast-10
.ALTSET2_76 EQUB $e6,$40,2,0,$80 ;vcast-11 (held)
.ALTSET2_77 EQUB $e7,$40,1,0,$80 ;vcast-13
.ALTSET2_78 EQUB $81,$80,1,0,$00 ;vcast-14
.ALTSET2_79 EQUB $82,$80,2,0,$00 ;vcast-15
.ALTSET2_80 EQUB $83,$80,3,0,$00 ;vcast-16
.ALTSET2_81 EQUB $84,$80,3,0,$00 ;vcast-17
.ALTSET2_82 EQUB $85,$80,0,0,$80 ;vcast-18
.ALTSET2_83 EQUB $86,$80,2,0,$80 ;vcast-10a
.ALTSET2_84 EQUB $87,$80,2,0,$80 ;vcast-10b
.ALTSET2_85 EQUB $88,$80,1,0,$00 ;vcast-1


\*-------------------------------
\*
\*  S W O R D   T A B L E
\*
\*  (192 bytes allocated -- 64 swords)
\*
\*  Sword images are taken from chtable3
\*
\*-------------------------------
\ ds swordtab-*

.swordtab

\* (Image, DX, DY)

.SWORDTAB_1 EQUB $1d,0,-9
.SWORDTAB_2 EQUB $22,-9,-29
.SWORDTAB_3 EQUB $1e,7,-25
.SWORDTAB_4 EQUB $1f,17,-26
.SWORDTAB_5 EQUB $23,7,-14
.SWORDTAB_6 EQUB $24,0,-5
.SWORDTAB_7 EQUB $20,17,-16
.SWORDTAB_8 EQUB $21,16,-19
.SWORDTAB_9 EQUB $4b,12,-9 ;alertstand
.SWORDTAB_10 EQUB $26,13,-34
.SWORDTAB_11 EQUB $27,7,-25
.SWORDTAB_12 EQUB $28,10,-16
.SWORDTAB_13 EQUB $29,10,-11
.SWORDTAB_14 EQUB $2a,22,-21
.SWORDTAB_15 EQUB $2b,28,-23
.SWORDTAB_16 EQUB $2c,13,-35
.SWORDTAB_17 EQUB $2d,0,-38
.SWORDTAB_18 EQUB $2e,0,-29
.SWORDTAB_19 EQUB $2f,21,-19
.SWORDTAB_20 EQUB $30,14,-23
.SWORDTAB_21 EQUB $31,21,-22
.SWORDTAB_22 EQUB $31,22,-23
.SWORDTAB_23 EQUB $2f,7,-13
.SWORDTAB_24 EQUB $2f,15,-18 ;$20,17,-19 for flash
.SWORDTAB_25 EQUB $24,0,-8
.SWORDTAB_26 EQUB $1e,7,-27
.SWORDTAB_27 EQUB $48,14,-28
.SWORDTAB_28 EQUB $26,7,-27
.SWORDTAB_29 EQUB $21,6,-23
.SWORDTAB_30 EQUB $21,9,-21
.SWORDTAB_31 EQUB $28,11,-18
.SWORDTAB_32 EQUB $2b,24,-23
.SWORDTAB_33 EQUB $2b,19,-23
.SWORDTAB_34 EQUB $2b,21,-23
;sheathing
.SWORDTAB_35 EQUB $40,7,-32
.SWORDTAB_36 EQUB $41,14,-32
.SWORDTAB_37 EQUB $42,14,-31
.SWORDTAB_38 EQUB $43,14,-29
.SWORDTAB_39 EQUB $44,28,-28
.SWORDTAB_40 EQUB $45,28,-28
.SWORDTAB_41 EQUB $46,21,-25
.SWORDTAB_42 EQUB $47,14,-22

.SWORDTAB_43 EQUB 0,14,-25 ;43-46: kid stabbed
.SWORDTAB_44 EQUB 0,21,-25
.SWORDTAB_45 EQUB $4a,0,-16
.SWORDTAB_46 EQUB $26,8,-37
.SWORDTAB_47 EQUB $4c,14,-24 ;47-50: enemy stabbed
.SWORDTAB_48 EQUB $4d,14,-24
.SWORDTAB_49 EQUB $4e,7,-14
.SWORDTAB_50 EQUB $26,8,-37

\*-------------------------------
\ lst
\ ds 1
\ usr $a9,15,$00,*-org
\ lst off
