`define INITIAL 4'd0
`define CLOCK 4'd1
`define SHOW_CLOCK 4'd2
`define CHANGE_MODE 4'd3
`define TIMER 4'd4
`define SHOW_TIMER 4'd5
`define ALARM 4'd6
`define SHOW_ALARM 4'd7
`define SHOW_STOPWATCH 4'd8

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
