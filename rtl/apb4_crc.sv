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

// 4 apb clock cycle
module apb4_crc (
    apb4_if.slave apb4
);

  logic [3:0] s_apb4_addr;
  logic s_crc_ctrl_d, s_crc_ctrl_q;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk, s_crc_wr_val;

  assign s_apb4_addr = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign s_crc_wr_val = s_apb4_wr_hdshk && s_apb4_addr == `CRC_DATA;
  assign apb4.pready = 1'b1;
  assign apb4.pslverr = 1'b0;


  assign s_crc_ctrl_d = (s_apb4_wr_hdshk && s_apb4_addr == `CRC_CTRL) ? apb4.pwdata[`CRC_CTRL_WIDTH-1:0] : s_crc_ctrl_q;
  dffr #(`CRC_CTRL_WIDTH) u_crc_ctrl_dffr (
      apb4.pclk,
      apb4.presetn,
      s_crc_ctrl_d,
      s_crc_ctrl_q
  );


  localparam int SHIFT_WIDTH = 33 + 32 + 32;
  localparam bit [31:0] POLY = 32'h04C11DB7;
  //    63:31: input  30:0 zero
  logic [SHIFT_WIDTH-1:0] s_shift_d, s_shift_q;
  for (genvar i = 0; i < SHIFT_WIDTH; i++) begin
    if (i >= 64) begin  // 64 <= i <= SHIFT_WIDTH - 1
      if (POLY & (1 << (i - 64))) begin
        assign s_shift_d[i] = s_shift_q[SHIFT_WIDTH-1] ? ~s_shift_q[i-1] : s_shift_q[i-1];
      end else begin
        assign s_shift_d[i] = s_shift_q[i-1];
      end
    end else if (i <= 31) begin  // 0 <= i <= 31
      assign s_shift_d[i] = 1'b0;
    end else begin  // 32 <= i <= 63
      assign s_shift_d[i] = s_crc_wr_val ? apb4.pwdata[i-32] : s_shift_q[i-1];
    end
  end

  dffr #(SHIFT_WIDTH) u_shift_dffr (
      apb4.pclk,
      apb4.presetn,
      s_shift_d,
      s_shift_q
  );

  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `CRC_CTRL: apb4.prdata[`CRC_CTRL_WIDTH-1:0] = s_crc_ctrl_q;
        default:   apb4.prdata = '0;
      endcase
    end
  end
endmodule
