module DE2_115 (
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);

/*================================================================*
 * REG/WIRE
 *================================================================*/
// Control
logic sys_clk, sys_rst_n;
logic key1down, key2down, key3down;
logic CLK_12M, CLK_100K, CLK_800K;
assign AUD_XCK	= CLK_12M;

//SDRAM I/O
logic w_mem_read, w_mem_write, w_mem_done;
logic [25:0] w_mem_addr;
wire [15:0] w_mem_data;
assign w_men_read	= key1down;
assign w_mem_write	= key2down;
assign w_mem_addr	= {8'b0, SW[17:0]};
assign LEDR[15:0]	= w_mem_data;
assign w_mem_data	= (w_mem_write) ? SW + 1 : 16'hzzzz;
assign LEDG[0]		= w_mem_done;

// Memory Controller Wires
logic [24:0] w_avm_address;
logic [3:0]  w_avm_byteenable;
logic        w_avm_chipselect;
logic [31:0] w_avm_writedata;
logic        w_avm_read;
logic        w_avm_write;
logic [31:0] w_avm_readdata;
logic        w_avm_readdatavalid;
logic        w_avm_waitrequest;

/*================================================================* 
 * Module 
 *================================================================*/
Debounce deb1(
	.i_in(KEY[1]),
	.i_rst_n(sys_rst_n),
	.i_clk(sys_clk),
	.o_neg(key1down) 
);

Debounce deb2(
	.i_in(KEY[2]),
	.i_rst_n(sys_rst_n),
	.i_clk(sys_clk),
	.o_neg(key2down) 
);
Debounce deb3(
	.i_in(KEY[3]),
	.i_rst_n(sys_rst_n),
	.i_clk(sys_clk),
	.o_neg(key3down) 
);

SdramController sdramcontroller0(
    .i_clk(sys_clk),
    .i_rst_n(sys_rst_n),
    .i_read(w_mem_read),
    .i_write(w_mem_write),
    .i_addr(w_mem_addr),
    .io_data(w_mem_data),
    .o_done(w_mem_done),
    .o_avm_address(w_avm_address),
    .o_avm_byteenable(w_avm_byteenable),
    .o_avm_chipselect(w_avm_chipselect),
    .o_avm_writedata(w_avm_writedata),
    .o_avm_read(w_avm_read),
    .o_avm_write(w_avm_write),
    .i_avm_readdata(w_avm_readdata),
    .i_avm_readdatavalid(w_avm_readdatavalid),
    .i_avm_waitrequest(w_avm_waitrequest)
);

qsys qsys0(
	//basic
    .clk_clk(CLOCK_50),
    .reset_reset_n(KEY[0]),
	//clk
	.altpll_clk_clk(sys_clk),
	.altpll_rst_n_reset(sys_rst_n),
	.sys_clk_clk(sys_clk),
	.clk12m_clk(CLK_12M),
	.clk800k_clk(CLK_800K),
	.clk100k_clk(CLK_100K),
	.sys_rst_n_reset(sys_rst_n),
	//avm
    .sdram_avm_address(w_avm_address),
    .sdram_avm_byteenable_n(~w_avm_byteenable),
    .sdram_avm_chipselect(w_avm_chipselect),
    .sdram_avm_writedata(w_avm_writedata),
    .sdram_avm_read_n(~w_avm_read),
    .sdram_avm_write_n(~w_avm_write),
    .sdram_avm_readdata(w_avm_readdata),
    .sdram_avm_readdatavalid(w_avm_readdatavalid),
    .sdram_avm_waitrequest(w_avm_waitrequest),
	.sdram_reset_reset_n(sys_rst_n),
	//wire
    .sdram_wire_addr(DRAM_ADDR),
    .sdram_wire_ba(DRAM_BA),
    .sdram_wire_cas_n(DRAM_CAS_N),
    .sdram_wire_cke(DRAM_CKE),
    .sdram_wire_cs_n(DRAM_CS_N),
    .sdram_wire_dq(DRAM_DQ),
    .sdram_wire_dqm(DRAM_DQM),
    .sdram_wire_ras_n(DRAM_RAS_N),
    .sdram_wire_we_n(DRAM_WE_N)
);

Top top0(
	.i_rst_n(sys_rst_n),
	.i_clk(CLK_12M),
	.i_key_0(key1down),
	.i_key_1(key2down),
	.i_key_2(key3down),
	.i_speed(SW[3:0]), // design how user can decide mode on your own
	.i_slow(SW[4]),

	// AudDSP and SRAM
	.o_SRAM_ADDR(SRAM_ADDR), // [19:0]
	.io_SRAM_DQ(SRAM_DQ), // [15:0]
	.o_SRAM_WE_N(SRAM_WE_N),
	.o_SRAM_CE_N(SRAM_CE_N),
	.o_SRAM_OE_N(SRAM_OE_N),
	.o_SRAM_LB_N(SRAM_LB_N),
	.o_SRAM_UB_N(SRAM_UB_N),
	
	// I2C
	.i_clk_100k(CLK_100K),
	.o_I2C_SCLK(I2C_SCLK),
	.io_I2C_SDAT(I2C_SDAT),
	
	// AudPlayer
	.i_AUD_ADCDAT(AUD_ADCDAT),
	.i_AUD_ADCLRCK(AUD_ADCLRCK),
	.i_AUD_BCLK(AUD_BCLK),
	.i_AUD_DACLRCK(AUD_DACLRCK),
	.o_AUD_DACDAT(AUD_DACDAT),
	.o_state(),//LEDG[2:0]
	.o_init(),//LEDG[4:3]
	.o_tmp()//LEDG[7:5]
);

SevenHexDecoder seven_dec0(
	.i_hex(),
	.o_seven_ten(),
	.o_seven_one()
);

// comment those are use for display
assign HEX0 = '1;
assign HEX1 = '1;
assign HEX2 = '1;
assign HEX3 = '1;
assign HEX4 = '1;
assign HEX5 = '1;
assign HEX6 = '1;
assign HEX7 = '1;


endmodule
