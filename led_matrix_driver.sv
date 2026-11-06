module led_matrix_driver #(
    parameter bit ROW_ACTIVE_HIGH = 1'b1,
    parameter bit COL_ACTIVE_HIGH = 1'b0
) (
    input  logic clk,
    input  logic reset,
    input  logic matrix_tick,

    input  logic [7:0] row_pixels,

    output logic [2:0] scan_row,
    output logic [7:0] matrix_rows,
    output logic [7:0] matrix_cols
);

    logic [7:0] row_onehot;

    always_ff @(posedge clk) begin
        if (reset)
            scan_row <= 3'd0;
        else if (matrix_tick)
            scan_row <= scan_row + 3'd1;
    end

    always_comb begin
        row_onehot = 8'b00000001 << scan_row;

        // Blank the matrix while reset is asserted.
        if (reset) begin
            matrix_rows = ROW_ACTIVE_HIGH ? 8'h00 : 8'hFF;
            matrix_cols = COL_ACTIVE_HIGH ? 8'h00 : 8'hFF;
        end
        else begin
            if (ROW_ACTIVE_HIGH)
                matrix_rows = row_onehot;
            else
                matrix_rows = ~row_onehot;

            if (COL_ACTIVE_HIGH)
                matrix_cols = row_pixels;
            else
                matrix_cols = ~row_pixels;
        end
    end

endmodule
