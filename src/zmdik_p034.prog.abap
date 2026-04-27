*&---------------------------------------------------------------------*
*& Report ZMDIK_P034
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P034.



include zmdik_p034_p001.
include zmdik_p034_p002.
include zmdik_p034_p003.


START-OF-SELECTION.
perform: get_data.
PERFORM set_fcat.
perform  set_layout.
 PERFORM   display_alv.
