*&---------------------------------------------------------------------*
*& Include          ZMDIK_P90_001
*&---------------------------------------------------------------------*
type-pools: ole2.
tables: sscrfields.

types: begin of ty_errinfo,
         key     type string,
         ret_tab type zcl_mdp_erec_srv=>tt_bapiret1,
       end of ty_errinfo.

types tt_errmap type hashed table of ty_errinfo with unique key key.

data: gt_data type  zcl_mdp_erec_srv=>ty_erec_tab.
data: lt_new  type  zcl_mdp_erec_srv=>ty_erec_tab.
data: gs_data type zcl_mdp_erec_srv=>ty_erec.

types ty_erec like line of gt_data.
types tt_erec type standard table of ty_erec with empty key.

data: ls_row type ty_erec.

class lcl_report definition deferred.
data: go_report type ref to lcl_report.

data go_srv type ref to zcl_mdp_erec_srv.

data: gs_erec type /mdpes/erec_t010.     " Dynpro

data  gv_init_0100 type abap_bool.

data  gt_sel_map type standard table of i with empty key.

data  g_screen_mode type c.

data gt_errmap type tt_errmap.
data: lv_errflds type string,
      lv_errmsg  type string.
data: ls_return type bapiret1,
      lt_return type  zcl_mdp_erec_srv=>tt_bapiret1.
