require 'csv'

# map format
# header bytes
# 0-1: map size
# 2: map height
# 3: map width
# 4: map[0]

def hex(num, rjust_len = 2)
    (num || 0).to_s(16).rjust(rjust_len, '0').upcase
end

filename = ARGV[0]
height = 0
width = nil
tiles = []

raise "File #{filename} not found" unless File.file?(filename)

CSV.foreach(filename) do |row|
    height += 1
    width ||= row.length
    row.each do |cell|
        tile = cell.to_i
        raise "Tile value too big" if tile > 0xff
        tiles << tile
    end
end

raise "Width too big" if width > 0xff
raise "Height too big" if height > 0xff

size = height * width
raise "Map too big" if size > 0xffff

size_msb = size >> 8
size_lsb = size & 0xff

tiles = [size_lsb, size_msb, height, width] + tiles

File.open("#{filename}.bin", "w+b") do |file|
    file.write([tiles.map { |i| hex(i) }.join].pack('H*'))
end
