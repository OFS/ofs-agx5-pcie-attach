# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
# Memory pin and location assignments
#
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# DDR4 Component CH0 (Bank 2B)
#-----------------------------------------------------------------------------
set_location_assignment PIN_BR49 -to ddr4_mem_ref_clk[0].clk
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to ddr4_mem_ref_clk[0].clk
set_location_assignment PIN_BR52 -to ddr4_mem_ref_clk[0].oct_rzqin
set_location_assignment PIN_CF52 -to ddr4_mem[0].a[0]
set_location_assignment PIN_CH52 -to ddr4_mem[0].a[1]
set_location_assignment PIN_CC52 -to ddr4_mem[0].a[2]
set_location_assignment PIN_CA52 -to ddr4_mem[0].a[3]
set_location_assignment PIN_CF49 -to ddr4_mem[0].a[4]
set_location_assignment PIN_CH49 -to ddr4_mem[0].a[5]
set_location_assignment PIN_CH41 -to ddr4_mem[0].a[6]
set_location_assignment PIN_CF41 -to ddr4_mem[0].a[7]
set_location_assignment PIN_CC41 -to ddr4_mem[0].a[8]
set_location_assignment PIN_CA41 -to ddr4_mem[0].a[9]
set_location_assignment PIN_CH38 -to ddr4_mem[0].a[10]
set_location_assignment PIN_CF38 -to ddr4_mem[0].a[11]
set_location_assignment PIN_BU52 -to ddr4_mem[0].a[12]
set_location_assignment PIN_BW49 -to ddr4_mem[0].a[13]
set_location_assignment PIN_CA49 -to ddr4_mem[0].a[14]
set_location_assignment PIN_BR41 -to ddr4_mem[0].a[15]
set_location_assignment PIN_BU41 -to ddr4_mem[0].a[16]
set_location_assignment PIN_CL45 -to ddr4_mem[0].act_n
set_location_assignment PIN_BR38 -to ddr4_mem[0].alert_n
set_location_assignment PIN_BU38 -to ddr4_mem[0].ba[0]
set_location_assignment PIN_CA38 -to ddr4_mem[0].ba[1]
set_location_assignment PIN_BW38 -to ddr4_mem[0].bg[0]
set_location_assignment PIN_CL42 -to ddr4_mem[0].bg[1]
set_location_assignment PIN_CK33 -to ddr4_mem_ref_clk[0].ck_t
set_location_assignment PIN_CL30 -to ddr4_mem_ref_clk[0].ck_c
set_location_assignment PIN_CK35 -to ddr4_mem[0].cke
set_location_assignment PIN_CK48 -to ddr4_mem[0].cs_n
set_location_assignment PIN_BP41 -to ddr4_mem[0].dbi_n[0]
set_location_assignment PIN_CL56 -to ddr4_mem[0].dbi_n[1]
set_location_assignment PIN_BF57 -to ddr4_mem[0].dbi_n[2]
set_location_assignment PIN_CL14 -to ddr4_mem[0].dbi_n[3]
set_location_assignment PIN_BK38 -to ddr4_mem[0].dq[0]
set_location_assignment PIN_BH49 -to ddr4_mem[0].dq[1]
set_location_assignment PIN_BH41 -to ddr4_mem[0].dq[2]
set_location_assignment PIN_BH52 -to ddr4_mem[0].dq[3]
set_location_assignment PIN_BH38 -to ddr4_mem[0].dq[4]
set_location_assignment PIN_BP52 -to ddr4_mem[0].dq[5]
set_location_assignment PIN_BM38 -to ddr4_mem[0].dq[6]
set_location_assignment PIN_BM52 -to ddr4_mem[0].dq[7]
set_location_assignment PIN_CL51 -to ddr4_mem[0].dq[8]
set_location_assignment PIN_CK66 -to ddr4_mem[0].dq[9]
set_location_assignment PIN_CK54 -to ddr4_mem[0].dq[10]
set_location_assignment PIN_CL73 -to ddr4_mem[0].dq[11]
set_location_assignment PIN_CL54 -to ddr4_mem[0].dq[12]
set_location_assignment PIN_CK73 -to ddr4_mem[0].dq[13]
set_location_assignment PIN_CK56 -to ddr4_mem[0].dq[14]
set_location_assignment PIN_CL70 -to ddr4_mem[0].dq[15]
set_location_assignment PIN_BF50 -to ddr4_mem[0].dq[16]
set_location_assignment PIN_BF64 -to ddr4_mem[0].dq[17]
set_location_assignment PIN_BE50 -to ddr4_mem[0].dq[18]
set_location_assignment PIN_BF68 -to ddr4_mem[0].dq[19]
set_location_assignment PIN_BE46 -to ddr4_mem[0].dq[20]
set_location_assignment PIN_BE64 -to ddr4_mem[0].dq[21]
set_location_assignment PIN_BF46 -to ddr4_mem[0].dq[22]
set_location_assignment PIN_BE68 -to ddr4_mem[0].dq[23]
set_location_assignment PIN_CK8  -to ddr4_mem[0].dq[24]
set_location_assignment PIN_CK20 -to ddr4_mem[0].dq[25]
set_location_assignment PIN_CK11 -to ddr4_mem[0].dq[26]
set_location_assignment PIN_CL20 -to ddr4_mem[0].dq[27]
set_location_assignment PIN_CL6  -to ddr4_mem[0].dq[28]
set_location_assignment PIN_CK26 -to ddr4_mem[0].dq[29]
set_location_assignment PIN_CL8  -to ddr4_mem[0].dq[30]
set_location_assignment PIN_CL23 -to ddr4_mem[0].dq[31]
set_location_assignment PIN_BK49 -to ddr4_mem[0].dqs_t[0]
set_location_assignment PIN_CK63 -to ddr4_mem[0].dqs_t[1]
set_location_assignment PIN_BE61 -to ddr4_mem[0].dqs_t[2]
set_location_assignment PIN_CK17 -to ddr4_mem[0].dqs_t[3]
set_location_assignment PIN_BM49 -to ddr4_mem[0].dqs_c[0]
set_location_assignment PIN_CL66 -to ddr4_mem[0].dqs_c[1]
set_location_assignment PIN_BE57 -to ddr4_mem[0].dqs_c[2]
set_location_assignment PIN_CL17 -to ddr4_mem[0].dqs_c[3]
set_location_assignment PIN_CK39 -to ddr4_mem[0].odt
set_location_assignment PIN_CL26 -to ddr4_mem[0].par
set_location_assignment PIN_CK45 -to ddr4_mem_ref_clk[0].reset_n

#-----------------------------------------------------------------------------
# DDR4 Component CH1 (Bank 3A)
#-----------------------------------------------------------------------------
set_location_assignment PIN_AB117 -to ddr4_mem_ref_clk[1].clk
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to ddr4_mem_ref_clk[1].clk
set_location_assignment PIN_AK111 -to ddr4_mem_ref_clk[1].oct_rzqin
set_location_assignment PIN_T114  -to ddr4_mem_group_1[0].a[0]
set_location_assignment PIN_P114  -to ddr4_mem_group_1[0].a[1]
set_location_assignment PIN_V117  -to ddr4_mem_group_1[0].a[2]
set_location_assignment PIN_T117  -to ddr4_mem_group_1[0].a[3]
set_location_assignment PIN_M114  -to ddr4_mem_group_1[0].a[4]
set_location_assignment PIN_K114  -to ddr4_mem_group_1[0].a[5]
set_location_assignment PIN_V108  -to ddr4_mem_group_1[0].a[6]
set_location_assignment PIN_T108  -to ddr4_mem_group_1[0].a[7]
set_location_assignment PIN_T105  -to ddr4_mem_group_1[0].a[8]
set_location_assignment PIN_P105  -to ddr4_mem_group_1[0].a[9]
set_location_assignment PIN_M105  -to ddr4_mem_group_1[0].a[10]
set_location_assignment PIN_K105  -to ddr4_mem_group_1[0].a[11]
set_location_assignment PIN_AG111 -to ddr4_mem_group_1[0].a[12]
set_location_assignment PIN_Y114  -to ddr4_mem_group_1[0].a[13]
set_location_assignment PIN_AB114 -to ddr4_mem_group_1[0].a[14]
set_location_assignment PIN_AK107 -to ddr4_mem_group_1[0].a[15]
set_location_assignment PIN_AK104 -to ddr4_mem_group_1[0].a[16]
set_location_assignment PIN_M117  -to ddr4_mem_group_1[0].act_n
set_location_assignment PIN_Y108  -to ddr4_mem_group_1[0].alert_n
set_location_assignment PIN_AB108 -to ddr4_mem_group_1[0].ba[0]
set_location_assignment PIN_Y105  -to ddr4_mem_group_1[0].ba[1]
set_location_assignment PIN_AB105 -to ddr4_mem_group_1[0].bg[0]
set_location_assignment PIN_F117  -to ddr4_mem_group_1[0].bg[1]
set_location_assignment PIN_H108  -to ddr4_mem_ref_clk[1].ck_t
set_location_assignment PIN_F108  -to ddr4_mem_ref_clk[1].ck_c
set_location_assignment PIN_F105  -to ddr4_mem_group_1[0].cke
set_location_assignment PIN_K117  -to ddr4_mem_group_1[0].cs_n
set_location_assignment PIN_B119  -to ddr4_mem_group_1[0].dbi_n[0]
set_location_assignment PIN_AC90  -to ddr4_mem_group_1[0].dbi_n[1]
set_location_assignment PIN_V87   -to ddr4_mem_group_1[0].dbi_n[2]
set_location_assignment PIN_H87   -to ddr4_mem_group_1[0].dbi_n[3]
set_location_assignment PIN_B97   -to ddr4_mem_group_1[0].dbi_n[4]
set_location_assignment PIN_A128  -to ddr4_mem_group_1[0].dq[0]
set_location_assignment PIN_A113  -to ddr4_mem_group_1[0].dq[1]
set_location_assignment PIN_B128  -to ddr4_mem_group_1[0].dq[2]
set_location_assignment PIN_B113  -to ddr4_mem_group_1[0].dq[3]
set_location_assignment PIN_A130  -to ddr4_mem_group_1[0].dq[4]
set_location_assignment PIN_A116  -to ddr4_mem_group_1[0].dq[5]
set_location_assignment PIN_B130  -to ddr4_mem_group_1[0].dq[6]
set_location_assignment PIN_B116  -to ddr4_mem_group_1[0].dq[7]
set_location_assignment PIN_AC96  -to ddr4_mem_group_1[0].dq[8]
set_location_assignment PIN_Y95   -to ddr4_mem_group_1[0].dq[9]
set_location_assignment PIN_Y98   -to ddr4_mem_group_1[0].dq[10]
set_location_assignment PIN_AG104 -to ddr4_mem_group_1[0].dq[11]
set_location_assignment PIN_AC100 -to ddr4_mem_group_1[0].dq[12]
set_location_assignment PIN_Y87   -to ddr4_mem_group_1[0].dq[13]
set_location_assignment PIN_AG100 -to ddr4_mem_group_1[0].dq[14]
set_location_assignment PIN_Y84   -to ddr4_mem_group_1[0].dq[15]
set_location_assignment PIN_V98   -to ddr4_mem_group_1[0].dq[16]
set_location_assignment PIN_P84   -to ddr4_mem_group_1[0].dq[17]
set_location_assignment PIN_T95   -to ddr4_mem_group_1[0].dq[18]
set_location_assignment PIN_T84   -to ddr4_mem_group_1[0].dq[19]
set_location_assignment PIN_T98   -to ddr4_mem_group_1[0].dq[20]
set_location_assignment PIN_M84   -to ddr4_mem_group_1[0].dq[21]
set_location_assignment PIN_P95   -to ddr4_mem_group_1[0].dq[22]
set_location_assignment PIN_K84   -to ddr4_mem_group_1[0].dq[23]
set_location_assignment PIN_K98   -to ddr4_mem_group_1[0].dq[24]
set_location_assignment PIN_K87   -to ddr4_mem_group_1[0].dq[25]
set_location_assignment PIN_H98   -to ddr4_mem_group_1[0].dq[26]
set_location_assignment PIN_M87   -to ddr4_mem_group_1[0].dq[27]
set_location_assignment PIN_M98   -to ddr4_mem_group_1[0].dq[28]
set_location_assignment PIN_F84   -to ddr4_mem_group_1[0].dq[29]
set_location_assignment PIN_F98   -to ddr4_mem_group_1[0].dq[30]
set_location_assignment PIN_D84   -to ddr4_mem_group_1[0].dq[31]
set_location_assignment PIN_A110  -to ddr4_mem_group_1[0].dq[32]
set_location_assignment PIN_B91   -to ddr4_mem_group_1[0].dq[33]
set_location_assignment PIN_B106  -to ddr4_mem_group_1[0].dq[34]
set_location_assignment PIN_A91   -to ddr4_mem_group_1[0].dq[35]
set_location_assignment PIN_A106  -to ddr4_mem_group_1[0].dq[36]
set_location_assignment PIN_B88   -to ddr4_mem_group_1[0].dq[37]
set_location_assignment PIN_B103  -to ddr4_mem_group_1[0].dq[38]
set_location_assignment PIN_A94   -to ddr4_mem_group_1[0].dq[39]
set_location_assignment PIN_B122  -to ddr4_mem_group_1[0].dqs_t[0]
set_location_assignment PIN_AG90  -to ddr4_mem_group_1[0].dqs_t[1]
set_location_assignment PIN_K95   -to ddr4_mem_group_1[0].dqs_t[2]
set_location_assignment PIN_F95   -to ddr4_mem_group_1[0].dqs_t[3]
set_location_assignment PIN_A101  -to ddr4_mem_group_1[0].dqs_t[4]
set_location_assignment PIN_A125  -to ddr4_mem_group_1[0].dqs_c[0]
set_location_assignment PIN_AG93  -to ddr4_mem_group_1[0].dqs_c[1]
set_location_assignment PIN_M95   -to ddr4_mem_group_1[0].dqs_c[2]
set_location_assignment PIN_D95   -to ddr4_mem_group_1[0].dqs_c[3]
set_location_assignment PIN_B101  -to ddr4_mem_group_1[0].dqs_c[4]
set_location_assignment PIN_F114  -to ddr4_mem_group_1[0].odt
set_location_assignment PIN_K108  -to ddr4_mem_group_1[0].par
set_location_assignment PIN_H117  -to ddr4_mem_ref_clk[1].reset_n

