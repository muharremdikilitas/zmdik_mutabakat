*&---------------------------------------------------------------------*
*& Include          ZMDIK_P86_I04
*&---------------------------------------------------------------------*


initialization.
*-
  create object go_report.
  go_report->initialization( ).

at selection-screen output.
*-
  go_report->set_first_status( ).

at selection-screen.
*-
  go_report->at_selection_screen( ).

start-of-selection.
*-
  go_report->check_fields( ).
  go_report->start_report( ).

end-of-selection.
*-
  go_report->prepare_alv( ).
