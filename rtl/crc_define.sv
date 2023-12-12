// Copyright (c) 2023 Beijing Institute of Open Source Chip
// crc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_CRC_DEF_SV
`define INC_CRC_DEF_SV

/* register mapping
 * CRC_CTRL:
 * BITS:   | 31:2 | 1  | 0    |
 * FIELDS: | RES  | EN | OVIE |
 * PERMS:  | NONE | RW | RW   |
 * ----------------------------
 * CRC_DATA:
 * BITS:   | 31:0 |
 * FIELDS: | DATA |
 * PERMS:  | RW   |
 * ----------------------------
*/

// verilog_format: off
`define CRC_CTRL 4'b0000 // BASEADDR + 0x00
`define CRC_DATA 4'b0001 // BASEADDR + 0x04

`define CRC_CTRL_ADDR {26'b0, `CRC_CTRL, 2'b00}
`define CRC_DATA_ADDR {26'b0, `CRC_DATA, 2'b00}

`define CRC_CTRL_WIDTH 1
`define CRC_DATA_WIDTH 32
// verilog_format: on

`endif