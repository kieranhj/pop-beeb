
\\ VGM Player module
\\ Include file
\\ Define ZP and constant vars only in here
\\ Customized version for Prince Of Persia 


\ ******************************************************************
\ *	Define global constants
\ ******************************************************************

; POP VGMs have been modified to contain no header information
VGM_HEADER = FALSE


\\ Player
VGM_PLAYER_string_max = 42			; size of our meta data strings (title and author)
VGM_PLAYER_sample_rate = 50			; locked to 50Hz

\ ******************************************************************
\ *	Declare ZP variables
\ ******************************************************************

\\ Player vars
.vgm_player_ended			SKIP 1		; non-zero when player has reached end of tune
.vgm_player_data			SKIP 1		; temporary variable when decoding sound data - must be separate as player running on events
;.vgm_player_last_reg		SKIP 1		; last channel (register) refered to by the VGM sound data
;.vgm_player_reg_bits		SKIP 1		; bits 0 - 7 set if SN register 0 - 7 updated this frame, cleared at start of player poll
;.vgm_player_counter			SKIP 2		; increments by 1 every poll (20ms) - used as our tracker line no. & to sync fx with audio update

.vgm_player_counter_tmp     SKIP 1