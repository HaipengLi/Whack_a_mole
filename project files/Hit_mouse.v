`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:45:39 01/01/2017 
// Design Name: 
// Module Name:    Hit_mouse 
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
module Hit_mouse(
	input wire clk,
	input wire [14:0] addr,
	output wire [11:0] data
   );
	hit_mouse R(.clka(clk),.addra(addr),.douta(data));
 
endmodule
