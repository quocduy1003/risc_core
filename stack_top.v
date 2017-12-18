module STACK_TOP ( 
	Reset,
	Clk,
	PushEnbl,
	PopEnbl,
	PushDataIn,
	PopDataOut,
	STACK_FULL,
	I_STACK_TOP_on,
	enable_signal
);

input		Reset,		// Reset
		Clk,		// Clock
		PushEnbl,	// Push cmd for stack
		PopEnbl;	// Pop cmd for stack

input [11:0]	PushDataIn;	// Data to be pushed into the stack 
input		I_STACK_TOP_on;
input		enable_signal;

output [11:0]	PopDataOut;	// Data popped out of the stack
output		STACK_FULL;	// Stack is full

wire [0:2]	TOS;
wire		STACK_FULL_int;

STACK_FSM I_STACK_FSM (
	.Reset		(Reset),
	.Clk		(Clk),
	.PushEnbl	(PushEnbl),
	.PopEnbl	(PopEnbl),
	.TOS		(TOS),
	.STACK_FULL	(STACK_FULL_int)
);

STACK_MEM I1_STACK_MEM (
	.Clk		(Clk),
	.PushEnbl	(PushEnbl),
	.PopEnbl	(PopEnbl),
	.Stack_Full 	(STACK_FULL_int),
	.TOS		(TOS),
	.PushDataIn	(PushDataIn[3:0]),
	.PopDataOut	(PopDataOut[3:0])
);

STACK_MEM I2_STACK_MEM (
	.Clk		(Clk),
	.PushEnbl	(PushEnbl),
	.PopEnbl	(PopEnbl),
	.Stack_Full 	(STACK_FULL_int),
	.TOS		(TOS),
	.PushDataIn	(PushDataIn[7:4]),
	.PopDataOut	(PopDataOut[7:4])
);

STACK_MEM I3_STACK_MEM (
	.Clk		(Clk),
	.PushEnbl	(PushEnbl),
	.PopEnbl	(PopEnbl),
	.Stack_Full 	(STACK_FULL_int),
	.TOS		(TOS),
	.PushDataIn	(PushDataIn[11:8]),
	.PopDataOut	(PopDataOut[11:8])
);

assign STACK_FULL = STACK_FULL_int;

endmodule
