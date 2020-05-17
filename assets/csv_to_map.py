import csv

if __name__ == '__main__':
    tiles = []

    with open('big.csv') as csvfile:
        csv_reader = csv.reader(csvfile)
        height = 0
        for row in csv_reader:
            height += 1
            width = 0
            for tile in row:
                width += 1
                tiles.append(int(tile))

    map_size = width * height
    if map_size > 0xffff:
        exit('map to large')
    ms_b1, ms_b2 = (map_size & 0xffff).to_bytes(2, 'big')

    print(hex(ms_b2), hex(ms_b1), hex(width), hex(height))
    raw_tilemap = [ms_b2, ms_b1, width, 00, height, 00] + tiles
    raw_tilemap + [0] * (256 - len(raw_tilemap) % 256)

    tilemap = bytearray(raw_tilemap)
    with open('big.bin', 'wb') as out_file:
        out_file.write(tilemap);
