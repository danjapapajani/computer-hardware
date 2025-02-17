module de1soc_top 
(
	// These are the board inputs/outputs required for all the ECE342 labs.
	// Each lab can use the subset it needs -- unused pins will be ignored.
	
    // Clock pins
    input                     CLOCK_50,

    // Seven Segment Displays
    output      [6:0]         HEX0,
    output      [6:0]         HEX1,
    output      [6:0]         HEX2,
    output      [6:0]         HEX3,
    output      [6:0]         HEX4,
    output      [6:0]         HEX5,

    // Pushbuttons
    input       [3:0]         KEY,

    // LEDs
    output      [9:0]         LEDR,

    // Slider Switches
    input       [9:0]         SW,

    // VGA
    output      [7:0]         VGA_B,
    output                    VGA_BLANK_N,
    output                    VGA_CLK,
    output      [7:0]         VGA_G,
    output                    VGA_HS,
    output      [7:0]         VGA_R,
    output                    VGA_SYNC_N,
    output                    VGA_VS
);

// VGA adapter and signals
logic [8:0] vga_x;
logic [7:0] vga_y;
logic [2:0] vga_color;
logic vga_plot;

logic [8:0] o_x0, o_x1;
logic [7:0] o_y0, o_y1;

logic done;

vga_adapter #
(
	.BITS_PER_CHANNEL(1)
)
vga_inst
(
	.CLOCK_50(CLOCK_50),
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_CLK(VGA_CLK),
	.x(vga_x),
	.y(vga_y),
	.color(vga_color),
	.plot(vga_plot)
);

// This generates a one-time active-high asynchronous reset
// signal on powerup. You can use it if you need it.
// All the KEY inputs are occupied, so we can't use one as a reset.
//logic reset;
//logic [1:0] reset_reg;
//always_ff @ (posedge CLOCK_50) begin
//	reset <= ~reset_reg[0];
//	reset_reg <= {1'b1, reset_reg[1]};
//end


user_interface init(
	.clk(CLOCK_50),
	.SW(SW[8:0]),
	.KEY(KEY[3:0]),
	.o_start(o_start),
	.o_x0(o_x0),
	.o_y0(o_y0),
	.o_x1(o_x1),
	.o_y1(o_y1),
	.o_colour(vga_color),
	.done(done)
	//.STATE(LEDR[9:0])
);

LDA init1(
	.clk(CLOCK_50),
	.i_start(o_start),
	.i_x0(o_x0),
	.i_y0(o_y0),
	.i_x1(o_x1),
	.i_y1(o_y1),
	.o_x(vga_x),
	.o_y(vga_y),
	.o_plot(vga_plot),
	.o_done(done)
);

endmodule