`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: Boot
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


module Boot (
    input  clk,
    input  global_rst,
    output init_rst
);
  //TODO: 理论上这个模块应该是收到global_rst时，拉高init_rst，
  //TODO: 再在该模块中把引导程序加载到0x80000000处，再拉低init_rst，
  //TODO: 但是由于我们的引导程序是在c++中加载的，所以这个模块暂时不做任何事情
  //TODO: 未来引导程序可能存在于ROM、Flash、SD卡等存储设备中，那时再修改这个模块
  assign init_rst = global_rst;
endmodule
