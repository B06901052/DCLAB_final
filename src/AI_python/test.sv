`timescale 1us/1us //unit/precise

module Test_tb;

/*================================================================*
 * Clock Settings
 *================================================================*/
localparam CLK		= 10;
localparam HCLK		= CLK/2;
localparam MAX_CLK	= 10000;

/*================================================================*
 * REG/WIRE
 *================================================================*/
logic clk, rst_n;
integer f1, i;
integer a,b,c,d,e;

always #HCLK clk = ~clk;

/*================================================================*
 * Test
 *================================================================*/
initial begin
	//reset
	clk				= 0;
	rst_n			= 1;
	#(2*CLK) rst_n	= 0;
	#(2*CLK) rst_n	= 1;
	f1 = $fopen("./dump/05_22_17_09_28.csv", "r");
	for(i=0;i<10;i=i+1) begin
		$fscanf(f1, "%d,%d,%d,%d,%d", a,b,c,d,e);
		$display("%d %d", b,c);
	end
	$fclose(f1);	
	@(posedge clk);
	$finish;
end

//time upper bound
initial begin
	#(MAX_CLK*CLK)
	$display("Too slow, abort.");
	$finish;
end

endmodule
