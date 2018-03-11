@echo on
rem| POP-BEEB audio compile script
rem| @simondotm

echo Processing >vgm_process_pop.txt

rem|-------------------------------------------------------------------------
rem| all audio for POP is VGM SN76489 format transposed from NTSC to 4Mhz
rem| then converted to raw format 50Hz
rem| music is EXO compressed using a 256 byte dictionary
rem| sfx is just raw chip data
rem| After compilation we delete any intermediate files
rem|  and only keep the EXO or RAW file data.
rem|
rem| folders:
rem|  ip - original POP-BEEB music by @inversephase
rem|  music - Sega Master system music by Matt Furniss
rem|  sfx - original POP-BEEB sound effects by @inversephase
rem|
rem| the script will compile any VGM source files it finds in the "vgm" subfolders.
rem| the script uses a copied version of the "vgmconverter" python script from
rem|  https://github.com/simondotm/vgm-converter
rem|-------------------------------------------------------------------------

rem|---- compile the ip music ----

for %%x in (ip\vgm\*.vgm) do vgmconverter.py "%%x" -n -t bbc -q 50 -r "ip\%%~nx.raw" -o "ip\%%~nx.bbc.vgm" >>vgm_process_pop.txt
for %%x in (ip\*.raw) do exomizer.exe raw -c -m 256 "%%x" -o "ip\%%~nx.raw.exo" >>vgm_process_pop.txt
del ip\*.bbc.vgm
del ip\*.raw


rem|---- compile the matt furniss / SMS music ----

for %%x in (music\vgm\*.vgm) do vgmconverter.py "%%x" -n -t bbc -q 50 -r "music\%%~nx.raw" -o "music\%%~nx.bbc.vgm" >>vgm_process_pop.txt
for %%x in (music\*.raw) do exomizer.exe raw -c -m 256 "%%x" -o "music\%%~nx.raw.exo" >>vgm_process_pop.txt
del music\*.bbc.vgm
del music\*.raw

rem|---- compile the sound effects (these are not EXO compressed) ----

for %%x in (sfx\vgm\*.vgm) do vgmconverter.py "%%x" -n -t bbc -q 50 -r "sfx\%%~nx.raw" -o "sfx\%%~nx.bbc.vgm" >>vgm_process_pop.txt
del sfx\*.bbc.vgm

rem pause