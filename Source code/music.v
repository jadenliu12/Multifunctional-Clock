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