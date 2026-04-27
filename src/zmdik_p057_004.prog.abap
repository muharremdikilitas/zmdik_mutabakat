*&---------------------------------------------------------------------*
*& Include          ZMDIK_P057_004
*&---------------------------------------------------------------------*

INITIALIZATION.
CREATE OBJECT go_report.

START-OF-SELECTION.
go_report->select( ).
go_report->mainloop( ).


end-of-SELECTION.

go_report->prepare_alv( ).
