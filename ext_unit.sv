module ext_unit #(
  parameter DATA_WIDTH = 32;  //parameter unused, would make things unreadable
)(
  input logic [25-1:0] imm,
  input logic [1:0]  ImmType,    // how should imm be decoded

  output logic [32-1:0] ImmOut
);

/*
R: None          // don't need to differentiate, just treat as I
I: {imm[24:13]}                               // 00
S: {imm[24:18], imm[4:0]}                     // 01
B: {imm[24], imm[0], imm[23:18], imm[4:1]}    // 10
J: {imm[24], imm[12:5], imm[13], imm[23:14]}
U: {imm[24:5]}                                // 11
*/

always_comb case(ImmType)    // for disambiguation, see above block comment
  2'b00: ImmOut = {21{imm[24]}, imm[23:13]};     
  2'b01: ImmOut = {21{imm[24]}, imm[23:18], imm[4:0]};
  2'b10: ImmOut = {21{imm[24]}, imm[0], imm[23:18], imm[4:1]};
  //2'b11: ImmOut = {21{imm[24]}, imm[12:5], imm[13], imm[23:14]};
  2'b11: ImmOut = {imm[24:5], 12{1'b0}};
endcase

endmodule
