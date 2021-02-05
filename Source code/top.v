`define n_one 7'b1111001
`define n_two 7'b0100100
`define n_three 7'b0110000
`define n_four 7'b0011001
`define n_five 7'b0010010
`define n_six 7'b0000010
`define n_seven 7'b1111000
`define n_eight 7'b0000000
`define n_nine 7'b0010000
`define n_zero 7'b1000000

`define one 7'b0000110
`define two 7'b1011011
`define three 7'b1001111
`define four 7'b1100110
`define five 7'b1101101
`define six 7'b1111101
`define seven 7'b0000111
`define eight 7'b1111111
`define nine 7'b1101111
`define zero 7'b0111111

`define alpha_a 7'b1011111
`define alpha_b 7'b1111100
`define alpha_c 7'b1011000
`define alpha_d 7'b1011110
`define alpha_e 7'b1111001
`define alpha_f 7'b1110001
`define alpha_g 7'b0111101
`define alpha_h 7'b1110100
`define alpha_i 7'b0010001
`define alpha_j 7'b0001101
`define alpha_k 7'b1110101
`define alpha_l 7'b0111000
`define alpha_m 7'b1010101
`define alpha_n 7'b1010100
`define alpha_o 7'b1011100
`define alpha_p 7'b1110011
`define alpha_q 7'b1100111
`define alpha_r 7'b1010000
`define alpha_s 7'b0101101
`define alpha_t 7'b1111000
`define alpha_u 7'b0011100
`define alpha_v 7'b0101010
`define alpha_w 7'b1101010
`define alpha_x 7'b0010100
`define alpha_y 7'b1101110
`define alpha_z 7'b0011011

`define INITIAL 4'd0
`define CLOCK 4'd1
`define SHOW_CLOCK 4'd2
`define CHANGE_MODE 4'd3
`define TIMER 4'd4
`define SHOW_TIMER 4'd5
`define ALARM 4'd6
`define SHOW_ALARM 4'd7
`define SHOW_STOPWATCH 4'd8

module top(
    input clk,
    inout PS2_DATA,
    inout PS2_CLK,
    output wire [6:0] LED,
    output wire [5:0] DIGIT,
    output wire [6:0] DISPLAY,
    output reg [3:0] DIGITS,
    output reg [6:0] DISPLAYS,      
    output wire dp,
    output wire sound,
    output wire on
);
    wire clk_div13;
    
    wire [3:0] state;
    wire error;
    
    wire [35:0] alphanum;
    wire [1:0] clk_date_cnt;
    wire enter_flag, esc_flag;
    
    wire [35:0] timer_cnt, timer_rec_cnt;
    wire [1:0] timer_rec_tot, timer_chosen;
    wire play_flag, dis1_flag, dis2_flag, dis3_flag, rec_flag;
    wire timer_set, condition, timer_resume, timer_match;  
    
    wire [35:0] clock_cnt;  
    wire [31:0] week; 
    
    wire [35:0] alarm_cnt;
    wire [3:0] alarm_set_cnt, chosen_num;
    wire dis4_flag, dis5_flag, dis6_flag, dis7_flag, dis8_flag, dis9_flag, dis0_flag;
    wire alarm_match;
    
    wire [35:0] stopw_cnt, stopw_rec_cnt;
    wire [1:0] stopw_rec_tot, stopw_chosen;
    wire stopw_resume;  
    
    wire blink_alarm, blink_timer;
    wire [3:0] flag;
    reg [3:0] out_value;

    clock_divider #(.n(13)) clk13(.clk(clk), .clk_div(clk_div13));
    
    keyboard getkey(.clk(clk), 
                    .error(error),
                    .state(state), 
                    .PS2_DATA(PS2_DATA), 
                    .PS2_CLK(PS2_CLK), 
                    .alphanum(alphanum), 
                    .clk_date_cnt(clk_date_cnt),
                    .enter_flag(enter_flag), 
                    .esc_flag(esc_flag),
                    .play_flag(play_flag),
                    .dis1_flag(dis1_flag),
                    .dis2_flag(dis2_flag),
                    .dis3_flag(dis3_flag),
                    .dis4_flag(dis4_flag),
                    .dis5_flag(dis5_flag),
                    .dis6_flag(dis6_flag),
                    .dis7_flag(dis7_flag),
                    .dis8_flag(dis8_flag),
                    .dis9_flag(dis9_flag),
                    .dis0_flag(dis0_flag),                                                            
                    .rec_flag(rec_flag)                    
                    );                                    
                    
    SevenSegment sevseg(.display(DISPLAY), 
                        .digit(DIGIT), 
                        .dp(dp), 
                        .nums((state == `SHOW_CLOCK) ? clock_cnt :
                              (state == `SHOW_TIMER) ? ((!timer_resume || timer_cnt == 0) ? timer_rec_cnt : timer_cnt) :
                              (state == `SHOW_ALARM) ? alarm_cnt : 
                              (state == `SHOW_STOPWATCH) ? ((!stopw_resume || stopw_cnt == 0) ? stopw_rec_cnt : stopw_cnt) : alphanum), 
                        .clk(clk)
                        );
                        
    keyboard_mode keymode(.clk(clk),
                          .enter_flag(enter_flag),
                          .esc_flag(esc_flag),
                          .timer_set(timer_set),
                          .clk_date_cnt(clk_date_cnt),
                          .alarm_set_cnt(alarm_set_cnt),
                          .alphanum(alphanum),
                          .timer_cnt(timer_cnt),
                          .state(state),
                          .error(error)
                          );     

    clock_24 clkmod(.clk(clk),
                 .enter_flag(enter_flag),
                 .play(play_flag),
                 .clk_date_cnt(clk_date_cnt),
                 .state(state),
                 .alphanum(alphanum),
                 .week(week),
                 .clock_cnt(clock_cnt)
                 );       
                              
    timer timermod(.clk(clk),
                   .condition(condition),
                   .enter_flag(enter_flag), 
                   .play(play_flag),
                   .record(rec_flag),
                   .display_1(dis1_flag),
                   .display_2(dis2_flag),
                   .display_3(dis3_flag),
                   .state(state),
                   .alphanum(alphanum),
                   .timer_resume(timer_resume),
                   .timer_match(timer_match),
                   .timer_set(timer_set),
                   .timer_rec_tot(timer_rec_tot),
                   .timer_cnt(timer_cnt),
                   .timer_chosen(timer_chosen),
                   .timer_rec_cnt(timer_rec_cnt)        
                   );          
                   
    alarm alarmmod(.clk(clk),
                   .enter_flag(enter_flag),
                   .display_1(dis1_flag),
                   .display_2(dis2_flag),
                   .display_3(dis3_flag),
                   .display_4(dis4_flag),
                   .display_5(dis5_flag),
                   .display_6(dis6_flag),
                   .display_7(dis7_flag),
                   .display_8(dis8_flag),
                   .display_9(dis9_flag),
                   .display_0(dis0_flag),
                   .state(state),
                   .clock_cnt(clock_cnt),
                   .alphanum(alphanum),
                   .alarm_match(alarm_match),
                   .alarm_set_cnt(alarm_set_cnt),
                   .chosen_num(chosen_num),
                   .alarm_cnt(alarm_cnt)    
                   );    

    stopwatch stopwmod(.clk(clk),
                       .enter_flag(enter_flag), 
                       .play(play_flag),
                       .record(rec_flag),
                       .display_1(dis1_flag),
                       .display_2(dis2_flag),
                       .display_3(dis3_flag),
                       .state(state),
                       .alphanum(alphanum),
                       .stopw_resume(stopw_resume),
                       .stopw_rec_tot(stopw_rec_tot),
                       .stopw_chosen(stopw_chosen),
                       .stopw_cnt(stopw_cnt),
                       .stopw_rec_cnt(stopw_rec_cnt)        
                       );         
                       
    LED_control ledctrl(.clk(clk),
                        .enter_flag(enter_flag),
                        .timer_resume(timer_resume),
                        .timer_set(timer_set),
                        .alarm_match(alarm_match),
                        .timer_match(timer_match),
                        .week(week),
                        .timer_rec_tot(timer_rec_tot),
                        .stopw_rec_tot(stopw_rec_tot),
                        .alarm_set_cnt(alarm_set_cnt),
                        .chosen_num(chosen_num),
                        .timer_chosen(timer_chosen),
                        .stopw_chosen(stopw_chosen),
                        .state(state),
                        .alphanum(alphanum),
                        .timer_cnt(timer_cnt),
                        .timer_rec_cnt(timer_rec_cnt),
                        .LED(LED),
                        .flag(flag),
                        .blink_alarm(blink_alarm),
                        .blink_timer(blink_timer)
                        ); 
                        
    music musicinst(.clk(clk), 
          .alarm_match(alarm_match),
          .timer_match(timer_match),
          .blink_alarm(blink_alarm),
          .blink_timer(blink_timer),          
          .on(on), 
          .speaker(sound)
          );
                                                                                          
          
    assign condition = timer_set;                                                      
 
    always @(posedge clk_div13) begin        
        case(DIGITS)
            4'b1110: begin         
                out_value = 10;             
                DIGITS = 4'b1101;
            end
            4'b1101: begin     
                out_value = clk_date_cnt;                                
                DIGITS = 4'b1011;
            end
            4'b1011: begin     
                out_value = flag;                                          
                DIGITS = 4'b0111;
            end
            4'b0111: begin      
                out_value = (state == `INITIAL) ? 4'd0 : 
                            (state == `CLOCK) ? 4'd1 : 
                            (state == `SHOW_CLOCK) ? 4'd2 : 
                            (state == `CHANGE_MODE) ? 4'd3 : 
                            (state == `TIMER) ? 4'd4 : 
                            (state == `SHOW_TIMER) ? 4'd5 : 
                            (state == `ALARM) ? 4'd6 : 
                            (state == `SHOW_ALARM) ? 4'd7 : 
                            (state == `SHOW_STOPWATCH) ? 4'd8 : 4'd9;                                                            
                DIGITS = 4'b1110;
            end
            default: begin
                out_value = (state == `INITIAL) ? 4'd0 : 
                            (state == `CLOCK) ? 4'd1 : 
                            (state == `SHOW_CLOCK) ? 4'd2 : 
                            (state == `CHANGE_MODE) ? 4'd3 : 
                            (state == `TIMER) ? 4'd4 : 
                            (state == `SHOW_TIMER) ? 4'd5 : 
                            (state == `ALARM) ? 4'd6 : 
                            (state == `SHOW_ALARM) ? 4'd7 :  
                            (state == `SHOW_STOPWATCH) ? 4'd8 : 4'd9;                                               
                DIGITS = 4'b1110;
            end                                    
        endcase
    end
    
    always @(*) begin
        case(out_value) 
            4'd0: DISPLAYS = `n_zero;
            4'd1: DISPLAYS = `n_one;
            4'd2: DISPLAYS = `n_two;
            4'd3: DISPLAYS = `n_three;
            4'd4: DISPLAYS = `n_four;
            4'd5: DISPLAYS = `n_five;
            4'd6: DISPLAYS = `n_six;
            4'd7: DISPLAYS = `n_seven;
            4'd8: DISPLAYS = `n_eight;
            4'd9: DISPLAYS = `n_nine;
            default: DISPLAYS = 7'b0111111;
        endcase
    end
 
endmodule

module clock_divider(clk, clk_div);   
    parameter n = 26;     
    input clk;   
    output clk_div;   
    
    reg [n-1:0] num;
    wire [n-1:0] next_num;
    
    always@(posedge clk)begin
    	num<=next_num;
    end
    
    assign next_num = num +1;
    assign clk_div = num[n-1];
    
endmodule