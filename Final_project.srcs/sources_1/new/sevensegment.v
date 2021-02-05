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


