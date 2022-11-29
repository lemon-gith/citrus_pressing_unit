module ctrl_unit(
  input logic Zero,               // was result of last op 0, from ALU

  input logic [6:0] op,
  input logic [2:0] funct3,
  input logic [6:0] funct7,
                                  // low (0) or high (1)
  output logic RegWrite,          // should CPU Reg be written to
  output logic [1:0] ResultSrcW,  // wo sollen wir ALUout hinleiten
  output logic MemWrite,          // write enable for data memory (RAM)
  output logic PCsrc,             // increment or jump
  output logic [3:0] ALUctrl,     // what should ALU do {func, funct3[2:0]}
  output logic ALUsrc,            // select 2nd data val as RD2 or ImmExt
  output logic [1:0] ImmSrc       // tells ext_unit how to decode incoming imm
  //, output logic TwoC           // should ALUop2 be two's complemented or not
);

/*
ALUsrc gives imm or reg2

R - 0110011 - ALUctrl just funct3 necessary
I - 00x0011 - ALUctrl for op[2] == 1 (x == 1), else do loading things (x == 0)
S - 0100011 - ALUctrl same as I(loading things), without unsigned specification
B - 1100011 - ALUctrl is idk, it just really needs to return flags, ig?
U - 0x10111 - ALUctrl needs to shift input imm up by 12 bits
J - 110x111 - who knows, assuming it needs to do sth else



R and I arithmetic handled via ALUctrl = funct3, with funct7[1]
ALUctrl = {funct7[1], funct3}, ALUsrc 0 or 1, respectively, for arithmetic
// funct7[1] is supposed to be 1 for sub and sra, 0 for add and srl

// can write a debugging check:
   funct7\[1] are all OR'd tgt and should return 0 for 
   all instr where funct7[1]'s is relevant
   
      // Note for ALU: shifts only care abt LS5b of rs2 or imm

I and S loading and storing all require an addition, then address is piped into DataMem A and RD2 to DataMem WD, just need to set MemWrite :)
// rd = SgnExt(DataMem[imm + rs1]) for I-type load, Ignore byte and half for now, just to word loading and storing  // how to get DataMem to know whether to 0 or sgn ext??
for I: ALUctrl = {000} (addi), RegWrite = 1
for S: ALUctrl = {000} (addi), MemWrite = 1


### B:
* beq  (000) = rs1 - rs2,    check for Zero      = 000 sub
* bne  (001) = rs1 - rs2,    check for ~Zero     = 000 sub
* blt  (100) = rs1 < rs2,    check ALUout        = 010 slt
* bge  (101) = rs1 >= rs2,   check for ~ALUout   = 010 slt
* bltu (110) = rs1 < rs2,    check ALUout        = 011 sltu
* bgeu (111) = rs1 >= rs2,   check for ~ALUout   = 011 sltu

ALUctrl[2:0] = {0, funct3[2:1]}                  (all register instructions)

//Pipelining will likely require state machines for these branch 'flags'


### U: 
would just be addi and zero to rd (add zero reg dealt with by ctrl_block)
* lui (---) = rd,    check ALUout        = 011 sltu


### J:
not doing jump commands for now, maybe later


functions:
* normal arithmetic       // ALUsrc will give reg or imm ALUctrl[3] giving sub/add, etc.
* branch comp things      // feed other values into ALU and set enables
* loading things          // ALU doesn't rly need to ld or store anything
* J things                // ??????????????????????????????????????????????
for U, need some way to pass on the note that a 12-bit shift is needed???

If you wanna work with available bits:
op[2] can give arithmetic or loading (1 or 0, respectively) for R and I and S
op[0] differentiates between RISU and JB
op[5] differentiates between RISB and UJ
*/

// TODO: Make sure the right bits are addressed, cos can't seem to remember which side is LSB here

RegWrite = instr[];
ALUctrl = instr[];
ALUsrc = instr[];
PCsrc = instr[];

assign op = instr[6:0];

always_comb case (op)
  7'b0110011: begin  // R-type instr
    RegWrite = 1;
    ALUctrl = {, op[2], funct3};
    ALUsrc = 0;
    PCsrc = 0;
  end

  7'b00x0011: begin  // I-type instr
    funct3 = instr[14:12];
    if (op[2] == 1'b1) begin
      if (funct3 == 3'bx01) funct7 = instr[31:25];

    end
    RegWrite = 1;
    ALUctrl = funct3;
    ALUsrc = 0;
    PCsrc = 0;
  end



  7'b1100011: begin  // B-type instr
    funct3 = instr[14:12];
    funct7 = 7'b0;
  end

  7'b110x111: begin  // J-type instr
    funct3 = 3'b0;
    funct7 = 7'b0;

    rd = instr[11:7];
  end
  
  default: begin
    funct3 = 3'b0;
    funct7 = 7'b0;
  end
endcase

endmodule
