.org 7e0000

joy1_raw:                 .rb 2
joy1_press:               .rb 2
joy1_held:                .rb 2
bg_scroll_x:              .rb 1
bg_scroll_y:              .rb 1
prev_bg_scroll_x:         .rb 1
prev_bg_scroll_y:         .rb 1
camera_x:                 .rb 2           ; camera top left corner
camera_y:                 .rb 2
prev_camera_x:            .rb 2
prev_camera_y:            .rb 2
camera_velocity_x:        .rb 2
camera_velocity_y:        .rb 2

current_map:              .rb 3           ; pointer to current map (map should always be in same bank)
current_map_width:        .rb 2           ; width of current map (in tiles)
current_map_height:       .rb 2           ; height of current map (in tiles)

current_map_width_pixel:  .rb 2
current_map_height_pixel: .rb 2

.org 7e2000

tilemap_buffer:           .rb 800
oam_buffer:               .rb 300         ; OAM buffer
