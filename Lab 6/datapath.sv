module datapath(

	input rst,
	input clk, 
	input logic [15:0] i_mem_rddata,
	input logic i_PC_write,
	input logic i_Addr_sel,
	input logic i_mem_wr,
	input logic i_MDR_load,
	input logic i_IR_load,
	input logic i_OpA_sel,
	input logic i_OpAB_load,
	input logic [1:0] i_ALU_1_sel,
	input logic [1:0] i_ALU_2_sel,
	input logic [1:0] i_ALUop_sel,
	input logic i_ALU_out,
	input logic i_RF_write,
	input logic i_Reg_in,
	input logic i_Flag_write,
	input logic i_RF_write_call,
	input logic i_mov_hi,
	
	output logic o_N,
	output logic o_Z,
	output logic [3:0] o_instr,
	output logic [15:0] o_mem_wrdata,
	output logic [15:0] o_mem_addr,
	output logic o_mem_rd,
	output logic o_mem_wr,
	output logic o_imm
);


	logic [15:0] ALU_in1;
	logic [15:0] ALU_in2;
	logic [15:0] ALU_out; 
	logic N_temp; 
	logic Z_temp;
	 

	ALU ALU_inst(
		.i_ALU_Op(i_ALUop_sel),
		.i_ALU_1(ALU_in1),
		.i_ALU_2(ALU_in2),
		.o_ALU_out(ALU_out), 
		.o_Z(Z_temp),
		.o_N(N_temp)
	);

	always @ (posedge clk or posedge rst) begin 
		if (rst) begin 
			o_N <= 0;
			o_Z <= 0;
		end 
		else begin 
			if (i_Flag_write) begin 
				o_N <= N_temp; 
				o_Z <= Z_temp; 
			end 
		end 
	end 


	logic [2:0] reg_y;
	logic [2:0] reg_x; 
	logic [2:0] reg_w;
	logic [15:0] data_w; 
	logic [15:0] data_1;
	logic [15:0] data_2; 

	RF RF_inst (
		.i_RF_write(i_RF_write),
		.clk(clk),
		.rst(rst),
		.i_reg_y(reg_y),
		.i_reg_x(reg_x),
		.i_reg_w(reg_w),
		.i_data_w(data_w),
		.o_data_1(data_1),
		.o_data_2(data_2)
	); 

	logic [15:0] PC;
	logic [15:0] IR;
	logic [15:0] MDR; 
	logic [7:0] imm8; 
	logic [10:0] imm11; 
	logic [15:0] opA;
	logic [15:0] opB;
	logic [15:0] ALU_out_reg;
	logic [15:0] imm8_reg, imm11_reg; 

	assign imm8 = IR[15:8];
	assign imm11 = IR[15:5];
	assign imm8_reg = $signed(imm8);
	//assign imm11_reg = $signed{imm11, 1'b0};
	assign imm11_reg = {imm11[10], imm11[10], imm11[10], imm11[10], imm11, 1'b0};

	assign o_mem_addr = i_Addr_sel ? PC : opB;
	assign reg_x = i_OpA_sel ? 3'd1 : IR[7:5];
	assign reg_y = IR[10:8];
	assign reg_w = i_RF_write_call ? 3'b111 : reg_x;
	assign data_w = i_Reg_in ? MDR : ALU_out_reg;
	assign o_instr = IR[4:0];
	assign o_imm = IR[4]; 
	assign o_mem_wrdata = opA;

	always_comb begin
		case(i_ALU_1_sel) 
			2'b00: ALU_in1 = PC;
			2'b01: ALU_in1 = opA;
			2'b11: ALU_in1 = 16'b0;
		endcase
		
		case(i_ALU_2_sel)
			2'b00: ALU_in2 = opB;
			2'b01: ALU_in2 = 16'd2;
			2'b10: ALU_in2 = imm8_reg;
			2'b11: ALU_in2 = imm11_reg;
		endcase
		
	end


	always_ff @ (posedge clk or posedge rst) begin 
		if (rst) begin
			PC <= 16'b0; 
			IR <= 16'b0; 
			MDR <= 16'b0;
			opA <= 16'b0;
			opB <= 16'b0;
			ALU_out_reg <= 16'b0;
		end
		
		if(i_PC_write) PC <= ALU_out;

		if(i_IR_load) IR <= i_mem_rddata;
		
		if(i_OpAB_load) begin
			opA <= data_1;
			opB <= data_2;
		end
		
		if(i_MDR_load) MDR <= i_mem_rddata;
		
		if(i_ALU_out) begin
			if(i_mov_hi) ALU_out_reg <= {imm8,opA[7:0]};
			else ALU_out_reg <= ALU_out;
		end
	end 
endmodule



























