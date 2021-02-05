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

`define INITIAL 4'd0
`define CLOCK 4'd1
`define SHOW_CLOCK 4'd2
`define CHANGE_MODE 4'd3
`define TIMER 4'd4
`define SHOW_TIMER 4'd5
`define ALARM 4'd6
`define SHOW_ALARM 4'd7
`define SHOW_STOPWATCH 4'd8

module keyboard(
    input clk,
    input error,
    input [3:0] state,
    inout PS2_DATA,
    inout PS2_CLK,
    output reg [35:0] alphanum,     
    output reg [1:0] clk_date_cnt,       
    output reg enter_flag,
    output reg esc_flag,
    output reg play_flag,
    output reg dis1_flag,
    output reg dis2_flag,
    output reg dis3_flag,
    output reg dis4_flag,
    output reg dis5_flag,
    output reg dis6_flag,
    output reg dis7_flag,
    output reg dis8_flag,
    output reg dis9_flag,
    output reg dis0_flag,            
    output reg rec_flag
    );
    
	parameter [8:0] KEY_CODES [0:48] = {
		9'b0_0100_0101,	// 0 => 45
		9'b0_0001_0110,	// 1 => 16
		9'b0_0001_1110,	// 2 => 1E
		9'b0_0010_0110,	// 3 => 26
		9'b0_0010_0101,	// 4 => 25
		9'b0_0010_1110,	// 5 => 2E
		9'b0_0011_0110,	// 6 => 36
		9'b0_0011_1101,	// 7 => 3D
		9'b0_0011_1110,	// 8 => 3E
		9'b0_0100_0110,	// 9 => 46
		
		9'b0_0111_0000, // right_0 => 70
		9'b0_0110_1001, // right_1 => 69
		9'b0_0111_0010, // right_2 => 72
		9'b0_0111_1010, // right_3 => 7A
		9'b0_0110_1011, // right_4 => 6B
		9'b0_0111_0011, // right_5 => 73
		9'b0_0111_0100, // right_6 => 74
		9'b0_0110_1100, // right_7 => 6C
		9'b0_0111_0101, // right_8 => 75
		9'b0_0111_1101, // right_9 => 7D
		
		9'b0_0001_0101, // Q => 15
		9'b0_0001_1101, // W => 1D
		9'b0_0010_0100, // E => 24
		9'b0_0010_1101, // R => 2D
		9'b0_0010_1100, // T => 2C
		9'b0_0011_0101, // Y => 35
		9'b0_0011_1100, // U => 3C
		9'b0_0100_0011, // I => 43
		9'b0_0100_0100, // O => 44
		9'b0_0100_1101, // P => 4D
		
		9'b0_0001_1100, // A => 1C
		9'b0_0001_1011, // S => 1B
		9'b0_0010_0011, // D => 23
		9'b0_0010_1011, // F => 2B
		9'b0_0011_0100, // G => 34
		9'b0_0011_0011, // H => 33
		9'b0_0011_1011, // J => 3B
		9'b0_0100_0010, // K => 42
		9'b0_0100_1011, // L => 4B
		
		9'b0_0001_1010, // Z => 1A
		9'b0_0010_0010, // X => 22
		9'b0_0010_0001, // C => 21
		9'b0_0010_1010, // V => 2A
		9'b0_0011_0010, // B => 32
		9'b0_0011_0001, // N => 31
		9'b0_0011_1010, // M => 3A
		
        9'b0_0101_1010, // ENTER => 5A	
        9'b0_0111_0110, // ESC => 76		
        9'b0_0010_1001 // SPACE => 29		
	};   	
	
	wire [511:0] key_down;
	wire [8:0] last_change;
	wire been_ready;	
	
	reg [5:0] alpanum_key;
	reg change_flag;
	
	reg [2:0] input_cnt;
	reg [3:0] prev_state;
	
	KeyboardDecoder key_de (
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(been_ready),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(1'b0),
		.clk(clk)
	);	
	
	always @(posedge clk) begin
	   prev_state <= state;
	end

	always @(posedge clk) begin
        if(error) begin
            alphanum <= 0;
            input_cnt <= 0;
        end
        else begin
            alphanum <= alphanum;
            if(state == `INITIAL) begin
                alphanum <= 0;
                input_cnt <= 0;
            end
            else if(prev_state != state) begin
                if(prev_state == `CHANGE_MODE || prev_state == `SHOW_CLOCK) begin
                    alphanum <= 0;
                    input_cnt <= 0;
                end                    
                else begin 
                    alphanum <= alphanum;   
                    input_cnt <= input_cnt;                
                end                    
            end
            else if(input_cnt < 6 && (state == `CLOCK || state == `TIMER || state == `ALARM || state == `CHANGE_MODE)) begin
                if(been_ready && key_down[last_change] == 1'b1) begin
                    if(alpanum_key != 6'd39 && alpanum_key != 6'd38 && alpanum_key != 6'd37 && alpanum_key != 6'd36) begin
                        if(input_cnt == 0) begin
                            if(state == `CLOCK) begin
                                if(clk_date_cnt == 0) begin
                                    if(alpanum_key <= 6'd2) begin
                                        alphanum <= {alpanum_key, alphanum[29:0]};
                                        input_cnt <= input_cnt + 1;
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                        
                                end
                                else begin
                                    if(alpanum_key <= 6'd3) begin
                                        alphanum <= {alpanum_key, alphanum[29:0]};
                                        input_cnt <= input_cnt + 1;  
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                                                  
                                end
                            end
                            else if(state == `TIMER || state == `ALARM) begin
                                if(alpanum_key <= 6'd2) begin
                                    alphanum <= {alpanum_key, alphanum[29:0]};
                                    input_cnt <= input_cnt + 1;
                                end
                                else begin
                                    alphanum <= alphanum;
                                    input_cnt <= input_cnt;                                        
                                end                                 
                            end
                            else if(state == `CHANGE_MODE) begin
                                alphanum <= {alpanum_key, alphanum[29:0]};
                                input_cnt <= input_cnt + 1;
                            end
                           else begin
                                alphanum <= alphanum;
                                input_cnt <= input_cnt;
                            end                                                                                                                
                        end                        
                        else if(input_cnt == 1) begin
                            if(state == `CLOCK) begin
                                if(clk_date_cnt == 0) begin
                                    if((alphanum[35:30] <= 6'd1 && alpanum_key <= 6'd9) || (alphanum[35:30] == 6'd2 && alpanum_key <= 6'd3)) begin
                                        alphanum <= {alphanum[35:30], alpanum_key, alphanum[23:0]};
                                        input_cnt <= input_cnt + 1;
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                        
                                end
                                else begin
                                    if((alphanum[35:30] <= 6'd2 && alpanum_key <= 6'd9) || (alphanum[35:30] == 6'd3 && alpanum_key <= 6'd1)) begin
                                        alphanum <= {alphanum[35:30], alpanum_key, alphanum[23:0]};
                                        input_cnt <= input_cnt + 1;  
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                                                  
                                end
                            end
                            else if(state == `TIMER || state == `ALARM) begin
                                if((alphanum[35:30] <= 6'd1 && alpanum_key <= 6'd9) || (alphanum[35:30] == 6'd2 && alpanum_key <= 6'd3)) begin
                                    alphanum <= {alphanum[35:30], alpanum_key, alphanum[23:0]};
                                    input_cnt <= input_cnt + 1;
                                end
                                else begin
                                    alphanum <= alphanum;
                                    input_cnt <= input_cnt;                                        
                                end                                 
                            end
                            else if(state == `CHANGE_MODE) begin
                                alphanum <= {alphanum[35:30], alpanum_key, alphanum[23:0]};
                                input_cnt <= input_cnt + 1;
                            end
                           else begin
                                alphanum <= alphanum;
                                input_cnt <= input_cnt;
                            end
                        end
                        else if(input_cnt == 2) begin
                            if(state == `CLOCK) begin
                                if(clk_date_cnt == 0) begin
                                    if(alpanum_key <= 6'd5) begin
                                        alphanum <= {alphanum[35:24], alpanum_key, alphanum[17:0]};
                                        input_cnt <= input_cnt + 1;
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                        
                                end
                                else begin
                                    if(alpanum_key <= 6'd1) begin
                                        alphanum <= {alphanum[35:24], alpanum_key, alphanum[17:0]};
                                        input_cnt <= input_cnt + 1;  
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                                                  
                                end
                            end
                            else if(state == `TIMER || state == `ALARM) begin
                                if(alpanum_key <= 6'd5) begin
                                    alphanum <= {alphanum[35:24], alpanum_key, alphanum[17:0]};
                                    input_cnt <= input_cnt + 1;
                                end
                                else begin
                                    alphanum <= alphanum;
                                    input_cnt <= input_cnt;                                        
                                end                                 
                            end
                            else if(state == `CHANGE_MODE) begin
                                alphanum <= {alphanum[35:24], alpanum_key, alphanum[17:0]};
                                input_cnt <= input_cnt + 1;
                            end
                           else begin
                                alphanum <= alphanum;
                                input_cnt <= input_cnt;
                            end 
                        end
                        else if(input_cnt == 3) begin
                            if(state == `CLOCK) begin
                                if(clk_date_cnt == 0) begin
                                    if(alphanum[23:18] <= 6'd5 && alpanum_key <= 6'd9) begin
                                        alphanum <= {alphanum[35:18], alpanum_key, alphanum[11:0]};
                                        input_cnt <= input_cnt + 1;
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                        
                                end
                                else begin
                                    if(alphanum[23:18] <= 6'd1 && alpanum_key <= 6'd2) begin
                                        alphanum <= {alphanum[35:18], alpanum_key, alphanum[11:0]};
                                        input_cnt <= input_cnt + 1;  
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                                                  
                                end
                            end
                            else if(state == `TIMER || state == `ALARM) begin
                                if(alphanum[23:18] <= 6'd5 && alpanum_key <= 6'd9) begin
                                    alphanum <= {alphanum[35:18], alpanum_key, alphanum[11:0]};
                                    input_cnt <= input_cnt + 1;
                                end
                                else begin
                                    alphanum <= alphanum;
                                    input_cnt <= input_cnt;                                        
                                end                                 
                            end
                            else if(state == `CHANGE_MODE) begin
                                alphanum <= {alphanum[35:18], alpanum_key, alphanum[11:0]};
                                input_cnt <= input_cnt + 1;
                            end
                           else begin
                                alphanum <= alphanum;
                                input_cnt <= input_cnt;
                            end
                        end
                        else if(input_cnt == 4) begin
                            if(state == `CLOCK) begin
                                if(clk_date_cnt == 0) begin
                                    if(alpanum_key <= 6'd5) begin
                                        alphanum <= {alphanum[35:12], alpanum_key, alphanum[5:0]};
                                        input_cnt <= input_cnt + 1;
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                        
                                end
                                else begin
                                    if(alpanum_key <= 6'd9) begin
                                        alphanum <= {alphanum[35:12], alpanum_key, alphanum[5:0]};
                                        input_cnt <= input_cnt + 1;  
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                                                  
                                end
                            end
                            else if(state == `TIMER || state == `ALARM) begin
                                if(alpanum_key <= 6'd5) begin
                                    alphanum <= {alphanum[35:12], alpanum_key, alphanum[5:0]};
                                    input_cnt <= input_cnt + 1;
                                end
                                else begin
                                    alphanum <= alphanum;
                                    input_cnt <= input_cnt;                                        
                                end                                 
                            end
                            else if(state == `CHANGE_MODE) begin
                                alphanum <= {alphanum[35:12], alpanum_key, alphanum[5:0]};
                                input_cnt <= input_cnt + 1;
                            end
                           else begin
                                alphanum <= alphanum;
                                input_cnt <= input_cnt;
                            end
                        end
                        else if(input_cnt == 5) begin
                            if(state == `CLOCK) begin
                                if(clk_date_cnt == 0) begin
                                    if(alphanum[11:6] <= 6'd5 && alpanum_key <= 6'd9) begin
                                        alphanum <= {alphanum[35:6], alpanum_key};
                                        input_cnt <= input_cnt + 1;
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                        
                                end
                                else begin
                                    if(alphanum[11:6] <= 6'd9 && alpanum_key <= 6'd9) begin
                                        alphanum <= {alphanum[35:6], alpanum_key};
                                        input_cnt <= input_cnt + 1;  
                                    end
                                    else begin
                                        alphanum <= alphanum;
                                        input_cnt <= input_cnt;                                        
                                    end                                                                  
                                end
                            end
                            else if(state == `TIMER || state == `ALARM) begin
                                if(alphanum[11:6] <= 6'd5 && alpanum_key <= 6'd9) begin
                                    alphanum <= {alphanum[35:6], alpanum_key};
                                    input_cnt <= input_cnt + 1;
                                end
                                else begin
                                    alphanum <= alphanum;
                                    input_cnt <= input_cnt;                                        
                                end                                 
                            end
                            else if(state == `CHANGE_MODE) begin
                                alphanum <= {alphanum[35:6], alpanum_key};
                                input_cnt <= input_cnt + 1;
                            end
                           else begin
                                alphanum <= alphanum;
                                input_cnt <= input_cnt;
                            end
                        end
                        else begin
                            alphanum <= alphanum;
                            input_cnt <= input_cnt;
                        end
                    end
                    else if(alpanum_key == 6'd37) begin
                        alphanum <= 0;
                        input_cnt <= 0;
                    end
                end      
            end
            else if(alpanum_key == 6'd37 && (state == `CLOCK || state == `TIMER || state == `ALARM || state == `CHANGE_MODE)) begin
                alphanum <= 0;
                input_cnt <= 0;                
            end
            else begin
                alphanum <= alphanum;
                input_cnt <= input_cnt;   
            end
        end
	end
	
	always @(posedge clk) begin
        if(state == `INITIAL) begin
            enter_flag <= 0;
            clk_date_cnt <= 0;
        end	    
        else if((input_cnt == 5 || input_cnt == 6) && state == `CHANGE_MODE) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd36) begin
                    enter_flag <= 1;
                    clk_date_cnt <= clk_date_cnt;
                end
            end
            else begin
                enter_flag <= 0;
                clk_date_cnt <= clk_date_cnt;
            end
        end
        else if(input_cnt == 6 && state == `CLOCK) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd36) begin
                    clk_date_cnt <= clk_date_cnt + 1;
                    enter_flag <= 1;
                end
            end
            else begin
                clk_date_cnt <= clk_date_cnt;
                enter_flag <= 0;
            end
        end        
        else if(input_cnt == 6 && (state == `TIMER || state == `ALARM)) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd36) begin
                    enter_flag <= 1;
                    clk_date_cnt <= clk_date_cnt;
                end
            end
            else begin
                enter_flag <= 0;
                clk_date_cnt <= clk_date_cnt;
            end
        end        
        else begin
            enter_flag <= 0;
            clk_date_cnt <= clk_date_cnt;
        end
	end	
	
	always @(posedge clk) begin
        if(been_ready && key_down[last_change] == 1'b1) begin
            if(alpanum_key == 6'd37) begin
                esc_flag <= 1;
            end
        end
        else begin
            esc_flag <= 0;
        end
	end		
	
	always @(posedge clk) begin
	   if(state == `SHOW_TIMER || state == `SHOW_STOPWATCH || state == `SHOW_CLOCK) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd38) begin
                    play_flag <= 1;
                end
            end	
            else begin
                play_flag <= 0;
            end   
	   end
	   else begin
	       play_flag <= 0;
	   end
	end
	
	always @(posedge clk) begin
	   if(state == `SHOW_TIMER || state == `SHOW_ALARM || state == `SHOW_STOPWATCH) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd1) begin
                    dis1_flag <= 1;
                end
            end	 
            else begin
                dis1_flag <= 0;
            end  
	   end
	   else begin
	       dis1_flag <= 0;
	   end
	end
	
	always @(posedge clk) begin
	   if(state == `SHOW_TIMER || state == `SHOW_ALARM || state == `SHOW_STOPWATCH) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd2) begin
                    dis2_flag <= 1;
                end
            end	
            else begin
                dis2_flag <= 0;
            end               
	   end
	   else begin
	       dis2_flag <= 0;
	   end
	end
	
	always @(posedge clk) begin
	   if(state == `SHOW_TIMER || state == `SHOW_ALARM || state == `SHOW_STOPWATCH) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd3) begin
                    dis3_flag <= 1;
                end
            end
            else begin
                dis3_flag <= 0;
            end             	   
	   end
	   else begin
	       dis3_flag <= 0;
	   end
	end		
	
	always @(posedge clk) begin
	   if(state == `SHOW_ALARM) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd4) begin
                    dis4_flag <= 1;
                end
            end	 
            else begin
                dis4_flag <= 0;
            end  
	   end
	   else begin
	       dis4_flag <= 0;
	   end
	end
	
	always @(posedge clk) begin
	   if(state == `SHOW_ALARM) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd5) begin
                    dis5_flag <= 1;
                end
            end	
            else begin
                dis5_flag <= 0;
            end               
	   end
	   else begin
	       dis5_flag <= 0;
	   end
	end
	
	always @(posedge clk) begin
	   if(state == `SHOW_ALARM) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd6) begin
                    dis6_flag <= 1;
                end
            end
            else begin
                dis6_flag <= 0;
            end             	   
	   end
	   else begin
	       dis6_flag <= 0;
	   end
	end
	
	always @(posedge clk) begin
	   if(state == `SHOW_ALARM) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd7) begin
                    dis7_flag <= 1;
                end
            end	 
            else begin
                dis7_flag <= 0;
            end  
	   end
	   else begin
	       dis7_flag <= 0;
	   end
	end
	
	always @(posedge clk) begin
	   if(state == `SHOW_ALARM) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd8) begin
                    dis8_flag <= 1;
                end
            end	
            else begin
                dis8_flag <= 0;
            end               
	   end
	   else begin
	       dis8_flag <= 0;
	   end
	end
	
	always @(posedge clk) begin
	   if(state == `SHOW_ALARM) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd9) begin
                    dis9_flag <= 1;
                end
            end
            else begin
                dis9_flag <= 0;
            end             	   
	   end
	   else begin
	       dis9_flag <= 0;
	   end
	end		
	
	always @(posedge clk) begin
	   if(state == `SHOW_ALARM) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd0) begin
                    dis0_flag <= 1;
                end
            end
            else begin
                dis0_flag <= 0;
            end             	   
	   end
	   else begin
	       dis0_flag <= 0;
	   end
	end
	
	always @(posedge clk) begin
	   if(state == `SHOW_TIMER || state == `SHOW_STOPWATCH) begin
            if(been_ready && key_down[last_change] == 1'b1) begin
                if(alpanum_key == 6'd13) begin
                    rec_flag <= 1;
                end
            end
            else begin
                rec_flag <= 0;
            end             	   
	   end
	   else begin
	       rec_flag <= 0;
	   end
	end		
	
	always @ (*) begin
		case (last_change)
			KEY_CODES[00] : alpanum_key = 6'd0;
			KEY_CODES[01] : alpanum_key = 6'd1;
			KEY_CODES[02] : alpanum_key = 6'd2;
			KEY_CODES[03] : alpanum_key = 6'd3;
			KEY_CODES[04] : alpanum_key = 6'd4;
			KEY_CODES[05] : alpanum_key = 6'd5;
			KEY_CODES[06] : alpanum_key = 6'd6;
			KEY_CODES[07] : alpanum_key = 6'd7;
			KEY_CODES[08] : alpanum_key = 6'd8;
			KEY_CODES[09] : alpanum_key = 6'd9;
			KEY_CODES[10] : alpanum_key = 6'd0;
			KEY_CODES[11] : alpanum_key = 6'd1;
			KEY_CODES[12] : alpanum_key = 6'd2;
			KEY_CODES[13] : alpanum_key = 6'd3;
			KEY_CODES[14] : alpanum_key = 6'd4;
			KEY_CODES[15] : alpanum_key = 6'd5;
			KEY_CODES[16] : alpanum_key = 6'd6;
			KEY_CODES[17] : alpanum_key = 6'd7;
			KEY_CODES[18] : alpanum_key = 6'd8;
			KEY_CODES[19] : alpanum_key = 6'd9;
			KEY_CODES[20] : alpanum_key = 6'd10;
			KEY_CODES[21] : alpanum_key = 6'd11;
			KEY_CODES[22] : alpanum_key = 6'd12;
			KEY_CODES[23] : alpanum_key = 6'd13;
			KEY_CODES[24] : alpanum_key = 6'd14;
			KEY_CODES[25] : alpanum_key = 6'd15;
			KEY_CODES[26] : alpanum_key = 6'd16;
			KEY_CODES[27] : alpanum_key = 6'd17;
			KEY_CODES[28] : alpanum_key = 6'd18;
			KEY_CODES[29] : alpanum_key = 6'd19;
			KEY_CODES[30] : alpanum_key = 6'd20;
			KEY_CODES[31] : alpanum_key = 6'd21;
			KEY_CODES[32] : alpanum_key = 6'd22;
			KEY_CODES[33] : alpanum_key = 6'd23;
			KEY_CODES[34] : alpanum_key = 6'd24;
			KEY_CODES[35] : alpanum_key = 6'd25;
			KEY_CODES[36] : alpanum_key = 6'd26;
			KEY_CODES[37] : alpanum_key = 6'd27;
			KEY_CODES[38] : alpanum_key = 6'd28;
			KEY_CODES[39] : alpanum_key = 6'd29;		
			KEY_CODES[40] : alpanum_key = 6'd30;
			KEY_CODES[41] : alpanum_key = 6'd31;
			KEY_CODES[42] : alpanum_key = 6'd32;
			KEY_CODES[43] : alpanum_key = 6'd33;
			KEY_CODES[44] : alpanum_key = 6'd34;
			KEY_CODES[45] : alpanum_key = 6'd35;
			KEY_CODES[46] : alpanum_key = 6'd36;
			KEY_CODES[47] : alpanum_key = 6'd37;
			KEY_CODES[48] : alpanum_key = 6'd38;
			default : alpanum_key = 6'd39; 		            
		endcase
	end	
	    
endmodule

module KeyboardDecoder(
	output reg [511:0] key_down,
	output wire [8:0] last_change,
	output reg key_valid,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk
    );
    
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
	parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
    reg [9:0] key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state;
    reg been_ready, been_extend, been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    
    wire [511:0] key_decode = 1 << last_change;
    assign last_change = {key[9], key[7:0]};
    
    KeyboardCtrl_0 inst (
		.key_in(key_in),
		.is_extend(is_extend),
		.is_break(is_break),
		.valid(valid),
		.err(err),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	
	OnePulse op (
		.signal_single_pulse(pulse_been_ready),
		.signal(been_ready),
		.clock(clk)
	);
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		state <= INIT;
    		been_ready  <= 1'b0;
    		been_extend <= 1'b0;
    		been_break  <= 1'b0;
    		key <= 10'b0_0_0000_0000;
    	end else begin
    		state <= state;
			been_ready  <= been_ready;
			been_extend <= (is_extend) ? 1'b1 : been_extend;
			been_break  <= (is_break ) ? 1'b1 : been_break;
			key <= key;
    		case (state)
    			INIT : begin
    					if (key_in == IS_INIT) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready  <= 1'b0;
							been_extend <= 1'b0;
							been_break  <= 1'b0;
							key <= 10'b0_0_0000_0000;
    					end else begin
    						state <= INIT;
    					end
    				end
    			WAIT_FOR_SIGNAL : begin
    					if (valid == 0) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready <= 1'b0;
    					end else begin
    						state <= GET_SIGNAL_DOWN;
    					end
    				end
    			GET_SIGNAL_DOWN : begin
						state <= WAIT_RELEASE;
						key <= {been_extend, been_break, key_in};
						been_ready  <= 1'b1;
    				end
    			WAIT_RELEASE : begin
    					if (valid == 1) begin
    						state <= WAIT_RELEASE;
    					end else begin
    						state <= WAIT_FOR_SIGNAL;
    						been_extend <= 1'b0;
    						been_break  <= 1'b0;
    					end
    				end
    			default : begin
    					state <= INIT;
						been_ready  <= 1'b0;
						been_extend <= 1'b0;
						been_break  <= 1'b0;
						key <= 10'b0_0_0000_0000;
    				end
    		endcase
    	end
    end
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		key_valid <= 1'b0;
    		key_down <= 511'b0;
    	end else if (key_decode[last_change] && pulse_been_ready) begin
    		key_valid <= 1'b1;
    		if (key[8] == 0) begin
    			key_down <= key_down | key_decode;
    		end else begin
    			key_down <= key_down & (~key_decode);
    		end
    	end else begin
    		key_valid <= 1'b0;
			key_down <= key_down;
    	end
    end

endmodule

module OnePulse (
	output reg signal_single_pulse,
	input wire signal,
	input wire clock
	);
	
	reg signal_delay;

	always @(posedge clock) begin
		if (signal == 1'b1 & signal_delay == 1'b0)
		  signal_single_pulse <= 1'b1;
		else
		  signal_single_pulse <= 1'b0;

		signal_delay <= signal;
	end
endmodule

module SevenSegment(
	output reg [6:0] display,
	output reg [5:0] digit,
	output reg dp,
	input wire [35:0] nums,
	input wire clk
    );
    
    reg [15:0] clk_divider;
    reg [5:0] display_num;
    
    always @ (posedge clk) begin
        clk_divider <= clk_divider + 15'b1;
    end
    
    always @ (posedge clk_divider[15]) begin
        case (digit)
            6'b111110 : begin
                    display_num <= nums[11:6];
                    dp = 0;
                    digit <= 6'b111101;
                end
            6'b111101 : begin
                    display_num <= nums[17:12];
                    dp = 1;
                    digit <= 6'b111011;
                end
            6'b111011 : begin
                    display_num <= nums[23:18];
                    dp = 0;
                    digit <= 6'b110111;
                end
            6'b110111 : begin
                    display_num <= nums[29:24];
                    dp = 1;
                    digit <= 6'b101111;
                end
            6'b101111 : begin
                    display_num <= nums[35:30];
                    dp = 0;
                    digit <= 6'b011111;
                end
            6'b011111 : begin
                    display_num <= nums[5:0];
                    dp = 0;
                    digit <= 6'b111110;
                end                                
            default : begin
                    display_num <= nums[5:0];
                    dp = 0;
                    digit <= 6'b111110;
                end				
        endcase
    end        
            
    always @ (*) begin
    	case (display_num)
    		0 : display = `zero;
			1 : display = `one;                                                
			2 : display = `two;                                                 
			3 : display = `three;                                              
			4 : display = `four;                                                
			5 : display = `five;                                                
			6 : display = `six; 
			7 : display = `seven;
			8 : display = `eight;
			9 : display = `nine;
    		10 : display = `alpha_q;
			11 : display = `alpha_w;                                                
			12 : display = `alpha_e;                                                 
			13 : display = `alpha_r;                                              
			14 : display = `alpha_t;                                                
			15 : display = `alpha_y;                                                
			16 : display = `alpha_u; 
			17 : display = `alpha_i; 
			18 : display = `alpha_o;
			19 : display = `alpha_p;
    		20 : display = `alpha_a;
			21 : display = `alpha_s;                                       
			22 : display = `alpha_d;                                                
			23 : display = `alpha_f;                                              
			24 : display = `alpha_g;                                                
			25 : display = `alpha_h;                                                
			26 : display = `alpha_j; 
			27 : display = `alpha_k; 
			28 : display = `alpha_l; 
			29 : display = `alpha_z; 
    		30 : display = `alpha_x; 
			31 : display = `alpha_c;                                                 
			32 : display = `alpha_v;                                                 
			33 : display = `alpha_b;                                              
			34 : display = `alpha_n;                                                
			35 : display = `alpha_m;                                                											
			default : display = 7'b1000000;
    	endcase
    end
    
endmodule

module keyboard_mode(
    input clk,
    input enter_flag,
    input esc_flag,
    input timer_set,
    input [1:0] clk_date_cnt,
    input [3:0] alarm_set_cnt,
    input [35:0] alphanum,
    input [35:0] timer_cnt,
    output reg [3:0] state,
    output reg error
    );     
	
    reg [3:0] next_state;
    reg next_error;
	
	always @(posedge clk) begin
	   state <= next_state;
	   error <= next_error;
	end
	
	always @* begin
        case(state)
            `INITIAL: begin
                next_state = (alphanum == 0) ? `CLOCK : `INITIAL;
                next_error = 0;
            end
            `CLOCK: begin
                next_state = (enter_flag && clk_date_cnt == 2) ? `SHOW_CLOCK : `CLOCK;
                next_error = (enter_flag && next_state == `CLOCK) ? 1 : 0;
            end
            `SHOW_CLOCK: begin
                next_state = (esc_flag) ? `CHANGE_MODE : `SHOW_CLOCK;
                next_error = 0;
            end
            `CHANGE_MODE: begin
                next_state = (!enter_flag) ? `CHANGE_MODE : (alphanum == {6'd14, 6'd17, 6'd35, 6'd12, 6'd13, 6'd0}) 
                                           ? ((timer_set) ? `SHOW_TIMER : `TIMER) : (alphanum == {6'd20, 6'd28, 6'd20, 6'd13, 6'd35, 6'd0}) 
                                           ? `ALARM : (alphanum == {6'd21, 6'd14, 6'd18, 6'd19, 6'd11, 6'd0}) 
                                           ? `SHOW_STOPWATCH : (alphanum == {6'd13, 6'd12, 6'd21, 6'd12, 6'd14, 6'd0}) 
                                           ? `INITIAL : (alphanum == {6'd31, 6'd28, 6'd18, 6'd31, 6'd27, 6'd0})
                                           ? `SHOW_CLOCK : `CHANGE_MODE;
                next_error = (enter_flag && next_state == `CHANGE_MODE) ? 1 : 0;                                            
            end
            `TIMER: begin
                next_state = (enter_flag) ? `SHOW_TIMER : `TIMER;
                next_error = (enter_flag && next_state == `TIMER) ? 1 : 0;
            end
            `SHOW_TIMER: begin
                next_state = ((timer_cnt == 0 && timer_set) || esc_flag) ? `SHOW_CLOCK : `SHOW_TIMER;
                next_error = 0;
            end
            `ALARM: begin
                next_state = (alarm_set_cnt == 10 || esc_flag) ? `SHOW_ALARM : `ALARM;
                next_error = (enter_flag && next_state == `ALARM) ? 1 : 0;
            end
            `SHOW_ALARM: begin
                next_state = (esc_flag) ? `SHOW_CLOCK : `SHOW_ALARM;
                next_error = 0;
            end
            `SHOW_STOPWATCH: begin
                next_state = (esc_flag) ? `SHOW_CLOCK : `SHOW_STOPWATCH;          
                next_error = 0;  
            end            
            default: begin
                next_state = `INITIAL;
                next_error = 0;
            end
        endcase	   
	end 
	  
endmodule

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

module LED_control(
    input clk,
    input enter_flag,
    input timer_set,
    input timer_resume,
    input alarm_match,
    input timer_match,
    input [31:0] week,
    input [1:0] timer_rec_tot,
    input [1:0] stopw_rec_tot,
    input [3:0] alarm_set_cnt,
    input [3:0] chosen_num,
    input [1:0] timer_chosen,
    input [1:0] stopw_chosen,
    input [3:0] state,
    input [35:0] alphanum,
    input [35:0] timer_cnt, 
    input [35:0] timer_rec_cnt,
    output reg [6:0] LED,
    output reg [3:0] flag,
    output reg blink_alarm,
    output reg blink_timer
    );
    
    wire clkDiv27, blink_alarm_flag, blink_timer_flag;
    reg [26:0] num, blink_num_alarm, blink_num_timer;
    reg [3:0] blink_cnt_alarm, blink_cnt_timer;
    //reg blink_alarm, blink_timer;
    
    reg [6:0] next_LED;
    
    reg [3:0] prev_state;
    
    reg dir, next_dir;
       
            
    always@(posedge clk)
    begin
        if(num < 100000000-1) begin
            if(timer_resume)
                num <= num + 1;
            else
                num <= num;                
        end
        else
            num <= 0;
    end    
    assign clkDiv27 = (num == 67108864) ? 1'b1 : 1'b0;
    
    always@(posedge clk)
    begin
        if(blink_num_alarm < 100000000-1 && (alarm_match || blink_alarm)) begin
            blink_num_alarm <= blink_num_alarm + 1;             
        end
        else
            blink_num_alarm <= 0;
    end    
    assign blink_alarm_flag = (blink_num_alarm == 67108864) ? 1'b1 : 1'b0;     
    
    always @(posedge clk) begin
        if(blink_alarm_flag) begin
            blink_cnt_alarm <= blink_cnt_alarm + 1;
        end
        else if(!blink_alarm) begin
            blink_cnt_alarm <= 0;
        end
        else begin
            blink_cnt_alarm <= blink_cnt_alarm;
        end
    end
    
    always@(posedge clk)
    begin
        if(blink_num_timer < 100000000-1 && (timer_match || blink_timer)) begin
            blink_num_timer <= blink_num_timer + 1;             
        end
        else
            blink_num_timer <= 0;
    end    
    assign blink_timer_flag = (blink_num_timer == 67108864) ? 1'b1 : 1'b0;     
    
    always @(posedge clk) begin
        if(blink_timer_flag) begin
            blink_cnt_timer <= blink_cnt_timer + 1;
        end
        else if(!blink_timer) begin
            blink_cnt_timer <= 0;
        end
        else begin
            blink_cnt_timer <= blink_cnt_timer;
        end
    end    
    
	always @(posedge clk) begin
	   prev_state <= state;
	end 
	
	always @(posedge clk) begin
	   if(alarm_match) begin
	       blink_alarm <= 1;
	   end
	   else if(blink_cnt_alarm == 6) begin
	       blink_alarm <= 0;
	   end
	   else begin
	       blink_alarm <= blink_alarm;
	   end
	end 
	
	always @(posedge clk) begin
	   if(timer_match) begin
	       blink_timer <= 1;
	   end
	   else if(blink_cnt_timer == 6) begin
	       blink_timer <= 0;
	   end
	   else begin
	       blink_timer <= blink_timer;
	   end
	end 	    

    always @(posedge clk) begin
        if((alarm_match || timer_match) && state > `CLOCK) begin
            if(alarm_match)
                {LED[6], LED[4], LED[2], LED[0]} <= 4'b1111;            
            else
                {LED[6], LED[4], LED[2], LED[0]} <= 4'd0;
            
            if(timer_match)
                {LED[5], LED[3], LED[1]} <= 3'b111;            
            else
                {LED[5], LED[3], LED[1]} <= 3'd0;
                            
            dir <= 0;
            flag <= 0;            
        end      
        else if((blink_alarm || blink_timer) && state > `CLOCK) begin
            if(blink_alarm && blink_alarm_flag)
                {LED[6], LED[4], LED[2], LED[0]} <= ~{LED[6], LED[4], LED[2], LED[0]};                
            else
                {LED[6], LED[4], LED[2], LED[0]} <= {LED[6], LED[4], LED[2], LED[0]};
                
            if(blink_timer && blink_timer_flag)  
                {LED[5], LED[3], LED[1]} <= ~{LED[5], LED[3], LED[1]};
            else
                {LED[5], LED[3], LED[1]} <= {LED[5], LED[3], LED[1]};                                                     
            
            dir <= 0;
            flag <= 1;
        end
        else if(state == `CHANGE_MODE && alphanum == {6'd14, 6'd17, 6'd35, 6'd12, 6'd13, 6'd0} && enter_flag && timer_set) begin
            if(timer_rec_tot == 3)
                LED <= {4'b0001, 3'b111};
            else if(timer_rec_tot == 2)
                LED <= {4'b0000, 3'b111};
            else if(timer_rec_tot == 1)
                LED <= {4'b0000, 3'b011};
            else
                LED <= 7'b0000001;   
            dir <= 0;  
            flag <= 2;   
        end
        else if(state == `CHANGE_MODE && alphanum == {6'd21, 6'd14, 6'd18, 6'd19, 6'd11, 6'd0} && enter_flag) begin
            if(stopw_rec_tot == 3)
                LED <= {3'b111, 4'b0000};
            else if(stopw_rec_tot == 2)
                LED <= {3'b110, 4'b0000};
            else if(stopw_rec_tot == 1)
                LED <= {3'b100, 4'b0000};
            else
                LED <= 7'b0000000;   
            dir <= 0;   
            flag <= 3;  
        end
        else if(state == `CHANGE_MODE && alphanum == {6'd20, 6'd28, 6'd20, 6'd13, 6'd35, 6'd0} && enter_flag && alarm_set_cnt == 10) begin
            if(alarm_set_cnt == 1) 
                LED <= 7'b0000001;
            else if(alarm_set_cnt == 2) 
                LED <= 7'b0000011;
            else if(alarm_set_cnt == 3) 
                LED <= 7'b0000101;
            else if(alarm_set_cnt == 4) 
                LED <= 7'b0000111;
            else if(alarm_set_cnt == 5) 
                LED <= 7'b0010101;
            else if(alarm_set_cnt == 6) 
                LED <= 7'b0010111;
            else if(alarm_set_cnt == 7) 
                LED <= 7'b1010101;
            else if(alarm_set_cnt == 8) 
                LED <= 7'b1010111;
            else if(alarm_set_cnt == 9) 
                LED <= 7'b1011111;    
            else if(alarm_set_cnt == 10) 
                LED <= 7'b1111111;     
            else
                LED <= 0; 
            dir <= 0;  
            flag <= 4;                                                                                                                                                                                   
        end      
        else if(state == `CHANGE_MODE) begin
            LED <= 0;
            dir <= 0;
            flag <= 13;
        end          
        else if(state == `SHOW_CLOCK) begin
            if(week == 0)
                LED <= 7'b1000000;
            else if(week == 1)
                LED <= 7'b0000001;
            else if(week == 2)
                LED <= 7'b0000010;
            else if(week == 3)
                LED <= 7'b0000100;
            else if(week == 4)
                LED <= 7'b0001000;
            else if(week == 5)
                LED <= 7'b0010000;
            else if(week == 6)
                LED <= 7'b0100000;
            else
                LED <= 7'b0000000;                            
            dir <= 0; 
            flag <= 5;               
        end
        else if(state == `TIMER && enter_flag) begin
            if(timer_rec_tot == 3)
                LED <= {4'b0001, 3'b111};
            else if(timer_rec_tot == 2)
                LED <= {4'b0000, 3'b111};
            else if(timer_rec_tot == 1)
                LED <= {4'b0000, 3'b011};
            else
                LED <= 7'b0000001;   
            dir <= 0;    
            flag <= 6; 
        end
        else if(state == `ALARM) begin
            if(alarm_set_cnt == 1) 
                LED <= 7'b0000001;
            else if(alarm_set_cnt == 2) 
                LED <= 7'b0000011;
            else if(alarm_set_cnt == 3) 
                LED <= 7'b0000101;
            else if(alarm_set_cnt == 4) 
                LED <= 7'b0000111;
            else if(alarm_set_cnt == 5) 
                LED <= 7'b0010101;
            else if(alarm_set_cnt == 6) 
                LED <= 7'b0010111;
            else if(alarm_set_cnt == 7) 
                LED <= 7'b1010101;
            else if(alarm_set_cnt == 8) 
                LED <= 7'b1010111;
            else if(alarm_set_cnt == 9) 
                LED <= 7'b1011111;    
            else if(alarm_set_cnt == 10) 
                LED <= 7'b1111111;     
            else
                LED <= 0; 
            dir <= 0;  
            flag <= 7;
        end  
        else if(state == `SHOW_TIMER && !timer_resume) begin
            if(timer_chosen == 0)
                LED <= {4'b0000, 3'b001};
            else if(timer_chosen == 1)
                LED <= {4'b0000, 3'b010};
            else if(timer_chosen == 2)
                LED <= {4'b0000, 3'b100};
            else begin
                if(timer_rec_tot == 3)
                    LED <= {4'b0000, 3'b111};
                else if(timer_rec_tot == 2)
                    LED <= {4'b0000, 3'b011};
                else if(timer_rec_tot == 1)
                    LED <= {4'b0000, 3'b001};
                else
                    LED <= 7'b0000000;                
            end                                
                            
            dir <= dir; 
            flag <= 8;                                                                                                               
        end              
        else if((clkDiv27 && state == `SHOW_TIMER) || (state == `SHOW_STOPWATCH) || (state == `SHOW_ALARM)) begin
            LED <= next_LED;
            dir <= next_dir;
            flag <= 9;
        end
        else if(prev_state != state) begin
            if(prev_state == `SHOW_TIMER || prev_state == `SHOW_STOPWATCH || prev_state == `SHOW_ALARM || prev_state == `SHOW_CLOCK) begin
                LED <= 0;
                dir <= 0;
            end
            else begin
                LED <= LED;
                dir <= dir;                
            end
            flag <= 10;
        end                  
        else begin
            LED <= LED;
            dir <= dir;
            flag <= 11;
        end          
    end
    
    always @* begin
        if(state == `SHOW_TIMER) begin
            if(timer_resume && timer_cnt != 0) begin
                if(timer_rec_tot == 3) begin
                    if(LED == 7'b0000111) begin
                        next_LED = 7'b0001111;
                        next_dir = 0;
                    end
                    else if(LED[3]) begin
                        next_dir = 0;
                        next_LED[6:4] = LED[5:3];
                        next_LED[3] = LED[6];
                        next_LED[2:0] = 3'b111;    
                    end
                    else if(LED[6]) begin
                        next_dir = 1;
                        next_LED[5:3] = LED[6:4];
                        next_LED[6] = LED[3];
                        next_LED[2:0] = 3'b111;
                    end
                    else begin
                        if(!dir) begin
                            next_LED[6:3] = {LED[5:3], 1'b0};
                            next_LED[2:0] = 3'b111;
                            next_dir = dir; 
                        end
                        else begin
                            next_LED[5:3] = LED[6:4];
                            next_LED[6] = LED[3];
                            next_LED[2:0] = 3'b111;  
                            next_dir = dir;                  
                        end
                    end                                
                end
                else if(timer_rec_tot == 2) begin
                    if(LED == 7'b0000011) begin
                        next_LED = 7'b0000111;
                        next_dir = 0;
                    end
                    else if(LED[2]) begin
                        next_dir = 0;
                        next_LED[6:3] = LED[5:2];
                        next_LED[2] = LED[6];
                        next_LED[1:0] = 2'b11;    
                    end
                    else if(LED[6]) begin
                        next_dir = 1;
                        next_LED[5:2] = LED[6:3];
                        next_LED[6] = LED[2];
                        next_LED[1:0] = 2'b11;
                    end
                    else begin
                        if(!dir) begin
                            next_LED[6:2] = {LED[5:2], 1'b0};
                            next_LED[1:0] = 2'b11;
                            next_dir = dir;
                        end
                        else begin
                            next_LED[5:2] = LED[6:3];
                            next_LED[6] = LED[2];
                            next_LED[1:0] = 2'b11;      
                            next_dir = dir;              
                        end
                    end            
                end
                else if(timer_rec_tot == 1) begin
                    if(LED == 7'b0000001) begin
                        next_LED = 7'b0000011;
                        next_dir = 0;
                    end
                    else if(LED[1]) begin
                        next_dir = 0;
                        next_LED[6:2] = LED[5:1];
                        next_LED[1] = LED[6];
                        next_LED[0] = 1'b1;    
                    end
                    else if(LED[6]) begin
                        next_dir = 1;
                        next_LED[5:1] = LED[6:2];
                        next_LED[6] = LED[1];
                        next_LED[0] = 1'b1;
                    end
                    else begin
                        if(!dir) begin
                            next_LED[6:1] = {LED[5:1], 1'b0};
                            next_LED[0] = 1'b1;
                            next_dir = dir;
                        end
                        else begin
                            next_LED[5:1] = LED[6:2];
                            next_LED[6] = LED[1];
                            next_LED[0] = 1'b1;     
                            next_dir = dir;               
                        end
                    end            
                end
                else begin
                    if(LED[0]) begin
                        next_dir = 0;
                        next_LED[6:1] = LED[5:0];
                        next_LED[0] = LED[6];   
                    end
                    else if(LED[6]) begin
                        next_dir = 1;
                        next_LED[5:0] = LED[6:1];
                        next_LED[6] = LED[0];
                    end
                    else begin
                        if(!dir) begin
                            next_LED[6:0] = {LED[5:0], 1'b0};
                            next_dir = dir;
                        end
                        else begin
                            next_LED[5:0] = LED[6:1];
                            next_LED[6] = LED[0];
                            next_dir = dir;
                        end
                    end            
                end
            end
            else begin
                next_LED = LED;
                next_dir = dir;                
            end           
        end   
        else if(state == `SHOW_STOPWATCH) begin
            if(stopw_rec_tot == 3)
                next_LED = {3'b111, 4'b0000};
            else if(stopw_rec_tot == 2)
                next_LED = {3'b110, 4'b0000};
            else if(stopw_rec_tot == 1)
                next_LED = {3'b100, 4'b0000};
            else
                next_LED = 7'b0000000;  
                
            if(stopw_chosen == 0)
                next_LED = {3'b100, 4'b0000};
            else if(stopw_chosen == 1)
                next_LED = {3'b010, 4'b0000};
            else if(stopw_chosen == 2)
                next_LED = {3'b001, 4'b0000};
            else
                next_LED = next_LED;    
                            
            next_dir = dir;             
        end
        else if(state == `SHOW_ALARM) begin     
            if(alarm_set_cnt == 1) 
                next_LED = 7'b0000001;
            else if(alarm_set_cnt == 2) 
                next_LED = 7'b0000011;
            else if(alarm_set_cnt == 3) 
                next_LED = 7'b0000101;
            else if(alarm_set_cnt == 4) 
                next_LED = 7'b0000111;
            else if(alarm_set_cnt == 5) 
                next_LED = 7'b0010101;
            else if(alarm_set_cnt == 6) 
                next_LED = 7'b0010111;
            else if(alarm_set_cnt == 7) 
                next_LED = 7'b1010101;
            else if(alarm_set_cnt == 8) 
                next_LED = 7'b1010111;
            else if(alarm_set_cnt == 9) 
                next_LED = 7'b1011111;    
            else if(alarm_set_cnt == 10) 
                next_LED = 7'b1111111;     
            else
                next_LED = 0;        
                
            next_dir = dir;                
        end             
        else begin
            next_LED = LED;
            next_dir = dir;
        end               
    end

    
endmodule

module music(
    input clk, 
    input alarm_match,
    input timer_match,
    input blink_alarm,
    input blink_timer,     
    output wire on, 
    output wire speaker
    );

    assign on = (alarm_match || timer_match || blink_alarm || blink_timer) ? 1'b0 : 1'b1;
    
    reg [15:0] counter;
    always @(posedge clk) counter <= counter+1;
    
    assign speaker = (on) ? counter[15] : 1'b0;
    
endmodule