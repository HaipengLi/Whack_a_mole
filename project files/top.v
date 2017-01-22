`timescale 1ns / 1ps

module top(
	input clk,
	input wire clear_screen,	//Switch to turn on or off the screen
	inout [3:0] KeyX,  // button array on SWORD
	inout [4:0] KeyY, //button array on SWORD
	output buzzer,

	output SEGLED_CLK,// 8 digit 7segment LED 
	output SEGLED_CLR,// 8 digit 7segment LED 
	output SEGLED_DO,// 8 digit 7segment LED 
	output SEGLED_PEN,// 8 digit 7segment LED 

	
	output LEDR0,//triLED Red color (Left one)
	output LEDG0,//triLED Green color(Left one)
	output LEDB0,//triLED Blue color(Left one)
    output LEDR1,////triLED Red color(Left one)
    output LEDG1,//triLED Green color(Left one)
    output LEDB1,//triLED Blue color(Left one)
	output wire HS,//horizontal scanner
	output wire VS,//vertical scanner
	output wire [3:0] R,//red colod number
	output wire [3:0] G,//green color number
	output wire [3:0] B//blue color number
    );
	reg [17:0]Map;//Used to store the states of each mole hole
	reg [17:0]Time1;//counter of appearance and disappearance of a mole
	reg [17:0]Time2;//counter of sound and visual effect
	reg [11:0]Score;//score
	reg[8:0] BTN;//set 1 when a valid button is pressed
	reg[8:0] BTN_successful;//set 1 when hit a mole
	reg[8:0] BTN_failed;//set 1 when hit a empty hole
	reg clk_1s;//clkdiv
	reg clk_50ms;//clkdiv
	reg clk_2s;//clkdiv
	reg [31:0]cnt_1s;
	reg [31:0]cnt_50ms;
	reg [31:0]cnt_2s;
	// wire [3:0] addr;
	reg [7:0] rand;//random number (used for generating random mole)
    reg buzzer_reg;//the state of buzzer
	initial begin
		Map=0;//***********************************
		Score=0;
		Time1=0;
		Time2=0;//initial
//		buzzer_reg=1;
		BTN_successful=0;
		BTN_failed=0;
		BTN=0;
	end
//	assign buzzer=buzzer_reg;
	//Key_input

	reg [31:0]clkdiv;
	always@(posedge clk) begin
		clkdiv <= clkdiv + 1'b1;
	end

	wire keyReady;
	wire [4:0] keyCode;
	Key_input k0 (.clk(clkdiv[15]), .keyX(KeyY), .keyY(KeyX), .keyCode(keyCode), .ready(keyReady));//call Key_input to detect button pressed
	wire [31:0] segTestData;//the data that needed to be displayed
	wire [3:0]sout;
	//Score Board
	Seg7Device segDevice(.clkIO(clkdiv[3]), .clkScan(clkdiv[15:14]), .clkBlink(clkdiv[25]),
		.data(segTestData), .point(8'h0), .LES(8'h0),
		.sout(sout));//call function to display score on the 8 digit 7 Segment LED board
	assign SEGLED_CLK = sout[3];
	assign SEGLED_DO = sout[2];
	assign SEGLED_PEN = sout[1];
	assign SEGLED_CLR = sout[0];
	assign segTestData = {20'b0,Score};//assign the score to the data

	//LED
	assign LEDB0 =1;//assign the visual effect for tricolor LED
	assign LEDG0 = ~((Map[1] & ~Map[0])|(Map[3] & ~Map[2])|(Map[5] & ~Map[4])|(Map[7] &~Map[6])|(Map[9] & ~Map[8])|(Map[11]& ~Map[10])|(Map[13] &~Map[12])|(Map[15]& ~Map[14])|(Map[17] & ~Map[16]));
	assign LEDR0 =  ~((Map[1] & Map[0])|(Map[3] & Map[2])|(Map[5] & Map[4])|(Map[7] &Map[6])|(Map[9] &Map[8])|(Map[11]& Map[10])|(Map[13] &Map[12])|(Map[15]& Map[14])|(Map[17] & Map[16]));	
	assign LEDR1=1;//turn off another LED
   	assign LEDG1=1;//turn off another LED
   	assign LEDB1=1;//turn off another LED
 	assign buzzer=buzzer_reg;//buzzer activated when hit mole
	reg wasReady;
	always @(posedge clk)begin//give the right BTN press signal
		wasReady <= keyReady;
		if (!wasReady&&keyReady) begin
			case (keyCode)
				5'h0: BTN[0]<=1;
				5'h4: BTN[1]<=1;
				5'h8: BTN[2]<=1;
				5'h1: BTN[3]<=1;
				5'h5: BTN[4]<=1;
				5'h9: BTN[5]<=1;
				5'h2: BTN[6]<=1;
				5'h6: BTN[7]<=1;
				5'ha: BTN[8]<=1;
				default: ;
			endcase
		end else begin
			BTN<=0;
		end	
	end
	//map refresher
	always@(posedge clk)begin//buzzer_reg, Map, 
		//status 00 and 01	
        if(((Map[1]&~Map[0])|(Map[3]&~Map[2])|(Map[5]&~Map[4])|(Map[7]&~Map[6])|(Map[9]&~Map[8])|(Map[11]&~Map[10])|(Map[13]&~Map[12])|(Map[15]&~Map[14])|(Map[17]&~Map[16]))==1)
            buzzer_reg=0;//only when "10" state that buzzer is activated
        else 
            buzzer_reg=1;//else buzzer turned off
		if(Time1[1:0]==0&&Time2[1:0]==0)begin
			Map[1:0]=0;//give proper state to Map
		end
		else if(Time1[1:0]!=0||Time2[1:0]==0)
			Map[1:0]=1;//give proper state to Map
		else if((Map[1:0]==2'b11||Map[1:0]==2'b10)&&Time2[1:0]==0) begin
			Map[1:0]=0;//give proper state to Map
		end else begin
		end

		//2
		if(Time1[3:2]==0&&Time2[3:2]==0)begin
			Map[3:2]=0;//give proper state to Map
		end
		else if(Time1[3:2]!=0||Time2[3:2]==0)//give proper state to Map[3:2]
			Map[3:2]=1;
		else if((Map[3:2]==2'b11||Map[3:2]==2'b10)&&Time2[3:2]==0) begin
			Map[3:2]=0;
		end else begin
		end

		if(Time1[5:4]==0&&Time2[5:4]==0)begin//give proper state to Map[5:4]
			Map[5:4]=0;
		end
		else if(Time1[5:4]!=0||Time2[5:4]==0)
			Map[5:4]=1;
		else if((Map[5:4]==2'b11||Map[5:4]==2'b10)&&Time2[5:4]==0) begin
			Map[5:4]=0;
		end else begin
		end

		if(Time1[7:6]==0&&Time2[7:6]==0)begin//give proper state to Map[7:6]
			Map[7:6]=0;
		end
		else if(Time1[7:6]!=0||Time2[7:6]==0)
			Map[7:6]=1;
		else if((Map[7:6]==2'b11||Map[7:6]==2'b10)&&Time2[7:6]==0) begin
			Map[7:6]=0;
		end else begin
		end

		if(Time1[9:8]==0&&Time2[9:8]==0)begin//give proper state to Map[9:8]
			Map[9:8]=0;
		end
		else if(Time1[9:8]!=0||Time2[9:8]==0)
			Map[9:8]=1;
		else if((Map[9:8]==2'b11||Map[9:8]==2'b10)&&Time2[9:8]==0) begin
			Map[9:8]=0;
		end else begin
		end

		if(Time1[11:10]==0&&Time2[11:10]==0)begin//give proper state to Map[11:10]
			Map[11:10]=0;
		end
		else if(Time1[11:10]!=0||Time2[11:10]==0)
			Map[11:10]=1;
		else if((Map[11:10]==2'b11||Map[11:10]==2'b10)&&Time2[11:10]==0) begin
			Map[11:10]=0;
		end else begin
		end

		if(Time1[13:12]==0&&Time2[13:12]==0)begin//give proper state to Map[13:12]
			Map[13:12]=0;
		end
		else if(Time1[13:12]!=0||Time2[13:12]==0)
			Map[13:12]=1;
		else if((Map[13:12]==2'b11||Map[13:12]==2'b10)&&Time2[13:12]==0) begin
			Map[13:12]=0;
		end else begin
		end

		if(Time1[15:14]==0&&Time2[15:14]==0)begin//give proper state to Map[15:14]
			Map[15:14]=0;
		end
		else if(Time1[15:14]!=0||Time2[15:14]==0)
			Map[15:14]=1;
		else if((Map[15:14]==2'b11||Map[15:14]==2'b10)&&Time2[15:14]==0) begin
			Map[15:14]=0;
		end else begin
		end

		if(Time1[17:16]==0&&Time2[17:16]==0)begin//give proper state to Map[17:16]
			Map[17:16]=0;
		end
		else if(Time1[17:16]!=0||Time2[17:16]==0)
			Map[17:16]=1;
		else if((Map[17:16]==2'b11||Map[17:16]==2'b10)&&Time2[17:16]==0) begin
			Map[17:16]=0;
		end else begin
		end
			//status 10 and 11
			//successful (10)
		if(BTN!=0)begin//when a button is pressed
				if(BTN[0]&&Time1[1:0]!=0)begin//hit mole 1?
					BTN_successful[0]=1;//yes
				end 
				if(BTN[0]&&Time1[1:0]==0)begin
					BTN_failed[0]=1;//no
				end
				//...For others (set successful and fail)
				if(BTN[1]&&Time1[3:2]!=0)begin
					BTN_successful[1]=1;
				end 
				if(BTN[1]&&Time1[3:2]==0)begin
					BTN_failed[1]=1;
				end

				if(BTN[2]&&Time1[5:4]!=0)begin
					BTN_successful[2]=1;
				end 
				if(BTN[2]&&Time1[5:4]==0)begin
					BTN_failed[2]=1;
				end

				if(BTN[3]&&Time1[7:6]!=0)begin
					BTN_successful[3]=1;
				end 
				if(BTN[3]&&Time1[7:6]==0)begin
					BTN_failed[3]=1;
				end

				if(BTN[4]&&Time1[9:8]!=0)begin
					BTN_successful[4]=1;
				end 
				if(BTN[4]&&Time1[9:8]==0)begin
					BTN_failed[4]=1;
				end

				if(BTN[5]&&Time1[11:10]!=0)begin
					BTN_successful[5]=1;
				end 
				if(BTN[5]&&Time1[11:10]==0)begin
					BTN_failed[5]=1;
				end

				if(BTN[6]&&Time1[13:12]!=0)begin
					BTN_successful[6]=1;
				end 
				if(BTN[6]&&Time1[13:12]==0)begin
					BTN_failed[6]=1;
				end

				if(BTN[7]&&Time1[15:14]!=0)begin
					BTN_successful[7]=1;
				end 
				if(BTN[7]&&Time1[15:14]==0)begin
					BTN_failed[7]=1;
				end

				if(BTN[8]&&Time1[17:16]!=0)begin
					BTN_successful[8]=1;
				end 
				if(BTN[8]&&Time1[17:16]==0)begin
					BTN_failed[8]=1;
				end

				if(BTN_successful!=0)begin//if hit a mole
					//gain score
					if(Score[3:0]==4'b1001)begin//score plus one
						Score[3:0]=0;
						if(Score[7:4]==4'b1001)begin
							Score[7:4]=0;
							if(Score[11:8]==4'b1001)begin
								Score[11:8]=0;
							end
							else begin
								Score[11:8]=Score[11:9]+1;
							end
						end 
						else begin
							Score[7:4]=Score[7:4]+1;
						end
					end
					else begin
						Score=Score+1;
					end	
					//Gain scores above 
					//Set Map below
					if(BTN_successful[0]==1)begin//set the state to "10"
						Map[1:0]=2;
						Time1[1:0]=0;
						Time2[1:0]=2'b11;
					end

					if(BTN_successful[1]==1)begin//set the state to "10"
						Map[3:2]=2;
						Time1[3:2]=0;
						Time2[3:2]=2'b11;
					end

					if(BTN_successful[2]==1)begin//set the state to "10"
						Map[5:4]=2;
						Time1[5:4]=0;
						Time2[5:4]=2'b11;
					end

					if(BTN_successful[3]==1)begin//set the state to "10"
						Map[7:6]=2;
						Time1[7:6]=0;
						Time2[7:6]=2'b11;
					end

					if(BTN_successful[4]==1)begin//set the state to "10"
						Map[9:8]=2;
						Time1[9:8]=0;
						Time2[9:8]=2'b11;
					end

					if(BTN_successful[5]==1)begin//set the state to "10"
						Map[11:10]=2;
						Time1[11:10]=0;
						Time2[11:10]=2'b11;
					end

					if(BTN_successful[6]==1)begin//set the state to "10"
						Map[13:12]=2;
						Time1[13:12]=0;
						Time2[13:12]=2'b11;
					end

					if(BTN_successful[7]==1)begin//set the state to "10"
						Map[15:14]=2;
						Time1[15:14]=0;
						Time2[15:14]=2'b11;
					end

					if(BTN_successful[8]==1)begin//set the state to "10"
						Map[17:16]=2;
						Time1[17:16]=0;
						Time2[17:16]=2'b11;
					end
					//... for others(Set Map)

				end
				//BTN_failed
				if(BTN_failed!=0)begin
					if(BTN_failed[0]==1)begin//set the state to "11" (hit an empty hole)
						Map[1:0]=3;
						Time1[1:0]=0;
						Time2[1:0]=2'b11;
					end
					if(BTN_failed[1]==1)begin//set the state to "11" (hit an empty hole)
						Map[3:2]=3;
						Time1[3:2]=0;
						Time2[3:2]=2'b11;
					end
					if(BTN_failed[2]==1)begin//set the state to "11" (hit an empty hole)
						Map[5:4]=3;
						Time1[5:4]=0;
						Time2[5:4]=2'b11;
					end
					if(BTN_failed[3]==1)begin//set the state to "11" (hit an empty hole)
						Map[7:6]=3;
						Time1[7:6]=0;
						Time2[7:6]=2'b11;
					end
					if(BTN_failed[4]==1)begin//set the state to "11" (hit an empty hole)
						Map[9:8]=3;
						Time1[9:8]=0;
						Time2[9:8]=2'b11;
					end
					if(BTN_failed[5]==1)begin//set the state to "11" (hit an empty hole)
						Map[11:10]=3;
						Time1[11:10]=0;
						Time2[11:10]=2'b11;
					end
					if(BTN_failed[6]==1)begin//set the state to "11" (hit an empty hole)
						Map[13:12]=3;
						Time1[13:12]=0;
						Time2[13:12]=2'b11;
					end
					if(BTN_failed[7]==1)begin//set the state to "11" (hit an empty hole)
						Map[15:14]=3;
						Time1[15:14]=0;
						Time2[15:14]=2'b11;
					end
					if(BTN_failed[8]==1)begin//set the state to "11" (hit an empty hole)
						Map[17:16]=3;
						Time1[17:16]=0;
						Time2[17:16]=2'b11;
					end
					//...for others(Set Map)
				end
				BTN_successful=0;//restore state of BTN
				BTN_failed=0;//restore state of BTN
		end
		//clk_1s: disppearing counter
		if (cnt_1s < 50_000_000) begin//should be 50_000_000
			cnt_1s = cnt_1s + 1;
		end else if(clk_1s==0) begin
			cnt_1s = 0;
			clk_1s = 1;
			//posedge
				if(Time1[1:0]>0)//every cycle minus one until to 0
					Time1[1:0]=Time1[1:0]-1;
				//... for others
				if(Time1[3:2]>0)
					Time1[3:2]=Time1[3:2]-1;
				if(Time1[5:4]>0)
					Time1[5:4]=Time1[5:4]-1;
				if(Time1[7:6]>0)
					Time1[7:6]=Time1[7:6]-1;
				if(Time1[9:8]>0)
					Time1[9:8]=Time1[9:8]-1;
				if(Time1[11:10]>0)
					Time1[11:10]=Time1[11:10]-1;
				if(Time1[13:12]>0)
					Time1[13:12]=Time1[13:12]-1;
				if(Time1[15:14]>0)
					Time1[15:14]=Time1[15:14]-1;
				if(Time1[17:16]>0)
					Time1[17:16]=Time1[17:16]-1;
			//end posedge
		end else begin
			cnt_1s=0;
			clk_1s=0;
		end
		//clk_50ms: effect counter
		if (cnt_50ms < 2_500_000) begin//should be 2_500_000
			cnt_50ms = cnt_50ms + 1;
		end else if(clk_50ms==0) begin
			cnt_50ms = 0;
			clk_50ms = 1;
			//posedge
				if(Time1[1:0]==0&&Time2[1:0]>0)//every cycle minus one until to 0
					Time2[1:0]=Time2[1:0]-1;
				else if(Time1[1:0]==0)
					Map[1:0]=0;
				//... for others	
				if(Time1[3:2]==0&&Time2[3:2]>0)
					Time2[3:2]=Time2[3:2]-1;
				else if(Time1[3:2]==0)
					Map[3:2]=0;
				if(Time1[5:4]==0&&Time2[5:4]>0)
					Time2[5:4]=Time2[5:4]-1;
				else if(Time1[5:4]==0)
					Map[5:4]=0;
				if(Time1[7:6]==0&&Time2[7:6]>0)
					Time2[7:6]=Time2[7:6]-1;
				else if(Time1[7:6]==0)
					Map[7:6]=0;
				if(Time1[9:8]==0&&Time2[9:8]>0)
					Time2[9:8]=Time2[9:8]-1;
				else if(Time1[9:8]==0)
					Map[9:8]=0;
				if(Time1[11:10]==0&&Time2[11:10]>0)
					Time2[11:10]=Time2[11:10]-1;
				else if(Time1[11:10]==0)
					Map[11:10]=0;
				if(Time1[13:12]==0&&Time2[13:12]>0)
					Time2[13:12]=Time2[13:12]-1;
				else if(Time1[13:12]==0)
					Map[13:12]=0;
				if(Time1[15:14]==0&&Time2[15:14]>0)
					Time2[15:14]=Time2[15:14]-1;
				else if(Time1[15:14]==0)
					Map[15:14]=0;
				if(Time1[17:16]==0&&Time2[17:16]>0)
					Time2[17:16]=Time2[17:16]-1;
				else if(Time1[17:16]==0)
					Map[17:16]=0;
		
			//end posedge
		end else begin
			cnt_50ms=0;
			clk_50ms=0;
		end
		//clk_2s: generator
		if (cnt_2s < 20_000_000) begin
			cnt_2s = cnt_2s + 1;
		end else if(clk_2s==0) begin
			cnt_2s = 0;
			clk_2s = 1;

			if(rand[6:3]==0)begin//rand[6:3] is a random number, we generate a mole randomly according to it.
				if(Map[1:0]==0)Time1[1:0]=3;
			end
			else if(~rand[6]&&~rand[5]&&~rand[4]&&rand[3])begin
				if(Map[3:2]==0)begin
					Time1[3:2]=3;
				end		
			end
			else if(~rand[6]&&~rand[5]&&rand[4]&&~rand[3])begin
				if(Map[5:4]==0)begin
					Time1[5:4]=3;
				end		
			end
			else if(~rand[6]&&~rand[5]&&rand[4]&&rand[3])begin
				if(Map[7:6]==0)begin
					Time1[7:6]=3;
				end		
			end
			else if(~rand[6]&&rand[5]&&~rand[4]&&~rand[3])begin
				if(Map[9:8]==0)begin
					Time1[9:8]=3;
				end		
			end
			else if(~rand[6]&&rand[5]&&~rand[4]&&rand[3])
				if(Map[11:10]==0)Time1[11:10]=3;
			else if(~rand[6]&&rand[5]&&rand[4]&&~rand[3])
				if(Map[13:12]==0)Time1[13:12]=3;
			else if(~rand[6]&&rand[5]&&rand[4]&&rand[3])
				if(Map[15:14]==0)Time1[15:14]=3;
			else if(rand[6]&&~rand[5]&&~rand[4]&&~rand[3])
				if(Map[17:16]==0)Time1[17:16]=3;
		//end posedge
		end else begin
			cnt_2s=0;
			clk_2s=0;
		end
	end	
	always @(posedge clk ) begin//generate a psudo-random number using LFSR 
		    if(~(clkdiv&&1))
		        rand <=8'b10110111;    /*load the initial value when load is active*/
		    else begin
		            rand[0] <= rand[7];
		            rand[1] <= rand[0];
		            rand[2] <= rand[1];
		            rand[3] <= rand[2];
		            rand[4] <= rand[3]^rand[7];
		            rand[5] <= rand[4]^rand[7];
		            rand[6] <= rand[5]^rand[7];
		            rand[7] <= rand[6];
		    end
	end
	display d0(clk,Map,clear_screen,HS,VS,R,G,B);//call display module to display it on monitor
endmodule
