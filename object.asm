InitOamBuffer:
    php
    sep #20
    rep #10
    lda #01
    ldx #0000
set_x_lsb:
    sta !oam_buffer,x
    inx
    inx
    inx
    inx
    cpx #0200       ; $OAML_SIZE
    bne @set_x_lsb

    lda #55         ; 01010101
set_x_msb:
    sta !oam_buffer,x
    inx
    sta !oam_buffer,x
    inx
    cpx #0220       ; $OAM_SIZE
    bne @set_x_msb

    plp
    rts
