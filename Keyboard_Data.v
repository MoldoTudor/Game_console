`timescale 1ns / 1ps



module Keyboard_Data(
    input clk,
    input rst,
    input key_data,
    input key_clk,
    output  reg [7:0]keyboard,
    output reg valid,
    output [7:0] keyboard_mem1);
    
    initial begin
    valid=0;
    keyboard=0;
    end
    

    reg [1:0] state;
    reg [3:0] count;
    reg [10:0] keyboard_mem=0;
    reg [10:0] keyboard_mem_next=0;
    reg [3:0] count_next;
    reg [4:0] count_release;
    reg stop=0;
    reg [2:0] ps2_clk=3'b111;
    reg done;
    reg valid_next=0 ;
    
    localparam idle = 2'b00;
    localparam dps = 2'b01;
    localparam load = 2'b10;

      wire falling;
      reg [1:0] state_next=0;
      reg [26:0] timer;
      reg clk1=1;
      reg timer_en;
      
      assign keyboard_mem1 = keyboard_mem[8:1] ;
      
      always@(posedge clk) begin
      ps2_clk<={ps2_clk[1:0] , key_clk} ;
      end
      
      assign falling = ( ps2_clk[2:1] == 2'b10 ) ? 1'b1 : 1'b0 ;
      
      always@(posedge clk)
      if(rst) begin
      state <= idle;
      keyboard_mem <= 0 ;
      count <=0;
      valid<=0;
      end 
      else begin
      state <= state_next;
      keyboard_mem <= keyboard_mem_next ;
      count <=count_next;
      valid<=valid_next;
      end
      
 

   
   always@(posedge clk) begin
   case(state_next)
    idle: begin   
                done<=0;
                if(falling) begin 
                state_next <=dps ;
                keyboard_mem_next<={key_data , keyboard_mem_next[10:1]}; 
                count_next<= 4'b1001;
                end
           end
    dps: begin  if(falling) begin
                keyboard_mem_next<={key_data , keyboard_mem_next[10:1]};
                if(count==0)
                state_next<=load;
                else
                count_next<=count_next-1;
                end                
         end
    load:begin 
                state_next<=idle;
                done<=1; 
                                
         end                     
   endcase 
   end

    
    always@(posedge clk) begin
    if((valid==1)&&(falling))    
    valid_next<=0;
    else begin
     if((keyboard_mem[8:1]==8'b11110000)&&(done)) begin
        stop<=1;
     end
     else 
        if((stop==1)&&(done)) begin
        stop<=0;
     end
     else if((done)) begin
            keyboard<=keyboard_mem[8:1];
            valid_next<=1;
            end
            end 
            end
endmodule
