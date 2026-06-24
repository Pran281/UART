`include "baud_gen.v"
`timescale 1ns / 1ps

module uart_core(
  input wire clk,
  input wire reset,
  input wire tx_start,
  input wire [7:0] tx_data,
  output reg tx,
  output tx_busy,
  input [31:0] baud_rate,
  input [31:0] freq,
  input wire rx,
  output reg [7:0] rx_data,
  output reg rx_done,
  output reg parity_error
);

  typedef enum logic [2:0] {IDLE, START, DATA, PARITY, STOP} state_t;
  state_t tx_state;
  state_t rx_state;
  
  assign tx_busy = (tx_state != IDLE);
  wire baud_tick;
 
  baud_gen bg(.*);
  
  // -- TX Signals --
  reg [7:0] tx_reg;
  reg [2:0] tx_bit;
  reg parity_bit;
  reg [3:0] tx_cnt; 

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      tx_state <= IDLE;
      tx <= 1;
      tx_bit <= 0;
      tx_cnt <= 0;
      tx_reg <= 8'b0;
    end else begin
      
      
      if(baud_tick && tx_state != IDLE) 
        tx_cnt <= tx_cnt + 1;

      case(tx_state)
        IDLE : begin
          tx <= 1;
          tx_cnt <= 0; 
          if(tx_start) begin
            tx_reg <= tx_data;
            parity_bit <= ~(^tx_data);
            tx_state <= START;
          end
        end
        
        START : begin
          tx <= 0;
          if(tx_cnt == 15 && baud_tick) begin
            tx_state <= DATA;
          end
        end
        
        DATA : begin
          tx <= tx_reg[tx_bit];
          if(tx_cnt == 15 && baud_tick) begin
            if(tx_bit == 3'd7) begin
              tx_bit <= 0;
              tx_state <= PARITY;
            end else begin
              tx_bit <= tx_bit + 1'b1;
            end
          end
        end
        
        PARITY: begin
          tx <= parity_bit;
          if(tx_cnt == 15 && baud_tick) begin
            tx_state <= STOP;
          end
        end
        
        STOP: begin
          tx <= 1;
          if(tx_cnt == 15 && baud_tick) begin
            tx_state <= IDLE;
          end
        end
      endcase
    end
  end
 
  // -- RX Signals --
  reg [7:0] rx_reg;
  reg [2:0] rx_bit;
  reg rx_parity;
  reg [3:0] rx_cnt;
  
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      rx_state <= IDLE;
      rx_done <= 0;
      parity_error <= 0;
      rx_reg <= 8'b0;
      rx_bit <= 0;
      rx_parity <= 0;
      rx_cnt <= 0;
    end else begin
      rx_done <= 0;
      
      if(baud_tick && rx_state != IDLE)
        rx_cnt <= rx_cnt + 1;
        
      case(rx_state)
        IDLE: begin
          rx_cnt <= 0;
          if(rx == 0)
            rx_state <= START;
        end
        
        START: begin
          
          if(rx_cnt == 7 && baud_tick) begin
            rx_state <= DATA;
            rx_cnt <= 0; 
          end
        end
        
        DATA: begin
          if(rx_cnt == 15 && baud_tick) begin
            rx_reg[rx_bit] <= rx; 
            if(rx_bit == 3'd7) begin
              rx_bit <= 0;
              rx_state <= PARITY;
            end else begin
              rx_bit <= rx_bit + 1'b1;
            end
          end
        end
        
        PARITY:  begin
          if(rx_cnt == 15 && baud_tick) begin
            rx_parity <= rx;
            rx_state <= STOP;
          end
        end
        
        STOP: begin
          if(rx_cnt == 15 && baud_tick) begin
            rx_data <= rx_reg;
            rx_done <= 1'b1; 
            parity_error <= ((~^rx_reg) != rx_parity);
            rx_state <= IDLE;
          end
        end
      endcase
    end
  end
endmodule
