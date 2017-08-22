module bin_to_BCD(input [11:0]amp, input SEC_CLOCK, output reg[3:0]ones, tens, hundreds, thousands);
    integer i;
    wire [11:0] amp_temp;
    assign amp_temp = (SEC_CLOCK)? (amp/10*8):amp;
    
    always @ (amp_temp)begin
        thousands = 0;
        hundreds = 0;
        tens = 0;
        ones = 0;
        
        for(i = 11; i >= 0; i = i-1)begin
            if(thousands >= 5) thousands = thousands +3;
            if(hundreds >= 5) hundreds = hundreds +3;
            if(tens >= 5) tens = tens +3;
            if(ones >= 5) ones = ones +3;
            
            thousands = thousands << 1;
            thousands[0] = hundreds[3];
            hundreds = hundreds << 1;
            hundreds[0] = tens[3];
            tens = tens << 1;
            tens[0] = ones[3];
            ones = ones << 1;
            ones[0] = amp_temp[i];
        end
    end
endmodule 