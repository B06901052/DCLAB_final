timeunit		1ns;
timeprecision	1ns;

module ImgSender #(
	parameter HEIGHT	= 480,
	parameter WIDTH		= 800,
	parameter XOFFSET	= 40,
	parameter YOFFSET	= 40,
	parameter BLOCK		= 50,
	parameter MARGIN	= 8
)(
	input			i_clk,
	input			i_rst_n,
	input	[1:0]	i_board [0:7][0:7],
	//sram
	input	[15:0]	i_data,
	output	[19:0]	o_addr,
	//img
	input  	[9:0]	i_x,
	input	[8:0]	i_y,
	output 	[23:0]	o_pixel
);
/*================================================================*
 * REG/WIRE
 *================================================================*/
//img
logic [9:0]		xi_r, xi_w, xf_r, xf_w, x_r, x_w;
logic [8:0]		yi_r, yi_w, yf_r, yf_w;
logic [23:0]	pixel_r, pixel_w;
logic [7:0]		buffer_r, buffer_w;
logic 			count_r, count_w;
//board
logic [2:0]		col_r, col_w, row_r, row_w;
logic [1:0]		board_r [0:7][0:7], board_w [0:7][0:7];//W0B1N2

wire  [23:0]	next_rgb;
wire			condition;
integer 		si, sj, ci, cj;
/*================================================================*
 * ASSIGN
 *================================================================*/
assign o_pixel	= pixel_r;
assign o_addr	= {(i_x==799 && i_y==479) ? 0 : i_x + i_y * 800 + 1, count_r};
assign condition= &{(xi_r <= i_x), (i_x < xf_r), (yi_r <= i_y), (i_y < yf_r)};
assign next_rgb	= (condition && !board_r[row_r][col_r][1]) ? {24{!board_r[row_r][col_r][0]}} : {buffer_r, i_data};
/*================================================================*
 * Sequential (state)
 *================================================================*/ 
always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		//img
		///boundary
		xi_r		<= XOFFSET + MARGIN;
		xf_r		<= XOFFSET + BLOCK - MARGIN;
		yi_r		<= YOFFSET + MARGIN;
		yf_r		<= YOFFSET + BLOCK - MARGIN;
		///img
		x_r			<= 0;	//pre_x_position
		pixel_r		<= '1;	//RGB
		buffer_r	<= '1;	//store R
		count_r		<= 0;	//count whether buffer is prepared
		//board
		col_r		<= 0;
		row_r		<= 0;
		for (si = 0; si < 8; si = si + 1) begin
			for(sj = 0; sj < 8; sj = sj + 1) begin
				board_r[si][sj]	<= 2;
			end
		end
	end else begin
		//img
		xi_r		<= xi_w;
		xf_r		<= xf_w;
		x_r			<= x_w;
		yi_r		<= yi_w;
		yf_r		<= yf_w;
		pixel_r		<= pixel_w;
		buffer_r	<= buffer_w;
		count_r		<= count_w;
		//board
		col_r		<= col_w;
		row_r		<= row_w;
		for (si = 0; si < 8; si = si + 1) begin
			for(sj = 0; sj < 8; sj = sj + 1) begin
				board_r[si][sj]	<= board_w[si][sj];
			end
		end
	end
end

/*================================================================* 
 * Combination
 *================================================================*/
//img
always_comb begin
	x_w			= i_x + 1;
	count_w		= x_r[0] ^ i_x[0];
	buffer_w	= (!count_r) ? i_data[7:0] : buffer_r;
	pixel_w		= (count_r) ? next_rgb : pixel_r;
	for (ci = 0; ci < 8; ci = ci + 1) begin
		for(cj = 0; cj < 8; cj = cj + 1) begin
			board_w[ci][cj]	= (ci+cj)%3;
		end
	end
end

//boundary
always_comb begin
	xi_w	= xi_r;
	xf_w	= xf_r;
	yi_w	= yi_r;
	yf_w	= yf_r;
	col_w	= col_r;
	row_w	= row_r;

	if (i_x == xf_r) begin
		if (xf_r == (XOFFSET + 8*BLOCK - MARGIN)) begin
			xi_w	= XOFFSET + MARGIN;
			xf_w	= XOFFSET + BLOCK - MARGIN;
			col_w	= 0;
		end else begin
			xi_w	= xi_r + BLOCK;
			xf_w	= xf_r + BLOCK;
			col_w	= col_r + 1;
		end
	end
	
	if (i_y == yf_r) begin
		if (yf_r == (YOFFSET + 8*BLOCK - MARGIN)) begin
			yi_w	= YOFFSET + MARGIN;
			yf_w	= YOFFSET + BLOCK - MARGIN;
			row_w	= 0;
		end else begin
			yi_w	= yi_r + BLOCK;
			yf_w	= yf_r + BLOCK;
			row_w	= row_r + 1;
		end
	end
end
endmodule