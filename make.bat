@echo off
set HH=%TIME:~0,2%
if %HH% leq 9 set HH=0%HH:~1,1%
echo EQUB $%DATE:~8,2%, $%DATE:~3,2%, $%DATE:~0,2%, $%HH%, $%TIME:~3,2%, "%USERNAME:~0,2%" > version.txt
del pop-beeb-side-a.ssd
bin\BeebAsm.exe -v -i pop-beeb.asm -di disc/template-side-a.ssd.bin -do pop-beeb-side-a.ssd > compile.txt

if %ERRORLEVEL% neq 0 (
	echo Assemble failed!
	exit /b 1
)

del "pop-beeb-side-a.ssd.$.PRIN2*"
bin\bbcim -e "pop-beeb-side-a.ssd" PRIN2
bin\pucrunch.exe -d -c0 -l0x1000 "pop-beeb-side-a.ssd.$.PRIN2" disc\prin2.pu.bin
bin\bbcim -d "pop-beeb-side-a.ssd" "$.PRIN2"

bin\bbcim -a "pop-beeb-side-a.ssd" "disc/boot.txt"
bin\bbcim -a "pop-beeb-side-a.ssd" "disc/prin2.pu.bin"

call make_pop_side_b.bat
del pop-beeb.dsd
bin\bbcim -interss sd pop-beeb-side-a.ssd pop-beeb-side-b.ssd pop-beeb.dsd
