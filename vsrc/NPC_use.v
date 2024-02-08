`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: NPC_use
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


module NPC_use (
    input clk,
    input rst
);
  reg  [31:0] inst;
  wire [31:0] pc;
  NPC NPC_inst (
      .clk(clk),
      .global_rst(rst),
      .inst(inst),
      .pc(pc)
  );
  reg  [ 9:0] ram_addr;  //RAM地址选择信号
  reg  [ 3:0] ram_wen;  //RAM写使能
  reg  [31:0] ram_din;  //RAM写数据
  wire [31:0] ram_dout;  //RAM输出信号
  BLK_RAM_32x1024 blk_ram (
      .clka (clk),
      .addra(ram_addr),
      .wea  (ram_wen),
      .dina (ram_din),
      .douta(ram_dout)
  );
  function [31:0] pmem_read_inst;
    input pc;
    begin
      //TODO: 读指令
    end
  endfunction
  always @(clk) begin
    inst <= pmem_read_inst(pc);
  end
endmodule
