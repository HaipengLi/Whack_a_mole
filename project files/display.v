`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:51:38 12/30/2016 
// Design Name: 
// Module Name:    display 
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
module display(
	input wire clk, 
	input wire [17:0] map,
	input wire clear_screen,
	output wire hs,
	output wire vs,
	output wire [3:0] r,
	output wire [3:0] g,
	output wire [3:0] b
    );
	 
	 wire [31:0] clk_signal;

	 wire vga_clk; //25M Hz
	 reg [11:0] vga_data;
	 wire [8:0] row_addr;
	 wire [9:0] col_addr;

	 wire [16:0] pic_addr;	 
	 wire [11:0] pic_out_mouse;
	 wire [11:0] pic_out_empty;
	 wire [11:0] pic_out_hit_empty;
	 wire [11:0] pic_out_hit_mouse;

	
	clkdiv c0(clk,1'b0,clk_signal);
	vgac v0 (.vga_clk(vga_clk), .clrn(clear_screen), .d_in(vga_data), .row_addr(row_addr), .col_addr(col_addr), .r(r), .g(g), .b(b), .hs(hs), .vs(vs));
	
	Mouse m0(vga_clk,pic_addr[14:0],pic_out_mouse);	
	Empty m1(vga_clk,pic_addr[14:0],pic_out_empty);
	Hit_mouse m2(vga_clk,pic_addr[14:0],pic_out_hit_mouse);
	Hit_empty m3(vga_clk,pic_addr[14:0],pic_out_hit_empty);
	
	assign pic_addr = (row_addr % 160)*160 + (col_addr-80) % 160 ;
	assign vga_clk = clk_signal[1];
	
	always@(posedge vga_clk) begin
		if(col_addr < 80 || col_addr > 560) begin 
			vga_data <= 12'hfff; //white
		end else begin 
			if(row_addr < 160 && col_addr < 240) begin
				if (map[1:0] == 2'b00) begin
					vga_data <= pic_out_empty;
				end else if (map[1:0] == 2'b01) begin
					vga_data <= pic_out_mouse;
				end else if (map[1:0] == 2'b11) begin
					vga_data <= pic_out_hit_empty;
				end else if (map[1:0] == 2'b10) begin
					vga_data <= pic_out_hit_mouse;
				end
			end else if (row_addr < 160 && col_addr < 400) begin
				if (map[3:2] == 2'b00) begin
					vga_data <= pic_out_empty;
				end else if (map[3:2] == 2'b01) begin
					vga_data <= pic_out_mouse;
				end else if (map[3:2] == 2'b11) begin
					vga_data <= pic_out_hit_empty;
				end else if (map[3:2] == 2'b10) begin
					vga_data <= pic_out_hit_mouse;
				end			
			end else if (row_addr < 160 && col_addr < 560) begin
				if (map[5:4] == 2'b00) begin
					vga_data <= pic_out_empty;
				end else if (map[5:4] == 2'b01) begin
					vga_data <= pic_out_mouse;
				end else if (map[5:4] == 2'b11) begin
					vga_data <= pic_out_hit_empty;
				end else if (map[5:4] == 2'b10) begin
					vga_data <= pic_out_hit_mouse;
				end			
			end else if (row_addr < 320 && col_addr < 240) begin
				if (map[7:6] == 2'b00) begin
					vga_data <= pic_out_empty;
				end else if (map[7:6] == 2'b01) begin
					vga_data <= pic_out_mouse;
				end else if (map[7:6] == 2'b11) begin
					vga_data <= pic_out_hit_empty;
				end else if (map[7:6] == 2'b10) begin
					vga_data <= pic_out_hit_mouse;
				end			
			end else if (row_addr < 320 && col_addr < 400) begin
				if (map[9:8] == 2'b00) begin
					vga_data <= pic_out_empty;
				end else if (map[9:8] == 2'b01) begin
					vga_data <= pic_out_mouse;
				end else if (map[9:8] == 2'b11) begin
					vga_data <= pic_out_hit_empty;
				end else if (map[9:8] == 2'b10) begin
					vga_data <= pic_out_hit_mouse;
				end			
			end else if (row_addr < 320 && col_addr < 560) begin
				if (map[11:10] == 2'b00) begin
					vga_data <= pic_out_empty;
				end else if (map[11:10] == 2'b01) begin
					vga_data <= pic_out_mouse;
				end else if (map[11:10] == 2'b11) begin
					vga_data <= pic_out_hit_empty;
				end else if (map[11:10] == 2'b10) begin
					vga_data <= pic_out_hit_mouse;
				end			
			end else if (row_addr < 480 && col_addr < 240) begin
				if (map[13:12] == 2'b00) begin
					vga_data <= pic_out_empty;
				end else if (map[13:12] == 2'b01) begin
					vga_data <= pic_out_mouse;
				end else if (map[13:12] == 2'b11) begin
					vga_data <= pic_out_hit_empty;
				end else if (map[13:12] == 2'b10) begin
					vga_data <= pic_out_hit_mouse;
				end			
			end else if (row_addr < 480 && col_addr < 400) begin
				if (map[15:14] == 2'b00) begin
					vga_data <= pic_out_empty;
				end else if (map[15:14] == 2'b01) begin
					vga_data <= pic_out_mouse;
				end else if (map[15:14] == 2'b11) begin
					vga_data <= pic_out_hit_empty;
				end else if (map[15:14] == 2'b10) begin
					vga_data <= pic_out_hit_mouse;
				end			
			end else if (row_addr < 480 && col_addr < 560) begin
				if (map[17:16] == 2'b00) begin
					vga_data <= pic_out_empty;
				end else if (map[17:16] == 2'b01) begin
					vga_data <= pic_out_mouse;
				end else if (map[17:16] == 2'b11) begin
					vga_data <= pic_out_hit_empty;
				end else if (map[17:16] == 2'b10) begin
					vga_data <= pic_out_hit_mouse;
				end			
			end
		end
	end
endmodule
