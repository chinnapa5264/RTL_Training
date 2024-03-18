`timescale 1ns/1ps

module tb_axis_register;

  // Parameters
  parameter  Data_Width = 8;

  //Ports
  reg  clk;
  reg  reset;
  reg [Data_Width-1   :0] s_axis_tdata;
  reg  s_axis_tvalid;
  reg  s_axis_tlast;
  wire  s_axis_tready;
  wire [Data_Width-1   :0] m_axis_tdata;
  wire  m_axis_tvalid;
  wire  m_axis_tlast;
  reg  m_axis_tready;

  eight_bit_register # (
            .Data_Width(Data_Width)
          )
          axi_reg_inst (
            .clk(clk),
            .reset(reset),
            . s_axis_tdata( s_axis_tdata),
            .s_axis_tvalid(s_axis_tvalid),
            .s_axis_tlast(s_axis_tlast),
            .s_axis_tready(s_axis_tready),
            .m_axis_tdata(m_axis_tdata),
            .m_axis_tvalid(m_axis_tvalid),
            .m_axis_tlast(m_axis_tlast),
            .m_axis_tready(m_axis_tready)
          );

  always #5  clk = ~ clk ;


  
  initial
  begin
 
    clk=0;
    reset=1;
    s_axis_tdata=0;
    s_axis_tvalid=0;
    s_axis_tlast=0;
    m_axis_tready=0;
    reset_signal_task();
    fork
 
      axi_ready_signal(50);
    //     #200
        axi_data_signal(20);
    axi_last_signal(22);
   
    join
      fork
      axi_ready_signal(10);
    //#200
        axi_data_signal(10);
    axi_last_signal(12);
    join
end

  task automatic reset_signal_task;
    begin
    repeat (2) @(posedge clk);
      reset = ~reset;
    end
  endtask
 task automatic axi_last_signal;
     input integer n;
        begin
        repeat (n) begin
            @(posedge clk); 
                if (s_axis_tdata==21) begin 
                 s_axis_tlast <= 1;
                end
                else begin    
                s_axis_tlast <= 0;
                end
            end
        end
    endtask
  
  task automatic axi_data_signal;
     input integer k;
        begin
        repeat (k) begin
            @(posedge clk); 
                if (!s_axis_tready) begin 
                s_axis_tvalid <= 0;
                s_axis_tdata<=s_axis_tdata;
                end
                else begin
                s_axis_tvalid <= 1;
                s_axis_tdata <= 3+s_axis_tdata;
                end
               
            end
            @(posedge clk);
            s_axis_tvalid <=0;
            s_axis_tdata <=0;
         //  s_axis_tlast <= 1;
        end
    endtask
  
 task automatic axi_ready_signal;
 input integer j;
        begin
    
            repeat (j) @(posedge clk) begin
               m_axis_tready <= 1; 
            end
          @(posedge clk) begin
               m_axis_tready <= 0; 
            end
        end
    endtask
        
endmodule