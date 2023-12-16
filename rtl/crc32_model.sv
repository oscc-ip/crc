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
//   * polynomial: x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x^1 + 1
//   * data width: 8
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

module crc32_04c11db7 (
    input  [ 7:0] data_i,
    input  [31:0] crc_i,
    output [31:0] crc_o
);

  assign crc_o[0] = data_i[6] ^ data_i[0] ^ crc_i[24] ^ crc_i[30];
  assign crc_o[1] = data_i[7] ^ data_i[6] ^ data_i[1] ^ data_i[0] ^ crc_i[24] ^ crc_i[25] ^ crc_i[30] ^ crc_i[31];
  assign crc_o[2] = data_i[7] ^ data_i[6] ^ data_i[2] ^ data_i[1] ^ data_i[0] ^ crc_i[24] ^ crc_i[25] ^ crc_i[26] ^ crc_i[30] ^ crc_i[31];
  assign crc_o[3] = data_i[7] ^ data_i[3] ^ data_i[2] ^ data_i[1] ^ crc_i[25] ^ crc_i[26] ^ crc_i[27] ^ crc_i[31];
  assign crc_o[4] = data_i[6] ^ data_i[4] ^ data_i[3] ^ data_i[2] ^ data_i[0] ^ crc_i[24] ^ crc_i[26] ^ crc_i[27] ^ crc_i[28] ^ crc_i[30];
  assign crc_o[5] = data_i[7] ^ data_i[6] ^ data_i[5] ^ data_i[4] ^ data_i[3] ^ data_i[1] ^ data_i[0] ^ crc_i[24] ^ crc_i[25] ^ crc_i[27] ^ crc_i[28] ^ crc_i[29] ^ crc_i[30] ^ crc_i[31];
  assign crc_o[6] = data_i[7] ^ data_i[6] ^ data_i[5] ^ data_i[4] ^ data_i[2] ^ data_i[1] ^ crc_i[25] ^ crc_i[26] ^ crc_i[28] ^ crc_i[29] ^ crc_i[30] ^ crc_i[31];
  assign crc_o[7] = data_i[7] ^ data_i[5] ^ data_i[3] ^ data_i[2] ^ data_i[0] ^ crc_i[24] ^ crc_i[26] ^ crc_i[27] ^ crc_i[29] ^ crc_i[31];
  assign crc_o[8] = data_i[4] ^ data_i[3] ^ data_i[1] ^ data_i[0] ^ crc_i[0] ^ crc_i[24] ^ crc_i[25] ^ crc_i[27] ^ crc_i[28];
  assign crc_o[9] = data_i[5] ^ data_i[4] ^ data_i[2] ^ data_i[1] ^ crc_i[1] ^ crc_i[25] ^ crc_i[26] ^ crc_i[28] ^ crc_i[29];
  assign crc_o[10] = data_i[5] ^ data_i[3] ^ data_i[2] ^ data_i[0] ^ crc_i[2] ^ crc_i[24] ^ crc_i[26] ^ crc_i[27] ^ crc_i[29];
  assign crc_o[11] = data_i[4] ^ data_i[3] ^ data_i[1] ^ data_i[0] ^ crc_i[3] ^ crc_i[24] ^ crc_i[25] ^ crc_i[27] ^ crc_i[28];
  assign crc_o[12] = data_i[6] ^ data_i[5] ^ data_i[4] ^ data_i[2] ^ data_i[1] ^ data_i[0] ^ crc_i[4] ^ crc_i[24] ^ crc_i[25] ^ crc_i[26] ^ crc_i[28] ^ crc_i[29] ^ crc_i[30];
  assign crc_o[13] = data_i[7] ^ data_i[6] ^ data_i[5] ^ data_i[3] ^ data_i[2] ^ data_i[1] ^ crc_i[5] ^ crc_i[25] ^ crc_i[26] ^ crc_i[27] ^ crc_i[29] ^ crc_i[30] ^ crc_i[31];
  assign crc_o[14] = data_i[7] ^ data_i[6] ^ data_i[4] ^ data_i[3] ^ data_i[2] ^ crc_i[6] ^ crc_i[26] ^ crc_i[27] ^ crc_i[28] ^ crc_i[30] ^ crc_i[31];
  assign crc_o[15] = data_i[7] ^ data_i[5] ^ data_i[4] ^ data_i[3] ^ crc_i[7] ^ crc_i[27] ^ crc_i[28] ^ crc_i[29] ^ crc_i[31];
  assign crc_o[16] = data_i[5] ^ data_i[4] ^ data_i[0] ^ crc_i[8] ^ crc_i[24] ^ crc_i[28] ^ crc_i[29];
  assign crc_o[17] = data_i[6] ^ data_i[5] ^ data_i[1] ^ crc_i[9] ^ crc_i[25] ^ crc_i[29] ^ crc_i[30];
  assign crc_o[18] = data_i[7] ^ data_i[6] ^ data_i[2] ^ crc_i[10] ^ crc_i[26] ^ crc_i[30] ^ crc_i[31];
  assign crc_o[19] = data_i[7] ^ data_i[3] ^ crc_i[11] ^ crc_i[27] ^ crc_i[31];
  assign crc_o[20] = data_i[4] ^ crc_i[12] ^ crc_i[28];
  assign crc_o[21] = data_i[5] ^ crc_i[13] ^ crc_i[29];
  assign crc_o[22] = data_i[0] ^ crc_i[14] ^ crc_i[24];
  assign crc_o[23] = data_i[6] ^ data_i[1] ^ data_i[0] ^ crc_i[15] ^ crc_i[24] ^ crc_i[25] ^ crc_i[30];
  assign crc_o[24] = data_i[7] ^ data_i[2] ^ data_i[1] ^ crc_i[16] ^ crc_i[25] ^ crc_i[26] ^ crc_i[31];
  assign crc_o[25] = data_i[3] ^ data_i[2] ^ crc_i[17] ^ crc_i[26] ^ crc_i[27];
  assign crc_o[26] = data_i[6] ^ data_i[4] ^ data_i[3] ^ data_i[0] ^ crc_i[18] ^ crc_i[24] ^ crc_i[27] ^ crc_i[28] ^ crc_i[30];
  assign crc_o[27] = data_i[7] ^ data_i[5] ^ data_i[4] ^ data_i[1] ^ crc_i[19] ^ crc_i[25] ^ crc_i[28] ^ crc_i[29] ^ crc_i[31];
  assign crc_o[28] = data_i[6] ^ data_i[5] ^ data_i[2] ^ crc_i[20] ^ crc_i[26] ^ crc_i[29] ^ crc_i[30];
  assign crc_o[29] = data_i[7] ^ data_i[6] ^ data_i[3] ^ crc_i[21] ^ crc_i[27] ^ crc_i[30] ^ crc_i[31];
  assign crc_o[30] = data_i[7] ^ data_i[4] ^ crc_i[22] ^ crc_i[28] ^ crc_i[31];
  assign crc_o[31] = data_i[5] ^ crc_i[23] ^ crc_i[29];

endmodule
