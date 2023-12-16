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
`include "crc_define.sv"

// four apb clock
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
  } fsm_t;

  logic [3:0] s_apb4_addr;
  logic [`CRC_CTRL_WIDTH-1:0] s_crc_ctrl_d, s_crc_ctrl_q;
  logic [`CRC_INIT_WIDTH-1:0] s_crc_init_d, s_crc_init_q;
  logic [`CRC_XORV_WIDTH-1:0] s_crc_xorv_d, s_crc_xorv_q;
  logic [`CRC_DATA_WIDTH-1:0] s_crc_data_d, s_crc_data_q;
  logic [`CRC_STAT_WIDTH-1:0] s_crc_stat_d, s_crc_stat_q;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk, s_crc_wr_val;
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

  logic s_bit_revout, s_bit_revin, s_bit_clr, s_bit_en, s_bit_done;
  logic [1:0] s_bit_crc_mode;
  fsm_t fsm_state_d, fsm_state_q;

  assign s_apb4_addr     = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready     = 1'b1;
  assign apb4.pslverr    = 1'b0;
  assign s_bit_revout    = s_crc_ctrl_q[3];
  assign s_bit_revin     = s_crc_ctrl_q[2];
  assign s_bit_clr       = s_crc_ctrl_q[1];
  assign s_bit_en        = s_crc_ctrl_q[0];
  assign s_bit_done      = s_crc_stat_q[0];
  assign s_bit_crc_mode  = s_crc_ctrl_q[5:4];
  assign s_crc8_wr       = apb4.pwdata[7:0];
  assign s_crc16_wr      = apb4.pwdata[15:0];
  assign s_crc32_wr      = apb4.pwdata[31:0];

  for (genvar i = 0; i < 8; i++) begin
    assign s_crc8_wr_rev[i] = s_crc8_wr[7-i];
  end

  for (genvar i = 0; i < 16; i++) begin
    if (i < 8) begin
      assign s_crc16_wr_rev[i] = s_crc16_wr[7-i];
    end else begin
      assign s_crc16_wr_rev[i] = s_crc16_wr[15-(i-8)];
    end
  end

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

  assign s_crc_ctrl_d = (s_apb4_wr_hdshk && s_apb4_addr == `CRC_CTRL) ? apb4.pwdata[`CRC_CTRL_WIDTH-1:0] : s_crc_ctrl_q;
  dffr #(`CRC_CTRL_WIDTH) u_crc_ctrl_dffr (
      apb4.pclk,
      apb4.presetn,
      s_crc_ctrl_d,
      s_crc_ctrl_q
  );

  assign s_crc_init_d = (s_apb4_wr_hdshk && s_apb4_addr == `CRC_INIT) ? apb4.pwdata[`CRC_INIT_WIDTH-1:0] : s_crc_init_q;
  dffr #(`CRC_INIT_WIDTH) u_crc_init_dffr (
      apb4.pclk,
      apb4.presetn,
      s_crc_init_d,
      s_crc_init_q
  );

  assign s_crc_xorv_d = (s_apb4_wr_hdshk && s_apb4_addr == `CRC_XORV) ? apb4.pwdata[`CRC_XORV_WIDTH-1:0] : s_crc_xorv_q;
  dffr #(`CRC_XORV_WIDTH) u_crc_xorv_dffr (
      apb4.pclk,
      apb4.presetn,
      s_crc_xorv_d,
      s_crc_xorv_q
  );

  always_comb begin
    s_crc_data_d = s_crc_data_q;
    if (s_apb4_wr_hdshk && s_apb4_addr == `CRC_DATA) begin
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
    end else if (fsm_state_q == DONE) begin
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
  dffr #(`CRC_DATA_WIDTH) u_crc_data_dffr (
      apb4.pclk,
      apb4.presetn,
      s_crc_data_d,
      s_crc_data_q
  );

  always_comb begin
    s_crc_stat_d    = s_crc_stat_q;
    s_crc_stat_d[0] = fsm_state_q == DONE;
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

  always_comb begin
    fsm_state_d = fsm_state_q;
    if (s_bit_en) begin
      unique case (fsm_state_q)
        IDLE: begin
          if (s_apb4_wr_hdshk && s_apb4_addr == `CRC_DATA) begin
            fsm_state_d = SHIFT1;
          end
        end
        SHIFT1:  fsm_state_d = SHIFT2;
        SHIFT2:  fsm_state_d = SHIFT3;
        SHIFT3:  fsm_state_d = SHIFT4;
        SHIFT4:  fsm_state_d = DONE;
        DONE:    fsm_state_d = IDLE;
        default: fsm_state_d = IDLE;
      endcase
    end
  end

  always_ff @(posedge apb4.pclk, negedge apb4.presetn) begin
    if (~apb4.presetn) begin
      fsm_state_q <= IDLE;
    end else begin
      fsm_state_q <= #1 fsm_state_d;
    end
  end

  for (genvar i = 0; i < 8; i++) begin
    assign s_crc8_q_rev[i] = s_crc8_q[7-i];
  end

  always_comb begin
    s_crc8_d = s_crc8_q;
    if (s_bit_clr) begin
      s_crc8_d = s_crc_init_q[7:0];
    end else if (fsm_state_q != IDLE) begin
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
    if (fsm_state_q == SHIFT1) begin
      s_crc8_data = s_crc_data_q[7:6];
    end else if (fsm_state_q == SHIFT2) begin
      s_crc8_data = s_crc_data_q[5:4];
    end else if (fsm_state_q == SHIFT3) begin
      s_crc8_data = s_crc_data_q[3:2];
    end else if (fsm_state_q == SHIFT4) begin
      s_crc8_data = s_crc_data_q[1:0];
    end
  end

  crc8_07 u_crc8_07 (
      .data_i(s_crc8_data),
      .crc_i (s_crc8_q),
      .crc_o (s_crc8_qq)
  );

  for (genvar i = 0; i < 16; i++) begin
    assign s_crc16_q_rev[i] = s_crc16_q[15-i];
  end
  always_comb begin
    s_crc16_d = s_crc16_q;
    if (s_bit_clr) begin
      s_crc16_d = s_crc_init_q[15:0];
    end else if (fsm_state_q != IDLE) begin
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
    if (fsm_state_q == SHIFT1) begin
      s_crc16_data = s_crc_data_q[15:12];
    end else if (fsm_state_q == SHIFT2) begin
      s_crc16_data = s_crc_data_q[11:8];
    end else if (fsm_state_q == SHIFT3) begin
      s_crc16_data = s_crc_data_q[7:4];
    end else if (fsm_state_q == SHIFT4) begin
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

  for (genvar i = 0; i < 32; i++) begin
    assign s_crc32_q_rev[i] = s_crc32_q[31-i];
  end
  always_comb begin
    s_crc32_d = s_crc32_q;
    if (s_bit_clr) begin
      s_crc32_d = s_crc_init_q[31:0];
    end else if (fsm_state_q != IDLE) begin
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
    if (fsm_state_q == SHIFT1) begin
      s_crc32_data = s_crc_data_q[31:24];
    end else if (fsm_state_q == SHIFT2) begin
      s_crc32_data = s_crc_data_q[23:16];
    end else if (fsm_state_q == SHIFT3) begin
      s_crc32_data = s_crc_data_q[15:8];
    end else if (fsm_state_q == SHIFT4) begin
      s_crc32_data = s_crc_data_q[7:0];
    end
  end

  crc32_04c11db7 u_crc32_04c11db7 (
      .data_i(s_crc32_data),
      .crc_i (s_crc32_q),
      .crc_o (s_crc32_qq)
  );
endmodule
