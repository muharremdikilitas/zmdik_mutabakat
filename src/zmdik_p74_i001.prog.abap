*&---------------------------------------------------------------------*
*& Include          ZMDIK_P74_I001
*&---------------------------------------------------------------------*

data:
  gv_fx_comp_no      type       bukrs,
  gv_fx_bank         type       zmdkp_de005,
  gv_fx_iban         type       iban,
  gv_fx_iban2        type       iban,
  gv_fx_acc_no       type       hktid,
  gv_fx_amount       type       p length 15 decimals 2,
  gv_fx_amount_trans type       p length 15 decimals  2,
  gv_fx_pb           type       waers,
  gv_fx_acc_no_2     type       hktid,
  gv_fx_pb_trans     type       waers,
  gv_fx_valid_date   type       zmdkp_de009,
  gv_fx_doc_date     type       zmdkp_de010,
  gv_fx_upb_amount   type       p length 15 decimals 2,
  gv_fx_curr_type    type       zmdkp_de012,
  gv_fx_curr         type       p length 15 decimals 5,
  gv_comp_code       type       bukrs,
  gv_proc_type       type       zmdkp_de003 value '1'.


data: gv_dynpro_num type char4.

data: gt_talimat type table of zmdp_t001,
      gs_talimat type zmdp_t001.

data: gt_fx_talimat type table of zmdp_t002,
      gs_fx_talimat type          zmdp_t002.

class lcl_report definition deferred.
data: go_report type ref to lcl_report.
