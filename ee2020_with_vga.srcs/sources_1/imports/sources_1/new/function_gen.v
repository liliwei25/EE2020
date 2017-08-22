module my_DAC(input CLOCK, RESET, TYPE, UPDATE, DUTYUP, DUTYDN, MODE, input [1:0] CONTROL, input [11:0] sw, output[15:0] led, 
    output dp, output [6:0]seg, output [3:0] an, output [11:0] DATA_A, input [11:0] mouseX, mouseY, keyX, keyY,
    input leftClick, rightClick, space, output reg freqclock = 0);
    
    reg HALF_CLOCK = 0, SEC_CLOCK = 0, DAC_CLOCK = 0, DEBOUNCE = 0, mORk = 0;
    reg[26:0]sec_count = 0;
    reg[5:0] COUNT = 0;
    reg[11:0] freqCount = 0, duty=0, dutycount = 0;
    reg[1:0] wave = 0;
    wire[11:0] SINE, TRIANGLE, SQUARE, value, amp, freq;
    reg[11:0] offset = 0, switchAmp = 12'hfff, switchFreq = 0;
    wire a, b, TYPE_PULSE, c, d, UPDATE_PULSE, e, f, g, h, DUTY_UP, i, j, DUTY_DN, k, l, LEFT_PULSE;//debouncing
    wire dir;
    wire[3:0] thousands, hundreds, tens, ones;
    
    sine_wave_gen wave1 (amp, freqclock, SINE, dir);
    triangle_wave_gen wave2 (amp, freqclock, TRIANGLE, SQUARE);    
    
    bin_to_BCD unit_a(amp, SEC_CLOCK, ones, tens, hundreds, thousands);
    seven_segment unit_b(CLOCK, SEC_CLOCK, ones, tens, hundreds, thousands, seg, an, dp);
    
    my_dff unit_one (DEBOUNCE, TYPE,a); //Debouncing circuits
    my_dff unit_two (DEBOUNCE, a, b);
    assign TYPE_PULSE = a&~b;
    
    my_dff unit_three (DEBOUNCE, UPDATE,c); //Debouncing circuits
    my_dff unit_four (DEBOUNCE, c, d);
    assign UPDATE_PULSE = c&~d;
    
    my_dff unit_seven (DEBOUNCE, DUTYUP,g); //Debouncing circuits
    my_dff unit_eight (DEBOUNCE, g, h);
    assign DUTY_UP = g&~h;
        
    my_dff unit_nine (DEBOUNCE, DUTYDN,i); //Debouncing circuits
    my_dff unit_ten (DEBOUNCE, i, j);
    assign DUTY_DN = i&~j;
    
    my_dff unit_eleven (DEBOUNCE, leftClick,k); //Debouncing circuits
    my_dff unit_twelve (DEBOUNCE, k, l);
    assign LEFT_PULSE = k&~l;
        
    assign amp = (MODE)? ((mORk)? keyY : (1023-mouseY)*4) : switchAmp;
    assign freq = (MODE)? ((mORk)? keyX :mouseX*16/5) : switchFreq;
    assign value = (((wave == 0) ? SQUARE : (wave == 1) ? TRIANGLE : SINE));
    assign DATA_A = (CONTROL==1)? (((4095-value) < offset)? 4095 : (value + offset)) : 
                    ((CONTROL==3) ? ((offset>value) ? 0 : value-offset) : value);
    assign led[11:0] = (CONTROL==0)? amp: (CONTROL==1 || CONTROL == 3)? offset: freq;
    assign led[12] = rightClick;
    assign led[13] = leftClick;
    assign led[14] = mouseY;
    assign led[15] = mouseX;
    
    always @ (posedge CLOCK)begin
        HALF_CLOCK <= ~HALF_CLOCK;
        COUNT <= COUNT+1;
        sec_count <= sec_count +1;
        SEC_CLOCK <= (sec_count == 0)? ~SEC_CLOCK:SEC_CLOCK;
        DAC_CLOCK <= (COUNT==0)? ~DAC_CLOCK:DAC_CLOCK;
        DEBOUNCE <= (sec_count[11:0] == 1) ? ~DEBOUNCE : DEBOUNCE;
        duty<=(RESET)?0:((DUTYUP)?((duty+sw[11:0]<=freq)?duty+sw[11:0]:duty):
                               (DUTYDN)?((duty-sw[11:0]<=freq)?duty-sw[11:0]:duty):duty);
        dutycount <= (dir)? (freq+duty) : (freq-duty);
        freqclock <= (freqCount == dutycount) ? ~freqclock : freqclock;
        freqCount <= (freqCount == dutycount) ? 0 : freqCount+1;
        wave<= (RESET)? 0 : (TYPE_PULSE || LEFT_PULSE || space) ? ((wave == 0)? 1 : (wave==1)?2:0) : wave;
    end
    
    always @ (posedge UPDATE_PULSE or posedge RESET) begin
        if(RESET)begin
            offset <= 0;
            switchFreq = 0;
            switchAmp = 12'hfff;
        end
        else begin
            if(MODE)
                mORk<=mORk +1;
            else begin
                switchAmp = (CONTROL==0) ? sw[11:0] : switchAmp;
                offset<=(CONTROL==1 || CONTROL==3) ? sw[11:0]:offset;
                switchFreq=(CONTROL == 2)? sw:switchFreq;  
            end
        end 
    end
endmodule

module my_dff(input DFF_CLOCK, D, output reg Q);
    always @ (posedge DFF_CLOCK) begin
        Q<=D;
    end
endmodule