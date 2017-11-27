@echo off
FOR %%F in (IMG.CHTAB*.bin) DO ..\pop2beeb\pop2beeb -i %%F -mode 5 -flip -test

FOR %%F in (IMG.BGTAB*.bin) DO ..\pop2beeb\pop2beeb -i %%F -mode 5 -flip -test -point 0
