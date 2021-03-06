;**************************************
; TileMap Demo
;
; tilemap format
; tile number lowest 8 bits
; vert flip | hori flip | prio bit | pal no H | pal no M | pal no L | tile number 10th bit | tile number 9th bith
;**************************************
.65816

.include var.asm
.include assets.asm

.org 008000
.base 0000

.include vectors.asm
.include init.asm
.include dma.asm
.include joypad.asm
.include map_utils.asm

MainLoop:
    wai

    jsr @HandleInput
    jsr @UpdateBGScroll

    jmp @MainLoop

.include info.asm
