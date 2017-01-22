`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:58:15 12/30/2016 
// Design Name: 
// Module Name:    mouse 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Mouse(
	input wire clk,
	input wire [14:0] addr,
	output wire [11:0] data
   );
	mouse R(.clka(clk),.addra(addr),.douta(data));
 
endmodule
