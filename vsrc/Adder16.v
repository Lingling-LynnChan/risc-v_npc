`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: Adder16
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module Adder16 (  //先行进位加法器
    input c0,  //进位
    input [15:0] in1,
    input [15:0] in2,
    output [15:0] sout,  //求和
    output cout  //进位
);
  wire c[3:1];
  Adder4 inst0 (
      .c0  (c0),
      .in1 (in1[3:0]),
      .in2 (in2[3:0]),
      .sout(sout[3:0]),
      .cout(c[1])
  );
  Adder4 inst1 (
      .c0  (c[1]),
      .in1 (in1[7:4]),
      .in2 (in2[7:4]),
      .sout(sout[7:4]),
      .cout(c[2])
  );
  Adder4 inst2 (
      .c0  (c[2]),
      .in1 (in1[11:8]),
      .in2 (in2[11:8]),
      .sout(sout[11:8]),
      .cout(c[3])
  );
  Adder4 inst3 (
      .c0  (c[3]),
      .in1 (in1[15:12]),
      .in2 (in2[15:12]),
      .sout(sout[15:12]),
      .cout(cout)
  );
endmodule
