// Testbench for 4-to-1 Multiplexer
module tb_mux4to1;

    // Testbench signals
    reg [1:0] sel;      // 2-bit select input
    reg [3:0] in;       // 4-bit input data
    wire out;           // Single-bit output from mux
    integer pass_count = 0;   // Counter for passed test cases
    integer total_tests = 16; // 4 bits input * 4 select values = 16 test cases
    integer i;
    integer j;
    reg expected_out;
    // Instantiate the multiplexer
    mux4to1 uut (
        .sel(sel),
        .in(in),
        .out(out)
    );

    // Testbench process
    initial begin
        // Iterate over all possible input and select combinations
        for ( i = 0; i < 4; i = i + 1) begin
            for ( j = 0; j < 16; j = j + 1) begin
                sel = i;          // Assign i to sel
                in = j;           // Assign j to in
                #10;              // Wait for output to settle
                
                // Determine expected output based on sel
                
                case (sel)
                    2'b00: expected_out = in[0];
                    2'b01: expected_out = in[1];
                    2'b10: expected_out = in[2];
                    2'b11: expected_out = in[3];
                endcase

                // Check if actual output matches expected output
                if (out === expected_out) begin
                    pass_count = pass_count + 1;  // Increment pass count
                    $display("Test Case sel=%b, in=%b: PASS", sel, in);
                end else begin
                    $display("Test Case sel=%b, in=%b: FAIL (Expected %b, Got %b)", sel, in, expected_out, out);
                end
            end
        end

        // Display the number of passed tests
        $display("Total Passed Test Cases: %0d / %0d", pass_count, total_tests);

        // End simulation
        $finish;
    end

endmodule
