/*
 * Copyright (c) 2024 K.Makise
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_kmakise_soc (
`ifdef USE_POWER_PINS
    inout             VPWR,
    inout             VGND,
`endif
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
//the bi-direction IO
assign uio_oe  = 8'b00010000; 
assign uio_out[7] = 1'b0;
assign uio_out[6] = 1'b0;
assign uio_out[5] = 1'b0;
assign uio_out[3] = 1'b0;
assign uio_out[2] = 1'b0;
assign uio_out[1] = 1'b0;
assign uio_out[0] = 1'b0;
//the noraml output IO
assign uo_out[0] = 1'b0;
assign uo_out[1] = 1'b0;
assign uo_out[2] = 1'b0;
assign uo_out[3] = 1'b0;
assign uo_out[4] = 1'b0;
assign uo_out[5] = 1'b0;

wire reset;
wire rx_enable;
wire rx_ready;
wire rx_valid;
wire [7:0] rx_data_out;
wire tx_enable;
wire tx_valid;
wire [7:0] tx_data_in;
wire tx_ready;
wire csb_n;
wire we_n;
wire [4:0] addr;
wire [31:0] sram_data_in;
wire [31:0] sram_data_out;
//wire [32:0] sram_data_out_full;
//wire [32:0] sram_data_in_full;
wire rx_in;
wire tx_out;
wire i_rst;
wire [31:0] sram_addr_serv;
wire [31:0] sram_data_read_serv;
wire [31:0] sram_data_write_serv;
wire sram_cs;
wire sram_we;
wire sram_ack;
wire [3:0] sram_wmask;
wire [3:0] wmask;
wire cs;
//assign sram_data_in_full = {1'b0, sram_data_in};
assign reset = ~rst_n;
assign rx_in = ui_in[3];
assign uio_out[4] = tx_out;
assign cs = ~csb_n;
//============================================//
//=================INSTANCES==================//
//============================================//
UARTReceiver UARTReceiver_ins (
    .clk (clk),      // clock
    .reset (reset),    // reset
    .enable (rx_enable),   // enable
    .in(rx_in),       // RX line
    .ready(rx_ready),    // OK to transmit
    .out (rx_data_out),      // received data
    .valid (rx_valid),    // RX completed
    .error(uo_out[7]),    // frame error
    .overrun(uo_out[6])   // overrun
);

UARTTransmitter UARTTransmitter_ins (
    .clk (clk),      // clock
    .reset(reset),    // reset
    .enable(tx_enable),   // TX enable
    .valid(tx_valid),    // start transaction
    .in(tx_data_in),       // data to transmit
    .out(tx_out),      // TX line
    .ready(tx_ready)     // ready for TX
);

SRAMController SRAMController_ins (
	.clk (clk),
	.rst_n (rst_n),
	// tx 
	.tx_ready (tx_ready),
	.tx_enable (tx_enable),
	.tx_valid (tx_valid), 
	.tx_data_in (tx_data_in),
	// rx
	.rx_data_out (rx_data_out),
	.rx_valid (rx_valid),
	.rx_enable (rx_enable),
	.rx_ready (rx_ready),
	// sram
	.csb_n (csb_n),
	.we_n (we_n),
	.addr (addr),
	//.sram_data_out (sram_data_out_full[31:0]),
	.sram_data_out (sram_data_out),
	.sram_data_in (sram_data_in),
	.wmask (wmask),
	// soc_serv
	.i_rst (i_rst), 
	.sram_addr_serv (sram_addr_serv),
	.sram_data_read_serv (sram_data_read_serv), 
	.sram_data_write_serv (sram_data_write_serv),
	.sram_cs (sram_cs),
	.sram_we (sram_we),
	.sram_ack (sram_ack),
	.sram_wmask (sram_wmask)
);
/*
myconfig_sky sram_ins (
`ifdef USE_POWER_PINS
    .vccd1(VDPWR),
    .vssd1(VGND),
`endif
  .clk0(clk), // clock
  .csb0(csb_n), // active low chip select
  .web0(we_n), // active low write control
  .addr0(addr),
  .spare_wen0(1'b0), // spare mask
  .din0(sram_data_in_full),
  .dout0(sram_data_out_full)
);
*/

RAM32 ram1 (
`ifdef USE_POWER_PINS
      .VPWR(VPWR),
      .VGND(VGND),
`endif
      .CLK (clk),
      .EN0 (cs),
      .A0  (addr),
      .WE0 (wmask),
      .Di0 (sram_data_in),
      .Do0 (sram_data_out)
  );
soc_serv_top soc_serv_top_ins(
	.clk (clk),
	.i_rst (i_rst),
	.i_timer_irq(ui_in[0]), 
	.sram_addr(sram_addr_serv),
	.sram_data_read(sram_data_read_serv),
	.sram_data_write(sram_data_write_serv),
	.sram_we(sram_we),//only dbus could write
	.sram_cs(sram_cs),//select mem
	.sram_ack(sram_ack),
	.sram_wmask(sram_wmask)
);
endmodule
