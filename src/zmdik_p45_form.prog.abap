*&---------------------------------------------------------------------*
*& Include          ZMDIK_P45_FORM
*&---------------------------------------------------------------------*
FORM display_alv .

IF go_grid is INITIAL.

   CREATE OBJECT go_cont
  EXPORTING
    container_name              = 'CC_ALV'.



CREATE OBJECT go_grid
  EXPORTING

    i_parent                = go_cont

  .

    PERFORM register_f4.



CREATE OBJECT go_event_receiver.


    set HANDLER go_event_receiver->handle_onf4 for go_grid.


    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_scarr
        it_fieldcatalog = gt_fcat.



    else.
  call METHOD go_grid->refresh_table_display.

  ENDIF.
    ENDFORM.




    FORM get_data .

  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.











ENDFORM.

FORM set_data .
*
CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
 EXPORTING
   I_STRUCTURE_NAME             = 'SCARR'
  CHANGING
    ct_fieldcat                  = gt_fcat.


IF gt_fcat IS NOT INITIAL.
  LOOP AT gt_fcat ASSIGNING <gfs_fcat>.
    IF <gfs_fcat>-fieldname = 'CARRNAME'.
      <gfs_fcat>-edit = abap_true.
      <gfs_fcat>-f4availabl = abap_true.
    ENDIF.
  ENDLOOP.
ENDIF.



ENDFORM.



*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .
  CLEAR: gs_layout.
  gs_layout-cwidth_opt = abap_true.         "layoutta yaptığımız değişiklikler tüm alv nin tüm kolonlarını etkiler.
  gs_layout-no_toolbar = abap_true.     " bu alv de ki toolbarı kaldırır.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form register_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_f4 .

  data: lt_f4 type LVC_T_F4,
        ls_f4 type lvc_s_f4.

  CLEAR: ls_f4.
  ls_f4-fieldname = 'CARRNAME'.
  ls_f4-register = abap_true.
  append ls_f4 to lt_f4.

      call METHOD go_grid->register_f4_for_fields                             "search help yapmak için kullanırız.
        EXPORTING
          it_f4 = lt_f4
        .
ENDFORM.
