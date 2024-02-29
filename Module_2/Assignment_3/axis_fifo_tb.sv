`timescale 1ns / 1ps


module tb_fifo_top;

  // Parameters
  localparam CLK_PERIOD = 10; // Clock period in time units
  localparam DATA_WIDTH = 32;
  localparam DEPTH = 4096;

  // Signals
  logic clk = 0;
  logic reset = 1;
  logic [DATA_WIDTH-1:0] writeData;
  logic writeDataValid;
  logic writeDataReady;
  logic writeDataLast;
  logic [DATA_WIDTH-1:0] readData;
  logic readDataValid;
  logic readDataReady;
  logic readDataLast;
  logic full;
  logic empty;

  // Instantiate DUT
  fifo_top dut (
    .clk(clk),
    .reset(reset),
    .writeData(writeData),
    .writeDataValid(writeDataValid),
    .writeDataReady(writeDataReady),
    .writeDataLast(writeDataLast),
    .readData(readData),
    .readDataValid(readDataValid),
    .readDataReady(readDataReady),
    .readDataLast(readDataLast),
    .full(full),
    .empty(empty)
  );
  // Clock generation
  always #((CLK_PERIOD)/2) clk = ~clk;

  // Testbench stimulus
  initial begin
    // Reset
    reset = 1;
    #100;
    reset = 0;

    // Write data
    writeDataValid = 1;
    repeat (10) begin
      #20;
      writeData = $random;
      writeDataLast = 0;
      #10;
    end
    writeDataLast = 1;
    writeDataValid = 0;

    // Read data
    repeat (10) begin
      #20;
      readDataReady = 1;
      //#10;
     // readDataReady = 0;
    end

    // End simulation
    #100;
    $finish;
  end

endmodule

module fifo_2048_tb;

  // Parameters
  localparam CLK_PERIOD = 10; // Clock period in time units
  localparam DATA_WIDTH = 32;
  localparam DEPTH = 2048;

  // Signals
  logic clk = 0;
  logic reset = 1;
  
  logic [DATA_WIDTH-1:0] writeData;
  logic writeDataValid;
  logic writeDataReady;
  logic writeDataLast;
  
  logic [DATA_WIDTH-1:0] readData;
  logic readDataValid;
  logic readDataReady;
  logic readDataLast;
  
  // Instantiate FIFO
  fifo_2048 #(
    .DataWidth(DATA_WIDTH),
    .Depth(DEPTH)
  ) dut (
    .clk(clk),
    .reset(reset),
    .writeData(writeData),
    .writeDataValid(writeDataValid),
    .writeDataReady(writeDataReady),
    .writeDataLast(writeDataLast),
    .readData(readData),
    .readDataValid(readDataValid),
    .readDataReady(readDataReady),
    .readDataLast(readDataLast),
    .full(full),
    .empty(empty)
  );

  // Clock generation
  always #((CLK_PERIOD)/2) clk = ~clk;

  // Testbench stimulus
  initial begin
    // Reset
    reset = 1;
    #100;
    reset = 0;

    // Write data
    writeDataValid = 1;
    repeat (10) begin
      #20;
      writeData = $random;
      writeDataLast = 0;
      #10;
    end
    writeDataLast = 1;
    writeDataValid = 0;

    // Read data
    repeat (10) begin
      #20;
      readDataReady = 1;
      //#10;
     // readDataReady = 0;
    end

    // End simulation
    #100;
    $finish;
  end

endmodule
