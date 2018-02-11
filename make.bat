@echo off
SET BUILDNO=%DATE:~8,2%%DATE:~3,2%%DATE:~0,2%_%TIME:~0,2%%TIME:~3,2%
echo %BUILDNO% > version.txt
..\..\bin\BeebAsm.exe -v -i pop-beeb.asm -do pop-beeb-side-a.ssd -boot Core > compile.txt
bin\bbcim -interss sd pop-beeb-side-a.ssd pop-beeb-side-b.ssd pop-beeb.dsd
