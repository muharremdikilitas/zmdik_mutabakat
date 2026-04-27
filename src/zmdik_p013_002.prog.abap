*&---------------------------------------------------------------------*
*& Include          ZMDIK_P013_002
*&---------------------------------------------------------------------*7


select a~carrid, a~fldate, a~connid, b~url UP TO 6 ROWS
from sflight as a
left OUTER join scarr as b
on a~carrid = b~carrid
into CORRESPONDING FIELDS OF table @lt_it.


*LOOP AT it_flight_data INTO ls_flight_data.
*
*  WRITE: / ls_flight_data-carrid, ls_flight_data-connid, ls_flight_data-
*
*ENDLOOP.

cl_demo_output=>display( lt_it ).
