//
// User core top-level
//
// Instantiated by the real top-level: apf_top
//

`default_nettype none

module core_top (

//
// physical connections
//

///////////////////////////////////////////////////
// clock inputs 74.25mhz. not phase aligned, so treat these domains as asynchronous

input   wire            clk_74a, // mainclk1
input   wire            clk_74b, // mainclk1 

///////////////////////////////////////////////////
// cartridge interface
// switches between 3.3v and 5v mechanically
// output enable for multibit translators controlled by pic32

// GBA AD[15:8]
inout   wire    [7:0]   cart_tran_bank2,
output  wire            cart_tran_bank2_dir,

// GBA AD[7:0]
inout   wire    [7:0]   cart_tran_bank3,
output  wire            cart_tran_bank3_dir,

// GBA A[23:16]
inout   wire    [7:0]   cart_tran_bank1,
output  wire            cart_tran_bank1_dir,

// GBA [7] PHI#
// GBA [6] WR#
// GBA [5] RD#
// GBA [4] CS1#/CS#
//     [3:0] unwired
inout   wire    [7:4]   cart_tran_bank0,
output  wire            cart_tran_bank0_dir,

// GBA CS2#/RES#
inout   wire            cart_tran_pin30,
output  wire            cart_tran_pin30_dir,
// when GBC cart is inserted, this signal when low or weak will pull GBC /RES low with a special circuit
// the goal is that when unconfigured, the FPGA weak pullups won't interfere.
// thus, if GBC cart is inserted, FPGA must drive this high in order to let the level translators
// and general IO drive this pin.
output  wire            cart_pin30_pwroff_reset,

// GBA IRQ/DRQ
inout   wire            cart_tran_pin31,
output  wire            cart_tran_pin31_dir,

// infrared
input   wire            port_ir_rx,
output  wire            port_ir_tx,
output  wire            port_ir_rx_disable, 

// GBA link port
inout   wire            port_tran_si,
output  wire            port_tran_si_dir,
inout   wire            port_tran_so,
output  wire            port_tran_so_dir,
inout   wire            port_tran_sck,
output  wire            port_tran_sck_dir,
inout   wire            port_tran_sd,
output  wire            port_tran_sd_dir,
 
///////////////////////////////////////////////////
// cellular psram 0 and 1, two chips (64mbit x2 dual die per chip)

output  wire    [21:16] cram0_a,
inout   wire    [15:0]  cram0_dq,
input   wire            cram0_wait,
output  wire            cram0_clk,
output  wire            cram0_adv_n,
output  wire            cram0_cre,
output  wire            cram0_ce0_n,
output  wire            cram0_ce1_n,
output  wire            cram0_oe_n,
output  wire            cram0_we_n,
output  wire            cram0_ub_n,
output  wire            cram0_lb_n,

output  wire    [21:16] cram1_a,
inout   wire    [15:0]  cram1_dq,
input   wire            cram1_wait,
output  wire            cram1_clk,
output  wire            cram1_adv_n,
output  wire            cram1_cre,
output  wire            cram1_ce0_n,
output  wire            cram1_ce1_n,
output  wire            cram1_oe_n,
output  wire            cram1_we_n,
output  wire            cram1_ub_n,
output  wire            cram1_lb_n,

///////////////////////////////////////////////////
// sdram, 512mbit 16bit

output  wire    [12:0]  dram_a,
output  wire    [1:0]   dram_ba,
inout   wire    [15:0]  dram_dq,
output  wire    [1:0]   dram_dqm,
output  wire            dram_clk,
output  wire            dram_cke,
output  wire            dram_ras_n,
output  wire            dram_cas_n,
output  wire            dram_we_n,

///////////////////////////////////////////////////
// sram, 1mbit 16bit

output  wire    [16:0]  sram_a,
inout   wire    [15:0]  sram_dq,
output  wire            sram_oe_n,
output  wire            sram_we_n,
output  wire            sram_ub_n,
output  wire            sram_lb_n,

///////////////////////////////////////////////////
// vblank driven by dock for sync in a certain mode

input   wire            vblank,

///////////////////////////////////////////////////
// i/o to 6515D breakout usb uart

output  wire            dbg_tx,
input   wire            dbg_rx,

///////////////////////////////////////////////////
// i/o pads near jtag connector user can solder to

output  wire            user1,
input   wire            user2,

///////////////////////////////////////////////////
// RFU internal i2c bus 

inout   wire            aux_sda,
output  wire            aux_scl,

///////////////////////////////////////////////////
// RFU, do not use
output  wire            vpll_feed,


//
// logical connections
//

///////////////////////////////////////////////////
// video, audio output to scaler
output  wire    [23:0]  video_rgb,
output  wire            video_rgb_clock,
output  wire            video_rgb_clock_90,
output  wire            video_de,
output  wire            video_skip,
output  wire            video_vs,
output  wire            video_hs,
    
output  wire            audio_mclk,
input   wire            audio_adc,
output  wire            audio_dac,
output  wire            audio_lrck,

///////////////////////////////////////////////////
// bridge bus connection
// synchronous to clk_74a
output  wire            bridge_endian_little,
input   wire    [31:0]  bridge_addr,
input   wire            bridge_rd,
output  reg     [31:0]  bridge_rd_data,
input   wire            bridge_wr,
input   wire    [31:0]  bridge_wr_data,

///////////////////////////////////////////////////
// controller data
// 
// key bitmap:
//   [0]    dpad_up
//   [1]    dpad_down
//   [2]    dpad_left
//   [3]    dpad_right
//   [4]    face_a
//   [5]    face_b
//   [6]    face_x
//   [7]    face_y
//   [8]    trig_l1
//   [9]    trig_r1
//   [10]   trig_l2
//   [11]   trig_r2
//   [12]   trig_l3
//   [13]   trig_r3
//   [14]   face_select
//   [15]   face_start
//   [31:28] type
// joy values - unsigned
//   [ 7: 0] lstick_x
//   [15: 8] lstick_y
//   [23:16] rstick_x
//   [31:24] rstick_y
// trigger values - unsigned
//   [ 7: 0] ltrig
//   [15: 8] rtrig
//
input   wire    [31:0]  cont1_key,
input   wire    [31:0]  cont2_key,
input   wire    [31:0]  cont3_key,
input   wire    [31:0]  cont4_key,
input   wire    [31:0]  cont1_joy,
input   wire    [31:0]  cont2_joy,
input   wire    [31:0]  cont3_joy,
input   wire    [31:0]  cont4_joy,
input   wire    [15:0]  cont1_trig,
input   wire    [15:0]  cont2_trig,
input   wire    [15:0]  cont3_trig,
input   wire    [15:0]  cont4_trig
    
);

// not using the IR port, so turn off both the LED, and
// disable the receive circuit to save power
assign port_ir_tx = 0;
assign port_ir_rx_disable = 1;

// bridge endianness
assign bridge_endian_little = 0;

// cart is unused, so set all level translators accordingly
// directions are 0:IN, 1:OUT
assign cart_tran_bank3 = 8'hzz;
assign cart_tran_bank3_dir = 1'b0;
assign cart_tran_bank2 = 8'hzz;
assign cart_tran_bank2_dir = 1'b0;
assign cart_tran_bank1 = 8'hzz;
assign cart_tran_bank1_dir = 1'b0;
assign cart_tran_bank0 = 4'hf;
assign cart_tran_bank0_dir = 1'b1;
assign cart_tran_pin30 = 1'b0;      // reset or cs2, we let the hw control it by itself
assign cart_tran_pin30_dir = 1'bz;
assign cart_pin30_pwroff_reset = 1'b0;  // hardware can control this
assign cart_tran_pin31 = 1'bz;      // input
assign cart_tran_pin31_dir = 1'b0;  // input

// link port is unused, set to input only to be safe
// each bit may be bidirectional in some applications
assign port_tran_so = 1'bz;
assign port_tran_so_dir = 1'b0;     // SO is output only
assign port_tran_si = 1'bz;
assign port_tran_si_dir = 1'b0;     // SI is input only
assign port_tran_sck = 1'bz;
assign port_tran_sck_dir = 1'b0;    // clock direction can change
assign port_tran_sd = 1'bz;
assign port_tran_sd_dir = 1'b0;     // SD is input and not used

// tie off the rest of the pins we are not using
assign cram0_a = 'h0;
assign cram0_dq = {16{1'bZ}};
assign cram0_clk = 0;
assign cram0_adv_n = 1;
assign cram0_cre = 0;
assign cram0_ce0_n = 1;
assign cram0_ce1_n = 1;
assign cram0_oe_n = 1;
assign cram0_we_n = 1;
assign cram0_ub_n = 1;
assign cram0_lb_n = 1;

assign cram1_a = 'h0;
assign cram1_dq = {16{1'bZ}};
assign cram1_clk = 0;
assign cram1_adv_n = 1;
assign cram1_cre = 0;
assign cram1_ce0_n = 1;
assign cram1_ce1_n = 1;
assign cram1_oe_n = 1;
assign cram1_we_n = 1;
assign cram1_ub_n = 1;
assign cram1_lb_n = 1;

assign sram_a = 'h0;
assign sram_dq = {16{1'bZ}};
assign sram_oe_n  = 1;
assign sram_we_n  = 1;
assign sram_ub_n  = 1;
assign sram_lb_n  = 1;

assign dbg_tx = 1'bZ;
assign user1 = 1'bZ;
assign aux_scl = 1'bZ;
assign vpll_feed = 1'bZ;


    wire    [31:0]  ram1_word_q_s;
synch_3 #(.WIDTH(32)) s0(ram1_word_q, ram1_word_q_s, clk_74a);

// for bridge write data, we just broadcast it to all bus devices
// for bridge read data, we have to mux it
// add your own devices here
always @(*) begin
    casex(bridge_addr)
    default: begin
        // all unmapped addresses are zero
        bridge_rd_data <= 0;
    end
    32'b000000xx_xxxxxxxx_xxxxxxxx_xxxxxxxx: begin
        bridge_rd_data <= ram1_word_q_s;
    end
    32'h50000000: begin
        bridge_rd_data <= screen_border;
    end
    32'hF8xxxxxx: begin
        bridge_rd_data <= cmd_bridge_rd_data;
    end
    endcase
end


//
// host/target command handler
//
    wire            reset_n;                // driven by host commands, can be used as core-wide reset
    wire    [31:0]  cmd_bridge_rd_data;
    
// bridge host commands
// synchronous to clk_74a
    wire            status_boot_done = pll_core_locked; 
    wire            status_setup_done = pll_core_locked; // rising edge triggers a target command
    wire            status_running = reset_n; // we are running as soon as reset_n goes high

    wire            dataslot_requestread;
    wire    [15:0]  dataslot_requestread_id;
    wire            dataslot_requestread_ack = 1;
    wire            dataslot_requestread_ok = 1;

    wire            dataslot_requestwrite;
    wire    [15:0]  dataslot_requestwrite_id;
    wire    [31:0]  dataslot_requestwrite_size;
    wire            dataslot_requestwrite_ack = 1;
    wire            dataslot_requestwrite_ok = 1;

    wire            dataslot_update;
    wire    [15:0]  dataslot_update_id;
    wire    [31:0]  dataslot_update_size;
    
    wire            dataslot_allcomplete;

    wire     [31:0] rtc_epoch_seconds;
    wire     [31:0] rtc_date_bcd;
    wire     [31:0] rtc_time_bcd;
    wire            rtc_valid;

    wire            savestate_supported;
    wire    [31:0]  savestate_addr;
    wire    [31:0]  savestate_size;
    wire    [31:0]  savestate_maxloadsize;

    wire            savestate_start;
    wire            savestate_start_ack;
    wire            savestate_start_busy;
    wire            savestate_start_ok;
    wire            savestate_start_err;

    wire            savestate_load;
    wire            savestate_load_ack;
    wire            savestate_load_busy;
    wire            savestate_load_ok;
    wire            savestate_load_err;
    
    wire            osnotify_inmenu;

// bridge target commands
// synchronous to clk_74a

    reg             target_dataslot_read;       
    reg             target_dataslot_write;

    wire            target_dataslot_ack;        
    wire            target_dataslot_done;
    wire    [2:0]   target_dataslot_err;

    reg     [15:0]  target_dataslot_id;
    reg     [31:0]  target_dataslot_slotoffset;
    reg     [31:0]  target_dataslot_bridgeaddr;
    reg     [31:0]  target_dataslot_length;
    
// bridge data slot access
// synchronous to clk_74a

    wire    [9:0]   datatable_addr;
    wire            datatable_wren;
    wire    [31:0]  datatable_data;
    wire    [31:0]  datatable_q;

core_bridge_cmd icb (

    .clk                    ( clk_74a ),
    .reset_n                ( reset_n ),

    .bridge_endian_little   ( bridge_endian_little ),
    .bridge_addr            ( bridge_addr ),
    .bridge_rd              ( bridge_rd ),
    .bridge_rd_data         ( cmd_bridge_rd_data ),
    .bridge_wr              ( bridge_wr ),
    .bridge_wr_data         ( bridge_wr_data ),
    
    .status_boot_done       ( status_boot_done ),
    .status_setup_done      ( status_setup_done ),
    .status_running         ( status_running ),

    .dataslot_requestread       ( dataslot_requestread ),
    .dataslot_requestread_id    ( dataslot_requestread_id ),
    .dataslot_requestread_ack   ( dataslot_requestread_ack ),
    .dataslot_requestread_ok    ( dataslot_requestread_ok ),

    .dataslot_requestwrite      ( dataslot_requestwrite ),
    .dataslot_requestwrite_id   ( dataslot_requestwrite_id ),
    .dataslot_requestwrite_size ( dataslot_requestwrite_size ),
    .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack ),
    .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok ),

    .dataslot_update            ( dataslot_update ),
    .dataslot_update_id         ( dataslot_update_id ),
    .dataslot_update_size       ( dataslot_update_size ),
    
    .dataslot_allcomplete   ( dataslot_allcomplete ),

    .rtc_epoch_seconds      ( rtc_epoch_seconds ),
    .rtc_date_bcd           ( rtc_date_bcd ),
    .rtc_time_bcd           ( rtc_time_bcd ),
    .rtc_valid              ( rtc_valid ),
    
    .savestate_supported    ( savestate_supported ),
    .savestate_addr         ( savestate_addr ),
    .savestate_size         ( savestate_size ),
    .savestate_maxloadsize  ( savestate_maxloadsize ),

    .savestate_start        ( savestate_start ),
    .savestate_start_ack    ( savestate_start_ack ),
    .savestate_start_busy   ( savestate_start_busy ),
    .savestate_start_ok     ( savestate_start_ok ),
    .savestate_start_err    ( savestate_start_err ),

    .savestate_load         ( savestate_load ),
    .savestate_load_ack     ( savestate_load_ack ),
    .savestate_load_busy    ( savestate_load_busy ),
    .savestate_load_ok      ( savestate_load_ok ),
    .savestate_load_err     ( savestate_load_err ),

    .osnotify_inmenu        ( osnotify_inmenu ),
    
    .target_dataslot_read       ( target_dataslot_read ),
    .target_dataslot_write      ( target_dataslot_write ),

    .target_dataslot_ack        ( target_dataslot_ack ),
    .target_dataslot_done       ( target_dataslot_done ),
    .target_dataslot_err        ( target_dataslot_err ),

    .target_dataslot_id         ( target_dataslot_id ),
    .target_dataslot_slotoffset ( target_dataslot_slotoffset ),
    .target_dataslot_bridgeaddr ( target_dataslot_bridgeaddr ),
    .target_dataslot_length     ( target_dataslot_length ),

    .datatable_addr         ( datatable_addr ),
    .datatable_wren         ( datatable_wren ),
    .datatable_data         ( datatable_data ),
    .datatable_q            ( datatable_q )

);



////////////////////////////////////////////////////////////////////////////////////////



// video generation
// ~12,288,000 hz pixel clock
//
// we want our video mode of 320x240 @ 60hz, this results in 204800 clocks per frame
// we need to add hblank and vblank times to this, so there will be a nondisplay area. 
// it can be thought of as a border around the visible area.
// to make numbers simple, we can have 400 total clocks per line, and 320 visible.
// dividing 204800 by 400 results in 512 total lines per frame, and 288 visible.
// this pixel clock is fairly high for the relatively low resolution, but that's fine.
// PLL output has a minimum output frequency anyway.


assign video_rgb_clock = clk_core_12288;
assign video_rgb_clock_90 = clk_core_12288_90deg;
assign video_rgb = vidout_rgb;
assign video_de = vidout_de;
assign video_skip = vidout_skip;
assign video_vs = vidout_vs;
assign video_hs = vidout_hs;

    localparam  VID_V_BPORCH = 'd10;
    localparam  VID_V_ACTIVE = 'd288;
    localparam  VID_V_TOTAL = 'd512;
    localparam  VID_H_BPORCH = 'd10;
    localparam  VID_H_ACTIVE = 'd320;
    localparam  VID_H_TOTAL = 'd400;
    
    reg [15:0]  frame_count;
    
    reg [9:0]   x_count;
    reg [9:0]   y_count;
    
    wire signed [9:0]  visible_x = $signed(x_count) - $signed(VID_H_BPORCH) /* synthesis keep */;
    wire signed [9:0]  visible_y = $signed(y_count) - $signed(VID_V_BPORCH) /* synthesis keep */;

    reg [23:0]  vidout_rgb;
    reg         vidout_de, vidout_de_1;
    reg         vidout_skip;
    reg         vidout_vs;
    reg         vidout_hs, vidout_hs_1;
    
    reg signed [9:0]   square_x = 'd135;
    reg signed [9:0]   square_y = 'd119;
    
    reg             screen_border = 1; // driven by BRIDGE clk_74a 
    wire            screen_border_s;
synch_3 s1(screen_border, screen_border_s, video_rgb_clock);

    wire            osnotify_inmenu_s; // driven by BRIDGE clk_74a in core_bridge_cmd
synch_3 s2(osnotify_inmenu, osnotify_inmenu_s, video_rgb_clock);

    wire    [31:0]  cont1_key_s;
synch_3 #(.WIDTH(32)) s22(cont1_key, cont1_key_s, video_rgb_clock);

    wire            disable_enable_vid;
synch_3 s23(display_enable_gated, disable_enable_vid, video_rgb_clock);

//
// mouse stuff starts here
//
    reg signed  [10:0]  mouse_pos_x = VID_H_ACTIVE/2;
    reg signed  [10:0]  mouse_pos_y = VID_V_ACTIVE/2;
    
    // do arithmetic shift right (preserve sign) to divide by 2
    // giving us 1 extra bit of subpixel precision 
    // this helps make the mouse feel better at our low resolution
    wire signed [9:0]   mouse_pos_x_half = mouse_pos_x >>> 1 /* synthesis keep */;
    wire signed [9:0]   mouse_pos_y_half = mouse_pos_y >>> 1 /* synthesis keep */;
    
    // handle synchronizing all the mouse data and latching on a new event
    wire            mouse_event_new_s;
synch_3 s24(mouse_event_new, mouse_event_new_s, video_rgb_clock);
    reg             mouse_event_new_last;
    reg             mouse_event_new_next;
    
    reg     [7:0]   mouse_buttons_last;
    wire    [7:0]   mouse_buttons_s;
    wire signed [15:0]  mouse_pointer_x_s;
    wire signed [15:0]  mouse_pointer_y_s;
synch_3 #(.WIDTH(8)) s25(mouse_buttons, mouse_buttons_s, video_rgb_clock);
synch_3 #(.WIDTH(16)) s26(mouse_pointer_x, mouse_pointer_x_s, video_rgb_clock);
synch_3 #(.WIDTH(16)) s27(mouse_pointer_y, mouse_pointer_y_s, video_rgb_clock);

    wire    [47:0]  kb_scancodes_s;
    wire    [15:0]  kb_modifiers_s;
    reg     [15:0]  kb_modifiers_last;
synch_3 #(.WIDTH(48)) s28(kb_scancodes, kb_scancodes_s, video_rgb_clock);
synch_3 #(.WIDTH(16)) s29(kb_modifiers, kb_modifiers_s, video_rgb_clock);

    wire    [3:0]   cont1_id_s;
    wire    [3:0]   cont2_id_s;
    wire    [3:0]   cont3_id_s;
    wire    [3:0]   cont4_id_s;
synch_3 #(.WIDTH(4)) s30(cont1_key[31:28], cont1_id_s, video_rgb_clock);
synch_3 #(.WIDTH(4)) s31(cont2_key[31:28], cont2_id_s, video_rgb_clock);
synch_3 #(.WIDTH(4)) s32(cont3_key[31:28], cont3_id_s, video_rgb_clock);
synch_3 #(.WIDTH(4)) s33(cont4_key[31:28], cont4_id_s, video_rgb_clock);
    
    reg     [4:0]   cursor_display_x;
    reg     [4:0]   cursor_display_y /* synthesis preserve */;
    
    reg     [7:0]   cursor_img_addr;
    wire    [1:0]   cursor_img_q;
mf_cursorimg    imci (
    .clock      ( video_rgb_clock ),
    .address    ( cursor_img_addr ),
    .q          ( cursor_img_q )
);

    reg             cursor_img_outputting, cursor_img_outputting_1;

always @(posedge video_rgb_clock or negedge reset_n) begin

    if(~reset_n) begin
    
        x_count <= 0;
        y_count <= 0;
        
    end else begin
        vidout_de <= 0;
        vidout_skip <= 0;
        vidout_vs <= 0;
        vidout_hs <= 0;
        
        vidout_hs_1 <= vidout_hs;
        vidout_de_1 <= vidout_de;
        
        
        // signals for the ram interface
        new_frame <= 0;
        next_line <= 0;
        
        // x and y counters
        x_count <= x_count + 1'b1;
        if(x_count == VID_H_TOTAL-1) begin
            x_count <= 0;
            
            y_count <= y_count + 1'b1;
            if(y_count == VID_V_TOTAL-1) begin
                y_count <= 0;
            end
        end
        
        // generate sync 
        if(x_count == 0 && y_count == 0) begin
            // sync signal in back porch
            // new frame
            vidout_vs <= 1;
            new_frame <= 1;
            
            if(!osnotify_inmenu_s) begin
                frame_count <= frame_count + 1'b1;
            end
        end
        
        // we want HS to occur a bit after VS, not on the same cycle
        if(x_count == 3) begin
            // sync signal in back porch
            // new line
            vidout_hs <= 1;
            
            // trigger the next_line signal 1 line ahead of the first visible line, to account for buffering
            if(y_count >= VID_V_BPORCH-1 && y_count < VID_V_ACTIVE+VID_V_BPORCH) begin
                next_line <= 1;
                linebuf_toggle <= linebuf_toggle ^ 1;
            end
        end
            
        // generate scanline buffer addressing
        // because our scanline BRAM is registered, it has an additional cycle of latency, 
        // so we must start incrementing its address a cycle early
        if(x_count >= VID_H_BPORCH-2) begin
            linebuf_rdaddr <= linebuf_rdaddr + 1'b1;
        end else begin
            linebuf_rdaddr <= 0;
        end
        
        
        // generate cursor bram addressing
        // this must happen a bit ahead in horizontal back porch because
        // reading the bram has some delay
        if(visible_x == mouse_pos_x_half - $signed(3) && visible_y == mouse_pos_y_half ) begin
            cursor_display_x <= 12;
            cursor_display_y <= 19;
            cursor_img_addr <= 0;
        end else if(visible_x == mouse_pos_x_half - $signed(3)) begin
            if(cursor_display_y) begin
                cursor_display_x <= 12; 
                cursor_display_y <= cursor_display_y - 1'b1;
            end
        end
        
        cursor_img_outputting <= 0;
        if(cursor_display_x) begin
            cursor_display_x <= cursor_display_x - 1'b1;
            cursor_img_addr <= cursor_img_addr + 1'b1;
            
            cursor_img_outputting <= 1;
        end
        cursor_img_outputting_1 <= cursor_img_outputting;
        
        
                
        // inactive screen areas are black
        vidout_rgb <= 24'h0;
        // generate active video
        if(x_count >= VID_H_BPORCH && x_count < VID_H_ACTIVE+VID_H_BPORCH) begin

            if(y_count >= VID_V_BPORCH && y_count < VID_V_ACTIVE+VID_V_BPORCH) begin
                // data enable. this is the active region of the line
                vidout_de <= 1;
                
                // generate the sliding XOR background
                //vidout_rgb[23:16] <= (visible_x + frame_count / 1) ^ (visible_y + frame_count/1);
                //vidout_rgb[15:8]  <= (visible_x + frame_count / 2) ^ (visible_y - frame_count/2);
                //vidout_rgb[7:0]     <= (visible_x - frame_count / 1) ^ (visible_y + 128);
                
                // convert RGB565 to RGB888
                vidout_rgb[23:16] <= {linebuf_q[15:11], linebuf_q[15:13]};
                vidout_rgb[15:8]  <= {linebuf_q[10:5], linebuf_q[10:9]};
                vidout_rgb[7:0]   <= {linebuf_q[4:0], linebuf_q[4:2]};
            
                // make screen gray if disable is not enabled to hide line buffers
                if(~disable_enable_vid) vidout_rgb <= 24'h202020;
                
                // single pixel at exact position. covered up by cursor
                if(visible_x == mouse_pos_x_half && visible_y == mouse_pos_y_half ) begin
                    vidout_rgb <= 24'hFFFFFF;
                end
                
                if(cursor_img_outputting_1) begin
                    if(cursor_img_q == 2'd1) vidout_rgb <= 24'h000000;
                    if(cursor_img_q == 2'd2) vidout_rgb <= 24'hFFFFFF;
                end
                
                if(cont1_id_s) begin
                    // any type present in player 1
                    if(visible_x > 240 && visible_x < 250 && visible_y > 270 && visible_y < 280) vidout_rgb <= 24'h00C000; 
                end
                if(cont1_id_s == 4'd1) begin
                    // POCKET internal present in player 1
                    if(visible_x > 240 && visible_x < 250 && visible_y > 270 && visible_y < 280) vidout_rgb <= 24'h30C0FF; 
                end
                if(cont2_id_s) begin
                    // any type present in player 2
                    if(visible_x > 260 && visible_x < 270 && visible_y > 270 && visible_y < 280) vidout_rgb <= 24'h00C000; 
                end
                if(cont3_id_s == 4'd4) begin
                    // keyboard detected in player 3
                    if(visible_x > 280 && visible_x < 290 && visible_y > 270 && visible_y < 280) vidout_rgb <= 24'hFF30FF; 
                end
                if(cont4_id_s == 4'd5) begin
                    // mouse detected in player 4
                    if(visible_x > 300 && visible_x < 310 && visible_y > 270 && visible_y < 280) vidout_rgb <= 24'hFFFF30; 
                end
                
                
                if(screen_border_s) begin
                    // add colored borders for debugging
                    if(visible_x == 0) begin
                        vidout_rgb <= 24'hFFFFFF;
                    end else if(visible_x == VID_H_ACTIVE-1) begin
                        vidout_rgb <= 24'h00FF00;
                    end else if(visible_y == 0) begin
                        vidout_rgb <= 24'hFF0000;
                    end else if(visible_y == VID_V_ACTIVE-1) begin
                        vidout_rgb <= 24'h0000FF;
                    end
                end

            end 
        end
 
        // note that these updates, while latched by the video pixel clock,
        // can occur anytime even in the middle of or after a frame. updates are not
        // latched on a new frame. this means that very rarely it's possible to have a cursor
        // that moves from the time the display starts scanning to when it finishes, and you may not
        // even see any mouse cursor for a single frame, or tearing in the cursor.
        // this is a compromise to keep the example from being even more complex and to reduce latency.
        
        // detect new mouse events
        mouse_event_new_last <= mouse_event_new_s;
        if(mouse_event_new_last != mouse_event_new_s) begin
            // new event
            mouse_event_new_next <= 1;
            
        end else begin
            mouse_event_new_next <= 0;
        end
        
        // update the signed cursor position with the new relative value
        // commit the current position to the FIFO if left mouse button is down
        cfifo_wrreq <= 0;
        if(mouse_event_new_next) begin
            mouse_pos_x <= mouse_pos_x + mouse_pointer_x_s;
            mouse_pos_y <= mouse_pos_y + mouse_pointer_y_s;
            
            mouse_buttons_last <= mouse_buttons_s;
            
            if(mouse_buttons_s[0]) begin
                cfifo_data[10:0] <= mouse_pos_x_half;
                cfifo_data[21:11] <= mouse_pos_y_half;
                cfifo_data[31] <= 1;
                cfifo_wrreq <= 1;
            end
            // falling edge of mouse left button (let go)
            if(~mouse_buttons_s[0] & mouse_buttons_last[0]) begin
                cfifo_data[10:0] <= mouse_pos_x_half;
                cfifo_data[21:11] <= mouse_pos_y_half;
                cfifo_data[31] <= 0;
                cfifo_wrreq <= 1;
            end
        end 
        // cap mouse cursor within screen bounding box
        if(mouse_pos_x_half < $signed(0)) mouse_pos_x <= 0;
        if(mouse_pos_y_half < $signed(0)) mouse_pos_y <= 0;
        if(mouse_pos_x_half >= $signed(VID_H_ACTIVE)) mouse_pos_x <= VID_H_ACTIVE*2-1;
        if(mouse_pos_y_half >= $signed(VID_V_ACTIVE)) mouse_pos_y <= VID_V_ACTIVE*2-1;
        
        
        if(new_frame) begin
            // scancodes can appear in any order in the scancode list
            // a CPU or simple iterative FSM for checking each of the 6 bytes for
            // the scancode in question would be a better idea. 
            // for now just assume that only 2 keys could be pressed simultaneously
            
            // only check the scancodes once per frame
            if(kb_scancodes_s[47:40] == 8'h50 || kb_scancodes_s[39:32] == 8'h50) begin
                mouse_pos_x <= mouse_pos_x - 2'd2;
            end
            if(kb_scancodes_s[47:40] == 8'h4F || kb_scancodes_s[39:32] == 8'h4F) begin
                mouse_pos_x <= mouse_pos_x + 2'd2;
            end
            if(kb_scancodes_s[47:40] == 8'h52 || kb_scancodes_s[39:32] == 8'h52) begin
                mouse_pos_y <= mouse_pos_y - 2'd2;
            end
            if(kb_scancodes_s[47:40] == 8'h51 || kb_scancodes_s[39:32] == 8'h51) begin
                mouse_pos_y <= mouse_pos_y + 2'd2;
            end
        
            kb_modifiers_last <= kb_modifiers_s;
            
            if(kb_modifiers_s[0]) begin
                cfifo_data[10:0] <= mouse_pos_x_half;
                cfifo_data[21:11] <= mouse_pos_y_half;
                cfifo_data[31] <= 1;
                cfifo_wrreq <= 1;
            end
            // user let go of CTRL key
            if(~kb_modifiers_s[0] & kb_modifiers_last[0]) begin
                cfifo_data[10:0] <= mouse_pos_x_half;
                cfifo_data[21:11] <= mouse_pos_y_half;
                cfifo_data[31] <= 0;
                cfifo_wrreq <= 1;
            end
        end
    end
end



    reg             next_line;
    wire            next_line_s;
synch_3 s3(next_line, next_line_s, clk_ram_controller);

    reg             new_frame;
    wire            new_frame_s;
synch_3 s4(new_frame, new_frame_s, clk_ram_controller);

    reg             display_enable;
    reg             ram_reloading;
    reg             display_enable_gated;
    wire            display_enable_s;
synch_3 s5(display_enable_gated, display_enable_s, clk_ram_controller);

    reg     [3:0]   rr_state;
    localparam      RR_STATE_0 = 'd0;
    localparam      RR_STATE_1 = 'd1;
    localparam      RR_STATE_2 = 'd2;
    localparam      RR_STATE_3 = 'd3;
    localparam      RR_STATE_4 = 'd4;
    localparam      RR_STATE_5 = 'd5;
    localparam      RR_STATE_6 = 'd6;
    localparam      RR_STATE_7 = 'd7;
    localparam      RR_STATE_8 = 'd8;
    localparam      RR_STATE_9 = 'd9;
    localparam      RR_STATE_10 = 'd10;
    
    reg     [10:0]  rr_line;
    
// fsm to handle reading ram 
//
// reset linecount on vsync, and fetch line buffers on hsync, in a pingpong buffer
always @(posedge clk_ram_controller) begin
    ram1_burst_rd <= 0;
    linebuf_wren <= 0;
    
    case(rr_state)
    RR_STATE_0: begin
    
        rr_state <= RR_STATE_1;
    end
    RR_STATE_1: begin
        
        if(new_frame_s) begin
            rr_line <= 'd0;
        end
        
        if(next_line_s && display_enable_s) begin
            // increment the line we will fetch next cycle
            rr_line <= rr_line + 1'b1;
            
            ram1_burst_rd <= 1'b1;
            // when displaying a contiguous buffer, we must determine the scanline
            // address with a multiplier. a better way is to fix the scanlines onto a 1024-word alignment
            // and correct the addressing as data is copied in.
            ram1_burst_addr <= rr_line * VID_H_ACTIVE; 
            ram1_burst_len <= 1024;
            ram1_burst_32bit <= 0;
            
            linebuf_wraddr <= -1;
            
            rr_state <= RR_STATE_2;
        end 
    end
    RR_STATE_2: begin
        if(ram1_burst_data_valid) begin
            // ram data is valid, write into the line buffer
            linebuf_data <= ram1_burst_data;
            linebuf_wraddr <= linebuf_wraddr + 1'b1;
            linebuf_wren <= 1;
        
        end
        if(ram1_burst_data_done) begin
            rr_state <= RR_STATE_1;
        end
    
    end
    endcase
end




    reg     [2:0]   reload_state;
    
    wire    [47:0]  kb_scancodes = {cont3_joy[31:0], cont3_trig[15:0]};
    wire    [15:0]  kb_modifiers = {cont3_key[7:0], cont3_key[15:8]};
    
    wire    [15:0]  mouse_counter_current = {cont4_key[7:0], cont4_key[15:8]};
    reg     [15:0]  mouse_counter_last;
    reg             mouse_event_new;
    wire    [7:0]   mouse_buttons = cont4_joy[23:16];
    wire signed [15:0]  mouse_pointer_x = {cont4_joy[7:0], cont4_joy[15:8]};
    wire signed [15:0]  mouse_pointer_y = {cont4_trig[7:0], cont4_trig[15:8]};
    
    
    reg     [6:0]   choldoff;
    
    // video pixel clock domain
    reg             cfifo_wrreq;
    reg     [31:0]  cfifo_data;
    
    // ram controller's write port clock domain
    reg             cfifo_rdreq;
    wire    [31:0]  cfifo_q;
    wire    [8:0]   cfifo_rdusedw;
mf_cursorfifo   imcf (
    // write clock (video pixel clock)
    .wrclk      ( video_rgb_clock ),
    .wrreq      ( cfifo_wrreq ),
    .data       ( cfifo_data ),

    // read clock domain (ram controller)
    .rdclk      ( clk_74a ),
    .rdreq      ( cfifo_rdreq ),
    .q          ( cfifo_q ),
    .rdusedw    ( cfifo_rdusedw )
);



initial begin
    display_enable <= 0;
    ram_reloading <= 0;
    
    reload_state <= 0;
    target_dataslot_read <= 0;      
    target_dataslot_write <= 0;
end
    
    
    
    reg [9:0]   work_x;
    reg [9:0]   work_y;
    reg [9:0]   target_x;
    reg [9:0]   target_y;
    reg         fifo_cleared;
    reg         reset_n_last;
    reg [3:0]   bootup_clearing;
    
always @(posedge clk_74a) begin
    ram1_word_rd <= 0;
    ram1_word_wr <= 0;
    
    // if APF wants to reload a slot, stop hitting ram
    if(dataslot_requestwrite) begin
        display_enable <= 0;
    end
    if(dataslot_allcomplete) begin
        //display_enable <= 1;
    end
    
    
    
    // wait til we are out of reset to start scanning out the display and hitting ram
    // also don't hit ram when we are reloading
    display_enable_gated <= display_enable & ~ram_reloading & reset_n & ~bootup_clearing;
    
    
    
    
    // handle the writes to the framebuffer coming from the mouse cursor
    // this really should be a proper FSM and could be improved
    cfifo_rdreq <= 0;
    if(choldoff) choldoff <= choldoff - 1'b1;
    // handle the coordinate updates
    if(cfifo_rdusedw > fifo_cleared && (choldoff == 0)) begin
        if(fifo_cleared == 1) begin
            cfifo_rdreq <= 1;
            choldoff <= 100;
        end else begin
            choldoff <= 94;
        end     
    end
    if(choldoff == 95) begin
        work_y <= cfifo_q[21:11];
        work_x <= cfifo_q[10:0];
    end 
    if(choldoff == 94) begin
        cfifo_rdreq <= 1;
    end
    if(choldoff == 90) begin
        target_y <= cfifo_q[21:11];
        target_x <= cfifo_q[10:0];
        
        if(~cfifo_q[31]) choldoff <= 0;
    end
    if(choldoff < 90 && choldoff[2:0] == 3'h0 && choldoff > 0) begin
        // give some more breathing time to interpolate until we reach the target coords
        if(work_x < target_x) work_x <= work_x + 1'b1;
        if(work_y < target_y) work_y <= work_y + 1'b1; 
        if(work_x > target_x) work_x <= work_x - 1'b1; 
        if(work_y > target_y) work_y <= work_y - 1'b1; 
    
        ram1_word_wr <= 1;
        ram1_word_addr <= ((work_y * VID_H_ACTIVE) >> 1) + work_x[9:1];
        ram1_word_wrmask <= work_x[0] ? 2'b10 : 2'b01;
        ram1_word_data <= 32'hFFFFFFFF;
        
        fifo_cleared <= 0;
    end
    if(~cfifo_q[31]) fifo_cleared <= 1;
    
    
    
    // handle bootup framebuffer clear
    reset_n_last <= reset_n;
    if(reset_n & ~reset_n_last) begin
        ram1_word_addr <= -1;
        bootup_clearing <= 1;
    end
    
    // cycle from 1-15 and perform a ram write every 15 cycles until enough words are cleared
    if(bootup_clearing) begin
        bootup_clearing <= bootup_clearing + 1'b1;
        if(&bootup_clearing) begin
            bootup_clearing <= 1;
            
            ram1_word_wr <= 1;
            ram1_word_wrmask <= 2'b00;
            ram1_word_addr <= ram1_word_addr + 1'b1;
            ram1_word_data <= 32'h21042104; // dark gray x2 pixels
            
            if(ram1_word_addr == VID_H_ACTIVE * VID_V_ACTIVE / 2) begin
                // the entire framebuffer is cleared
                
                bootup_clearing <= 0;
                if(dataslot_allcomplete) begin
                    display_enable <= 1;
                end
            end
        end
    end
    
    
    // handle memory mapped I/O from pocket
    //
    if(bridge_wr) begin
        casex(bridge_addr[31:24])
        8'b000000xx: begin
            // 64mbyte sdram mapped at 0x0
        
            // the ram controller's word port is 32bit aligned
            ram1_word_wr <= 1;
            ram1_word_wrmask <= 2'b00;
            ram1_word_addr <= bridge_addr[25:2];
            ram1_word_data <= bridge_wr_data;
        end
        8'h50: begin
            screen_border <= bridge_wr_data;
        end
        endcase
    end
    if(bridge_rd) begin
        casex(bridge_addr[31:24])
        8'b000000xx: begin
            // start new read
            ram1_word_rd <= 1;                  
            // convert from byte address to word address
            ram1_word_addr <= bridge_addr[25:2]; 
        end
        endcase
        
    end
    
    // handle the reloading of the framebuffer image by requesting a slot read at a certain offset in the slot's file
    case(reload_state)
    0: begin
    
        // wait for user to press button
        if(|cont1_key[7:4]) begin
            ram_reloading <= 1;
        
            // start the command
            target_dataslot_id <= 16'h20;
            target_dataslot_slotoffset <= 0;
            target_dataslot_bridgeaddr <= 32'h0;
            target_dataslot_length <= 184320;
            target_dataslot_read <= 1;
            
            reload_state <= 1;
        end
        if(cont1_key[4]) target_dataslot_slotoffset <= 184320*0;
        if(cont1_key[5]) target_dataslot_slotoffset <= 184320*1;
        if(cont1_key[6]) target_dataslot_slotoffset <= 184320*2;
        if(cont1_key[7]) target_dataslot_slotoffset <= 184320*3;
                
        // select - save to saved slot
        if(cont1_key[14]) begin
            ram_reloading <= 1;
        
            // start the command
            target_dataslot_id <= 16'h22;
            target_dataslot_slotoffset <= 0;
            target_dataslot_bridgeaddr <= 32'h0;
            target_dataslot_length <= 184320;
            target_dataslot_write <= 1;
            
            reload_state <= 1;
        end
        // start - load from saved slot
        if(cont1_key[15]) begin
            ram_reloading <= 1;
        
            // start the command
            target_dataslot_id <= 16'h22;
            target_dataslot_slotoffset <= 0;
            target_dataslot_bridgeaddr <= 32'h0;
            target_dataslot_length <= 184320;
            target_dataslot_read <= 1;
            
            reload_state <= 1;
        end
    end
    1: begin
        // wait for ack
        if(target_dataslot_ack) begin
            target_dataslot_read <= 0;
            target_dataslot_write <= 0;
            
            reload_state <= 2;
        end
    end
    2: begin
        if(target_dataslot_done) begin
            ram_reloading <= 0;
            
            reload_state <= 0;
        end
    end
    endcase
    
    
    // handle the mouse movement.
    // APF from Dock encapsulates the HID report descriptors into the existing pad registers
    // additionally, a 16-bit counter is incremented with each new report, so it's possible to tell when
    // a new, updated report has occurred.
    //
    // mice will appear on controller 4 always, and cont4_key[31:29] will be 4'h5 to identify this player
    // as a mouse controller.
    //
    // cont4_joy[31:16] : buttons on the mouse. 
    //                    bit0 = left mouse button, bit1 = right button bit2 = middle button
    //                    up to 8 buttons. 1 for each bit
    // cont4_joy[15:0]  : relative X movement, stored little endian. 
    // cont4_key[15:0]  : report counter, stored little endian. 
    // cont4_trig[15:0] : relative Y movement, stored little endian. 
    //
    // for little endian values, byteswap {[7:0], [15:8]} to get signed number.
    
    mouse_counter_last <= mouse_counter_current;
    if(mouse_counter_current != mouse_counter_last) begin
        // new event
        mouse_event_new <= ~mouse_event_new;
    end
    
    
    // handle the keyboard key state.
    // APF from Dock encapsulates the HID report descriptors into the existing pad registers
    // keyboard scan codes are sent when pressed, there are no discrete events like the mouse has.
    //
    // keyboards will appear on controller 3 always, and cont3_key[31:29] will be 4'h4 to identify this player
    // as a keyboard-type controller.
    //
    // {cont3_joy[31:0], cont3_trig[15:0]} : a list of up to six concurrent 8-bit keyboard scan codes.
    // cont3_key[15:0]                     : modifier bits (ctrl, shift, alt keys) as 16-bit little endian
    
    
    
end



//
// audio i2s silence generator
// see other examples for actual audio generation
//

assign audio_mclk = audgen_mclk;
assign audio_dac = audgen_dac;
assign audio_lrck = audgen_lrck;

// generate MCLK = 12.288mhz with fractional accumulator
    reg         [21:0]  audgen_accum = 0;
    reg                 audgen_mclk;
    parameter   [20:0]  CYCLE_48KHZ = 21'd122880 * 2;
always @(posedge clk_74a) begin
    audgen_accum <= audgen_accum + CYCLE_48KHZ;
    if(audgen_accum >= 21'd742500) begin
        audgen_mclk <= ~audgen_mclk;
        audgen_accum <= audgen_accum - 21'd742500 + CYCLE_48KHZ;
    end
end

// generate SCLK = 3.072mhz by dividing MCLK by 4
    reg [1:0]   aud_mclk_divider;
    wire        audgen_sclk = aud_mclk_divider[1] /* synthesis keep*/;
    reg         audgen_lrck_1;
always @(posedge audgen_mclk) begin
    aud_mclk_divider <= aud_mclk_divider + 1'b1;
end

// shift out audio data as I2S 
// 32 total bits per channel, but only 16 active bits at the start and then 16 dummy bits
//
    reg     [4:0]   audgen_lrck_cnt;    
    reg             audgen_lrck;
    reg             audgen_dac;
always @(negedge audgen_sclk) begin
    audgen_dac <= 1'b0;
    // 48khz * 64
    audgen_lrck_cnt <= audgen_lrck_cnt + 1'b1;
    if(audgen_lrck_cnt == 31) begin
        // switch channels
        audgen_lrck <= ~audgen_lrck;
        
    end 
end


///////////////////////////////////////////////



// note that the 12.288mhz PLL output is actually only used for video generation!
    wire    clk_core_12288;
    wire    clk_core_12288_90deg;
    wire    clk_ram_controller;
    wire    clk_ram_chip;
    wire    clk_ram_90;
    
    wire    pll_core_locked;
    
mf_pllbase mp1 (
    .refclk         ( clk_74a ),
    .rst            ( 0 ),
    
    .outclk_0       ( clk_core_12288 ),
    .outclk_1       ( clk_core_12288_90deg ),
    
    .outclk_2       ( clk_ram_controller ),
    .outclk_3       ( clk_ram_chip ),
    .outclk_4       ( clk_ram_90 ),
    
    .locked         ( pll_core_locked )
);

// clk_12288 drives the pingpong toggle for the line buffer.
// however, we need to use this toggle in the other clock domain, clk_ram_controller.
// so it's necessary to use a synchronizer to bring this into the other clock domain.
    reg             linebuf_toggle;
    wire            linebuf_toggle_s;
synch_3 s9(linebuf_toggle, linebuf_toggle_s, clk_ram_controller);

    reg     [9:0]   linebuf_rdaddr;
    wire    [10:0]  linebuf_rdaddr_fix = (linebuf_toggle ? linebuf_rdaddr : (linebuf_rdaddr + 'd1024));
    wire    [15:0]  linebuf_q;
    
    reg     [9:0]   linebuf_wraddr;
    wire    [10:0]  linebuf_wraddr_fix = (linebuf_toggle_s ? (linebuf_wraddr + 'd1024) : linebuf_wraddr);
    reg     [15:0]  linebuf_data;
    reg             linebuf_wren;

mf_linebuf  mf_linebuf_inst (
    .rdclock        ( clk_core_12288 ),
    .rdaddress      ( linebuf_rdaddr_fix ),
    .q              ( linebuf_q ),
    
    .wrclock        ( clk_ram_controller ),
    .wraddress      ( linebuf_wraddr_fix ),
    .data           ( linebuf_data ),
    .wren           ( linebuf_wren )
);


    reg             ram1_burst_rd; // must be synchronous to clk_ram
    reg     [24:0]  ram1_burst_addr;
    reg     [10:0]  ram1_burst_len;
    reg             ram1_burst_32bit;
    wire    [31:0]  ram1_burst_data;
    wire            ram1_burst_data_valid;
    wire            ram1_burst_data_done;
    
    wire            ram1_burstwr;
    wire    [24:0]  ram1_burstwr_addr;
    wire            ram1_burstwr_ready;
    wire            ram1_burstwr_strobe;
    wire    [15:0]  ram1_burstwr_data;
    wire            ram1_burstwr_done;
    
    reg             ram1_word_rd;
    reg             ram1_word_wr;
    reg     [23:0]  ram1_word_addr;
    reg     [1:0]   ram1_word_wrmask;
    reg     [31:0]  ram1_word_data;
    wire    [31:0]  ram1_word_q;
    wire            ram1_word_busy;

io_sdram isr0 (
    .controller_clk ( clk_ram_controller ),
    .chip_clk       ( clk_ram_chip ),
    .clk_90         ( clk_ram_90 ),
    .reset_n        ( 1'b1 ), // fsm has its own boot reset
    
    .phy_cke        ( dram_cke ),
    .phy_clk        ( dram_clk ),
    .phy_cas        ( dram_cas_n ),
    .phy_ras        ( dram_ras_n ),
    .phy_we         ( dram_we_n ),
    .phy_ba         ( dram_ba ),
    .phy_a          ( dram_a ),
    .phy_dq         ( dram_dq ),
    .phy_dqm        ( dram_dqm ),
    
    .burst_rd           ( ram1_burst_rd ),
    .burst_addr         ( ram1_burst_addr ),
    .burst_len          ( ram1_burst_len ),
    .burst_32bit        ( ram1_burst_32bit ),
    .burst_data         ( ram1_burst_data ),
    .burst_data_valid   ( ram1_burst_data_valid ),
    .burst_data_done    ( ram1_burst_data_done ),

    .burstwr        ( ram1_burstwr ),
    .burstwr_addr   ( ram1_burstwr_addr ),
    .burstwr_ready  ( ram1_burstwr_ready ),
    .burstwr_strobe ( ram1_burstwr_strobe ),
    .burstwr_data   ( ram1_burstwr_data ),
    .burstwr_done   ( ram1_burstwr_done ),
    
    .word_rd    ( ram1_word_rd ),
    .word_wr    ( ram1_word_wr ),
    .word_addr  ( ram1_word_addr ),
    .word_wrmask ( ram1_word_wrmask ),
    .word_data  ( ram1_word_data ),
    .word_q     ( ram1_word_q ),
    .word_busy  ( ram1_word_busy )
        
);

    
endmodule
