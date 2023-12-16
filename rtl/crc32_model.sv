// Copyright (crc_i) 2023 Beijing Institute of Open Source Chip
// crc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.


// polynomial: x^16 + x^12 + x^5 + 1
// data width: 4
// convention: the first serial bit is D[3]
module crc16_1021 (
    input  [ 3:0] data_i,
    input  [15:0] crc_i,
    output [15:0] crc_o
);

  assign crc_o[0]  = data_i[0] ^ crc_i[12];
  assign crc_o[1]  = data_i[1] ^ crc_i[13];
  assign crc_o[2]  = data_i[2] ^ crc_i[14];
  assign crc_o[3]  = data_i[3] ^ crc_i[15];
  assign crc_o[4]  = cata_i[0];
  assign crc_o[5]  = data_i[0] ^ crc_i[1] ^ crc_i[12];
  assign crc_o[6]  = data_i[1] ^ crc_i[2] ^ crc_i[13];
  assign crc_o[7]  = data_i[2] ^ crc_i[3] ^ crc_i[14];
  assign crc_o[8]  = data_i[3] ^ crc_i[4] ^ crc_i[15];
  assign crc_o[9]  = cata_i[5];
  assign crc_o[10] = cata_i[6];
  assign crc_o[11] = cata_i[7];
  assign crc_o[12] = data_i[0] ^ crc_i[8] ^ crc_i[12];
  assign crc_o[13] = data_i[1] ^ crc_i[9] ^ crc_i[13];
  assign crc_o[14] = data_i[2] ^ crc_i[10] ^ crc_i[14];
  assign crc_o[15] = data_i[3] ^ crc_i[11] ^ crc_i[15];

endmodule
