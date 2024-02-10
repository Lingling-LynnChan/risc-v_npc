`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: ALU
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


module ALU #(  //算术逻辑单元
    WIDTH = 1  //位宽
) (
    input [WIDTH-1:0] in1,
    input [WIDTH-1:0] in2,
    input [2:0] sel,  //运算选择: add、sub、xor、or、and、sll、srl、sra
    output [WIDTH-1:0] out1,
    output out2
);
  wire [WIDTH-1:0] out8to1[8];  //八选一输入端


endmodule
