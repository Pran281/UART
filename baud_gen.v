`timescale 1ns / 1ps

module baud_gen(
input wire clk,
input wire reset,
output reg baud_tick,
input  [31:0] baud_rate,
input [31:0] freq
);
wire [31:0]baud_divisor;
reg [31:0]count;

assign baud_divisor = (baud_rate != 0) ? (freq/(baud_rate * 16)) : 1;
always @(posedge clk or posedge reset) begin
       if(reset) begin
         count <= 0;
          baud_tick <= 0;
       end else begin
         if(count >= baud_divisor - 1) begin
           count <= 0;
           baud_tick <= 1;
           end else begin
           count <= count+1;
           baud_tick <= 0;
           end
           end
           end
           endmodule
