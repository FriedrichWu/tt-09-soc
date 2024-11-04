/// sta-blackbox

`default_nettype none

module RAM32 (
`ifdef USE_POWER_PINS
    input VPWR,
    input VGND,
`endif
    input CLK,
    input [3:0] WE0,
    input EN0,
    input [4:0] A0,
    input [31:0] Di0,
    output reg [31:0] Do0
);
 
endmodule
