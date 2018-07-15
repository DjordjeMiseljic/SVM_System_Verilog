`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2018 11:31:02 AM
// Design Name: 
// Module Name: memory_submodul
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


module memory_submodul
  (
   input logic  clk,
   input logic  reset,
   //control logic from axi
   input logic  cmd_wr_i,
   //output logic for axi
   output logic cmd_axi_o,
   output logic status_axi_o,
   output logic axi_intr_o,
   //output logic to deskew
   output logic start,
   //input logic from deskew
   input logic  ready,
   input logic  done_intr
   
   );

   logic        cmd_signal, status_signal, done_intr_signal;
   assign start = cmd_signal;
   assign cmd_axi_o = cmd_signal;
   assign status_axi_o = status_signal;
   assign axi_intr_o = done_intr_signal;
   
   //cmd register
   always_ff@(posedge clk)begin
      if(!reset)
         cmd_signal <= 0;
      else
        cmd_signal <= cmd_wr_i;
   end
   //status register
   always_ff@(posedge clk)begin
      if(!reset)
        status_signal <= 0;
      else
        status_signal <= ready;
   end
   //interrupt register
   always_ff@(posedge clk)begin
      if(!reset)
        done_intr_signal <= 0;
      else
       done_intr_signal <= done_intr;
   end
   
endmodule
