`timescale 10us/10us //unit/precise

module ImgSender_tb;

/*================================================================*
 * Clock Settings
 *================================================================*/
localparam CLK		= 20;
localparam HCLK		= CLK/2;
localparam MAX_CLK	= 10_0000;

/*================================================================*
 * REG/WIRE
 *================================================================*/
logic 		clk, rst_n;
logic [1:0] board [0:7][0:7]; 
logic [23:0]pixel;
logic [9:0]	x;
logic [8:0]	y;
integer		i, j;

always #HCLK clk = ~clk;

/*================================================================*
 * Test
 *================================================================*/
initial begin
	//output fsdb
	`ifdef FSDB
		$fsdbDumpfile("ImgSender_tb.fsdb");
		$fsdbDumpvars(0, ImgSender_tb, "+mda");
	`endif
	//reset
	clk				= 0;
	rst_n			= 1;
	#(2*CLK) rst_n	= 0;
	#(2*CLK) rst_n	= 1;
end
//board
initial begin
	for (i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin
			board[i][j]	<= 0;
		end
	end
end
initial begin
	for (j = 0; j < 480; j = j + 1) begin
		for (i = 0; i < 800; i = i + 1) begin
			#(2*CLK)
			x	= i;
			y	= j;
		end
		
	end
	@(posedge clk);
	$finish;
end

//time upper bound
initial begin
	#(MAX_CLK*CLK)
	$display("Too slow, abort.");
	$finish;
end

/*================================================================* 
 * Module under Test
 *================================================================*/
ImgSender i0 (
	.i_clk(clk),
	.i_rst_n(rst_n),
	.i_board(board),
	.i_data(24'h00ff00),
	.o_addr(addr),
	.i_x(x),
	.i_y(y),
	.o_pixel(pixel)
);
endmodule
