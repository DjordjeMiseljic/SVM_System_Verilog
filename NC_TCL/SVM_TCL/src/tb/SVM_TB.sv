`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2018 04:10:08 PM
// Design Name: 
// Module Name: SVM_TB
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


module SVM_TB#
(
   parameter integer WIDTH                 = 16,
   parameter integer C_S_AXI_DATA_WIDTH	  = 32,
   parameter integer C_S_AXI_ADDR_WIDTH    = 4,
   parameter integer C_S_AXIS_TDATA_WIDTH  = 32  
)
();
   // PARAMETERS
   localparam bit[9:0] sv_array[0:9] = {10'd361, 10'd267, 10'd581, 10'd632, 10'd480, 10'd513, 10'd376, 10'd432, 10'd751, 10'd683};
   localparam bit[9:0] IMG_LEN = 10'd784; 

   // Ports of Axi Slave Bus Interface S_AXI
   logic  s_axi_aclk=0;
   logic  s_axi_aresetn=1;
   logic [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr=0;
   logic [2 : 0] s_axi_awprot;
   logic  s_axi_awvalid=0;
   logic  s_axi_awready=0;
   logic [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata=0;
   logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb;
   logic  s_axi_wvalid=0;
   logic  s_axi_wready=0;
   logic [1 : 0] s_axi_bresp=0;
   logic  s_axi_bvalid=0;
   logic  s_axi_bready=0;
   logic [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr=0;
   logic [2 : 0] s_axi_arprot;
   logic  s_axi_arvalid=0;
   logic  s_axi_arready=0;
   logic [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata=0;
   logic [1 : 0] s_axi_rresp=0;
   logic  s_axi_rvalid=0;
   logic  s_axi_rready=0;

   // Ports of Axi Slave Bus Interface S_AXIS
   logic  s_axis_aclk=0;
   logic  s_axis_aresetn=1;
   logic  s_axis_tready=0;
   logic [C_S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata=0;
   logic [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] s_axis_tstrb=4'b1111;
   logic  s_axis_tlast=0;
   logic  s_axis_tvalid=0;

   // INTERRUPT OUT
   logic interrupt;

   // TB VARIABLES

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

   int image=0;
   int core=0;
   int sv=0;

    
   SVM_IP_v1_0 #
   (
      .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
      .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
      .C_S_AXIS_TDATA_WIDTH(C_S_AXIS_TDATA_WIDTH),
      .WIDTH(WIDTH)                
   )
   SVM_IP_inst
   (
      .s_axi_aclk(s_axi_aclk),
      .s_axi_aresetn(s_axi_aresetn),
      .s_axi_awaddr(s_axi_awaddr),
      .s_axi_awprot(s_axi_awprot),
      .s_axi_awvalid(s_axi_awvalid),
      .s_axi_awready(s_axi_awready),
      .s_axi_wdata(s_axi_wdata),
      .s_axi_wstrb(s_axi_wstrb),
      .s_axi_wvalid(s_axi_wvalid),
      .s_axi_wready(s_axi_wready),
      .s_axi_bresp(s_axi_bresp),
      .s_axi_bvalid(s_axi_bvalid),
      .s_axi_bready(s_axi_bready),
      .s_axi_araddr(s_axi_araddr),
      .s_axi_arprot(s_axi_arprot),
      .s_axi_arvalid(s_axi_arvalid),
      .s_axi_arready(s_axi_arready),
      .s_axi_rdata(s_axi_rdata),
      .s_axi_rresp(s_axi_rresp),
      .s_axi_rvalid(s_axi_rvalid),
      .s_axi_rready(s_axi_rready),
      .s_axis_aclk(s_axis_aclk),
      .s_axis_aresetn(s_axis_aresetn),
      .s_axis_tready(s_axis_tready),
      .s_axis_tdata(s_axis_tdata),
      .s_axis_tstrb(s_axis_tstrb),
      .s_axis_tlast(s_axis_tlast),
      .s_axis_tvalid(s_axis_tvalid),
      .interrupt(interrupt)
   ); 
   


   // CLOCK DRIVERS
   always
		#50ns s_axi_aclk <= ~s_axi_aclk;
   always
		#50ns s_axis_aclk <= ~s_axis_aclk;

   //CLEAR QUEUES, EXTRACT DATA FROM FILES                                       *****
   initial 
   begin
   
      while(yQ.size()!=0)
      yQ.delete(0);
      
      for(int c=0; c<10; c++)
      begin
         bQ[c]=0;
         while(ltQ[c].size()!=0)
            ltQ[c].delete(0);
         while(ltQ[c].size()!=0)   
            svQ[c].delete(0);   
      end
      
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
   end 
    
   //RESET MODULE, START IT, SEND NECESSAIRY DATA TROUGH AXI STREAM *****
   initial 
   begin
      s_axi_aresetn=0;
      s_axis_aresetn=0;
      #300ns s_axi_aresetn=1;
      s_axis_aresetn=1;
      
      for(image=0; image<10; image++)
      begin
         
        // START=1
        s_axi_awaddr = 0;
        s_axi_awvalid = 1; 
        s_axi_wdata = 1;
        s_axi_wvalid = 1;
        s_axi_wstrb=4'b1111;
        wait(s_axi_awready == 1);
        wait(s_axi_wready == 1);
        $display("prosao1");
        s_axi_bready = 1;
        wait(s_axi_bvalid);
        $display("prosao2");
        s_axi_awvalid = 0; 
        s_axi_wstrb=4'b0000;
        s_axi_wdata = 0;
        s_axi_wvalid = 0;
        #200ns s_axi_bready = 0;
    
        //START=0
        s_axi_awaddr = 0;
        s_axi_awvalid = 1; 
        s_axi_wstrb=4'b1111;
        s_axi_wdata = 0;
        s_axi_wvalid = 1;
        wait(s_axi_awready == 1);
        wait(s_axi_wready == 1);
        $display("prosao3");
        s_axi_bready = 1;
        wait(s_axi_bvalid);
        #200ns s_axi_bready = 0;
        s_axi_wstrb=4'b0000;
        s_axi_wdata = 0;
        s_axi_wvalid = 0;
        
        
          //@(posedge interrupt);
          for(i=0; i<IMG_LEN; i++)
          begin
             s_axis_tstrb=4'b1111;
             s_axis_tdata=yQ[image*784+i];
             s_axis_tvalid=1;
             @(posedge s_axis_aclk iff s_axis_tready==1);
          end
          //$display("input image saved\n");
          s_axis_tvalid=0;
          s_axis_tstrb=4'b0000;
          for(core=0; core<10; core++)
          begin
          //$display("core num:%d \n",core);
             for(sv=0; sv<sv_array[core]; sv++)
             begin
    
                //$display("sv number: %d \n",sv);
                //send support vector
                @(posedge interrupt);
                for(i=0; i<IMG_LEN; i++)
                begin
                   s_axis_tstrb=4'b1111;
                   s_axis_tdata=svQ[core][sv*IMG_LEN + i];
                   s_axis_tvalid=1;
                   @(posedge s_axis_aclk iff s_axis_tready==1);
                end
                s_axis_tvalid=0;
                s_axis_tstrb=4'b0000;
    
                //send lambda(target)
                @(posedge interrupt);
                s_axis_tstrb=4'b1111;
                s_axis_tdata=ltQ[core][sv];
                s_axis_tvalid=1;
                @(posedge s_axis_aclk iff s_axis_tready==1);
                s_axis_tvalid=0;
                s_axis_tstrb=4'b0000;
             end
             //$display("sending bias \n");
             //send bias
             @(posedge interrupt);
          
             /*@(negedge s_axi_aclk);
             //reading state
             s_axi_araddr = 4'hC;
             s_axi_arvalid = 1;
             s_axi_rready = 1;
             wait(s_axi_arready);
             wait(s_axi_rvalid);
             $display("res is: %d", s_axi_rdata[3:0]);
             s_axi_arvalid = 0;
             s_axi_rready = 0;*/

             s_axis_tstrb=4'b1111;
             s_axis_tdata=bQ[core];
             s_axis_tvalid=1;
             @(posedge s_axis_aclk iff s_axis_tready==1);
             s_axis_tstrb=4'b0000;
             s_axis_tvalid=0;
          end
          @(posedge interrupt)
          #100ns;
          @(negedge s_axi_aclk);
          //reading result 
          s_axi_araddr = 4'h4;
          s_axi_arvalid = 1;
          s_axi_rready = 1;
          wait(s_axi_arready);
          wait(s_axi_rvalid);
          $display("ready is: %b", s_axi_rdata[0]);
          s_axi_arvalid = 0;
          s_axi_rready = 0;
          #200ns;
         
          @(negedge s_axi_aclk);
          //reading result 
          s_axi_araddr = 4'h8;
          s_axi_arvalid = 1;
          s_axi_rready = 1;
          wait(s_axi_arready);
          wait(s_axi_rvalid);
          $display("res is: %d", s_axi_rdata[3:0]);
          s_axi_arvalid = 0;
          s_axi_rready = 0;
          #200ns;
          /*
          @(negedge s_axi_aclk);
          //reading state
          s_axi_araddr = 4'hC;
          s_axi_arvalid = 1;
          s_axi_rready = 1;
          wait(s_axi_arready);
          wait(s_axi_rvalid);
          $display("res is: %d", s_axi_rdata[3:0]);
          s_axi_arvalid = 0;
          s_axi_rready = 0;
          #200ns;
          */
      end  
      $finish;
   end
   

    
endmodule
