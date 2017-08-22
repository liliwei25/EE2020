`timescale 1ns / 1ps

module Keyboard(input CLK, PS2_CLK,PS2_DATA, output reg [11:0] keyX = 0, keyY = 0, output reg space = 0, esc = 0);
	wire [7:0] ARROW_UP = 8'h75;	//codes for arrows
	wire [7:0] ARROW_DOWN = 8'h72;
	wire [7:0] ARROW_LEFT = 8'h6B;
	wire [7:0] ARROW_RIGHT = 8'h74;	
	wire [7:0] TOGGLE = 8'h4E;
	wire [7:0] MODE = 8'h0E;
	wire [7:0] ONE = 8'h16;
    wire [7:0] TWO = 8'h1E;
    wire [7:0] THREE = 8'h26;
    wire [7:0] FOUR = 8'h25;
    wire [7:0] FIVE = 8'h2E;
    wire [7:0] SIX = 8'h36;
    wire [7:0] SEVEN = 8'h3D;
    wire [7:0] EIGHT = 8'h3E;
    wire [7:0] NINE = 8'h46;
    wire [7:0] ZERO = 8'h45;
    wire [7:0] SPACE = 8'h29;
    wire [7:0] ENTER = 8'h5A;
    wire [7:0] F1 = 8'h05;
    wire [7:0] F2 = 8'h06;
    wire [7:0] F3 = 8'h04;
    wire [7:0] F4 = 8'h0C;	
    wire [7:0] ESC = 8'h76;	
	reg [11:0] count_reading = 0, valX, valY;			
	reg [10:0] scan_code = 0;			
	reg [7:0] CODEWORD = 0, DOWNCOUNTER = 0;						
	reg [3:0]COUNT = 0;	
	reg [1:0] pos = 0;						 	
    reg PREVIOUS_STATE = 1 , read = 0, scan_err = 0, TRIG_ARR, TRIGGER = 0, mode = 0, toggle = 0;	
    
	always @(posedge CLK) begin				//This reduces the frequency 250 times
		if (DOWNCOUNTER < 249) begin			//and uses variable TRIGGER as the new board clock 
			DOWNCOUNTER <= DOWNCOUNTER + 1;
			TRIGGER <= 0;
		end
		else begin
			DOWNCOUNTER <= 0;
			TRIGGER <= 1;
		end
	end
	
	always @(posedge CLK) begin	
		if (TRIGGER) begin
			if (read)				
				count_reading <= count_reading + 1;	
			else 						
				count_reading <= 0;			
		end
	end

	always @(posedge CLK) begin		
	if (TRIGGER) begin						
		if (PS2_CLK != PREVIOUS_STATE) begin		
			if (!PS2_CLK) begin				
				read <= 1;				
				scan_err <= 0;				
				scan_code[10:0] <= {PS2_DATA, scan_code[10:1]};
				COUNT <= COUNT + 1;		
			end
		end
		else if (COUNT == 11) begin				
			COUNT <= 0;
			read <= 0;					
			TRIG_ARR <= 1;					
			
			if (!scan_code[10] || scan_code[0] || !(scan_code[1]^scan_code[2]^scan_code[3]^scan_code[4]
				^scan_code[5]^scan_code[6]^scan_code[7]^scan_code[8]
				^scan_code[9]))
				scan_err <= 1;
			else 
				scan_err <= 0;
		end	
		else  begin						
			TRIG_ARR <= 0;					
			if (COUNT < 11 && count_reading >= 4000) begin	
				COUNT <= 0;				
				read <= 0;				
			end
		end
	PREVIOUS_STATE <= PS2_CLK;					
	end
	end

	always @(posedge CLK) begin
		if (TRIGGER) begin					
			if (TRIG_ARR) begin				
				if (scan_err) begin			
					CODEWORD <= 8'd0;		
				end
				else begin
					CODEWORD <= scan_code[8:1];	
				end				
			end					
			else CODEWORD <= 8'd0;				
		end
		else CODEWORD <= 8'd0;					
	end
	
	always @(posedge CLK) begin
	   	space<=(CODEWORD == SPACE)?1 :0;
        esc <= (CODEWORD == ESC)? 1 : 0;
	end
	always @(posedge CLK) begin	
        if (CODEWORD == ARROW_UP)
            keyY <= (keyY< 4095)? (keyY+1) : keyY;
        else if (CODEWORD == ARROW_DOWN)
            keyY <= (keyY > 0)? (keyY - 1) : keyY;		
        else if (CODEWORD == ARROW_LEFT)
            keyX <= (keyX > 0)? (keyX -1 ) : keyX;
        else if (CODEWORD == ARROW_RIGHT)
            keyX <= (keyX< 4095)? (keyX+1) : keyX;
        else if (CODEWORD == MODE)
            mode <= mode + 1;
        else if (CODEWORD == TOGGLE)
            toggle<=toggle+1;
        else if (CODEWORD == F1)
            pos <= 0;
        else if (CODEWORD == F2)
            pos <= 1;
        else if (CODEWORD == F3)
            pos <= 2;
        else if (CODEWORD == F4)
            pos <= 3;
        else if (CODEWORD == ONE)begin
                valX <= (pos == 0)? 1 : (pos == 1)? 10 : (pos == 2)? 100 : 1000;
                valY <= (pos == 0)? 1 : (pos == 1)? 10 : (pos == 2)? 100 : 1000;
        end
        else if (CODEWORD == TWO)begin
                valX <= (pos == 0)? 2 : (pos == 1)? 20 : (pos == 2)? 200 : 2000;
                valY <= (pos == 0)? 2 : (pos == 1)? 20 : (pos == 2)? 200 : 2000;
        end
        else if (CODEWORD == THREE)begin
                valX <= (pos == 0)? 3 : (pos == 1)? 30 : (pos == 2)? 300 : 3000;
                valY <= (pos == 0)? 3 : (pos == 1)? 30 : (pos == 2)? 300 : 3000;
        end
        else if (CODEWORD == FOUR)begin
                valX <= (pos == 0)? 4 : (pos == 1)? 40 : (pos == 2)? 400 : 4000;
                valY <= (pos == 0)? 4 : (pos == 1)? 40 : (pos == 2)? 400 : 4000;
        end
        else if (CODEWORD == FIVE)begin
                valX <= (pos == 0)? 5 : (pos == 1)? 50 : (pos == 2)? 500 : 4095;
                valY <= (pos == 0)? 5 : (pos == 1)? 50 : (pos == 2)? 500 : 4095;
        end
        else if (CODEWORD == SIX)begin
                valX <= (pos == 0)? 6 : (pos == 1)? 60 : (pos == 2)? 600 : 4095;
                valY <= (pos == 0)? 6 : (pos == 1)? 60 : (pos == 2)? 600 : 4095;
        end
        else if (CODEWORD == SEVEN)begin
                valX <= (pos == 0)? 7 : (pos == 1)? 70 : (pos == 2)? 700 : 4095;
                valY <= (pos == 0)? 7 : (pos == 1)? 70 : (pos == 2)? 700 : 4095;
        end
        else if (CODEWORD == EIGHT)begin
                valX <= (pos == 0)? 8 : (pos == 1)? 80 : (pos == 2)? 800 : 4095;
                valY <= (pos == 0)? 8 : (pos == 1)? 80 : (pos == 2)? 800 : 4095;
        end
        else if (CODEWORD == NINE)begin
                valX <= (pos == 0)? 9 : (pos == 1)? 90 : (pos == 2)? 900 : 4095;
                valY <= (pos == 0)? 9 : (pos == 1)? 90 : (pos == 2)? 900 : 4095;
        end
        else if (CODEWORD == ZERO)begin
                valX <= (pos == 0)? 0 : (pos == 1)? 0 : (pos == 2)? 0 : 0;
                valY <= (pos == 0)? 0 : (pos == 1)? 0 : (pos == 2)? 0 : 0;
        end
        else if (CODEWORD == ENTER) begin
            if(mode)
                keyX<= (toggle)? ((keyX>=valX)?(keyX-valX):0):((4095-keyX>=valX)?(keyX+valX):4095);
            else
                keyY<= (toggle)? ((keyY>=valY)?(keyY-valY):0):((4095-keyY>=valY)?(keyY+valY):4095);
        end
    end
endmodule