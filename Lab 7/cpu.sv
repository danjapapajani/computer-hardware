module cpu
(
	input clk,
	input reset,
	
	output logic [15:0] o_pc_addr,
	output logic o_pc_rd,
	input logic [15:0] i_pc_rddata,
	
	output logic [15:0] o_ldst_addr,
	output logic o_ldst_rd,
	output logic o_ldst_wr,
	input logic [15:0] i_ldst_rddata,
	output logic [15:0] o_ldst_wrdata,
	
	output logic [7:0][15:0] o_tb_regs
);

	logic [15:0] ALU_in1;
	logic [15:0] ALU_in2;
	logic [15:0] ALU_out; 
	logic [1:0] ALUop_sel;
	logic N, Z, N_d, Z_d;
	

	ALU ALU_inst(
			.i_ALU_Op(ALUop_sel),
			.i_ALU_1(ALU_in1),
			.i_ALU_2(ALU_in2),
			.o_ALU_out(ALU_out), 
			.o_Z(Z),
			.o_N(N)
		);
		
	logic [2:0] reg_y;
	logic [2:0] reg_x; 
	logic [2:0] reg_w;
	logic [15:0] data_w; 
	logic [15:0] data_1;
	logic [15:0] data_2; 
	logic RF_write;
	logic ld_data;
	logic ld_en;
	
	RF RF_inst (
		.i_RF_write(RF_write),
		.clk(clk),
		.rst(reset),
		.i_reg_y(reg_y),
		.i_reg_x(reg_x),
		.i_reg_w(reg_w),
		.i_data_w(data_w),
		.o_data_1(data_1),
		.o_data_2(data_2),
		.o_tb_regs(o_tb_regs)
	); 

	logic valid_STAGE1;
	logic valid_STAGE2;
	logic valid_STAGE3;
	logic imm;
	logic forward;
	logic flag_write;
	logic [15:0] PC;
	logic [15:0] IR_STAGE1;
	logic [15:0] IR_STAGE2;
	logic [15:0] IR_STAGE3;
	logic [15:0] IR_STAGE4;
	logic [15:0] opA;
	logic [15:0] opB;
	logic [3:0] instr;
	logic [15:0] imm8_reg, imm11_reg; 
	logic [7:0] imm8;
	logic [15:0] PC_STAGE1;
	logic [15:0] PC_STAGE2;
	logic [15:0] PC_STAGE3;
	logic call, call_delay, call_delay_delayed;
	logic jumpr, jump_d, jump_dd; 
	logic [15:0] ALU_out_reg;
	logic jumpi,jumpi_d,jumpi_dd;
	logic jz,jn,jz_d,jn_d,jz_dd,jn_dd;
	logic jnr, jzr, jzr_d, jzr_dd, jnr_d, jnr_dd; 
	logic call_ddd;


	assign IR_STAGE1 = i_pc_rddata;
	assign opB = data_2;
	assign opA = data_1;
	assign data_w = ld_data ? i_ldst_rddata : ALU_out_reg;
	assign imm8 = IR_STAGE2[15:8];
	assign imm8_reg = $signed(IR_STAGE2[15:8]);
	assign imm11_reg = {IR_STAGE2[15], IR_STAGE2[15], IR_STAGE2[15], IR_STAGE2[15], IR_STAGE2[15:5], 1'b0};
	assign imm = IR_STAGE2[4];
	assign forward_y = (reg_y == reg_w) ? 1'b1 : 1'b0;
	assign forward_x = (reg_x == reg_w) ? 1'b1 : 1'b0;
	assign PC_STAGE1 = PC;
	assign call = (IR_STAGE2[3:0] == 4'b1100 && !(IR_STAGE3[3:0] == 4'b1001)) ? 1'b1 : 1'b0;
	assign jumpr = IR_STAGE2[4:0] == 5'b01000 ? 1'b1 : 1'b0;
	assign ALU_out_reg = jump_d ? (opA + imm8_reg) : ALU_out;
	assign jumpi = (IR_STAGE2[4:0] == 5'b11000) ? 1'b1 : 1'b0;
	
	assign jz = (IR_STAGE2[3:0] == 4'b1001 && Z) ? 1'b1 : 1'b0;
	assign jzr = (IR_STAGE2[4:0] == 5'b01001 && Z_d) ? 1'b1 : 1'b0;
	assign jn = (IR_STAGE2[3:0] == 4'b1010 && N) ? 1'b1 : 1'b0;
	
	assign RF_write = (IR_STAGE2[3:0] == 4'b0000 || IR_STAGE2[3:0] == 4'b0001 || IR_STAGE2[3:0] == 4'b0010 || IR_STAGE2[3:0] == 4'b0100 || IR_STAGE2[3:0] == 4'b0110 || IR_STAGE2[3:0] == 4'b1100 || IR_STAGE3[3:0] == 4'b0100 || IR_STAGE2[3:0] == 4'b0110);
	assign o_ldst_addr = data_w;
	assign ld_data = (IR_STAGE3[3:0] == 4'b0100);
	
	always @ (posedge clk) begin 
		if(reset) begin
			PC <= 16'b0;
			IR_STAGE2 <= 16'b0;
			IR_STAGE3 <= 16'b0;
			IR_STAGE4 <= 16'b0;
			valid_STAGE2 <= 1'b0;
			valid_STAGE3 <= 1'b0;
			flag_write <= 1'b0;
			valid_STAGE1 <= 1'b1;
		end else begin 
		
			call_delay <= call;
			call_delay_delayed <= call_delay;
			jump_d <= jumpr; 
			jump_dd <= jump_d;
			jumpi_d <= jumpi;
			jumpi_dd <= jumpi_d;
			jn_d <= jn;
			jn_dd <= jn_d;
			jz_d <= jz;
			jz_dd <= jz_d;
			jzr_d <= jzr;
			jzr_dd <= jzr_d; 
			jnr_d <= jnr; 
			jnr_dd <= jnr_d;
			N_d <= N;
			Z_d <= Z;
			call_ddd <= call_delay_delayed;
			
			/*************************//*
			********** FETCH ************
			***************************/
			if(valid_STAGE1) begin
				o_pc_rd <= 1'b1;
				o_pc_addr <= PC;

				if (call && imm)PC <= PC_STAGE3 + imm11_reg;
				else if(call && !imm)PC <= data_w;
				else if (jumpi)PC <= PC_STAGE3 + imm11_reg;
				else if(jz && imm) PC <= PC_STAGE3 + imm11_reg;
				else if(jn && imm) PC <= PC_STAGE3 + imm11_reg;
				else if(jz && !imm) PC <= PC_STAGE2;
				else if(jn && !imm) PC <= ALU_out;
				else if (jumpr) PC <= ALU_out;
				else PC <= PC + 2'd2;
	
				reg_x <= IR_STAGE1[7:5];
				reg_y <= IR_STAGE1[10:8];
				instr <= IR_STAGE1[4:0];
				
				if(IR_STAGE1[3:0] == 4'b0100) o_ldst_rd <= 1'b1;
				
				IR_STAGE2 <= IR_STAGE1;
				PC_STAGE2 <= PC_STAGE1;
				PC_STAGE3 <= PC_STAGE2;

				if (call_delay || call_delay_delayed || jump_d || jump_dd || jumpi_d || jumpi_dd || jn_d || jn_dd || jz_d || jz_dd || jnr_d || jnr_dd || jzr_d || jzr_dd || jnr) 
					valid_STAGE2 <= 1'b0;
				else valid_STAGE2 <= 1'b1;
			end
			
			/*************************//*
			****** READ AND DECODE ******
			***************************/
			if(valid_STAGE2) begin
				IR_STAGE3 <= IR_STAGE2;
				valid_STAGE3 <= 1'b1;
				
				
				if(instr == 4'b0001) begin 
					if(imm) ALU_in2 <= imm8_reg;
					else if(forward_y) ALU_in2 <= data_w;
					else ALU_in2 <= opB;
					
					if(forward_x) ALU_in1 <= data_w;
					else ALU_in1 <= opA;
					ALUop_sel <= 2'b00;
					reg_w <= IR_STAGE2[7:5];
				end else if(instr == 4'b0010 | instr == 4'b0011) begin
					if(imm) begin
						if(forward_x) ALU_in1 <= data_w;
						else ALU_in1 <= opA;
						ALU_in2 <= imm8_reg;
						ALUop_sel <= 2'b01;
						reg_w <= IR_STAGE2[7:5];
					end 
				end else if(instr == 4'b0000) begin
					if(imm) ALU_in2 <= imm8_reg;
					else if(forward_y) ALU_in2 <= data_w;
					else ALU_in2 <= opB;
					ALU_in1 <= 16'b0;
					ALUop_sel <= 2'b00;
					reg_w <= IR_STAGE2[7:5];			
				end else if(instr == 4'b0110 && imm) begin
					if(forward_x) ALU_in2 <= {imm8, data_w[7:0]};
					else ALU_in2 <= {imm8, opA[7:0]};
					ALU_in1 <= 16'b0;
					ALUop_sel <= 2'b00;
					reg_w <= IR_STAGE2[7:5];	
				end
				else if (IR_STAGE2[4:0] == 5'b11001) begin
					if(Z) begin
						valid_STAGE2 <= 1'b0;
						valid_STAGE3 <= 1'b0;
					end
				end else if(IR_STAGE2[4:0] == 5'b01001) begin
					if(Z_d) begin
						if(forward_x) ALU_in1 <= data_w;
						else ALU_in1 <= opA;
						ALUop_sel <= 2'b11;
						valid_STAGE2 <= 1'b0;
						valid_STAGE3 <= 1'b0;
					end
				end else if(IR_STAGE2[4:0] == 5'b11010) begin
					if(N) begin
						valid_STAGE2 <= 1'b0;
						valid_STAGE3 <= 1'b0;
					end
				end else if (IR_STAGE2[4:0] == 5'b01010)begin
					if(N_d) begin
						if(forward_x) ALU_in1 <= data_w;
						else ALU_in1 <= opA;
						ALUop_sel <= 2'b11;
						valid_STAGE2 <= 1'b0;
						valid_STAGE3 <= 1'b0;
						jnr <= 1'b1;
					end else jnr <= 1'b0;
				end else if (instr == 4'b1000) begin
					if(imm) begin
						valid_STAGE2 <= 1'b0;
						valid_STAGE3 <= 1'b0;
					end else begin
						if(forward_x) ALU_in1 <= data_w;
						else ALU_in1 <= opA;
						ALUop_sel <= 2'b11;
						valid_STAGE2 <= 1'b0;
						valid_STAGE3 <= 1'b0;
					end
				end else if(instr == 4'b1100) begin
					valid_STAGE2 <= 1'b0;
					valid_STAGE3 <= 1'b0;
					reg_w <= 3'b111;
					ALU_in1 <= PC_STAGE3;
					ALU_in2 <= opB;
					ALUop_sel <= 2'b11;
				end else if(instr == 4'b0100) begin
					reg_w <= IR_STAGE2[7:5];
				end else if(instr == 4'b0101) begin
					o_ldst_wr <= 1'b1;
					if(forward_x) o_ldst_wrdata <= data_w;
					else o_ldst_wrdata <= opA;
				end else if(instr == 4'b0110) begin
					if(forward_x) ALU_in1 <= {imm8,data_w[7:0]};
					else ALU_in1 <= {imm8,opA[7:0]};
					ALU_in2 <= 16'b0;
					ALUop_sel <= 2'b00;
					reg_w <= IR_STAGE2[7:5];
				end
			end
			
			/*************************//*
			********** EXECUTE **********
			***************************/
			if(valid_STAGE3) begin
				IR_STAGE4 <= IR_STAGE3;
				if(IR_STAGE3[3:0] == 4'b0101) o_ldst_wr <= 1'b0;
			end
		end
	end 
endmodule

