module LDA
(
	input clk,
	input i_start,
	input logic [8:0] i_x0,
	input logic [7:0] i_y0,
	input logic [8:0] i_x1,
	input logic [7:0] i_y1,
	output [8:0] o_x,
	output [7:0] o_y,
	output o_plot,
	output logic o_done
);

logic i_counter_done;
logic i_swap1_check, i_swap2_check, i_steep_swap_2, o_draw,o_steep, o_check_error, o_local_vars, o_set_up;
logic o_check_x, o_check_steep_x, o_is_it_steep, o_update_vars,i_reset;
	
	
LDA_control init0
(
	.clk(clk),
	.i_start(i_start),
	.i_x0(i_x0),
	.i_y0(i_y0),
	.i_x1(i_x1),
	.i_y1(i_y1),
	.i_counter_done(i_counter_done),
	.i_swap1_check(i_swap1_check),
	.i_swap2_check(i_swap2_check),
	.i_steep_swap_2(i_steep_swap_2),
	.o_reset(i_reset),
	.o_draw(o_draw),
	.o_steep(o_steep),
	.o_check_error(o_check_error),
	.o_local_vars(o_local_vars),
	.o_set_up(o_set_up),
	.o_check_x(o_check_x),
	.o_check_steep_x(o_check_steep_x),
	.o_is_it_steep(o_is_it_steep),
	.o_update_vars(o_update_vars),
	.o_done(o_done)
	
);

LDA_datapath init1
(
	.clk(clk),
	.i_x0(i_x0),
	.i_y0(i_y0),
	.i_x1(i_x1),
	.i_y1(i_y1),
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
	.i_reset(i_reset)
);

endmodule

//**************************************
//*                                    *
//*          DATAPATH MODULE           *
//*                                    *
//**************************************
module LDA_datapath
(
	input clk,
	input [8:0] i_x0,
	input [7:0] i_y0,
	input [8:0] i_x1,
	input [7:0] i_y1,
	input i_draw,
	input i_steep,
	input i_check_error,
	input i_local_vars,
	input i_set_up,
	input i_check_x,
	input i_check_steep_x,
	input i_is_it_steep,
	input i_update_vars,
	input i_reset,
	output logic [8:0] o_x,
	output logic [7:0] o_y,
	output logic o_plot,
	output logic o_swap1_check,
	output logic o_swap2_check,
	output logic o_steep_swap_2,
	output logic o_counter_done,
	output logic o_done
);

logic [8:0] deltax, deltax_current, deltax_abs, x_final, i_x0_current, i_x1_current, x;
logic signed [8:0] error;
logic [7:0] deltay, deltay_current, deltay_abs, y, i_y0_current, i_y1_current;
logic signed [7:0] ystep;
logic steep, x_switcheroo;

assign o_counter_done = x > i_x1_current;
always_ff @ (posedge clk)begin
	if(i_is_it_steep) begin
	
		if(i_y1 > i_y0)
			deltay_abs = i_y1 - i_y0;
		else
			deltay_abs = i_y0 - i_y1;
			
		if(i_x1 > i_x0)
			deltax_abs = i_x1 - i_x0;
		else
			deltax_abs = i_x0 - i_x1;
			
		o_swap2_check = i_x0 > i_x1;
		o_swap1_check = deltay_abs > deltax_abs;
		

	end
	
	if(i_steep) begin //swap x and y 
		i_x0_current <= i_y0;
		i_y0_current <= i_x0;
		
		i_x1_current <= i_y1;
		i_y1_current <= i_x1;
		
		steep = 1'b1; 

	end
	
	if (i_check_steep_x) begin 
		o_steep_swap_2 = i_x0_current > i_x1_current;
	end 
	
	if(i_check_x) begin 
		if(steep) begin 
			i_x0_current <= i_x1_current;
			i_x1_current <= i_x0_current;
			
			i_y0_current <= i_y1_current;
			i_y1_current <= i_y0_current;
		end
		
		else begin
			i_x0_current <= i_x1;
			i_x1_current <= i_x0;
			
			i_y0_current <= i_y1;
			i_y1_current <= i_y0;
		end
		
		x_switcheroo = 1'b1;
	end 
	
	if((~steep) & (~x_switcheroo)) begin
		i_x0_current <= i_x0;
		i_x1_current <= i_x1;
		i_y0_current <= i_y0;
		i_y1_current <= i_y1;
    end

	if(i_reset) begin
		steep = 1'b0;
		x_switcheroo = 1'b0;
	end

	if(i_local_vars) begin 
		deltax_current = i_x1_current - i_x0_current;
		
		if (i_y1_current > i_y0_current)
			deltay_current = i_y1_current - i_y0_current;
		else 
			deltay_current = i_y0_current - i_y1_current;
		
		if (i_y0_current < i_y1_current) 
			ystep = 8'd1;
		else 
			ystep = -8'd1;
	end 
	
	if(i_draw) begin
		if(steep) begin
			o_x = y;
			o_y = x;
			o_plot = 1'b1;
		end
		else begin
			o_x = x;
			o_y = y;
			o_plot = 1'b1;
		end
		
		//error <= error + deltay_abs;
	end
	else if(i_set_up)begin
		error = -1*(deltax_current >> 1);
		error[8] = 1'b1;
		
		x = i_x0_current;
		y = i_y0_current;
		o_plot=1'b1;
	end
	
	else if(i_check_error) begin
		error = error + deltay_current;
		o_plot = 1'b0;
	end
	
	else if(i_update_vars) begin
		o_plot = 1'b0;
		x = x + 9'd1;
		
		if(error > 0) begin
			y = y + ystep;
			error = error - deltax_current;
		end
	end
	else if(i_reset)
		o_plot = 1'b0;
	
end
endmodule




//**************************************
//*                                    *
//*      LDA CONTROLPATH MODULE        *
//*                                    *
//**************************************
module LDA_control
(
	input clk,
	input i_start,
	input [8:0] i_x0,
	input [7:0] i_y0,
	input [8:0] i_x1,
	input [7:0] i_y1,
	input i_counter_done,
	input i_swap1_check,
	input i_swap2_check,
	input i_steep_swap_2,
	output logic o_draw,
	output logic o_steep,
	output logic o_check_error,
	output logic o_local_vars,
	output logic o_set_up,
	output logic o_check_x,
	output logic o_check_steep_x,
	output logic o_is_it_steep,
	output logic o_update_vars,
	output logic o_reset,
	output logic o_done
	
);


enum int unsigned
{
	S_START,
	S_STEEP,
	S_OPTIONS,
	S_SWAP_1,
	S_SWAP_2,
	S_LOCAL_VARS,
	S_DRAW,
	S_CHECK_ERROR,
	S_UPDATE_VARS,
	S_CHECK_X_STEEP,
	S_DELTAS,
	S_CHECK_DONE,
	S_MORE_OPTIONS,
	S_SET_UP,
	S_DELAY
	
} state, nextstate;

always_ff @ (posedge clk) begin

	state <= nextstate;
	
end 

always_comb begin
	
	nextstate = state;
	o_is_it_steep = 1'b0;
	o_check_error = 1'b0;
	o_local_vars = 1'b0;
	o_update_vars = 1'b0;
	o_draw = 1'b0;
	o_check_steep_x = 1'b0;
	o_check_x = 1'b0;
	o_steep = 1'b0;
	o_set_up = 1'b0;
	o_reset = 1'b0;
	o_done = 1'b0;
	
	case (state)
		
		S_START: begin
			if(i_start) begin
				o_reset = 1'b1;
				nextstate = S_STEEP;

			end
		end
		
		S_STEEP: begin
			o_is_it_steep = 1'b1;
			nextstate = S_OPTIONS;

		end
		
		S_OPTIONS: begin
			if (~i_swap1_check & ~i_swap2_check)
				nextstate = S_LOCAL_VARS; 
			
			else if (~i_swap1_check & i_swap2_check)
				nextstate = S_SWAP_2;
				
			else
				nextstate = S_SWAP_1;
		end
		
		S_SWAP_1: begin
			o_steep = 1'b1;
			nextstate = S_CHECK_X_STEEP;
		end
		
		S_CHECK_X_STEEP: begin
			o_check_steep_x = 1'b1;
			nextstate = S_MORE_OPTIONS;
		end 
		
		S_MORE_OPTIONS: begin
			if(i_steep_swap_2) 
				nextstate = S_SWAP_2;
			else 
				nextstate = S_LOCAL_VARS;
		end
		
		S_SWAP_2: begin
			o_check_x = 1'b1;
			nextstate = S_LOCAL_VARS;
		end
		
		S_SET_UP: begin
			o_set_up = 1'b1;
			nextstate = S_DRAW;
		end
		
		S_LOCAL_VARS: begin
			o_local_vars = 1'b1;
			nextstate = S_SET_UP;
		end
		
		S_DRAW: begin
			o_draw = 1'b1;
			nextstate = S_CHECK_ERROR;
		end
			
		S_CHECK_ERROR: begin
			o_check_error = 1'b1;
			nextstate = S_UPDATE_VARS;
		end
		
		S_UPDATE_VARS: begin
			o_update_vars = 1'b1;
			nextstate = S_CHECK_DONE;
		end
		
		S_CHECK_DONE: begin
			if(i_counter_done) begin
				o_reset = 1'b1;
				nextstate = S_DELAY;
			end
			else 
				nextstate = S_DRAW;
			end
				
		S_DELAY: begin
			o_done = 1'b1;
			nextstate = S_START;
		end
		
			
	endcase
end

endmodule 