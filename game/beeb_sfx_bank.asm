; Beeb SFX Bank
; All SFX fit into 1KB space at top of BANK1 == ROM 5

;----------------------------------------------------------------
; SFX
;----------------------------------------------------------------

.pop_sfx_start

.pop_sfx_00 ; PlateDown
INCBIN "audio/sfx/00 platedown.raw"
.pop_sfx_01 ; PlateUp
INCBIN "audio/sfx/01 plateup.raw"
.pop_sfx_02 ; GateDown
INCBIN "audio/sfx/02 gatedown.raw"

.pop_sfx_05 ; Splat
INCBIN "audio/sfx/05 splat.raw"
.pop_sfx_06 ; MirrorCrack
INCBIN "audio/sfx/06 mirrorcrack.raw"
.pop_sfx_07 ; LooseCrash
INCBIN "audio/sfx/07 platecrash.raw"

.pop_sfx_09 ; Footstep
INCBIN "audio/sfx/09 footstep.raw"
.pop_sfx_10 ; RaisingExit
INCBIN "audio/sfx/10 exitrise.raw"
.pop_sfx_11 ; RaisingGate
INCBIN "audio/sfx/11 gaterise.raw"
.pop_sfx_12 ; LoweringGate
INCBIN "audio/sfx/12 gatelower.raw"
.pop_sfx_13 ; SmackWall
INCBIN "audio/sfx/13 ungh.raw"
.pop_sfx_14 ; Impaled
INCBIN "audio/sfx/14 impale.raw"
.pop_sfx_15 ; GateSlam
INCBIN "audio/sfx/15 gateslam.raw"
.pop_sfx_16 ; FlashMsg
INCBIN "audio/sfx/16 message.raw"
.pop_sfx_17 ; SwordClash1
INCBIN "audio/sfx/17 swordparry.raw"
.pop_sfx_18 ; SwordClash2
INCBIN "audio/sfx/18 swordhit.raw"
.pop_sfx_19 ; JawsClash
INCBIN "audio/sfx/19 jawsclash.raw"

.pop_sfx_03 ; SpecialKey1
.pop_sfx_04 ; SpecialKey2
.pop_sfx_08 ; GotKey
INCBIN "audio/sfx/annoyshort.raw"

.pop_music_glug
INCBIN "audio/sfx/3glugs.raw"

.pop_sfx_end
