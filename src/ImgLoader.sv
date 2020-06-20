timeunit		10ns;
timeprecision	10ns;

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
localparam S_SEND		= 2;

/*================================================================*
 * REG/WIRE
 *================================================================*/
logic [1:0]		state;
logic			fin_r, fin_w;
logic [4:0] 	avm_address_r, avm_address_w;
logic			avm_read_r, avm_read_w, avm_write_r, avm_write_w;
logic [15:0]	data_r, data_w;
logic [19:0]	addr_r, addr_w;
logic 			count_r, count_w;


/*================================================================*
 * ASSIGN
 *================================================================*/
assign avm_address  = avm_address_r;
assign avm_read     = avm_read_r;
assign avm_write    = avm_write_r;
assign avm_writedata= {24'b0, data_r[15:8]};
assign o_data		= data_r;
assign o_address	= addr_r;

/*================================================================* 
 * Combination
 *================================================================*/
//avm
always_comb begin
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
		if (&{(state == S_LOAD), avm_readdata[RX_OK_BIT], !avm_waitrequest}) begin
			avm_address_w	= RX_BASE;
		end else if (&{(state == S_SEND), avm_readdata[TX_OK_BIT], (!avm_waitrequest)}) begin
			avm_read_w		= 0;
			avm_write_w		= 1;
			avm_address_w	= TX_BASE;
		end else begin
			avm_address_w	= STATUS_BASE;
		end
	end
	endcase
end

//data IO
always_comb begin
	data_w			= data_r;
	count_w			= count_r;
	addr_w			= addr_r;
	case(state)
	S_IDLE: begin
		if (i_start) begin
			data_w	= 0;
			count_w	= 0;
			addr_w	= 0;
		end
	end
	S_LOAD: begin
		if (addr_r[0] ~^ count_w) begin
			addr_w	= addr_r + 1;
		end
		if (avm_address_r == RX_BASE && !avm_waitrequest) begin
			if (addr_r[0]) begin
				data_w	= {data_w[7:0], avm_readdata[7:0]};
				count_w	= ~count_r;
			end else begin
				data_w	= {8'b0, avm_readdata[7:0]};
			end
		end
	end
	S_SEND: begin
		if (avm_address_r == TX_BASE && !avm_waitrequest) begin
			count_w	= ~count_r;
			data_w	= {data_r[7:0], 8'b0};
		end		
	end
	endcase
end

/*================================================================*
 * Sequential (state)
 *================================================================*/ 
always_ff @(posedge avm_clk or posedge avm_rst) begin
	if (avm_rst) begin
		data_r			<= 0;
		count_r			<= 0;
		addr_r			<= 0;
		avm_address_r	<= STATUS_BASE;
		avm_read_r		<= 1;
		avm_write_r		<= 0;
		state			<= S_IDLE;
	end else begin
		data_r			<= data_w;
		count_r			<= count_w;
		addr_r			<= addr_w;
		avm_address_r	<= avm_address_w;
		case(state)
		S_IDLE: state	<= (i_start)	? S_LOAD : state;
		S_LOAD: state	<= (count_r)	? S_SEND : state;
		S_SEND: state	<= (|addr_r)	? S_IDLE : ((count_r) ? S_LOAD : state);
		endcase
	end
end
endmodule