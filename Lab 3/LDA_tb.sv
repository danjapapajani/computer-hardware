`timescale 1ns/1ns

module LDA_tb();
// Generates a 50MHz clock.
logic clk;
  // Wait 10ns, flip the clock, repeat forever

logic [8:0] dut_SW; 
logic [3:0] dut_KEY;
logic [9:0] dut_LEDR;
logic [8:0] o_x0, o_x1, o_x;
logic [7:0] o_y0, o_y1, o_y;
logic [2:0] o_colour;
	
logic i_load_x, i_load_y, i_load_c, i_go;
logic o_load_x, o_load_y, o_load_c, o_go, o_init, o_update_coords;

assign i_load_x = dut_KEY[0];
assign i_load_y = dut_KEY[1];
assign i_load_c = dut_KEY[2];
assign i_go = dut_KEY[3];


// "input" to the system
logic i_counter_done, o_start;
logic i_swap1_check, i_swap2_check, i_steep_swap_2, o_draw,o_steep, o_check_error, o_local_vars, o_set_up;
logic o_check_x, o_check_steep_x, o_is_it_steep, o_update_vars;

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
	.o_update_coords(o_update_coords),
	.outstate(dut_LEDR[9:0]),
	.done(done)
	
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
	.o_colour(o_colour),
	.done(done)
);

LDA_control init4
(
	.clk(clk),
	.i_start(o_start),
	.i_x0(o_x0),
	.i_y0(o_y0),
	.i_x1(o_x1),
	.i_y1(o_y1),
	.i_counter_done(i_counter_done),
	.i_swap1_check(i_swap1_check),
	.i_swap2_check(i_swap2_check),
	.i_steep_swap_2(i_steep_swap_2),
	.o_draw(o_draw),
	.o_steep(o_steep),
	.o_check_error(o_check_error),
	.o_local_vars(o_local_vars),
	.o_set_up(o_set_up),
	.o_check_x(o_check_x),
	.o_check_steep_x(o_check_steep_x),
	.o_is_it_steep(o_is_it_steep),
	.o_update_vars(o_update_vars),
	.o_done(done),
	.o_reset(reset)
	
);

LDA_datapath init6
(
	.clk(clk),
	.i_x0(o_x0),
	.i_y0(o_y0),
	.i_x1(o_x1),
	.i_y1(o_y1),
	.i_draw(o_draw),
	.i_steep(o_steep),
	.i_check_error(o_check_error),
	.i_local_vars(o_local_vars),
	.i_set_up(o_set_up),
	.i_check_x(o_check_x),
	.i_check_steep_x(o_check_steep_x),
	.i_is_it_steep(o_is_it_steep),
	.i_update_vars(o_update_vars),
	.o_x(o_x),
	.o_y(o_y),
	.o_plot(o_plot),
	.o_swap1_check(i_swap1_check),
	.o_swap2_check(i_swap2_check),
	.o_steep_swap_2(i_steep_swap_2),
	.o_counter_done(i_counter_done),
	.i_reset(reset)
);

vga_bmp vga_bmp_inst
(
	.clk(clk),
	.x(o_x),
	.y(o_y),
	.color(3'b110),
	.plot(o_plot)
);

// assuming we are drawing in a 16 x 16 screen
always 
	begin 
		clk <= 0;
		#25;
		clk <= 1;
		#25;
	end
	
	initial 
	begin
		dut_KEY[3:0] <= 4'b0;
		dut_SW[8:0] <= 8'b0;
		#50;
	
		dut_SW[8:0] <= 9'b1;
		#50;
		dut_KEY[0] <= 1;
		#50;
		
		dut_KEY[0] = 0;
		#50;
		
		dut_SW[8:0] <= 9'b10;
		#50;
		dut_KEY[1] <= 1;
		#50;
		
		dut_KEY[1] = 0;
		#50;
		
		dut_SW[2:0] <= 3'b1;
		#50;
		dut_KEY[2] <= 1;
		#50;
		
		dut_KEY[2] = 0;
		#90;
		
		dut_KEY[3] <= 1;
		#50;
		
		dut_KEY[3] <= 0;
		#50;
		
		dut_KEY[3:0] <= 4'b0;
		#50;
		
		
		
		vga_bmp_inst.write_bmp();
	
	$stop();

	end
endmodule
	
	




















