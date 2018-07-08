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
   logic                clk_s=0;
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
   logic                [WIDTH-1:0] bdata_b2s_s;
   logic                [WIDTH-1:0] bdata_s2b_s;
   logic                [9:0] baddr_s;
   logic                en_s;
   logic                we_s;
   //bram interface signals 2
   logic                [WIDTH-1:0] bdata_b2s_s2;
   logic                [WIDTH-1:0] bdata_s2b_s2;
   logic                [9:0] baddr_s2;
   logic                en_s2;
   logic                we_s2;
   
   string y_dir = "C:/\Users/\Djordje/\ML_number_recognition_SVM/\bin_data/\y";
   string b_dir = "C:/\Users/\Djordje/\ML_number_recognition_SVM/\bin_data/\b";
   string lt_dir = "C:/\Users/\Djordje/\ML_number_recognition_SVM/\bin_data/\lt";
   string sv_dir = "C:/\Users/\Djordje/\ML_number_recognition_SVM/\bin_data/\sv";

   logic[15 : 0] yQ[$];
   logic[15 : 0] bQ[10];
   logic[15 : 0] ltQ[10][$];
   logic[15 : 0] svQ[10][$];

   logic[15 : 0] tmp;
   int i=0;
   int num=0;
   int fd=0;
   string s="";

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
      .bdata_in(bdata_b2s_s),
      .bdata_out(bdata_s2b_s),
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
      .pi_dia(bdata_s2b_s),
      .pi_dib(bdata_s2b_s2),
      .po_doa(bdata_b2s_s),
      .po_dob(bdata_b2s_s2)
   );
   //CLK DRIVER                                                       *****
   always
		#50ns clk_s <= ~clk_s;

   //RESET MODULE + INCAPACITATE SECOND 'B' BRAM PORT INTERFACE      *****
   initial 
   begin
      bdata_s2b_s2=16'b0;
      baddr_s2=10'b0;
      en_s2=0;
      we_s2=0;
      reset_s=1;
      start_s=1;
      #300ns reset_s=1;
   end


   //EXTRACTING DATA FROM FILES                                       *****
   initial 
   begin

      //EXTRACTING TEST IMAGE [y]
      fd = ($fopen({y_dir,"/\y_bin.txt"}, "r"));
      if(fd)
      begin
         $display("y_bin opened successfuly");
         while(!$feof(fd))
         begin
            if(i == 783) 
            begin
               $fscanf(fd ,"%b\n",tmp);
               yQ.push_back(tmp);
               num++;
               i = 0;             
            end  
            else 
            begin
               $fscanf(fd ,"%b",tmp);
               yQ.push_back(tmp);
               i++;
            end
            
         end
         $display("Num of images in queue is: %d",num);
      end
      else
        $display("Error opening y_bin file");
        num=0;
      $fclose(fd);

      //EXTRACTING SUPPORT VECTORS [sv]
      for (int x=0; x<10; x++)
      begin
         s.itoa(x);
         fd = ($fopen({sv_dir,"/\sv_bin",s,".txt"}, "r"));
         if(fd)
         begin
            $display("sv_bin%d opened successfuly",x);
            while(!$feof(fd))
            begin
               if(i == 783) 
               begin
                  $fscanf(fd ,"%b\n",tmp);
                  svQ[x].push_back(tmp);
                  num++;
                  i = 0;             
               end  
               else 
               begin
                  $fscanf(fd ,"%b",tmp);
                  svQ[x].push_back(tmp);
                  i++;
               end
               
            end
            $display("Num of support vectors for core %d in queue is: %d",x,num);
         end
         else
           $display("Error opening %d. sv_bin file",x);
           num=0;
         $fclose(fd);
      end
      
      
      
      //EXTRACTING LAMBDAS [lt] 
      for (int x=0; x<10; x++)
      begin
         s.itoa(x);
         fd = ($fopen({lt_dir,"/\lt_bin",s,".txt"}, "r"));
         if(fd)
         begin
            $display("lt_bin%d opened successfuly",x);
            while(!$feof(fd))
            begin
                  $fscanf(fd ,"%b\n",tmp);
                  ltQ[x].push_back(tmp);
                  num++;
               
            end
            $display("Num of lambdas for core %d in queue is: %d",x,num);

         end
         
         else
           $display("Error opening %d. lt_bin file",x);
           num=0;
         $fclose(fd);
      end


      //EXTRACTING BIASES [b]
      for (int x=0; x<10; x++)
      begin
         s.itoa(x);
         fd = ($fopen({b_dir,"/\b_bin",s,".txt"}, "r"));
         if(fd)
         begin
            $display("b_bin%d opened successfuly",x);
            while(!$feof(fd))
            begin
                  $fscanf(fd ,"%b\n",tmp);
                  bQ[x]=tmp;
            end
         end
         else
           $display("Error opening %d. b_bin file",x);
           num=0;
         $fclose(fd);
      end

   end // initial begin

endmodule
