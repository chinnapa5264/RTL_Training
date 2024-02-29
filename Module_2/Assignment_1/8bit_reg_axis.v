`timescale 1ns / 1ps

module eight_bit_register_st (
    input wire clk,
    input wire reset,
    
    input wire [7:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,
    input wire s_axis_tlast,
    
    output wire [7:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,
    output wire m_axis_tlast
);

    reg [7:0] reg_data;
    reg valid_out;
    reg out_tlast;
    
     wire ready;
     wire enable;
     wire t_last;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_data <= 8'b0;
        end else begin
            if (m_axis_tready && valid_out) begin
                reg_data <= s_axis_tdata;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_out <= 1'b0;
        end else begin
            valid_out <= s_axis_tvalid ? 1'b1 : (m_axis_tready && valid_out);
        end
    end

  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      out_tlast <= 0;
    end
      else if (enable == 1)
      begin
        out_tlast <= t_last;
      end
   end

    assign ready = (valid_out == 0) | ((m_axis_tready == 1) & (valid_out == 1));
    assign enable = ((ready == 1) & (s_axis_tvalid == 1));

    assign t_last = (s_axis_tlast==1);

    assign s_axis_tready = ~valid_out || m_axis_tready;
    assign m_axis_tdata = reg_data;
    assign m_axis_tvalid = valid_out;
    assign m_axis_tlast = out_tlast;

endmodule

