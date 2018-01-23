@echo off
FOR %%F in (IMG.CHTAB*.bin) DO ..\pop2beeb\pop2beeb -i %%F -o BEEB.%%F -b %%F.mode5.png -pal 0

..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -o BEEB.IMG.BGTAB1.DUN.bin -b IMG.BGTAB1.DUN.bin.mode5.png -pal 0
..\pop2beeb\pop2beeb -i IMG.BGTAB2.DUN.bin -o BEEB.IMG.BGTAB2.DUN.bin -b IMG.BGTAB2.DUN.bin.mode5.png -pal 0

..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -s 1 -e 87 -o BEEB.IMG.BGTAB1.DUNA.bin -b IMG.BGTAB1.DUN.bin.mode5.png -pal 0
..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -s 88 -e 111 -o BEEB.IMG.BGTAB1.DUNB.bin -b IMG.BGTAB1.DUN.bin.mode5.png -pal 0

..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -o BEEB.IMG.BGTAB1.PAL.bin -b IMG.BGTAB1.PAL.bin.mode5.png -pal 0
..\pop2beeb\pop2beeb -i IMG.BGTAB2.PAL.bin -o BEEB.IMG.BGTAB2.PAL.bin -b IMG.BGTAB2.PAL.bin.mode5.png -pal 0

..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -s 1 -e 87 -o BEEB.IMG.BGTAB1.PALA.bin -b IMG.BGTAB1.PAL.bin.mode5.png -pal 0
..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -s 88 -e 111 -o BEEB.IMG.BGTAB1.PALB.bin -b IMG.BGTAB1.PAL.bin.mode5.png -pal 0

..\pop2beeb\pop2beeb -i IMG.CHTAB1.bin -halfv -o BEEB.IMG.CHTAB1.HALF.bin -b IMG.CHTAB1.bin.mode5.half.png -pal 0
..\pop2beeb\pop2beeb -i IMG.CHTAB2.bin -halfv -o BEEB.IMG.CHTAB2.HALF.bin -b IMG.CHTAB2.bin.mode5.half.png -pal 0
..\pop2beeb\pop2beeb -i IMG.CHTAB3.bin -halfv -o BEEB.IMG.CHTAB3.HALF.bin -b IMG.CHTAB3.bin.mode5.half.png -pal 0
..\pop2beeb\pop2beeb -i IMG.CHTAB5.bin -halfv -o BEEB.IMG.CHTAB5.HALF.bin -b IMG.CHTAB5.bin.mode5.half.png -pal 0
