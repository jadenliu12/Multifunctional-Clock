`define INITIAL 4'd0
`define CLOCK 4'd1
`define SHOW_CLOCK 4'd2
`define CHANGE_MODE 4'd3
`define TIMER 4'd4
`define SHOW_TIMER 4'd5
`define ALARM 4'd6
`define SHOW_ALARM 4'd7
`define SHOW_STOPWATCH 4'd8

module alarm(
    input clk,
    input enter_flag,
    input display_1,
    input display_2,
    input display_3,
    input display_4,
    input display_5,
    input display_6,
    input display_7,
    input display_8,
    input display_9,
    input display_0,                
    input [3:0] state,
    input [35:0] clock_cnt,
    input [35:0] alphanum,
    output reg alarm_match,
    output reg [3:0] alarm_set_cnt,
    output wire [3:0] chosen_num,
    output wire [35:0] alarm_cnt    
    );
    
    reg [35:0] alarm_no [0:9];
    reg set [0:9];
    
    initial begin
        set[0] = 0;
        set[1] = 0;
        set[2] = 0;
        set[3] = 0;
        set[4] = 0;
        set[5] = 0;
        set[6] = 0;
        set[7] = 0;
        set[8] = 0;
        set[9] = 0;
        alarm_set_cnt = 0;
    end
    
    reg one = 0;
    reg two = 0;
    reg three = 0;
    reg four = 0;
    reg five = 0;
    reg six = 0;
    reg seven = 0;
    reg eight = 0;
    reg nine = 0;
    reg zero = 0;                
    
    integer i;
    
    wire clkDiv27;
    reg [26:0] num;   
            
    always@(posedge clk)
    begin
        if(num < 100000000-1) 
            num <= num + 1;        
        else
            num <= 0;
    end    
    assign clkDiv27 = (num == 67108864) ? 1'b1 : 1'b0;    
   
    always @(posedge clk) begin
        if(state == `INITIAL) begin
            alarm_no[0] = 0;
            alarm_no[1] = 0;
            alarm_no[2] = 0;
            alarm_no[3] = 0;
            alarm_no[4] = 0;
            alarm_no[5] = 0;
            alarm_no[6] = 0;
            alarm_no[7] = 0;
            alarm_no[8] = 0;
            alarm_no[9] = 0;
            set[0] = 0;
            set[1] = 0;
            set[2] = 0;
            set[3] = 0;
            set[4] = 0;
            set[5] = 0;
            set[6] = 0;
            set[7] = 0;
            set[8] = 0;
            set[9] = 0;
            alarm_match = 0;
            alarm_set_cnt = 0;        
        end    
        else if(state == `ALARM && enter_flag) begin
            if(!set[0]) begin
                alarm_no[0] = alphanum;
                set[0] = 1;
                alarm_match = 0;
                alarm_set_cnt = alarm_set_cnt + 1;
            end
            else if(!set[1]) begin
                alarm_no[1] = alphanum;
                set[1] = 1;
                alarm_match = 0;
                alarm_set_cnt = alarm_set_cnt + 1;
            end
            else if(!set[2]) begin
                alarm_no[2] = alphanum;
                set[2] = 1;
                alarm_match = 0;
                alarm_set_cnt = alarm_set_cnt + 1;
            end
            else if(!set[3]) begin
                alarm_no[3] = alphanum;
                set[3] = 1;
                alarm_match = 0;
                alarm_set_cnt = alarm_set_cnt + 1;
            end
            else if(!set[4]) begin
                alarm_no[4] = alphanum;
                set[4] = 1;
                alarm_match = 0;
                alarm_set_cnt = alarm_set_cnt + 1;
            end
            else if(!set[5]) begin
                alarm_no[5] = alphanum;
                set[5] = 1;
                alarm_match = 0;
                alarm_set_cnt = alarm_set_cnt + 1;
            end
            else if(!set[6]) begin
                alarm_no[6] = alphanum;
                set[6] = 1;
                alarm_match = 0;
                alarm_set_cnt = alarm_set_cnt + 1;
            end
            else if(!set[7]) begin
                alarm_no[7] = alphanum;
                set[7] = 1;
                alarm_match = 0;
                alarm_set_cnt = alarm_set_cnt + 1;
            end
            else if(!set[8]) begin
                alarm_no[8] = alphanum;
                set[8] = 1;
                alarm_match = 0;
                alarm_set_cnt = alarm_set_cnt + 1;
            end
            else if(!set[9]) begin
                alarm_no[9] = alphanum;
                set[9] = 1;
                alarm_match = 0;
                alarm_set_cnt = alarm_set_cnt + 1;
            end
        end
        else if(clkDiv27 && alarm_match) begin
            alarm_match = 0;
            alarm_set_cnt = alarm_set_cnt;
        end
        else if(state > `CLOCK) begin
            if(clock_cnt == alarm_no[0] && set[0]) begin
                alarm_no[0] = 0;
                set[0] = 0;
                alarm_match = 1;
                alarm_set_cnt = alarm_set_cnt - 1;
            end
            if(clock_cnt == alarm_no[1] && set[1]) begin
                alarm_no[1] = 0;
                set[1] = 0;
                alarm_match = 1;
                alarm_set_cnt = alarm_set_cnt - 1;
            end
            if(clock_cnt == alarm_no[2] && set[2]) begin
                alarm_no[2] = 0;
                set[2] = 0;
                alarm_match = 1;
                alarm_set_cnt = alarm_set_cnt - 1;
            end
            if(clock_cnt == alarm_no[3] && set[3]) begin
                alarm_no[3] = 0;
                set[3] = 0;
                alarm_match = 1;
                alarm_set_cnt = alarm_set_cnt - 1;
            end
            if(clock_cnt == alarm_no[4] && set[4]) begin
                alarm_no[4] = 0;
                set[4] = 0;
                alarm_match = 1;
                alarm_set_cnt = alarm_set_cnt - 1;
            end
            if(clock_cnt == alarm_no[5] && set[5]) begin
                alarm_no[5] = 0;
                set[5] = 0;
                alarm_match = 1;
                alarm_set_cnt = alarm_set_cnt - 1;
            end
            if(clock_cnt == alarm_no[6] && set[6]) begin
                alarm_no[6] = 0;
                set[6] = 0;
                alarm_match = 1;
                alarm_set_cnt = alarm_set_cnt - 1;
            end
            if(clock_cnt == alarm_no[7] && set[7]) begin
                alarm_no[7] = 0;
                set[7] = 0;
                alarm_match = 1;
                alarm_set_cnt = alarm_set_cnt - 1;
            end
            if(clock_cnt == alarm_no[8] && set[8]) begin
                alarm_no[8] = 0;
                set[8] = 0;
                alarm_match = 1;
                alarm_set_cnt = alarm_set_cnt - 1;
            end
            if(clock_cnt == alarm_no[9] && set[9]) begin
                alarm_no[9] = 0;
                set[9] = 0;
                alarm_match = 1;
                alarm_set_cnt = alarm_set_cnt - 1;
            end
        end
        else begin
            alarm_match = alarm_match;
            alarm_set_cnt = alarm_set_cnt;        
        end      
    end
    
    always @(posedge clk) begin
        if(state != `SHOW_ALARM)
            one <= 0;
        else if(display_1 && !two && !three && !four && !five && !six && !seven && !eight && !nine && !zero && set[1])
            one <= ~one;
        else
            one <= one;           
    end
    
    always @(posedge clk) begin
        if(state != `SHOW_ALARM)
            two <= 0;
        else if(display_2 && !one && !three && !four && !five && !six && !seven && !eight && !nine && !zero && set[2])
            two <= ~two;
        else
            two <= two;           
    end

    always @(posedge clk) begin
        if(state != `SHOW_ALARM)
            three <= 0;
        else if(display_3 && !one && !two && !four && !five && !six && !seven && !eight && !nine && !zero && set[3])
            three <= ~three;
        else
            three <= three;           
    end
    
    always @(posedge clk) begin
        if(state != `SHOW_ALARM)
            four <= 0;
        else if(display_4 && !one && !two && !three && !five && !six && !seven && !eight && !nine && !zero && set[4])
            four <= ~four;
        else
            four <= four;           
    end
    
    always @(posedge clk) begin
        if(state != `SHOW_ALARM)
            five <= 0;
        else if(display_5 && !one && !two && !three && !four && !six && !seven && !eight && !nine && !zero && set[5])
            five <= ~five;
        else
            five <= five;           
    end

    always @(posedge clk) begin
        if(state != `SHOW_ALARM)
            six <= 0;
        else if(display_6 && !one && !two && !three && !four && !five && !seven && !eight && !nine && !zero && set[6])
            six <= ~six;
        else
            six <= six;           
    end
    
    always @(posedge clk) begin
        if(state != `SHOW_ALARM)
            seven <= 0;
        else if(display_7 && !one && !two && !three && !four && !five && !six && !eight && !nine && !zero && set[7])
            seven <= ~seven;
        else
            seven <= seven;           
    end
    
    always @(posedge clk) begin
        if(state != `SHOW_ALARM)
            eight <= 0;
        else if(display_8 && !one && !two && !three && !four && !five && !six && !seven && !nine && !zero && set[8])
            eight <= ~eight;
        else
            eight <= eight;           
    end

    always @(posedge clk) begin
        if(state != `SHOW_ALARM)
            nine <= 0;
        else if(display_9 && !one && !two && !three && !four && !five && !six && !seven && !eight && !zero && set[9])
            nine <= ~nine;
        else
            nine <= nine;           
    end 
    
    always @(posedge clk) begin
        if(state != `SHOW_ALARM)
            zero <= 0;
        else if(display_0 && !one && !two && !three && !four && !five && !six && !seven && !eight && !nine && set[0])
            zero <= ~zero;
        else
            zero <= zero;           
    end            
    
    assign alarm_cnt = (zero) ? alarm_no[0] :
                       (one) ? alarm_no[1] :
                       (two) ? alarm_no[2] :
                       (three) ? alarm_no[3] :
                       (four) ? alarm_no[4] :
                       (five) ? alarm_no[5] :
                       (six) ? alarm_no[6] :
                       (seven) ? alarm_no[7] :
                       (eight) ? alarm_no[8] :
                       (nine) ? alarm_no[9] : 0;
                       
    assign chosen_num = (zero) ? 0 :
                       (one) ? 1 :
                       (two) ? 2 :
                       (three) ? 3 :
                       (four) ? 4 :
                       (five) ? 5 :
                       (six) ? 6 :
                       (seven) ? 7 :
                       (eight) ? 8 :
                       (nine) ? 9 : 10;                       
        
endmodule
