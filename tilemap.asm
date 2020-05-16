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
    .incbin assets/small.bin

.org 7e0000
tilemap_buffer:
    .rb 0800

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

    lda #00
    sta 210d
    sta 210d
    sta 210e
    sta 210e

    lda #10             ; BG1 MAP @ VRAM[2000]
    sta 2107            ; BG1SC
    lda #00             ; BG1 tiles @ VRAM[0000]
    sta 210b            ; BG12NBA

    lda #01             ; enable BG1&3
    sta 212c            ; TM

    ; ---- DMA transfers ---
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


InitTilemapBuffer:
;**************************************
; tilemap format
; tile number lowest 8 bits
; vert flip | hori flip | prio bit | pal no H | pal no M | pal no L | tile number 10th bit | tile number 9th bith
;**************************************


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
