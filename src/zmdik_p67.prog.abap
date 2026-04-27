*&---------------------------------------------------------------------*
*& Report ZMDIK_P67
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P67.

INCLUDE zmdik_p67_p001.
INCLUDE zmdik_p67_p002.
INCLUDE zmdik_p67_p003.



initialization.
  title1 = 'Seçim Alanı'.
  title2 = 'Tarih Seçimi'.

  start-of-selection.

  perform: get_data,
           set_layout,
           set_fcat,
           display_alv.
