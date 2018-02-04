@echo off
FOR %%F in (IMG.CHTAB*.bin) DO ..\pop2beeb\pop2beeb -i %%F -mode 5 -flip -test

REM FOR %%F in (IMG.BGTAB*.bin) DO ..\pop2beeb\pop2beeb -i %%F -mode 5 -flip -test -point 0

..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -mode 5 -point 0 -even 1 -flip -test
..\pop2beeb\pop2beeb -i IMG.BGTAB2.DUN.bin -mode 5 -point 0 -even 1 -flip -test

..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -mode 5 -point 0 -even 0 -flip -test
..\pop2beeb\pop2beeb -i IMG.BGTAB2.PAL.bin -mode 5 -point 0 -even 0 -flip -test

