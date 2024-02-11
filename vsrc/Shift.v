`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: Shift
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


module Shift #(
    WIDTH = 1
) (
    input en,
    input [WIDTH-1:0] in1,
    input [WIDTH-1:0] in2,
    input is_left,
    input is_logical,
    output [WIDTH-1:0] out
);
  assign out = en ? (is_left ? (in1 << in2) : is_logical ? (in1 >> in2) : (in1 >>> in2)) : 0;
endmodule
