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
// Dependencies: x删除字符 dd删除行 yy复制行 p/P粘贴到下/上方 o/O插入新行到下/上方 u 撤回
// ngg转到行 0nl(n|)跳转列 n[enter]偏移行 nl偏移列
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


endmodule
