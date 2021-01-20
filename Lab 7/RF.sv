module RF(

	input i_RF_write,
	input clk,
	input rst,
	input logic [2:0] i_reg_y,
	input logic [2:0] i_reg_x,
	input logic [2:0] i_reg_w,
	input logic [15:0] i_data_w,
	
	output logic [15:0] o_data_1,
	output logic [15:0] o_data_2,
	output [7:0][15:0] o_tb_regs
);

	logic [15:0] r0;
	logic [15:0] r1;
	logic [15:0] r2;
	logic [15:0] r3;
	logic [15:0] r4;
	logic [15:0] r5;
	logic [15:0] r6;
	logic [15:0] r7;
	
	logic [15:0] data_temp_1;
	logic [15:0] data_temp_2;
	
	assign o_data_1 = data_temp_1;
	assign o_data_2 = data_temp_2;
	
	assign o_tb_regs[0] = r0;
	assign o_tb_regs[1] = r1;
	assign o_tb_regs[2] = r2;
	assign o_tb_regs[3] = r3;
	assign o_tb_regs[4] = r4;
	assign o_tb_regs[5] = r5;
	assign o_tb_regs[6] = r6;
	assign o_tb_regs[7] = r7;
	
	always_comb begin
		
		case(i_reg_x)
			3'b000: data_temp_1 = r0;
			3'b001: data_temp_1 = r1;
			3'b010: data_temp_1 = r2;
			3'b011: data_temp_1 = r3;
			3'b100: data_temp_1 = r4;
			3'b101: data_temp_1 = r5;
			3'b110: data_temp_1 = r6;
			3'b111: data_temp_1 = r7;
		endcase
		
		case(i_reg_y)
			3'b000: data_temp_2 = r0;
			3'b001: data_temp_2 = r1;
			3'b010: data_temp_2 = r2;
			3'b011: data_temp_2 = r3;
			3'b100: data_temp_2 = r4;
			3'b101: data_temp_2 = r5;
			3'b110: data_temp_2 = r6;
			3'b111: data_temp_2 = r7;
		endcase
	end
	
	always_ff @(posedge clk or posedge rst) begin
		
		if(rst) begin
			r0 = 16'b0;
			r1 = 16'b0;
			r2 = 16'b0;
			r3 = 16'b0;
			r4 = 16'b0;
			r5 = 16'b0;
			r6 = 16'b0;
			r7 = 16'b0;
		end else begin 
			
			if(i_RF_write) begin
				case(i_reg_w)
					3'b000: r0 = i_data_w;
					3'b001: r1 = i_data_w;
					3'b010: r2 = i_data_w;
					3'b011: r3 = i_data_w;
					3'b100: r4 = i_data_w;
					3'b101: r5 = i_data_w;
					3'b110: r6 = i_data_w;
					3'b111: r7 = i_data_w;
				endcase
			end
		end
	end
				
endmodule
