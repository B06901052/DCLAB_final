`timescale 10us/10us //unit/precise

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
logic start, ai_done, player_done;
logic [2:0] ai_row, ai_col, player_row, player_col;
integer file, corder, row, col, d, e;

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

	file = $fopen("./AI_python/dump/5_tsai.csv", "r");//filename == who is first
	assert (file) 
	else begin
		$display("filepath is wrong");
		$finish();
	end
	//reset
	clk				= 1;
	rst_n			= 1;
	start			= 0;
	player_done		= 0;
	player_row		= 0;
	player_col		= 0;
	#(2*CLK) rst_n	= 0;
	#(2*CLK) rst_n	= 1;
	#(CLK) start	= 1;
	#(CLK) start	= 0;

	while (!$feof(file)) begin
		$fscanf(file, "%d,%d,%d,%d,%d", corder, row, col, d, e);
		if (corder == -2) begin
			wait(ai_done);
			assert (row==ai_row && col==ai_col) 
			else begin 
				$display("error at (%2d,%1d,%1d,%2d,%2d)", corder, row, col, d, e);
				$display("\n(%1d,%1d)", ai_row, ai_col);
				$fclose(file);
				$finish;
			end
		end else begin
			#(2*CLK)
			player_row	= row;
			player_col	= col;
			#(2*CLK)
			player_done	= 1;
			#(CLK)
			player_done	= 0;
		end
		
	end
	$fclose(file);
	
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
	.i_mode(2'b01),//0~2:1P easy, normal, hard; 3:2P
	.i_start(start),
	.i_surrender(1'b0),
	.i_prestep(1'b0),
	.i_row(player_row),
	.i_col(player_col),
	.i_player_done(player_done),
	.o_board(),
	.o_row(ai_row),
	.o_col(ai_col),
	.o_aidone(ai_done)
);
endmodule
