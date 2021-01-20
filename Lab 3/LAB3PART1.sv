`timescale 1ns/1ns
module tb();

	logic clk;
	//initial clk = 1'b0;     // Clock starts at 0
	//always #10 clk = ~clk;  // Wait 10ns, flip the clock, repeat forever

	logic [8:0] dut_SW; 
	logic [3:0] KEY;
	logic [8:0] o_x0, o_x1;
	logic [7:0] o_y0, o_y1;
	logic [2:0] o_colour;
	
logic i_load_x, i_load_y, i_load_c, i_go;
logic o_load_x, o_load_y, o_load_c, o_go, o_init, o_update_coords;

assign i_load_x = KEY[0];
assign i_load_y = KEY[1];
assign i_load_c = KEY[2];
assign i_go = KEY[3];

	
	//instantiate the module to be tested
UI_control control
(
	.clk(clk),
	.i_load_x(i_load_x),
	.i_load_y(i_load_y),
	.i_load_c(i_load_c),
	.i_go(i_go),
	.o_load_x(o_load_x),
	.o_load_y(o_load_y),
	.o_load_c(o_load_c),
	.o_go(o_go),
	.o_init(o_init),
	.o_update_coords(o_update_coords)
	
);

UI_datapath data
(
	.clk(clk),
	.SW(dut_SW[8:0]),
	.i_load_x(o_load_x),
	.i_load_y(o_load_y),
	.i_load_c(o_load_c),
	.i_go(o_go),
	.i_init(o_init),
	.i_update_coords(o_update_coords),
	.o_start(o_start),
	.o_x0(o_x0),
	.o_y0(o_y0),
	.o_x1(o_x1),
	.o_y1(o_y1),
	.o_colour(o_colour)
);

	
	
	always 
	begin 
		clk <= 0;
		#25;
		clk <= 1;
		#25;
	end
	
	initial 
	begin
		KEY[3:0] = 3'b0;
		dut_SW[8:0] <= 9'b1;
		#50;
		KEY[0] <= 1;
		#50;
		
		KEY[0] = 0;
		#50;
		
		dut_SW[8:0] <= 9'b10;
		#50;
		KEY[1] <= 1;
		#50;
		
		KEY[1] = 0;
		#50;
		
		dut_SW[2:0] <= 3'b1;
		#50;
		KEY[2] <= 1;
		#50;
		
		KEY[2] = 0;
		#50;
		
		KEY[3] <= 1;
		#50;
		
		KEY[3] <= 0;
		#50;		
		
		

		dut_SW[8:0] <= 9'b11;
		#50;
		KEY[0] <= 1;
		#50;
		
		KEY[0] = 0;
		#50;
		
		dut_SW[8:0] <= 9'b10;
		#50;
		KEY[1] <= 1;
		#50;
		
		KEY[1] = 0;
		#50;
		
		dut_SW[2:0] <= 3'b1;
		#50;
		KEY[2] <= 1;
		#50;
		
		KEY[2] = 0;
		#50;
		
		KEY[3] <= 1;
		#50;
		
		KEY[3] <= 0;
		#50;
	end
endmodule

	