module datapath(A, B, C, K );
input A, B , C;
output K,L,M;
AND2_X1 i_0 (.A(A),.B(B),.ZN(n_0));
OR2_X1 i_1 (.A(A),.B(C),.ZN(n_1));
AND2_X1 i_2 (.A(n_0),.B(n_1),.ZN(n_2));
INV_X1 i_3 (.A(n_2), .ZN(K));
endmodule
