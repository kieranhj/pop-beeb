@echo off
..\..\bin\BeebAsm.exe -v -i pop-beeb.asm -do pop-beeb-side-a.ssd -boot Core > compile.txt
bin\bbcim -interss sd pop-beeb-side-a.ssd pop-beeb-side-b.ssd pop-beeb.dsd
