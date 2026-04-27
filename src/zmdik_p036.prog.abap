*&---------------------------------------------------------------------*
*& Report ZMDIK_P036
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P036.





INCLUDE  ZMDIK_P036_p001.
INCLUDE  ZMDIK_P036_p002.
INCLUDE  ZMDIK_P036_p003.


START-OF-SELECTION.
PERFORM get_data.
PERFORM set_layout.
PERFORM set_fieldcat.
PERFORM display_alv.
