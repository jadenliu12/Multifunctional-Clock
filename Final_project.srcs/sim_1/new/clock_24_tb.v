module clock_24_tb;
    
    reg clk, enter_flag, play_flag;
    reg [1:0] clk_date_cnt;
    reg [3:0] state;
    reg [35:0] alphanum;
    wire [3:0] week;
    wire [35:0] clock_cnt;
    
    clock_24 clkmodtb(.clk(clk),
                 .enter_flag(enter_flag),
                 .play(play_flag),
                 .clk_date_cnt(clk_date_cnt),
                 .state(state),
                 .alphanum(alphanum),
                 .week(week),
                 .clock_cnt(clock_cnt)
                 );    
                 
    initial begin
        #0  state = 4'd1; clk_date_cnt = 2'd2; alphanum = {6'd0, 6'd5, 6'd0, 6'd1, 6'd2, 6'd1}; enter_flag = 1'b1; play_flag = 1'd0;
        #30 state = 4'd2;   
        $finish;
    end 
    
    always #10 clk = ~clk;                
    
endmodule
