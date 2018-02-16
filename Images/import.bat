@echo off
REM FOR %%F in (IMG.CHTAB*.bin) DO ..\pop2beeb\pop2beeb -i %%F -o BEEB.%%F -b %%F.mode5.png -pal 0

REM ..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -o BEEB.IMG.BGTAB1.DUN.bin -b IMG.BGTAB1.DUN.bin.john.png -pal 0
..\pop2beeb\pop2beeb -i IMG.BGTAB2.DUN.bin -o BEEB.IMG.BGTAB2.DUN.bin -b IMG.BGTAB2.DUN.bin.john.png

..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -s 1 -e 87 -o BEEB.IMG.BGTAB1.DUNA.bin -b IMG.BGTAB1.DUN.bin.john.png
..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -s 88 -e 111 -o BEEB.IMG.BGTAB1.DUNB.bin -b IMG.BGTAB1.DUN.bin.john.png

REM ..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -o BEEB.IMG.BGTAB1.PAL.bin -b IMG.BGTAB1.PAL.bin.mode5.png -pal 0
..\pop2beeb\pop2beeb -i IMG.BGTAB2.PAL.bin -o BEEB.IMG.BGTAB2.PAL.bin -b IMG.BGTAB2.PAL.bin.john.png

..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -s 1 -e 87 -o BEEB.IMG.BGTAB1.PALA.bin -b IMG.BGTAB1.PAL.bin.john.png
..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -s 88 -e 111 -o BEEB.IMG.BGTAB1.PALB.bin -b IMG.BGTAB1.PAL.bin.john.png

REM ..\pop2beeb\pop2beeb -i IMG.CHTAB1.bin -halfv -o BEEB.IMG.CHTAB1.HALF.bin -b IMG.CHTAB1.bin.mode5.half.png -pal 0
REM ..\pop2beeb\pop2beeb -i IMG.CHTAB2.bin -halfv -o BEEB.IMG.CHTAB2.HALF.bin -b IMG.CHTAB2.bin.mode5.half.png -pal 0
REM ..\pop2beeb\pop2beeb -i IMG.CHTAB3.bin -halfv -o BEEB.IMG.CHTAB3.HALF.bin -b IMG.CHTAB3.bin.mode5.half.png -pal 0
REM ..\pop2beeb\pop2beeb -i IMG.CHTAB5.bin -halfv -o BEEB.IMG.CHTAB5.HALF.bin -b IMG.CHTAB5.bin.mode5.half.png -pal 0

..\pop2beeb\pop2beeb -i IMG.CHTAB7.bin -o BEEB.IMG.CHTAB7.mode2.bin -b IMG.CHTAB7.bin.mode2.png -mode 2
..\pop2beeb\pop2beeb -i IMG.CHTAB6.A.bin -s 1 -e 73 -o BEEB.IMG.CHTAB8.mode2.bin -b IMG.CHTAB6.A.bin.mode2.png -mode 2
..\pop2beeb\pop2beeb -i IMG.CHTAB6.A.bin -s 74 -e 103 -o BEEB.IMG.CHTAB9.mode2.bin -b IMG.CHTAB6.A.bin.mode2.png -mode 2
..\pop2beeb\pop2beeb -i IMG.CHTAB6.B.bin -o BEEB.IMG.CHTAB6.mode2.bin -b IMG.CHTAB6.B.bin.mode2.png -mode 2
