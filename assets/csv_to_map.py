import csv

tiles = []

with open('small.csv') as csvfile:
    csv_reader = csv.reader(csvfile)
    height = 0
    for row in csv_reader:
        height += 1
        width = 0
        for tile in row:
            width += 1
            tiles.append(int(tile))


raw_tilemap = [width, height] + tiles
raw_tilemap + [0] * (256 - len(raw_tilemap) % 256)

tilemap = bytearray(raw_tilemap)
with open('small.bin', 'wb') as out_file:
    out_file.write(tilemap);
