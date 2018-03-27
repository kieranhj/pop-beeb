@echo off
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.CHTAB6.mode2.bin disc\chtab6.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.CHTAB7.mode2.bin disc\chtab7.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.CHTAB8.mode2.bin disc\chtab8.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.CHTAB9.mode2.bin disc\chtab9.pu.bin

bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.CHTAB5.bin disc\chtab5.pu.bin

bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.BGTAB1.DUNA.bin disc\dun1a.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.BGTAB1.DUNB.bin disc\dun1b.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.BGTAB2.DUN.bin disc\dun2.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.BGTAB1.PALA.bin disc\pal1a.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.BGTAB1.PALB.bin disc\pal1b.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.BGTAB2.PAL.bin disc\pal2.pu.bin

bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.CHTAB4.FAT.bin disc\fat.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.CHTAB4.GD.bin disc\gd.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.CHTAB4.SHAD.bin disc\shad.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.CHTAB4.SKEL.bin disc\skel.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Images\Beeb.IMG.CHTAB4.VIZ.bin disc\viz.pu.bin

bin\pucrunch.exe -d -c0 -l0x1000 Other\john.Splash.mode2.bin disc\splash.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Other\john.Credits.mode2.bin disc\credits.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Other\john.Epilog.mode2.bin disc\epilog.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Other\john.Prolog.mode2.bin disc\prolog.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Other\john.Sumup.mode2.bin disc\sumup.pu.bin

bin\pucrunch.exe -d -c0 -l0x1000 Other\john.Byline.mode2.bin disc\byline.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Other\john.Title.mode2.bin disc\title.pu.bin
bin\pucrunch.exe -d -c0 -l0x1000 Other\john.Presents.mode2.bin disc\presents.pu.bin

bin\pucrunch.exe -d -c0 -l0x7C00 Other\bitshifters3.mode7.bin disc\bits.pu.bin

REM Now convert assets to pak file

bin\BeebAsm.exe -i disc\pak_levels.asm
bin\BeebAsm.exe -i disc\pak_sprites.asm
