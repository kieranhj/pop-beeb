@echo off
FOR %%F in (IMG.*.bin) DO ..\pop2beeb\pop2beeb -i %%F -o BEEB.%%F -mode 5
