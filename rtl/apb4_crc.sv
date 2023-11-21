// Copyright (c) 2023 Beijing Institute of Open Source Chip
// rtc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

// verilog_format: off
`define CRC_CTRL 4'b0000 //BASEADDR+0x00
`define CRC_DATA 4'b0001 //BASEADDR+0x04
// verilog_format: on

module apb4_crc #(
    parameter int                    DATA_WIDTH = 32,
    parameter logic [DATA_WIDTH-1:0] POLY       = 32'h04C11DB7
) (
    // verilog_format: off
    apb4_if.slave apb4,
    // verilog_format: on
    output logic  irq_o
);

endmodule
