*&---------------------------------------------------------------------*
*& Report ZMDIK_P024
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P024.

data: gt_table TYPE TABLE of sflight.

PARAMETERS: carrid TYPE sflight-carrid,
            connid TYPE sflight-connid,
            rows TYPE i.

CALL FUNCTION 'ZMDIK_FM_001'
 EXPORTING
   IV_CARRID       = carrid
   IV_CONNID       = connid
   IV_ROWS         = rows
 IMPORTING
   LV_SONUC        = gt_table
          .
