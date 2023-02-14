package testbench_pkg;

`define err_display(msg) begin $display("%c[1;31m",27); $display msg; $display("%c[1;0m",27); end

import "DPI-C" function int model_add(int src1, int src2);

// ==========================================
// Module transaction object
// ==========================================
class add_item #(int size);
  rand bit [size-1:0] src1;
  rand bit [size-1:0] src2;
  bit [size-1:0] result;


  function void print(string tag="");
    $display("T=%0t %s a=0x%0h b=0x%0h result=0x%0h", $time, tag, src1, src2, result);
  endfunction

  function void copy(add_item #(size) tmp);
    this.src1   = tmp.src1;
    this.src2   = tmp.src2;
    this.result = tmp.result;
  endfunction

endclass

// ==========================================
// GENERATOR
// ==========================================
class generator #(int size);
  mailbox drv_mbx;
  event drv_done;
  int loop = 40;

  task run();
    for (int i=0; i < loop; i++) begin
      add_item #(size) item = new;
      item.randomize();
      $display("T=%0t [Generator] Loop:%0d/%0d create next item", $time, i+1, loop);
      drv_mbx.put(item);
    $display("T=%0t [Generator] Wait for driver to be done", $time);
      @ (drv_done);
    end
  endtask
endclass

// ==========================================
// Module SCOREBOARD
// ==========================================

class scoreboard #(int size);
  mailbox  scb_mbx;

  task run();
    forever begin
      add_item #(size) item, ref_item;
      scb_mbx.get(item);
      item.print("Scoreboard");

      ref_item = new();
      ref_item.copy(item);
      ref_item.result = model_add(item.src1, item.src2);

      // Check result
      if (ref_item.result!= item.result) begin
        $display("\x1B[31mT=%0t [Scoreboard] ERROR! Result missmatch ", $time,
          "ref_item=%0d item=%0d\x1B[0m", ref_item.result, item.result);
        $fatal("Adder did not return the correct result...halting tests");
      end else begin
        $display("T=%0t [Scoreboard] \x1B[32mPASS!\x1B[0m Result match ", $time,
          "ref_item=%0d item=%0d", ref_item.result, item.result);
      end

    end
  endtask
endclass

// ==========================================
// DRIVER
// ==========================================

class driver #(int size);
  virtual add_if vif;
  event   drv_done;
  mailbox drv_mbx;

  task run();
    $display("T=%0t [Driver] starting ...", $time);

    forever begin
      add_item #(size) item;
      $display("T=%0t [Driver] waiting fo item ...", $time);
      drv_mbx.get(item);
      @ (posedge vif.clk)
      item.print("Driver");
      vif.src1  <= item.src1;
      vif.src2  <= item.src2;
      -> drv_done;
    end
  endtask
endclass

// ==========================================
// MONITOR
// ==========================================

class monitor #(int size);
  virtual add_if vif;
  mailbox scb_mbx;

  task run();
    $display("T=%0t [Monitor] starting ...", $time);
    forever begin
      add_item #(size) item = new;

      @ (posedge vif.clk)

      item.src1   = vif.src1;
      item.src2   = vif.src2;
      item.result = vif.result;

      item.print("Monitor");
      scb_mbx.put(item);
    end
  endtask

endclass

// ==========================================
// ENV
// ==========================================

class env #(int size);
  driver     #(size) d0;
  monitor    #(size) m0;
  generator  #(size) g0;
  scoreboard #(size) s0;
  mailbox scb_mbx;
  virtual add_if vif;

  mailbox drv_mbx;
  event   drv_done;

  function new();
    d0 = new;
    m0 = new;
    g0 = new;
    s0 = new;
    drv_mbx = new();
    scb_mbx = new();

    d0.drv_mbx = drv_mbx;
    g0.drv_mbx = drv_mbx;
    m0.scb_mbx = scb_mbx;
    s0.scb_mbx = scb_mbx;

    d0.drv_done = drv_done;
    g0.drv_done = drv_done;
  endfunction

  virtual task run();
    d0.vif = vif;
    m0.vif = vif;

    fork
      d0.run();
      m0.run();
      g0.run();
      s0.run();
    join_any // In this case if driver finishes, the monitor and scoreboard will not check latest mailbox
  endtask
endclass

// ==========================================
// Module TEST
// ==========================================

class test #(int size);
  env #(size) e0;

  function new();
    e0 = new;
  endfunction

  virtual task run();
    e0.run();
  endtask
endclass

endpackage
