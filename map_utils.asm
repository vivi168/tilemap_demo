;**************************************
;
; Update Background Scrolling
;
;**************************************
UpdateBGScroll:
    php

    rep #20
    lda @screen_x_velocity
    beq @check_vertical_scrolling

    ldx @screen_m_x
    stx @prev_screen_m_x

    clc
    adc @screen_m_x
    sta @screen_m_x

    cmp #0000
    bmi @skip_horizontal_scrolling

    clc
    adc #0100
    cmp @current_map_width_pixel
    beq @continue_horizontal_scrolling
    bcs @skip_horizontal_scrolling

continue_horizontal_scrolling:
    jsr @UpdateBGHorizontalScroll
    bra @check_vertical_scrolling

skip_horizontal_scrolling:
    lda @prev_screen_m_x
    sta @screen_m_x

check_vertical_scrolling:

    lda @screen_y_velocity
    beq @exit_update_bg_scroll

    ldx @screen_m_y
    stx @prev_screen_m_y

    clc
    adc @screen_m_y
    sta @screen_m_y

    cmp #0000
    bmi @skip_vertical_scrolling

    clc
    adc #00e0
    cmp @current_map_height_pixel
    beq @continue_vertical_scrolling
    bcs @skip_vertical_scrolling

continue_vertical_scrolling:
    jsr @UpdateBGVerticalScroll
    bra @exit_update_bg_scroll

skip_vertical_scrolling:
    lda @prev_screen_m_y
    sta @screen_m_y

exit_update_bg_scroll:
    plp
    rts

;**************************************
;
; Update Background Horizontal Scrolling
;
;**************************************
UpdateBGHorizontalScroll:
    php
    sep #20

    lda @screen_tm_x
    sta @prev_screen_tm_x

    clc
    adc @screen_x_velocity
    sta @screen_tm_x

    cmp @prev_screen_tm_x
    bpl @update_column_ahead

    jsr @TilemapIndexFromScreenCoords
    jsr @MapIndexFromScreenCoords
    bra @copy_new_column

update_column_ahead:
    lda @prev_screen_tm_x

    lda @screen_tm_x
    pha
    lda @prev_screen_tm_x
    sta @screen_tm_x
    jsr @TilemapIndexFromScreenCoords
    pla
    sta @screen_tm_x

    rep #20
    lda @screen_m_x
    pha
    lda @prev_screen_m_x
    clc
    adc #0100
    sta @screen_m_x
    jsr @MapIndexFromScreenCoords
    pla
    sta @screen_m_x
    sep #20

copy_new_column:
    phy
    phx
    jsr @CopyMapColumnToTileMapBuffer
    plx
    ply

skip_column_update:
    plp
    rts

;**************************************
;
; Update Background Vertical Scrolling
;
;**************************************
UpdateBGVerticalScroll:
    php
    sep #20

    lda @screen_tm_y
    sta @prev_screen_tm_y

    clc
    adc @screen_y_velocity
    sta @screen_tm_y

    lda @prev_screen_tm_y
    bit #07
    bne @skip_row_update

    cmp @screen_tm_y
    bmi @update_row_ahead

    jsr @TilemapIndexFromScreenCoords
    jsr @MapIndexFromScreenCoords
    bra @copy_new_row

update_row_ahead:
    lda @screen_tm_y
    pha
    clc
    adc #e0
    sta @screen_tm_y
    jsr @TilemapIndexFromScreenCoords
    pla
    sta @screen_tm_y

    rep #20
    lda @screen_m_y
    pha
    clc
    adc #00e0
    sta @screen_m_y
    jsr @MapIndexFromScreenCoords
    pla
    sta @screen_m_y
    sep #20

copy_new_row:
    phy
    phx
    jsr @CopyMapRowToTileMapBuffer
    plx
    ply

skip_row_update:
    plp
    rts

;**************************************
;
; result in X
;
;**************************************
TilemapIndexFromScreenCoords:
    php

    sep #20
    lda @screen_tm_x
    lsr
    lsr
    lsr                 ; x //= 8
    rep #20
    and #00ff
    pha

    sep #20
    lda @screen_tm_y
    cmp #08
    bcc @skip_tm_y_calculation      ; no need to do complex math on y < 8 (index 0)

    lsr
    lsr
    lsr                 ; y //= 8
    rep #20
    and #00ff
    asl
    asl
    asl
    asl
    asl                 ; y *= screen_w (32)
    clc
    adc 01,s
    plx
    bra @exit_tm_index

skip_tm_y_calculation:
    rep #20
    pla

exit_tm_index:
    asl                 ; x2 because tilemap entries are 2 bytes long
    tax                 ; save index in x

    plp
    rts

;**************************************
;
; result in Y
;
;**************************************
MapIndexFromScreenCoords:
    php
    phd

    ldy @screen_m_y
    phy ; p1

    tsc
    tcd

    rep #20
    lda @screen_m_x
    lsr
    lsr
    lsr

    cpy #0008
    bcc @skip_m_y_calculation

    pha ; p2

    lsr 01
    lsr 01
    lsr 01

    lda @current_map_width
    lsr
mult_y_by_map_w:
    asl 01
    lsr
    bne @mult_y_by_map_w

    pla ; p2
    clc
    adc 01

skip_m_y_calculation:
    ply ; p1

    tay

    pld
    plp
    rts


;**************************************
;
; arg1(@0a) = map read start, arg2(@08) = tilemap buffer write start
;
;**************************************
CopyMapColumnToTileMapBuffer:
    phx
    phd

    ; --- reserve local variables on the stack
    lda @current_map+2
    pha
    ldx @current_map
    phx
    lda #20
    pha                 ; loop counter

    tsc
    tcd

    ldy 0d              ; pointer to map read start, should be a PARAM
    ldx 0b              ; pointer to tilemap write start. multiple of 2 because tile is 2 bytes. should be determined by screen TM position

copy_column_loop:
    lda [02],y
    sta !tilemap_buffer,x
    inx
    lda #00
    sta !tilemap_buffer,x
    dex

    rep #20
    ; next map entry
    tya
    clc
    adc !current_map_width
    tay

    ; next tilemap entry
    txa
    clc
    adc #0040           ; 0x40 because vram entry are 2 bytes
    tax
    ; here wrap at row 0 if necessary
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr                 ; one additional shift right because tilemap is 2 bytes for one entry
    cmp #0020
    bcc @skip_column_wrap
    txa
    and #003f           ; #003f because tilemap index are multiple of 2s
    tax
skip_column_wrap:
    sep #20

    dec 01
    bne @copy_column_loop

    plx
    pla
    pla
    pld
    plx

    rts

; arg1(@0d) = map read start, arg2(@0b) = tilemap buffer write start
CopyMapRowToTileMapBuffer:
    phx
    phd

    ; --- reserve local variables on the stack
    lda @current_map+2
    pha
    ldx @current_map
    phx
    lda #20
    pha                 ; loop counter

    tsc
    tcd                 ; create a local frame

    ldy 0d              ; map read start initial map offset
    ldx 0b              ; load tilemap buffer write start offset

copy_row_loop:
    lda [02],y
    iny
    sta !tilemap_buffer,x
    inx
    lda #00
    sta !tilemap_buffer,x
    inx

    rep #20
    txa
    ; here wrap at column  0 if necessary
    bit #003f
    bne @skip_row_wrap
    sec
    sbc #0040
    tax

skip_row_wrap:
    sep #20

    dec 01
    bne @copy_row_loop

    plx                 ; clean up after ourselve
    pla
    pla
    pld
    plx

    rts

; arg1(@0b) = map read start, arg2(@09) = tilemap buffer write start
InitTilemapBuffer:
    phx
    phd
    php

    lda #1c             ; loop counter
    pha                 ; reserve as local variable

    tsc
    tcd
init_map_loop:

    tsx

    rep #20
    lda 0b              ; pointer to map read start
    pha
    clc
    adc !current_map_width
    sta 0b              ; update for next loop iteration

    lda 09              ; pointer to tilemap write start. multiple of 2 because tile is 2 bytes. should be determined by screen TM position
    pha
    clc
    adc #0040           ; tilemap are multiple of 2s
    sta 09              ; update for next loop iteration
    sep #20

    jsr @CopyMapRowToTileMapBuffer
    txs

    dec 01
    bne @init_map_loop

    pla                 ; clean up after ourselve
    plp
    pld
    plx

    rts
