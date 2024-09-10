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
  int                    crc16_8005_arc_data    [256];
  int                    crc16_8005_buypass_data[256];
  virtual apb4_if.master apb4;


  extern function new(string name = "crc_test", virtual apb4_if.master apb4);
  extern task automatic test_reset_reg();
  extern task automatic test_wr_rd_reg(input bit [31:0] run_times = 1000);
  extern task automatic test_gen_lut();
  extern task automatic test_crc8();
  extern task automatic test_crc16();
  extern task automatic test_crc();
endclass

function CRCTest::new(string name, virtual apb4_if.master apb4);
  super.new("apb4_master", apb4);
  this.name = name;
  this.wr_val = 0;
  this.apb4 = apb4;

  // refin: true refout: true
  this.crc16_8005_arc_data = '{
      16'h0000,
      16'hc0c1,
      16'hc181,
      16'h0140,
      16'hc301,
      16'h03c0,
      16'h0280,
      16'hc241,
      16'hc601,
      16'h06c0,
      16'h0780,
      16'hc741,
      16'h0500,
      16'hc5c1,
      16'hc481,
      16'h0440,
      16'hcc01,
      16'h0cc0,
      16'h0d80,
      16'hcd41,
      16'h0f00,
      16'hcfc1,
      16'hce81,
      16'h0e40,
      16'h0a00,
      16'hcac1,
      16'hcb81,
      16'h0b40,
      16'hc901,
      16'h09c0,
      16'h0880,
      16'hc841,
      16'hd801,
      16'h18c0,
      16'h1980,
      16'hd941,
      16'h1b00,
      16'hdbc1,
      16'hda81,
      16'h1a40,
      16'h1e00,
      16'hdec1,
      16'hdf81,
      16'h1f40,
      16'hdd01,
      16'h1dc0,
      16'h1c80,
      16'hdc41,
      16'h1400,
      16'hd4c1,
      16'hd581,
      16'h1540,
      16'hd701,
      16'h17c0,
      16'h1680,
      16'hd641,
      16'hd201,
      16'h12c0,
      16'h1380,
      16'hd341,
      16'h1100,
      16'hd1c1,
      16'hd081,
      16'h1040,
      16'hf001,
      16'h30c0,
      16'h3180,
      16'hf141,
      16'h3300,
      16'hf3c1,
      16'hf281,
      16'h3240,
      16'h3600,
      16'hf6c1,
      16'hf781,
      16'h3740,
      16'hf501,
      16'h35c0,
      16'h3480,
      16'hf441,
      16'h3c00,
      16'hfcc1,
      16'hfd81,
      16'h3d40,
      16'hff01,
      16'h3fc0,
      16'h3e80,
      16'hfe41,
      16'hfa01,
      16'h3ac0,
      16'h3b80,
      16'hfb41,
      16'h3900,
      16'hf9c1,
      16'hf881,
      16'h3840,
      16'h2800,
      16'he8c1,
      16'he981,
      16'h2940,
      16'heb01,
      16'h2bc0,
      16'h2a80,
      16'hea41,
      16'hee01,
      16'h2ec0,
      16'h2f80,
      16'hef41,
      16'h2d00,
      16'hedc1,
      16'hec81,
      16'h2c40,
      16'he401,
      16'h24c0,
      16'h2580,
      16'he541,
      16'h2700,
      16'he7c1,
      16'he681,
      16'h2640,
      16'h2200,
      16'he2c1,
      16'he381,
      16'h2340,
      16'he101,
      16'h21c0,
      16'h2080,
      16'he041,
      16'ha001,
      16'h60c0,
      16'h6180,
      16'ha141,
      16'h6300,
      16'ha3c1,
      16'ha281,
      16'h6240,
      16'h6600,
      16'ha6c1,
      16'ha781,
      16'h6740,
      16'ha501,
      16'h65c0,
      16'h6480,
      16'ha441,
      16'h6c00,
      16'hacc1,
      16'had81,
      16'h6d40,
      16'haf01,
      16'h6fc0,
      16'h6e80,
      16'hae41,
      16'haa01,
      16'h6ac0,
      16'h6b80,
      16'hab41,
      16'h6900,
      16'ha9c1,
      16'ha881,
      16'h6840,
      16'h7800,
      16'hb8c1,
      16'hb981,
      16'h7940,
      16'hbb01,
      16'h7bc0,
      16'h7a80,
      16'hba41,
      16'hbe01,
      16'h7ec0,
      16'h7f80,
      16'hbf41,
      16'h7d00,
      16'hbdc1,
      16'hbc81,
      16'h7c40,
      16'hb401,
      16'h74c0,
      16'h7580,
      16'hb541,
      16'h7700,
      16'hb7c1,
      16'hb681,
      16'h7640,
      16'h7200,
      16'hb2c1,
      16'hb381,
      16'h7340,
      16'hb101,
      16'h71c0,
      16'h7080,
      16'hb041,
      16'h5000,
      16'h90c1,
      16'h9181,
      16'h5140,
      16'h9301,
      16'h53c0,
      16'h5280,
      16'h9241,
      16'h9601,
      16'h56c0,
      16'h5780,
      16'h9741,
      16'h5500,
      16'h95c1,
      16'h9481,
      16'h5440,
      16'h9c01,
      16'h5cc0,
      16'h5d80,
      16'h9d41,
      16'h5f00,
      16'h9fc1,
      16'h9e81,
      16'h5e40,
      16'h5a00,
      16'h9ac1,
      16'h9b81,
      16'h5b40,
      16'h9901,
      16'h59c0,
      16'h5880,
      16'h9841,
      16'h8801,
      16'h48c0,
      16'h4980,
      16'h8941,
      16'h4b00,
      16'h8bc1,
      16'h8a81,
      16'h4a40,
      16'h4e00,
      16'h8ec1,
      16'h8f81,
      16'h4f40,
      16'h8d01,
      16'h4dc0,
      16'h4c80,
      16'h8c41,
      16'h4400,
      16'h84c1,
      16'h8581,
      16'h4540,
      16'h8701,
      16'h47c0,
      16'h4680,
      16'h8641,
      16'h8201,
      16'h42c0,
      16'h4380,
      16'h8341,
      16'h4100,
      16'h81c1,
      16'h8081,
      16'h4040
  };

  // refin: false refout: false
  this.crc16_8005_buypass_data = '{
      16'h0000,
      16'h8005,
      16'h800f,
      16'h000a,
      16'h801b,
      16'h001e,
      16'h0014,
      16'h8011,
      16'h8033,
      16'h0036,
      16'h003c,
      16'h8039,
      16'h0028,
      16'h802d,
      16'h8027,
      16'h0022,
      16'h8063,
      16'h0066,
      16'h006c,
      16'h8069,
      16'h0078,
      16'h807d,
      16'h8077,
      16'h0072,
      16'h0050,
      16'h8055,
      16'h805f,
      16'h005a,
      16'h804b,
      16'h004e,
      16'h0044,
      16'h8041,
      16'h80c3,
      16'h00c6,
      16'h00cc,
      16'h80c9,
      16'h00d8,
      16'h80dd,
      16'h80d7,
      16'h00d2,
      16'h00f0,
      16'h80f5,
      16'h80ff,
      16'h00fa,
      16'h80eb,
      16'h00ee,
      16'h00e4,
      16'h80e1,
      16'h00a0,
      16'h80a5,
      16'h80af,
      16'h00aa,
      16'h80bb,
      16'h00be,
      16'h00b4,
      16'h80b1,
      16'h8093,
      16'h0096,
      16'h009c,
      16'h8099,
      16'h0088,
      16'h808d,
      16'h8087,
      16'h0082,
      16'h8183,
      16'h0186,
      16'h018c,
      16'h8189,
      16'h0198,
      16'h819d,
      16'h8197,
      16'h0192,
      16'h01b0,
      16'h81b5,
      16'h81bf,
      16'h01ba,
      16'h81ab,
      16'h01ae,
      16'h01a4,
      16'h81a1,
      16'h01e0,
      16'h81e5,
      16'h81ef,
      16'h01ea,
      16'h81fb,
      16'h01fe,
      16'h01f4,
      16'h81f1,
      16'h81d3,
      16'h01d6,
      16'h01dc,
      16'h81d9,
      16'h01c8,
      16'h81cd,
      16'h81c7,
      16'h01c2,
      16'h0140,
      16'h8145,
      16'h814f,
      16'h014a,
      16'h815b,
      16'h015e,
      16'h0154,
      16'h8151,
      16'h8173,
      16'h0176,
      16'h017c,
      16'h8179,
      16'h0168,
      16'h816d,
      16'h8167,
      16'h0162,
      16'h8123,
      16'h0126,
      16'h012c,
      16'h8129,
      16'h0138,
      16'h813d,
      16'h8137,
      16'h0132,
      16'h0110,
      16'h8115,
      16'h811f,
      16'h011a,
      16'h810b,
      16'h010e,
      16'h0104,
      16'h8101,
      16'h8303,
      16'h0306,
      16'h030c,
      16'h8309,
      16'h0318,
      16'h831d,
      16'h8317,
      16'h0312,
      16'h0330,
      16'h8335,
      16'h833f,
      16'h033a,
      16'h832b,
      16'h032e,
      16'h0324,
      16'h8321,
      16'h0360,
      16'h8365,
      16'h836f,
      16'h036a,
      16'h837b,
      16'h037e,
      16'h0374,
      16'h8371,
      16'h8353,
      16'h0356,
      16'h035c,
      16'h8359,
      16'h0348,
      16'h834d,
      16'h8347,
      16'h0342,
      16'h03c0,
      16'h83c5,
      16'h83cf,
      16'h03ca,
      16'h83db,
      16'h03de,
      16'h03d4,
      16'h83d1,
      16'h83f3,
      16'h03f6,
      16'h03fc,
      16'h83f9,
      16'h03e8,
      16'h83ed,
      16'h83e7,
      16'h03e2,
      16'h83a3,
      16'h03a6,
      16'h03ac,
      16'h83a9,
      16'h03b8,
      16'h83bd,
      16'h83b7,
      16'h03b2,
      16'h0390,
      16'h8395,
      16'h839f,
      16'h039a,
      16'h838b,
      16'h038e,
      16'h0384,
      16'h8381,
      16'h0280,
      16'h8285,
      16'h828f,
      16'h028a,
      16'h829b,
      16'h029e,
      16'h0294,
      16'h8291,
      16'h82b3,
      16'h02b6,
      16'h02bc,
      16'h82b9,
      16'h02a8,
      16'h82ad,
      16'h82a7,
      16'h02a2,
      16'h82e3,
      16'h02e6,
      16'h02ec,
      16'h82e9,
      16'h02f8,
      16'h82fd,
      16'h82f7,
      16'h02f2,
      16'h02d0,
      16'h82d5,
      16'h82df,
      16'h02da,
      16'h82cb,
      16'h02ce,
      16'h02c4,
      16'h82c1,
      16'h8243,
      16'h0246,
      16'h024c,
      16'h8249,
      16'h0258,
      16'h825d,
      16'h8257,
      16'h0252,
      16'h0270,
      16'h8275,
      16'h827f,
      16'h027a,
      16'h826b,
      16'h026e,
      16'h0264,
      16'h8261,
      16'h0220,
      16'h8225,
      16'h822f,
      16'h022a,
      16'h823b,
      16'h023e,
      16'h0234,
      16'h8231,
      16'h8213,
      16'h0216,
      16'h021c,
      16'h8219,
      16'h0208,
      16'h820d,
      16'h8207,
      16'h0202
  };

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

task automatic test_crc8();
  $display("%t === [test gen crc8] ===", $time);

endtask

task automatic CRCTest::test_crc16();
  $display("=== [test gen crc16] ===");
  repeat (400) @(posedge this.apb4.pclk);
  // this.write(`CRC_INIT_ADDR, 32'h1D0F & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b010001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h123 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hD1B2, Helper::EQUL, Helper::INFO);
endtask

task automatic CRCTest::test_crc();
  $display("=== [test crc8 val] ===");
  // this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b000001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h4 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h1C, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'h55 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b000001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hD9, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'hFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b001101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h4 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hC8, Helper::EQUL, Helper::INFO);

  // $display("=== [test crc16 0x1021 val] ===");
  // this.write(`CRC_INIT_ADDR, 32'h1D0F & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b010001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h9706, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b010001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h0EC9, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b010001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hF136, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hD186, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h213E, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'hB2AA & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h22B0, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'h89EC & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h943F, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hDEC1, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b010001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h13C6, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'hC6C6 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hCF26, Helper::EQUL, Helper::INFO);

  // $display("=== [test crc16 0x8005 val] ===");
  // for (int i = 0; i < 256; i++) begin
  //   this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  //   this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b000_0010 & {`CRC_CTRL_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b010_1101 & {`CRC_CTRL_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.write(`CRC_DATA_ADDR, i & {`CRC_DATA_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.read(`CRC_DATA_ADDR);
  //   if (this.crc16_8005_arc_data[i] - super.rd_data != 0) begin
  //     $display("%t %d expt: %h actu: %h", $time, i, this.crc16_8005_arc_data[i], super.rd_data);
  //   end
  // end

  // for (int i = 0; i < 256; i++) begin
  //   this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  //   this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b10_1101 & {`CRC_CTRL_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.write(`CRC_DATA_ADDR, i & {`CRC_DATA_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.read(`CRC_DATA_ADDR);
  //   if (this.crc16_8005_buypass_data[i] - super.rd_data != 0) begin
  //     $display("%t %d expt: %h actu: %h", $time, i, this.crc16_8005_buypass_data[i], super.rd_data);
  //   end
  // end

  // NOTE:
  // for (int i = 0; i < 256; i++) begin
  //   this.write(`CRC_INIT_ADDR, 32'h800D & {`CRC_INIT_WIDTH{1'b1}});
  //   this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b10_0001 & {`CRC_CTRL_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.write(`CRC_DATA_ADDR, i & {`CRC_DATA_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.read(`CRC_DATA_ADDR);
  //   $display("%t %d expt: %h", $time, i, super.rd_data);
  // end

  // this.write(`CRC_INIT_ADDR, 32'h800D & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b100001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hEC9F, Helper::EQUL, Helper::INFO);


  // this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b101101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h88F2, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b101101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hC70C, Helper::EQUL, Helper::INFO);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b101101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'hE3A4 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h6841, Helper::EQUL, Helper::INFO);

  // $display("=== [test crc32 val] ===");
  // this.write(`CRC_INIT_ADDR, 32'hFFFF_FFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'hFFFF_FFFF & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b111101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h4A090E98, Helper::EQUL, Helper::INFO);

  // for (int i = 0; i < 256; i++) begin
  //   this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  //   this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b11_0001 & {`CRC_CTRL_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.write(`CRC_DATA_ADDR, i & {`CRC_DATA_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.read(`CRC_DATA_ADDR);
  //   $display("%t %d expt: %h", $time, i, super.rd_data);
  // end

endtask

`endif
