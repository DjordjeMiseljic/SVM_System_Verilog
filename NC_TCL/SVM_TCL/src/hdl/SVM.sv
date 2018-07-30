`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Team Kole
// Engineer: Djordje 'Miske Debug' Miseljic
// 
// Create Date: 07/05/2018 10:46:17 PM
// Design Name: 
// Module Name: SVM
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


module SVM#
(
   parameter WIDTH = 16
)
(
   //clock, reset
   input logic                clk,
   input logic                reset,
   //status registers
   input logic                start,
   output logic               ready,
   output logic               interrupt,
   output logic               [3:0] cl_num,
   output logic               [3:0] state,
   //stream interface
   input logic                [WIDTH-1:0] sdata,
   input logic                svalid,
   output logic               sready,
   //bram interface
   input logic                [WIDTH-1:0] bdata_in,
   output logic               [WIDTH-1:0] bdata_out,
   output logic               [9:0] baddr,
   output logic               en,
   output logic               we
);

   // REGISTERS 
   // RES - res_t [6,10]
   logic [15 : 0]	res_reg,res_next;	
   	
   // NUM - num_t [4,0]
   logic [3 : 0]	num_reg,num_next;
   		
   // ACC - acc_t [14,14]
   logic [27 : 0]	acc_reg,acc_next;
   		
   // P - p_t [14,14]
   logic [27 : 0]	p_reg,p_next;	
   	
   // I and SV - max 784
   logic [9 : 0]	i_reg,i_next, sv_reg,sv_next;	
   	
   // CORE - max 10
   logic [3 : 0]	core_reg,core_next;
   
   // SDATA - [2,14]
   logic [15 : 0]	sdata_reg,sdata_next;		
   
   // FSM states
   typedef enum	logic[3:0]{idle, intr0, y, c, s, i0, i1, i2, l, intr1, b, intr2} states;
   states 	state_reg, state_next;

   // ADDITIONAL SIGNALS
   logic [31 : 0]	i1_tmp;		
   logic [31 : 0]	i2_tmp;		
   logic [84 : 0]	i2_tmp1;		
   logic [44 : 0]	l_tmp;		
   

   // NUM OF SUPPORT VECTORS
   localparam bit[9:0] sv_array[0:9] = {10'd361, 10'd267, 10'd581, 10'd632, 10'd480, 10'd513, 10'd376, 10'd432, 10'd751, 10'd683};
   localparam bit[9:0] IMG_LEN = 10'd784; 

   // SEQUENTIAL LOGIC
   always_ff @(posedge clk) begin
      if(!reset)
      begin
         res_reg <= 0;
         num_reg <= 0;
         acc_reg <= 0;
         p_reg <= 0;
         sv_reg <= 0;
         i_reg <= 0;
         core_reg <= 0;
         sdata_reg <= 0;
         state_reg <= idle;
      end
      else
      begin
         res_reg <= res_next;
         num_reg <= num_next;
         acc_reg <= acc_next;
         p_reg <= p_next;
         sv_reg <= sv_next;
         i_reg <= i_next;
         core_reg <= core_next;
         state_reg <= state_next;
         sdata_reg <= sdata_next;
      end // if (reset == 1)
   end // always @ (posedge clk)


   // COMBINATORIAL LOGIC
   always@(*) begin
      res_next = res_reg;
      num_next = num_reg;
      acc_next = acc_reg;
      p_next = p_reg;
      sv_next = sv_reg;
      i_next = i_reg;
      core_next = core_reg;
      state_next = state_reg;
      sdata_next = sdata_reg;
      baddr = 11'b0;
      bdata_out = 16'b0;
      en = 0;
      we = 0;
      ready = 0;
      sready = 0;
      interrupt = 0;

      case (state_reg)

         // IDLE state
         idle:
         begin
            res_next = 0;
            acc_next = 0;
            p_next = 0;
            sv_next = 0;
            i_next = 0;
            core_next = 0;
            sdata_next = 0;
            ready = 1;
            if(start == 1)
               state_next  = intr0;
            else
               state_next = idle;
         end  	  

         // INTR0 state
         intr0:
         begin
            interrupt = 1;
            i_next = 0;
            state_next = y;
         end

         // Y state
         y:
         begin
            sready=1'b1;
            if(svalid==1'b1)
            begin
               baddr=i_reg;
               bdata_out=sdata;
               en=1'b1;
               we=1'b1;
               i_next++;
               if(i_next==IMG_LEN)
               begin
                  core_next=0;
                  state_next=c;
               end
               else
                  state_next=y;
            end
            else
               state_next=y;
         end

         // C state
         c:
         begin
            acc_next=0;
            sv_next=0;
            state_next=s;
         end

         // S state
         s:
         begin
            p_next=28'h0004000;
            i_next=0;
            interrupt=1;
            state_next=i0;
         end

         // I0 state
         i0:
         begin
            sready=1'b1;
            if(svalid==1'b1)
            begin
               baddr=i_reg;
               en=1;
               we=0;
               sdata_next=sdata;
               state_next=i1;
            end
            else
               state_next=i0;
         end

         // I1 state
         i1:
         begin
            i1_tmp=(bdata_in*sdata_reg);
            p_next=p_reg+i1_tmp[29:14];
            i_next++;
            if(i_next==IMG_LEN)
               state_next=i2;
            else
               state_next=i0; 
         end

         // I2 state
         i2:
         begin
            i2_tmp=p_reg/10;
            i2_tmp1=i2_tmp*i2_tmp*i2_tmp;
            p_next=i2_tmp1[55:28];
            interrupt=1;
            state_next=l;
         end

         // L state
         l:
         begin
            sready=1'b1;
            if(svalid==1'b1)
            begin
               l_tmp=$signed(p_reg)*$signed(sdata);
               p_next=l_tmp[41:14];
               acc_next=$signed(acc_reg)+$signed(p_next);
               sv_next++;
               if(sv_next==sv_array[core_reg])
                  state_next=intr1;
               else
                  state_next=s;
            end
            else
               state_next=l;
         end

         // INTR1 state
         intr1:
         begin
            interrupt=1;
            state_next=b;
         end

         // B state
         b:
         begin
            sready=1'b1;
            if(svalid==1'b1)
            begin
               acc_next=$signed(acc_reg)+$signed(sdata);
               if(core_reg==0)
               begin
                  res_next=acc_next[19:4];
                  num_next=0;
               end
               else
               begin
                  if($signed(acc_next)>$signed(res_reg))
                  begin
                     res_next=acc_next[19:4]; 
                     num_next=core_reg;
                  end
               end
               core_next++;
               if(core_next==10)
                  state_next=intr2;
               else
                  state_next=c;
            end
            else
               state_next=b;
         end

         // INTR2 state
         intr2:
         begin
            interrupt=1;
            state_next=idle;
         end

         // DEFAULT state
         default:
         begin
            state_next=idle;
         end
      endcase
   end
      assign cl_num = num_reg;
      assign state = state_reg;
endmodule
