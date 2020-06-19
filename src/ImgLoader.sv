timeunit		1ns;
timeprecision	1ns;

module ImgLoader #(
	parameter HEIGHT	= 480,
	parameter WIDTH		= 800
)(
	input		  	i_start,
	//avm
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
logic [31:0]	avm_writedata_r;
logic [4:0] 	avm_address_r, avm_address_w;
logic			avm_read_r, avm_read_w, avm_write_r, avm_write_w;
logic [15:0]	data_r, data_w;
logic [19:0]	addr_r, addr_w;
logic [20:0]	counter_r, counter_w;


/*================================================================*
 * ASSIGN
 *================================================================*/
assign avm_address  = avm_address_r;
assign avm_read     = avm_read_r;
assign avm_write    = avm_write_r;
assign avm_writedata= avm_writedata_r;
assign o_data		= data_r;
assign o_address	= addr_r;

/*================================================================* 
 * Combination
 *================================================================*/
always_comb begin
	data_w			= data_r;
	counter_w		= counter_r;
	addr_w			= addr_r;
	avm_address_w	= avm_address_r;
	avm_read_w		= avm_read_r;
	avm_write_w		= avm_write_r;
	case(avm_address_r)
	RX_BASE: begin
		if (!avm_waitrequest)
			avm_address_w	= STATUS_BASE;
	end
	TX_BASE: begin
		if (!avm_waitrequest) begin
			avm_read_w		= 1;
			avm_write_w		= 0;
			avm_address_w	= STATUS_BASE;
		end
	end
	default: begin
		if ((state_r == S_LOAD) && avm_readdata[RX_OK_BIT] && !avm_waitrequest) begin
			avm_address_w	= RX_BASE;
		end else if (state_r == S_SEND && avm_readdata[TX_OK_BIT] && !avm_waitrequest) begin
			avm_read_w		= 0;
			avm_write_w		= 1;
			avm_address_w	= TX_BASE;
		end
	end
	endcase
	case(state_r)
	S_IDLE: begin
	if (i_start) begin
		data_w			= 0;
		counter_w		= 0;
		addr_w			= 0;
		avm_address_w	= STATUS_BASE;
	end
	S_LOAD: begin
	end
	S_SEND: begin
	end
	end if (state_r) begin
		avm_address_w	= ((avm_address_r == RX_BASE && avm_waitrequest) || 
						   (avm_readdata[RX_OK_BIT] && !avm_waitrequest)) ? RX_BASE : STATUS_BASE;
		if (avm_address_r == RX_BASE && !avm_waitrequest) begin
			counter_w	= counter_r + 1;
			data_w	= {data_r[7:0], avm_readdata[7:0]};
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
		data_r        <= 0;
		counter_r		<= 0;
		addr_r			<= 0;
		avm_address_r   <= STATUS_BASE;
		state_r         <= S_IDLE;
	end else begin
		data_r        <= data_w;
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