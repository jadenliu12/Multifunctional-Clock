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
