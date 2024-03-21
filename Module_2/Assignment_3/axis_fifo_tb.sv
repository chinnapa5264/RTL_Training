`timescale 1ns / 1ps


module axis_fifo_tb;
 // Parameters
  localparam  DataWidth = 32;
  localparam  Depth = 2048;
  localparam PtrWidth = $clog2(Depth);

  //Ports
  logic  clk;
  logic  rst;
  logic [DataWidth-1   :0] s_axis_tdata='d0;
   logic [DataWidth-1   :0] s_axis_tdata_reg;
  logic  s_axis_tvalid=0;
  logic  s_axis_tlast=0;
  logic  s_axis_tready;
  logic [DataWidth-1   :0] m_axis_tdata;
  logic  m_axis_tvalid;
  logic  m_axis_tlast;
  logic  m_axis_tready=0;
  logic full,empty;

  axis_fifo # (
              .DataWidth(DataWidth),
              .Depth(Depth),
              .PtrWidth(PtrWidth)
            )
            axis_fifo_inst (
              .clk(clk),
              .rst(rst),
              .s_axis_tdata(s_axis_tdata),
              .s_axis_tvalid(s_axis_tvalid),
              .s_axis_tlast(s_axis_tlast),
              .s_axis_tready(s_axis_tready),
              .m_axis_tdata(m_axis_tdata),
              .m_axis_tvalid(m_axis_tvalid),
              .m_axis_tlast(m_axis_tlast),
              .m_axis_tready(m_axis_tready),
              .full(full),
              .empty(empty)
            );


  always #5  clk = ! clk ;

  initial
  begin
    clk=1;
    rst=1;
    reset;
    #20
     fork
       begin

         axis_data_signal(2050);
       end
   
     join

     #10 
     axis_read_signal;

     $stop();

  end
   initial begin
     #3000
     m_axis_tready=1;
     #30480
      m_axis_tready=0;
     end 

  integer file1,file2,file3;

task automatic reset;
    begin
    repeat (3) @(posedge clk);
      rst = ~rst;
    end
  endtask

  task automatic axis_data_signal(input [12:0] n);
    file1 = $fopen("data_input_with_last_2048.csv", "r");
    repeat (n)
    begin
      if (file1 == 0)
      begin
        $stop("Error in Opening file !!");
      end
      else
      begin
        @(posedge clk);
        $fscanf(file1,"%d,%b",s_axis_tdata,s_axis_tlast);
        s_axis_tvalid<=1;
        $display("%d,%d\n",s_axis_tdata,s_axis_tlast);
      end
    end
    s_axis_tvalid<=0;
    $fclose(file1);
  endtask

 task automatic axis_read_signal;
  file3 = $fopen("output_data.csv", "r");
  file2 = $fopen("output_tb_pass.csv", "w");
   begin
          if (file3 == 0) begin
              $stop("Error in Opening file !!");
          end
          else if (file2 == 0) begin
            $stop("Error in Opening file !!");
        end
          else begin
          while (m_axis_tvalid) begin
          @(posedge clk);
          $fscanf(file3,"%d",s_axis_tdata_reg);
          if (m_axis_tdata==s_axis_tdata_reg)
          $fdisplay(file2,"pass, %d",m_axis_tdata);
          else $fdisplay(file2,"fail, %d",m_axis_tdata);
          end
          end
          
    end

  $fclose(file3);
  $fclose(file2);
  endtask

 
endmodule


/* // Parameters
  localparam  DataWidth = 32;
  localparam  Depth = 16;
  localparam PtrWidth= $clog2(Depth);

  //Ports
  logic  clk;
  logic  reset;
  logic [DataWidth-1   :0] s_axis_tdata='d0;
  logic  s_axis_tvalid=0;
  logic  s_axis_tlast=0;
  logic  s_axis_tready;
  logic [DataWidth-1   :0] m_axis_tdata;
  logic  m_axis_tvalid;
  logic  m_axis_tlast;
  logic  m_axis_tready=0;
  logic full,empty;
 

  axis_fifo # (
              .DataWidth(DataWidth),
              .Depth(Depth),
              .PtrWidth(PtrWidth)
            )
            axis_fifo_inst (
              .clk(clk),
              .rst(reset),
              .s_axis_tdata(s_axis_tdata),
              .s_axis_tvalid(s_axis_tvalid),
              .s_axis_tlast(s_axis_tlast),
              .s_axis_tready(s_axis_tready),
              .m_axis_tdata(m_axis_tdata),
              .m_axis_tvalid(m_axis_tvalid),
              .m_axis_tlast(m_axis_tlast),
              .m_axis_tready(m_axis_tready),
              .full(full),
              .empty(empty)
            );


  always #5  clk = ! clk ;

  initial
  begin
    clk=1;
    reset=1;
    reset_signal;
     fork
       begin
         axi_data_signal(80049);
        end  
         begin
         axi_last_signal(80050);     
       end
    
     join

  end



task automatic reset_signal;
    begin
    repeat (3) @(posedge clk);
      reset = ~reset;
    end
  endtask

  task automatic axi_data_signal(input [12:0] n);
  begin
  integer count = 0;
    repeat (n)
    begin
       @(posedge clk); 
                if (!s_axis_tready) begin 
                s_axis_tvalid <= 0;
                s_axis_tdata<=0;
                s_axis_tlast <= 0;
                end
                else begin
                s_axis_tvalid <= 1;
                s_axis_tdata <= s_axis_tdata+1;
         
                end
        end
       end
         
  
  endtask
  
 task automatic axi_last_signal;
    input integer j;
    begin
     
        repeat (j) begin
        integer count=0;
            @(posedge clk);
               count=count+1;
                if (s_axis_tdata==Depth-1 ) begin
                    s_axis_tlast <= 1;
                end else begin
                    s_axis_tlast <= 0;
                end
            end
   
        s_axis_tlast <= 0; // Make sure to clear s_axis_tlast at the end
    end
endtask

initial begin
@(posedge clk);
m_axis_tready =0;
#5000
@(posedge clk);
m_axis_tready =1;
end
*/


