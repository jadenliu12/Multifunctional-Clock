`define INITIAL 4'd0
`define CLOCK 4'd1
`define SHOW_CLOCK 4'd2
`define CHANGE_MODE 4'd3
`define TIMER 4'd4
`define SHOW_TIMER 4'd5
`define ALARM 4'd6
`define SHOW_ALARM 4'd7
`define SHOW_STOPWATCH 4'd8

module clock_24(
    input clk,
    input enter_flag,  
    input play,  
    input [1:0] clk_date_cnt,
    input [3:0] state,    
    input  [35:0] alphanum,
    output wire [31:0] week,
    output wire [35:0] clock_cnt
    );

    reg [5:0] digit1, digit2, digit3, digit4, digit5, digit6;
    reg [5:0] next_digit1, next_digit2, next_digit3, next_digit4, next_digit5, next_digit6;  
    
    reg [5:0] date_digit1, date_digit2, month_digit1, month_digit2, year_digit1, year_digit2;    
    reg [5:0] next_date_digit1, next_date_digit2, next_month_digit1, next_month_digit2, next_year_digit1, next_year_digit2;    
    
    wire [31:0] year;
    wire [31:0] month;
    wire [31:0] day;       
    
    reg flag;  
       
    wire clkDiv27;    
    reg [26:0] num;     
    
    parameter [31:0] m [0:11] = {
        31'd0, // january
        31'd3, // february
        31'd2, // march
        31'd5, // april
        31'd0, // may
        31'd3, // june
        31'd5, // july
        31'd1, // august
        31'd4, // september
        31'd6, // october        
        31'd2, // november
        31'd4 // december
     };      
                  
    always @(posedge clk) begin
        if(play && state == `SHOW_CLOCK)
            flag <= ~flag;
        else
            flag <= flag;                     
    end            
            
    always@(posedge clk)
    begin
        if(num < 100000000-1)
            num <= num + 1;
        else
            num <= 0;
    end    
    assign clkDiv27 = (num == 67108864) ? 1'b1 : 1'b0;
        
    always@(posedge clk) begin
        if(state == `CLOCK && enter_flag && clk_date_cnt == 1)
            {digit1, digit2, digit3, digit4, digit5, digit6} <= alphanum;
        else if(state == `CLOCK && enter_flag && clk_date_cnt == 2)
            {date_digit1, date_digit2, month_digit1, month_digit2, year_digit1, year_digit2} <= alphanum;            
        else if(clkDiv27) begin
            digit1 <= next_digit1;
            digit2 <= next_digit2;
            digit3 <= next_digit3;
            digit4 <= next_digit4;
            digit5 <= next_digit5;
            digit6 <= next_digit6;
            
            date_digit1 <= next_date_digit1;
            date_digit2 <= next_date_digit2;
            month_digit1 <= next_month_digit1;
            month_digit2 <= next_month_digit2;
            year_digit1 <= next_year_digit1;
            year_digit2 <= next_year_digit2;                      
        end
        else begin
            digit1 <= digit1;
            digit2 <= digit2;
            digit3 <= digit3;
            digit4 <= digit4;
            digit5 <= digit5;
            digit6 <= digit6; 
   
            date_digit1 <= date_digit1;
            date_digit2 <= date_digit2;
            month_digit1 <= month_digit1;
            month_digit2 <= month_digit2;
            year_digit1 <= year_digit1;
            year_digit2 <= year_digit2;                                                
        end
    end
    
    always@(*) begin
        if(digit1 == 6'd2) begin
            if(digit2 == 6'd3) begin
                if(digit3 == 6'd5) begin
                    if(digit4 == 6'd9) begin
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd0;
                                next_digit2 = 6'd0;
                                next_digit3 = 6'd0;
                                next_digit4 = 6'd0;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9 
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = 6'd5;
                                next_digit4 = 6'd9;
                                next_digit5 = 6'd5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = 6'd5;
                                next_digit4 = 6'd9;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = 6'd5;
                                next_digit4 = 6'd9;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                    
                    else begin //digit4 != 4'd9
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = 6'd5;
                                next_digit4 = digit4 + 6'd1;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = 6'd5;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = 6'd5;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = 6'd5;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                end
                
                else begin //digit3 != 6'd5
                    if(digit4 == 6'd9) begin
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = digit3 + 6'd1;
                                next_digit4 = 6'd0;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                    
                    else begin //digit4 != 6'd9
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = digit3;
                                next_digit4 = digit4 + 6'd1;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = 6'd3;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                end
            end
            
            else begin //digit2 != 6'd3
                if(digit3 == 6'd5) begin
                    if(digit4 == 6'd9) begin
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = digit2 + 6'd1;
                                next_digit3 = 6'd0;
                                next_digit4 = 6'd0;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                    
                    else begin //digit4 != 6'd9
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4 + 6'd1;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                end
                
                else begin //digit3 != 6'd5
                    if(digit4 == 6'd9) begin
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3 + 6'd1;
                                next_digit4 = 6'd0;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd0
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                    
                    else begin //digit4 != 6'd9
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4 + 6'd1;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = 6'd2;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                end
            end
        end //digit1 == 6'd2;
        
        else begin //digit1 != 6'd2;
            if(digit2 == 6'd3) begin
                if(digit3 == 6'd5) begin
                    if(digit4 == 6'd9) begin
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1 + 6'd1;
                                next_digit2 = 6'd0;
                                next_digit3 = 6'd0;
                                next_digit4 = 6'd0;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                    
                    else begin //digit4 != 6'd9
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4 + 6'd1;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9)
                            begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                end
                
                else begin //digit3 != 6'd5
                    if(digit4 == 6'd9) begin
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3 + 6'd1;
                                next_digit4 = 6'd0;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                    
                    else begin //digit4 != 6'd9
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4 + 6'd1;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9)
                            begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                end
            end
            
            else begin //digit2 != 6'd3
                if(digit3 == 6'd5) begin
                    if(digit4 == 6'd9) begin
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1;
                                next_digit2 = digit2 + 6'd1;
                                next_digit3 = 6'd0;
                                next_digit4 = 6'd0;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                    
                    else begin //digit4 != 6'd9
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4 + 6'd1;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                end
                
                else begin //digit3 != 6'd5
                    if(digit4 == 6'd9) begin
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3 + 6'd1;
                                next_digit4 = 6'd0;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9)
                            begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9 
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                    
                    else begin //digit4 != 6'd9
                        if(digit5 == 6'd5) begin
                            if(digit6 == 6'd9) begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4 + 6'd1;
                                next_digit5 = 6'd0;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                        
                        else begin //digit5 != 6'd5
                            if(digit6 == 6'd9)
                            begin
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5 + 6'd1;
                                next_digit6 = 6'd0;
                            end
                            
                            else begin //digit6 != 6'd9
                                next_digit1 = digit1;
                                next_digit2 = digit2;
                                next_digit3 = digit3;
                                next_digit4 = digit4;
                                next_digit5 = digit5;
                                next_digit6 = digit6 + 6'd1;
                            end
                        end
                    end
                end
            end
        end //digit1 == 6'd1;
    end   

    
    always@(*) begin
        if(digit1 == 6'd2 && digit2 == 6'd3 && digit3 == 6'd5 && digit4 == 6'd9 && digit5 == 6'd5 && digit6 == 6'd9) begin
            //December
            if(month_digit1 == 6'd1 && month_digit2 == 6'd2) begin
                if(date_digit1 == 6'd3 && date_digit2 == 6'd1) begin
                    if(year_digit1 == 6'd5 && year_digit2 == 6'd0) begin
                        next_year_digit1 = year_digit1;
                        next_year_digit2 = year_digit2;
                        next_month_digit1 = month_digit1;
                        next_month_digit2 = month_digit2;
                        next_date_digit1 = date_digit1;
                        next_date_digit2 = date_digit2;
                    end
                    
                    else if(year_digit1 < 6'd5 && year_digit2 == 6'd9) begin
                        next_year_digit1 = year_digit1 + 6'd1;
                        next_year_digit2 = 6'd0;
                        next_month_digit1 = 6'd0;
                        next_month_digit2 = 6'd1;
                        next_date_digit1 = 6'd0;
                        next_date_digit2 = 6'd1;
                    end
                    
                    else begin
                        next_year_digit1 = year_digit1;
                        next_year_digit2 = year_digit2 + 6'd1;
                        next_month_digit1 = 6'd0;
                        next_month_digit2 = 6'd1;
                        next_date_digit1 = 6'd0;
                        next_date_digit2 = 6'd1;
                    end
                end
                
                else if(date_digit1 == 6'd3 && date_digit2 == 6'd0) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = 6'd3;
                    next_date_digit2 = 6'd1;
                end
                
                else if(date_digit1 < 6'd3 && date_digit2 == 6'd9) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = date_digit1 + 6'd1;
                    next_date_digit2 = 6'd0;
                end
                
                else if(date_digit1 < 6'd3 && date_digit2 != 6'd9) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = date_digit1;
                    next_date_digit2 = date_digit2 + 6'd1;
                end

                else begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = date_digit1;
                    next_date_digit2 = date_digit2;                                
                end
            end //December
            
            //February
            else if(month_digit1 == 6'd0 && month_digit2 == 6'd2) begin
                if(date_digit1 == 6'd2 && date_digit2 == 6'd8) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2 + 6'd1;
                    next_date_digit1 = 6'd0;
                    next_date_digit2 = 6'd1;
                end
                
                else if(date_digit1 < 6'd2 && date_digit2 == 6'd9) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = date_digit1 + 6'd1;
                    next_date_digit2 = 6'd0;
                end
                
                else begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = date_digit1;
                    next_date_digit2 = date_digit2 + 6'd1;
                end
            end
            
            else if(month_digit1 == 6'd0 && month_digit2 == 6'd9) begin
                if(date_digit1 == 6'd3 && date_digit2 == 6'd0) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = 6'd1;
                    next_month_digit2 = 6'd0;
                    next_date_digit1 = 6'd0;
                    next_date_digit2 = 6'd1;
                end
                
                else if(date_digit1 < 6'd3 && date_digit2 == 6'd9) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = date_digit1 + 6'd1;
                    next_date_digit2 = 6'd0;
                end
                
                else begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = date_digit1;
                    next_date_digit2 = date_digit2 + 6'd1;
                end
            end
            
            //November, June, April
            else if((month_digit1 == 6'd1 && month_digit2 == 6'd1) ||
                    (month_digit1 == 6'd0 && month_digit2 == 6'd6) ||
                    (month_digit1 == 6'd0 && month_digit2 == 6'd4)) begin
                if(date_digit1 == 6'd3 && date_digit2 == 6'd0) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2 + 6'd1;
                    next_date_digit1 = 6'd0;
                    next_date_digit2 = 6'd1;
                end
                
                else if(date_digit1 < 6'd3 && date_digit2 == 6'd9) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = date_digit1 + 6'd1;
                    next_date_digit2 = 6'd0;
                end
                
                else begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = date_digit1;
                    next_date_digit2 = date_digit2 + 6'd1;
                end
            end
            
            //October, August, July, May, March, January
            else if((month_digit1 == 6'd1 && month_digit2 == 6'd0) ||
                    (month_digit1 == 6'd0 && month_digit2 == 6'd8) ||
                    (month_digit1 == 6'd0 && month_digit2 == 6'd7) ||
                    (month_digit1 == 6'd0 && month_digit2 == 6'd5) ||
                    (month_digit1 == 6'd0 && month_digit2 == 6'd3) ||
                    (month_digit1 == 6'd0 && month_digit2 == 6'd1)) begin
                if(date_digit1 == 6'd3 && date_digit2 == 6'd1) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2 + 6'd1;
                    next_date_digit1 = 6'd0;
                    next_date_digit2 = 6'd1;
                end
                
                else if(date_digit1 == 6'd3 && date_digit2 == 6'd0) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = 6'd3;
                    next_date_digit2 = 6'd1;
                end
                
                else if(date_digit1 < 6'd3 && date_digit2 == 6'd9) begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = date_digit1 + 6'd1;
                    next_date_digit2 = 6'd0;
                end
                
                else begin
                    next_year_digit1 = year_digit1;
                    next_year_digit2 = year_digit2;
                    next_month_digit1 = month_digit1;
                    next_month_digit2 = month_digit2;
                    next_date_digit1 = date_digit1;
                    next_date_digit2 = date_digit2 + 6'd1;
                end
            end
            
            else begin
                next_year_digit1 = year_digit1;
                next_year_digit2 = year_digit2;
                next_month_digit1 = month_digit1;
                next_month_digit2 = month_digit2;
                next_date_digit1 = date_digit1;
                next_date_digit2 = date_digit2;            
            end
        end
        else begin
            next_year_digit1 = year_digit1;
            next_year_digit2 = year_digit2;
            next_month_digit1 = month_digit1;
            next_month_digit2 = month_digit2;
            next_date_digit1 = date_digit1;
            next_date_digit2 = date_digit2;
        end
    end                        
    
    assign clock_cnt = (!flag) ? {digit1, digit2, digit3, digit4, digit5, digit6} : {date_digit1, date_digit2, month_digit1, month_digit2, year_digit1, year_digit2};        
    assign year = ((year_digit1 == 12'd5 && year_digit2 == 12'd0) || (year_digit1 < 12'd5)) ? (2000 + (year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1) + year_digit2) : 
                                                                                     (1900 + (year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1 + year_digit1) + year_digit2);
    assign month = (month_digit1 + month_digit1 + month_digit1 + month_digit1 + month_digit1 + month_digit1 + month_digit1 + month_digit1 + month_digit1 + month_digit1) + month_digit2;
    assign day = (date_digit1 + date_digit1 + date_digit1 + date_digit1 + date_digit1 + date_digit1 + date_digit1 + date_digit1 + date_digit1 + date_digit1) + date_digit2;
    assign week = ((year - (month < 3 ? 1 : 0)) + ((year - (month < 3 ? 1 : 0))/4) - ((year - (month < 3 ? 1 : 0))/100) + ((year - (month < 3 ? 1 : 0))/400) + m[month - 1] + day)%7;
        
endmodule