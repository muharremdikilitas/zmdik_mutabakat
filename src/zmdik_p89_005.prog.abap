*&---------------------------------------------------------------------*
*& Include          ZMDIK_P89_005
*&---------------------------------------------------------------------*

INITIALIZATION.
CREATE OBJECT go_report.
START-OF-SELECTION.

  go_report->prepare_alv( ).
