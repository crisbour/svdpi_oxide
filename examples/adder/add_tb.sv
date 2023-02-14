`define DATA_WIDTH 32

interface add_if #(
  parameter DATA_WIDTH = `DATA_WIDTH
  )(input bit clk);
  logic [DATA_WIDTH-1:0] src1;
  logic [DATA_WIDTH-1:0] src2;
  logic [DATA_WIDTH-1:0] result;
endinterface

import testbench_pkg::*;

module tb;

  reg clk;

  always #10 clk = ~clk;

  add_if _if (clk);

  adder u0 (
    .a (_if.src1),
    .b (_if.src2),
    .result (_if.result)
  );

  test #(`DATA_WIDTH) t0;

  initial begin
    clk <= 0;
    t0 = new;
    t0.e0.vif = _if;
    t0.run();

    #50 $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,_if);
  end


endmodule
