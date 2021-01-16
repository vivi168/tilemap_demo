.define STACK_SIZE 1fff

ResetVector:
    sei                 ; disable interrupts
    clc
    xce
    cld
    jmp !FastReset
FastReset:
    sep #20             ; M8
    rep #10             ; X16

    ldx #STACK_SIZE
    txs                 ; set stack pointer to 1fff

    lda #01
    sta @MEMSEL

    ; Forced Blank
    lda #80
    sta INIDISP
    jsr @ClearRegisters

    ; ---- BG settings
    lda #01
    sta BGMODE

    lda @bg_scroll_x    ; first write = lower byte
    sta BG1HOFS
    lda #00             ; second write = upper 2 bits
    sta BG1HOFS         ; horizontal scroll
    lda @bg_scroll_y
    dec
    sta BG1VOFS
    lda #00
    sta BG1VOFS         ; vertical scroll. caution, offset by -1

    lda #10             ; BG1 MAP @ VRAM[2000]
    sta BG1SC
    lda #00             ; BG1 tiles @ VRAM[0000]
    sta BG12NBA

    lda #11             ; enable BG1 + sprites
    sta TM

    ; --- OBJ settings
    lda #62             ; sprite 16x16 small, 32x32 big
    sta OBJSEL          ; oam start @VRAM[8000]

    jsr @InitOamBuffer
    jsr @TransferOamBuffer

    ; --- windowing settings
    lda #03
    sta W12SEL
    lda #08
    sta WH0
    lda #f7
    sta WH1
    lda #01
    sta TMW

    ; --- some initialization
    rep #20
    lda !big_map+2              ; map[2] = height|width
    xba
    and #00ff
    sta @current_map_width
    asl
    asl
    asl
    sta @current_map_width_pixel
    lda !big_map+2              ; map[2] = height|width
    and #00ff
    sta @current_map_height
    asl
    asl
    asl
    sta @current_map_height_pixel
    sep #20
    ldx #@big_map+4
    stx @current_map
    lda #^big_map+4
    sta @current_map+2          ; LL HH BB (little endian)
    ; ---

    tsx
    lda #13                     ; init player at [13,13] (16x16 grid)
    sta @player_x
    sta @player_y
    rep #20
    and #00ff
    asl
    asl
    asl
    asl
    sta @player_px              ; convert to pixel coord
    sta @player_py
    sep #20
    jsr @UpdateCamera           ; update camear coord
    jsr @MapIndexFromScreenCoords ; result in Y
    phy
    pea 0000
    jsr @InitTilemapBuffer
    txs

    ; ---- DMA transfers ---
    ; Copy tilemap buffer to VRAM
    tsx                 ; save stack pointer
    pea 1000            ; vram dest addr (@2000 really, word steps)
    pea @tilemap_buffer
    lda #^tilemap_buffer
    pha
    pea TILEMAP_SIZE    ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy tileset.bin to VRAM
    tsx                 ; save stack pointer
    pea 0000            ; vram dest addr (@0000 really, word steps)
    pea @tileset
    lda #^tileset
    pha
    pea TILESET_SIZE    ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy tileset-pal.bin to CGRAM
    tsx                 ; save stack pointer
    lda #00             ; cgram dest addr (@0000 really, 2 bytes step)
    pha
    pea @tileset_palette
    lda #^tileset_palette
    pha
    lda #PALETTE_SIZE   ; bytes_to_trasnfer
    pha
    jsr @CgramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy spritesheet.bin to VRAM
    tsx             ; save stack pointer
    pea 4000        ; vram_dest_addr
    pea @spritesheet
    lda #^spritesheet
    pha
    pea SPRTSHT_SIZE; bytes_to_trasnfer
    jsr @VramDmaTransfer
    txs             ; restore stack pointer

    ; Copy spritesheet-pal.bin to CGRAM
    tsx                 ; save stack pointer
    lda #80             ; cgram dest addr (@CGRAM[0100] really, 2 bytes step)
    pha
    pea @spritesheet_pal
    lda #^spritesheet_pal
    pha
    lda #PALETTE_SIZE   ; bytes_to_trasnfer
    pha
    jsr @CgramDmaTransfer
    txs                 ; restore stack pointer

    ; ----

    lda #0f             ; release forced blanking, set screen to full brightness
    sta INIDISP

    lda #81             ; enable NMI, turn on automatic joypad polling
    sta NMITIMEN
    cli                 ; enable interrupts

    jmp @MainLoop

BreakVector:
    rti

NmiVector:
    php
    rep #30
    pha
    phx
    phy

    sep #20
    rep #10

    lda RDNMI

    jsr @ReadJoyPad1

    lda @bg_scroll_x
    sta BG1HOFS
    lda #00
    sta BG1HOFS

    lda @bg_scroll_y
    dec                 ; Y scroll is offset by -1 (hardware quirk)
    sta BG1VOFS
    lda #00
    sta BG1VOFS

    ; Copy tilemap buffer to VRAM
    tsx                 ; save stack pointer
    pea 1000            ; vram dest addr (@2000 really, word steps)
    pea @tilemap_buffer
    lda #^tilemap_buffer
    pha
    pea TILEMAP_SIZE    ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    jsr @TransferOamBuffer

    rep #30
    ply
    plx
    pla
    plp
    rti
