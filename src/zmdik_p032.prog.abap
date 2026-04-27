*&---------------------------------------------------------------------*
*& Report ZMDIK_P032
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P032.



data: BEGIN OF gst_str,
  pers_id TYPE ZMDIK_PERSID_DE,
  pers_ad TYPE ZMDIK_PERSAD_DE,
  pers_soyad TYPE ZMDIK_PERSSOYAD_DE,
  pers_cins TYPE ZMDIK_PERSCINS_DE,
  END OF gst_str.


  DATA: gt_it like TABLE OF gst_str,
        gs_it like gst_str.


  data: gt_fieldcatalog TYPE slis_t_fieldcat_alv,
        gs_fieldcatalog TYPE slis_fieldcat_alv,
        gs_layout TYPE slis_layout_alv.






  FORM set_fc .

 CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
  EXPORTING
     I_PROGRAM_NAME               = sy-repid
  I_INTERNAL_TABNAME           = 'GT_LIST'
*    I_STRUCTURE_NAME             = 'ZMDIK_DE_S'
     I_INCLNAME                   = sy-repid

    CHANGING
      ct_fieldcat                  = gt_fieldcatalog.



  clear gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'PERS_ID'.
  gs_fieldcatalog-seltext_s = 'pers id'.
  gs_fieldcatalog-seltext_m = 'personel id'.
  gs_fieldcatalog-seltext_l = 'personel id'.
  gs_fieldcatalog-key = abap_true.
  gs_fieldcatalog-col_pos = '0'.
*  gs_fieldcatalog-edit = 'X'.  " Editlenebilir hale getirme

  APPEND gs_fieldcatalog to gt_fieldcatalog.





    clear gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'PERS_AD'.
  gs_fieldcatalog-seltext_s = 'pers ad'.
  gs_fieldcatalog-seltext_m = 'personel ad'.
  gs_fieldcatalog-seltext_l = 'personel ad'.
  gs_fieldcatalog-col_pos = '1'.
*   gs_fieldcatalog-edit = 'X'.  " Editlenebilir hale getirme

  APPEND gs_fieldcatalog to gt_fieldcatalog.




    clear gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'PERS_SOYAD'.
  gs_fieldcatalog-seltext_s = 'pers soyad'.
  gs_fieldcatalog-seltext_m = 'personel soyad'.
  gs_fieldcatalog-seltext_l = 'personel soyad'.
*  gs_fieldcatalog-key = abap_true.
  gs_fieldcatalog-col_pos = '2'.
*   gs_fieldcatalog-edit = 'X'.  " Editlenebilir hale getirme

  APPEND gs_fieldcatalog to gt_fieldcatalog.




    clear gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'PERS_CINS'.
  gs_fieldcatalog-seltext_s = 'pers cins'.
  gs_fieldcatalog-seltext_m = 'personel cins'.
  gs_fieldcatalog-seltext_l = 'personel cins'.
*  gs_fieldcatalog-key = abap_true.
  gs_fieldcatalog-col_pos = '3'.
*   gs_fieldcatalog-edit = 'X'.  " Editlenebilir hale getirme

  APPEND gs_fieldcatalog to gt_fieldcatalog.








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
SELECT * FROM zmdik_pers_t into CORRESPONDING FIELDS OF TABLE gt_it.


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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
     I_CALLBACK_PROGRAM                = sy-repid
     I_CALLBACK_PF_STATUS_SET          = 'PF_STATUS_SET'
     I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
     IS_LAYOUT                         = gs_layout
     IT_FIELDCAT                       = gt_fieldcatalog
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT                           =
*     IT_FILTER                         =
*     IS_SEL_HIDE                       =
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = ' '
*     IS_VARIANT                        =
*     IT_EVENTS                         =
*     IT_EVENT_EXIT                     =
*     IS_PRINT                          =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER           =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab                          = gt_it.
*   EXCEPTIONS
*     PROGRAM_ERROR                     = 1
*     OTHERS                            = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.





form pf_status_set USING p_extab TYPE slis_t_extab.
  SET PF-STATUS '0100'.
  ENDFORM.


FORM USER_COMMAND USING p_ucomm type sy-ucomm
                        ps_selfield TYPE slis_selfield.
  DATA: lv_value TYPE char10.
   CASE p_ucomm.
    WHEN '&SIL'.
data ls_sil type zmdik_pers_t.
     MOVE-CORRESPONDING gt_it[ ps_selfield-tabindex ]  to ls_sil.
      delete gt_it where pers_id = ls_sil-pers_id.
      delete from zmdik_pers_t where pers_id = @ls_sil-pers_id.
       ps_selfield-refresh = 'X'.


  ENDCASE.


ENDFORM.







START-OF-SELECTION.
PERFORM get_data.
PERFORM set_fc.
PERFORM set_layout.
PERFORM display_alv.
