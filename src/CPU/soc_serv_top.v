`default_nettype none
module soc_serv_top (
	input  wire        clk,
	input  wire        i_rst,
	input  wire        i_timer_irq, 
	output wire [31:0] sram_addr,
	input  wire [31:0] sram_data_read,
	output wire [31:0] sram_data_write,
	output wire        sram_we,//only dbus could write
	output wire        sram_cs,//select mem
	input  wire        sram_ack,
	output wire [3:0]  sram_wmask
);
//============INTERNAL_SIGNAL===========//
wire [31:0] o_ibus_adr;
wire [31:0] o_dbus_adr;
wire        i_ibus_ack;
wire        i_dbus_ack;
wire        o_ibus_cyc;
wire        o_dbus_cyc;
wire [31:0] o_dbus_dat;
wire        o_dbus_we;
// Arbiter
// simple implementation, since in fact ibus & dbus will not be active at the same time
assign i_ibus_ack      = sram_ack & !o_dbus_cyc;
assign i_dbus_ack      = sram_ack & !o_ibus_cyc;
assign sram_addr       = o_ibus_cyc ? (o_ibus_adr >> 2) : (o_dbus_adr >> 2); //translate to the exact SRAM address 
assign sram_data_write = o_dbus_dat;
assign sram_we = o_dbus_we & !o_ibus_cyc;
assign sram_cs = o_ibus_cyc | o_dbus_cyc;
//======================================//
//=============INSTANCES================//
//======================================//
serv_rf_top serv_rf_top_ins(
   .clk(clk),
   .i_rst(i_rst),
   .i_timer_irq(i_timer_irq),
   .o_ibus_adr(o_ibus_adr),
   .o_ibus_cyc(o_ibus_cyc),
   .i_ibus_rdt(sram_data_read),
   .i_ibus_ack(i_ibus_ack),
   .o_dbus_adr(o_dbus_adr),
   .o_dbus_dat(o_dbus_dat),
   .o_dbus_sel(sram_wmask), 
   .o_dbus_we(o_dbus_we) ,
   .o_dbus_cyc(o_dbus_cyc),
   .i_dbus_rdt(sram_data_read),
   .i_dbus_ack(i_dbus_ack),

   // below unused
   // Extension
   .o_ext_rs1(),
   .o_ext_rs2(),
   .o_ext_funct3(),
   .i_ext_rd(32'd0),
   .i_ext_ready(1'b0),
   // MDU
   .o_mdu_valid()
);
endmodule