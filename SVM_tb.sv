`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Team Kole
// Engineer: Djordje 'Miske Debug' Miseljic
// 
// Create Date: 07/06/2018 02:52:17 PM
// Design Name: 
// Module Name: SVM_tb
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


module SVM_tb#
(
   parameter WIDTH = 16
)
(
);
   //clock, reset
   logic                clk_s;
   logic                reset_s;
   //status signals
   logic                start_s;
   logic                ready_s;
   logic                interrupt_s;
   logic                [3:0] cl_num_s;
   //stream interface signals
   logic                [WIDTH-1:0] sdata_s;
   logic                svalid_s;
   logic                sready_s;
   //bram interface signals 1
   logic                [WIDTH-1:0] bdata_in_s;
   logic                [WIDTH-1:0] bdata_out_s;
   logic                [9:0] baddr_s;
   logic                en_s;
   logic                we_s;
   //bram interface signals 2
   logic                [WIDTH-1:0] bdata_in_s2;
   logic                [WIDTH-1:0] bdata_out_s2;
   logic                [9:0] baddr_s2;
   logic                en_s2;
   logic                we_s2;
   
   
   string dir = "C:\Users\Djordje\ML_number_recognition_SVM\bin_data";
   logic[15 : 0] yQ[$];
   logic[15 : 0] yQ[$];
   logic[15 : 0] yQ[$];
   logic[15 : 0] yQ[$];
   logic[15 : 0] yQ[$];


   SVM DUT
   (
      .clk(clk_s),
      .reset(reset_s),
      .start(start_s),
      .ready(ready_s),
      .interrupt(interrupt_s),
      .cl_num(cl_num_s),
      .sdata(sdata_s),
      .svalid(svalid_s),
      .sready(sready_s),
      .bdata_in(bdata_in_s),
      .bdata_out(bdata_out_s),
      .baddr(baddr_s),
      .en(en_s),
      .we(we_s)
   );
   BRAM MEM
   (
      .pi_clka(clk_s),
      .pi_clkb(clk_s),
      .pi_ena(en_s),
      .pi_enb(en_s2),
      .pi_wea(we_s),
      .pi_web(we_s2),
      .pi_addra({baddr_s}),
      .pi_addrb({baddr_s2}),
      .pi_dia(bdata_in_s),
      .pi_dib(bdata_in_s2),
      .po_doa(bdata_out_s),
      .po_dob(bdata_out_s2)
   );



endmodule
