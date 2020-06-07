timeunit		1ns;
timeprecision	1ns;

module Top (
	input		i_clk,
	input		i_rst_n,
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
localparam S_IDLE = 0;

/*================================================================*
 * REG/WIRE
 *================================================================*/
logic	state_r;

/*================================================================*
 * ASSIGN
 *================================================================*/

/*================================================================*
 * Sequential (state)
 *================================================================*/ 
always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
	
	end else begin
		case (state_r)
		S_IDLE:begin
		
		end
		default:begin
		
		end
		endcase
	end
end

/*================================================================* 
 * Combination
 *================================================================*/ 
always_comb begin
	
end

/*================================================================* 
 * Module 
 *================================================================*/

endmodule