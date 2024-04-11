`timescale 1ns / 1ps


module axi_stream_multiply_add_tb;

  // Parameters
  parameter DW = 8;
  
  // Inputs
  logic clk;
  logic rst;
  logic signed [DW-1:0] a=0, b=0, c=0, d=0;
  logic s_axis_valid_a=0, s_axis_valid_b=0, s_axis_valid_c=0, s_axis_valid_d=0;
  logic s_axis_ready_a, s_axis_ready_b, s_axis_ready_c, s_axis_ready_d;
  logic m_axis_ready=1;
  
  // Outputs
  logic signed [DW-1:0] m_axis_tdata;
  logic m_axis_valid;
  logic overflow;
  
  // Instantiate the DUT
  axi_stream_multiply_add #(.DW(DW)) dut (
    .clk(clk),
    .rst(rst),
    .a(a),
    .s_axis_valid_a(s_axis_valid_a),
    .s_axis_ready_a(s_axis_ready_a),
    .b(b),
    .s_axis_valid_b(s_axis_valid_b),
    .s_axis_ready_b(s_axis_ready_b),
    .c(c),
    .s_axis_valid_c(s_axis_valid_c),
    .s_axis_ready_c(s_axis_ready_c),
    .d(d),
    .s_axis_valid_d(s_axis_valid_d),
    .s_axis_ready_d(s_axis_ready_d),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_valid(m_axis_valid),
    .m_axis_ready(m_axis_ready),
    .overflow(overflow)
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
   repeat(9)
   begin
   if(file1==0)
   begin
   $stop("Error in Opening file !!");
   end
    else
      begin
        @(posedge clk);
        $fscanf(file1,"%d,%d,%d,%d",a,b,c,d);
        s_axis_valid_a<=1;
        s_axis_valid_b<=1;
        s_axis_valid_c<=1;
        s_axis_valid_d<=1;
        $display("%d,%d,%d,%d\n",a,b,c,d);
      end
    end
     @(posedge clk);
        s_axis_valid_a<=0;
        s_axis_valid_b<=0;
        s_axis_valid_c<=0;
        s_axis_valid_d<=0;
        a<=0;
        b<=0;
        c<=0;
        d<=0;
        
    $fclose(file1);
    end
   endtask
  endmodule

