.define OAML_SIZE   0200
.define OAM_SIZE    0220

; clear oam buffer with off screen sprites
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
    cpx #OAML_SIZE
    bne @set_x_lsb

    lda #55         ; 01010101
set_x_msb:
    sta !oam_buffer,x
    inx
    sta !oam_buffer,x
    inx
    cpx #OAM_SIZE
    bne @set_x_msb

    plp
    rts

DrawSprite:
    rts

; input in X : sprite index
UpdatePlayer:
    php

    lda @player_sx
    lda #78
    sta !oam_buffer

    lda @player_sy
    lda #68
    sta !oam_buffer+1

    ; tile_no (get from player state)
    lda #00
    sta !oam_buffer+2

    ; attributes
    ; vhpp cccn
    ; 0011 0000
    lda #30
    sta !oam_buffer+3

    jsr @SetSpriteStatus

    plp
    rts

; set OAM hi params
; input in X : sprite index
; input in A : status
SetSpriteStatus:
    lda #54
    sta !oam_buffer_hi

    rts

PlayerAnimTable:
stand_down:     .db 01,  01          ; [0] first entry is array size, next are sprite indices
stand_up:       .db 01,  04          ; [1]
stand_left:     .db 01,  07          ; [2]
stand_right:    .db 01,  87          ; [3] if (128 & idx == 128 => idx = 128 ^ idx => flip sprite horizontal)
walk_down:      .db 03,  00, 01, 02  ; [4]
walk_up:        .db 03,  03, 04, 05  ; [5]
walk_left:      .db 02,  06, 07      ; [6]
walk_right:     .db 02,  86, 87      ; [7]
