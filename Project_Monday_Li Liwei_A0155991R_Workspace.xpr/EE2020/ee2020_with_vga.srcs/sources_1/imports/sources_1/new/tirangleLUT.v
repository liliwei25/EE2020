module triangle_wave_gen(input[11:0] amp, input CLOCK, output [11:0] triangle_out, square_out);
    reg [11:0] value = 0; //Counter to increase amplitude according to frequency
    reg dir = 1; //Direction of amplitude; 1: increase, 0: decrease
    
    always@ (posedge CLOCK)begin
        value = (dir) ? value+ 1 : value - 1; //Changes amplitude with frequency
    end
    
    always@(negedge CLOCK) begin
        dir <= (value == 4095 || value == 0) ? ~dir : dir; //Changes direction at max/ min amplitude
    end
    
    assign triangle_out = amp*value/4095; //Output for Triangle Wave; Changes values according to selected amplitude
    assign square_out = (dir)? amp : 0; //Output for Square Wave; Alternates between selected amplitude and 0
endmodule