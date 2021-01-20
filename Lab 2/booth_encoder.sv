module booth_encoder
(
	input i_q_prev,
	input i_q,
	output o_plus_j,
	output o_minus_j
);

	//plus_j 
	assign o_plus_j = i_q_prev & ~i_q;

	//minus_j
	assign o_minus_j = ~i_q_prev & i_q;

endmodule