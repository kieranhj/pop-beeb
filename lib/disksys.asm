; DFS/ADFS Disk op routines
; helpful for streaming, faster loading to SWR etc.
; http://chrisacorns.computinghistory.org.uk/docs/Acorn/Manuals/Acorn_DiscSystemUGI2.pdf
; Our SWR loader is 60% faster than *SRLOAD

DISKSYS_DEBUG = FALSE
DISKSYS_CATALOG_ADDR = SCRATCH_RAM_ADDR
DISKSYS_BUFFER_ADDR = DISKSYS_CATALOG_ADDR+512 ; &1000 ; must be page aligned
DISKSYS_BUFFER_SIZE = 1 ; SECTORS TO READ, MUST BE ONE (for now)

.osword_params
.osword_params_drive
EQUB 0				; drive
.osword_params_address
EQUD 0				; address
EQUB &03			; number params
EQUB &53			; command = read data multi-sector
.osword_params_track
EQUB 0				; logical track
.osword_params_sector
EQUB 0				; logical sector
.osword_params_size_sectors
EQUB &2A			; sector size / number sectors = 256 / 10
.osword_params_return
EQUB 0				; returned error value

; Returns last diskop error code in A
.disksys_get_error
{
    lda osword_params_return
    rts
}

;--------------------------------------------------------------
; set disk head position for next read operation
;--------------------------------------------------------------
; on entry
; X = track number (0-79)
; Y = sector number (0-9)
; max 80 tracks x 10 sectors = 800 sectors
.disksys_seek
{
    stx osword_params_track
    sty osword_params_sector
    rts
}



;--------------------------------------------------------------
; Load sectors from disk to memory
;--------------------------------------------------------------
; on entry
; A = number of sectors to read (0-31)
; X = destination memory address LSB
; Y = destination memory address MSB
; if previous seek was to the first sector on a track, and A=10 then a complete track will be read.
.disksys_read_sectors
{
	\\ Store sector count in params block
    and #&1f
    ora #&20
	sta osword_params_size_sectors

	\\ Update load address in params block
    stx osword_params_address+0
	sty osword_params_address+1

	\\ Make DFS read multi-sector call
	ldx #LO(osword_params)
	ldy #HI(osword_params)
	lda #&7F
	jsr osword

	\\ Error value returned in osword_params_return
    rts
}

IF 0
.disksys_catalogue_addr     EQUW 0

;--------------------------------------------------------------
; set the memory address where the disk catalogue will be stored
;--------------------------------------------------------------
; on entry
; X = catalogue memory address LSB
; Y = catalogue memory address MSB
.disksys_set_catalogue_addr
{
    stx disksys_catalogue_addr+0
    sty disksys_catalogue_addr+1
    rts
}
ENDIF

;--------------------------------------------------------------
; Fetch the 512 byte catalogue from the disk to memory
;--------------------------------------------------------------
; on entry
; X = destination memory address LSB
; Y = destination memory address MSB
; on exit
; 512 bytes written to buffer in X/Y
.disksys_read_catalogue
{
 ;   jsr disksys_set_catalogue_addr

    ldx #0
    ldy #0
    jsr disksys_seek
    lda #2
    ldx #LO(DISKSYS_CATALOG_ADDR) ;disksys_catalogue_addr+0
    ldy #HI(DISKSYS_CATALOG_ADDR) ;disksys_catalogue_addr+1
    jsr disksys_read_sectors    
    rts
}


IF 0
; on entry
; X is ID of the file
; Assumes disksys_read_catalogue has been called prior
; X, Y is preserved
; TEST FUNCTION
.disksys_get_filename
{
    txa
    pha

    lda #LO(DISKSYS_CATALOG_ADDR) ;disksys_catalogue_addr+0
    sta addr+1
    lda #HI(DISKSYS_CATALOG_ADDR) ;disksys_catalogue_addr+1
    sta addr+2

    txa
    asl a
    asl a
    asl a
    clc
    adc #8
    tax    

    ldy #8
.addr
    lda &ffff,x
    jsr &ffee
    inx
    dey
    bne addr

    pla
    tax
    rts
}
ENDIF



;--------------------------------------------------------------
; Returns number of files on the disk in A
;--------------------------------------------------------------
; X/Y preserved
.disksys_get_numfiles
{
    lda #LO(DISKSYS_CATALOG_ADDR) ;disksys_catalogue_addr+0
    clc
    adc #5
    sta addr+1
    lda #HI(DISKSYS_CATALOG_ADDR) ;disksys_catalogue_addr+1
    adc #1
    sta addr+2
.addr
    lda &ffff ; get numfiles (is *8)
    ; divide numfiles by 8
    lsr a
    lsr a
    lsr a
    rts
}


;--------------------------------------------------------------
; Find a file on the disk by filename
;--------------------------------------------------------------
; Returns id of a file on the disk (0-31)
; returns 255 if not found
; X = filename address LSB
; Y = filename address MSB
; filename must be an 8 byte format where D is directory "NNNNNNND"
; filename IS case sensitive.
.disksys_find_file
{
    stx comp_addr2+1
    sty comp_addr2+2

    lda #LO(DISKSYS_CATALOG_ADDR) ;disksys_catalogue_addr+0
    clc
    adc #8
    sta comp_addr+1
    lda #HI(DISKSYS_CATALOG_ADDR) ;disksys_catalogue_addr+1
    adc #0
    sta comp_addr+2

    ; get numfiles
    jsr disksys_get_numfiles    
    sta counter+1    

;loop through files looking for exact match
    ldx #0
.check_loop
    ldy #7
.comp_loop

.comp_addr
    lda &ffff,y     ; modified

.comp_addr2
    cmp &ffff,y     ; modified

    bne failed
    dey
    bpl comp_loop
    ; found it, return id
    txa
    rts


.failed

    lda comp_addr+1
    clc
    adc #8
    sta comp_addr+1
    lda comp_addr+2
    adc #0
    sta comp_addr+2
    inx
.counter
    cpx #123        ; modified
    beq end
    jmp check_loop
.end
    ; not found
    lda #255
    rts
}


;--------------------------------------------------------------
; Fetch file attributes
;--------------------------------------------------------------
; returns file attributes for given file id
; on entry
; A=file id (0-31)
; on exit
; X=attributes LSB
; Y=attributes MSB
.disksys_file_info
{
    asl a
    asl a
    asl a
    clc
    adc #8
    adc #LO(DISKSYS_CATALOG_ADDR) ;disksys_catalogue_addr+0
    tax
    lda #HI(DISKSYS_CATALOG_ADDR) ;disksys_catalogue_addr+1
    adc #1
    tay
    rts
}

;--------------------------------------------------------------
; Load a file from disk to memory (SWR supported)
; Loads in sector granularity so will always write to page aligned address
;--------------------------------------------------------------
; A=memory address MSB (page aligned)
; X=filename address LSB
; Y=filename address MSB
; clobbers memory DISKSYS_BUFFER_ADDR to DISKSYS_BUFFER_ADDR+768
.disksys_load_file
{
    sta transfer_addr+2

    ; get the currently selected ROM/RAM bank
    ; BEFORE we do any DFS related work since that will page the DFS ROM in
    lda &f4
    sta swr_select+1    

    txa:pha:tya:pha

    ; load 512 byte disk catalogue to DISKSYS_CATALOG_ADDR to DISKSYS_CATALOG_ADDR+512
    ldx #LO(DISKSYS_CATALOG_ADDR)
    ldy #HI(DISKSYS_CATALOG_ADDR)
    jsr disksys_read_catalogue

    pla:tay:pla:tax

    jsr disksys_find_file
    bpl continue
    ; file not found
    rts
.file_length    EQUB 0,0,0
.file_sector    EQUB 0,0
.file_sectors   EQUW 0

IF DISKSYS_DEBUG
.txt_sector EQUS "sector %w", LO(file_sector), HI(file_sector), 13,10,0
.txt_length EQUS "length %w", LO(file_length), HI(file_length), 13,10,0
.txt_sectors EQUS "sectors %w", LO(file_sectors), HI(file_sectors), 13,10,0
.txt_t1 EQUS "Track %a", 13,10,0
.txt_s1 EQUS "Sector %a", 13,10,0
.txt_l1 EQUS "Loading to %a", 13,10,0
ENDIF


.continue
    ; get attributes
    jsr disksys_file_info
    ; we ignore load & exec address
    ; just need length & start sector 
    stx &9e
    sty &9f

    ; get file length in bytes
    ldy #4
    lda (&9e),y
    sta file_length+0
    iny
    lda (&9e),y
    sta file_length+1
    iny
    lda (&9e),y
    lsr a
    lsr a
    lsr a
    lsr a
    and #3
    sta file_length+2

    ; get sector offset (10 bits)
    lda (&9e),y
    and #3
    sta file_sector+1
    iny
    lda (&9e),y
    sta file_sector+0    

    ; round up file length to total sector count
    lda file_length+1
    sta file_sectors+0
    lda file_length+2
    sta file_sectors+1
    lda file_length+0
    beq pagea
    inc file_sectors+0
    bcc pagea
    inc file_sectors+1
.pagea

IF DISKSYS_DEBUG
    MPRINT txt_sector
    MPRINT txt_length
    MPRINT txt_sectors
ENDIF 

;  divide sector offset by 10 to get track & sector
    lda file_sector+1
    ldx #8
    asl file_sector+0
.l1 
    rol a
    bcs l2
    cmp #10
    bcc l3
.l2 
    sbc #10
    sec
.l3 
    rol file_sector+0
    dex
    bne l1    

    sta file_sector+1   ; now contains sector

IF DISKSYS_DEBUG
    lda file_sector+0   ; now contains track
    MPRINT txt_t1
    lda file_sector+1   ; now contains sector
    MPRINT txt_s1
ENDIF
    


.load_loop

    ; seek to sector
    ldx file_sector+0   ; track
    ldy file_sector+1   ; sector
    jsr disksys_seek

    ; see if any sectors left to load
    lda file_sectors+0
    bne fetch
    lda file_sectors+1
    bne fetch

IF DISKSYS_DEBUG
    MPRINT txt_sectors
ENDIF    
    ; finished
    rts
.fetch

IF DISKSYS_DEBUG
    lda transfer_addr+2
    MPRINT txt_l1
ENDIF

    ; load a single sector to 256 byte memory buffer DISKSYS_BUFFER_ADDR
    lda #DISKSYS_BUFFER_SIZE
    ldx #LO(DISKSYS_BUFFER_ADDR)
    ldy #HI(DISKSYS_BUFFER_ADDR)
    jsr disksys_read_sectors

    sei
.swr_select
    ; select the destination ROM/RAM bank that was selected on entry to the routine 
    lda #&FF            ; MODIFIED
    jsr swr_select_bank

    ; copy from the memory buffer to destination address
    ldx #0
.transfer
    lda DISKSYS_BUFFER_ADDR,x
.transfer_addr
    sta &ff00,x         ; modified
    inx
    bne transfer
    cli

    ; advance destination memory address by one page 
    inc transfer_addr+2

    ; advance disk head to next sector
    inc file_sector+1
    lda file_sector+1
    cmp #10
    bne same_track
    ; move to next track
    lda #0
    sta file_sector+1
    inc file_sector+0
.same_track

    ; decrease the number of sectors remaining
    lda file_sectors+0
    sec
    sbc #1
    sta file_sectors+0
    lda file_sectors+1
    sbc #0
    sta file_sectors+1

    jmp load_loop
}

; DFS DISK FORMAT
; 
; Sector 00
; &00 to &07 First eight bytes of the 13-byte disc title
; &08 to &0E First file name
; &0F Directory of first file name
; &10 to &1E Second file name
; &1F Directory of second file name . . . .
;  . . and so on
; Repeated up to 31 files

; Sector 01
; &00 to &03 Last four bytes of the disc title
; &04 Sequence number
; &05 The number of catalogue entries multiplied by 8
; &06 (bits 0,1) Number of sectors on disc (two high order bits of 10 bit
; number)
; (bits 4,5) !BOOT start-up option
; &07 Number of sectors on disc (eight low order bits of 10 bit
; number)
; &08 First file's load address, low order bits
; &09 First file's load address, middle order bits
; &OA First file's exec address, low order bits
; &0B First file's exec address, middle order bits
; &0C First file's length in bytes, low order bits
; &0D First file's length in bytes, middle order bits
; &0E (bits 0,1) First file's start sector, two high order bits of 10 bit
; number
; (bits 2,3) First file's load address, high order bits
; (bits 4,5) First file's length in bytes, high order bits
; (bits 6,7) First file's exec address, high order bits
; &0F First file's start sector, eight low order bits of 10 bit
; number
; . . . and so on
; Repeated for up to 31 files


