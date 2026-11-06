module sevenseg (
    input  logic [3:0] bin_in,
    output logic [6:0] seg_out
);

    // DE10-Lite seven-segment displays are active-low.
    always_comb begin
        case (bin_in)
            4'd0: seg_out = 7'b1000000;
            4'd1: seg_out = 7'b1111001;
            4'd2: seg_out = 7'b0100100;
            4'd3: seg_out = 7'b0110000;
            4'd4: seg_out = 7'b0011001;
            4'd5: seg_out = 7'b0010010;
            4'd6: seg_out = 7'b0000010;
            4'd7: seg_out = 7'b1111000;
            4'd8: seg_out = 7'b0000000;
            4'd9: seg_out = 7'b0010000;
            default: seg_out = 7'b1111111;
        endcase
    end

endmodule
