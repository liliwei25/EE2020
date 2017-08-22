module seven_segment(input CLOCK, SEC_CLOCK, input[3:0]ones, tens, hundreds, thousands, output [6:0]seg, 
    output [3:0]an, output reg dp);
    
    reg [17:0]count = 0; //18 bit counter to multiplex at 1000Hz
    reg [3:0]an_temp, seg_temp;
    reg [6:0]seg_val;
     
    assign seg = seg_val;
    assign an = an_temp;
    
    always @ (posedge CLOCK) begin
       count <= count + 1;
    end
     
    always @ (*) begin
        case(count[17:16]) //using 2 MSBs of counter    
            2'b00 : begin  //enable the fourth display
                seg_temp = ones;
                an_temp = 4'b1110;
                dp = 1;
            end  
            2'b01: begin  //enable the third display
                seg_temp = tens;
                an_temp = 4'b1101;
                dp = 1;
            end
            2'b10: begin //enable the second display
                seg_temp = hundreds;
                an_temp = 4'b1011;
                dp = 1;
            end
            2'b11: begin //enable the first display
                seg_temp = thousands;
                an_temp = 4'b0111;
                dp = (SEC_CLOCK)? 0 : 1;
            end
        endcase
     end
     
    always @ (*) begin
        case(seg_temp)
            4'd0 : seg_val = 7'b1000000; //display 0
            4'd1 : seg_val = 7'b1111001; //display 1
            4'd2 : seg_val = 7'b0100100; //display 2
            4'd3 : seg_val = 7'b0110000; //display 3
            4'd4 : seg_val = 7'b0011001; //display 4
            4'd5 : seg_val = 7'b0010010; //display 5
            4'd6 : seg_val = 7'b0000010; //display 6
            4'd7 : seg_val = 7'b1111000; //display 7
            4'd8 : seg_val = 7'b0000000; //display 8
            4'd9 : seg_val = 7'b0010000; //display 9
            default : seg_val = 7'b0111111; //dash
        endcase
    end
endmodule