@echo off
FOR %%F in (IMG.CHTAB*.bin) DO ..\pop2beeb\pop2beeb -i %%F -o BEEB.%%F -mode 5 -pal 12

REM FOR %%F in (IMG.BGTAB*.bin) DO ..\pop2beeb\pop2beeb -i %%F -o BEEB.%%F -mode 5 -point 0

..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -o BEEB.IMG.BGTAB1.DUN.bin -mode 5 -point 0 -even 1
..\pop2beeb\pop2beeb -i IMG.BGTAB2.DUN.bin -o BEEB.IMG.BGTAB2.DUN.bin -mode 5 -point 0 -even 1

..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -s 1 -e 87 -o BEEB.IMG.BGTAB1.DUNA.bin -mode 5 -point 0 -even 1
..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -s 88 -e 111 -o BEEB.IMG.BGTAB1.DUNB.bin -mode 5 -point 0 -even 1

..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -o BEEB.IMG.BGTAB1.PAL.bin -mode 5 -point 0 -even 0
..\pop2beeb\pop2beeb -i IMG.BGTAB2.PAL.bin -o BEEB.IMG.BGTAB2.PAL.bin -mode 5 -point 0 -even 0

..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -s 1 -e 87 -o BEEB.IMG.BGTAB1.PALA.bin -mode 5 -point 0 -even 0
..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -s 88 -e 111 -o BEEB.IMG.BGTAB1.PALB.bin -mode 5 -point 0 -even 0
