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
   //start
   input logic start_axi_i,
   output logic start_axi_o,
   output logic start_svm_o,
   //ready
   input logic  ready_svm_i,
   output logic ready_axi_o,
   //classified number
   input logic [3:0] cl_num_svm_i,
   output logic [3:0] cl_num_axi_o,
   //state
   input logic [3:0] state_svm_i,
   output logic [3:0] state_axi_o
   );

   logic start_s, ready_s;
   logic [3:0] cl_num_s;
   logic [3:0] state_s;
   
   //ASSIGN STATEMENTS
   assign start_svm_o = start_s;
   assign start_axi_o = start_s;
   assign ready_axi_o =ready_s;
   assign cl_num_axi_o = cl_num_s;
   assign state_axi_o = state_s;
   
   //START REG
   always_ff@(posedge clk)begin
      if(!reset)
         start_s <= 0;
      else
        start_s <= start_axi_i;
   end
   
   //READY REG
   always_ff@(posedge clk)begin
      if(!reset)
        ready_s <= 0;
      else
        ready_s <= ready_svm_i;
   end
   
   //CL_NUM REG
   always_ff@(posedge clk)begin
      if(!reset)
        cl_num_s <= 0;
      else
        cl_num_s <= cl_num_svm_i;
   end
   
   //STATE REG
   always_ff@(posedge clk)begin
      if(!reset)
        state_s <= 0;
      else
        state_s <= state_svm_i;
   end
endmodule
   
