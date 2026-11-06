module tick_generator #(
    parameter int CLK_HZ        = 50_000_000,
    parameter int GAME_HZ       = 12,
    parameter int MATRIX_ROW_HZ = 8_000
) (
    input  logic clk,
    input  logic reset,
    output logic game_tick,
    output logic matrix_tick
);

    localparam int GAME_DIV   = CLK_HZ / GAME_HZ;
    localparam int MATRIX_DIV = CLK_HZ / MATRIX_ROW_HZ;

    localparam int GAME_WIDTH =
        (GAME_DIV <= 1) ? 1 : $clog2(GAME_DIV);

    localparam int MATRIX_WIDTH =
        (MATRIX_DIV <= 1) ? 1 : $clog2(MATRIX_DIV);

    logic [GAME_WIDTH-1:0]   game_count;
    logic [MATRIX_WIDTH-1:0] matrix_count;

    always_ff @(posedge clk) begin
        if (reset) begin
            game_count   <= '0;
            matrix_count <= '0;
            game_tick    <= 1'b0;
            matrix_tick  <= 1'b0;
        end
        else begin
            game_tick   <= 1'b0;
            matrix_tick <= 1'b0;

            if (game_count == GAME_DIV - 1) begin
                game_count <= '0;
                game_tick  <= 1'b1;
            end
            else begin
                game_count <= game_count + 1'b1;
            end

            if (matrix_count == MATRIX_DIV - 1) begin
                matrix_count <= '0;
                matrix_tick  <= 1'b1;
            end
            else begin
                matrix_count <= matrix_count + 1'b1;
            end
        end
    end

endmodule
