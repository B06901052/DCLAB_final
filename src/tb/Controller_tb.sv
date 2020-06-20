`timescale 10us/10us //unit/precise
`include ""

module Controller_tb;

/*================================================================*
 * Clock Settings
 *================================================================*/
localparam CLK		= 20;
localparam HCLK		= CLK/2;
localparam MAX_CLK	= 100_0000;

/*================================================================*
 * REG/WIRE
 *================================================================*/
logic clk, rst_n;
integer file;

always #HCLK clk = ~clk;

/*================================================================*
 * Test
 *================================================================*/
initial begin
	//output fsdb
	`ifdef FSDB
		$fsdbDumpfile("Controller_tb.fsdb");
		$fsdbDumpvars(0, Controller_tb, "+mda");
	`endif

	file = $fopen("../pc_python/golden/enc1.bin", "rb");
	//reset
	clk				= 0;
	rst_n			= 1;
	#(2*CLK) rst_n	= 0;
	#(2*CLK) rst_n	= 1;

	
	@(posedge clk);
	$finish;
end

//time upper bound
initial begin
	#(MAX_CLK*CLK)
	$display("Over the timing upper bound, abort.");
	$finish;
end

/*================================================================* 
 * Module under Test
 *================================================================*/
Controller ctrl0 (
	.i_clk(clk),
	.i_rst_n(rst_n),
	.i_mode(2'b0),//0~2:1P easy, normal, hard; 3:2P
	.i_start(),
	.i_surrender(),
	.i_prestep(),
	.i_row(),
	.i_col(),
	.i_player_done()
);
endmodule
