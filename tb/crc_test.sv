// Copyright (c) 2023 Beijing Institute of Open Source Chip
// crc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_CRC_TEST_SV
`define INC_CRC_TEST_SV

`include "apb4_master.sv"
`include "crc_define.sv"

class CRCTest extends APB4Master;
  string                 name;
  int                    wr_val;
  virtual apb4_if.master apb4;

  extern function new(string name = "crc_test", virtual apb4_if.master apb4);
  extern task automatic test_reset_reg();
  extern task automatic test_wr_rd_reg(input bit [31:0] run_times = 1000);
  extern task automatic test_crc();
endclass

function CRCTest::new(string name, virtual apb4_if.master apb4);
  super.new("apb4_master", apb4);
  this.name   = name;
  this.wr_val = 0;
  this.apb4   = apb4;
endfunction

task automatic CRCTest::test_reset_reg();
  super.test_reset_reg();
  // verilog_format: off
  this.rd_check(`CRC_CTRL_ADDR, "CTRL REG", 32'b0 & {`CRC_CTRL_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`CRC_INIT_ADDR, "INIT REG", 32'b0 & {`CRC_INIT_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`CRC_XORV_ADDR, "XORV REG", 32'b0 & {`CRC_XORV_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'b0 & {`CRC_DATA_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`CRC_STAT_ADDR, "STAT REG", 32'b0 & {`CRC_INIT_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  // verilog_format: on
endtask

task automatic CRCTest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();
  // verilog_format: off
  for (int i = 0; i < run_times; i++) begin
    this.wr_rd_check(`CRC_CTRL_ADDR, "CTRL REG", $random & {`CRC_CTRL_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`CRC_INIT_ADDR, "INIT REG", $random & {`CRC_INIT_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`CRC_XORV_ADDR, "XORV REG", $random & {`CRC_XORV_WIDTH{1'b1}}, Helper::EQUL);
  end
  // verilog_format: on
endtask

task automatic CRCTest::test_crc();
  $display("=== [test crc val] ===");
  this.write(`CRC_INIT_ADDR, 32'h1D0F & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0001 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h9706, Helper::EQUL, Helper::INFO);

  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0001 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h0EC9, Helper::EQUL, Helper::INFO);

  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0001 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hF136, Helper::EQUL, Helper::INFO);

  this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b1101 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hD186, Helper::EQUL, Helper::INFO);

  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b1101 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h213E, Helper::EQUL, Helper::INFO);

  this.write(`CRC_INIT_ADDR, 32'hB2AA & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b1101 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h22B0, Helper::EQUL, Helper::INFO);

  this.write(`CRC_INIT_ADDR, 32'h89EC & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b1101 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h943F, Helper::EQUL, Helper::INFO);

  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b1101 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hDEC1, Helper::EQUL, Helper::INFO);

  this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0001 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h13C6, Helper::EQUL, Helper::INFO);

  this.write(`CRC_INIT_ADDR, 32'hC6C6 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b1101 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hCF26, Helper::EQUL, Helper::INFO);

endtask

`endif
