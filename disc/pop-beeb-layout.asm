; pop-beeb-side-a.asm
; Make the disc

\*-------------------------------
; Put files on SIDE A of the disk
\*-------------------------------

\ Start with !BOOT
;PUTFILE "disc/boot.txt", "!BOOT", &FFFF, 0

\ All code
PUTFILE "disc/Core", "Prince", &E00, &E77
PUTFILE "disc/bits.pu.bin", "BITS", &7C00, 0
PUTFILE "disc/Lower", "Lower", &C00, 0
PUTFILE "disc/Main", "Main", &3000, 0
PUTFILE "disc/Hazel", "Hazel", &D300, 0
PUTFILE "disc/AuxB", "AuxB", &8000, 0
PUTFILE "disc/High", "High", &8000, 0

\ Audio Banks
PUTFILE "disc/Audio0", "Audio0", &8000, 0
PUTFILE "disc/Audio1", "Audio1", &8000, 0
PUTFILE "disc/Audio2", "Audio2", &8000, 0
PUTFILE "disc/Audio3", "Audio3", &8000, 0
PUTFILE "disc/Audio4", "Audio4", &8000, 0

\ Image files
PUTFILE "disc/splash.pu.bin", "SPLASH", &3000, 0
PUTFILE "disc/title.pu.bin", "TITLE", &3000, 0
PUTFILE "disc/presents.pu.bin", "PRESENT", &3000, 0
PUTFILE "disc/byline.pu.bin", "BYLINE", &3000, 0
PUTFILE "disc/prolog.pu.bin", "PROLOG", &3000, 0
PUTFILE "disc/sumup.pu.bin", "SUMUP", &3000, 0
PUTFILE "disc/credits.pu.bin", "CREDITS", &3000, 0
PUTFILE "disc/epilog.pu.bin", "EPILOG", &3000, 0

\ Game file
PUTFILE "disc/BANK1.pu.bin", "BANK1", &8000, 0

\ Princess room
PUTFILE "disc/PRIN2.pu.bin", "PRIN2", &3F00, 0

\ Sprites
PUTFILE "disc/sprites.bin", "SPRITES", 0

\ Levels
PUTFILE "disc/levels.bin", "LEVELS", 0

\ Manual (if room at end)
;PUTFILE "Manual.txt", "MANUAL", 0
