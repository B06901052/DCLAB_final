timeunit		1ns;
timeprecision	1ns;
tem
module ImgLoader #(
	parameter HEIGHT	= 640,
	parameter WIDTH		= 640
)(
	input		  	i_start,
	input         	avm_rst,
	input         	avm_clk,
	output  [4:0] 	avm_address,
	output        	avm_read,
	input  [31:0] 	avm_readdata,
	output        	avm_write,
	output [31:0] 	avm_writedata,
	input         	avm_waitrequest,

	output [19:0] 	o_address,
	output [15:0] 	o_data,
	output			o_fin
);

/*================================================================*
 * LOCALPARAM
 *================================================================*/
localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

//FSM
localparam S_IDLE		= 0;//receive 
localparam S_LOAD		= 1;

/*================================================================*
 * REG/WIRE
 *================================================================*/
logic			state_r, fin_r, fin_w;
logic [31:0]	avm_writedata_r;//current no usage
logic [15:0]	buffer_r, buffer_w;
logic [19:0]	addr_r, addr_w;
logic [20:0]	counter_r, counter_w;
logic [4:0] 	avm_address_r, avm_address_w;


/*================================================================*
 * ASSIGN
 *================================================================*/
assign avm_address  = avm_address_r;
assign avm_read     = 1;
assign avm_write    = 0;
assign avm_writedata= avm_writedata_r;//{{24'b0}, dec_r[BITS-256-8-:8]}
assign o_data		= data_r;
assign o_address	= addr_r;

/*================================================================* 
 * Combination
 *================================================================*/ 
if (avm_address_r == RX_BASE && !avm_waitrequest) begin
	buffer_r    		<= {buffer_r[7:0], avm_readdata[7:0]};
	row_counter_r + 1	<= (start_r) ? 0 : row_counter_r + 1;
end
always_comb begin
	// TODO
	buffer_w		= buffer_r;
	counter_w		= counter_r;
	addr_w			= addr_r;
	avm_address_w	= avm_address_r;
	if (i_start) begin
		buffer_w		= 0;
		counter_w		= 0;
		addr_w			= 0;
		avm_address_w	= STATUS_BASE;
	end if (state_r) begin
		avm_address_w	= ((avm_address_r == RX_BASE && avm_waitrequest) || 
					       (avm_readdata[RX_OK_BIT] && !avm_waitrequest)) ? RX_BASE : STATUS_BASE;
		if (avm_address_r == RX_BASE && !avm_waitrequest) begin
			counter_w	= counter_r + 1;
			buffer_w	= {buffer_r[7:0], avm_readdata[7:0]};
		end
		if (counter_r[1]) begin
			addr_w		= addr_r + 1;
		end
	end
end

/*================================================================*
 * Sequential (state)
 *================================================================*/ 
always_ff @(posedge avm_clk or posedge avm_rst) begin
	if (avm_rst) begin
		buffer_r        <= 0;
		counter_r		<= 0;
		addr_r			<= 0;
		avm_address_r   <= STATUS_BASE;
		state_r         <= S_IDLE;
	end else begin
		buffer_r        <= buffer_w;
		counter_r		<= counter_w;
		addr_r			<= addr_w;
		avm_address_r   <= avm_address_w;
		case(state_r)
		S_IDLE: state_r	<= (i_start) ? S_LOAD : S_IDLE;
		S_LOAD: state_r <= (fin_r)	 ? S_IDLE : S_LOAD;
		endcase
	end
end
endmodule