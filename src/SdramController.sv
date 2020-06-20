timeunit		10ns;
timeprecision	10ns;

module SdramController (
	input			i_clk,
	input			i_rst_n,
    // Interface
    input           i_read,
    input           i_write,
    input   [25:0]  i_addr,//2*64MB / 16 bits= 2**6 * 2**20
    inout   [15:0]  io_data,
    output          o_done,
    // SDRAM Controller
    output  [24:0]  o_avm_address,
    output  [3:0]   o_avm_byteenable,
    output          o_avm_chipselect,
    output  [31:0]  o_avm_writedata,
    output          o_avm_read,
    output          o_avm_write,
    input   [31:0]  i_avm_readdata,
    input           i_avm_readdatavalid,
    input           i_avm_waitrequest
);

/*================================================================*
 * LOCALPARAM
 *================================================================*/
localparam S_IDLE	= 0;
localparam S_READ	= 1;
localparam S_WRITE	= 3;

/*================================================================*
 * REG/WIRE
 *================================================================*/
logic [1:0]		state;
logic [25:0]	addr_r, addr_w;
logic 			read_r, read_w, write_r, write_w, oen_r, oen_w, done_r, done_w;
logic [15:0]	data_r, data_w;

/*================================================================*
 * ASSIGN
 *================================================================*/
assign o_avm_chipselect	= 1'b1;
assign o_avm_address	= addr_r[25:1];
assign o_avm_read		= read_r;
assign o_avm_write		= write_r;
assign o_avm_byteenable = (addr_r[0]) ? 4'b1100 : 4'b0011;
assign o_avm_writedata	= (addr_r[0]) ? {data_r,16'b0} : {16'b0,data_r};
assign io_data			= oen_r ? data_r : 16'hzzzz;
assign o_done			= done_r;

assign read_condition	= (i_read & ~i_write) | (read_r & ~write_r);
assign write_condition	= (i_read & ~i_write) | (read_r & ~write_r);
/*================================================================*
 * Sequential (state)
 *================================================================*/ 
always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
        oen_r	<= 0;
		read_r	<= 0;
		write_r	<= 0;
        addr_r	<= 0;
        data_r	<= 0;
        done_r	<= 0;
        state	<= S_IDLE;		
	end else begin
        oen_r	<= oen_w;
		read_r	<= read_w;
		write_r	<= write_w;
        addr_r	<= addr_w;
        data_r	<= data_w;
        done_r	<= done_w;
		case (state)
		S_IDLE: begin
			if (~i_avm_waitrequest) begin
				if (read_condition) begin
					state	<= S_READ;
				end else if (write_condition) begin
					state	<= S_WRITE;
				end
			end
		end
		S_READ: state	<= (i_avm_readdatavalid) ? S_IDLE : S_READ;
		S_WRITE:state	<= (i_avm_waitrequest) ? S_WRITE : S_IDLE;
		default:state	<= state;
		endcase
	end
end

/*================================================================* 
 * Combination
 *================================================================*/ 
always_comb begin
    oen_w	= oen_r;
    addr_w	= addr_r;
	read_w	= read_r;
	write_w	= write_r;
	data_w	= data_r;
    done_w	= 0;

	case (state)
	S_READ: begin
		if (i_avm_readdatavalid) begin
			read_w	= 0;
			oen_w	= 1;
			data_w	= (addr_r[0]) ? i_avm_readdata[31:16] : i_avm_readdata[15:0];
			done_w	= 1;
		end
	end
	S_WRITE: begin
		if (~i_avm_waitrequest) begin
			write_w	= 0;
			done_w	= 1;
		end
	end
	default: begin
        if (read_condition) begin
			read_w	= 1;
			addr_w	= i_addr;
		end else if (write_condition) begin
			write_w	= 1;
			addr_w	= i_addr;
			data_w	= io_data;
		end
	end
	endcase
end
endmodule