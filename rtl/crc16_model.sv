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
//   * polynomial: x^16 + x^12 + x^5 + 1
//   * data width: 4
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

module crc16_1021 (
    input  [ 3:0] data_i,
    input  [15:0] crc_i,
    output [15:0] crc_o
);

  assign crc_o[0]  = data_i[0] ^ crc_i[12];
  assign crc_o[1]  = data_i[1] ^ crc_i[13];
  assign crc_o[2]  = data_i[2] ^ crc_i[14];
  assign crc_o[3]  = data_i[3] ^ crc_i[15];
  assign crc_o[4]  = crc_i[0];
  assign crc_o[5]  = data_i[0] ^ crc_i[1] ^ crc_i[12];
  assign crc_o[6]  = data_i[1] ^ crc_i[2] ^ crc_i[13];
  assign crc_o[7]  = data_i[2] ^ crc_i[3] ^ crc_i[14];
  assign crc_o[8]  = data_i[3] ^ crc_i[4] ^ crc_i[15];
  assign crc_o[9]  = crc_i[5];
  assign crc_o[10] = crc_i[6];
  assign crc_o[11] = crc_i[7];
  assign crc_o[12] = data_i[0] ^ crc_i[8] ^ crc_i[12];
  assign crc_o[13] = data_i[1] ^ crc_i[9] ^ crc_i[13];
  assign crc_o[14] = data_i[2] ^ crc_i[10] ^ crc_i[14];
  assign crc_o[15] = data_i[3] ^ crc_i[11] ^ crc_i[15];

endmodule

// Purpose : synthesizable CRC function
//   * polynomial: x^16 + x^15 + x^2 + 1
//   * data width: 4
module crc16_8005 (
    input  [ 3:0] data_i,
    input  [15:0] crc_i,
    output [15:0] crc_o
);
  assign crc_o[0] = data_i[3] ^ data_i[2] ^ data_i[1] ^ data_i[0] ^ crc_i[12] ^ crc_i[13] ^ crc_i[14] ^ crc_i[15];
  assign crc_o[1] = data_i[3] ^ data_i[2] ^ data_i[1] ^ crc_i[13] ^ crc_i[14] ^ crc_i[15];
  assign crc_o[2] = data_i[1] ^ data_i[0] ^ crc_i[12] ^ crc_i[13];
  assign crc_o[3] = data_i[2] ^ data_i[1] ^ crc_i[13] ^ crc_i[14];
  assign crc_o[4] = data_i[3] ^ data_i[2] ^ crc_i[0] ^ crc_i[14] ^ crc_i[15];
  assign crc_o[5] = data_i[3] ^ crc_i[1] ^ crc_i[15];
  assign crc_o[6] = crc_i[2];
  assign crc_o[7] = crc_i[3];
  assign crc_o[8] = crc_i[4];
  assign crc_o[9] = crc_i[5];
  assign crc_o[10] = crc_i[6];
  assign crc_o[11] = crc_i[7];
  assign crc_o[12] = crc_i[8];
  assign crc_o[13] = crc_i[9];
  assign crc_o[14] = crc_i[10];
  assign crc_o[15] = data_i[3] ^ data_i[2] ^ data_i[1] ^ data_i[0] ^ crc_i[11] ^ crc_i[12] ^ crc_i[13] ^ crc_i[14] ^ crc_i[15];
endmodule
