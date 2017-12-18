module REG_FILE (
	Reset,
	Clk,
	Addr_A,
	Addr_B,
	Addr_C,
	RegPort_C,
	Write_RegC,
	RegPort_A,
	RegPort_B,
	I_REG_FILE_on,
       	enable_signal
);
input		Reset,		// Reset for initialising registers
		Clk;		// CPU Clock

input [6:0]	Addr_A,		// Address for port A
		Addr_B,		// Address for port B
		Addr_C;		// Address for port C

input [15:0]	RegPort_C;	// Wr Data for port C

input		Write_RegC;
input 		I_REG_FILE_on;
input		enable_signal;
output [15:0]	RegPort_A,	// Data Out of port A
		RegPort_B;	// Data Out of port A

reg [15:0] Reg_Array [3:0];

integer i;

// REG_FILE write

always @ (posedge Clk)
begin
  for (i = 3; i >= 0; i = i - 1)
    if (Reset)
      Reg_Array[i] <= 16'b0000000000000000;

  if (Write_RegC)
      Reg_Array[Addr_C] <= RegPort_C;

end

assign  RegPort_A = Reg_Array[Addr_A];
assign  RegPort_B = Reg_Array[Addr_B];

endmodule
