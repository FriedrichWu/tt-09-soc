# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = tt_um_kmakise_soc.v SRAMController.v UARTReceiver.v UARTTransmitter.v ../macro/RAM32.v /CPU/serv_aligner.v /CPU/serv_alu.v /CPU/serv_bufreg.v /CPU/serv_bufreg2.v /CPU/serv_compdec.v /CPU/serv_csr.v /CPU/serv_ctrl.v /CPU/serv_debug.v /CPU/serv_decode.v /CPU/serv_immdec.v /CPU/serv_mem_if.v /CPU/serv_rf_if.v /CPU/serv_rf_ram_if.v /CPU/serv_rf_ram.v /CPU/serv_rf_top.v /CPU/serv_state.v /CPU/serv_top.v /CPU/soc_serv_top.v 

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS 		+= -I$(SRC_DIR)

else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

# sram behavioral module
VERILOG_SOURCES += ../macro/RAM32.v 
endif

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# MODULE is the basename of the Python test file
ifneq ($(GATES),yes)

# rtl simulation
MODULE = test

else

# gate level simulation
# use different test file because the instance name will change after synthesis
MODULE = test_gl

endif


# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
