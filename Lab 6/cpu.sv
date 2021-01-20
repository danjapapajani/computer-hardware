module cpu(
	
	input clk,
	input reset,
	input logic [15:0] i_mem_rddata,
	
	output logic [15:0] o_mem_wrdata,
	output logic [15:0] o_mem_addr,
	output logic o_mem_rd,
	output logic o_mem_wr
);

	
	logic rst;
	logic set_addr;
	logic read_data;
	logic inc_PC;
	logic updatePC;
	logic read_IR;
	logic mv_rd;
	logic mv_wr;
	logic ld_rd;
	logic readRx_add;
	logic readRy_add;
	logic add_add;
	logic writeRx_add;
	logic readMem;
	logic writeRx_ld;
	logic st_Rx;
	logic rd_Rx_mvi;
	logic mvi;
	logic addi;
	logic jump;
	logic new_PC;
	logic call;
	logic [4:0] instr;
	logic N;
	logic Z;
	logic [3:0] imm;
	
	datapath data(
		.reset(reset),
		.clk(clk), 
		.i_mem_rddata(i_mem_rddata),
		.i_reset(rst),
		.i_set_addr(set_addr),
		.i_rd_data(rd_data),
		.i_inc_PC(inc_PC),
		.i_read_IR(read_IR),
		.i_mv_rd(mv_rd),
		.i_mv_wr(mv_wr),
		.i_readRx_add(readRx_add),
		.i_readRy_add(readRy_add),
		.i_add_add(add_add),
		.i_updatePC(updatePC),
		.i_writeRx_add(writeRx_add),
		.i_ld_rd(ld_rd),
		.i_readMem(readMem),
		.i_writeRx_ld(writeRx_ld),
		.i_st_Rx(st_Rx),
		.i_rd_Rx_mvi(rd_Rx_mvi),
		.i_mvi(mvi),
		.i_addi(addi),
		.i_jump(jump),
		.i_new_PC(new_PC),
		.i_call(call),
	
		.o_N(N),
		.o_Z(Z),
		.o_opCode(instr),
		.o_mem_wrdata(o_mem_wrdata),
		.o_mem_addr(o_mem_addr),
		.o_mem_rd(o_mem_rd),
		.o_mem_wr(o_mem_wr)
	);
	

	
	control control(
		.reset(reset),
		.clk(clk),
		.i_N(N),
		.i_Z(Z),
		.i_instr(instr),

		.o_mem_rd(mem_rd),
		.o_mem_wr(mem_wr),
		.o_reset(rst),
		.o_set_addr(set_addr),
		.o_read_data(read_data),
		.o_inc_PC(inc_PC),
		.o_updatePC(updatePC),
		.o_read_IR(read_IR),
		.o_mv_rd(mv_rd),
		.o_mv_wr(mv_wr),
		.o_ld_rd(ld_rd),
		.o_readRx_add(readRx_add),
		.o_readRy_add(readRy_add),
		.o_add_add(add_add),
		.o_writeRx_add(writeRx_add),
		.o_readMem(readMem),
		.o_writeRx_ld(writeRx_ld),
		.o_st_Rx(st_Rx),
		.o_rd_Rx_mvi(rd_Rx_mvi),
		.o_mvi(mvi),
		.o_addi(addi),
		.o_jump(jump),
		.o_new_PC(new_PC),
		.o_call(call)
		
	);
	
endmodule