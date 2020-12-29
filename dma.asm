VramDmaTransfer:
    phx                 ; save stack pointer
    phd                 ; save direct page
    tsc
    tcd                 ; direct page = stack pointer

    ldx 0c              ; vram dest addr
    stx VMADDL

    lda #18             ; VMDATAL 21*18*
    sta BBAD0

    ldx 0a              ; rom src addr
    stx A1T0L
    lda 09              ; rom src bank
    sta A1T0B

    ldx 07              ; nb of bytes to transfer
    stx DAS0L

    lda #01
    sta DMAP0

    lda #01
    sta MDMAEN

    pld                 ; restore direct page
    plx                 ; restore stack pointer
    rts

CgramDmaTransfer:
    phx                 ; save stack pointer
    phd                 ; save direct page
    tsc
    tcd                 ; direct page = stack pointer

    lda 0b              ; cgram dest addr
    sta CGADD

    lda #22
    sta BBAD0

    ldx 09              ; rom src addr
    stx A1T0L
    lda 08              ; rom src bank
    sta A1T0B

    lda 07              ; nb of bytes to transfer
    sta DAS0L

    lda #00
    sta DMAP0

    lda #01
    sta MDMAEN

    pld
    plx
    rts

TransferOamBuffer:
    ldx #0000
    stx OAMADDL

    lda #04         ; OAMDATA 21*04*
    sta BBAD0

    ; from 7e/2000
    ldx #@oam_buffer
    stx A1T0L
    lda #^oam_buffer
    sta A1T0B

    ; transfer 220 bytes
    ldx #0220
    stx DAS0L

    ; DMA params: A to B
    lda #00
    sta DMAP0
    ; initiate DMA via channel 0 (LSB = channel 0, MSB channel 7)
    lda #01
    sta MDMAEN
    rts
