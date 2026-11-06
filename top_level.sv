module top_level (
    // DE10-Lite 50 MHz clock
    input  logic clk,

    // Active-low push buttons
    input  logic key0,
    input  logic key1,

    // Seven-segment displays
    output logic [6:0] hex0,
    output logic [6:0] hex1,
    output logic [6:0] hex2,
    output logic [6:0] hex3,
    output logic [6:0] hex4,
    output logic [6:0] hex5,

    // External 8x8 LED matrix
    output logic [7:0] matrix_rows,
    output logic [7:0] matrix_cols
);

    // matrix_cols[7] is the left-most physical column in this wiring.
    localparam logic [2:0] BIRD_X = 3'd7;

    // =====================================================
    // RESET
    // =====================================================

    logic reset;

    power_on_reset power_reset (
        .clk   (clk),
        .reset (reset)
    );

    // =====================================================
    // BUTTONS
    // KEY0 = start/restart
    // KEY1 = flap
    // =====================================================

    logic start_pulse;
    logic flap_pulse;

    button_conditioner start_button (
        .clk         (clk),
        .reset       (reset),
        .button_n    (key0),
        .press_pulse (start_pulse)
    );

    button_conditioner flap_button (
        .clk         (clk),
        .reset       (reset),
        .button_n    (key1),
        .press_pulse (flap_pulse)
    );

    // =====================================================
    // TIMING
    // =====================================================

    logic game_tick;
    logic matrix_tick;

    // Slow game updates make the 8x8 version playable; matrix scanning stays fast.
    tick_generator #(
        .CLK_HZ        (50_000_000),
        .GAME_HZ       (5),
        .MATRIX_ROW_HZ (8_000)
    ) timing (
        .clk         (clk),
        .reset       (reset),
        .game_tick   (game_tick),
        .matrix_tick (matrix_tick)
    );

    // =====================================================
    // GAME STATE
    // =====================================================

    logic game_active;
    logic game_over;
    logic show_pipe;
    logic new_game_pulse;
    logic collision;

    game_fsm controller (
        .clk            (clk),
        .reset          (reset),
        .start_pulse    (start_pulse),
        .collision      (collision),
        .game_active    (game_active),
        .game_over      (game_over),
        .show_pipe      (show_pipe),
        .new_game_pulse (new_game_pulse)
    );

    // =====================================================
    // BIRD
    // =====================================================

    logic [2:0] bird_height;

    bird_datapath bird (
        .clk            (clk),
        .reset          (reset),
        .game_active    (game_active),
        .game_tick      (game_tick),
        .flap_pulse     (flap_pulse),
        .new_game_pulse (new_game_pulse),
        .bird_height    (bird_height)
    );

    // =====================================================
    // RANDOM PIPE GENERATOR
    // =====================================================

    logic [1:0] random_bits;

    lfsr8 random_generator (
        .clk         (clk),
        .reset       (reset),
        .random_bits (random_bits)
    );

    // =====================================================
    // PIPE
    // =====================================================

    logic [2:0] pipe_x;
    logic [2:0] gap_center;
    logic pipe_passed;

    pipe_datapath #(
        .BIRD_X(BIRD_X)
    ) pipe (
        .clk            (clk),
        .reset          (reset),
        .game_active    (game_active),
        .game_tick      (game_tick),
        .new_game_pulse (new_game_pulse),
        .random_bits    (random_bits),
        .pipe_x         (pipe_x),
        .gap_center     (gap_center),
        .pipe_passed    (pipe_passed)
    );

    // =====================================================
    // COLLISION
    // =====================================================

    collision_logic #(
        .BIRD_X(BIRD_X)
    ) collision_detector (
        .game_active (game_active),
        .bird_height (bird_height),
        .pipe_x      (pipe_x),
        .gap_center  (gap_center),
        .collision   (collision)
    );

    // =====================================================
    // SCORE
    // =====================================================

    logic score_reset;
    logic score_pulse;

    logic [3:0] score_ones;
    logic [3:0] score_tens;

    assign score_reset =
        reset ||
        new_game_pulse;

    assign score_pulse =
        pipe_passed &&
        game_active &&
        ~collision;

    score_counter score (
        .clk         (clk),
        .reset       (score_reset),
        .score_pulse (score_pulse),
        .score_ones  (score_ones),
        .score_tens  (score_tens)
    );

    // =====================================================
    // HEX SCORE
    // =====================================================

    sevenseg ones_display (
        .bin_in  (score_ones),
        .seg_out (hex0)
    );

    sevenseg tens_display (
        .bin_in  (score_tens),
        .seg_out (hex1)
    );

    // Unused HEX displays off.
    assign hex2 = 7'h7F;
    assign hex3 = 7'h7F;
    assign hex4 = 7'h7F;
    assign hex5 = 7'h7F;

    // =====================================================
    // GAME RENDERER
    // =====================================================

    logic [2:0] scan_row;
    logic [7:0] row_pixels;

    game_renderer #(
        .BIRD_X(BIRD_X)
    ) renderer (
        .scan_row    (scan_row),
        .bird_height (bird_height),
        .pipe_x      (pipe_x),
        .gap_center  (gap_center),
        .show_pipe   (show_pipe),
        .row_pixels  (row_pixels)
    );

    // =====================================================
    // LED MATRIX DRIVER
    // =====================================================

    // 788A/788AS common-cathode matrix convention used here:
    //   selected row (cathode) = LOW
    //   lit column  (anode)   = HIGH
    led_matrix_driver #(
        .ROW_ACTIVE_HIGH (1'b0),
        .COL_ACTIVE_HIGH (1'b1)
    ) matrix_driver (
        .clk         (clk),
        .reset       (reset),
        .matrix_tick (matrix_tick),
        .row_pixels  (row_pixels),
        .scan_row    (scan_row),
        .matrix_rows (matrix_rows),
        .matrix_cols (matrix_cols)
    );


endmodule
