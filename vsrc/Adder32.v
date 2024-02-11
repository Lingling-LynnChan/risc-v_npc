`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: Adder32
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
    input [31:0] in1,
    input [31:0] in2,
    output [31:0] sout,  //求和
    output cout  //进位
);
  wire c1;
  Adder16 inst0 (
      .c0  (c0),
      .in1 (in1[15:0]),
      .in2 (in2[15:0]),
      .sout(sout[15:0]),
      .cout(c1)
  );
  Adder16 inst1 (
      .c0  (c1),
      .in1 (in1[31:16]),
      .in2 (in2[31:16]),
      .sout(sout[31:16]),
      .cout(cout)
  );
endmodule
