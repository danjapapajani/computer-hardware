module row #(
	parameter row_num
)
(
	input [7:0] i_m,
	input i_q_prev,
	input i_q,
	input [16:0]i_pin,
	output[16:0] o_pout
	//output o_final
);

	logic plus;
	logic minus;
	logic [7:0] sign;
	logic [16:0] cin;
	assign cin[0] = minus;
	
	booth_encoder booth
	(
	   .i_q_prev(i_q_prev),
		.i_q(i_q),
		.o_plus_j(plus),
		.o_minus_j(minus)
	);
	
	genvar i;
	genvar y;
	generate
		for(i = 0; i < 8; i++) begin : multipliers
			multiplier mult_inst
			(
				.i_pin(i_pin[i+1]),
				.i_plus_j(plus),
				.i_minus_j(minus),
				.i_cin(cin[i]),
				.i_m(i_m[i]),
				.o_pout(o_pout[i]),
				.o_sign(sign[i]),
				.o_cout(cin[i+1])
			);
		end

		for (y = 8; y < (16 - row_num); y++) begin : extenders
			fulladder sign_extender_inst
			(
				.i_cin(cin[y]),
				.i_pin(i_pin[y+1]),
				.i_sign(sign[7]),
				.o_pout(o_pout[y]),
				.o_cout(cin[y+1])
			);
		end
	endgenerate
	
	
	//fulladder FA
	//(
	//	.i_cin(cin[8]),
	//   .i_pin(i_pin[8]),
	//	.i_sign(sign[7]),
	//	.o_pout(o_pout[8]),
	//	.o_cout(o_pout[9])
	//);
	
	//assign o_final = o_pout[0];

	
	endmodule 