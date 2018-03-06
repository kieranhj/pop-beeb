@echo off
FOR %%F in (IMG.CHTAB*.bin) DO ..\pop2beeb\pop2beeb -i %%F -mode 5 -test

..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -mode 5 -point 0 -even 1 -test
..\pop2beeb\pop2beeb -i IMG.BGTAB2.DUN.bin -mode 5 -point 0 -even 1 -test

..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -mode 5 -point 0 -even 0 -test
..\pop2beeb\pop2beeb -i IMG.BGTAB2.PAL.bin -mode 5 -point 0 -even 0 -test
