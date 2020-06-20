timeunit		10ns;
timeprecision	10ns;

module Controller (
	input		i_clk,
	input		i_rst_n,
	input [1:0] i_mode,//0~2:1P easy, normal, hard; 3:2P
	input		i_start,
	input		i_surrender,
	input 		i_prestep,
	input [2:0]	i_row,
	input [2:0]	i_col,
	input		i_player_done
);

/*================================================================*
 * LOCALPARAM
 *================================================================*/
localparam S_IDLE		= 0;
localparam S_AI			= 1;
localparam S_YOU		= 2;
localparam S_UPDATE		= 3;
localparam S_CHECK		= 4;
/*================================================================*
 * REG/WIRE
 *================================================================*/
//control
logic [2:0]	state;
logic 		corder_r, corder_w;	//current order
logic		porder_r, porder_w;	//player order
logic		enai_r, enai_w;		//enable ai
logic		random_r, random_w;
logic		ai_start_r, ai_start_w;
logic		up_start_r, up_start_w;
logic [6:0] count_r, count_w;
logic		fin_r, fin_w;
//board
logic [1:0] board_r [0:7][0:7], board_w[0:7][0:7];
logic [1:0]	pre_board_r [0:7][0:7], pre_board_w[0:7][0:7];
//AI
wire		ai2up_start;
wire [2:0]	ai2up_row, ai2up_col;
wire		ai_done;
wire [1:0]	ai_board [0:7][0:7];
//updater
wire [4:0]	up_flip;
wire [1:0]	up_board [0:7][0:7];
wire		up_start, up_done, up_fin;

integer si, sj, ci, cj;
/*================================================================*
 * ASSIGN
 *================================================================*/
assign up_start	= (state == S_AI) ? ai2up_start : up_start_r;
assign up_row	= (state == S_AI) ? ai2up_row : i_row;
assign up_col	= (state == S_AI) ? ai2up_col : i_col;
/*================================================================* 
 * Combination
 *================================================================*/
// control
always_comb begin
	corder_w	= corder_r;
	porder_w	= porder_r;
	enai_w		= enai_r;
	random_w	= ~random_r;
	ai_start_w	= 0;
	up_start_w	= 0;
	count_w		= count_r;
	fin_w		= 0;

	case (state)
	S_IDLE: begin
		if (i_start) begin
			corder_w	= 0;
			porder_w	= random_r;
			enai_w		= ~&i_mode;
			if (enai_w && porder_w)
				ai_start_w	= 1;
		end
	end
	S_AI: begin
		if (ai_done) begin
			up_start_w	= 1;
			count_w		= 0;
			corder_w	= ~corder_r;
		end
	end
	S_YOU: begin
		if (i_player_done)
			up_start_w	= 1;
	end
	S_UPDATE: begin
		if (up_done && (|up_flip)) begin
			up_start_w	= 1;
			count_w		= 0;
			corder_w	= ~corder_r;
		end
	end
	S_CHECK: begin
		if (up_done) begin
			count_w	= count_r + 1;
			if (&count_r && ~|up_flip)
				fin_w	= 1;
			if (count_r == 7'b011_1111)
				corder_w= ~corder_r;
			if (&{(|up_flip), enai_r, (corder_r^porder_r)})
					ai_start_w	= 1;
		end
	end
	endcase
end

// board
task assign_board(
	input [1:0]	board [0:7][0:7]
);
	for (ci = 0; ci < 8; ci = ci + 1) begin
		for (cj = 0; cj < 8; cj = cj + 1)
			board_w[ci][cj]	= board[ci][cj];
	end
endtask
task assign_pre_board(
	input [1:0]	board [0:7][0:7]
);
	for (ci = 0; ci < 8; ci = ci + 1) begin
		for (cj = 0; cj < 8; cj = cj + 1)
			pre_board_w[ci][cj]	= board[ci][cj];
	end
endtask
always_comb begin
	assign_board(board_r);
	assign_pre_board(pre_board_r);
	if (fin_r || i_surrender) begin
		for (ci = 0; ci < 8; ci = ci + 1) begin
			for (cj = 0; cj < 8; cj = cj + 1)
				board_w[ci][cj]	= 2;
				pre_board_w[ci][cj] = 2;
		end		
	end
	case (state)
	S_IDLE: begin
		if (i_start) begin
			board_w[3][3]		= 0;
			board_w[4][4]		= 0;
			board_w[3][4]		= 1;
			board_w[4][3]		= 1;
			pre_board_w[3][3]	= 0;
			pre_board_w[4][4]	= 0;
			pre_board_w[3][4]	= 1;
			pre_board_w[4][3]	= 1;
		end
	end
	S_UPDATE: begin
		if (up_done && |up_flip)
			assign_board(up_board);
			assign_board(board_r);
	end
	S_AI: begin
		if (ai_done)
			assign_board(ai_board);
			assign_board(board_r);
	end
	endcase
end
/*================================================================*
 * Sequential (state)
 *================================================================*/ 
always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		//Control
		state		<= S_IDLE;
		corder_r	<= 0;
		porder_r	<= 0;
		enai_r		<= 0;
		random_r	<= 0;
		ai_start_r	<= 0;
		up_start_r	<= 0;
		count_r		<= 0;
		fin_r		<= 0;
		//board
		for (si = 0; si < 8; si = si + 1) begin
			for (sj = 0; sj < 8; sj = sj + 1) begin
				board_r[si][sj]		<= 2;
				pre_board_r[si][sj]	<= 2;
			end
		end
		//updater


	end else begin
		case (state)
		S_IDLE:
			state	<= (i_start) ? ((~&i_mode && random_r) ? S_AI : S_YOU) : state;
		S_AI:
			state	<= (ai_done) ? S_CHECK : state;
		S_YOU:
			state	<= (i_player_done) ? S_UPDATE : state;
		S_UPDATE:
			state	<= (up_done) ? ((|up_flip) ? S_CHECK : S_YOU) : state;
		S_CHECK: begin
			if (up_done) begin
				if (|up_flip) begin
					if (enai_r & (corder_r^porder_r)) begin
						state	<= S_AI;
					end else begin
						state	<= S_YOU;
					end
				end else if (&count_r) begin
					state		<= S_IDLE;
				end else
					state		<= state;
			end else
				state			<= state;
		end
		endcase
		random_r		<= random_w;
		porder_r	<= porder_w;
		for (si = 0; si < 8; si = si + 1) begin
			for (sj = 0; sj < 8; sj = sj + 1)
				board_r[si][sj]	<= board_w[si][sj];
		end
	end
end
/*================================================================* 
 * Module 
 *================================================================*/
AI ai0(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_start(ai_start_r),
	.i_color(corder_r),
	.i_current_board(board_r),
	.o_updated_board(ai_board),
 	.o_done(ai_done),
	//for updater
	.i_upboard(up_board),
	.i_flip(up_flip),
	.i_done(up_done),
	.o_up_start(ai2up_start),
	.o_row(ai2up_row),
	.o_col(ai2up_col)
);

updater up0(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	//MUX part
	.i_start(up_start),
	.i_color(corder_r),
	.i_row(up_row),
	.i_col(up_col),
	//common part
	.i_current_board(board_r),
	.o_updated_board(up_board),
	.o_flip(up_flip),
	.o_done(up_done)
);
endmodule