/*
 * Created by 
   ../bin/Linux-x86_64-O/oasysGui 19.2-p002 on Sat Oct 29 11:08:28 2022
 * (C) Mentor Graphics Corporation
 */
/* CheckSum: 2530884883 */

module datapath(inputB, inputA, p_0);
   input [7:0]inputB;
   input [7:0]inputA;
   output [8:0]p_0;

   HA_X1 i_0 (.A(inputB[0]), .B(inputA[0]), .CO(n_0), .S(p_0[0]));
   HA_X1 i_1 (.A(inputB[1]), .B(inputA[1]), .CO(n_2), .S(n_1));
   HA_X1 i_2 (.A(inputB[2]), .B(inputA[2]), .CO(n_6), .S(n_5));
   HA_X1 i_3 (.A(inputB[3]), .B(inputA[3]), .CO(n_10), .S(n_9));
   HA_X1 i_4 (.A(inputB[4]), .B(inputA[4]), .CO(n_14), .S(n_13));
   HA_X1 i_5 (.A(inputB[5]), .B(inputA[5]), .CO(n_18), .S(n_17));
   HA_X1 i_6 (.A(inputB[6]), .B(inputA[6]), .CO(n_22), .S(n_21));
   HA_X1 i_7 (.A(inputB[7]), .B(inputA[7]), .CO(n_26), .S(n_25));
   XOR2_X1 i_8 (.A(n_0), .B(n_1), .Z(p_0[1]));
   XNOR2_X1 i_9 (.A(n_5), .B(n_27), .ZN(p_0[2]));
   XNOR2_X1 i_10 (.A(n_9), .B(n_23), .ZN(p_0[3]));
   XNOR2_X1 i_11 (.A(n_13), .B(n_19), .ZN(p_0[4]));
   XNOR2_X1 i_12 (.A(n_17), .B(n_15), .ZN(p_0[5]));
   XNOR2_X1 i_13 (.A(n_21), .B(n_11), .ZN(p_0[6]));
   XNOR2_X1 i_14 (.A(n_25), .B(n_7), .ZN(p_0[7]));
   INV_X1 i_15 (.A(n_3), .ZN(p_0[8]));
   AOI21_X1 i_16 (.A(n_26), .B1(n_25), .B2(n_4), .ZN(n_3));
   INV_X1 i_17 (.A(n_7), .ZN(n_4));
   AOI21_X1 i_18 (.A(n_22), .B1(n_21), .B2(n_8), .ZN(n_7));
   INV_X1 i_19 (.A(n_11), .ZN(n_8));
   AOI21_X1 i_20 (.A(n_18), .B1(n_17), .B2(n_12), .ZN(n_11));
   INV_X1 i_21 (.A(n_15), .ZN(n_12));
   AOI21_X1 i_22 (.A(n_14), .B1(n_13), .B2(n_16), .ZN(n_15));
   INV_X1 i_23 (.A(n_19), .ZN(n_16));
   AOI21_X1 i_24 (.A(n_10), .B1(n_9), .B2(n_20), .ZN(n_19));
   INV_X1 i_25 (.A(n_23), .ZN(n_20));
   AOI21_X1 i_26 (.A(n_6), .B1(n_5), .B2(n_24), .ZN(n_23));
   INV_X1 i_27 (.A(n_27), .ZN(n_24));
   AOI21_X1 i_28 (.A(n_2), .B1(n_0), .B2(n_1), .ZN(n_27));
endmodule

module adderPlus(inputA, inputB, Sum, Carry);
   input [7:0]inputA;
   input [7:0]inputB;
   output [7:0]Sum;
   output Carry;

   datapath i_0_0 (.inputB(inputB), .inputA(inputA), .p_0({Carry, Sum[7], Sum[6], 
      Sum[5], Sum[4], Sum[3], Sum[2], Sum[1], Sum[0]}));
endmodule
