`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: Adder4
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


module Adder4 (  //先行进位加法器
    input c0,  //进位
    input [3:0] in1,
    input [3:0] in2,
    output [3:0] sout,  //求和
    output cout  //进位
);
  wire [3:0] g;  //生成
  wire [3:0] p;  //传递
  /* verilator lint_off UNOPTFLAT */wire [4:0] c;  //进位
  assign g = in1 & in2;
  assign p = in1 ^ in2;
  assign c[0] = c0;
  assign c[1] = g[0] | (c[0] & p[0]);
  assign c[2] = g[1] | (g[0] & p[1]) | (c[0] & p[0] & p[1]);
  assign c[3] = g[2] | (g[1] & p[2]) | (g[0] & p[1] & p[2]) | (c[0] & p[0] & p[1] & p[2]);
  assign c[4] = g[3] | (g[2]&p[3])| (g[1] & p[2] & p[3]) | (g[0] & p[1] & p[2] & p[3]) | (c[0] & p[0] & p[1] & p[2] & p[3]);
  assign sout = p ^ c[3:0];
  assign cout = c[4];
endmodule
