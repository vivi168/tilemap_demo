# TODO

## TileMap Engine

1. ~~Load tileset into VRAM~~
2. ~~Load tileset palette into CGRAM~~
3. ~~BG initial settings~~

4. ~~Map to Tilemap routine~~
5. ~~Map to Tilemap routine - take bg scroll and screen size into account (write where screen start, and only screen wide/high portion of map)~~

6. ~~Map column to Tilemap routine~~
7. ~~Map row to Tilemap routine~~

- Maybe pass map address as a parameter
- ~~Rewrite InitTilemapBuffer to use either column or row routine (whichever is quicker) in a loop to init map~~

8. ~~allow scrolling with arrows~~

- ~~register arrow presses & update bg scroll accordingly~~
- ~~keep track of bg scroll position relative to map (top left corner of screen)~~
- ~~keep track of bg scroll position relative to tilemap (top left corner of screen)~~
- ~~routine to convert screen top left position to map index/tilemap index~~
- ~~use bg scroll to copy a new row/column when crossing a row/column threshold (every 8px)~~

## BG update strategy:
```
if (screen_m_x < 0 || screen_m_x > map_w - screen_w) || (screen_m_y < 0 || screen_m_y > map_h - screen_h)
    => stop scrolling to prevent going out of bound

if screen_tm_x crosses 8 threshold : update column
if screen_tm_y crosses 8 threshold : update row
```
9. ~~test with medium map~~
10. ~~test with big map~~
11. change map with A,B,X,Y

???

Profit.
