@echo off

rem disk1 now created by beebasm

del "pop-beeb-side-a.ssd.$.Audio*"

bin\bbcim -e "pop-beeb-side-a.ssd" Audio3
bin\bbcim -e "pop-beeb-side-a.ssd" Audio4

del "pop-beeb-side-b.ssd"
copy "disc\template-side-b.ssd.bin" "pop-beeb-side-b.ssd"

bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.BGTAB1.DUNB.bin"

bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL0"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL1"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL2"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL3"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL4"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL5"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL6"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL7"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL8"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL9"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL10"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL11"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL12"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL13"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"
bin\bbcim -a "pop-beeb-side-b.ssd" "disc\dummy.txt"
bin\bbcim -a "pop-beeb-side-b.ssd" "Levels\LEVEL14"
bin\bbcim -d "pop-beeb-side-b.ssd" "$.DUMMY"

bin\bbcim -a "pop-beeb-side-b.ssd" "pop-beeb-side-a.ssd.$.Audio3"

bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.BGTAB1.DUNA.bin"
bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.BGTAB2.DUN.bin"
bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.BGTAB1.PALA.bin"
bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.BGTAB1.PALB.bin"
bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.BGTAB2.PAL.bin"

bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.CHTAB4.FAT.bin"
bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.CHTAB4.GD.bin"
bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.CHTAB4.SHAD.bin"
bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.CHTAB4.SKEL.bin"
bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.CHTAB4.VIZ.bin"

bin\bbcim -a "pop-beeb-side-b.ssd" "pop-beeb-side-a.ssd.$.Audio4"

REM bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.CHTAB6.mode2.bin"
REM bin\bbcim -a "pop-beeb-side-b.ssd" "Images/BEEB.IMG.CHTAB8.mode2.bin"
bin\bbcim -a "pop-beeb-side-b.ssd" "Images/chtab6.pu.bin"
bin\bbcim -a "pop-beeb-side-b.ssd" "Images/chtab8.pu.bin"

bin\bbcim -a "pop-beeb-side-b.ssd" "disc/prin2.pu.bin"
