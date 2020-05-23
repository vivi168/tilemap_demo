;**************************************
; TileMap Demo
;
; tilemap format
; tile number lowest 8 bits
; vert flip | hori flip | prio bit | pal no H | pal no M | pal no L | tile number 10th bit | tile number 9th bith
;**************************************
.65816

.org 018000
.base 8000

tileset:
    .incbin assets/tileset.bin
tileset_palette:
    .incbin assets/tileset-pal.bin
small_map:
    .incbin assets/small.bin
medium_map:
    .incbin assets/medium.bin
big_map:
    .incbin assets/big.bin

.org 7e0000
joy1_raw:
    .rb 2
joy1_press:
    .rb 2
joy1_held:
    .rb 2
screen_x_velocity:
    .rb 2
screen_y_velocity:
    .rb 2
screen_tm_x:            ; screen position relative to tilemap
    .rb 1
screen_tm_y:
    .rb 1
prev_screen_tm_x:
    .rb 1
prev_screen_tm_y:
    .rb 1
screen_m_x:             ; screen position relative to map
    .rb 2
screen_m_y:
    .rb 2
prev_screen_m_x:
    .rb 2
prev_screen_m_y:
    .rb 2

current_map:            ; pointer to current map (map should always be in same bank)
    .rb 3
current_map_width:      ; width of current map (in tiles)
    .rb 2
current_map_height:     ; height of current map (in tiles)
    .rb 2
current_map_width_pixel:
    .rb 2
current_map_height_pixel:
    .rb 2
tilemap_buffer:
    .rb 800

.org 008000
.base 0000

ResetVector:
    sei                 ; disable interrupts
    clc
    xce
    sep #20             ; M8
    rep #10             ; X16

    ldx #1fff
    txs                 ; set stack pointer to 1fff

    ; Forced Blank
    lda #80
    sta 2100            ; INIDISP
    jsr @ClearRegisters

    ; ---- BG settings
    lda #01
    sta 2105            ; BGMODE 1

    lda @screen_tm_x    ; first write = lower byte
    sta 210d
    lda #00             ; second write = upper 2 bits
    sta 210d            ; horizontal scroll
    lda @screen_tm_y
    dec
    sta 210e
    lda #00
    sta 210e            ; vertical scroll. caution, offset by -1

    lda #10             ; BG1 MAP @ VRAM[2000]
    sta 2107            ; BG1SC
    lda #00             ; BG1 tiles @ VRAM[0000]
    sta 210b            ; BG12NBA

    lda #01             ; enable BG1&3
    sta 212c            ; TM

    ; windowing settings
    lda #03
    sta 2123
    lda #08
    sta 2126
    lda #f7
    sta 2127
    lda #01
    sta 212e

    ; --- some initialization
    rep #20
    lda !big_map+2
    sta @current_map_width
    asl
    asl
    asl
    sta @current_map_width_pixel
    lda !big_map+4
    sta @current_map_height
    asl
    asl
    asl
    sta @current_map_height_pixel
    sep #20
    ldx #@big_map+6
    stx @current_map
    lda #^big_map+6
    sta @current_map+2
    ; ---

    tsx
    pea 0000
    pea 0000
    jsr @InitTilemapBuffer
    txs

    ; ---- DMA transfers ---
    ; Copy tilemap buffer to VRAM
    tsx                 ; save stack pointer
    pea 1000            ; vram dest addr (@2000 really, word steps)
    pea @tilemap_buffer
    lda #^tilemap_buffer
    pha
    pea 0800            ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy tileset.bin to VRAM
    tsx                 ; save stack pointer
    pea 0000            ; vram dest addr (@0000 really, word steps)
    pea @tileset
    lda #^tileset
    pha
    pea 0400            ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    ; Copy tileset-pal.bin to CGRAM
    tsx                 ; save stack pointer
    lda #00             ; cgram dest addr (@0000 really, 2 bytes step)
    pha
    pea @tileset_palette
    lda #^tileset_palette
    pha
    lda #20             ; bytes_to_trasnfer
    pha
    jsr @CgramDmaTransfer
    txs                 ; restore stack pointer
    ; ----

    lda #0f             ; release forced blanking, set screen to full brightness
    sta 2100            ; INIDISP

    lda #81             ; enable NMI, turn on automatic joypad polling
    sta 4200            ; NMITIMEN
    cli                 ; enable interrupts

    jmp @MainLoop

BreakVector:
    rti

NmiVector:
    php
    rep #30
    pha
    phx
    phy

    sep #20
    rep #10

    lda 4210            ; RDNMI

    jsr @ReadJoyPad1

    lda @screen_tm_x
    sta 210d
    lda #00
    sta 210d

    lda @screen_tm_y
    dec                 ; Y scroll is offset by -1 (hardware quirk)
    sta 210e
    lda #00
    sta 210e

    ; Copy tilemap buffer to VRAM
    tsx                 ; save stack pointer
    pea 1000            ; vram dest addr (@2000 really, word steps)
    pea @tilemap_buffer
    lda #^tilemap_buffer
    pha
    pea 0800            ; nb of bytes to transfer
    jsr @VramDmaTransfer
    txs                 ; restore stack pointer

    rep #30
    ply
    plx
    pla
    plp
    rti

MainLoop:
    wai

    jsr @HandleInput
    jsr @UpdateBGScroll

    jmp @MainLoop


HandleInput:
    rep #20

    lda @joy1_held

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
    lda #fffe           ; negative velocity
    sta @screen_y_velocity
    stz @screen_x_velocity
    bra @exit_handle_input

move_down:
    lda #0002           ; positive velocity
    sta @screen_y_velocity
    stz @screen_x_velocity
    bra @exit_handle_input

move_left:
    lda #fffe
    sta @screen_x_velocity
    stz @screen_y_velocity
    bra @exit_handle_input

move_right:
    lda #0002
    sta @screen_x_velocity
    stz @screen_y_velocity

exit_handle_input:
    sep #20
    rts

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

ClearRegisters:
    stz 2101
    stz 2102
    stz 2103
    stz 2105
    stz 2106
    stz 2107
    stz 2108
    stz 2109
    stz 210a
    stz 210b
    stz 210c

    rep #20

    stz 210d
    stz 210d
    stz 210e
    stz 210e
    stz 210f
    stz 210f
    stz 2110
    stz 2110
    stz 2111
    stz 2111
    stz 2112
    stz 2112
    stz 2113
    stz 2113
    stz 2114
    stz 2114

    sep #20

    lda #80
    sta 2115
    stz 2116
    stz 2117
    stz 211a

    rep #20

    lda #0001
    sta 211b
    stz 211c
    stz 211d
    sta 211e
    stz 211f
    stz 2120

    sep #20

    stz 2121
    stz 2123
    stz 2124
    stz 2125
    stz 2126
    stz 2127
    stz 2128
    stz 2129
    stz 212a
    stz 212b
    lda #01
    sta 212c
    stz 212d
    stz 212e
    stz 212f
    lda #30
    sta 2130
    stz 2131
    lda #e0
    sta 2132
    stz 2133

    stz 4200
    lda #ff
    sta 4201
    stz 4202
    stz 4203
    stz 4204
    stz 4205
    stz 4206
    stz 4207
    stz 4208
    stz 4209
    stz 420a
    stz 420b
    stz 420c
    lda #01
    sta 420d

    ; ---- custom registers

    stz @screen_tm_x
    stz @screen_tm_y
    stz @prev_screen_tm_x
    stz @prev_screen_tm_y
    stz @screen_x_velocity
    stz @screen_y_velocity
    rep #20
    stz @screen_m_x
    stz @screen_m_y
    stz @prev_screen_m_x
    stz @prev_screen_m_y
    sep #20


    rts

;**************************************
; ROM registration data
;**************************************
.org ffb0
.base 7fb0

; zero bytes
    .db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
; game title "TILEMAP DEMO         "
    .db 53,55,50,45,52,20,53,4e,41,4b,45,20,20,20,20,20,20,20,20,20,20
; map mode
    .db 30
; cartridge type
    .db 00
; ROM size
    .db 09
; RAM size
    .db 01
; destination code
    .db 00
; fixed value
    .db 33
; mask ROM version
    .db 00
; checksum complement
    .db 00,00
; checksum
    .db 00,00

;**************************************
; Vectors
;**************************************
.org ffe0
.base 7fe0

; zero bytes
    .db 00,00,00,00
; 65816 mode
    .db 00,00           ; COP
    .db @BreakVector    ; BRK
    .db 00,00
    .db @NmiVector      ; NMI
    .db 00,00
    .db 00,00           ; IRQ

; zero bytes
    .db 00,00,00,00
; 6502 mode
    .db 00,00           ; COP
    .db 00,00
    .db 00,00
    .db 00,00           ; NMI
    .db @ResetVector    ; RESET
    .db 00,00           ; IRQ/BRK
