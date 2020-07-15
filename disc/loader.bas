1*FX200,3
10MODE7
20A%=0:X%=1:R%=USR(&FFF4):M%=(R%DIV256)AND255
30tstaddr = &8008
40values = &90
50unique = &80
60RomSel = &FE30
70RamSel = &FE32
80REM Find 16 values distinct from the 16 rom values and each other and save the original rom values
90DIM CODE &100
100FOR P = 0 TO 2 STEP 2
110P%=CODE
120[OPT P
130SEI
140LDY #15        \\ unique values (-1) to find
150TYA            \\ A can start anywhere less than 256-64 as it just needs to allow for enough numbers not to clash with rom, tst and uninitialised tst values
160.next_val
170LDX #15        \\ sideways bank
180ADC #1         \\ will inc mostly by 2, but doesn't matter
190.next_slot
200STX RomSel
210CMP tstaddr
220BEQ next_val
230CMP unique,X   \\ doesn't matter that we haven't checked these yet as it just excludes unnecessary values, but is safe
240BEQ next_val
250DEX
260BPL next_slot
270STA unique,Y
280LDX tstaddr
290STX values,Y
300DEY
310BPL next_val
320\\ Try to swap each rom value with a unique test value - top down wouldn't work for Solidisk
330LDX #0         \\ count up to allow for Solidisk only having 3 select bits
340.swap
350STX RamSel     \\ set RamSel incase it is used
360STX RomSel     \\ set RomSel as it will be needed to read, but is also sometimes used to select write
370LDA unique,X
380STA tstaddr
390INX            \\ count up to allow for Solidisk only have 3 select bits
400CPX #16
410BNE swap
420\\ count matching values and restore old values - reverse order to swapping is safe
430LDY #16
440LDX #15
450.tst_restore
460STX RomSel
470LDA tstaddr
480CMP unique,X   \\ if it has changed, but is not this value, it will be picked up in a later bank
490BNE not_swr
500STX RamSel     \\ set RamSel incase it is used
510LDA values,X
520STA tstaddr
530DEY
540STX values,Y
550.not_swr
560DEX
570BPL tst_restore
580STY values
590LDA &F4
600STA RomSel     \\ restore original ROM
610CLI
620RTS
630]
640NEXT
650CALL CODE
660PRINT"PRINCE OF PERSIA by"'"the BITSHIFTERS COLLECTIVE"''"Checking system requirements..."
670IF NOT(M%=3 OR M%=5) THEN PRINT'"Sorry, this game requires a BBC Master.":END
680PRINT'"Detected ";16-?&90;" SWRAM banks:";
690IF ?&90 <> 16 THEN FOR X% = ?&90 TO 15 : PRINT;" ";X%?&90; : NEXT
700IF ?&90 > (16-4) THEN PRINT'"Sorry, this game requires 4x SWRAM banks in slots 4,5,6,7.":END
710IF PAGE > &E00 THEN PRINT'"Sorry, this game requires PAGE at &E00.":END
720PRINT'"Loading...";
730*RUN Prince
740END
