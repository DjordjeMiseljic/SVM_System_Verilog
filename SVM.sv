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
   // ACC - acc_t [14,10]
   logic [27 : 0]	acc_reg,acc_next;		
   // P - p_t [14,12]
   logic [27 : 0]	p_reg,p_next;		
   // I and SV - max 784
   logic [9 : 0]	i_reg,i_next, sv_reg,sv_next;		
   // CORE - max 10
   logic [3 : 0]	core_reg,core_next;
   // SDATA - [2,14]
   logic [15 : 0]	sdata_reg,sdata_next;		
   
   // FSM states
   typedef enum	logic[3:0]{idle, intr0, y, c, s, i0, i1, i2, l, intr1, b, intr2} states;
   states 	state, state_next;

   // ADDITIONAL SIGNALS
   logic [27 : 0]	p_tmp;		

   // NUM OF SUPPORT VECTORS
   localparam bit[9:0] sv_array[0:9] = {10'd361, 10'd267, 10'd581, 10'd632, 10'd80, 10'd513, 10'd376, 10'd432, 10'd751, 10'd683};
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
         state <= idle;
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
         state <= state_next;
         sdata_reg <= sdata_next;
      end // if (reset == 1)
   end // always @ (posedge clk)


   // COMBINATORIAL LOGIC
   always@(*) begin
      sdata_next = sdata_reg;
      res_next = res_reg;
      num_next = num_reg;
      acc_next = acc_reg;
      p_next = p_reg;
      sv_next = sv_reg;
      i_next = i_reg;
      core_next = core_reg;
      state_next = state;
      baddr = 11'b0;
      bdata_out = 16'b0;
      cl_num = 4'b0;
      en = 0;
      we = 0;
      ready = 0;
      sready = 0;
      interrupt = 0;

      case (state)

         // IDLE state
         idle:
         begin
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
            p_next=1;
            i_next=0;
            interrupt=1;
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
            p_next=p_reg+(bdata_in*sdata_reg);
            i_next++;
            if(i_next==IMG_LEN)
               state_next=i2;
            else
               state_next=i0; 
         end

         // I2 state
         i2:
         begin
            p_tmp=p_reg/10;
            p_next=p_tmp*p_tmp*p_tmp;
            interrupt=1;
            state_next=l;
         end

         // L state
         l:
         begin
            sready=1'b1;
            if(svalid==1'b1)
            begin
               p_next=p_reg*sdata;
               acc_next=acc_reg+p_next;
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
               acc_next=acc_reg+sdata;
               if(core_reg==0)
               begin
                  res_next=acc_next;
                  num_next=0;
               end
               else
               begin
                  if(acc_next>res_reg)
                  begin
                     res_next=acc_next;
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
            cl_num=num_reg;
            state_next=idle;
         end

         // DEFAULT state
         default:
         begin
            state_next=idle;
         end
         
      endcase
   end
endmodule
