*&---------------------------------------------------------------------*
*& Include          ZMDIK_P89_001
*&---------------------------------------------------------------------*
tables zmdik_erec.

data: gsy_data type zgty_str,
      gty_data type standard table of zgty_str with empty key.


data: gs_erec type zmdik_erec.     " Dynpro

data  gv_init_0100 type abap_bool.

class lcl_report definition deferred.
data: go_report type ref to lcl_report.

data  gt_sel_map type standard table of i with empty key.

data  g_screen_mode type c.


data go_srv type ref to zcl_mdp_erec_srv.


types ty_erec like line of gty_data.
types tt_erec type standard table of ty_erec with empty key.


types: begin of ty_errinfo,
         key     type string,
         errmsg  type string,
         errflds type string,
       end of ty_errinfo.

types tt_errmap type hashed table of ty_errinfo with unique key key.
data gt_errmap type tt_errmap.


data: lv_errflds type string,
      lv_errmsg  type string,
      ls_srv     type zgty_str.
