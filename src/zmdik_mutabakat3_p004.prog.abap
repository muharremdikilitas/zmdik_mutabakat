*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTABAKAT3_P004
*&---------------------------------------------------------------------*
INITIALIZATION.
*-
  CREATE OBJECT go_report.
  go_report->initialization( ).

AT SELECTION-SCREEN OUTPUT.
*-
  go_report->set_first_status( ).

AT SELECTION-SCREEN.
*-
  go_report->at_selection_screen( ).

START-OF-SELECTION.
*-
  go_report->check_fields( ).
  go_report->start_report( ).

END-OF-SELECTION.
*-
  go_report->prepare_alv( ).
