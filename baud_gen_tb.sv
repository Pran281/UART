`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2026 12:20:24 AM
// Design Name: 
// Module Name: baud_gen_tb
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


module baud_gen_tb;
logic clk,reset;
logic baud_tick;
logic [31:0] baud_rate;
logic [31:0] freq;
//logic [31:0] count;
//logic [31:0] baud_divisor;
 
 baud_gen dut (.*);
  //check if reset was toggled
  covergroup baud_gen_cg @(posedge clk);
  cp_reset: coverpoint reset{
  bins active = {1};
  bins inactive ={0};
  bins reset_toggle = (1 => 0);
  }
  
  //check if standard baud rates were tested
  cp_baud_rate: coverpoint baud_rate{
  bins br_9600 = {9600};
  bins br_11500 = {115200};
  }
  
  //check if baud_tick actually fired
  cp_tick: coverpoint baud_tick {
  bins tick_generated = (0 => 1);
  }
  endgroup
  
  baud_gen_cg cg;
  
 initial begin
 clk = 0;
 forever #10 clk = ~clk;
 end

initial begin
baud_gen_cg = new();
#10
 reset = 1;
 baud_rate = 9600;
 freq = 50000000;

 #20
 reset = 0;
 
 
 #1000000;
 
 baud_rate=115200;
 #5000; 
 
  $display("Total Functional coverage : %0.2f",cg.get_inst_coverage());
 $finish;
  end
 endmodule
 