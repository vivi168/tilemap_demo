.define OAML_SIZE   0200
.define OAM_SIZE    0220

.define FRAME_STEP 0f ; change animation every X frame

.define STAND_DOWN  00
.define WALK_DOWN   02
.define STAND_UP    07
.define WALK_UP     09
.define STAND_LEFT  0e
.define WALK_LEFT   10
.define STAND_RIGHT 13
.define WALK_RIGHT  15

;**************************************
;
; clear oam buffer with off screen sprites
;
;**************************************
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

;**************************************
;
; input in X : sprite index
;
;**************************************
UpdatePlayer:
    php

    ;;; X COORD. skip if velocity_x = 0
    lda @player_velocity_x
    beq @update_px

    ; move horizontaly, so previous Y coord is now same as current
    lda @player_y
    sta @prev_player_y

    lda @player_x
    sta @prev_player_x
    clc
    adc @player_velocity_x
    sta @player_x

    ; TODO keep player X coord in bound here

update_px:
    lda @player_x
    ; player px += velocity_px if player.x*16 != player.px
    rep #20
    and #00ff
    asl
    asl
    asl
    asl
    cmp @player_px
    ; if player.x * 16 == player.px, skip. else, increment
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

    ; move vertically, so previous X coord is now same as current
    lda @player_x
    sta @prev_player_x

    lda @player_y
    sta @prev_player_y
    clc
    adc @player_velocity_y
    sta @player_y

    ; TODO keep player Y coord in bound here

update_py:
    lda @player_y
    ; player py += velocity_py if player.y*16 != player.py
    rep #20
    and #00ff
    asl
    asl
    asl
    asl
    cmp @player_py
    ; if player.y * 16 == player.py, skip. else, increment
    beq @skip_update_py
    lda @player_velocity_py
    clc
    adc @player_py
    sta @player_py

skip_update_py:

    jsr @UpdateCamera
    jsr @UpdatePlayerOAM

    plp
    rts

UpdatePlayerOAM:
    php

    ;;; OAM low buffer
    rep #20
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

    jsr @FindAnimTileNo

    bit #80
    bpl @skip_sprite_flip
    eor #80
    sta !oam_buffer+2

    ; attributes
    ; vhpp cccn
    ; 0111 0000
    lda #70
    sta !oam_buffer+3

    bra @update_oam_hi
skip_sprite_flip:
    sta !oam_buffer+2

    ; attributes
    ; vhpp cccn
    ; 0011 0000
    lda #30
    sta !oam_buffer+3

update_oam_hi:
    ;;; OAM hi buffer
    lda #54
    sta !oam_buffer_hi

    plp
    rts

; result in A
FindAnimTileNo:
    lda @player_anim_state
    sta @player_prev_anim_state

    lda @player_velocity_px
    beq @check_moving_vertically
    jsr @MovingHorizontaly
    bra @select_anim_frame

check_moving_vertically:
    lda @player_velocity_py
    beq @select_idle_sprite
    jsr @MovingVerticaly
    bra @select_anim_frame

select_idle_sprite:
    jsr @IdleSprite

; --- select animation frame ---
select_anim_frame:
    lda @frame_counter
    bit #FRAME_STEP
    bne @skip_frame_update
    inc @player_anim_frame
skip_frame_update:
    ; tile_no (get from player state)
    sep #10

    lda @player_anim_frame
    clc
    adc @player_anim_state
    tax

    lda @PlayerAnimTable,x
    cmp #ff
    bne @exit_find_anim_tileno
    ; loop back at animation beginning
    stz @player_anim_frame
    ldx @player_anim_state
    lda @PlayerAnimTable,x

exit_find_anim_tileno:
    rep #10
    rts

MovingHorizontaly:
    lda #WALK_LEFT
    sta @player_anim_state
check_prev_hori_anim_state:
    cmp @player_prev_anim_state
    beq @quit_moving_hori
    stz @player_anim_frame
quit_moving_hori:
    rts

MovingVerticaly:
    lda #WALK_DOWN
    sta @player_anim_state
check_prev_vert_anim_state:
    cmp @player_prev_anim_state
    beq @quit_moving_vert
    stz @player_anim_frame
quit_moving_vert:
    rts

IdleSprite:
    lda #STAND_DOWN
    sta @player_anim_state
check_prev_idl_anim_state:
    cmp @player_prev_anim_state
    beq @quit_idle_sprite
    stz @player_anim_frame
quit_idle_sprite:
    rts

PlayerAnimTable:
stand_down:     .db 02, ff              ; [0] ff marks end of entry
walk_down:      .db 00, 02, 04, 02, ff  ; [2]
stand_up:       .db 08, ff              ; [7]
walk_up:        .db 06, 08, 0a, 08, ff  ; [9]
stand_left:     .db 0e, ff              ; [14]
walk_left:      .db 0c, 0e, ff          ; [16]
stand_right:    .db 8e, ff              ; [19] if value is negative, flip sprite
walk_right:     .db 8c, 8e, ff          ; [21]
