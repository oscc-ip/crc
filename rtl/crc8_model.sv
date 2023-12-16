////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 1999-2008 Easics NV.
// This source file may be used and distributed without restriction
// provided that this copyright statement is not removed from the file
// and that any derivative work contains the original copyright notice
// and the associated disclaimer.
//
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// Purpose : synthesizable CRC function
//   * polynomial: x^8 + x^2 + x^1 + 1
//   * data width: 2
//
// Info : tools@easics.be
//        http://www.easics.com
//
// -- Adaptable modifications are redistributed under compatible License --
//
// Copyright (c) 2023 Beijing Institute of Open Source Chip
// crc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

module crc8_07 (
    input  [1:0] data_i,
    input  [7:0] crc_i,
    output [7:0] crc_o
);

  assign crc_o[0] = data_i[0] ^ crc_i[6];
  assign crc_o[1] = data_i[1] ^ data_i[0] ^ crc_i[6] ^ crc_i[7];
  assign crc_o[2] = data_i[1] ^ data_i[0] ^ crc_i[0] ^ crc_i[6] ^ crc_i[7];
  assign crc_o[3] = data_i[1] ^ crc_i[1] ^ crc_i[7];
  assign crc_o[4] = crc_i[2];
  assign crc_o[5] = crc_i[3];
  assign crc_o[6] = crc_i[4];
  assign crc_o[7] = crc_i[5];
endmodule
