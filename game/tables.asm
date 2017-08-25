; tables.asm
; Originally TABLES.S
; All precalculated tables

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

\ dum org

IF _TODO
ByteTable ds $100
OffsetTable ds $100
BlockTable ds $100
PixelTable ds $100
\Mult10 ds $10
\Mult7 ds $10
\Mult30 ds $40

BlockEdge ds 20
BlockTop ds 5
BlockBot skip 5
FloorY ds 5
BlockAy ds 5

 dend
ENDIF

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

IF _TODO
*-------------------------------
* ByteTable
*
* Index:  Real screen X-coord (0-255)
* Yields: Byte # (0-36)
*-------------------------------

 ds ByteTable-*

]byte = 0
 lup 36
 db ]byte,]byte,]byte,]byte,]byte,]byte,]byte
]byte = ]byte+1
 --^
 db 36,36,36,36

*-------------------------------
* OffsetTable
*
* Index:  Same as ByteTable
* Yields: Offset (0-6)
*-------------------------------
 ds OffsetTable-*

 lup 36
 db 0,1,2,3,4,5,6
 --^
 db 0,1,2,3

*-------------------------------
* BlockTable
*
* Index:  Screen X-coord (0 to 255)
* Yields: Block # (-5 to 14)
*-------------------------------
 ds BlockTable-*

]byte = -5
 db ]byte,]byte

 lup 18
]byte = ]byte+1
 db ]byte,]byte,]byte,]byte,]byte,]byte,]byte
 db ]byte,]byte,]byte,]byte,]byte,]byte,]byte
 --^

]byte = ]byte+1
 db ]byte,]byte

*-------------------------------
* PixelTable
*
* Index:  Same as BlockTable
* Yields: Pixel # within block (0 to 13)
*-------------------------------
 ds PixelTable-*

 db 12,13

 lup 18
 db 0,1,2,3,4,5,6,7,8,9,10,11,12,13
 --^

 db 0,1
ENDIF

\*-------------------------------
\* Mult10
\*-------------------------------
\ ds Mult10-*
\
\]byte = 0
\ lup 16
\ db ]byte
\]byte = ]byte+10
\ --^
.Mult10
FOR n,0,15,1
EQUB n * 10
NEXT

\*-------------------------------
\* Mult7
\*-------------------------------
\ ds Mult7-*
\
\]byte = 0
\ lup 16
\ db ]byte
\]byte = ]byte+7
\ --^
.Mult7
FOR n,0,15,1
EQUB n * 7
NEXT

\*-------------------------------
\* Mult30
\*-------------------------------
\ ds Mult30-*
\
\]word = 0
\ lup 32
\ dw ]word
\]word = ]word+30
\ --^
.Mult30
FOR n,0,31,1
EQUW n * 30
NEXT

\*-------------------------------
\* BlockEdge
\*
\* Index:  Block X (-5 to 14) + 5
\* Yields: Screen X-coord of left edge of block
\*-------------------------------
\ ds BlockEdge-*
\
\]byte = -12
\ lup 20
\ db ]byte
\]byte = ]byte+14
\ --^
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
