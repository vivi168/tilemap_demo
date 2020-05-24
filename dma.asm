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
