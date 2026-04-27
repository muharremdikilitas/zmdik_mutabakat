*&---------------------------------------------------------------------*
*& Include          ZMDIK_P89_001
*&---------------------------------------------------------------------*

types: begin of gty_itab,
         gv_parnr type parnr,
         gv_bukrs type bukrs,
         gv_koart type zmdik_erec-koart,
         gv_accno type zmdik_erec-accno,
         gv_ptype type zmdik_erec-ptype,
         gv_loekz type zmdik_erec-loekz,
         gv_ename type zmdik_erec-ename,
         gv_email type zmdik_erec-email,
         gv_telf  type zmdik_erec-telf1,
         gv_tckid type zmdik_erec-tckid,
         gv_erdat type char12,
         gv_ernam type char12,
         gv_erzet type char12,
         gv_aenam type char12,
         gv_aedat type char12,
         gv_aezet type char12,
       end of gty_itab.

data: gt_itab type table of gty_itab,
      gs_itab type          gty_itab.

data: gsy_data type zgty_str,
      gty_data type table of zgty_str.


data: gs_erec type zmdik_erec.     " Dynpro

data  gv_init_0100 type abap_bool.

class lcl_report definition deferred.
data: go_report type ref to lcl_report.

data  gt_sel_map type standard table of i with empty key.

data  g_screen_mode type c.


data go_srv type ref to zcl_mdp_erec_srv.
if go_srv is initial.
  create object go_srv.
endif.

types ty_erec like line of gty_data.
types tt_erec type standard table of ty_erec with empty key.


types: begin of ty_errinfo,
         key     type string,
         errmsg  type string,
         errflds type string,
       end of ty_errinfo.

types tt_errmap type hashed table of ty_errinfo with unique key key.
data gt_errmap type tt_errmap.
