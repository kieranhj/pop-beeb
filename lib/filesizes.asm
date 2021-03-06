; Calculate file sizes for assembler

CLEAR 0, &FFFF
ORG 0
GUARD &8000
INCBIN "disc/splash.pu.bin"
PAGE_ALIGN
.pu_splash_size
pu_splash_loadat = &8000 - pu_splash_size

CLEAR 0, &FFFF
ORG 0
GUARD &8000
INCBIN "disc/title.pu.bin"
PAGE_ALIGN
.pu_title_size
pu_title_loadat = &8000 - pu_title_size

CLEAR 0, &FFFF
ORG 0
GUARD &8000
INCBIN "disc/presents.pu.bin"
PAGE_ALIGN
.pu_presents_size
pu_presents_loadat = &8000 - pu_presents_size

CLEAR 0, &FFFF
ORG 0
GUARD &8000
INCBIN "disc/byline.pu.bin"
PAGE_ALIGN
.pu_byline_size
pu_byline_loadat = &8000 - pu_byline_size

CLEAR 0, &FFFF
ORG 0
GUARD &8000
INCBIN "disc/prolog.pu.bin"
PAGE_ALIGN
.pu_prolog_size
pu_prolog_loadat = &8000 - pu_prolog_size

CLEAR 0, &FFFF
ORG 0
GUARD &8000
INCBIN "disc/sumup.pu.bin"
PAGE_ALIGN
.pu_sumup_size
pu_sumup_loadat = &8000 - pu_sumup_size

CLEAR 0, &FFFF
ORG 0
GUARD &8000
INCBIN "disc/credits.pu.bin"
PAGE_ALIGN
.pu_credits_size
pu_credits_loadat = &8000 - pu_credits_size

CLEAR 0, &FFFF
ORG 0
GUARD &8000
INCBIN "disc/epilog.pu.bin"
PAGE_ALIGN
.pu_epilog_size
pu_epilog_loadat = &8000 - pu_epilog_size

CLEAR 0, &FFFF
