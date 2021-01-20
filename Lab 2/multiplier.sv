module multiplier
(
	input i_pin,
	input i_plus_j,
	input i_minus_j,
	input i_cin,
	input i_m,
	output o_pout,
	output o_sign,
	output o_cout
);
	
	//m 
	assign o_sign = (~i_m & i_minus_j) | (i_plus_j & i_m);
	
	//full adder
	fulladder FA
	(
		.i_cin(i_cin),
		.i_pin(i_pin),
		.i_sign(o_sign),
		.o_pout(o_pout),
		.o_cout(o_cout)
	);
		
endmodule