// 4-to-1 Multiplexer module
module mux4to1 (
    input [1:0] sel,   // 2-bit select input
    input [3:0] in,    // 4-bit input data
    output out         // Single-bit output
);

    // Multiplexer logic
    assign out = (sel == 2'b00) ? in[0] :
                 (sel == 2'b01) ? in[1] :
                 (sel == 2'b10) ? in[2] :
                                  in[3];

endmodule
