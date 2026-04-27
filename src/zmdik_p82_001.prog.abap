*&---------------------------------------------------------------------*
*& Include          ZMDIK_P79_001
*&---------------------------------------------------------------------*
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

DATA go_srv TYPE REF TO zcl_mdp_erec_srv.
IF go_srv IS INITIAL.
  CREATE OBJECT go_srv.
ENDIF.


DATA: gt_disp TYPE STANDARD TABLE OF zmdik_erec WITH EMPTY KEY,
      gs_disp TYPE zmdik_erec.


DATA gr_disp TYPE REF TO data.
FIELD-SYMBOLS: <gt_disp> TYPE STANDARD TABLE,
               <gs_disp> TYPE any.




FIELD-SYMBOLS:        " dinamik satır
               <ls_src>  TYPE any,        " kaynak satır (gt_data)
               <loekz>   TYPE any.
