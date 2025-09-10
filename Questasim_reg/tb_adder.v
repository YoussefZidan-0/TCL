// Testbench for 1-bit Full Adder
module tb_full_adder;

    // Testbench signals
    reg A, B, Cin;
    wire Sum, Cout;
    reg expected_Sum;
    reg expected_Cout ;
    // Counter for passed test cases
    integer pass_count = 0;
    integer total_tests = 8;  // 2^3 = 8 possible test cases for 3 inputs
    integer i;
    // Instantiate the full adder
    full_adder uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    // Testbench process
    initial begin
        // Iterate over all possible input combinations
        
        for ( i = 0; i < total_tests; i = i + 1) begin
            {A, B, Cin} = i;  // Assign binary value of i to {A, B, Cin}
            
            // Wait for a time step to observe the output
            #10;
            
            // Expected values for Sum and Cout
             expected_Sum = A ^ B ^ Cin;
             expected_Cout = (A & B) | (Cin & (A ^ B));

            // Check if actual output matches expected output
            if (Sum === expected_Sum && Cout === expected_Cout) begin
                pass_count = pass_count + 1;  // Increment pass count
                $display("Test %0d: PASS | A=%b, B=%b, Cin=%b, Sum=%b, Cout=%b", i, A, B, Cin, Sum, Cout);
            end else begin
                $display("Test %0d: FAIL | A=%b, B=%b, Cin=%b, Sum=%b (Expected %b), Cout=%b (Expected %b)", 
                         i, A, B, Cin, Sum, expected_Sum, Cout, expected_Cout);
            end
        end

        // Display the number of passed tests
        $display("Total Passed Test Cases: %0d / %0d", pass_count, total_tests);
        
        // Stop the simulation
        $finish;
    end

endmodule
