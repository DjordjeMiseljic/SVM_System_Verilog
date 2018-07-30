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
   output logic  cmd_wr_o,
   output logic status_axi_o,
   
   //output logic to deskew
   output logic start,
   //input logic from deskew
   input logic  ready
   
   
   );

   logic        cmd_signal, status_signal, done_intr_signal;
   assign start = cmd_signal;
   
   assign status_axi_o = status_signal;
   assign cmd_wr_o = cmd_signal;
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
   
   
endmodule
