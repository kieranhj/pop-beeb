; tables.asm
; Originally TABLES.S
; All precalculated tables

_DIV7_TABLES = TRUE                ; use tables (faster) or loop (smaller) to DIV & MOD by 7

.tables
\org = $e00
\ tr on
\ lst off
\*-------------------------------
\*
\*  PRINCE OF PERSIA
\*  Copyright 1989 Jordan Mechner
\*
\*-------------------------------

\*-------------------------------
\ org org
\*-------------------------------
\ScrnLeft = 58
\ScrnTop = 0
ScrnBot = 191

tables_VertDist = 10 ;from bottom of block to center plane
BlockHeight = 63
DHeight = 3 ;floorpiece thickness

Blox1 = BlockHeight
Blox2 = 2*BlockHeight
Blox3 = 3*BlockHeight
Blox4 = 4*BlockHeight

\*-------------------------------
; Move PAGE aligned tables to start!
\*-------------------------------

PAGE_ALIGN

\*-------------------------------
\* ByteTable
\*
\* Index:  Real screen X-coord (0-255)
\* Yields: Byte # (0-36)
\*-------------------------------

IF _DIV7_TABLES
.ByteTable
FOR n,0,35,1
EQUB n,n,n,n,n,n,n
NEXT
EQUB 36,36,36,36
ENDIF

\*-------------------------------
\* OffsetTable
\*
\* Index:  Same as ByteTable
\* Yields: Offset (0-6)
\*-------------------------------

IF _DIV7_TABLES
.OffsetTable
FOR n,1,36,1
EQUB 0,1,2,3,4,5,6
NEXT
EQUB 0,1,2,3
ENDIF

\*-------------------------------
\* BlockTable
\*
\* Index:  Screen X-coord (0 to 255)
\* Yields: Block # (-5 to 14)
\*-------------------------------

.BlockTable
EQUB LO(-5),LO(-5)
FOR n,1,18,1
byte = -5 + n
EQUB LO(byte),LO(byte),LO(byte),LO(byte),LO(byte),LO(byte),LO(byte)
EQUB LO(byte),LO(byte),LO(byte),LO(byte),LO(byte),LO(byte),LO(byte)
NEXT
EQUB 14,14

\*-------------------------------
\* PixelTable
\*
\* Index:  Same as BlockTable
\* Yields: Pixel # within block (0 to 13)
\*-------------------------------

.PixelTable
EQUB 12,13
FOR n,1,18,1
EQUB 0,1,2,3,4,5,6,7,8,9,10,11,12,13
NEXT
EQUB 0,1

\*-------------------------------
\* BlockEdge
\*
\* Index:  Block X (-5 to 14) + 5
\* Yields: Screen X-coord of left edge of block
\*-------------------------------

.BlockEdge
FOR n,0,19,1
EQUB LO(-12 + n * 14)
NEXT

\*-------------------------------
\* BlockTop, BlockBot, FloorY
\*
\* Index:  Block Y (-1 to 3) + 1

 .BlockTop

 EQUB ScrnBot+1-Blox4
 EQUB ScrnBot+1-Blox3
 EQUB ScrnBot+1-Blox2
 EQUB ScrnBot+1-Blox1
 EQUB ScrnBot+1

\*-------------------------------
 .BlockBot

 EQUB ScrnBot-Blox3
 EQUB ScrnBot-Blox2
 EQUB ScrnBot-Blox1
 EQUB ScrnBot
 EQUB ScrnBot+Blox1

\*-------------------------------
 .FloorY

 EQUB ScrnBot-Blox3-tables_VertDist
 EQUB ScrnBot-Blox2-tables_VertDist
 EQUB ScrnBot-Blox1-tables_VertDist
 EQUB ScrnBot-tables_VertDist
 EQUB ScrnBot+Blox1-tables_VertDist

\*-------------------------------
 .BlockAy

 EQUB ScrnBot-Blox3-DHeight
 EQUB ScrnBot-Blox2-DHeight
 EQUB ScrnBot-Blox1-DHeight
 EQUB ScrnBot-DHeight
 EQUB ScrnBot+Blox1-DHeight

\*-------------------------------
\ lst
\eof ds 1
\ usr $a9,3,$000,*-org
\ lst off

\*-------------------------------
\* Multiplication Tables
\*
\*-------------------------------

\*-------------------------------
\* Mult10
\*-------------------------------
.Mult10
FOR n,0,15,1
EQUB n * 10
NEXT

\*-------------------------------
\* Mult7
\*-------------------------------
.Mult7
FOR n,0,15,1
EQUB n * 7
NEXT

\*-------------------------------
\* Mult30
\*-------------------------------
.Mult30
FOR n,0,31,1
EQUW n * 30
NEXT

\*-------------------------------
; Mult16 LO byte
\*-------------------------------
.Mult16_LO
FOR n,0,39,1
EQUB LO(n*16)
NEXT

\*-------------------------------
; Mult16 HI byte
\*-------------------------------
.Mult16_HI          ; or shift...
FOR n,0,39,1
EQUB HI(n*16)
NEXT

\*-------------------------------
; Hmm, these multiplication tables include all Mult16 entries.. combine?
\*-------------------------------
.Mult8_LO
FOR n,0,79,1
EQUB LO(n*8)
NEXT

.Mult8_HI
FOR n,0,79,1
EQUB HI(n*8)
NEXT
