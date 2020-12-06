.org 7e0000

joy1_raw:                 .rb 2
joy1_press:               .rb 2
joy1_held:                .rb 2
screen_x_velocity:        .rb 2
screen_y_velocity:        .rb 2
screen_tm_x:              .rb 1           ; screen position relative to tilemap
screen_tm_y:              .rb 1
prev_screen_tm_x:         .rb 1
prev_screen_tm_y:         .rb 1
screen_m_x:               .rb 2           ; screen position relative to map
screen_m_y:               .rb 2
prev_screen_m_x:          .rb 2
prev_screen_m_y:          .rb 2

current_map:              .rb 3           ; pointer to current map (map should always be in same bank)
current_map_width:        .rb 2           ; width of current map (in tiles)
current_map_height:       .rb 2           ; height of current map (in tiles)

current_map_width_pixel:  .rb 2
current_map_height_pixel: .rb 2
tilemap_buffer:           .rb 800

oam_buffer:               .rb 300         ; OAM buffer
