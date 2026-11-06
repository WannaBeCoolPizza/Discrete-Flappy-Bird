module pipe_datapath #(
    parameter logic [2:0] BIRD_X = 3'd7
) (
    input  logic clk,
    input  logic reset,

    input  logic game_active,
    input  logic game_tick,

    input  logic new_game_pulse,
    input  logic [1:0] random_bits,

    output logic [2:0] pipe_x,
    output logic [2:0] gap_center,
    output logic pipe_passed
);

    always_ff @(posedge clk) begin
        // Pulse for one FPGA clock only.
        pipe_passed <= 1'b0;

        if (reset) begin
            pipe_x     <= 3'd0;
            gap_center <= 3'd4;
        end
        else if (new_game_pulse) begin
            pipe_x     <= 3'd0;
            gap_center <= 3'd2 + {1'b0, random_bits};
        end
        else if (game_active && game_tick) begin
            // Column 7 is the fixed bird column (left-most on this wiring).
            // Pipes enter from column 0 (right-most) and move toward the bird.
            if (pipe_x == BIRD_X) begin
                // The bird safely passed this pipe. Spawn a new one on the
                // opposite edge and choose a new random opening.
                pipe_passed <= 1'b1;
                pipe_x      <= 3'd0;

                // 00,01,10,11 -> gap center 2,3,4,5.
                gap_center <= 3'd2 + {1'b0, random_bits};
            end
            else begin
                pipe_x <= pipe_x + 3'd1;
            end
        end
    end

endmodule
