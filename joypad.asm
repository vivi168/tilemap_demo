ReadJoyPad1:
    php
read_joy1_data:
    lda 4212            ; read joypad status (HVBJOY)
    and #01
    bne @read_joy1_data ; read done when 0

    rep #30             ; m16, x16

    ldx @joy1_raw       ; read previous frame raw input
    lda 4218            ; read current frame raw input (JOY1L)
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
    rep #20

    lda @joy1_press

    bit #0800
    bne @move_up

    bit #0400
    bne @move_down

    bit #0200
    bne @move_left

    bit #0100
    bne @move_right

    stz @screen_x_velocity
    stz @screen_y_velocity
    bra @exit_handle_input

move_up:
    lda #fff8           ; negative velocity
    sta @screen_y_velocity
    stz @screen_x_velocity
    bra @exit_handle_input

move_down:
    lda #0008           ; positive velocity
    sta @screen_y_velocity
    stz @screen_x_velocity
    bra @exit_handle_input

move_left:
    lda #fff8
    sta @screen_x_velocity
    stz @screen_y_velocity
    bra @exit_handle_input

move_right:
    lda #0008
    sta @screen_x_velocity
    stz @screen_y_velocity

exit_handle_input:
    sep #20
    rts
