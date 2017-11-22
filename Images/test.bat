@echo off
FOR %%F in (IMG.*.bin) DO ..\pop2beeb\pop2beeb -i %%F -mode 5 -flip -test

..\pop2beeb\pop2beeb -i IMG.BGTAB1.DUN.bin -mode 5 -point 0 -flip -test
..\pop2beeb\pop2beeb -i IMG.BGTAB2.DUN.bin -mode 5 -point 0 -flip -test
..\pop2beeb\pop2beeb -i IMG.BGTAB1.PAL.bin -mode 5 -point 0 -flip -test
..\pop2beeb\pop2beeb -i IMG.BGTAB2.PAL.bin -mode 5 -point 0 -flip -test
