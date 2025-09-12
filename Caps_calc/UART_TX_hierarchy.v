/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : K-2015.06
// Date      : Mon Sep  8 18:44:48 2025
/////////////////////////////////////////////////////////////


module serializer ( CLK, RST, P_DATA, DATA_VALID, Busy, SER_EN, SER_DONE, 
        SER_DATA );
  input [7:0] P_DATA;
  input CLK, RST, DATA_VALID, Busy, SER_EN;
  output SER_DONE, SER_DATA;
  wire   N23, N25, n15, n16, n17, n18, n19, n20, n21, n22, n1, n2, n3, n4, n5,
         n6, n7, n8, n9, n10, n11, n12, n13, n14, n23;
  wire   [7:1] P_DATA_REG;
  wire   [2:0] SER_COUNTER;

  DFFRQX1M P_DATA_REG_reg_7_ ( .D(n16), .CK(CLK), .RN(RST), .Q(P_DATA_REG[7])
         );
  DFFRQX1M P_DATA_REG_reg_6_ ( .D(n17), .CK(CLK), .RN(RST), .Q(P_DATA_REG[6])
         );
  DFFRQX1M P_DATA_REG_reg_5_ ( .D(n18), .CK(CLK), .RN(RST), .Q(P_DATA_REG[5])
         );
  DFFRQX1M P_DATA_REG_reg_4_ ( .D(n19), .CK(CLK), .RN(RST), .Q(P_DATA_REG[4])
         );
  DFFRQX1M P_DATA_REG_reg_3_ ( .D(n20), .CK(CLK), .RN(RST), .Q(P_DATA_REG[3])
         );
  DFFRQX1M P_DATA_REG_reg_2_ ( .D(n21), .CK(CLK), .RN(RST), .Q(P_DATA_REG[2])
         );
  DFFRQX1M P_DATA_REG_reg_1_ ( .D(n22), .CK(CLK), .RN(RST), .Q(P_DATA_REG[1])
         );
  DFFRQX1M P_DATA_REG_reg_0_ ( .D(n15), .CK(CLK), .RN(RST), .Q(SER_DATA) );
  DFFRQX1M SER_COUNTER_reg_2_ ( .D(N25), .CK(CLK), .RN(RST), .Q(SER_COUNTER[2]) );
  DFFRQX2M SER_COUNTER_reg_0_ ( .D(N23), .CK(CLK), .RN(RST), .Q(SER_COUNTER[0]) );
  DFFSX2M SER_COUNTER_reg_1_ ( .D(n23), .CK(CLK), .SN(RST), .QN(SER_COUNTER[1]) );
  AOI222X2M U3 ( .A0(n11), .A1(P_DATA[1]), .B0(n10), .B1(P_DATA_REG[1]), .C0(
        n8), .C1(P_DATA_REG[2]), .Y(n9) );
  AOI222X2M U4 ( .A0(n11), .A1(P_DATA[3]), .B0(n10), .B1(P_DATA_REG[3]), .C0(
        n8), .C1(P_DATA_REG[4]), .Y(n4) );
  AOI222X2M U5 ( .A0(n11), .A1(P_DATA[5]), .B0(n10), .B1(P_DATA_REG[5]), .C0(
        n8), .C1(P_DATA_REG[6]), .Y(n6) );
  AOI222X2M U6 ( .A0(n11), .A1(P_DATA[2]), .B0(n10), .B1(P_DATA_REG[2]), .C0(
        n8), .C1(P_DATA_REG[3]), .Y(n3) );
  AOI222X2M U7 ( .A0(n11), .A1(P_DATA[4]), .B0(n10), .B1(P_DATA_REG[4]), .C0(
        n8), .C1(P_DATA_REG[5]), .Y(n5) );
  AOI222X2M U8 ( .A0(n11), .A1(P_DATA[6]), .B0(n10), .B1(P_DATA_REG[6]), .C0(
        n8), .C1(P_DATA_REG[7]), .Y(n7) );
  AOI222X2M U9 ( .A0(n11), .A1(P_DATA[0]), .B0(n10), .B1(SER_DATA), .C0(
        P_DATA_REG[1]), .C1(n8), .Y(n2) );
  AOI211X2M U10 ( .A0(n14), .A1(n13), .B0(SER_DONE), .C0(n12), .Y(N25) );
  OAI211X1M U11 ( .A0(SER_COUNTER[0]), .A1(SER_COUNTER[1]), .B0(SER_EN), .C0(
        n14), .Y(n23) );
  NAND2X1M U12 ( .A(SER_COUNTER[0]), .B(SER_COUNTER[1]), .Y(n14) );
  NOR2X8M U13 ( .A(n11), .B(n12), .Y(n8) );
  NOR2X1M U14 ( .A(SER_COUNTER[0]), .B(n12), .Y(N23) );
  CLKINVX2M U15 ( .A(SER_EN), .Y(n12) );
  NOR2BX1M U16 ( .AN(DATA_VALID), .B(Busy), .Y(n1) );
  AND3X2M U17 ( .A(SER_COUNTER[0]), .B(SER_COUNTER[1]), .C(SER_COUNTER[2]), 
        .Y(SER_DONE) );
  NOR2X8M U18 ( .A(SER_EN), .B(n11), .Y(n10) );
  BUFX5M U19 ( .A(n1), .Y(n11) );
  CLKINVX1M U20 ( .A(n2), .Y(n15) );
  CLKINVX1M U21 ( .A(n3), .Y(n21) );
  CLKINVX1M U22 ( .A(n4), .Y(n20) );
  CLKINVX1M U23 ( .A(n5), .Y(n19) );
  CLKINVX1M U24 ( .A(n6), .Y(n18) );
  CLKINVX1M U25 ( .A(n7), .Y(n17) );
  CLKINVX1M U26 ( .A(n9), .Y(n22) );
  AO22XLM U27 ( .A0(n11), .A1(P_DATA[7]), .B0(n10), .B1(P_DATA_REG[7]), .Y(n16) );
  CLKINVX1M U28 ( .A(SER_COUNTER[2]), .Y(n13) );
endmodule


module MUX ( CLK, RST, mux_sel, IN0, IN1, IN2, IN3, MUX_OUT );
  input [1:0] mux_sel;
  input CLK, RST, IN0, IN1, IN2, IN3;
  output MUX_OUT;
  wire   mux_comb, n1;

  DFFRHQX8M MUX_OUT_reg ( .D(mux_comb), .CK(CLK), .RN(RST), .Q(MUX_OUT) );
  OAI21X1M U3 ( .A0(mux_sel[1]), .A1(IN1), .B0(mux_sel[0]), .Y(n1) );
  OAI2BB1XLM U4 ( .A0N(IN2), .A1N(mux_sel[1]), .B0(n1), .Y(mux_comb) );
endmodule


module FSM ( CLK, RST, DATA_VALID, PAR_EN, SER_DONE, SER_EN, Busy, mux_sel );
  output [1:0] mux_sel;
  input CLK, RST, DATA_VALID, PAR_EN, SER_DONE;
  output SER_EN, Busy;
  wire   n12, Busy_REG, n1, n3, n4, n5, n6, n7, n8, n10, n11;
  wire   [2:0] current_state;
  wire   [2:1] next_state;

  DFFSX2M current_state_reg_0_ ( .D(n10), .CK(CLK), .SN(RST), .Q(n11), .QN(
        current_state[0]) );
  DFFRQX4M current_state_reg_2_ ( .D(next_state[2]), .CK(CLK), .RN(RST), .Q(
        current_state[2]) );
  DFFRQX2M current_state_reg_1_ ( .D(next_state[1]), .CK(CLK), .RN(RST), .Q(
        current_state[1]) );
  DFFSRHQX1M Busy_reg ( .D(Busy_REG), .CK(CLK), .SN(1'b1), .RN(RST), .Q(n12)
         );
  AOI32X1M U3 ( .A0(n4), .A1(n6), .A2(n11), .B0(current_state[2]), .B1(n3), 
        .Y(Busy_REG) );
  AOI33X2M U4 ( .A0(n6), .A1(n5), .A2(DATA_VALID), .B0(PAR_EN), .B1(SER_DONE), 
        .B2(SER_EN), .Y(n10) );
  CLKINVX1M U5 ( .A(n12), .Y(n1) );
  INVX8M U6 ( .A(n1), .Y(Busy) );
  AOI211X2M U7 ( .A0(n11), .A1(n7), .B0(current_state[2]), .C0(n4), .Y(
        next_state[2]) );
  NAND2BX1M U8 ( .AN(PAR_EN), .B(SER_DONE), .Y(n7) );
  OAI31X2M U9 ( .A0(current_state[2]), .A1(current_state[1]), .A2(n11), .B0(n8), .Y(next_state[1]) );
  INVX2M U10 ( .A(current_state[1]), .Y(n4) );
  NOR2X2M U11 ( .A(current_state[1]), .B(current_state[0]), .Y(n5) );
  AOI21X1M U12 ( .A0(current_state[2]), .A1(current_state[1]), .B0(
        current_state[0]), .Y(mux_sel[0]) );
  NOR3X12M U13 ( .A(current_state[2]), .B(current_state[0]), .C(n4), .Y(SER_EN) );
  OAI31X4M U14 ( .A0(current_state[2]), .A1(n4), .A2(n11), .B0(n3), .Y(
        mux_sel[1]) );
  CLKINVX1M U16 ( .A(current_state[2]), .Y(n6) );
  CLKINVX1M U17 ( .A(n5), .Y(n3) );
  NAND2XLM U18 ( .A(SER_EN), .B(n7), .Y(n8) );
endmodule


module parity_calc ( P_DATA, Busy, DATA_VALID, PAR_TYPE, PAR_EN, CLK, RST, 
        par_bit );
  input [7:0] P_DATA;
  input Busy, DATA_VALID, PAR_TYPE, PAR_EN, CLK, RST;
  output par_bit;
  wire   n11, n12, n13, n14, n15, n16, n17, n18, n19, n1, n2, n3, n4, n5, n6,
         n7, n8, n9;
  wire   [7:0] P_DATA_REG;

  DFFRQX1M P_DATA_REG_reg_7_ ( .D(n19), .CK(CLK), .RN(RST), .Q(P_DATA_REG[7])
         );
  DFFRQX1M P_DATA_REG_reg_6_ ( .D(n18), .CK(CLK), .RN(RST), .Q(P_DATA_REG[6])
         );
  DFFRQX1M P_DATA_REG_reg_5_ ( .D(n17), .CK(CLK), .RN(RST), .Q(P_DATA_REG[5])
         );
  DFFRQX1M P_DATA_REG_reg_4_ ( .D(n16), .CK(CLK), .RN(RST), .Q(P_DATA_REG[4])
         );
  DFFRQX1M P_DATA_REG_reg_3_ ( .D(n15), .CK(CLK), .RN(RST), .Q(P_DATA_REG[3])
         );
  DFFRQX1M P_DATA_REG_reg_0_ ( .D(n12), .CK(CLK), .RN(RST), .Q(P_DATA_REG[0])
         );
  DFFRQX1M par_bit_reg ( .D(n11), .CK(CLK), .RN(RST), .Q(par_bit) );
  DFFRQX2M P_DATA_REG_reg_1_ ( .D(n13), .CK(CLK), .RN(RST), .Q(P_DATA_REG[1])
         );
  DFFRQX2M P_DATA_REG_reg_2_ ( .D(n14), .CK(CLK), .RN(RST), .Q(P_DATA_REG[2])
         );
  CLKBUFX4M U2 ( .A(n7), .Y(n8) );
  OAI2B1X1M U3 ( .A1N(par_bit), .A0(PAR_EN), .B0(n6), .Y(n11) );
  OAI211X1M U4 ( .A0(n5), .A1(n4), .B0(PAR_EN), .C0(n3), .Y(n6) );
  XOR3X1M U5 ( .A(PAR_TYPE), .B(P_DATA_REG[0]), .C(n2), .Y(n4) );
  AOI2BB2X2M U6 ( .B0(P_DATA_REG[1]), .B1(P_DATA_REG[2]), .A0N(P_DATA_REG[2]), 
        .A1N(P_DATA_REG[1]), .Y(n5) );
  CLKINVX4M U7 ( .A(n8), .Y(n9) );
  XOR3XLM U8 ( .A(P_DATA_REG[4]), .B(P_DATA_REG[5]), .C(P_DATA_REG[7]), .Y(n1)
         );
  XOR3XLM U9 ( .A(P_DATA_REG[3]), .B(P_DATA_REG[6]), .C(n1), .Y(n2) );
  NAND2XLM U10 ( .A(n5), .B(n4), .Y(n3) );
  NAND2BXLM U11 ( .AN(Busy), .B(DATA_VALID), .Y(n7) );
  AO22XLM U12 ( .A0(n9), .A1(P_DATA[0]), .B0(n8), .B1(P_DATA_REG[0]), .Y(n12)
         );
  AO22XLM U13 ( .A0(n9), .A1(P_DATA[5]), .B0(n8), .B1(P_DATA_REG[5]), .Y(n17)
         );
  AO22XLM U14 ( .A0(n9), .A1(P_DATA[7]), .B0(n8), .B1(P_DATA_REG[7]), .Y(n19)
         );
  AO22XLM U15 ( .A0(n9), .A1(P_DATA[6]), .B0(n8), .B1(P_DATA_REG[6]), .Y(n18)
         );
  AO22XLM U16 ( .A0(n9), .A1(P_DATA[3]), .B0(n8), .B1(P_DATA_REG[3]), .Y(n15)
         );
  AO22XLM U17 ( .A0(n9), .A1(P_DATA[4]), .B0(n8), .B1(P_DATA_REG[4]), .Y(n16)
         );
  AO22XLM U18 ( .A0(n9), .A1(P_DATA[2]), .B0(n8), .B1(P_DATA_REG[2]), .Y(n14)
         );
  AO22XLM U19 ( .A0(n9), .A1(P_DATA[1]), .B0(n8), .B1(P_DATA_REG[1]), .Y(n13)
         );
endmodule


module UART_TX ( CLK, RST, PAR_TYP, PAR_EN, DATA_VALID, P_DATA, TX_OUT, Busy
 );
  input [7:0] P_DATA;
  input CLK, RST, PAR_TYP, PAR_EN, DATA_VALID;
  output TX_OUT, Busy;
  wire   ser_en, ser_done, ser_data, par_bit;
  wire   [1:0] mux_sel;

  serializer serializer_unit ( .CLK(CLK), .RST(RST), .P_DATA(P_DATA), 
        .DATA_VALID(DATA_VALID), .Busy(Busy), .SER_EN(ser_en), .SER_DONE(
        ser_done), .SER_DATA(ser_data) );
  MUX MUX_unit ( .CLK(CLK), .RST(RST), .mux_sel(mux_sel), .IN0(1'b0), .IN1(
        ser_data), .IN2(par_bit), .IN3(1'b1), .MUX_OUT(TX_OUT) );
  FSM FSM_unit ( .CLK(CLK), .RST(RST), .DATA_VALID(DATA_VALID), .PAR_EN(PAR_EN), .SER_DONE(ser_done), .SER_EN(ser_en), .Busy(Busy), .mux_sel(mux_sel) );
  parity_calc parity_calc_unit ( .P_DATA(P_DATA), .Busy(Busy), .DATA_VALID(
        DATA_VALID), .PAR_TYPE(PAR_TYP), .PAR_EN(PAR_EN), .CLK(CLK), .RST(RST), 
        .par_bit(par_bit) );
endmodule

