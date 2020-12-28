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

    lda @bg_scroll_x    ; first write = lower byte
    sta 210d
    lda #00             ; second write = upper 2 bits
    sta 210d            ; horizontal scroll
    lda @bg_scroll_y
    dec
    sta 210e
    lda #00
    sta 210e            ; vertical scroll. caution, offset by -1

    lda #10             ; BG1 MAP @ VRAM[2000]
    sta 2107            ; BG1SC
    lda #00             ; BG1 tiles @ VRAM[0000]
    sta 210b            ; BG12NBA

    lda #11             ; enable BG1 + sprites
    sta 212c            ; TM

    ; --- OBJ settings
    lda #62             ; sprite 16x16 small, 32x32 big
    sta 2101            ; oam start @VRAM[8000]

    jsr @InitOamBuffer
    jsr @TransferOamBuffer

    ; --- windowing settings
    lda #03
    sta 2123
    lda #08
    sta 2126
    lda #f7
    sta 2127
    lda #01
    sta 212e

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
    ; formula
    ; first param = map_index, = (camera_x + camera_y * width) / 8
    ; eg : camera_x = 0x268, camera_y = 0x38, pea 0x3cd
    ldy #0168
    sty @camera_x
    ldy #0068
    sty @camera_y
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
    pea 0800            ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy tileset.bin to VRAM
    tsx                 ; save stack pointer
    pea 0000            ; vram dest addr (@0000 really, word steps)
    pea @tileset
    lda #^tileset
    pha
    pea 0a00            ; nb of bytes to transfer
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

    ; Copy spritesheet.bin to VRAM
    tsx             ; save stack pointer
    pea 4000        ; vram_dest_addr
    pea @spritesheet
    lda #^spritesheet
    pha
    pea 0400        ; bytes_to_trasnfer
    jsr @VramDmaTransfer
    txs             ; restore stack pointer

    ; Copy spritesheet-pal.bin to CGRAM
    tsx                 ; save stack pointer
    lda #80             ; cgram dest addr (@CGRAM[0100] really, 2 bytes step)
    pha
    pea @spritesheet_pal
    lda #^spritesheet_pal
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
    php
    rep #30
    pha
    phx
    phy

    sep #20
    rep #10

    lda 4210            ; RDNMI

    jsr @ReadJoyPad1

    lda @bg_scroll_x
    sta 210d
    lda #00
    sta 210d

    lda @bg_scroll_y
    dec                 ; Y scroll is offset by -1 (hardware quirk)
    sta 210e
    lda #00
    sta 210e

    ; Copy tilemap buffer to VRAM
    tsx                 ; save stack pointer
    pea 1000            ; vram dest addr (@2000 really, word steps)
    pea @tilemap_buffer
    lda #^tilemap_buffer
    pha
    pea 0800            ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    jsr @TransferOamBuffer

    rep #30
    ply
    plx
    pla
    plp
    rti
