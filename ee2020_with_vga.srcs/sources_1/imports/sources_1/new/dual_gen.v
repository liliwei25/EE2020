module dual_gen(input CLOCK, RESET, TYPE, UPDATE, DUTYUP, DUTYDN, CHANNEL, MODE, input [1:0] CONTROL, input [11:0] sw,
    output[3:0] JA, an, output[15:0] led, output dp, output [6:0]seg, inout PS2Clk, PS2Data, 
    output[3:0] vgaRed, vgaBlue, vgaGreen, output Hsync, Vsync);
    
    wire TYPE_A, TYPE_B, UPDATE_A, UPDATE_B, DUTYUP_A, DUTYUP_B, DUTYDN_A, DUTYDN_B, MODE_A, MODE_B,
      dp_a, dp_b, leftClick, leftA, leftB, rightClick, rightA, rightB, middleClick, freqClock, freqClockA, freqClockB
      , space, esc, reset, wave;
    wire[1:0] CONTROL_A, CONTROL_B;
    wire[11:0]sw_a, sw_b;
    wire[3:0]JA_A, JA_B, an_a, an_b;
    wire[15:0]led_a, led_b;
    wire[6:0]seg_a, seg_b;
    wire[11:0]DATA_A, DATA_B, mouseX, mXA, mXB, mouseY, mYA, mYB ,keyX, kXA, kXB, keyY, kYA, kYB, ycor, rgb;
    reg HALF_CLOCK = 0;
    reg [5:0] COUNT = 0;
    reg DAC_CLOCK = 0;
    reg [11:0] xcor = 0;
    reg [1:0] slowcount = 0;
    
    assign reset = (RESET || esc || middleClick)? 1 : 0;
    assign TYPE_A = (CHANNEL)? TYPE : TYPE_A;
    assign TYPE_B = (CHANNEL)? TYPE_B : TYPE;
    assign UPDATE_A = (CHANNEL)? UPDATE : UPDATE_A;
    assign UPDATE_B = (CHANNEL)? UPDATE_B : UPDATE;
    assign DUTYUP_A = (CHANNEL)? DUTYUP : DUTYUP_A;
    assign DUTYUP_B = (CHANNEL)? DUTYUP_B : DUTYUP;
    assign DUTYDN_A = (CHANNEL)? DUTYDN : DUTYDN_A;
    assign DUTYDN_B = (CHANNEL)? DUTYDN_B : DUTYDN;
    assign CONTROL_A = (CHANNEL)? CONTROL : CONTROL_A;
    assign CONTROL_B = (CHANNEL)? CONTROL_B : CONTROL;
    assign MODE_A = (CHANNEL)? MODE : MODE_A;
    assign MODE_B = (CHANNEL)? MODE_B : MODE;
    assign mXA = (CHANNEL)? mouseX : mXA;
    assign mXB = (CHANNEL)? mXB : mouseX;
    assign mYA = (CHANNEL)? mouseY : mYA;
    assign mYB = (CHANNEL)? mYB : mouseY;
    assign kXA = (CHANNEL)? keyX : kXA;
    assign kXB = (CHANNEL)? kXB : keyX;
    assign kYA = (CHANNEL)? keyY : kYA;
    assign kYB = (CHANNEL)? kYB : keyY;
    assign leftA = (CHANNEL)? leftClick : leftA;
    assign leftB = (CHANNEL)? leftB : leftClick;
    assign rightA= (CHANNEL)? rightClick : rightA;
    assign rightB= (CHANNEL)? rightB:rightClick;
    assign sw_a = (CHANNEL)? sw : sw_a;
    assign sw_b = (CHANNEL)? sw_b: sw;
    assign led = (CHANNEL)? led_a : led_b;
    assign dp = (CHANNEL)? dp_a : dp_b;
    assign seg = (CHANNEL)? seg_a : seg_b;
    assign an = (CHANNEL)? an_a : an_b;
    assign freqClock = (CHANNEL)? freqClockA : freqClockB;
    assign ycor = (CHANNEL)? DATA_A : DATA_B;
    assign vgaRed = rgb[3:0];
    assign vgaGreen = rgb[7:4];
    assign vgaBlue = rgb[11:8];
    
    my_DAC gen1(CLOCK, reset, TYPE_A, UPDATE_A, DUTYUP_A, DUTYDN_A, MODE_A, CONTROL_A, sw_a, led_a, dp_a, seg_a, an_a,
         DATA_A, mXA, mYA, kXA, kYA, leftA, rightA, space, freqClockA);
    my_DAC gen2(CLOCK, reset, TYPE_B, UPDATE_B, DUTYUP_B, DUTYDN_B, MODE_B, CONTROL_B, sw_b, led_b, dp_b, seg_b, an_b,
         DATA_B, mXB, mYB, kXB, kYB, leftB, rightB, space, freqClockB);
    vga vga(CLOCK,reset, ycor, xcor, Hsync, Vsync, rgb);
    Keyboard keyboard (CLOCK, PS2Clk, PS2Data, keyX, keyY, space, esc);
    
    always @ (posedge CLOCK) begin
        HALF_CLOCK <= ~HALF_CLOCK;
        COUNT <= COUNT+1;
        DAC_CLOCK <= (COUNT==0)? ~DAC_CLOCK:DAC_CLOCK;
    end
    
    always @ (posedge freqClock) begin
        slowcount<=slowcount+1;
        xcor<= (slowcount == 0)? xcor+1 : xcor;
    end

    DA2RefComp MY_BASIC_DAC (
     .CLK(HALF_CLOCK), 
     .START(DAC_CLOCK), 
     .RST(reset), 
     .D1(JA[1]), 
     .D2(JA[2]), 
     .CLK_OUT(JA[3]), 
     .nSYNC(JA[0]), 
     .DATA1(DATA_A), 
     .DATA2(DATA_B), 
     .DONE()  
    );
    
    MouseCtl mymouse (
     .clk(CLOCK),
     .rst(reset),
     .xpos(mouseX),
     .ypos(mouseY),
     .zpos(),
     .left(leftClick),
     .middle(middleClick),
     .right(rightClick),
     .new_event(),
     .value(),
     .setx(),
     .sety(),
     .setmax_x(),
     .setmax_y(),
     .ps2_clk(PS2Clk),
     .ps2_data(PS2Data)
    );
endmodule