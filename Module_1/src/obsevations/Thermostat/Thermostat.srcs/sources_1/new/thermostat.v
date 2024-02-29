`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2024 15:03:38
// Design Name: 
// Module Name: thermostat
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


module thermostat(
input too_cold,
input too_hot,
input mode,
input fan_on,
output heater,
output aircon,
output fan

    );
    assign heater = mode && too_cold;
    assign aircon = (~mode)&& too_hot;
    assign fan = aircon || heater || fan_on;
endmodule
