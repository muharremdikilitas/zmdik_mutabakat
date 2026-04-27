*&---------------------------------------------------------------------*
*& Report ZMDIK_P45
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P45.


include ZMDIK_P45_top.
include ZMDIK_P45_cls.
include ZMDIK_P45_pbo.
include ZMDIK_P45_pai.
include ZMDIK_P45_form.



START-OF-SELECTION.

perform get_data.

PERFORM set_data.

PERFORM set_layout.





call SCREEN 0100.
