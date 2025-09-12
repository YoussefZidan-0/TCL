/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06
// Date      : Mon Sep  8 18:56:36 2025
/////////////////////////////////////////////////////////////


module UART_TX ( CLK, RST, PAR_TYP, PAR_EN, DATA_VALID, P_DATA, TX_OUT, Busy
 );
  input [7:0] P_DATA;
  input CLK, RST, PAR_TYP, PAR_EN, DATA_VALID;
  output TX_OUT, Busy;
  wire   n4, ser_en, ser_done, ser_data, par_bit, serializer_unit_n23,
         serializer_unit_n22, serializer_unit_n21, serializer_unit_n20,
         serializer_unit_n19, serializer_unit_n18, serializer_unit_n17,
         serializer_unit_n16, serializer_unit_n15, serializer_unit_n14,
         serializer_unit_n13, serializer_unit_n12, serializer_unit_n11,
         serializer_unit_n10, serializer_unit_n9, serializer_unit_n8,
         serializer_unit_n7, serializer_unit_n6, serializer_unit_n5,
         serializer_unit_n4, serializer_unit_n3, serializer_unit_n2,
         serializer_unit_n1, serializer_unit_N25, serializer_unit_N24,
         serializer_unit_N23, MUX_unit_n3, MUX_unit_n2, MUX_unit_mux_comb,
         FSM_unit_n11, FSM_unit_n10, FSM_unit_n9, FSM_unit_n8, FSM_unit_n7,
         FSM_unit_n6, FSM_unit_n4, FSM_unit_n3, FSM_unit_n2, FSM_unit_n1,
         FSM_unit_Busy_REG, parity_calc_unit_n16, parity_calc_unit_n15,
         parity_calc_unit_n14, parity_calc_unit_n13, parity_calc_unit_n12,
         parity_calc_unit_n11, parity_calc_unit_n10, parity_calc_unit_n9,
         parity_calc_unit_n8, parity_calc_unit_n7, parity_calc_unit_n6,
         parity_calc_unit_n5, parity_calc_unit_n4, parity_calc_unit_n3,
         parity_calc_unit_n2, parity_calc_unit_n1, n2, n3;
  wire   [1:0] mux_sel;
  wire   [2:0] serializer_unit_SER_COUNTER;
  wire   [7:1] serializer_unit_P_DATA_REG;
  wire   [2:0] FSM_unit_next_state;
  wire   [2:0] FSM_unit_current_state;
  wire   [7:0] parity_calc_unit_P_DATA_REG;

  NOR2X12M serializer_unit_U19 ( .A(serializer_unit_n3), .B(n3), .Y(
        serializer_unit_n6) );
  AO2B2X1M parity_calc_unit_U16 ( .B0(P_DATA[7]), .B1(n2), .A0(
        parity_calc_unit_P_DATA_REG[7]), .A1N(n2), .Y(parity_calc_unit_n16) );
  AO2B2X1M parity_calc_unit_U15 ( .B0(P_DATA[6]), .B1(n2), .A0(
        parity_calc_unit_P_DATA_REG[6]), .A1N(n2), .Y(parity_calc_unit_n15) );
  AO2B2X1M parity_calc_unit_U14 ( .B0(P_DATA[5]), .B1(n2), .A0(
        parity_calc_unit_P_DATA_REG[5]), .A1N(n2), .Y(parity_calc_unit_n14) );
  AO2B2X1M parity_calc_unit_U13 ( .B0(P_DATA[4]), .B1(n2), .A0(
        parity_calc_unit_P_DATA_REG[4]), .A1N(n2), .Y(parity_calc_unit_n13) );
  AO2B2X1M parity_calc_unit_U12 ( .B0(P_DATA[3]), .B1(n2), .A0(
        parity_calc_unit_P_DATA_REG[3]), .A1N(n2), .Y(parity_calc_unit_n12) );
  AO2B2X1M parity_calc_unit_U11 ( .B0(P_DATA[2]), .B1(n2), .A0(
        parity_calc_unit_P_DATA_REG[2]), .A1N(n2), .Y(parity_calc_unit_n11) );
  AO2B2X1M parity_calc_unit_U10 ( .B0(P_DATA[1]), .B1(n2), .A0(
        parity_calc_unit_P_DATA_REG[1]), .A1N(n2), .Y(parity_calc_unit_n10) );
  AO2B2X1M parity_calc_unit_U9 ( .B0(P_DATA[0]), .B1(n2), .A0(
        parity_calc_unit_P_DATA_REG[0]), .A1N(n2), .Y(parity_calc_unit_n9) );
  CLKXOR2X2M parity_calc_unit_U8 ( .A(parity_calc_unit_P_DATA_REG[7]), .B(
        parity_calc_unit_P_DATA_REG[6]), .Y(parity_calc_unit_n6) );
  XOR3XLM parity_calc_unit_U7 ( .A(parity_calc_unit_P_DATA_REG[5]), .B(
        parity_calc_unit_P_DATA_REG[4]), .C(parity_calc_unit_n6), .Y(
        parity_calc_unit_n3) );
  XNOR2X1M parity_calc_unit_U6 ( .A(parity_calc_unit_P_DATA_REG[2]), .B(
        parity_calc_unit_P_DATA_REG[3]), .Y(parity_calc_unit_n5) );
  XOR3XLM parity_calc_unit_U5 ( .A(parity_calc_unit_P_DATA_REG[1]), .B(
        parity_calc_unit_P_DATA_REG[0]), .C(parity_calc_unit_n5), .Y(
        parity_calc_unit_n4) );
  XOR3XLM parity_calc_unit_U4 ( .A(parity_calc_unit_n3), .B(PAR_TYP), .C(
        parity_calc_unit_n4), .Y(parity_calc_unit_n1) );
  OAI2BB2X1M parity_calc_unit_U2 ( .B0(parity_calc_unit_n1), .B1(
        parity_calc_unit_n2), .A0N(par_bit), .A1N(parity_calc_unit_n2), .Y(
        parity_calc_unit_n8) );
  DFFRX1M FSM_unit_Busy_reg ( .D(FSM_unit_Busy_REG), .CK(CLK), .RN(RST), .Q(n4) );
  DFFRX1M serializer_unit_SER_COUNTER_reg_1_ ( .D(serializer_unit_N24), .CK(
        CLK), .RN(RST), .Q(serializer_unit_SER_COUNTER[1]), .QN(
        serializer_unit_n2) );
  DFFRQX2M FSM_unit_current_state_reg_1_ ( .D(FSM_unit_next_state[1]), .CK(CLK), .RN(RST), .Q(FSM_unit_current_state[1]) );
  DFFRQX2M parity_calc_unit_par_bit_reg ( .D(parity_calc_unit_n8), .CK(CLK), 
        .RN(RST), .Q(par_bit) );
  DFFRQX2M parity_calc_unit_P_DATA_REG_reg_7_ ( .D(parity_calc_unit_n16), .CK(
        CLK), .RN(RST), .Q(parity_calc_unit_P_DATA_REG[7]) );
  DFFRQX2M parity_calc_unit_P_DATA_REG_reg_6_ ( .D(parity_calc_unit_n15), .CK(
        CLK), .RN(RST), .Q(parity_calc_unit_P_DATA_REG[6]) );
  DFFRQX2M parity_calc_unit_P_DATA_REG_reg_5_ ( .D(parity_calc_unit_n14), .CK(
        CLK), .RN(RST), .Q(parity_calc_unit_P_DATA_REG[5]) );
  DFFRQX2M parity_calc_unit_P_DATA_REG_reg_4_ ( .D(parity_calc_unit_n13), .CK(
        CLK), .RN(RST), .Q(parity_calc_unit_P_DATA_REG[4]) );
  DFFRQX2M parity_calc_unit_P_DATA_REG_reg_3_ ( .D(parity_calc_unit_n12), .CK(
        CLK), .RN(RST), .Q(parity_calc_unit_P_DATA_REG[3]) );
  DFFRQX2M parity_calc_unit_P_DATA_REG_reg_2_ ( .D(parity_calc_unit_n11), .CK(
        CLK), .RN(RST), .Q(parity_calc_unit_P_DATA_REG[2]) );
  DFFRQX2M parity_calc_unit_P_DATA_REG_reg_1_ ( .D(parity_calc_unit_n10), .CK(
        CLK), .RN(RST), .Q(parity_calc_unit_P_DATA_REG[1]) );
  DFFRQX2M parity_calc_unit_P_DATA_REG_reg_0_ ( .D(parity_calc_unit_n9), .CK(
        CLK), .RN(RST), .Q(parity_calc_unit_P_DATA_REG[0]) );
  DFFRQX2M serializer_unit_P_DATA_REG_reg_6_ ( .D(serializer_unit_n18), .CK(
        CLK), .RN(RST), .Q(serializer_unit_P_DATA_REG[6]) );
  DFFRQX2M serializer_unit_P_DATA_REG_reg_5_ ( .D(serializer_unit_n19), .CK(
        CLK), .RN(RST), .Q(serializer_unit_P_DATA_REG[5]) );
  DFFRQX2M serializer_unit_P_DATA_REG_reg_4_ ( .D(serializer_unit_n20), .CK(
        CLK), .RN(RST), .Q(serializer_unit_P_DATA_REG[4]) );
  DFFRQX2M serializer_unit_P_DATA_REG_reg_3_ ( .D(serializer_unit_n21), .CK(
        CLK), .RN(RST), .Q(serializer_unit_P_DATA_REG[3]) );
  DFFRQX2M serializer_unit_P_DATA_REG_reg_2_ ( .D(serializer_unit_n22), .CK(
        CLK), .RN(RST), .Q(serializer_unit_P_DATA_REG[2]) );
  DFFRQX2M serializer_unit_P_DATA_REG_reg_1_ ( .D(serializer_unit_n23), .CK(
        CLK), .RN(RST), .Q(serializer_unit_P_DATA_REG[1]) );
  DFFRQX2M serializer_unit_P_DATA_REG_reg_0_ ( .D(serializer_unit_n16), .CK(
        CLK), .RN(RST), .Q(ser_data) );
  DFFRQX2M serializer_unit_P_DATA_REG_reg_7_ ( .D(serializer_unit_n17), .CK(
        CLK), .RN(RST), .Q(serializer_unit_P_DATA_REG[7]) );
  DFFRHQX8M MUX_unit_MUX_OUT_reg ( .D(MUX_unit_mux_comb), .CK(CLK), .RN(RST), 
        .Q(TX_OUT) );
  DFFRX2M FSM_unit_current_state_reg_0_ ( .D(FSM_unit_next_state[0]), .CK(CLK), 
        .RN(RST), .Q(FSM_unit_current_state[0]), .QN(FSM_unit_n4) );
  DFFRX2M serializer_unit_SER_COUNTER_reg_0_ ( .D(serializer_unit_N23), .CK(
        CLK), .RN(RST), .Q(serializer_unit_SER_COUNTER[0]) );
  DFFRX2M FSM_unit_current_state_reg_2_ ( .D(FSM_unit_next_state[2]), .CK(CLK), 
        .RN(RST), .Q(FSM_unit_current_state[2]), .QN(FSM_unit_n2) );
  DFFRX2M serializer_unit_SER_COUNTER_reg_2_ ( .D(serializer_unit_N25), .CK(
        CLK), .RN(RST), .Q(serializer_unit_SER_COUNTER[2]), .QN(
        serializer_unit_n1) );
  INVX2M U3 ( .A(PAR_EN), .Y(parity_calc_unit_n2) );
  OAI21X2M U4 ( .A0(FSM_unit_current_state[2]), .A1(FSM_unit_current_state[0]), 
        .B0(FSM_unit_n3), .Y(mux_sel[0]) );
  AOI32X1M U5 ( .A0(serializer_unit_SER_COUNTER[0]), .A1(serializer_unit_n1), 
        .A2(serializer_unit_SER_COUNTER[1]), .B0(
        serializer_unit_SER_COUNTER[2]), .B1(serializer_unit_n2), .Y(
        serializer_unit_n14) );
  AND3X2M U6 ( .A(serializer_unit_SER_COUNTER[0]), .B(
        serializer_unit_SER_COUNTER[2]), .C(serializer_unit_SER_COUNTER[1]), 
        .Y(ser_done) );
  BUFX10M U7 ( .A(n4), .Y(Busy) );
  NOR2X2M U8 ( .A(FSM_unit_n8), .B(FSM_unit_current_state[0]), .Y(ser_en) );
  NAND2X2M U9 ( .A(FSM_unit_current_state[1]), .B(FSM_unit_n2), .Y(FSM_unit_n8) );
  NOR2X2M U10 ( .A(FSM_unit_current_state[0]), .B(FSM_unit_current_state[1]), 
        .Y(FSM_unit_n11) );
  NOR2X8M U11 ( .A(n3), .B(serializer_unit_n6), .Y(serializer_unit_n4) );
  OAI31X2M U12 ( .A0(parity_calc_unit_n2), .A1(FSM_unit_n6), .A2(FSM_unit_n1), 
        .B0(FSM_unit_n10), .Y(FSM_unit_next_state[0]) );
  NAND3X2M U13 ( .A(FSM_unit_n11), .B(FSM_unit_n2), .C(DATA_VALID), .Y(
        FSM_unit_n10) );
  INVX2M U14 ( .A(ser_en), .Y(serializer_unit_n3) );
  INVX2M U15 ( .A(FSM_unit_n11), .Y(FSM_unit_n3) );
  INVX2M U16 ( .A(ser_en), .Y(FSM_unit_n1) );
  INVX2M U17 ( .A(ser_done), .Y(FSM_unit_n6) );
  CLKBUFX8M U18 ( .A(parity_calc_unit_n7), .Y(n2) );
  NOR2BX1M U19 ( .AN(DATA_VALID), .B(Busy), .Y(parity_calc_unit_n7) );
  CLKBUFX6M U20 ( .A(serializer_unit_n7), .Y(n3) );
  NOR2BX1M U21 ( .AN(DATA_VALID), .B(Busy), .Y(serializer_unit_n7) );
  OAI2BB1X2M U22 ( .A0N(serializer_unit_n4), .A1N(
        serializer_unit_P_DATA_REG[6]), .B0(serializer_unit_n8), .Y(
        serializer_unit_n18) );
  AOI22X1M U23 ( .A0(serializer_unit_P_DATA_REG[7]), .A1(serializer_unit_n6), 
        .B0(P_DATA[6]), .B1(n3), .Y(serializer_unit_n8) );
  OAI2BB1X2M U24 ( .A0N(serializer_unit_n4), .A1N(
        serializer_unit_P_DATA_REG[5]), .B0(serializer_unit_n9), .Y(
        serializer_unit_n19) );
  AOI22X1M U25 ( .A0(serializer_unit_P_DATA_REG[6]), .A1(serializer_unit_n6), 
        .B0(P_DATA[5]), .B1(n3), .Y(serializer_unit_n9) );
  OAI2BB1X2M U26 ( .A0N(serializer_unit_n4), .A1N(
        serializer_unit_P_DATA_REG[4]), .B0(serializer_unit_n10), .Y(
        serializer_unit_n20) );
  AOI22X1M U27 ( .A0(serializer_unit_P_DATA_REG[5]), .A1(serializer_unit_n6), 
        .B0(P_DATA[4]), .B1(n3), .Y(serializer_unit_n10) );
  OAI2BB1X2M U28 ( .A0N(serializer_unit_n4), .A1N(
        serializer_unit_P_DATA_REG[3]), .B0(serializer_unit_n11), .Y(
        serializer_unit_n21) );
  AOI22X1M U29 ( .A0(serializer_unit_P_DATA_REG[4]), .A1(serializer_unit_n6), 
        .B0(P_DATA[3]), .B1(n3), .Y(serializer_unit_n11) );
  OAI2BB1X2M U30 ( .A0N(serializer_unit_n4), .A1N(
        serializer_unit_P_DATA_REG[2]), .B0(serializer_unit_n12), .Y(
        serializer_unit_n22) );
  AOI22X1M U31 ( .A0(serializer_unit_P_DATA_REG[3]), .A1(serializer_unit_n6), 
        .B0(P_DATA[2]), .B1(n3), .Y(serializer_unit_n12) );
  OAI2BB1X2M U32 ( .A0N(serializer_unit_P_DATA_REG[1]), .A1N(
        serializer_unit_n4), .B0(serializer_unit_n13), .Y(serializer_unit_n23)
         );
  AOI22X1M U33 ( .A0(serializer_unit_P_DATA_REG[2]), .A1(serializer_unit_n6), 
        .B0(P_DATA[1]), .B1(n3), .Y(serializer_unit_n13) );
  OAI2BB1X2M U34 ( .A0N(ser_data), .A1N(serializer_unit_n4), .B0(
        serializer_unit_n5), .Y(serializer_unit_n16) );
  AOI22X1M U35 ( .A0(serializer_unit_P_DATA_REG[1]), .A1(serializer_unit_n6), 
        .B0(P_DATA[0]), .B1(n3), .Y(serializer_unit_n5) );
  AO22X1M U36 ( .A0(serializer_unit_n4), .A1(serializer_unit_P_DATA_REG[7]), 
        .B0(P_DATA[7]), .B1(n3), .Y(serializer_unit_n17) );
  NOR2X2M U37 ( .A(FSM_unit_n7), .B(FSM_unit_n8), .Y(FSM_unit_next_state[2])
         );
  AOI21X2M U38 ( .A0(ser_done), .A1(parity_calc_unit_n2), .B0(
        FSM_unit_current_state[0]), .Y(FSM_unit_n7) );
  OAI32X2M U39 ( .A0(FSM_unit_n4), .A1(FSM_unit_current_state[2]), .A2(
        FSM_unit_current_state[1]), .B0(FSM_unit_n9), .B1(FSM_unit_n1), .Y(
        FSM_unit_next_state[1]) );
  NOR2X2M U40 ( .A(PAR_EN), .B(FSM_unit_n6), .Y(FSM_unit_n9) );
  OAI2B2X1M U41 ( .A1N(mux_sel[1]), .A0(MUX_unit_n2), .B0(mux_sel[1]), .B1(
        MUX_unit_n3), .Y(MUX_unit_mux_comb) );
  NAND2X2M U42 ( .A(ser_data), .B(mux_sel[0]), .Y(MUX_unit_n3) );
  NOR2X2M U43 ( .A(par_bit), .B(mux_sel[0]), .Y(MUX_unit_n2) );
  OAI21X2M U44 ( .A0(FSM_unit_n8), .A1(FSM_unit_n4), .B0(FSM_unit_n3), .Y(
        mux_sel[1]) );
  NOR2X2M U45 ( .A(serializer_unit_n3), .B(serializer_unit_SER_COUNTER[0]), 
        .Y(serializer_unit_N23) );
  OAI2BB2X1M U46 ( .B0(serializer_unit_n14), .B1(serializer_unit_n3), .A0N(
        serializer_unit_SER_COUNTER[2]), .A1N(serializer_unit_N23), .Y(
        serializer_unit_N25) );
  OAI221X1M U47 ( .A0(FSM_unit_n3), .A1(FSM_unit_n2), .B0(
        FSM_unit_current_state[2]), .B1(FSM_unit_n4), .C0(FSM_unit_n8), .Y(
        FSM_unit_Busy_REG) );
  NOR2X2M U48 ( .A(serializer_unit_n15), .B(serializer_unit_n3), .Y(
        serializer_unit_N24) );
  CLKXOR2X2M U49 ( .A(serializer_unit_SER_COUNTER[0]), .B(serializer_unit_n2), 
        .Y(serializer_unit_n15) );
endmodule

