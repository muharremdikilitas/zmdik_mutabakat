*&---------------------------------------------------------------------*
*& Include          ZMDIK_P031_P002
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_fc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fc .

*  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*   EXPORTING
*     I_PROGRAM_NAME               =
*     I_INTERNAL_TABNAME           =
*     I_STRUCTURE_NAME             =
*     I_INCLNAME                   =
*      ct_fieldcat                  = gt_fieldcatalog
*
*  IF sy-subrc <> 0.
* Implement suitable error handling here
*  ENDIF.





  clear gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'PERS_ID'.
  gs_fieldcatalog-seltext_s = 'pers id'.
  gs_fieldcatalog-seltext_m = 'personel id'.
  gs_fieldcatalog-seltext_l = 'personel id'.
  gs_fieldcatalog-key = abap_true.
  gs_fieldcatalog-col_pos = '0'.
  APPEND gs_fieldcatalog to gt_fieldcatalog.





    clear gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'PERS_AD'.
  gs_fieldcatalog-seltext_s = 'pers ad'.
  gs_fieldcatalog-seltext_m = 'personel ad'.
  gs_fieldcatalog-seltext_l = 'personel ad'.
  gs_fieldcatalog-col_pos = '1'.
  APPEND gs_fieldcatalog to gt_fieldcatalog.




    clear gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'PERS_SOYAD'.
  gs_fieldcatalog-seltext_s = 'pers soyad'.
  gs_fieldcatalog-seltext_m = 'personel soyad'.
  gs_fieldcatalog-seltext_l = 'personel soyad'.
*  gs_fieldcatalog-key = abap_true.
  gs_fieldcatalog-col_pos = '2'.
  APPEND gs_fieldcatalog to gt_fieldcatalog.




    clear gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'PERS_CINS'.
  gs_fieldcatalog-seltext_s = 'pers cins'.
  gs_fieldcatalog-seltext_m = 'personel cins'.
  gs_fieldcatalog-seltext_l = 'personel cins'.
*  gs_fieldcatalog-key = abap_true.
  gs_fieldcatalog-col_pos = '3'.
  APPEND gs_fieldcatalog to gt_fieldcatalog.




    clear gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'PER_AD'.
  gs_fieldcatalog-seltext_s = 'dep_pers ad'.
  gs_fieldcatalog-seltext_m = ' departman personel ad'.
  gs_fieldcatalog-seltext_l = 'departman personel ad'.
*  gs_fieldcatalog-key = abap_true.
  gs_fieldcatalog-col_pos = '4'.
  APPEND gs_fieldcatalog to gt_fieldcatalog.



    clear gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'P_MAAS'.
  gs_fieldcatalog-seltext_s = 'pers maas'.
  gs_fieldcatalog-seltext_m = 'personel maaş'.
  gs_fieldcatalog-seltext_l = 'personel maaş'.
*  gs_fieldcatalog-key = abap_true.
  gs_fieldcatalog-col_pos = '5'.
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
select  ZMDIK_PERS_T~PERS_ID  ZMDIK_PERS_T~PERS_AD ZMDIK_PERS_T~PERS_SOYAD ZMDIK_PERS_T~PERS_CINS
  ZMDIK_DEP_T~PER_AD ZMDIK_maas_T~P_MAAS
  FROM ZMDIK_PERS_T inner join ZMDIK_DEP_T on
   ZMDIK_PERS_T~pers_id eq ZMDIK_DEP_T~PER_ID INNER JOIN
   ZMDIK_maas_T ON  ZMDIK_maas_T~P_PID eq ZMDIK_DEP_T~DEP_ID
    INTO TABLE gt_it.



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
FORM display_alv .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
*     I_CALLBACK_PROGRAM                = ' '
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
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
