`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2018 11:57:49 AM
// Design Name: 
// Module Name: Deskew_tb
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


module Deskew_tb#(
    parameter WIDTH = 16
    )
    (
    
    );
   //clock, reset
   logic clk = 0;
   logic reset;
   //control signals
   logic dskw_start;
   logic dskw_ready;
   //Data transfer signals beetween BRAM and DESKEW
   logic [10:0] dskw_address;
   logic [WIDTH-1 : 0] dskw_in_data;
   logic [WIDTH-1 : 0] dskw_out_data;
   logic               dskw_en;
   logic               dskw_we;
   //Signals to insert image into BRAM
   logic [10:0] bram_address;
   logic [WIDTH-1 : 0] bram_in_data;
   logic [WIDTH-1 : 0] bram_out_data;
   logic               bram_en;
   logic               bram_we;   
   
   int fd_img;
   int fd_img_2;   
   logic[15 : 0] queue[$];
   logic [63 : 0] pixel;
   logic[15:0] img;
   
   Deskew DUT
     (
      .clk(clk),
      .reset(reset),
      .start(dskw_start),
      .ready(dskw_ready),
      .address(dskw_address),
      .in_data(dskw_in_data),
      .out_data(dskw_out_data),
      .en(dskw_en),
      .we(dskw_we)
      );

   BRAM MEM
     (
      .pi_clka(clk),
      .pi_clkb(clk),
      .pi_ena(bram_en),
      .pi_enb(dskw_en),
      .pi_wea(bram_we),
      .pi_web(dskw_we),
      .pi_addra({bram_address}),
      .pi_addrb({dskw_address}),
      .pi_dia(bram_in_data),
      .pi_dib(dskw_out_data),
      .po_doa(bram_out_data),
      .po_dob(dskw_in_data)
      );
   
   initial begin    
       fd_img = ($fopen("C:/Users/Nikola/Documents/PROJEKAT_ML/ML_number_recognition_SVM/y_bin.txt", "r"));
       if(fd_img)begin
          $display("opened successfuly");
          for(int i = 0; i < 784; i++)begin
             $fscanf(fd_img ,"%b",img);
             if(i == 783)
                queue.push_back(0);
             else
                queue.push_back(img);
             $display("%d: ,%b", i, queue[i]);
          end
       end
       else
         $display("Error opening file");
       $fclose(fd_img);
   end // initial begin
   initial begin
      reset = 1;
      #100ns reset = 0;
      bram_en = 1;
      bram_we = 1;      
      for(int i = 0; i<784; i++)begin
         #100ns bram_address = i;
         bram_in_data = queue[i];
      end
      #100ns;
      bram_en = 0;
      bram_we = 0;
      #50ns dskw_start = 1;
      #150ns dskw_start = 0;
      wait (dskw_ready == 1);
      bram_en = 1;
      #200ns;
      fd_img_2 = ($fopen("C:/Users/Nikola/Documents/PROJEKAT_ML/ML_number_recognition_SVM/number_dskw.txt", "w"));
      if(fd_img)begin
          $display("file opened");
          for(int i = 0; i<784; i++) begin
            #100ns bram_address = 784 + i;
            $fwrite(fd_img,"%b\n",bram_out_data);  
          end      
      end
      else
        $display("error opening file");
      $fclose(fd_img_2);
      
   end
   
   always
		#50ns clk <= ~clk;
     
   
   
endmodule
