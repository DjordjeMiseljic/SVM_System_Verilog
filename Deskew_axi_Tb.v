`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2018 03:10:45 PM
// Design Name: 
// Module Name: Deskew_axi_Tb
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

module Deskew_axi_Tb #(
// Users to add parameters here
        
		// User parameters ends
		// Do not modify the parameters beyond this line
        parameter integer WIDTH	= 16,
        parameter integer ADDRESS	= 4,

		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
    
    );
     
     logic               done_interrupt;
     // Ports of Axi Slave Bus Interface S00_AXI
     logic  s00_axi_aclk = 0;
     logic  s00_axi_aresetn;
     logic [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr = 0;
     logic [2 : 0] s00_axi_awprot = 0;
     logic  s00_axi_awvalid = 0;
     logic  s00_axi_awready;
     logic [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata = 0;
     logic [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb = 0;
     logic  s00_axi_wvalid = 0;
     logic  s00_axi_wready;
     logic [1 : 0] s00_axi_bresp;
     logic  s00_axi_bvalid;
     logic  s00_axi_bready = 0;
     logic [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr = 0;
     logic [2 : 0] s00_axi_arprot = 0;
     logic  s00_axi_arvalid = 0;
     logic  s00_axi_arready;
     logic [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
     logic [1 : 0] s00_axi_rresp;
     logic  s00_axi_rvalid;
     logic  s00_axi_rready = 0;
    //signals for comunicating with BRAM 
    logic [12:0] axi_address = 0;
    logic [WIDTH-1 : 0] axi_in_data;
    logic [WIDTH-1 : 0] axi_out_data;
    logic               axi_en = 0;
    logic               axi_we = 0;
    //Signals to insert image into BRAM
    logic [12:0] bram_address;
    logic [WIDTH-1 : 0] bram_in_data;
    logic [WIDTH-1 : 0] bram_out_data;
    logic               bram_en;
    logic               bram_we;   
    //varibles needed for testbench
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
       
       
     //instantiation of modules   
    Deskew_axi_v1_0 #(.WIDTH(16),
                      .ADDRESS(ADDRESS))
                     Deskew_Axi(.s00_axi_aclk(s00_axi_aclk),
                    .s00_axi_aresetn(s00_axi_aresetn),
                    .s00_axi_awaddr(s00_axi_awaddr),
                    .s00_axi_awprot(s00_axi_awprot),
                    .s00_axi_awvalid(s00_axi_awvalid),
                    .s00_axi_awready(s00_axi_awready),
                    .s00_axi_wdata(s00_axi_wdata),
                    .s00_axi_wstrb(s00_axi_wstrb),
                    .s00_axi_wvalid(s00_axi_wvalid),
                    .s00_axi_wready(s00_axi_wready),
                    .s00_axi_bresp(s00_axi_bresp),
                    .s00_axi_bvalid(s00_axi_bvalid),
                    .s00_axi_bready(s00_axi_bready),
                    .s00_axi_araddr(s00_axi_araddr),
                    .s00_axi_arprot(s00_axi_arprot),
                    .s00_axi_arvalid(s00_axi_arvalid),
                    .s00_axi_arready(s00_axi_arready),
                    .s00_axi_rdata(s00_axi_rdata),
                    .s00_axi_rresp(s00_axi_rresp),
                    .s00_axi_rvalid(s00_axi_rvalid),
                    .s00_axi_rready(s00_axi_rready),
                    //user_logic
                    .address(axi_address),
                    .in_data(axi_in_data),
                    .out_data(axi_out_data),
                    .en(axi_en),
                    .we(axi_we),
                    .done_interrupt(done_interrupt)
                    );
     BRAM #(.WADDR(13))
          MEM
          (
           .pi_clka(s00_axi_aclk),
           .pi_clkb(s00_axi_aclk),
           .pi_ena(bram_en),
           .pi_enb(axi_en),
           .pi_wea(bram_we),
           .pi_web(axi_we),
           .pi_addra({bram_address}),
           .pi_addrb({axi_address}),
           .pi_dia(bram_in_data),
           .pi_dib(axi_out_data),
           .po_doa(bram_out_data),
           .po_dob(axi_in_data)
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
   
         //EXTRACTING GOLDEN VECTORS for comparison
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
      
      //driving the modules
    initial begin
        `ifdef ONE_IMG 
            s00_axi_aresetn = 0;
            //s00_axi_araddr = 1'b1;
            
            #200ns s00_axi_aresetn = 1;
            bram_en = 1;
            bram_we = 1;      
            for(int i = 0; i<784; i++)begin
               #200ns bram_address = i * 4;
               bram_in_data = queue[i];
            end
            #100ns;
            bram_en = 0;
            bram_we = 0;
            
            //reading status
            s00_axi_araddr = 3'h4;
            s00_axi_arvalid = 1;
            s00_axi_rready = 1;
            wait(s00_axi_arready);
            wait(s00_axi_rvalid);
            $display("ready is: %b", s00_axi_rdata[0]);
            s00_axi_arvalid = 0;
            s00_axi_rready = 0;
            #200ns
            //reading written cmd
            s00_axi_araddr = 1'b0;
            s00_axi_arvalid = 1;
            s00_axi_rready = 1;
            wait(s00_axi_arready);
            wait(s00_axi_rvalid);
            $display("start is: %b", s00_axi_rdata[0]);
            s00_axi_arvalid = 0;
            s00_axi_rready = 0;
            #200ns
            // start = 1
            s00_axi_awaddr = 0;
            s00_axi_awvalid = 1; 
            s00_axi_wdata = 1;
            s00_axi_wvalid = 1;
            wait(s00_axi_awready == 1);
            wait(s00_axi_wready == 1);
            $display("prosao1");
            s00_axi_bready = 1;
            wait(s00_axi_bvalid);
            $display("prosao2");
            
            s00_axi_awvalid = 0; 
            s00_axi_wdata = 0;
            s00_axi_wvalid = 0;
            #200ns s00_axi_bready = 0;
            //reading written cmd
            s00_axi_araddr = 1'b0;
            s00_axi_arvalid = 1;
            s00_axi_rready = 1;
            wait(s00_axi_arready);
            wait(s00_axi_rvalid);
            $display("start is: %b", s00_axi_rdata[0]);
            s00_axi_arvalid = 0;
            s00_axi_rready = 0;
            
           #200ns
            //start = 0
            s00_axi_awaddr = 0;
            s00_axi_awvalid = 1; 
            s00_axi_wdata = 0;
            s00_axi_wvalid = 1;
            wait(s00_axi_awready == 1);
            wait(s00_axi_wready == 1);
            $display("prosao3");
            s00_axi_bready = 1;
            wait(s00_axi_bvalid);
            #200ns s00_axi_bready = 0;
            
            s00_axi_wdata = 0;
            s00_axi_wvalid = 0;
            $display("prosao4");
            #200ns
            s00_axi_araddr = 3'h4;
            s00_axi_arvalid = 1;
            s00_axi_rready = 1;
            wait(s00_axi_arready);
            wait(s00_axi_rvalid);
            $display("ready is: %b", s00_axi_rdata[0]);
            s00_axi_arvalid = 0;
            s00_axi_rready = 0;
            #200ns
            wait(done_interrupt == 1);       
            bram_en = 1;
            #200ns;
            fd_img_2 = ($fopen("C:/Users/Nikola/Documents/PROJEKAT_ML/ML_number_recognition_SVM/number_dskw.txt", "w"));
            if(fd_img)begin
               $display("file opened");
               for(int i = 0; i<784; i++) begin
                  #200ns bram_address = 784 * 4 + i * 4;
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
            s00_axi_aresetn = 0;
            #200ns s00_axi_aresetn = 1;
            $display("%d", k1);   
            for(int j = 0; j<k1; j++)begin
               bram_en = 1;
                        bram_we = 1;      
                        for(int i = 0; i<784; i++)begin
                           #200ns bram_address = i * 4;
                           bram_in_data = queue[j*784 + i];
                        end
                        #100ns;
                        bram_en = 0;
                        bram_we = 0;
                        
                        //reading status
                        s00_axi_araddr = 3'h4;
                        s00_axi_arvalid = 1;
                        s00_axi_rready = 1;
                        wait(s00_axi_arready);
                        wait(s00_axi_rvalid);
                        $display("ready is: %b", s00_axi_rdata[0]);
                        s00_axi_arvalid = 0;
                        s00_axi_rready = 0;
                        #200ns
                        //reading written cmd
                        s00_axi_araddr = 1'b0;
                        s00_axi_arvalid = 1;
                        s00_axi_rready = 1;
                        wait(s00_axi_arready);
                        wait(s00_axi_rvalid);
                        $display("start is: %b", s00_axi_rdata[0]);
                        s00_axi_arvalid = 0;
                        s00_axi_rready = 0;
                        #200ns
                        // start = 1
                        s00_axi_awaddr = 0;
                        s00_axi_awvalid = 1; 
                        s00_axi_wdata = 1;
                        s00_axi_wvalid = 1;
                        wait(s00_axi_awready == 1);
                        wait(s00_axi_wready == 1);
                        $display("prosao1");
                        
                        s00_axi_bready = 1;
                       
                        wait(s00_axi_bvalid);
                        $display("prosao2");
                         s00_axi_awvalid = 0; 
                         s00_axi_wdata = 0;
                         s00_axi_wvalid = 0;
                        
                        #200ns s00_axi_bready = 0;
                        //reading written cmd
                        s00_axi_araddr = 1'b0;
                        s00_axi_arvalid = 1;
                        s00_axi_rready = 1;
                        wait(s00_axi_arready);
                        wait(s00_axi_rvalid);
                        $display("start is: %b", s00_axi_rdata[0]);
                        s00_axi_arvalid = 0;
                        s00_axi_rready = 0;
                        
                       #200ns
                        //start = 0
                        s00_axi_awaddr = 0;
                        s00_axi_awvalid = 1; 
                        s00_axi_wdata = 0;
                        s00_axi_wvalid = 1;
                        wait(s00_axi_awready == 1);
                        wait(s00_axi_wready == 1);
                        $display("prosao3");
                        s00_axi_bready = 1;
                        wait(s00_axi_bvalid);
                        
                        
                        s00_axi_wdata = 0;
                        s00_axi_wvalid = 0;
                        s00_axi_awvalid = 0;
                        #200ns s00_axi_bready = 0; 
                        $display("prosao4");
                        #200ns
                        s00_axi_araddr = 3'h4;
                        s00_axi_arvalid = 1;
                        s00_axi_rready = 1;
                        wait(s00_axi_arready);
                        wait(s00_axi_rvalid);
                        $display("ready is: %b", s00_axi_rdata[0]);
                        s00_axi_arvalid = 0;
                        s00_axi_rready = 0;
                        #200ns
                        wait(done_interrupt == 1);       
                        bram_en = 1;
                        #200ns;
               #200ns;
               for(int i = 0; i<784; i++) begin
                  bram_address = 784*4 + i*4;
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
        #50ns s00_axi_aclk <= ~ s00_axi_aclk;
                            
endmodule


