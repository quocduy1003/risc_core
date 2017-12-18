module  PRGRM_CNT (
	Reset,
	Clk,
	Incrmnt_PC,
	Ld_Brnch_Addr,
	Ld_Rtn_Addr,
	Imm_Addr,
	Return_Addr,
	PC
);
input		Reset,		// Reset for the PC
		Clk,		// CPU Clock
		Incrmnt_PC,	// Increment PC
		Ld_Brnch_Addr,	// Load Jmp/Call Addr from instruction
		Ld_Rtn_Addr;	// Load Return Addr
input [7:0]	Imm_Addr,	// Immediate Addr for Jmp/Call
		Return_Addr;	// Return addr from Stack

output [7:0]	PC;		// Addr of instruction to be fetched in
                                // the next Fetch Cycle
reg [7:0] PCint;

always @ (posedge Clk)
begin
  if (Reset)
    PCint <= 8'b00000000;
  else if (Incrmnt_PC)		// Occurs in WRITEBACK cycle
    PCint <= PCint + 1;
  else if (Ld_Rtn_Addr)		// Occurs in WRITEBACK cycle
    PCint <= Return_Addr;
  else if (Ld_Brnch_Addr)	// Occurs in WRITEBACK cycle
    PCint <= Imm_Addr;
end

assign PC = PCint;

endmodule
