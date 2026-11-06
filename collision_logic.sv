module collision_logic #(
    parameter logic [2:0] BIRD_X = 3'd7
) (
    input  logic game_active,

    input  logic [2:0] bird_height,
    input  logic [2:0] pipe_x,
    input  logic [2:0] gap_center,

    output logic collision
);

    logic [2:0] gap_low;
    logic [2:0] gap_high;

    logic same_column;
    logic outside_gap;
    logic pipe_collision;

    always_comb begin
        // Three-pixel-tall opening:
        // gap_center-1, gap_center, gap_center+1.
        gap_low  = gap_center - 3'd1;
        gap_high = gap_center + 3'd1;

        same_column = (pipe_x == BIRD_X);

        outside_gap =
            (bird_height < gap_low) ||
            (bird_height > gap_high);

        pipe_collision =
            same_column &&
            outside_gap;

        // For the 8x8 version, allow the bird to use all eight rows.
        // A game-over occurs when the bird overlaps a pipe pixel.
        collision = game_active && pipe_collision;
    end

endmodule
