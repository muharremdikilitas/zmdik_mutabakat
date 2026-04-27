*&---------------------------------------------------------------------*
*& Report ZMDIK_P65
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P65.

include zmdik_P65_top.
include zmdik_p65_clss.
include zmdik_P65_pbo.
include zmdik_P65_pai.
include zmdik_P65_form.


START-OF-SELECTION.

START-OF-SELECTION.

perform get_data.

PERFORM set_data.

PERFORM set_layout.





call SCREEN 0100.
