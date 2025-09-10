// 1-bit Full Adder module
module full_adder (
    input A,
    input B,
    input Cin,
    output Sum,
    output Cout
);

    // Logic for the Sum and Carry Out
    assign Sum = A ^ B ^ Cin;
    assign Cout = (A & B) | (Cin & (A ^ B));

endmodule
