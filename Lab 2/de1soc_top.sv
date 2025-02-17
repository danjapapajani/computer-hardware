module de1soc_top 
(
	// These are the board inputs/outputs required for all the ECE342 labs.
	// Each lab can use the subset it needs -- unused pins will be ignored.
	
    // Clock pins
    input                     CLOCK_50,

    // Seven Segment Displays
    output      [6:0]         HEX0,
    output      [6:0]         HEX1,
    output      [6:0]         HEX2,
    output      [6:0]         HEX3,
    output      [6:0]         HEX4,
    output      [6:0]         HEX5,

    // Pushbuttons
    input       [3:0]         KEY,

    // LEDs
    output      [9:0]         LEDR,

    // Slider Switches
    input       [9:0]         SW,

    // VGA
    output      [7:0]         VGA_B,
    output                    VGA_BLANK_N,
    output                    VGA_CLK,
    output      [7:0]         VGA_G,
    output                    VGA_HS,
    output      [7:0]         VGA_R,
    output                    VGA_SYNC_N,
    output                    VGA_VS
);

	wire clk = CLOCK_50;
	logic [7:0] i_x;
	logic [7:0] i_y;
	logic [15:0] o_final_product;
	wire enable = SW[9];
	
	
	always@(posedge clk)
		begin 
			if(enable) 
				i_x[7:0] <= SW[7:0];
			else if (!enable)
				i_y[7:0] <= SW[7:0];
		end	
		
		
	mult M1
	(
		.i_m(i_x),
		.i_q(i_y),
		.o_product(o_final_product)
	);
		
	hex_decoder hexdec0
	(
		.hex_digit(o_final_product[3:0]),
		.segments(HEX0)
	);
	
	hex_decoder hexdec1
	(
		.hex_digit(o_final_product[7:4]),
		.segments(HEX1)
	);
	
	
	hex_decoder hexdec2
	(
		.hex_digit(o_final_product[11:8]),
		.segments(HEX2)
	);
	
	hex_decoder hexdec3
	(
		.hex_digit(o_final_product[15:12]),
		.segments(HEX3)
	);
		
		
	assign HEX4 = '1;
	assign HEX5 = '1;

endmodule