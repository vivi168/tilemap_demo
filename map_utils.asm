UpdateCamera:
    php

    rep #20

    ; prev_camera_x = camera_x
    lda @camera_x
    sta @prev_camera_x

    ; camera_x += camera_velocity_x
    clc
    adc @camera_velocity_x
    sta @camera_x

    ; if camera_x < 0, camera_x = prev
    cmp #0000
    bmi @restore_camera_x

    ; if camera_x + screen_w > map_w, camera_x = prev
    clc
    adc #0100
    cmp @current_map_width_pixel
    beq @check_camera_y
    bcc @check_camera_y

restore_camera_x:
    lda @prev_camera_x
    sta @camera_x

check_camera_y:
    ; prev_camera_y = camera_y
    lda @camera_y
    sta @prev_camera_y

    ; camera_y += camera_velocity_y
    clc
    adc @camera_velocity_y
    sta @camera_y

    ; if camera_y < 0, camera_y = prev
    cmp #0000
    bmi @restore_camera_y

    ; if camera_y + screen_w > map_w, camera_y = prev
    clc
    adc #00e0
    cmp @current_map_height_pixel
    beq @exit_camera_update
    bcc @exit_camera_update

restore_camera_y:
    lda @prev_camera_y
    sta @camera_y

exit_camera_update:
    plp
    rts

;**************************************
;
; Update Background Scrolling
;
;**************************************
UpdateBGScroll:
    php

    rep #20
    lda @camera_x
    cmp @prev_camera_x
    beq @check_vertical_scrolling

    jsr @UpdateBGHorizontalScroll

check_vertical_scrolling:

    lda @camera_y
    cmp @prev_camera_y
    beq @exit_update_bg_scroll

    jsr @UpdateBGVerticalScroll

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

    ; save old scroll
    lda @bg_scroll_x
    sta @prev_bg_scroll_x

    ; new scroll = bg_scroll_x + (camera_x - prev_camera_x)
    lda @camera_x
    sec
    sbc @prev_camera_x
    clc
    adc @bg_scroll_x
    sta @bg_scroll_x

    ; skip update unless we are on a new tile threshold
    bit #07
    bne @skip_column_update
    cmp @prev_bg_scroll_x
    bpl @update_column_ahead

    jsr @TilemapIndexFromScreenCoords
    jsr @MapIndexFromScreenCoords
    bra @copy_new_column

update_column_ahead:
    lda @bg_scroll_x
    pha
    lda @prev_bg_scroll_x
    sta @bg_scroll_x
    jsr @TilemapIndexFromScreenCoords
    pla
    sta @bg_scroll_x

    rep #20
    lda @camera_x
    pha
    lda @prev_camera_x
    clc
    adc #0100
    sta @camera_x
    jsr @MapIndexFromScreenCoords
    pla
    sta @camera_x
    sep #20

copy_new_column:
    phy
    phx
    brk 00
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

    lda @bg_scroll_y
    sta @prev_bg_scroll_y

    lda @camera_y
    sec
    sbc @prev_camera_y
    clc
    adc @bg_scroll_y
    sta @bg_scroll_y

    lda @prev_bg_scroll_y
    bit #07
    bne @skip_row_update
    cmp @bg_scroll_y
    bmi @update_row_ahead

    jsr @TilemapIndexFromScreenCoords
    jsr @MapIndexFromScreenCoords
    bra @copy_new_row

update_row_ahead:
    lda @bg_scroll_y
    pha
    clc
    adc #e0
    sta @bg_scroll_y
    jsr @TilemapIndexFromScreenCoords
    pla
    sta @bg_scroll_y

    rep #20
    lda @camera_y
    pha
    clc
    adc #00e0
    sta @camera_y
    jsr @MapIndexFromScreenCoords
    pla
    sta @camera_y
    sep #20

copy_new_row:
    phy
    phx
    brk 00
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
    lda @bg_scroll_x
    lsr
    lsr
    lsr                 ; x //= 8
    rep #20
    and #00ff
    pha

    sep #20
    lda @bg_scroll_y
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
; formula: i = x + y * width
;**************************************
MapIndexFromScreenCoords:
    php

    lda @current_map_width ; should always be 8 bits (<= 255)
    sta 4202 ; multiplicand 1

    brk 00
    rep #20
    lda @camera_y
    ; camera_y //= 8
    ; -> ensure it's always 8 bits
    lsr
    lsr
    lsr
    sep #20
    sta 4203 ; multiplicand 2

    nop
    nop
    nop
    nop ; wait 8 cycles

    rep #20
    lda 4216 ; 16 bits mult result

    pha
    lda @camera_x
    lsr
    lsr
    lsr
    clc
    adc 01,s
    tay
    pla

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

    lda #20             ; loop counter, number of rows to copy
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
