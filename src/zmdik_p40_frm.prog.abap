*&---------------------------------------------------------------------*
*& Include          ZMDIK_P40_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .
create OBJECT go_cont                         "konteynır oluşturup id sini verdik.
  EXPORTING

    container_name              = 'CC_ALV'.


CREATE OBJECT go_alv                            "oluşturduğumuz konteynır objesini alv nin alanına verdik
  EXPORTING
    i_parent                = go_cont.




call METHOD go_alv->set_table_for_first_display
  EXPORTING
    i_structure_name              = 'SCARR'

  CHANGING
    it_outtab                     = gt_scarr.
IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  select * from scarr
  INTO TABLE gt_scarr.

ENDFORM.
