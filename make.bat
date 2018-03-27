@echo off
set HH=%TIME:~0,2%
if %HH% leq 9 set HH=0%HH:~1,1%
echo EQUB $%DATE:~8,2%, $%DATE:~3,2%, $%DATE:~0,2%, $%HH%, $%TIME:~3,2%, "%USERNAME:~0,2%" > version.txt

rem SM: selfishly not sending compiler output to compile.txt so I can use VS.code console instead
rem KC: super hack balls just for me ;)
rem SM: better fix
rem if "%USERNAME%"=="kconnell" (
if "%1"=="vsc" (
bin\BeebAsm.exe -v -i pop-beeb.asm 
) else (
bin\BeebAsm.exe -v -i pop-beeb.asm > compile.txt
)

if %ERRORLEVEL% neq 0 (
	echo Assemble failed!
	exit /b 1
)

rem Crunch files produced by Code build
bin\pucrunch.exe -d -c0 -l0x1000 "disc\PRIN2" disc\prin2.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 "disc\BANK1" disc\bank1.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 "disc\Main" disc\main.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 "disc\AuxB" disc\auxb.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 "disc\High" disc\high.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 "disc\Hazel" disc\hazel.pu.bin

rem Produce the disc image
del pop-beeb.ssd
bin\BeebAsm.exe -v -i disc\pop-beeb-layout.asm -boot Prince -di disc\disc-template.ssd.bin -do pop-beeb.ssd
