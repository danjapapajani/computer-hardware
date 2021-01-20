module mult
(
	input [7:0] i_m,
	input [7:0] i_q,
	output [15:0] o_product
);



	logic [16:0] pout [8:0];
	
	logic [8:0] q_in;
	assign q_in[0] = 1'b0;
	assign q_in[8:1] = i_q[7:0];
	
	assign pout[0] = 17'b0;

	genvar i;
	genvar j;
	genvar x;
	generate
		for(i = 0; i < 8; i++) begin : rows
			row #
				(
					.row_num(i)
				)
			row_inst_next
				(
					.i_m(i_m[7:0]),
					.i_q_prev(q_in[i]),
					.i_q(q_in[i+1]),
					.i_pin(pout[i]),
					.o_pout(pout[i+1])
					//.o_final(o_product[i])
				);
			
		end
		
		for (x = 0; x < 8; x++) begin: first 
			assign o_product[x] = pout[x+1][0];
		end

	
		for (j = 0; j < 8; j++) begin : last
			assign o_product[j+8] = pout[8][j+1];
		end

	endgenerate
	
	
	
endmodule 