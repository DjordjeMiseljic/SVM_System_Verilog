`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nikola Kovacevic
// 
// Create Date: 06/14/2018 02:48:38 PM
// Design Name: Accelerator for number recognition using SVM algorithm
// Module Name: Deskew
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

module Deskew#
  (
   parameter WIDTH = 16
   )
   (
    //clock, reset
    input logic                clk,
    input logic                reset,
   
    //control signals IO
    input logic                start,
    output logic               ready,
    // 
    //Data transfer IO
    output logic [10:0]         address,
    input logic [WIDTH-1 : 0]  in_data,
    output logic [WIDTH-1 : 0] out_data,
    output logic               en,
    output logic               we
    );
   // REG and NEXT signals
    logic [4 : 0]         x_reg, y_reg, x_next, y_next;
   //registers needed to calculate image moments (fixed point)
    logic [WIDTH-1 + 12 : 0]    M_reg[3], M_next[3];
    //logic [WIDTH-1 + 40 : 0]    temp1_reg, temp1_next, temp2_reg, temp2_next;
    logic [WIDTH-1 + 26 : 0]    temp1,temp2;
   //logic [WIDTH-1 + 36 : 0]    mu02_next, mu02_reg;
    logic [WIDTH-1 + 26 : 0]    mu11_next, mu11_reg, mu02_next, mu02_reg; //61
   
   //registers needed to calculate DESKEW (fixed point)
   
    logic [WIDTH-1 + 26 : 0]    xp_reg, yp_reg, xp_next, yp_next;
    logic [WIDTH-1 + 26 : 0]    R2_reg, R2_next;

    logic [WIDTH-1 + 12 : 0]    x1_reg, x1_next, x2_reg, y2_reg, x2_next, y2_next;
   
  
   
   // ASMD states
   typedef enum                logic[4:0]{idle ,i1 ,i2, i2_1, i3, i4, i5, i5_1, i6, i7, i8, i8_1, i8_2, i8_3, i8_4, i8_5, i8_6} states;
   states state, state_next;
   const logic [25 : 0] one = {13'b0,1'b1,14'b0};
   
   //FSM STATES

   //VARIABLE REGISTER TRANSFER
   always_ff @(posedge clk) begin
      if(!reset)begin
         x_reg <= 0;
         y_reg <= 0;
         mu11_reg <= 0;
         mu02_reg <= 0;
         M_reg[0] <= 0;
         M_reg[1] <= 0;
         M_reg[2] <= 0;
         xp_reg <= 0;
         yp_reg <= 0;         
         R2_reg <= 0;
         x1_reg <= 0;
         x2_reg <= 0;
         y2_reg <= 0;
         
//         temp1_reg <= 0;
  //       temp2_reg <= 0;
         state <= idle;
      end
      else begin
         x_reg <= x_next;
         y_reg <= y_next;
         mu11_reg <= mu11_next;
         mu02_reg <= mu02_next;
         M_reg[0] <= M_next[0];
         M_reg[1] <= M_next[1];
         M_reg[2] <= M_next[2]; 
         xp_reg <= xp_next;
         yp_reg <= yp_next;         
         R2_reg <= R2_next;
         x1_reg <= x1_next;
         x2_reg <= x2_next;
         y2_reg <= y2_next;
         state <= state_next;
    //     temp1_reg <= temp1_next;
      //   temp2_reg <= temp2_next;
      end // if (reset == 1)
   end // always @ (posedge clk)
   //Combination circuit realising ASMD
   always@(*) begin
      x_next = x_reg;
      y_next = y_reg;
      mu11_next = mu11_reg;
      mu02_next = mu02_reg;
      M_next[0] = M_reg[0];
      M_next[1] = M_reg[1];
      M_next[2] = M_reg[2];
      xp_next = xp_reg;
      yp_next = yp_reg;
      R2_next = R2_reg;
      x1_next = x1_reg;
      x2_next = x2_reg;
      y2_next = y2_reg;
      state_next = state;
//      temp1_next = temp1_reg;
  //    temp2_next = temp2_reg;
      address = 11'b0;
      out_data = 16'b0;
      en = 0;
      we = 0;
      ready = 0;
      
      case (state)
        idle:begin
           ready = 1;
           if(start == 1)begin
              x_next = 0;
              y_next = 0;
              mu11_next = 0;
              mu02_next = 0;              
              M_next[0] = 0;
              M_next[1] = 0;
              M_next[2] = 0;
              xp_next = 0;
              yp_next = 0;
              R2_next = 0;
              x1_next = 0;
              x2_next = 0;
              y2_next = 0;
              state_next  = i1;
           end                    
           else begin
              state_next = idle;
           end    
        end // case: idle
        i1:begin
           y_next  = 0;
           state_next = i2;
        end
        i2:begin
           address = x_reg + y_reg*28;
           en = 1;
           state_next = i2_1;
        end
        i2_1:begin
           M_next[2] = in_data + M_reg[2];//m00
           M_next[0] = in_data * x_reg + M_reg[0];//m10
           M_next[1] = in_data * y_reg + M_reg[1];//m01
           y_next = y_reg + 1;
           if(y_next == 28)begin
              x_next = x_reg + 1;
              if(x_next == 28)
                state_next = i3;
              else
                state_next = i1;
           end
           else begin
              state_next = i2;                 
           end
        end // case: i2_1
        i3:begin
           M_next[0] = {M_reg[0], 14'b0} / M_reg[2] ;// x_mc_next = m10/m00
           M_next[1] = {M_reg[1], 14'b0} / M_reg[2];//  y_mc_next = m01/m00
           x_next = 0;
           state_next = i4;           
        end
        i4:begin
           y_next = 0;
           state_next = i5;
        end
        i5:begin
           address = x_reg + y_reg*28;
           en = 1;
           //temp1_next = (({y_reg[13:0],14'b0} - M_reg[1][27:0]) * ({y_reg[13:0],14'b0} - M_reg[1][27:0]));
           //temp2_next = (({x_reg[13:0],14'b0} - M_reg[0][27:0]) * ({y_reg[13:0],14'b0} - M_reg[1][27:0]));
           state_next = i5_1;              
        end
        i5_1:begin
           temp1 = ({y_reg,14'b0} - M_reg[1][27:0]) * ({y_reg,14'b0} - M_reg[1][27:0]);
           temp2 = (({x_reg,14'b0} - M_reg[0][27:0]) * ({y_reg,14'b0} - M_reg[1][27:0]));
           mu02_next = in_data * temp1[41:14] + (mu02_reg);
           mu11_next = $signed(in_data)*$signed(temp2[41:14]) + $signed(mu11_reg);
//           mu02_next = in_data * temp1_reg[41:14] + (mu02_reg);
//           mu11_next = $signed(in_data)*$signed(temp2_reg[41:14]) + $signed(mu11_reg);
           y_next = y_reg + 1;
           if(y_next == 28)begin
              x_next = x_reg + 1;
              if(x_next == 28)
                state_next = i6;
              else
                state_next = i4;
           end
           else begin
              state_next = i5;                 
           end
        end // case: i5_1
        
        i6:begin
           M_next[0] = ($signed({mu11_reg[41:14],14'b0})/$signed(mu02_reg[41:14]));
           temp1 = $signed({mu11_reg[41:14],14'b0})/$signed(mu02_reg[41:14]) * $signed({10'b0,4'b1110,14'b0});
           M_next[1] = -temp1[41:14];
           x_next = 0;    
           state_next = i7;          
        end
        i7:begin
           y_next = 0;
           state_next  = i8;              
        end
        i8:begin
           xp_next = $signed(one) * $signed({23'b0,x_reg,14'b0}) + $signed(M_reg[0]) * $signed({23'b0,y_reg,14'b0}) + $signed(M_reg[1])*$signed(one);
           yp_next = {23'b0, y_reg,28'b0};
           if(xp_next < {23'b0,5'b11011,28'b0} && yp_next <{23'b0,5'b11011,28'b0} && xp_next >= 0 && yp_next >=0)
             state_next = i8_1;
           else begin
              address = x_reg + y_reg*28 + 784;
              out_data = 0;
              en = 1;
              we = 1;
              state_next = i8_6;                 
           end
        end // case: i8
        i8_1:begin
           x1_next = {9'b0 ,xp_reg[32:28], 14'b0};
           x2_next = {9'b0 ,xp_reg[32:28], 14'b0} + one;
           y2_next = {9'b0 ,yp_reg[32:28], 14'b0} + one;
           state_next = i8_2;              
        end
        i8_2:begin
           address = x1_reg[18:14] + y2_reg[18:14] * 28 ;
           //M_next[2] = ($signed(xp_reg[41:14]) - $signed(x1_reg)); 
           en = 1;
           state_next = i8_3;              
        end
        i8_3:begin
           R2_next = ({26'b0, in_data,14'b0}) - (($signed(xp_reg[41:14]) - $signed(x1_reg)) * in_data);
           //assert ($signed(R2_next) >= 0)
           address = x2_reg[18:14] + y2_reg[18:14] * 28 ;
           en = 1;
           state_next = i8_4;
        end
        i8_4:begin
           
           R2_next = R2_reg + ($signed(xp_reg[41:14]) - $signed(x1_reg)) * in_data;
           state_next = i8_5;              
        end
        
        i8_5:begin
           address = 784 + x_reg + y_reg*28;   //probaj da izbacis        
           out_data = R2_reg[29:14];
           en = 1;
           we = 1;
           state_next = i8_6;           
        end

        i8_6:begin
           
           y_next = y_reg + 1;
           if(y_next == 28)begin
              x_next = x_reg + 1;
              if(x_next == 28)
                state_next = idle;
              else
                state_next = i7;
           end
           else begin
              state_next = i8;                 
           end
        end // case: i8_7
        default:begin
            //state_next = state;
        end        
      endcase // case (state)      
   end // always_comb
   
endmodule
