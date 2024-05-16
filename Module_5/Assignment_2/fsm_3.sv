`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2024 15:22:38
// Design Name: 
// Module Name: fsm_3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fsm_3 #(
    parameter DW_IN  = 16,
    parameter DW_OUT = 16,
    parameter DW_USER = 8
  )
  (
    input                   clock,
    input                   reset_n,

     //packet config
    input  [DW_IN-1:0] config_in_tdata,
    input               config_in_tvalid,
    output reg          config_out_tready,

    input  [DW_IN-1:0] data_in_tdata,
    input  [DW_USER-1:0] data_in_tuser,
    input               data_in_tlast,
    input               data_in_tvalid,
    output reg data_in_tready,
   
    // output interface
    output reg [DW_OUT-1:0] data_out_tdata,
    output reg [DW_USER-1:0] data_out_tuser,
    output reg data_out_tlast,
    output reg data_out_tvalid,
    input  data_out_tready
  );
  // local parameters
  enum reg [2:0] {
         CONFIG_DATA,
         RD_WR_DATA,
         MERGE,
         FILTER,
         FLUSH,
         SEND_LAST0_SAMPLE
       } state,next;

  // variables to register the inputs
  reg [DW_IN-1:0] data_in_tdata_reg;
  reg [DW_USER-1:0] data_in_tuser_reg;
  reg                  data_in_tlast_reg;
  reg                  data_in_tvalid_reg;
  reg                  data_out_tready_reg;
  
   reg [ DW_IN -1:0] config_in_tdata_reg;
  reg [DW_USER-1:0] config_in_tuser_reg;
  reg                  config_in_tvalid_reg;
  reg                  config_out_tready_reg;
  // temporary storage registers
  reg [DW_OUT - 1:0] rem_bits,mem_1;
  reg [DW_USER - 1:0  ] rem_user=0;
   reg [DW_USER - 1:0  ] count_user=0;
    reg [DW_USER - 1:0  ] count=0;
  reg last;

  reg [DW_OUT-1:0] data_out_tdata_1d;
  reg [DW_USER-1:0] data_out_tuser_1d;

 
  // REGISTERING THE INPUT PORTS
  always_ff @(posedge clock)
  begin:REGISTERING_INPUT
    if(!reset_n)
    begin
      data_in_tdata_reg  <= 'd0;
      data_in_tuser_reg  <= 'd0;
      data_in_tvalid_reg <= 'd0;
      data_in_tlast_reg  <= 'd0;
    end
    else
    begin
      if(data_in_tready==1 && data_in_tvalid==1)
      begin
        data_in_tdata_reg <= data_in_tdata;
        data_in_tuser_reg <= data_in_tuser;
        data_in_tlast_reg <= data_in_tlast;
      end
      else if(config_out_tready==1 && config_in_tvalid==1)
        begin
          config_in_tdata_reg <= config_in_tdata;
        end
      else
      begin
        config_in_tdata_reg <=config_in_tdata_reg;
        data_in_tdata_reg <= data_in_tdata_reg;
        data_in_tuser_reg <= data_in_tuser_reg;
        data_in_tlast_reg <= data_in_tlast_reg;
      end
      data_in_tvalid_reg  <= data_in_tvalid;
      data_out_tready_reg <= data_out_tready;
      config_in_tvalid_reg  <= config_in_tvalid;
      config_out_tready_reg <= config_out_tready;
    end
  end
  // NEXT STATE SEQUENTIAL BLOCK
  always_ff @(posedge clock)
  begin:NEXT_STATE_SEQ
    if(!reset_n)
    begin
      state <= CONFIG_DATA;
    end
    else
    begin
      state <= next;
    end
  end
  // NEXT STATE DECODER
  always_comb
  begin : NEXT_STATE_DECODER
    // next = RD_WR_DATA;
    case(state)
       CONFIG_DATA :
      begin
        if(config_out_tready&&config_in_tvalid)
          begin
            next = RD_WR_DATA;
          end
        else
          begin
            next = CONFIG_DATA;
          end
        
        
      end
          RD_WR_DATA :
      begin
      
        if(data_out_tready&&data_in_tvalid)
          begin
            next = MERGE;
          end
        else
          begin
            next = RD_WR_DATA;
          end
        
        
      end
    
     MERGE :
      begin
     
        if((count_user<=(config_in_tdata-DW_OUT))&&!data_in_tlast)
          begin
           
            next = MERGE ;
          end
          else if((count_user>(config_in_tdata-DW_OUT))&&!data_in_tlast)
           begin
            next = FILTER;
          end
           else if((count_user==(config_in_tdata))&&data_in_tlast)
           begin
            next = SEND_LAST0_SAMPLE;
          end
        else
          begin
            next =SEND_LAST0_SAMPLE;
          end
        
        
      end
      FILTER :
      begin
  
        if(data_out_tready&&data_in_tvalid)
          begin
            next =FLUSH;
          end
        else
          begin
            next = FILTER;
          end
      
      end
       FLUSH :
      begin
  
        if(data_out_tready&&data_in_tvalid)
          begin
            next =MERGE;
          end
        else
          begin
            next = FILTER;
          end
      
      end
      // sending the last sample with data_out_tlast asserted
      SEND_LAST0_SAMPLE :
      begin
        if(data_out_tready == 1)
        begin
          next = RD_WR_DATA;
        end
        else
        begin
          next = SEND_LAST0_SAMPLE;
        end
      end

      default :
      begin
        next = RD_WR_DATA;
      end
    endcase
  end
  // STATE DEFINITIONS
  always_ff @(posedge clock)
  begin : STATE_DEFINITION
    case(state)
    
     CONFIG_DATA :
      begin
        if(config_out_tready && config_in_tvalid)
        begin
            config_in_tdata_reg <= config_in_tdata;      
        end
        else
        begin
          config_in_tdata_reg <=config_in_tdata_reg ;
        end
      end
      RD_WR_DATA :
      begin
              count_user<=count_user+data_in_tuser;  
        if(data_in_tready && data_in_tvalid)
          begin
            data_out_tdata_1d <= data_in_tdata;
           data_out_tuser_1d <= data_in_tuser;  
           last<=0; 
          
          end
          else
          begin
             data_out_tdata_1d <= 0;
           data_out_tuser_1d <= 0;
        last<=0;
          
          end
      end
      /* In this state,input data will be merged with already stored bits in the buffer and will be
       sent out only when the requred number of valid bits(DW_OUT) are available
      */
      MERGE :
      begin
       
        if(count_user <(config_in_tdata-DW_OUT))
        begin
        
            data_out_tdata_1d <= data_in_tdata;
           data_out_tuser_1d <= data_in_tuser;
          count_user<=count_user+data_in_tuser; 
          last<=0;
           
          end
        else if(count_user >(config_in_tdata-DW_OUT))
        begin
        
            data_out_tdata_1d <= data_in_tdata;
           data_out_tuser_1d <=config_in_tdata-count_user ;
          count_user<=count_user+data_in_tuser; 
          last<=1;
           
          end
           else if(count_user ==(config_in_tdata-DW_OUT))
        begin
        
            data_out_tdata_1d <= data_in_tdata_reg;
           data_out_tuser_1d <=data_in_tuser ;
          count_user<=count_user+data_in_tuser; 
          last<=1;
           
          end
          
          else
          begin
             data_out_tdata_1d <= 0;
           data_out_tuser_1d <= 0;
         last<=0;   
           count_user<=0;
          
          end
      
        end
        
      
       FILTER :
      begin
       //count_user=8;
          if(count_user>(config_in_tdata))
          begin
            data_out_tdata_1d <= data_in_tdata_reg>>8;
           data_out_tuser_1d <= 8;
           count_user<=8;
           last<=0;      
          end
          else
          begin
             data_out_tdata_1d <= 0;
           data_out_tuser_1d <= 0;
     count_user<=0;
        last<=0;    
          
          end
      end

          FLUSH :
      begin
      if(count_user <(config_in_tdata))
          begin
            data_out_tdata_1d <= data_in_tdata_reg;
           data_out_tuser_1d <= data_in_tuser;
           count_user<= count_user+data_in_tuser;
         last<=0;      
          end
          else
          begin
             data_out_tdata_1d <= 0;
           data_out_tuser_1d <= 0;
            count_user<=0;
          last<=0;    
          
          end
      end


      SEND_LAST0_SAMPLE :
      begin
        if(data_out_tready==1)
        begin
          data_out_tdata_1d <= data_in_tdata;
           data_out_tuser_1d <=data_in_tuser;
            count_user<= data_in_tuser;
          last<= data_in_tlast;  
        end
        else
        begin
           data_out_tdata_1d <= 0;
           data_out_tuser_1d <= 0;
           count_user<=0;
         last<=0;   
        end
      end

      default :
      begin
     data_out_tdata_1d <= 0;
           data_out_tuser_1d <= 0;
      end
    endcase
  end

  // output decoder
  always_comb
  begin : OUTPUT_DECODER
		data_out_tdata = 'd0;
	  data_out_tuser = 'd0;
	  data_out_tvalid = 'd0;
	  data_out_tlast = 'd0;
      case(state)
        RD_WR_DATA :
        begin
      
              if(count_user>=0)
              begin
                data_out_tdata = data_out_tdata_1d;
                data_out_tuser = data_out_tuser_1d;
                data_out_tvalid = data_in_tvalid;
                data_out_tlast = data_in_tlast;
              end
              else
              begin
                data_out_tdata = data_out_tdata_1d;
                data_out_tuser = data_out_tuser_1d;
                data_out_tvalid = 0;
                data_out_tlast = data_in_tlast;
              end
            end
		

        MERGE :
        begin
          if(count_user >0&&!data_out_tlast)
          begin
            data_out_tdata =  data_out_tdata_1d;
            data_out_tuser = data_out_tuser_1d;
            data_out_tlast = last;
            data_out_tvalid = data_in_tvalid;
          end
     
          else
          begin
            data_out_tvalid = 0;
          end
        end
        FILTER :
        begin
          if(count_user>0)
          begin
            data_out_tdata =  data_out_tdata_1d;
            data_out_tuser = data_out_tuser_1d;
            data_out_tlast = last;
            data_out_tvalid =data_in_tvalid;
          end
          else
          begin
            data_out_tvalid = 0;
          end
        end
         FLUSH :
        begin
          if(count_user >= 0)
          begin
            data_out_tdata =  data_out_tdata_1d;
            data_out_tuser = data_out_tuser_1d;
            data_out_tlast = last;
            data_out_tvalid = data_in_tvalid;
          end
          else
          begin
            data_out_tvalid = 0;
          end
        end
        // sending the last sample
        SEND_LAST0_SAMPLE :
        begin
        if(data_in_tready)
          begin
         data_out_tdata =  data_out_tdata_1d;
            data_out_tuser = data_out_tuser_1d;
            data_out_tlast = 1;
            data_out_tvalid = data_in_tvalid;
            end
        end
      
		  /*
        default :
        begin
          data_out_tdata = 'd0;
          data_out_tuser = 'd0;
          data_out_tvalid = 0;
          data_out_tlast = 0;
        end
		  */
      endcase
  end
  always_comb
  begin
      
      data_in_tready = (state==RD_WR_DATA||state==FLUSH||state==FILTER || state==MERGE|| state==SEND_LAST0_SAMPLE) && (data_out_tready==1) ?  1 : 0 ;
  end
endmodule
