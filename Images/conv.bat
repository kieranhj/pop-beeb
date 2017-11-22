@echo off
FOR %%F in (IMG.CHTAB*.bin) DO ..\pop2beeb\pop2beeb -i %%F -o BEEB.%%F -mode 5

FOR %%F in (IMG.BGTAB*.bin) DO ..\pop2beeb\pop2beeb -i %%F -o BEEB.%%F -mode 5 -point 0

..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -s 1 -e 9 -o BEEB.IMG.BGTAB1.DUNA.bin -mode 5 -point 0
..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -s 10 -e 22 -o BEEB.IMG.BGTAB1.DUNB.bin -mode 5 -point 0
..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -s 23 -e 111 -o BEEB.IMG.BGTAB1.DUNC.bin -mode 5 -point 0

..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -s 1 -e 9 -o BEEB.IMG.BGTAB1.PALA.bin -mode 5 -point 0
..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -s 10 -e 22 -o BEEB.IMG.BGTAB1.PALB.bin -mode 5 -point 0
..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -s 23 -e 111 -o BEEB.IMG.BGTAB1.PALC.bin -mode 5 -point 0

..\pop2beeb\pop2beeb -i IMG.CHTAB1.bin -halfv -o BEEB.IMG.CHTAB1.HALF.bin -mode 5
..\pop2beeb\pop2beeb -i IMG.CHTAB2.bin -halfv -o BEEB.IMG.CHTAB2.HALF.bin -mode 5
..\pop2beeb\pop2beeb -i IMG.CHTAB3.bin -halfv -o BEEB.IMG.CHTAB3.HALF.bin -mode 5
..\pop2beeb\pop2beeb -i IMG.CHTAB5.bin -halfv -o BEEB.IMG.CHTAB5.HALF.bin -mode 5
