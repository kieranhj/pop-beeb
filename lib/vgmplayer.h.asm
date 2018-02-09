
\\ VGM Player module
\\ Include file
\\ Define ZP and constant vars only in here
\\ Customized version for Prince Of Persia 
\\       VGMs are exported as raw files, 50Hz packets, no header block
\\       VGM music is compressed using exomizer raw -c -m 256 <file.raw> -o <file.exo>
\\       VGM sfx are not compressed.


\ ******************************************************************
\ *	Define global constants
\ ******************************************************************


\ ******************************************************************
\ *	Declare ZP variables
\ ******************************************************************

\\ Player vars
.vgm_player_ended			SKIP 1		; non-zero when player has reached end of tune
.vgm_sfx_addr               SKIP 2      ; currently playing sfx memory address
