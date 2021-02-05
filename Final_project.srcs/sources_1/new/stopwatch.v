`define INITIAL 4'd0
`define CLOCK 4'd1
`define SHOW_CLOCK 4'd2
`define CHANGE_MODE 4'd3
`define TIMER 4'd4
`define SHOW_TIMER 4'd5
`define ALARM 4'd6
`define SHOW_ALARM 4'd7
`define SHOW_STOPWATCH 4'd8

module stopwatch(
    input clk,
    input play,    
    input enter_flag,
    input record,
    input display_1,
    input display_2,
    input display_3,
    input [3:0] state,
    input [35:0] alphanum,
    output reg stopw_resume,        
    output wire [1:0] stopw_rec_tot, 
    output wire [1:0] stopw_chosen,   
    output wire [35:0] stopw_cnt,
    output wire [35:0] stopw_rec_cnt
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
    reg recorded1 = 1'b0;
    reg recorded2 = 1'b0;
    reg recorded3 = 1'b0;
    
    wire clkDiv25;
    
    reg [24:0] num;   
            
    always@(posedge clk) begin
        if(stopw_resume) begin
            if(num <= 1005000)
                num <= num + 1;
            else
                num <= 0;
        end           
        else
            num <= num;          
    end    
    assign clkDiv25 = (num == 1005000) ? 1'b1 : 1'b0; 
    
    always@(posedge clk) begin
        if(state == `CHANGE_MODE && alphanum == {6'd21, 6'd14, 6'd18, 6'd19, 6'd11, 6'd0} && enter_flag) begin
            {digit1, digit2, digit3, digit4, digit5, digit6} <= 0;
        end
        else if(clkDiv25) begin    
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
    end
    
    always @(posedge clk) begin
        if((state == `CHANGE_MODE && alphanum == {6'd21, 6'd14, 6'd18, 6'd19, 6'd11, 6'd0} && enter_flag) || state == `INITIAL) begin
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
        else if(r && !recorded1 && !recorded2 && !recorded3 && stopw_resume) begin
            recorded1 <= 1'b1;
            record1_digit1 <= digit1;
            record1_digit2 <= digit2;
            record1_digit3 <= digit3;
            record1_digit4 <= digit4;
            record1_digit5 <= digit5;
            record1_digit6 <= digit6;            
        end            
        else if(r && recorded1 && !recorded2 && !recorded3 && stopw_resume) begin
            recorded2 <= 1'b1;
            record2_digit1 <= digit1;
            record2_digit2 <= digit2;
            record2_digit3 <= digit3;
            record2_digit4 <= digit4;
            record2_digit5 <= digit5;
            record2_digit6 <= digit6;            
        end            
        else if(r && recorded1 && recorded2 && !recorded3 && stopw_resume) begin
            recorded3 <= 1'b1;           
            record3_digit1 <= digit1;
            record3_digit2 <= digit2;
            record3_digit3 <= digit3;
            record3_digit4 <= digit4;
            record3_digit5 <= digit5;
            record3_digit6 <= digit6;                 
        end
        else begin
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
        if(record && state == `SHOW_STOPWATCH)
            r <= 1;
        else
            r <= 0;           
    end
    
    always @(posedge clk) begin
        if(stopw_resume)
            one <= 0;
        else if(display_1 && !two && !three && !stopw_resume && state == `SHOW_STOPWATCH && recorded1)
            one <= ~one;
        else
            one <= one;           
    end
    
    always @(posedge clk) begin
        if(stopw_resume)
            two <= 0;
        else if(display_2 && !one && !three && !stopw_resume && state == `SHOW_STOPWATCH && recorded2)
            two <= ~two;
        else
            two <= two;           
    end

    always @(posedge clk) begin
        if(stopw_resume)
            three <= 0;
        else if(display_3 && !one && !two && !stopw_resume && state == `SHOW_STOPWATCH && recorded3)
            three <= ~three;
        else
            three <= three;           
    end            
    
    always @(posedge clk) begin
        if(state == `CHANGE_MODE && alphanum == {6'd21, 6'd14, 6'd18, 6'd19, 6'd11, 6'd0} && enter_flag)
            stopw_resume <= 1;
        else if(play && state == `SHOW_STOPWATCH)
            stopw_resume <= ~stopw_resume;
        else
            stopw_resume <= stopw_resume;           
    end        
    
    always @(*) begin
        if(!stopw_resume) begin
            next_digit1 = digit1;
            next_digit2 = digit2;
            next_digit3 = digit3;
            next_digit4 = digit4;
            next_digit5 = digit5;
            next_digit6 = digit6;
        end    
        else begin
            if(digit1 == 6'd2) begin
                if(digit2 == 6'd3) begin
                    if(digit3 == 6'd5) begin
                        if(digit4 == 6'd9) begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = 6'd5;
                                    next_digit4 = 6'd9;
                                    next_digit5 = 6'd9;
                                    next_digit6 = 6'd9;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = 6'd5;
                                    next_digit4 = 6'd9;
                                    next_digit5 = 6'd9;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = 6'd5;
                                    next_digit4 = 6'd9;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = 6'd5;
                                    next_digit4 = 6'd9;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                        end
                        
                        else begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = 6'd5;
                                    next_digit4 = digit4 + 6'd1;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = 6'd5;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = 6'd5;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
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
                    
                    else begin
                        if(digit4 == 6'd9) begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = digit3 + 6'd1;
                                    next_digit4 = 6'd0;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                        end
                        
                        else begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 + 6'd1;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = 6'd3;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
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
                
                else begin
                    if(digit3 == 6'd5) begin
                        if(digit4 == 6'd9) begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2 + 6'd1;
                                    next_digit3 = 6'd0;
                                    next_digit4 = 6'd0;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                        end
                        
                        else begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 + 6'd1;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
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
                    
                    else begin
                        if(digit4 == 6'd9) begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3 + 6'd1;
                                    next_digit4 = 6'd0;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                        end
                        
                        else begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 + 6'd1;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = 6'd2;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
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
            
            else begin
                if(digit2 == 6'd3) begin
                    if(digit3 == 6'd5) begin
                        if(digit4 == 6'd9) begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1 + 6'd1;
                                    next_digit2 = 6'd0;
                                    next_digit3 = 6'd0;
                                    next_digit4 = 6'd0;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                        end
                        
                        else begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 + 6'd1;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
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
                    
                    else begin
                        if(digit4 == 6'd9) begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3 + 6'd1;
                                    next_digit4 = 6'd0;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                        end
                        
                        else begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 + 6'd1;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
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
                
                else begin
                    if(digit3 == 6'd5) begin
                        if(digit4 == 6'd9) begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2 + 6'd1;
                                    next_digit3 = 6'd0;
                                    next_digit4 = 6'd0;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                        end
                        
                        else begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 + 6'd1;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
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
                    
                     else begin
                        if(digit4 == 6'd9) begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3 + 6'd1;
                                    next_digit4 = 6'd0;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                        end
                        
                        else begin
                            if(digit5 == 6'd9) begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4 + 6'd1;
                                    next_digit5 = 6'd0;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5;
                                    next_digit6 = digit6 + 6'd1;
                                end
                            end
                            
                            else begin
                                if(digit6 == 6'd9) begin
                                    next_digit1 = digit1;
                                    next_digit2 = digit2;
                                    next_digit3 = digit3;
                                    next_digit4 = digit4;
                                    next_digit5 = digit5 + 6'd1;
                                    next_digit6 = 6'd0;
                                end
                                
                                else begin
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
            end
        end
    end            
    
    
    assign stopw_cnt = {digit1, digit2, digit3, digit4, digit5, digit6};
    assign stopw_rec_cnt = (one) ? {record1_digit1, record1_digit2, record1_digit3, record1_digit4, record1_digit5, record1_digit6} : 
                          (two) ? {record2_digit1, record2_digit2, record2_digit3, record2_digit4, record2_digit5, record2_digit6} : 
                          (three) ? {record3_digit1, record3_digit2, record3_digit3, record3_digit4, record3_digit5, record3_digit6} : {digit1, digit2, digit3, digit4, digit5, digit6};   
    assign stopw_rec_tot = (recorded3) ? 2'd3 : (recorded2) ? 2'd2 : (recorded1) ? 2'd1 : 2'd0;                    
    assign stopw_chosen = (one) ? 0 :
                       (two) ? 1 :
                       (three) ? 2 : 3;             
endmodule