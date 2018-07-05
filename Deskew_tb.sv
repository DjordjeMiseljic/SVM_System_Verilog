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
//`define ONE_IMG 1
`define MULTIPLE_IMG 1

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
   logic dskw_done_interrupt;
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
   logic [15 : 0] golden_vectors[$];
   logic [16 : 0] golden_vector;
   logic [16 : 0] golden_vector2;
   logic[15:0] img;
   int k1 = 0;
   int k2 = 0, k3 = 0;
   int i =0;
   
   string file_path = "C:/Users/Nikola/Documents/PROJEKAT_ML/ML_number_recognition_SVM/y_bin.txt";
   Deskew DUT
     (
      .clk(clk),
      .reset(reset),
      .start(dskw_start),
      .done_interrupt(dskw_done_interrupt),
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
      fd_img = ($fopen(file_path, "r"));
      if(fd_img)begin
         $display("opened successfuly");
         while(!$feof(fd_img))begin
            if(i == 783) begin
               $fscanf(fd_img ,"%b\n",img);
               queue.push_back(img);
               k1++;
               i = 0;             
            end  
            else begin
               $fscanf(fd_img ,"%b",img);
               queue.push_back(img);
               i++;
            end
            
         end
         $display("num of images in queue  is:  %d", k1);

      end
      else
        $display("Error opening file");
      $fclose(fd_img);
      fd_img = ($fopen("C:/Users/Nikola/Documents/PROJEKAT_ML/ML_number_recognition_SVM/python_deskewed_bin.txt", "r"));

      //GOLDEN VECTORS for comparison
      i = 0;
      
      if(fd_img)begin
         $display("opened successfuly");
         
         while(!$feof(fd_img))begin
            
            if(i == 783) begin
               $fscanf(fd_img ,"%b\n",img);
               golden_vectors.push_back(img);
               k2++;
               i = 0;             
            end  
            else begin
               $fscanf(fd_img ,"%b",img);
               golden_vectors.push_back(img);
               //$display("%d: ,%b", i, golden_vectors[i]);
               i++;
            end
            
            
         end
         $display("num of images in golden vectors queue is:  %d", k2);
      end
      else
        $display("Error opening file");
      $fclose(fd_img);
      assert (k1 == k2) else $error("length of golden vectors and number of images doesnt match");
      k2 = 0;
   end // initial begin

   // Sending data into DUT
   initial begin
  `ifdef ONE_IMG 
      reset = 0;
      dskw_start = 0;
      #200ns reset = 1;
      bram_en = 1;
      bram_we = 1;      
      for(int i = 0; i<784; i++)begin
         #100ns bram_address = i;
         bram_in_data = queue[i];
      end
      #100ns;
      bram_en = 0;
      bram_we = 0;
      dskw_start = 1;
      #150ns dskw_start = 0;
      wait (dskw_ready == 1);
      bram_en = 1;
      #200ns;
      fd_img_2 = ($fopen("C:/Users/Nikola/Documents/PROJEKAT_ML/ML_number_recognition_SVM/number_dskw.txt", "w"));
      if(fd_img)begin
         $display("file opened");
         for(int i = 0; i<784; i++) begin
            #200ns bram_address = 784 + i;
            #200ns golden_vector = golden_vectors[i]+16'h4000 - bram_out_data;
            golden_vector2 = golden_vectors[i];
            assert (golden_vector > 16'b0011100110011010 && golden_vector < 16'b0100011001100110) //assert(izraz>0.999 or izraz<1.001)
            else k2++;
            
            //$display("bram out data: %b \t golden_vector: %b",bram_out_data, golden_vectors[i]);
            $fwrite(fd_img,"%b\n",bram_out_data);  
         end
         $display("number of assertions is: %d", k2);      
      end
      else
        $display("error opening file");
      $fclose(fd_img_2);
      $display("END OF SIMULATION");
      $display("number of assertions is: %d", k2);
      $finish; 
     `endif
     
      `ifdef MULTIPLE_IMG
      reset = 0;
      dskw_start = 0;
      #200ns reset = 1;
      $display("%d", k1);   
      for(int j = 0; j<k1; j++)begin
         bram_en = 1;
         bram_we = 1;      
         for(int i = 0; i<784; i++)begin
            #100ns bram_address = i;
            bram_in_data = queue[j*784 + i];
         end
         #100ns;
         bram_en = 0;
         bram_we = 0;
         dskw_start = 1;
         #150ns dskw_start = 0;
         wait (dskw_ready == 1);
         bram_en = 1;
         #200ns;
         for(int i = 0; i<784; i++) begin
            bram_address = 784 + i;
            #200ns ;
            golden_vector = golden_vectors[784 * j + i]+16'h4000 - bram_out_data;
            golden_vector2 = golden_vectors[784 * j + i];
            assert (golden_vector > 16'b0011100110011010 && golden_vector < 16'b0100011001100110) //assert(izraz>0.89 or izraz<1.11)
            else begin
            k2++;
            k3++;
            end
            golden_vector =  bram_out_data;
            //$display("bram out data: %b \t golden_vector: %b",bram_out_data, golden_vectors[i]);            
         end
         $display("number of assertions is: %d", k2);
         k2 = 0;
         bram_en = 0;
         #200ns;      
      end // for (int j = 0; j<k1; j++)
      $display("END OF SIMULATION");
      $display("total number of assertions is: %d", k3);
      $finish; 
       
      `endif
          
   end   

   
   
   always
		#50ns clk <= ~clk;
     
   
   
endmodule
