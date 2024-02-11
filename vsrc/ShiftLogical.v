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
    input [WIDTH-1:0] ins,
    input [WIDTH-1:0] inw,
    input is_left,
    input is_logical,
    output [WIDTH-1:0] out
);
  assign out = is_left ? (inw << ins) : is_logical ? (inw >> ins) : inw >>> ins;
endmodule
