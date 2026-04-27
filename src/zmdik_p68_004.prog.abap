*&---------------------------------------------------------------------*
*& Include          ZMDIK_P68_004
*&---------------------------------------------------------------------*


INITIALIZATION.
  CREATE OBJECT go_report.

START-OF-SELECTION.

go_report->select( ).
go_report->mainloop( ).


END-OF-SELECTION.

go_report->prepare_alv( ).
