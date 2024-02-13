`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: MuxMap
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


module top (
    input clk,
    input rst,
    output ebreak
);
  import "DPI-C" function bit [31:0] pmem_read(input bit [31:0] addr);
  wire [31:0] inst;
  wire [31:0] pc;
  GPC GPC32 (
      .clk (clk),
      .rst (rst),
      .inst(inst),
      .pc  (pc),
      .ebreak(ebreak)
  );
  assign inst = pmem_read(pc);

endmodule
