module user_interface
(
	input clk,
	input [8:0] SW,
	input [3:0] KEY,
	input logic done,
	output logic o_start,
	output logic [8:0] o_x0,
	output logic [7:0] o_y0,
	output logic [8:0] o_x1,
	output logic [7:0] o_y1,
	output logic [2:0] o_colour
);

logic i_load_x, i_load_y, i_load_c, i_go;
logic o_load_x, o_load_y, o_load_c;

assign i_load_x = ~KEY[0];
assign i_load_y = ~KEY[1];
assign i_load_c = ~KEY[2];
assign i_go = ~KEY[3];

UI_control init0
(
	.clk(clk),
	.i_load_x(i_load_x),
	.i_load_y(i_load_y),
	.i_load_c(i_load_c),
	.i_go(i_go),
	.i_done(done),
	.o_load_x(o_load_x),
	.o_load_y(o_load_y),
	.o_load_c(o_load_c),
	.o_start(o_start)
	//.o_init(o_init),
	//.o_update_coords(o_update_coords)
	
);

UI_datapath init1
(
	.clk(clk),
	.SW(SW[8:0]),
	.i_load_x(o_load_x),
	.i_load_y(o_load_y),
	.i_load_c(o_load_c),
	.i_done(done),
	.o_x0(o_x0),
	.o_y0(o_y0),
	.o_x1(o_x1),
	.o_y1(o_y1),
	.o_colour(o_colour)
);

endmodule

//**************************************
//*                                    *
//*          DATAPATH MODULE           *
//*                                    *
//**************************************
module UI_datapath
(
	input clk,
	input [8:0] SW,
	input i_load_x,
	input i_load_y,
	input i_load_c,
	input i_done,
	output logic o_start,
	output logic [8:0] o_x0,
	output logic [7:0] o_y0,
	output logic [8:0] o_x1,
	output logic [7:0] o_y1,
	output logic [2:0] o_colour
);

initial o_x0 = 9'd0;
initial o_y0 = 8'd0;

always_ff @ (posedge clk)begin
	
	if(i_load_x) 
		o_x1 <= SW[8:0];
		
	if (i_load_y)
	o_y1 <= SW[8:0];
	
	if(i_load_c)
	o_colour <= SW[2:0];
	
	if(i_done)begin
		o_x0 <= o_x1;
		o_y0 <= o_y1;
	end
		
end
endmodule


//**************************************
//*                                    *
//*        CONTROLPATH MODULE          *
//*                                    *
//**************************************
module UI_control
(
	input clk,
	input i_load_x,
	input i_load_y,
	input i_load_c,
	input i_go,
	input i_done,
	output logic o_load_x,
	output logic o_load_y,
	output logic o_load_c,
	output logic o_start
);


logic init;
enum int unsigned
{
	S_INIT,
	S_WAITX,
	S_WAITY,
	S_WAITC,
	S_WAITGO,
	S_LOAD_X,
	S_LOAD_Y,
	S_LOAD_C,
	S_GO

	
} state, nextstate;

always_ff @ (posedge clk) begin

	state <= nextstate;
	
end 

always_comb begin
	
	nextstate = state;
	o_load_x = 1'b0;
	o_load_y = 1'b0;
	o_load_c = 1'b0;
	o_start = 1'b0;
	
	case (state)
	
		S_INIT: begin
			//o_init = 1'b1;
			nextstate = S_WAITX;
		end
		
		S_WAITX: begin
			if(i_load_x) 
				nextstate = S_LOAD_X;	
		end
		
		S_LOAD_X: begin
			o_load_x = 1'b1;
			if(~i_load_x)
				nextstate = S_WAITY;
		end
		
		S_WAITY: begin
			if (i_load_y) 
				nextstate = S_LOAD_Y;
		end
		
		S_LOAD_Y: begin
			o_load_y = 1'b1;
			if(~i_load_y)
			nextstate = S_WAITC;
		end
		
		S_WAITC: begin
			if (i_load_c) 
				nextstate = S_LOAD_C;
		end
		
		S_LOAD_C: begin
			o_load_c = 1'b1;
			if(~i_load_c)
			nextstate = S_WAITGO;
		end
			
		S_WAITGO: begin
			if (i_go) 
				nextstate = S_GO;
		end
				
		S_GO: begin
			o_start = 1'b1;
			//o_update_coords = 1'b1;
			if(i_done)
				nextstate = S_WAITX;
		end
			

	endcase
end

endmodule 