*&---------------------------------------------------------------------*
*& Report ZMDIK_P009
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P009.
DATA: gv_persid    TYPE zmdik_persid_de,
      gv_persad    TYPE zmdik_persad_de,
      gv_perssoyad TYPE zmdik_persad_de,
      gv_perscins  TYPE zmdik_perscins_de,
      gs_pers_t TYPE zmdik_pers_t,
      gt_pers_t TYPE TABLE of zmdik_pers_t,
      gt_pers_t2 TYPE TABLE of zmdik_pers_t.


INSERT zmdik_pers_t from TABLE gt_pers_t2.

  delete from zmdik_pers_t .
select * FROM zmdik_pers_t into TABLE gt_pers_t2.
  cl_demo_output=>display( gt_pers_t2 ).
