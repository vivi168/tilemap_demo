.define OAML_SIZE   0200
.define OAM_SIZE    0220

.define ANIMATION_SPEED 02 ; change animation every X frame

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

    ;;; X COORD. skip if velocity_x = 0
    lda @player_velocity_x
    beq @update_px

    lda @player_x
    sta @prev_player_x
    lda @player_velocity_x
    clc
    adc @player_x
    sta @player_x

    ; TODO keep player X coord in bound here

update_px:
    lda @player_x
    ; player px += velocity_px if player.x*8 != player.px
    rep #20
    and #00ff
    asl
    asl
    asl
    cmp @player_px
    ; if player.x * 8 == player.px, skip. else, increment
    beq @skip_update_px
    lda @player_velocity_px
    clc
    adc @player_px
    sta @player_px

skip_update_px:

    sep #20

    ;;; Y COORD. skip if velocity_y = 0
    lda @player_velocity_y
    beq @update_py

    lda @player_y
    sta @prev_player_y
    lda @player_velocity_y
    clc
    adc @player_y
    sta @player_y

    ; TODO keep player Y coord in bound here

update_py:
    lda @player_y
    ; player py += velocity_py if player.y*8 != player.py
    rep #20
    and #00ff
    asl
    asl
    asl
    cmp @player_py
    ; if player.y * 8 == player.py, skip. else, increment
    beq @skip_update_py
    lda @player_velocity_py
    clc
    adc @player_py
    sta @player_py

skip_update_py:

    jsr @UpdateCamera

    ;;; UPDATE OAM

    lda @player_px
    sec
    sbc @camera_x
    sep #20
    sta !oam_buffer

    rep #20
    lda @player_py
    sec
    sbc @camera_y
    sep #20
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
