@echo off

REM FOR %%F in (BEEB.IMG.*.bin) DO ..\audio\exomizer.exe raw -c -m 256 %%F -o %%F.exo

del *.pu
FOR %%F in (BEEB.IMG.*.bin) DO ..\bin\pucrunch.exe -d -c0 -l0x8000 %%F %%F.pu
