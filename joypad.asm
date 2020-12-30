.define JOY_UP      0800
.define JOY_DOWN    0400
.define JOY_LEFT    0200
.define JOY_RIGHT   0100

.define VEL_PL      0002    ; positive velocity
.define VEL_MI      fffe    ; negative velocity

.define PLAYER_VEL_PL 01
.define PLAYER_VEL_MI ff

.define PLAYER_VEL_PL16 0001
.define PLAYER_VEL_MI16 ffff

ReadJoyPad1:
    php
read_joy1_data:
    lda HVBJOY          ; read joypad status
    and #01
    bne @read_joy1_data ; read done when 0

    rep #30             ; m16, x16

    ldx @joy1_raw       ; read previous frame raw input
    lda JOY1L           ; read current frame raw input (JOY1L)
    sta @joy1_raw       ; save it
    txa                 ; move previous frame raw input to A
    eor @joy1_raw       ; XOR previous with current, get changes. Held and unpressed become 0
    and @joy1_raw       ; AND previous with current, only pressed left to 1
    sta @joy1_press     ; store pressed
    txa                 ; move previous frame raw input to A
    and @joy1_raw       ; AND with current, only held are left to 1
    sta @joy1_held      ; stored held

    plp
    rts

HandleInput:
    php

    ; don't register input if player is moving
    ; (player.x * 8 != player.px => player is moving)
    sep #20
    lda @player_x
    rep #20
    and #00ff
    asl
    asl
    asl
    cmp @player_px
    bne @clean_exit_handle_input

    sep #20

    lda @player_y
    rep #20
    and #00ff
    asl
    asl
    asl
    cmp @player_py
    bne @clean_exit_handle_input

    lda @joy1_held

    bit #JOY_UP
    bne @move_up

    bit #JOY_DOWN
    bne @move_down

    bit #JOY_LEFT
    bne @move_left

    bit #JOY_RIGHT
    bne @move_right

clean_exit_handle_input:
    sep #20

    stz @player_velocity_x
    stz @player_velocity_y
    bra @exit_handle_input

move_up:
    lda #PLAYER_VEL_MI16
    sta @player_velocity_py
    sep #20
    lda #PLAYER_VEL_MI
    sta @player_velocity_y
    stz @player_velocity_x
    bra @exit_handle_input

move_down:
    lda #PLAYER_VEL_PL16
    sta @player_velocity_py
    sep #20
    lda #PLAYER_VEL_PL
    sta @player_velocity_y
    stz @player_velocity_x
    bra @exit_handle_input

move_left:
    lda #PLAYER_VEL_MI16
    sta @player_velocity_px
    sep #20
    lda #PLAYER_VEL_MI
    sta @player_velocity_x
    stz @player_velocity_y
    bra @exit_handle_input

move_right:
    lda #PLAYER_VEL_PL16
    sta @player_velocity_px
    sep #20
    lda #PLAYER_VEL_PL
    sta @player_velocity_x
    stz @player_velocity_y

exit_handle_input:
    plp
    rts
