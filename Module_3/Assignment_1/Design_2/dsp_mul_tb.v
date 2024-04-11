`timescale 1ns / 1ps

module dsp_mult_tb;

    // Parameters
    parameter WIDTH = 16;
    
    // Signals
    reg clk;
    reg rst;
    reg [WIDTH-1:0] input_a_tdata=0;
    reg input_a_tvalid=0;
    wire input_a_tready;
    reg [WIDTH-1:0] input_b_tdata=0;
    reg input_b_tvalid=0;
    wire input_b_tready;
    reg [WIDTH-1:0] input_c_tdata=0;
    reg input_c_tvalid=0;
    wire input_c_tready;
    wire [(WIDTH*2)-1:0] output_tdata;
    wire output_tvalid;
    reg output_tready=1;

    // Instantiate the unit under test (UUT)
    dsp_mult #(
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .input_a_tdata(input_a_tdata),
        .input_a_tvalid(input_a_tvalid),
        .input_a_tready(input_a_tready),
        .input_b_tdata(input_b_tdata),
        .input_b_tvalid(input_b_tvalid),
        .input_b_tready(input_b_tready),
        .input_c_tdata(input_c_tdata),
        .input_c_tvalid(input_c_tvalid),
        .input_c_tready(input_c_tready),
        .output_tdata(output_tdata),
        .output_tvalid(output_tvalid),
        .output_tready(output_tready)
    );

always #5  clk = ! clk ;

integer file1;
    // Clock generation
    initial begin
        clk = 1;
        rst = 1;
        reset;
        fork 
        begin
        axis_data_signal;
        end
        join
        
    end

    task automatic reset;
    begin
    repeat (3) @(posedge clk);
      rst = ~rst;
    end
  endtask

   task automatic axis_data_signal;
   begin
   file1 = $fopen("data_input.csv","r");
   repeat(10)
   begin
   if(file1==0)
   begin
   $stop("Error in Opening file !!");
   end
    else
      begin
        @(negedge clk);
        $fscanf(file1,"%d,%d,%d",input_a_tdata,input_b_tdata,input_c_tdata);
        input_a_tvalid<=1;
        input_b_tvalid<=1;
        input_c_tvalid<=1;
        
        $display("%d,%d,%d\n",input_a_tdata,input_b_tdata,input_c_tdata);
      end
    end
    @(negedge clk)
     input_a_tvalid<=0;
     input_b_tvalid<=0;
     input_c_tvalid<=0;
     input_a_tdata<=0;
     input_b_tdata<=0;
     input_c_tdata<=0;
     $fclose(file1);
    end
   endtask
  endmodule
 
