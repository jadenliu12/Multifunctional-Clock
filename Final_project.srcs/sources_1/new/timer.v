`define INITIAL 4'd0
`define CLOCK 4'd1
`define SHOW_CLOCK 4'd2
`define CHANGE_MODE 4'd3
`define TIMER 4'd4
`define SHOW_TIMER 4'd5
`define ALARM 4'd6
`define SHOW_ALARM 4'd7
`define SHOW_STOPWATCH 4'd8

module timer(
    input clk,
    input condition,
    input enter_flag,
    input play,
    input record,
    input display_1,
    input display_2,
    input display_3,
    input [3:0] state,
    input [35:0] alphanum,
    output reg timer_resume,    
    output wire timer_set,
    output reg timer_match,
    output wire [1:0] timer_rec_tot,
    output wire [1:0] timer_chosen,
    output wire [35:0] timer_cnt,
    output wire [35:0] timer_rec_cnt   
    );
    
    reg [5:0] digit1, digit2, digit3, digit4, digit5, digit6;
    reg [5:0] next_digit1, next_digit2, next_digit3, next_digit4, next_digit5, next_digit6;
    
    reg [5:0] record1_digit1, record1_digit2, record1_digit3, record1_digit4, record1_digit5, record1_digit6;
    reg [5:0] next_record1_digit1, next_record1_digit2, next_record1_digit3, next_record1_digit4, next_record1_digit5, next_record1_digit6;
    
    reg [5:0] record2_digit1, record2_digit2, record2_digit3, record2_digit4, record2_digit5, record2_digit6;
    reg [5:0] next_record2_digit1, next_record2_digit2, next_record2_digit3, next_record2_digit4, next_record2_digit5, next_record2_digit6;
    
    reg [5:0] record3_digit1, record3_digit2, record3_digit3, record3_digit4, record3_digit5, record3_digit6;
    reg [5:0] next_record3_digit1, next_record3_digit2, next_record3_digit3, next_record3_digit4, next_record3_digit5, next_record3_digit6;
    
    reg r;
    reg one = 0;
    reg two = 0;
    reg three = 0;
    reg recorded1 = 0;
    reg recorded2 = 0;
    reg recorded3 = 0;         

    wire clkDiv27;
    
    reg [26:0] num;      
            
    always@(posedge clk)
    begin
        if(num < 100000000-1) begin
            if(condition && timer_resume)
                num <= num + 1;
            else
                num <= num;                
        end
        else
            num <= 0;
    end    
    assign clkDiv27 = (num == 67108864) ? 1'b1 : 1'b0;       
        
    always @(posedge clk) begin
        if(state == `INITIAL) begin
            {digit1, digit2, digit3, digit4, digit5, digit6} <= 0;
        end
        else if(state == `TIMER && enter_flag) begin
            {digit1, digit2, digit3, digit4, digit5, digit6} <= alphanum;      
        end
        else if(clkDiv27) begin    
            digit1 <= next_digit1;
            digit2 <= next_digit2;
            digit3 <= next_digit3;
            digit4 <= next_digit4;
            digit5 <= next_digit5;
            digit6 <= next_digit6;
        end
        else begin
            digit1 <= digit1;
            digit2 <= digit2;
            digit3 <= digit3;
            digit4 <= digit4;
            digit5 <= digit5;
            digit6 <= digit6;
        end
        
        if(clkDiv27 && {next_digit1, next_digit2, next_digit3, next_digit4, next_digit5, next_digit6} == 0 && timer_set && state > `CLOCK)
            timer_match <= 1;
        else
            timer_match <= 0;            
    end
    
    always @(posedge clk) begin
        if((state == `CHANGE_MODE && alphanum == {6'd14, 6'd17, 6'd35, 6'd12, 6'd13, 6'd0} && enter_flag && !timer_set) || state == `INITIAL) begin
            recorded1 <= 1'b0;
            recorded2 <= 1'b0;
            recorded3 <= 1'b0;        
            
            record1_digit1 <= 0;
            record1_digit2 <= 0;
            record1_digit3 <= 0;
            record1_digit4 <= 0;
            record1_digit5 <= 0;
            record1_digit6 <= 0;       
            
            record2_digit1 <= 0;
            record2_digit2 <= 0;
            record2_digit3 <= 0;
            record2_digit4 <= 0;
            record2_digit5 <= 0;
            record2_digit6 <= 0;  
            
            record3_digit1 <= 0;
            record3_digit2 <= 0;
            record3_digit3 <= 0;
            record3_digit4 <= 0;
            record3_digit5 <= 0;
            record3_digit6 <= 0;                                
        end
        else if(r && !recorded1 && !recorded2 && !recorded3 && timer_cnt != 0 && timer_resume) begin
            recorded1 <= 1'b1;
            record1_digit1 <= digit1;
            record1_digit2 <= digit2;
            record1_digit3 <= digit3;
            record1_digit4 <= digit4;
            record1_digit5 <= digit5;
            record1_digit6 <= digit6;            
        end            
        else if(r && recorded1 && !recorded2 && !recorded3 && timer_cnt != 0 && timer_resume) begin
            recorded2 <= 1'b1;
            record2_digit1 <= digit1;
            record2_digit2 <= digit2;
            record2_digit3 <= digit3;
            record2_digit4 <= digit4;
            record2_digit5 <= digit5;
            record2_digit6 <= digit6;            
        end            
        else if(r && recorded1 && recorded2 && !recorded3 && timer_cnt != 0 && timer_resume) begin
            recorded3 <= 1'b1;           
            record3_digit1 <= digit1;
            record3_digit2 <= digit2;
            record3_digit3 <= digit3;
            record3_digit4 <= digit4;
            record3_digit5 <= digit5;
            record3_digit6 <= digit6;                 
        end
        else begin
            recorded1 <= recorded1;
            recorded2 <= recorded2;
            recorded3 <= recorded3;
        
            record1_digit1 <= record1_digit1;
            record1_digit2 <= record1_digit2;
            record1_digit3 <= record1_digit3;
            record1_digit4 <= record1_digit4;
            record1_digit5 <= record1_digit5;
            record1_digit6 <= record1_digit6;
            
            record2_digit1 <= record2_digit1;
            record2_digit2 <= record2_digit2;
            record2_digit3 <= record2_digit3;
            record2_digit4 <= record2_digit4;
            record2_digit5 <= record2_digit5;
            record2_digit6 <= record2_digit6;
            
            record3_digit1 <= record3_digit1;
            record3_digit2 <= record3_digit2;
            record3_digit3 <= record3_digit3;
            record3_digit4 <= record3_digit4;
            record3_digit5 <= record3_digit5;
            record3_digit6 <= record3_digit6;          
        end    
    end
    
    always @(posedge clk) begin
        if(record && state == `SHOW_TIMER)
            r <= 1;
        else
            r <= 0;           
    end
    
    always @(posedge clk) begin
        if(state != `SHOW_TIMER)
            one <= 0;
        else if(display_1 && !two && !three && recorded1 && (!timer_resume || (state == `SHOW_TIMER && timer_cnt == 0)))
            one <= ~one;
        else
            one <= one;           
    end
    
    always @(posedge clk) begin
        if(state != `SHOW_TIMER)
            two <= 0;
        else if(display_2 && !one && !three && recorded2 && (!timer_resume || (state == `SHOW_TIMER && timer_cnt == 0)))
            two <= ~two;
        else
            two <= two;           
    end

    always @(posedge clk) begin
        if(state != `SHOW_TIMER)
            three <= 0;
        else if(display_3 && !one && !two && recorded3 && (!timer_resume || (state == `SHOW_TIMER && timer_cnt == 0)))
            three <= ~three;
        else
            three <= three;           
    end            
    
    always @(posedge clk) begin
        if(state == `TIMER && enter_flag)
            timer_resume <= 1;
        else if(timer_cnt == 0)
            timer_resume <= 0;           
        else if(play && state == `SHOW_TIMER)
            timer_resume <= ~timer_resume;
        else
            timer_resume <= timer_resume;           
    end        
    
    always @* begin
        if(!timer_resume) begin       
            next_digit1 = digit1;
            next_digit2 = digit2;
            next_digit3 = digit3;
            next_digit4 = digit4;
            next_digit5 = digit5;
            next_digit6 = digit6;
        end                   
        else begin
            if(digit1 == 0) begin
                if(digit2 == 0) begin
                    if(digit3 == 0) begin
                        if(digit4 == 0) begin
                            if(digit5 == 0) begin                             
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = 0;
                                    next_digit5 = 0;
                                    next_digit6 = 0;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = 0;
                                    next_digit5 = 0;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = 0;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = 0;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                        else begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = digit4 - 1;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                    end
                    else begin 
                        if(digit4 == 0) begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = digit3 - 1;
                                    next_digit4 = 9;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                        else begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 - 1;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin 
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                    end
                end
                else begin
                    if(digit3 == 0) begin
                        if(digit4 == 0) begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2 - 1;
                                    next_digit3 = 5;
                                    next_digit4 = 9;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                        else begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 - 1;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                    end
                    else begin
                        if(digit4 == 0) begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3 - 1;
                                    next_digit4 = 9;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                        else begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 - 1;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = 0;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                    end
                end
            end 
            else begin
                if(digit2 == 0) begin
                    if(digit3 == 0) begin
                        if(digit4 == 0) begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1 - 1;
                                    next_digit2 = 9;
                                    next_digit3 = 5;
                                    next_digit4 = 9;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = 0;
                                    next_digit5 = 0;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0)
                                begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = 0;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = 0;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                        else begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = digit4 - 1;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = 0;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                    end
                    else begin
                        if(digit4 == 0) begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = digit3 - 1;
                                    next_digit4 = 9;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                        else begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 - 1;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = 0;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                    end
                end
                else begin
                    if(digit3 == 0) begin
                        if(digit4 == 0) begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2 - 1;
                                    next_digit3 = 5;
                                    next_digit4 = 9;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                        else begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 - 1;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                    end
                    else begin
                        if(digit4 == 0) begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3 - 1;
                                    next_digit4 = 9;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                        else begin
                            if(digit5 == 0) begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 - 1;
                                    next_digit5 = 5;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                            else begin
                                if(digit6 == 0) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 - 1;
                                    next_digit6 = 9;
                                end
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 - 1;
                                end
                            end
                        end
                    end
                end
            end 
        end
    end
   
    assign timer_cnt = {digit1, digit2, digit3, digit4, digit5, digit6};
    assign timer_rec_cnt = (one) ? {record1_digit1, record1_digit2, record1_digit3, record1_digit4, record1_digit5, record1_digit6} : 
                          (two) ? {record2_digit1, record2_digit2, record2_digit3, record2_digit4, record2_digit5, record2_digit6} : 
                          (three) ? {record3_digit1, record3_digit2, record3_digit3, record3_digit4, record3_digit5, record3_digit6} : {digit1, digit2, digit3, digit4, digit5, digit6}; 
    assign timer_set = (timer_cnt == 0) ? 1'b0 : 1'b1;
    assign timer_rec_tot = (recorded3) ? 2'd3 : (recorded2) ? 2'd2 : (recorded1) ? 2'd1 : 2'd0;
    assign timer_chosen = (one) ? 0 :
                       (two) ? 1 :
                       (three) ? 2 : 3;  
endmodule