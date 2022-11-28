module ctrl_block#(
  parameter DATA_WIDTH = 32;
  parameter REG_ADD_WIDTH = 5;
)(
  input logic Zero,                     // Fresh from ALU
  input logic [DATA_WIDTH-1:0] instr,   // provided by InstrMem
  input logic [DATA_WIDTH-1:0] Result,  // ALUOut, DataMem RD, or PC + 4

  output logic ResultSrc,         // Result =  ALUOut, DataMem RD, or PC + 4
  output logic MemWrite,          // should DataMem be written to
  output logic PCsrc,             // should a branch/jump occur
  output logic [2:0] ALUControl,  // what should ALU do
  output logic ALUSrc,            // ALUop2 = RD2 or ImmExt
  
  output logic [REG_ADD_WIDTH-1:0] RD1,   // RegFile data addressed by rs1
  output logic [REG_ADD_WIDTH-1:0] RD2,   // RegFile data addressed by rs2
  //output logic [REG_ADD_WIDTH-1:0] Rd,    // RegFile address from instr's rd
  // Will need Rd for pipelining

  output logic [DATA_WIDTH-1:0] ImmExt   // extended imm value
);


//region stuff to be passed onto DataMem person
/*      // dk how relevant any of this is or where it needs to be considered
for ext_unit - extension start-index
00: 
01: 
10: 
11: 

load byte - from [8] upwards
load half - from [16]
regular   - from [12]
idk       - from [?]
*/
//endregion


//TODO: Check if this even needs to be declared
logic [1:0] ImmSrc;  // which imm-decoding strategy should ext_unit employ
logic RegWrite;  // should RegFile be written to

ctrl_unit fred(   // no DATA_WIDTH, just assumed to run on 32 bits, cos, ugh
  .Zero(Zero),    // From ALU, fed straight to ctrl_unit

  .op(instr[6:0]),
  .funct3(instr[14:12]),
  .funct7(instr[31:25]),

  .RegWrite(RegWrite),
  .ResultSrc(ResultSrc),
  .MemWrite(MemWrite),
  .PCsrc(PCsrc),
  .ALUctrl(ALUControl),
  .ALUsrc(ALUSrc), 
  .ImmSrc(ImmSrc)
);


ext_unit ext(32)(
  .Imm(instr[31:7]),  // have to feed anything possibly relevant
  .ImmType(ImmSrc),

  .ImmOut(ImmExt)
);


register_unit RegFile(32)(
  .WE3(RegWrite),

  .A1(if (instr[6:0] == 7'b0x10111) 7'b0;   // ensures imm added to 0 for lui
      else instr[24:20];),
  .A2(instr[19:15]),

  .A3(instr[11:7]),
  .WD3(Result),

  .RD1(RD1),
  .RD2(RD2)
);
//Rd = instr[11:7];  
// this will be output and an input ver. will go into RegFile in pipelined ver.


endmodule
