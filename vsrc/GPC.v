`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: GPC
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


module GPC (  //Gwen Processor Core
    input  wire        clk,    //时钟信号
    input  wire        rst,    //全局复位
    input  wire [31:0] inst,   //返回的指令
    output wire [31:0] pc,
    output wire        ebreak
);
  assign pc = 32'h80000000;
  assign ebreak = 1;

endmodule
