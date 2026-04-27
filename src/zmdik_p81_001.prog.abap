*&---------------------------------------------------------------------*
*& Include          ZMDIK_P79_001
*&---------------------------------------------------------------------*
type-pools: salv.


data: gs_data     type          zmdik_erec,
      gt_data     type table of zmdik_erec,
      gv_last_idx type i.

data: gs_erec type zmdik_erec.     " Dynpro

data  gv_init_0100 type abap_bool.

class lcl_report definition deferred.
data: go_report type ref to lcl_report.

data  gt_sel_map type standard table of i with empty key.

data  g_screen_mode type c.
