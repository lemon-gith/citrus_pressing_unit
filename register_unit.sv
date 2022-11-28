module register_unit #(
  parameter ADDRESS_WIDTH = 5,
            DATA_WIDTH = 32
)(
  input logic clk,
  input logic WE3,                        // should WD3 be written to A3

  input logic [ADDRESS_WIDTH - 1:0] A1,   // address given by rs1
  input logic [ADDRESS_WIDTH - 1:0] A2,   // address given by rs2

  input logic [ADDRESS_WIDTH - 1:0] A3,   // address given by rd
  input logic [DATA_WIDTH - 1:0] WD3,     // data piped in through Result
  
  output logic [DATA_WIDTH - 1 : 0] RD1,  // data in A1
  output logic [DATA_WIDTH - 1 : 0] RD2   // data in A2
);

logic [DATA_WIDTH - 1 : 0] ram_array [2**ADDRESS_WIDTH - 1 : 0];


always_comb begin
  RD1 = ram_array[A1];
  RD2 = ram_array[A2];
end

always_ff @(posedge clk)
  if (WE3) ram_array[A3] <= WD3;


endmodule
