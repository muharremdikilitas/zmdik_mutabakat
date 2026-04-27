*&---------------------------------------------------------------------*
*& Report ZMDIK_P028
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P028.
data: gt_data TYPE TABLE OF scarr.
FIELD-SYMBOLS: <fs_001> type scarr.


SELECT * from scarr INTO TABLE gt_data.

LOOP AT gt_data ASSIGNING <fs_001>.
  IF <fs_001>-carrid eq 'LH'.
    <fs_001>-carrname = 'Muharrem'.
     .

  ENDIF.

ENDLOOP.

APPEND INITIAL LINE TO  gt_data ASSIGNING <fs_001>.
IF <fs_001> is INITIAL.
    <fs_001>-carrid = 'ZZ' .
    <fs_001>-carrname = 'TRY'.
ENDIF.

modify scarr from TABLE gt_data.
SELECT * from scarr INTO TABLE gt_data.


cl_demo_output=>display( gt_data ).
