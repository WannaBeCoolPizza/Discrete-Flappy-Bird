module game_fsm (
    input  logic clk,
    input  logic reset,
    input  logic start_pulse,
    input  logic collision,

    output logic game_active,
    output logic game_over,
    output logic show_pipe,
    output logic new_game_pulse
);

    typedef enum logic [1:0] {
        IDLE,
        PLAYING,
        GAME_OVER
    } state_t;

    state_t state;

    always_ff @(posedge clk) begin
        if (reset) begin
            state          <= IDLE;
            new_game_pulse <= 1'b0;
        end
        else begin
            new_game_pulse <= 1'b0;

            case (state)
                IDLE: begin
                    if (start_pulse) begin
                        state          <= PLAYING;
                        new_game_pulse <= 1'b1;
                    end
                end

                PLAYING: begin
                    if (collision)
                        state <= GAME_OVER;
                end

                GAME_OVER: begin
                    if (start_pulse) begin
                        state          <= PLAYING;
                        new_game_pulse <= 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    assign game_active = (state == PLAYING);
    assign game_over   = (state == GAME_OVER);
    assign show_pipe   = (state != IDLE);

endmodule
