module ALU(

	input logic [1:0] i_ALU_Op,
	input logic [15:0] i_ALU_1,
	input logic [15:0] i_ALU_2,
	
	output logic [15:0] o_ALU_out,
	output o_N,
	output o_Z
);

	logic [15:0] ALU_out_temp;
	
	
	assign o_ALU_out = ALU_out_temp;
	assign o_N = o_ALU_out[15];
	assign o_Z = (o_ALU_out == 16'b0);
	
	always_comb begin
	
		case(i_ALU_Op)
			2'b00: ALU_out_temp = i_ALU_1 + i_ALU_2;
			2'b01: ALU_out_temp = i_ALU_1 - i_ALU_2;
			2'b10: ALU_out_temp = 2*i_ALU_2;
			2'b11: ALU_out_temp = i_ALU_1;
		endcase
	end
	
endmodule
	
			