module game_renderer #(
    parameter logic [2:0] BIRD_X = 3'd7
) (
    input  logic [2:0] scan_row,

    input  logic [2:0] bird_height,
    input  logic [2:0] pipe_x,
    input  logic [2:0] gap_center,

    input  logic show_pipe,

    output logic [7:0] row_pixels
);

    logic [2:0] row_height;
    logic [2:0] gap_low;
    logic [2:0] gap_high;

    integer column;

    always_comb begin
        // Logical/physical mapping used by this project:
        //   matrix_rows[0] = top row, matrix_rows[7] = bottom row
        //   matrix_cols[7] = left-most column (fixed bird column)
        //   matrix_cols[0] = right-most column (pipe spawn side)
        // Game height convention: 7 = top, 0 = bottom.
        row_height = 3'd7 - scan_row;

        gap_low  = gap_center - 3'd1;
        gap_high = gap_center + 3'd1;

        row_pixels = 8'b00000000;

        for (column = 0; column < 8; column = column + 1) begin
            // Bird pixel.
            if ((column == BIRD_X) &&
                (row_height == bird_height)) begin
                row_pixels[column] = 1'b1;
            end

            // Pipe pixel.
            if (show_pipe &&
                (column == pipe_x) &&
                ((row_height < gap_low) ||
                 (row_height > gap_high))) begin
                row_pixels[column] = 1'b1;
            end
        end
    end

endmodule
