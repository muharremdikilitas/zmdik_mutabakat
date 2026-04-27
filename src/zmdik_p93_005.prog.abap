*&---------------------------------------------------------------------*
*& Include          ZMDIK_P89_005
*&---------------------------------------------------------------------*

initialization.
  create object go_report.
  create object go_srv.

at selection-screen on value-request for  p_acno-low.

  go_report->f4_interlocutor(
      exporting
        iv_ptype   = p_koart-low
        iv_bukrs   = p_bukrs
      changing
        cv_interlocutor =  p_acno-low  ).

start-of-selection.

  go_report->start_alv( ).
