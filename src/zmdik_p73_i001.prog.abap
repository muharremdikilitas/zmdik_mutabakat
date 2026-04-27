*&---------------------------------------------------------------------*
*& Include          ZMDIK_P73_I001
*&---------------------------------------------------------------------*

data: gv_comp_code   type       bukrs,
      gv_doc_date    type       zmdkp_de002,
      gv_proc_type   type       zmdkp_de003 value '1',
      gv_snd_cust_no type       bukrs,
      gv_snd_name    type       zmdkp_de004,
      gv_snd_bank    type       zmdkp_de005,
      gv_snd_acc_no  type       hktid,
      gv_amount      type       p decimals 2,
      gv_snd_iban    type       iban,
      gv_snd_pb      type       waers,
      gv_rcv_cust_no type       bukrs,
      gv_rvc_name    type       zmdkp_de007,
      gv_rvc_bank    type       zmdkp_de005,
      gv_rvc_acc_no  type       hktid,
      gv_rvc_amount  type       p decimals 2,
      gv_rvc_iban    type       iban,
      gv_rvc_pb      type       waers.



data: gv_dynpro_num type char4.

data: gt_talimat type table of zmdp_t001,
      gs_talimat type zmdp_t001.

data: gt_fx_talimat type table of zmdp_t002,
      gs_fx_talimat type          zmdp_t002.

class lcl_report definition deferred.
data: go_report type ref to lcl_report.
