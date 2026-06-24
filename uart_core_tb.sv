module uart_core_tb;
  logic clk, reset;
  logic tx_start;
  logic [7:0] tx_data;
  logic tx;
  logic tx_busy;
  logic [31:0] baud_rate;
  logic [31:0] freq;
  logic rx;
  logic [7:0] rx_data;
  logic rx_done;
  logic parity_error;

  uart_core dut (.*);

  assign rx = tx;

  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
  
  initial begin
   reset = 1;
    tx_start = 0;
    tx_data = 8'b10111110;
    baud_rate=115200;
    freq=5000000;
    
    #100;
    reset = 0;
    
    #100;
    
    tx_start = 1;
    #20;
    tx_start = 0;
    
    wait(rx_done == 1);
    $display("Success Transmitted = %b | Recieved =%b",tx_data,rx_data);
    
    #500000;
    $finish;
  end
    initial begin
      $dumpfile("uart_core_tb.vcd");
      $dumpvars(0,uart_core_tb);
end
endmodule
