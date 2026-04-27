*&---------------------------------------------------------------------*
*& Include          ZMDIK_P014_002
*&---------------------------------------------------------------------*



SELECT-OPTIONS s_carrid for scarr-carrid.



START-OF-SELECTION.

select * FROM scarr INTO TABLE gt_scarr WHERE carrid in s_carrid.



  if gt_scarr is NOT INITIAL.

  SELECT * FROM sflight into CORRESPONDING FIELDS OF TABLE gt_sflight FOR ALL ENTRIES IN gt_scarr where carrid = gt_scarr-carrid.

ENDIF.
    if gt_sflight is NOT INITIAL.

      LOOP AT gt_sflight into gs_sflight .
        WRITE: / 'Havayolu Kodu' , gs_sflight-carrid,
                  'Uçuş Numarası' , gs_sflight-connid,
                  'Max Koltuk Sayısı' , gs_sflight-seatsmax.

      ENDLOOP.
      ENDIF.
