module control(

	input rst,
	input clk, 
	input i_N,
	input i_Z,
	input [3:0] i_instr,
	input i_imm,
	
	output logic o_PC_write,
	output logic o_Addr_sel,
	output logic o_mem_rd,
	output logic o_mem_wr,
	output logic o_MDR_load,
	output logic o_IR_load,
	output logic o_OpA_sel,
	output logic o_OpAB_load,
	output logic [1:0] o_ALU_1_sel,
	output logic [1:0] o_ALU_2_sel,
	output logic [1:0] o_ALUop_sel,
	output logic o_ALU_out,
	output logic o_RF_write,
	output logic o_RF_write_call,
	output logic o_Reg_in,
	output logic o_Flag_write,
	output logic o_mov_hi
	
);


	enum int unsigned 
	{ 
		S_RESET,
		S_FETCH,
		S_DECODE,
		S_ADD_ADDI,
		S_SAVE_MULTIPLY,
		S_LOAD_OPB,
		S_SAVE_PC,
		S_SAVE_REG,
		S_SUB_SUBI_CMP_CMPI,
		S_LD,
		S_LD_SAVE,
		S_LD_SAVE2,		
		S_ST,
		S_MV_MVI_MVHI,
		S_JR_JZ_JN,
		S_JR_JZ_JN_IMM,
		S_CALL,
		S_SAVE_REG_PC,
		S_FETCH_JMP_CALL,
		S_RX_TO_PC,
		S_DATA,
		S_SAVE_REG_PC_2,
		S_JUMP_TO_PC
	} state, nextstate;
		
	always_ff @ (posedge clk or posedge rst) begin
		if(rst) state <= S_RESET;
		else state <= nextstate;
	end 
	
	always_comb begin
		
		nextstate = state;
		o_PC_write = 1'b0;
		o_Addr_sel = 1'b0;
		o_mem_rd = 1'b0;
		o_mem_wr = 1'b0;
		o_MDR_load = 1'b0;
		o_IR_load = 1'b0;
		o_OpA_sel = 1'b0;
		o_OpAB_load = 1'b0;
		o_ALU_1_sel = 2'b0;
		o_ALU_2_sel = 2'b0;
		o_ALUop_sel= 2'b0;
		o_ALU_out = 1'b0;
		o_RF_write = 1'b0;
		o_Reg_in = 1'b0;
		o_Flag_write = 1'b0;
		o_RF_write_call = 1'b0;
		o_mov_hi = 1'b0;
		
		case(state)
			S_RESET: begin
				nextstate = S_FETCH;
			end
			
			S_FETCH: begin
				o_PC_write = 1'b1;
				o_Addr_sel = 1'b1;
				o_mem_rd = 1'b1;
				o_ALU_2_sel = 2'b01;
				
				nextstate = S_DATA;
			end
			
			S_DATA: begin 
			
				o_IR_load = 1'b1;
				nextstate = S_DECODE; 
			end 
			
			S_DECODE: begin
				o_OpAB_load = 1'b1;
				
				if(i_instr == 4'b0001) 
					nextstate = S_ADD_ADDI;
				else if(i_instr == 4'b0010 | i_instr == 4'b0011)
					nextstate = S_SUB_SUBI_CMP_CMPI;
				else if(i_instr == 4'b0100)
					nextstate = S_LD;
				else if(i_instr == 4'b0101)
					nextstate = S_ST;
				else if(i_instr == 4'b0000 | i_instr == 4'b0110)
					nextstate = S_MV_MVI_MVHI;
				else if(i_instr == 4'b1000 | i_instr == 4'b1001 | i_instr == 4'b1010)
					nextstate = S_JR_JZ_JN;
				else if(i_instr == 4'b1100)
					nextstate = S_CALL;
			end
			
			S_ADD_ADDI: begin 
				if (i_imm) o_ALU_2_sel = 2'b10; 
				o_ALU_1_sel = 2'b01;
				o_ALU_out = 1'b1;
				o_Flag_write = 1'b1;
				nextstate = S_SAVE_REG;
			end 
			
			S_SAVE_REG: begin 
				o_RF_write = 1'b1;
				nextstate = S_FETCH;
			end 
			
			S_SAVE_MULTIPLY: begin 
				o_ALU_2_sel = 2'b11;
				o_ALU_out = 1'b1;
				o_ALUop_sel = 2'b10;
				nextstate = S_SAVE_REG_PC; 
			end 
			
			S_SAVE_REG_PC: begin
				o_RF_write = 1'b1;
				nextstate = S_LOAD_OPB;
			end
			
			S_LOAD_OPB: begin
				o_OpAB_load = 1'b1;
				nextstate = S_SAVE_PC;
			end
			
			S_SAVE_PC: begin
				o_PC_write = 1'b1;
				nextstate = S_FETCH;
			end
			
			S_SUB_SUBI_CMP_CMPI: begin 
				if (i_imm) begin 
					o_ALU_1_sel = 2'b01; 
					o_ALU_2_sel = 2'b10; 
					o_ALUop_sel = 2'b01; 
					o_ALU_out = 1'b1; 
					o_Flag_write = 1'b1; 
					if (i_instr == 4'b0010)
						nextstate = S_SAVE_REG; 
					else if (i_instr == 4'b0011)
						nextstate = S_FETCH; 
				end else begin 
					o_ALU_1_sel = 2'b01; 
					o_ALUop_sel = 2'b01; 
					o_ALU_out = 1'b1; 
					o_Flag_write = 1'b1; 
					if (i_instr == 4'b0010)
						nextstate = S_SAVE_REG; 
					else if (i_instr == 4'b0011)
						nextstate = S_FETCH; 
				end
			end 
			
			S_LD: begin 
				o_mem_rd = 1'b1;
				nextstate = S_LD_SAVE;
			end
				
			S_LD_SAVE: begin
				o_MDR_load = 1'b1;
				nextstate = S_LD_SAVE2;
			end
			
			S_LD_SAVE2: begin 
				o_ALU_out = 1'b1;
				o_RF_write = 1'b1;
				o_Reg_in = 1'b1;
				nextstate = S_FETCH; 
			end 
					
			S_ST: begin
				o_mem_wr = 1'b1;
				nextstate = S_FETCH;
			end
			
			
			
			S_MV_MVI_MVHI: begin
				if(i_instr == 4'b0000) begin
					if(i_imm) o_ALU_2_sel = 2'b10;
					else o_ALU_2_sel = 2'b00;
					
					o_ALU_1_sel = 2'b11; //adding zero
					o_ALUop_sel = 2'b00;
					o_ALU_out = 1'b1;
					nextstate = S_SAVE_REG;
				end 
				else if(i_instr == 4'b0110 && i_imm) begin
					o_mov_hi = 1'b1;
					o_ALUop_sel = 2'b00;
					o_ALU_out = 1'b1;
					nextstate = S_SAVE_REG;	
				end 
			end
			
			S_FETCH_JMP_CALL: begin
				o_PC_write = 1'b1;
				o_ALU_1_sel = 2'b00;
				o_ALU_2_sel = 2'b11;
				o_ALU_out = 1'b1;
				nextstate = S_FETCH; 
			end
			
			S_JR_JZ_JN: begin
				if(i_instr == 4'b1000) begin
					if(i_imm) nextstate = S_FETCH_JMP_CALL;
					else begin
						o_PC_write = 1'b1;
						o_ALU_1_sel = 2'b01;
						o_ALUop_sel = 2'b11;
						nextstate = S_FETCH;
					end
				end
			
				if(i_instr == 4'b1001) begin
					if(i_Z) begin
						if(i_imm) nextstate = S_FETCH_JMP_CALL;
						else begin
							o_PC_write = 1'b1;
							o_ALU_1_sel = 2'b01;
							o_ALUop_sel = 2'b11;
							nextstate =  S_FETCH;
						end
					end
					else nextstate = S_FETCH;
				end
				
				if(i_instr == 4'b1010) begin
					if(i_N) begin
						if(i_imm) nextstate = S_FETCH_JMP_CALL;
						else begin
							o_PC_write = 1'b1;
							o_ALU_1_sel = 2'b01;
							o_ALUop_sel = 2'b11;
							nextstate =  S_FETCH;
						end
					end
					else nextstate = S_FETCH;
				end
			end
			
			
			S_CALL: begin
				o_ALU_1_sel = 1'b0;
				o_ALUop_sel = 2'b11;
				o_ALU_out = 1'b1;
				nextstate = S_SAVE_REG_PC_2;
			end
			
			S_SAVE_REG_PC_2: begin
				o_RF_write = 1'b1;
				o_RF_write_call = 1'b1;
				
				if(i_imm) nextstate = S_FETCH_JMP_CALL;
				else nextstate = S_RX_TO_PC;
			end
			
			S_RX_TO_PC: begin
				o_PC_write = 1'b1;
				o_ALU_1_sel = 2'b01;
				nextstate = S_FETCH;
			end
		endcase
	end
endmodule
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	