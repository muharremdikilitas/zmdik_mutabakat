*&---------------------------------------------------------------------*
*& Report ZMDIK_P030
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P030.

data: k_no TYPE char10,
      k_adi TYPE char20,
      k_sifre TYPE char20.

data: gs_log TYPE zmdik_log2,
      gt_log TYPE TABLE OF zmdik_log2.

 data: gt_fieldcatalog TYPE  SLIS_T_FIELDCAT_ALV,
        gs_fieldcatalog TYPE slis_fieldcat_alv.

select * FROM zmdik_log2 INTO TABLE gt_log.


clear gs_fieldcatalog.
gs_fieldcatalog-fieldname = 'K_ADI'.
gs_fieldcatalog-col_pos = '0'.
gs_fieldcatalog-seltext_l = 'ADI'.
APPEND gs_fieldcatalog to gt_fieldcatalog.


clear gs_fieldcatalog.
gs_fieldcatalog-fieldname = 'K_NO'.
gs_fieldcatalog-col_pos = '1'.
gs_fieldcatalog-seltext_l = ' NUMARASI'.
APPEND gs_fieldcatalog to gt_fieldcatalog.



clear gs_fieldcatalog.
gs_fieldcatalog-fieldname = 'K_SIFRE'.
gs_fieldcatalog-col_pos = '2'.
gs_fieldcatalog-seltext_l = 'ŞİFRE'.
APPEND gs_fieldcatalog to gt_fieldcatalog.





CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
*   I_CALLBACK_PROGRAM                = ' '
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  = 'ZMDIK_LOG2'
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
*   IS_LAYOUT                         =
   IT_FIELDCAT                       = gt_fieldcatalog
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
*   O_PREVIOUS_SRAL_HANDLER           =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    t_outtab                          = gt_log
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.
