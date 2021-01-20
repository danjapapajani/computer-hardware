module fulladder
(	
	input i_cin,
	input i_pin,
	input i_sign,
	output o_pout,
	output o_cout
);


	assign o_pout = (i_pin ^ i_sign) ^ i_cin;	//sum result
	assign o_cout = (i_pin & i_sign) | (i_pin & i_cin) | (i_sign & i_cin); //carry out result
	
endmodule 	
