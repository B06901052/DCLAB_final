timeunit		1ns;
timeprecision	1ns;

module Controller (
	input		i_clk,
	input		i_rst_n,
	input [1:0] i_mode,//0~2:1P easy, normal, hard; 3:2P
	input		i_start,
	input		i_surrender,
	input 		i_prestep,
	input		i_check,
	input [2:0]	i_row,
	input [2:0]	i_col,
);

/*================================================================*
 * LOCALPARAM
 *================================================================*/
localparam S_IDLE	= 0;
localparam S_1P_AI	= 1;
localparam S_1P_YOU	= 2;
localparam S_2P		= 3;
/*================================================================*
 * REG/WIRE
 *================================================================*/
logic [1:0]	state;
logic 		order_r, order_w, ai_done, updater_done, fin;
logic [1:0] board_r [0:7][0:7], board_w[0:7][0:7], pre_board_r [0:7][0:7], pre_board_w[0:7][0:7];

integer si, sj, ci, cj;
/*================================================================*
 * ASSIGN
 *================================================================*/

/*================================================================* 
 * Combination
 *================================================================*/ 
always_comb begin
	order_w	= (S_IDLE) ? ~order_r : order_r;
	if (i_start) begin
		board_w[3][3]	= 0;
		board_w[4][4]	= 0;
		board_w[3][4]	= 1;
		board_w[4][3]	= 1;
	end else if (fin || i_surrender) begin
		for (ci = 0; ci < 8; ci = ci + 1) begin
			for (cj = 0; cj < 8; cj = cj + 1) begin
				board_w[ci][cj]	= 2;
			end
		end		
	end else begin
		
	end
end
/*================================================================*
 * Sequential (state)
 *================================================================*/ 
always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state			<= S_IDLE;
		order_r			<= 0;
		for (si = 0; si < 8; si = si + 1) begin
			for (sj = 0; sj < 8; sj = sj + 1) begin
				board_r[si][sj]	<= 2;
			end
		end
	end else begin
		case (state)
		S_IDLE:state	<= (&i_mode) ? S_2P : ((random) ? S_1P_AI : S_1P_YOU);
		S_1P_AI:state	<= (ai_done) ? S_1P_YOU : state;
		S_1P_YOU:state	<= (updater_done) ? S_1P_AI : state;
		S_2P:state		<= state;
		endcase
		order_r			<= order_w;
		for (si = 0; si < 8; si = si + 1) begin
			for (sj = 0; sj < 8; sj = sj + 1) begin
				board_r[si][sj]	<= board_w[si][sj];
			end
		end
	end
end
/*================================================================* 
 * Module 
 *================================================================*/
AI ai0(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_start(),
	.i_color(),
	.i_current_board(board_r),
	.o_updated_board(ai),
 	.o_done(ai_done),
	.o_end(fin),
);


endmodule