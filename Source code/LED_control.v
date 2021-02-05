`define INITIAL 4'd0
`define CLOCK 4'd1
`define SHOW_CLOCK 4'd2
`define CHANGE_MODE 4'd3
`define TIMER 4'd4
`define SHOW_TIMER 4'd5
`define ALARM 4'd6
`define SHOW_ALARM 4'd7
`define SHOW_STOPWATCH 4'd8

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

