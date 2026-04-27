*&---------------------------------------------------------------------*
*& Include          ZMDIK_P033_P003
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .


    SELECT * FROM bkpf INTO CORRESPONDING FIELDS OF TABLE gt_data
     where bukrs eq p_bukrs and
           gjahr eq p_gjahr and
            belnr in g_belnr.










* data: gt_data TYPE table of gsy_str,
*       gs_data TYPE bkpf.
*
*  data: gt_fieldcatalog TYPE  SLIS_T_FIELDCAT_ALV,
*        gs_fieldcatalog TYPE slis_fieldcat_alv.
*  DATA: gs_layout TYPE slis_layout_alv.
*
*   DATA: gt_events type SLIS_T_EVENT,
*        gs_event TYPE slis_alv_event.
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
gs_layout-window_titlebar = 'kalem tablosu '.
gs_layout-zebra = abap_true.
gs_layout-colwidth_optimize = abap_true.
gs_layout-info_fieldname = 'LINE_COLOR'.
gs_layout-box_fieldname = 'SELKZ'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat .
CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
 EXPORTING
   I_PROGRAM_NAME               = sy-repid
   I_INTERNAL_TABNAME           ='GT_DATA'
   I_STRUCTURE_NAME             = 'BKPF'
*   I_CLIENT_NEVER_DISPLAY       = 'X'
*   I_INCLNAME                   =
*   I_BYPASSING_BUFFER           =
*   I_BUFFER_ACTIVE              =
  CHANGING
    ct_fieldcat                  = gt_fieldcatalog.
* EXCEPTIONS
*   INCONSISTENT_INTERFACE       = 1
*   PROGRAM_ERROR                = 2
*   OTHERS                       = 3
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.






CLEAR gs_fieldcatalog.
gs_fieldcatalog-fieldname = 'BLDAT'.
gs_fieldcatalog-seltext_s = 'Belge tarihi'.
gs_fieldcatalog-hotspot = ''.
*gs_fieldcatalog- = 'C610'.
APPEND gs_fieldcatalog TO gt_fieldcatalog.


*LOOP AT gt_fieldcatalog INTO gs_fieldcatalog where fieldname = 'BLDAT' .
*  gs_fieldcatalog-emphasize = 'C610'.
*
*
*  MODIFY gt_fieldcatalog from gs_fieldcatalog.
*ENDLOOP.




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
     I_CALLBACK_PROGRAM                = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
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
      t_outtab                          = gt_data
   EXCEPTIONS
     PROGRAM_ERROR                     = 1
     OTHERS                            = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.


FORM USER_COMMAND USING p_ucomm TYPE sy-ucomm
                    ps_selfield TYPE slis_selfield.

  DATA: lt_selected TYPE TABLE OF gsy_str,
        ls_selected TYPE gsy_str.

  IF p_ucomm = '&IC1'.
   " READ TABLE gt_data INTO gs_data WITH KEY belnr = ps_selfield-value.
    READ TABLE gt_data INTO ls_selected WITH KEY belnr = ps_selfield-value.
    IF sy-subrc = 0.
       ls_selected-line_color = 'C410'. " Renk kodud

       " MODIFY gt_data FROM ls_selected INDEX ps_selfield-tabindex.
        MODIFY gt_data FROM ls_selected INDEX ps_selfield-tabindex.
*        APPEND ls_selected to gt_data.

        ps_selfield-refresh = 'X'.

        PERFORM show_popup USING ls_selected ps_selfield-value.
    ENDIF.
ENDIF.



  ENDFORM.



   FORM show_popup USING p_data TYPE gsy_str p_selfvalue.

*     data: ps_selfield TYPE slis_selfield.

 SELECT * FROM bkpf
    WHERE belnr = @p_selfvalue
    INTO TABLE  @gt_data2 .




  cl_salv_table=>factory(
*  EXPORTING
*    list_display   = if_salv_c_bool_sap=>false " ALV Displayed in List Mode
*    r_container    =                           " Abstract Container for GUI Controls
*    container_name =
   IMPORTING
      r_salv_table   =  go_alv                         " Basis Class Simple ALV Tables
    CHANGING
      t_table        = gt_data2
  ).
*CATCH cx_salv_msg. " ALV: General Error Class with Message
  go_alv->set_screen_popup(
    EXPORTING
      start_column = 1
      end_column   = 100
      start_line   = 1
      end_line     = 20
  ).
  go_alv->display( ).


ENDFORM.
