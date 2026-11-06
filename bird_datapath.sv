module bird_datapath (
    input  logic clk,
    input  logic reset,

    input  logic game_active,
    input  logic game_tick,

    input  logic flap_pulse,
    input  logic new_game_pulse,

    output logic [2:0] bird_height
);

    // A button pulse is much shorter than one game tick, so remember it.
    logic flap_pending;

    always_ff @(posedge clk) begin
        if (reset || new_game_pulse) begin
            bird_height <= 3'd4;
            flap_pending <= 1'b0;
        end
        else begin
            if (!game_active) begin
                flap_pending <= 1'b0;
            end
            else begin
                if (flap_pulse)
                    flap_pending <= 1'b1;

                if (game_tick) begin
                    // Height convention:
                    // 7 = top of screen, 0 = bottom of screen.
                    if (flap_pending || flap_pulse) begin
                        // Flap = +2, but saturate at the top.
                        if (bird_height >= 3'd5)
                            bird_height <= 3'd7;
                        else
                            bird_height <= bird_height + 3'd2;
                    end
                    else begin
                        // Gravity = -1, but saturate at the bottom.
                        if (bird_height == 3'd0)
                            bird_height <= 3'd0;
                        else
                            bird_height <= bird_height - 3'd1;
                    end

                    flap_pending <= 1'b0;
                end
            end
        end
    end

endmodule
