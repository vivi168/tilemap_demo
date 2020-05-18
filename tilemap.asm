;**************************************
; TileMap Demo
;**************************************
.65816

.org 018000
.base 8000

tileset:
    .incbin assets/tileset.bin
tileset_palette:
    .incbin assets/tileset-pal.bin
small_map:
    .incbin assets/big.bin

.org 7e0000
map_offset:
    .rb 2
tilemap_buffer:
    .rb 800

.org 008000
.base 0000

ResetVector:
    sei                 ; disable interrupts
    clc
    xce
    sep #20             ; M8
    rep #10             ; X16

    ldx #1fff
    txs                 ; set stack pointer to 1fff

    ; Forced Blank
    lda #80
    sta 2100            ; INIDISP
    jsr @ClearRegisters

    ; ---- BG settings
    lda #01
    sta 2105            ; BGMODE 1

    lda #00             ; first write = lower byte
    sta 210d
    lda #00             ; second write = upper 2 bits
    sta 210d            ; horizontal scroll
    lda #ff
    sta 210e
    lda #03
    sta 210e            ; vertical scroll. caution, offset by -1

    lda #10             ; BG1 MAP @ VRAM[2000]
    sta 2107            ; BG1SC
    lda #00             ; BG1 tiles @ VRAM[0000]
    sta 210b            ; BG12NBA

    lda #01             ; enable BG1&3
    sta 212c            ; TM

    tsx
    pea 046e            ; pointer to map read start
    pea 0374            ; pointer to tilemap write start. multiple of 2 because tile is 2 bytes. should be determined by screen TM position
    jsr @CopyMapColumnToTileMapBuffer
    txs

    tsx
    pea 054d            ; pointer to map read start
    pea 06d0            ; pointer to tilemap write start. multiple of 2 because tile is 2 bytes. should be determined by screen TM position
    jsr @CopyMapRowToTileMapBuffer
    txs

    ;jsr @InitTilemapBuffer

    ; ---- DMA transfers ---
    ; Copy tilemap buffer to VRAM
    tsx                 ; save stack pointer
    pea 1000            ; vram dest addr (@2000 really, word steps)
    pea @tilemap_buffer
    lda #^tilemap_buffer
    pha
    pea 0800            ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy tileset.bin to VRAM
    tsx                 ; save stack pointer
    pea 0000            ; vram dest addr (@0000 really, word steps)
    pea @tileset
    lda #^tileset
    pha
    pea 0400            ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy tileset-pal.bin to CGRAM
    tsx                 ; save stack pointer
    lda #00             ; cgram dest addr (@0000 really, 2 bytes step)
    pha
    pea @tileset_palette
    lda #^tileset_palette
    pha
    lda #20             ; bytes_to_trasnfer
    pha
    jsr @CgramDmaTransfer
    txs                 ; restore stack pointer
    ; ----

    lda #0f             ; release forced blanking, set screen to full brightness
    sta 2100            ; INIDISP

    lda #81             ; enable NMI, turn on automatic joypad polling
    sta 4200            ; NMITIMEN
    cli                 ; enable interrupts

    jmp @MainLoop

BreakVector:
    rti

NmiVector:
    pha

    lda 4210            ; RDNMI

    pla
    rti

MainLoop:
    jmp @MainLoop

; arg1(@0a) = map read start, arg2(@08) = tilemap buffer write start
CopyMapColumnToTileMapBuffer:
    phx
    phd

    lda #20
    pha                 ; reserve loop counter on stack

    tsc
    tcd

    phb                 ; save data bank register
    lda #01
    pha
    plb                 ; DBR = 1

    ldy 0a              ; pointer to map read start, should be a PARAM
    ldx 08              ; pointer to tilemap write start. multiple of 2 because tile is 2 bytes. should be determined by screen TM position

copy_column_loop:
    lda @small_map+6,y
    sta !tilemap_buffer,x
    inx
    lda #00
    sta !tilemap_buffer,x
    dex

    rep #20
    ; next map entry
    tya
    clc
    adc @small_map+2
    tay

    ; next tilemap entry
    txa
    clc
    adc #0040           ; 0x40 because vram entry are 2 bytes
    tax
    ; here wrap at row 0 if necessary
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr                 ; one additional shift right because tilemap is 2 bytes for one entry
    cmp #0020
    bcc @skip_column_wrap
    txa
    and #003f           ; #003f because tilemap index are multiple of 2s
    tax
skip_column_wrap:
    sep #20

    dec 01
    bne @copy_column_loop

    plb                 ; restore data bank register

    pla
    pld
    plx

    rts

; arg1(@0a) = map read start, arg2(@08) = tilemap buffer write start
CopyMapRowToTileMapBuffer:
    phx
    phd

    lda #20             ; loop counter
    pha

    tsc
    tcd                 ; create a local frame

    phb                 ; save data bank register
    lda #01
    pha
    plb                 ; DBR = 1 (to access small map Y indexed)

    ldy 0a              ; map read start initial map offset
    ldx 08              ; load tilemap buffer write start offset

copy_row_loop:
    lda @small_map+6,y
    iny
    sta !tilemap_buffer,x
    inx
    lda #00
    sta !tilemap_buffer,x
    inx

    rep #20
    txa
    ; here wrap at column  0 if necessary
    bit #003f
    bne @skip_row_wrap
    sec
    sbc #0040
    tax
skip_row_wrap:
    sep #20

    dec 01
    bne @copy_row_loop

    plb                 ; restore data bank register

    pla
    pld
    plx

    rts

InitTilemapBuffer:
;**************************************
; tilemap format
; tile number lowest 8 bits
; vert flip | hori flip | prio bit | pal no H | pal no M | pal no L | tile number 10th bit | tile number 9th bith
;**************************************
    ldy #0000           ; pointer to map read start
    ldx #0000           ; pointer to tilemap write start
    stx @map_offset ; map_offset = 0

    phb                 ; save data bank register
    lda #01
    pha
    plb                 ; DBR = 1

tilemap_loop:

    rep #20
    phy
    tya
    beq @continue_loop
    dec
    eor 01,s
    and #0020
    beq @add_offset
    lda !map_offset
    clc
    adc @small_map+2
    sec
    sbc #0020
    sta !map_offset

add_offset:
    tya
    clc
    adc !map_offset
    tay

continue_loop:
    sep #20

    lda @small_map+6,y  ; +6: account for map size + width/height header
    ply
    sta !tilemap_buffer,x
    inx
    lda #00
    sta !tilemap_buffer,x
    inx

    iny
    cpy #400            ; copy one full tilemap (32x32 tiles)
    bne @tilemap_loop

    plb                 ; restore data bank register
    rts

VramDmaTransfer:
    phx                 ; save stack pointer
    phd                 ; save direct page
    tsc
    tcd                 ; direct page = stack pointer

    ldx 0c              ; vram dest addr
    stx 2116

    lda #18             ; VMDATAL 21*18*
    sta 4301

    ldx 0a              ; rom src addr
    stx 4302
    lda 09              ; rom src bank
    sta 4304

    ldx 07              ; nb of bytes to transfer
    stx 4305

    lda #01
    sta 4300

    lda #01
    sta 420b

    pld                 ; restore direct page
    plx                 ; restore stack pointer
    rts

CgramDmaTransfer:
    phx                 ; save stack pointer
    phd                 ; save direct page
    tsc
    tcd                 ; direct page = stack pointer

    lda 0b              ; cgram dest addr
    sta 2121

    lda #22
    sta 4301

    ldx 09              ; rom src addr
    stx 4302
    lda 08              ; rom src bank
    sta 4304

    lda 07              ; nb of bytes to transfer
    sta 4305

    lda #00
    sta 4300

    lda #01
    sta 420b

    pld
    plx
    rts

ClearRegisters:
    stz 2101
    stz 2102
    stz 2103
    stz 2105
    stz 2106
    stz 2107
    stz 2108
    stz 2109
    stz 210a
    stz 210b
    stz 210c

    rep #20

    stz 210d
    stz 210d
    stz 210e
    stz 210e
    stz 210f
    stz 210f
    stz 2110
    stz 2110
    stz 2111
    stz 2111
    stz 2112
    stz 2112
    stz 2113
    stz 2113
    stz 2114
    stz 2114

    sep #20

    lda #80
    sta 2115
    stz 2116
    stz 2117
    stz 211a

    rep #20

    lda #0001
    sta 211b
    stz 211c
    stz 211d
    sta 211e
    stz 211f
    stz 2120

    sep #20

    stz 2121
    stz 2123
    stz 2124
    stz 2125
    stz 2126
    stz 2127
    stz 2128
    stz 2129
    stz 212a
    stz 212b
    lda #01
    sta 212c
    stz 212d
    stz 212e
    stz 212f
    lda #30
    sta 2130
    stz 2131
    lda #e0
    sta 2132
    stz 2133

    stz 4200
    lda #ff
    sta 4201
    stz 4202
    stz 4203
    stz 4204
    stz 4205
    stz 4206
    stz 4207
    stz 4208
    stz 4209
    stz 420a
    stz 420b
    stz 420c
    lda #01
    sta 420d

    rts

;**************************************
; ROM registration data
;**************************************
.org ffb0
.base 7fb0

; zero bytes
    .db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
; game title "TILEMAP DEMO         "
    .db 53,55,50,45,52,20,53,4e,41,4b,45,20,20,20,20,20,20,20,20,20,20
; map mode
    .db 30
; cartridge type
    .db 00
; ROM size
    .db 09
; RAM size
    .db 01
; destination code
    .db 00
; fixed value
    .db 33
; mask ROM version
    .db 00
; checksum complement
    .db 00,00
; checksum
    .db 00,00

;**************************************
; Vectors
;**************************************
.org ffe0
.base 7fe0

; zero bytes
    .db 00,00,00,00
; 65816 mode
    .db 00,00           ; COP
    .db @BreakVector    ; BRK
    .db 00,00
    .db @NmiVector      ; NMI
    .db 00,00
    .db 00,00           ; IRQ

; zero bytes
    .db 00,00,00,00
; 6502 mode
    .db 00,00           ; COP
    .db 00,00
    .db 00,00
    .db 00,00           ; NMI
    .db @ResetVector    ; RESET
    .db 00,00           ; IRQ/BRK
