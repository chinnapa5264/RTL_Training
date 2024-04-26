`timescale 1ns / 1ns



module FPadder 
#(parameter  WI1 = 5,             // integer part bitwidth for integer 1  
             WF1 = 14,          // fractional part bitwidth for integer 1
             WI2 = 5,             // integer part bitwidth for integer 2
             WF2 = 14,          // fractional part bitwidth for integer 2
             WIO = 6,            // integer part bitwidth for addition output (user input)
             WFO = 14 ,           // integer part bitwidth for addition outout (user input)
             bigger_int = ((WI1>=WI2))?WI1:WI2,// bigger integer part among the two numbers is taken
             bigger_Frac = ((WF1>=WF2))?WF1:WF2 // bigger integer part among the two numbers is taken  
            )
   (
    input signed [WI1+WF1-1 : 0] A,             //input A
    input signed [WI2+WF2-1 : 0] B,             //input B
    output overflow,                            // overflow flag        
    output signed  [WIO+WFO-1 : 0] out          // addition output
    );

wire   [bigger_int+bigger_Frac: 0] tempout;    // output without truncation 


reg sign;  
reg    [(WI1+WF1-1):WF1] A_I;                               // integer part of A
reg    [(WF1-1):0] A_F;                                     // Fractional part of A
reg    [(WI2+WF2-1):WF2] B_I;                               // integer part of B                        
reg    [(WF2-1):0] B_F;                                     // Fractional part of A 
reg    [(bigger_int+bigger_Frac-1):bigger_Frac] tempA_I;  // bitwidth adjusted integer part of A   
reg    [(bigger_Frac-1):0] tempA_F;                       // bitwidth adjusted fractional part of A                       
reg    [(bigger_int+bigger_Frac-1):bigger_Frac] tempB_I;  // bitwidth adjusted integer part of B                               
reg    [(bigger_Frac-1):0] tempB_F;                       // bitwidth adjusted integer part of B 
reg   [bigger_int+bigger_Frac-1 : 0] tempA;               // bitwidth adjusted input A
reg   [bigger_int+bigger_Frac-1 : 0] tempB;               // bitwidth adjusted input B
reg    [WIO-1 : 0] outI;                                  //truncated output integer bits 
reg    [WFO-1 : 0] outF;                                  //truncated output fraction bits

//----------------separating Integer Parts and Fractional parts of numbers----------------------------//  
always @* begin
  A_I = A[(WI1+WF1-1):WF1];
  A_F = A[(WF1-1):0];
  B_I = B[(WI2+WF2-1):WF2];
  B_F = B[(WF2-1):0];
end

//---------------------------Sign extension for integer part-----------------------------------------// 
always @* begin
  if (WI1 > WI2) begin                                  
    tempB_I = {{(WI1-WI2){B_I[WI2+WF2-1]}},B_I};
    tempA_I = A_I;
  end
  else begin
    tempA_I = {{(WI2-WI1){A_I[WI1+WF1-1]}},A_I};
    tempB_I = B_I;
  end
end

//-----------------------------Zero padding for fractional part---------------------------------------//  
always @* begin
  if (WF1 > WF2) begin
    tempB_F = {B_F,{(WF1-WF2){1'b0}}};
    tempA_F = A_F;
  end
  else begin
    tempA_F = {A_F,{(WF2-WF1){1'b0}}};
    tempB_F = B_F;
  end
 end  
 
//--------------------------------------------Addition------------------------------------------------//
 always @* begin
 tempA = {tempA_I,tempA_F};
 tempB = {tempB_I,tempB_F};
 end
assign tempout = $signed(tempA) + $signed(tempB);


always @ * begin
if ((tempA[bigger_int+bigger_Frac-1]&& tempB[bigger_int+bigger_Frac-1]))
 sign = 1;
else if((!tempA[bigger_int+bigger_Frac-1]== tempB[bigger_int+bigger_Frac-1]||tempA[bigger_int+bigger_Frac-1]==! tempB[bigger_int+bigger_Frac-1]))
sign = tempout[bigger_int+bigger_Frac-1]; 
else 
 sign=0;
end



//------------------------------------------truncation-------------------------------------------------//
//---------------------------------adjusting bitwidth of fractional part-------------------------------//
always @* begin
  if (WFO >= bigger_Frac)begin
    outF = {tempout[bigger_Frac-1:0],{(WFO-bigger_Frac){1'b0}}};
  end
  else begin
    outF = tempout[(bigger_Frac-1):(bigger_Frac-WFO)];
  end
end
//---------------------adjusting bitwidth of Integer part and check if overflow occurs-----------------//
// If overflow occurs indicate by making overflow flag = 1
             
assign overflow = (bigger_int>=WIO)?tempout[bigger_int+bigger_Frac]? (~&tempout[bigger_int+bigger_Frac: bigger_Frac+WIO-1] == tempout[bigger_int+bigger_Frac ]):(|tempout[bigger_int+bigger_Frac-1:bigger_Frac+WIO-1]):0;


always @* begin
  if (WIO >= (bigger_int)+1)begin
    outI = {{(WIO-bigger_int){sign}},tempout[bigger_int+bigger_Frac-1:bigger_Frac]};
  end
  else begin
    if (WIO == 1)begin
      outI = sign;
    end  
    else begin
      outI = {sign,tempout[WIO+WFO-2:WFO]};
  end
end
end

assign out ={outI,outF};




endmodule

