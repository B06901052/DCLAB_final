module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0,
	input i_key_1,
	input i_key_2,
	input [3:0] i_speed, // design how user can decide mode on your own
	input i_slow,
	// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  signed [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	// AudPlayer
	input  i_AUD_ADCDAT,
	input  i_AUD_ADCLRCK,
	input  i_AUD_BCLK,
	input  i_AUD_DACLRCK,
	output o_AUD_DACDAT,
	output [2:0] o_state,
	output [1:0] o_init,
	output [2:0] o_tmp
);

// design the FSM and states as you like
localparam S_IDLE       = 0;
localparam S_I2C        = 1;
localparam S_RECD       = 2;
localparam S_RECD_PAUSE = 3;
localparam S_PLAY       = 4;
localparam S_PLAY_PAUSE = 5;

logic [2:0] state_r, state_w;
logic init_start, init_fin;
logic rec_start_r, rec_pause_r, rec_stop_r, en_player;
logic dsp_start_r, dsp_pause_r, dsp_stop_r;
logic i2c_oen, i2c_sdat;
logic [19:0] addr_record, addr_play;
logic signed [15:0] data_record, data_play, dac_data;
logic tmp, tmp_nstart;

assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;//???if not acknowledge?

assign o_SRAM_ADDR = (state_r == S_RECD || state_r == S_RECD_PAUSE) ? addr_record : addr_play;//change
assign io_SRAM_DQ  = (state_r == S_RECD) ? data_record : 16'dz; // sram_dq as output
assign data_play   = (state_r != S_RECD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;
assign o_state	   = state_r;
assign o_init	   = {init_fin, init_start};
assign o_tmp	   = {tmp, tmp_nstart, 1'b0};
assign state_w	   = state_r;
// below is a simple example for module division
// you can design these as you like

// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_start(init_start),
	.o_finished(init_fin),
	.o_sclk(o_I2C_SCLK),
	.o_sdat(i2c_sdat),
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_start(dsp_start_r),
	.i_pause(dsp_pause_r),
	.i_stop(dsp_stop_r),
	.i_speed(i_speed[2:0]),
	.i_fast(i_speed[3]),
	.i_slow_0(~i_slow), // constant interpolation
	.i_slow_1(i_slow), // linear interpolation
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(data_play),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play),
	.o_en(en_player)
);

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_en(en_player), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(o_AUD_DACDAT)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and save to SRAM
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(rec_start_r),
	.i_pause(rec_pause_r),
	.i_stop(rec_stop_r),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record),
	.o_data(data_record)
);

//sequencial
always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r 	<= S_IDLE;
		tmp			<= 1;
	end else if (tmp) begin
		state_r		<= S_I2C;
		tmp			<= 0;
	end else if (init_fin) begin
		state_r		<= S_IDLE;
	end else begin
		case(state_r)
			S_IDLE:begin
				if (i_key_0) begin
					Control(1,0,0,0,0,0,S_RECD);
				end else if (i_key_1) begin
					Control(0,0,0,1,0,0,S_PLAY);
				end else if (i_key_2) begin
					Control(0,0,1,0,0,1,S_IDLE);
				end else begin
					Control(0,0,0,0,0,0,S_IDLE);
				end
			end
			S_RECD:begin
				if (i_key_0) begin
					Control(0,1,0,0,0,0,S_RECD_PAUSE);
				end else if (i_key_1) begin
					Control(0,0,1,1,0,0,S_PLAY);
				end else if (i_key_2 || o_SRAM_ADDR == '1) begin//change
					Control(0,0,1,0,0,1,S_IDLE);
				end else begin
					Control(0,0,0,0,0,0,S_RECD);
				end
			end
			S_RECD_PAUSE:begin
				if (i_key_0) begin
					Control(1,0,0,0,0,0,S_RECD);
				end else if (i_key_1) begin
					Control(0,0,1,1,0,0,S_PLAY);
				end else if (i_key_2) begin
					Control(0,0,1,0,0,1,S_IDLE);
				end else begin
					Control(0,0,0,0,0,0,S_RECD_PAUSE);
				end
			end
			S_PLAY:begin
				if (i_key_0) begin
					Control(1,0,0,0,0,1,S_RECD);
				end else if (i_key_1) begin
					Control(0,0,0,0,1,0,S_PLAY_PAUSE);
				end else if (i_key_2 || o_SRAM_ADDR[19:4] == '1) begin//change
					Control(0,0,1,0,0,1,S_IDLE);
				end else begin
					Control(0,0,0,0,0,0,S_PLAY);
				end
			end
			S_PLAY_PAUSE:begin
				if (i_key_0) begin
					Control(1,0,0,0,0,1,S_RECD);
				end else if (i_key_1) begin
					Control(0,0,0,0,1,0,S_PLAY);//notice
				end else if (i_key_2) begin
					Control(0,0,1,0,0,1,S_IDLE);
				end else begin
					Control(0,0,0,0,0,0,S_PLAY_PAUSE);				
				end
			end
		endcase
	end
end

always_ff @(posedge i_clk_100k or negedge i_rst_n) begin
	if (!i_rst_n) begin
		init_start	<= 0;
		tmp_nstart	<= 1;
	end else if (state_r == S_I2C) begin
		if (tmp_nstart) begin
			init_start	<= 1;
			tmp_nstart	<= 0;
		end else
			init_start	<= 0;
	end

end

task Control;
    input c1, c2, c3, c4, c5, c6;
	input [2:0] c7;
    begin
        rec_start_r	<= c1;
		rec_pause_r	<= c2;
		rec_stop_r	<= c3;
		dsp_start_r	<= c4;
		dsp_pause_r	<= c5;
		dsp_stop_r	<= c6;
		state_r		<= c7;
    end
endtask

endmodule