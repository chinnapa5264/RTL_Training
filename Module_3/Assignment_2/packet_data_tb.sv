`timescale 1ns / 1ps

module packet_data_tb;

  // Parameters
  localparam  Data_width = 8;
  localparam  Depth = 64;


  //Ports
  logic  clk=1;
  logic  rst=1;
  logic [Data_width-1   :0] s_axis_tdata='d0,s_axis_tdata_i;
  logic  s_axis_tvalid=0;
  logic  s_axis_tlast=0;
  logic  s_axis_tready;
  logic [Data_width-1   :0] m_axis_tdata;
  logic  m_axis_tvalid;
  logic  m_axis_tlast;
  logic  m_axis_tready=0;
//  logic full,empty;

  logic [Data_width-1:0] len=64;
  logic [Data_width-1:0] k=30;
  logic [Data_width+Data_width-1:0] packet_config={k,len};

  packet_data # (
              .Data_width(Data_width),
              .Depth(Depth)
            )
            packet_add_dut1 (
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
              .packet_config(packet_config)
            );
 
  always #5  clk = ! clk ;

  initial
  begin
  fork 
  begin
    reset;

    axis_write(257);
 
     end
     begin

     axis_read(257);
    // m_tready=0;
      $stop();
     end
     join


  end
 reg [10:0] counter;
  integer file,file2,file3;

  task automatic reset;
  begin
   repeat (3) @(negedge clk);
      rst = ~rst;
    end
  endtask

  task automatic axis_write(input [10:0] n);
    file = $fopen("input_dat.csv", "r");
    repeat (n)
    begin
      if (file == 0)
      begin
        $stop("Error in Opening file !!");
      end
      else
      begin
        @(negedge clk);
        $fscanf(file,"%d,%d",s_axis_tdata,s_axis_tlast);
        
        s_axis_tvalid<=1;
      //  $display("%d,%b",s_tdata,s_tlast);
      end
    end
    s_axis_tvalid<=0;
    $fclose(file);
  endtask

  task automatic axis_read(input [10:0] n);
  file3 = $fopen("out_ref.csv", "r");
  file2 = $fopen("output.csv", "w");

    begin
          if (file3 == 0) begin
              $stop("Error in Opening file !!");
          end
          else if (file2 == 0) begin
            $stop("Error in Opening file !!");
        end
          else begin
          m_axis_tready=1;
          wait(m_axis_tvalid);
          while (m_axis_tvalid) begin
          counter=0;
          @(negedge clk);
          counter<=counter+1;
          $fscanf(file3,"%d",s_axis_tdata_i);
          if (m_axis_tdata==s_axis_tdata_i)
          $fdisplay(file2,"pass,%d",m_axis_tdata);
          else $fdisplay(file2,"fail,%d",m_axis_tdata);
          if (counter==n-2) begin
           m_axis_tready=0;
           counter=0;
           end
          end
          
          end
          
    end

  $fclose(file3);
  $fclose(file2);
  endtask

endmodule




