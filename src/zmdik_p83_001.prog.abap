*&---------------------------------------------------------------------*
*& Include          ZMDIK_P83_001
*&---------------------------------------------------------------------*

type-pools: salv.
TYPE-POOLS: icon.

data: gs_data     type          zmdik_erec,
      gt_data     type table of zmdik_erec,
      gv_last_idx type i.

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
         gv_tckid    type zmdik_erec-tckid,
         gv_erdat    type erdat,
         gv_ernam    type ernam,
         gv_erzet    type erzet,
         gv_aenam    type aenam,
         gv_aedat    type aedat,
        gv_aezet    type aezet,
       end of gty_itab.

 data: gt_itab type table of gty_itab,
       gs_itab type          gty_itab.
