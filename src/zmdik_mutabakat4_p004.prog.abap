*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTABAKAT4_P004
*&---------------------------------------------------------------------*

initialization.
*-
  create object go_agreement.
  go_agreement->initialization( ).

at selection-screen output.
*-
  go_agreement->set_first_status( ).

at selection-screen.
*-
  go_agreement->at_selection_screen( ).

start-of-selection.
*-
  go_agreement->check_fields( ).
  go_agreement->start_report( ).

end-of-selection.
*-
  go_agreement->prepare_alv( ).
