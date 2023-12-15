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

  typedef enum logic {
    IDLE,
    SHIFT1,
    SHIFT2,
    SHIFT3,
    SHIFT4
  } fsm_t;

  logic [3:0] s_apb4_addr;
  logic [`CRC_CTRL_WIDTH-1:0] s_crc_ctrl_d, s_crc_ctrl_q;
  logic [`CRC_INIT_WIDTH-1:0] s_crc_init_d, s_crc_init_q;
  logic [`CRC_XORV_WIDTH-1:0] s_crc_xorv_d, s_crc_xorv_q;
  logic [`CRC_DATA_WIDTH-1:0] s_crc_data_d, s_crc_data_q;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk, s_crc_wr_val;
  logic [15:0] s_crc16_d, s_crc16_q, s_crc16_qq;
  logic [3:0] s_crc16_data;
  fsm_t fsm_state_d, fsm_state_q;
  logic s_bit_revout, s_bit_revin, s_bit_clr, s_bit_en;

  assign s_apb4_addr = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready = 1'b1;
  assign apb4.pslverr = 1'b0;
  assign s_bit_revout = s_crc_ctrl_q[4];
  assign s_bit_revin = s_crc_ctrl_q[3];
  assign s_bit_clr = s_crc_ctrl_q[2];
  assign s_bit_en = s_crc_ctrl_q[0];

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

  assign s_crc_data_d = (s_apb4_wr_hdshk && s_apb4_addr == `CRC_DATA) ? apb4.pwdata[`CRC_DATA_WIDTH-1:0] : s_crc_data_q;
  dffr #(`CRC_DATA_WIDTH) u_crc_data_dffr (
      apb4.pclk,
      apb4.presetn,
      s_crc_data_d,
      s_crc_data_q
  );

  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `CRC_CTRL: apb4.prdata[`CRC_CTRL_WIDTH-1:0] = s_crc_ctrl_q;
        `CRC_INIT: apb4.prdata[`CRC_INIT_WIDTH-1:0] = s_crc_init_q;
        `CRC_XORV: apb4.prdata[`CRC_XORV_WIDTH-1:0] = s_crc_xorv_q;
        `CRC_DATA: apb4.prdata[`CRC_DATA_WIDTH-1:0] = s_crc_data_q ^ s_crc_xorv_q;
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
        SHIFT4:  fsm_state_d = IDLE;
        default: fsm_state_d = IDLE;
      endcase
    end
  end

  always_ff @(posedge apb4.pclk or negedge apb4.presetn) begin
    if (~apb4.presetn) begin
      fsm_state_q <= IDLE;
    end else begin
      fsm_state_q <= fsm_state_d;
    end
  end

  always_comb begin
    s_crc16_d = s_crc16_qq;
    if (s_bit_clr) begin
      s_crc16_d = s_crc_init_q[15:0];
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
      s_crc16_data = s_crc_data_q[3:0];
    end else if (fsm_state_q == SHIFT2) begin
      s_crc16_data = s_crc_data_q[7:4];
    end else if (fsm_state_q == SHIFT3) begin
      s_crc16_data = s_crc_data_q[11:8];
    end else if (fsm_state_q == SHIFT4) begin
      s_crc16_data = s_crc_data_q[15:12];
    end
  end

  crc16_1021 u_crc16_1021 (
      .data_i(s_crc16_data),
      .crc_i (s_crc16_q),
      .crc_o (s_crc16_qq)
  );

endmodule
