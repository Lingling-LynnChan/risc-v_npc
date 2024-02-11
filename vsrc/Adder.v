`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: Adder
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


module Adder #(
    WIDTH = 1
) (
    input en,
    input c0,  //进位
    input [WIDTH-1:0] in1,
    input [WIDTH-1:0] in2,
    output [WIDTH-1:0] sout,  //求和
    output cout  //进位
);
  assign {cout, sout} = en ? (in1 + in2 + c0) : 0;
endmodule
