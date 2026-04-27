*&---------------------------------------------------------------------*
*& Report ZMDIK_P033
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P033.



INCLUDE zmdik_p033_p001. "data
INCLUDE zmdik_p033_p002.  "
INCLUDE zmdik_p033_p003.



start-of-selection.
  perform: get_data,
           set_layout,
           set_fieldcat,
           display_alv.
