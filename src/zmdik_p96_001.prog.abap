*&---------------------------------------------------------------------*
*& Include          ZMDIK_P96_001
*&---------------------------------------------------------------------*
tables: /mdpes/erec_t010 , kna1 , knb1, adr6, adrt.

types tt_bapiret2 type standard table of bapiret2 with empty key.
types: begin of ty_err,
         key     type string,
         ret_tab type tt_bapiret2,
       end of ty_err.

data: gt_data type  zcl_mdp_erec_srv=>ty_erec_tab.
data: gt_tab_data type  zcl_mdp_erec_srv=>ty_gt_data.
data: bt_data type  zcl_mdp_erec_srv=>ty_erec_tab.
data: gs_data type zcl_mdp_erec_srv=>ty_erec.

types ty_erec like line of gt_data.
types tt_erec type standard table of ty_erec with empty key.
data gt_errmap type hashed table of ty_err with unique key key.
class lcl_report definition deferred.
data: go_report type ref to lcl_report.

data go_srv type ref to zcl_mdp_erec_srv.

data: gs_erec type /mdpes/erec_t010.     " Dynpro

data  gv_init_0100 type abap_bool.

data  gt_sel_map type standard table of i with empty key.

data  g_screen_mode type c.


data: lv_errflds type string,
      lv_errmsg  type string.
data: ls_return type bapiret1,
      lt_return type  zcl_mdp_erec_srv=>tt_bapiret1.

data: lv_saved   type i,
      lv_updated type i,
      lv_skipped type i,
      lv_total   type i.
data lv_only_x type abap_bool.
data gv_remark type char50.

data lv_rule type c.
