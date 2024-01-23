// Copyright (c) 2023 Beijing Institute of Open Source Chip
// crc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "register.sv"
`include "edge_det.sv"
`include "crc_define.sv"

module apb4_crc (
    apb4_if.slave apb4
);

  typedef enum logic [2:0] {
    IDLE,
    SHIFT1,
    SHIFT2,
    SHIFT3,
    SHIFT4,
    DONE
  } lut_fsm_t;

  logic [3:0] s_apb4_addr;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk;
  logic [`CRC_CTRL_WIDTH-1:0] s_crc_ctrl_d, s_crc_ctrl_q;
  logic s_crc_ctrl_en;
  logic [`CRC_INIT_WIDTH-1:0] s_crc_init_d, s_crc_init_q;
  logic s_crc_init_en;
  logic [`CRC_XORV_WIDTH-1:0] s_crc_xorv_d, s_crc_xorv_q;
  logic s_crc_xorv_en;
  logic [`CRC_DATA_WIDTH-1:0] s_crc_data_d, s_crc_data_q;
  logic s_crc_data_en;
  logic [`CRC_STAT_WIDTH-1:0] s_crc_stat_d, s_crc_stat_q;
  logic s_crc_stat_en;
  logic s_bit_en, s_bit_ld, s_bit_revin, s_bit_revout, s_bit_init, s_bit_init_re;
  logic s_bit_done, s_bit_cmp;
  logic [1:0] s_bit_crc_mode;

  // crc8
  logic [7:0] s_crc8_wr, s_crc8_wr_rev;
  logic [7:0] s_crc8_d, s_crc8_q, s_crc8_qq, s_crc8_q_rev;
  logic [1:0] s_crc8_data;
  // crc16
  logic [15:0] s_crc16_wr, s_crc16_wr_rev;
  logic [15:0] s_crc16_d, s_crc16_q, s_crc16_qq, s_crc16_q_rev;
  logic [15:0] s_crc16_qq_1021, s_crc16_qq_8005;
  logic [3:0] s_crc16_data;
  // crc32
  logic [31:0] s_crc32_wr, s_crc32_wr_rev;
  logic [31:0] s_crc32_d, s_crc32_q, s_crc32_qq, s_crc32_q_rev;
  logic [7:0] s_crc32_data;
  // lut
  lut_fsm_t s_lut_fsm_d, s_lut_fsm_q;
  logic [255:0][31:0] s_lut_d, s_lut_q;
  logic s_lut_en;
  logic [8:0] s_lut_idx_d, s_lut_idx_q;
  logic       s_lut_idx_en;
  // user idx
  logic [4:0] s_user_msb_idx;
  logic [2:0] s_user_len;
  logic [15:0] s_user_crc16_d, s_user_crc16_q;
  logic [2:0] s_user_cnt_d, s_user_cnt_q;
  logic [7:0] s_user_wr_data;


  assign s_apb4_addr     = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready     = 1'b1;
  assign apb4.pslverr    = 1'b0;

  assign s_bit_en        = s_crc_ctrl_q[0];
  assign s_bit_ld        = s_crc_ctrl_q[1];
  assign s_bit_revin     = s_crc_ctrl_q[2];
  assign s_bit_revout    = s_crc_ctrl_q[3];
  assign s_bit_crc_mode  = s_crc_ctrl_q[5:4];
  assign s_bit_init      = s_crc_ctrl_q[6];
  assign s_bit_done      = s_crc_stat_q[0];
  assign s_bit_cmp       = s_crc_stat_q[1];

  assign s_crc8_wr       = s_bit_init ? s_lut_idx_q : apb4.pwdata[7:0];
  assign s_crc16_wr      = s_bit_init ? s_lut_idx_q : apb4.pwdata[15:0];
  assign s_crc32_wr      = s_bit_init ? s_lut_idx_q : apb4.pwdata[31:0];

  //crc8
  for (genvar i = 0; i < 8; i++) begin
    assign s_crc8_wr_rev[i] = s_crc8_wr[7-i];
  end
  for (genvar i = 0; i < 8; i++) begin
    assign s_crc8_q_rev[i] = s_crc8_q[7-i];
  end

  // crc16
  for (genvar i = 0; i < 16; i++) begin
    if (i < 8) begin
      assign s_crc16_wr_rev[i] = s_crc16_wr[7-i];
    end else begin
      assign s_crc16_wr_rev[i] = s_crc16_wr[15-(i-8)];
    end
  end
  for (genvar i = 0; i < 16; i++) begin
    assign s_crc16_q_rev[i] = s_crc16_q[15-i];
  end

  // crc32
  for (genvar i = 0; i < 32; i++) begin
    if (i < 8) begin
      assign s_crc32_wr_rev[i] = s_crc32_wr[7-i];
    end else if (i < 16) begin
      assign s_crc32_wr_rev[i] = s_crc32_wr[15-(i-8)];
    end else if (i < 24) begin
      assign s_crc32_wr_rev[i] = s_crc32_wr[23-(i-16)];
    end else begin
      assign s_crc32_wr_rev[i] = s_crc32_wr[31-(i-24)];
    end
  end
  for (genvar i = 0; i < 32; i++) begin
    assign s_crc32_q_rev[i] = s_crc32_q[31-i];
  end

  assign s_crc_ctrl_en = s_apb4_wr_hdshk && s_apb4_addr == `CRC_CTRL;
  assign s_crc_ctrl_d  = s_crc_ctrl_en ? apb4.pwdata[`CRC_CTRL_WIDTH-1:0] : s_crc_ctrl_q;
  dffer #(`CRC_CTRL_WIDTH) u_crc_ctrl_dffer (
      apb4.pclk,
      apb4.presetn,
      s_crc_ctrl_en,
      s_crc_ctrl_d,
      s_crc_ctrl_q
  );

  assign s_crc_init_en = s_apb4_wr_hdshk && s_apb4_addr == `CRC_INIT;
  assign s_crc_init_d  = s_crc_init_en ? apb4.pwdata[`CRC_INIT_WIDTH-1:0] : s_crc_init_q;
  dffer #(`CRC_INIT_WIDTH) u_crc_init_dffer (
      apb4.pclk,
      apb4.presetn,
      s_crc_init_en,
      s_crc_init_d,
      s_crc_init_q
  );

  assign s_crc_xorv_en = s_apb4_wr_hdshk && s_apb4_addr == `CRC_XORV;
  assign s_crc_xorv_d  = s_crc_xorv_en ? apb4.pwdata[`CRC_XORV_WIDTH-1:0] : s_crc_xorv_q;
  dffer #(`CRC_XORV_WIDTH) u_crc_xorv_dffer (
      apb4.pclk,
      apb4.presetn,
      s_crc_xorv_en,
      s_crc_xorv_d,
      s_crc_xorv_q
  );

  // TODO: simplify sel logic impl
  assign s_crc_data_en = s_bit_init || (s_apb4_wr_hdshk && s_apb4_addr == `CRC_DATA) || (s_lut_fsm_q == DONE);
  always_comb begin
    s_crc_data_d = s_crc_data_q;
    if (s_bit_init) begin
      if (s_bit_revin) begin
        unique case (s_bit_crc_mode)
          `CRC8_MODE:       s_crc_data_d = s_crc8_wr_rev;
          `CRC16_1021_MODE: s_crc_data_d = s_crc16_wr_rev;
          `CRC16_8005_MODE: s_crc_data_d = s_crc16_wr_rev;
          `CRC32_MODE:      s_crc_data_d = s_crc32_wr_rev;
          default:          s_crc_data_d = s_crc8_wr_rev;
        endcase
      end else begin
        unique case (s_bit_crc_mode)
          `CRC8_MODE:       s_crc_data_d = s_crc8_wr;
          `CRC16_1021_MODE: s_crc_data_d = s_crc16_wr;
          `CRC16_8005_MODE: s_crc_data_d = s_crc16_wr;
          `CRC32_MODE:      s_crc_data_d = s_crc32_wr;
          default:          s_crc_data_d = s_crc8_wr;
        endcase
      end
    end else if (s_bit_en && s_apb4_wr_hdshk && s_apb4_addr == `CRC_DATA) begin
      if (s_bit_revin) begin
        unique case (s_bit_crc_mode)
          `CRC8_MODE:       s_crc_data_d = s_crc8_wr_rev;
          `CRC16_1021_MODE: s_crc_data_d = s_crc16_wr_rev;
          `CRC16_8005_MODE: s_crc_data_d = s_crc16_wr_rev;
          `CRC32_MODE:      s_crc_data_d = s_crc32_wr_rev;
          default:          s_crc_data_d = s_crc8_wr_rev;
        endcase
      end else begin
        unique case (s_bit_crc_mode)
          `CRC8_MODE:       s_crc_data_d = s_crc8_wr;
          `CRC16_1021_MODE: s_crc_data_d = s_crc16_wr;
          `CRC16_8005_MODE: s_crc_data_d = s_crc16_wr;
          `CRC32_MODE:      s_crc_data_d = s_crc32_wr;
          default:          s_crc_data_d = s_crc8_wr;
        endcase
      end
    end else if (s_bit_en && s_lut_fsm_q == DONE) begin
      if (s_bit_revout) begin
        unique case (s_bit_crc_mode)
          `CRC8_MODE:       s_crc_data_d = s_crc8_q_rev ^ s_crc_xorv_q[7:0];
          `CRC16_1021_MODE: s_crc_data_d = s_crc16_q_rev ^ s_crc_xorv_q[15:0];
          `CRC16_8005_MODE: s_crc_data_d = s_crc16_q_rev ^ s_crc_xorv_q[15:0];
          `CRC32_MODE:      s_crc_data_d = s_crc32_q_rev ^ s_crc_xorv_q[31:0];
          default:          s_crc_data_d = s_crc8_q_rev ^ s_crc_xorv_q[7:0];
        endcase
      end else begin
        unique case (s_bit_crc_mode)
          `CRC8_MODE:       s_crc_data_d = s_crc8_q ^ s_crc_xorv_q[7:0];
          `CRC16_1021_MODE: s_crc_data_d = s_crc16_q ^ s_crc_xorv_q[15:0];
          `CRC16_8005_MODE: s_crc_data_d = s_crc16_q ^ s_crc_xorv_q[15:0];
          `CRC32_MODE:      s_crc_data_d = s_crc32_q ^ s_crc_xorv_q[31:0];
          default:          s_crc_data_d = s_crc8_q ^ s_crc_xorv_q[7:0];
        endcase
      end
    end
  end
  dffer #(`CRC_DATA_WIDTH) u_crc_data_dffer (
      apb4.pclk,
      apb4.presetn,
      s_crc_data_en,
      s_crc_data_d,
      s_crc_data_q
  );

  always_comb begin
    s_crc_stat_d[0] = s_lut_fsm_q == DONE;
    s_crc_stat_d[1] = s_lut_idx_q == 9'd256;
  end
  dffr #(`CRC_STAT_WIDTH) u_crc_stat_dffr (
      apb4.pclk,
      apb4.presetn,
      s_crc_stat_d,
      s_crc_stat_q
  );

  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `CRC_CTRL: apb4.prdata[`CRC_CTRL_WIDTH-1:0] = s_crc_ctrl_q;
        `CRC_INIT: apb4.prdata[`CRC_INIT_WIDTH-1:0] = s_crc_init_q;
        `CRC_XORV: apb4.prdata[`CRC_XORV_WIDTH-1:0] = s_crc_xorv_q;
        `CRC_DATA: apb4.prdata[`CRC_DATA_WIDTH-1:0] = s_crc_data_q;
        `CRC_STAT: apb4.prdata[`CRC_STAT_WIDTH-1:0] = s_crc_stat_q;
        default:   apb4.prdata = '0;
      endcase
    end
  end

  edge_det_re #(
      .STAGE     (2),
      .DATA_WIDTH(1)
  ) u_lut_init_edge_det_re (
      .clk_i  (apb4.pclk),
      .rst_n_i(apb4.presetn),
      .dat_i  (s_bit_init),
      .re_o   (s_bit_init_re)
  );

  assign s_lut_idx_en = s_bit_init_re || (s_lut_fsm_q == DONE);
  always_comb begin
    s_lut_idx_d = s_lut_idx_q;
    if (s_bit_init_re) begin
      s_lut_idx_d = '0;
    end else if (s_lut_fsm_q == DONE) begin
      s_lut_idx_d = s_lut_idx_q + 1'b1;
    end
  end
  dffer #(9) u_lut_idx_dffer (
      apb4.pclk,
      apb4.presetn,
      s_lut_idx_en,
      s_lut_idx_d,
      s_lut_idx_q
  );

  assign s_lut_en = s_bit_init_re || (s_lut_fsm_q == DONE);
  always_comb begin
    s_lut_d = s_lut_q;
    if (s_bit_init_re) begin
      s_lut_d = '0;
    end else if (s_lut_fsm_q == DONE) begin
      if (s_bit_revout) begin
        unique case (s_bit_crc_mode)
          `CRC8_MODE:       s_lut_d[s_lut_idx_q] = s_crc8_q_rev ^ s_crc_xorv_q[7:0];
          `CRC16_1021_MODE: s_lut_d[s_lut_idx_q] = s_crc16_q_rev ^ s_crc_xorv_q[15:0];
          `CRC16_8005_MODE: s_lut_d[s_lut_idx_q] = s_crc16_q_rev ^ s_crc_xorv_q[15:0];
          `CRC32_MODE:      s_lut_d[s_lut_idx_q] = s_crc32_q_rev ^ s_crc_xorv_q[31:0];
          default:          s_lut_d[s_lut_idx_q] = s_crc8_q_rev ^ s_crc_xorv_q[7:0];
        endcase
      end else begin
        unique case (s_bit_crc_mode)
          `CRC8_MODE:       s_lut_d[s_lut_idx_q] = s_crc8_q ^ s_crc_xorv_q[7:0];
          `CRC16_1021_MODE: s_lut_d[s_lut_idx_q] = s_crc16_q ^ s_crc_xorv_q[15:0];
          `CRC16_8005_MODE: s_lut_d[s_lut_idx_q] = s_crc16_q ^ s_crc_xorv_q[15:0];
          `CRC32_MODE:      s_lut_d[s_lut_idx_q] = s_crc32_q ^ s_crc_xorv_q[31:0];
          default:          s_lut_d[s_lut_idx_q] = s_crc8_q ^ s_crc_xorv_q[7:0];
        endcase
      end
      // $display("%t s_lut_d[%d]: %h", $time, s_lut_idx_q, s_lut_d[s_lut_idx_q]);
    end
  end
  dffer #(256 * 32) u_lut_dffer (
      apb4.pclk,
      apb4.presetn,
      s_lut_en,
      s_lut_d,
      s_lut_q
  );

  always_comb begin
    s_lut_fsm_d = s_lut_fsm_q;
    if (s_bit_init_re) begin
      s_lut_fsm_d = IDLE;
    end else if (s_bit_init) begin
      unique case (s_lut_fsm_q)
        IDLE:
        if (s_lut_idx_q < 256) begin
          s_lut_fsm_d = SHIFT1;
        end
        SHIFT1:  s_lut_fsm_d = SHIFT2;
        SHIFT2:  s_lut_fsm_d = SHIFT3;
        SHIFT3:  s_lut_fsm_d = SHIFT4;
        SHIFT4:  s_lut_fsm_d = DONE;
        DONE:    s_lut_fsm_d = IDLE;
        default: s_lut_fsm_d = IDLE;
      endcase
    end
  end
  always_ff @(posedge apb4.pclk, negedge apb4.presetn) begin
    if (~apb4.presetn) begin
      s_lut_fsm_q <= IDLE;
    end else begin
      s_lut_fsm_q <= #1 s_lut_fsm_d;
    end
  end


  always_comb begin
    s_crc8_d = s_crc8_q;
    if (s_bit_ld) begin
      s_crc8_d = s_crc_init_q[7:0];
    end else if (s_lut_fsm_q != IDLE) begin
      s_crc8_d = s_crc8_qq;
    end
  end
  dffr #(8) u_crc8_dffr (
      apb4.pclk,
      apb4.presetn,
      s_crc8_d,
      s_crc8_q
  );

  always_comb begin
    s_crc8_data = '0;
    if (s_lut_fsm_q == SHIFT1) begin
      s_crc8_data = s_crc_data_q[7:6];
    end else if (s_lut_fsm_q == SHIFT2) begin
      s_crc8_data = s_crc_data_q[5:4];
    end else if (s_lut_fsm_q == SHIFT3) begin
      s_crc8_data = s_crc_data_q[3:2];
    end else if (s_lut_fsm_q == SHIFT4) begin
      s_crc8_data = s_crc_data_q[1:0];
    end
  end

  crc8_07 u_crc8_07 (
      .data_i(s_crc8_data),
      .crc_i (s_crc8_q),
      .crc_o (s_crc8_qq)
  );


  always_comb begin
    s_crc16_d = s_crc16_q;
    if (s_bit_ld || s_lut_fsm_q == DONE) begin
      s_crc16_d = s_crc_init_q[15:0];
    end else if (s_bit_init && s_lut_fsm_q != IDLE) begin
      s_crc16_d = s_crc16_qq;
    end
  end
  dffr #(16) u_crc16_dffr (
      apb4.pclk,
      apb4.presetn,
      s_crc16_d,
      s_crc16_q
  );

  always_comb begin
    s_crc16_data = '0;
    if (s_lut_fsm_q == SHIFT1) begin
      s_crc16_data = s_crc_data_q[15:12];
    end else if (s_lut_fsm_q == SHIFT2) begin
      s_crc16_data = s_crc_data_q[11:8];
    end else if (s_lut_fsm_q == SHIFT3) begin
      s_crc16_data = s_crc_data_q[7:4];
    end else if (s_lut_fsm_q == SHIFT4) begin
      s_crc16_data = s_crc_data_q[3:0];
    end
  end

  assign s_crc16_qq = s_bit_crc_mode == `CRC16_1021_MODE ? s_crc16_qq_1021 : s_crc16_qq_8005;
  crc16_1021 u_crc16_1021 (
      .data_i(s_crc16_data),
      .crc_i (s_crc16_q),
      .crc_o (s_crc16_qq_1021)
  );
  crc16_8005 u_crc16_8005 (
      .data_i(s_crc16_data),
      .crc_i (s_crc16_q),
      .crc_o (s_crc16_qq_8005)
  );


  always_comb begin
    s_crc32_d = s_crc32_q;
    if (s_bit_ld) begin
      s_crc32_d = s_crc_init_q[31:0];
    end else if (s_lut_fsm_q != IDLE) begin
      s_crc32_d = s_crc32_qq;
    end
  end
  dffr #(32) u_crc32_dffr (
      apb4.pclk,
      apb4.presetn,
      s_crc32_d,
      s_crc32_q
  );

  always_comb begin
    s_crc32_data = '0;
    if (s_lut_fsm_q == SHIFT1) begin
      s_crc32_data = s_crc_data_q[31:24];
    end else if (s_lut_fsm_q == SHIFT2) begin
      s_crc32_data = s_crc_data_q[23:16];
    end else if (s_lut_fsm_q == SHIFT3) begin
      s_crc32_data = s_crc_data_q[15:8];
    end else if (s_lut_fsm_q == SHIFT4) begin
      s_crc32_data = s_crc_data_q[7:0];
    end
  end
  crc32_04c11db7 u_crc32_04c11db7 (
      .data_i(s_crc32_data),
      .crc_i (s_crc32_q),
      .crc_o (s_crc32_qq)
  );


  // calc user crc value
  always_comb begin
    s_user_msb_idx = '0;
    s_user_len     = '0;
    if (s_crc_data_q[31:28] != '0) begin
      s_user_msb_idx = 5'd31;
      s_user_len     = 3'd4;
    end else if (s_crc_data_q[27:24] != '0) begin
      s_user_msb_idx = 5'd27;
      s_user_len     = 3'd4;
    end else if (s_crc_data_q[23:20] != '0) begin
      s_user_msb_idx = 5'd23;
      s_user_len     = 3'd3;
    end else if (s_crc_data_q[19:16] != '0) begin
      s_user_msb_idx = 5'd19;
      s_user_len     = 3'd3;
    end else if (s_crc_data_q[15:12] != '0) begin
      s_user_msb_idx = 5'd15;
      s_user_len     = 3'd2;
    end else if (s_crc_data_q[11:8] != '0) begin
      s_user_msb_idx = 5'd1;
      s_user_len     = 3'd2;
    end else if (s_crc_data_q[7:4] != '0) begin
      s_user_msb_idx = 5'd7;
      s_user_len     = 3'd1;
    end else if (s_crc_data_q[3:0] != '0) begin
      s_user_msb_idx = 5'd23;
      s_user_len     = 3'd1;
    end else begin
      s_user_msb_idx = '0;
      s_user_len     = '0;
    end
  end

  // s_user_wr_data
  always_comb begin
    s_user_cnt_d = s_user_cnt_q;
    if (s_bit_ld) begin
      s_user_cnt_d = '0;
    end else if (s_bit_en) begin
      s_user_cnt_d = s_user_cnt_q + 1'b1;
    end
  end
  dffr #(3) u_user_cnt_dffr (
      apb4.pclk,
      apb4.presetn,
      s_user_cnt_d,
      s_user_cnt_q
  );

  always_comb begin
    s_user_crc16_d = s_user_crc16_q;
    if (s_bit_ld) begin
      s_user_crc16_d = s_crc_init_q[15:0];
    end else if (s_bit_en && s_user_cnt_q <= s_user_len) begin  // TODO:
      s_user_crc16_d = s_user_crc16_q[15:8] ^ s_lut_q[(s_user_crc16_q[7:0])^s_user_wr_data];
    end
  end
  dffr #(16) u_user_crc16_dffr (
      apb4.pclk,
      apb4.presetn,
      s_user_crc16_d,
      s_user_crc16_q
  );


endmodule
