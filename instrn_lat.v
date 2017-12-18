
module INSTRN_LAT (
	Clk,
	Instrn,
	Latch_Instr,
	Crnt_Instrn_1,
	Crnt_Instrn_2
);

input		Clk;		// CPU Clock
input [31:0]	Instrn;		// Instrn for 
input		Latch_Instr;	// Enable for latching instruction
output [31:0]	Crnt_Instrn_1;
output [31:0]	Crnt_Instrn_2;	// Instrn under/about to be processed

reg [31:0]	Crnt_Instrn_1;
reg [31:0]	Crnt_Instrn_2;

always @ (posedge Clk)
begin
  if (Latch_Instr) begin
    Crnt_Instrn_1 <= Instrn;
    Crnt_Instrn_2 <= Instrn;
  end
end

endmodule
