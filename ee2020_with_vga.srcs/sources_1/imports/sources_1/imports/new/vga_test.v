module vga (input clk, reset, input [11:0] ycount,xcount,output hsync, vsync, output [11:0] rgb);
	reg [11:0] rgb_reg;
	wire video_on, currentPos, grid, name;
    wire [9:0] xcor, ycor;
    
    assign name = ((ycor<=236 && ycor >= 227 && xcor == 10) || (ycor == 236 && xcor >= 10 && xcor <= 15) || 
                  (ycor<=236 && ycor >= 227 && xcor == 17) || (xcor == 19 && (ycor == 227 || ycor == 228)) ||
                  (xcor == 20 && (ycor == 229 || ycor == 230)) || (xcor == 21 && (ycor == 231 || ycor == 232)) ||
                  (xcor == 22 && (ycor == 233 || ycor == 234)) || (xcor == 23 && (ycor == 235 || ycor == 236)) ||
                  (xcor == 24 && (ycor == 236 || ycor == 235)) || (xcor == 25 && (ycor == 234 || ycor == 233)) || 
                  (xcor == 26 && (ycor == 232 || ycor == 231)) || (xcor == 27 && (ycor == 230 || ycor == 229)) || 
                  (xcor == 28 && (ycor == 228 || ycor == 227)) || (xcor == 29 && (ycor == 227 || ycor == 228)) ||
                  (xcor == 30 && (ycor == 229 || ycor == 230)) || (xcor == 31 && (ycor == 231 || ycor == 232)) ||
                  (xcor == 32 && (ycor == 233 || ycor == 234)) || (xcor == 33 && (ycor == 235 || ycor == 236)) ||
                  (xcor == 34 && (ycor == 236 || ycor == 235)) || (xcor == 35 && (ycor == 234 || ycor == 233)) || 
                  (xcor == 36 && (ycor == 232 || ycor == 231)) || (xcor == 37 && (ycor == 230 || ycor == 229)) || 
                  (xcor == 38 && (ycor == 228 || ycor == 227)) || (xcor == 40 && ycor <=236 && ycor >= 227) ||
                  (xcor >= 40 && xcor <= 45 && ycor == 236) || (xcor >= 40 && xcor <= 45 && ycor == 231) ||
                  (xcor >= 40 && xcor <= 45 && ycor == 227) || (xcor == 47 && ycor <= 236 && ycor >= 227))? 1: 0;
    assign grid = (xcor == 1 || xcor == 319 || xcor == 639 || ycor == 22 ||ycor == 239 || ycor == 479)? 1 : 0;
    assign currentPos = (xcor == (xcount>>3) && ycor == 367-(rgb_reg>>4)) ? 1 :0;
    assign rgb = (video_on && (grid||currentPos||name)) ? 4095 : 12'b0;
        
    always @(posedge clk)begin
        rgb_reg <= (reset)? 0 : ycount;
    end
    
    vga_sync vga_sync_unit (
     .clk(clk),
     .reset(reset), 
     .hsync(hsync), 
     .vsync(vsync),
     .video_on(video_on), 
     .p_tick(), 
     .x(xcor), 
     .y(ycor));
endmodule