*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTABAKAT2_P004
*&---------------------------------------------------------------------*


initialization.
  if go_lcl_report is initial.
    create object go_lcl_report.
  endif.
  t1 = 'Kullanıcı Seçim Ekranı'.

start-of-selection.
  call method go_lcl_report->init_alv.
  call screen 0100.
