*&---------------------------------------------------------------------*
*& Report ZMDIK_P023
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P023.


TYPES: BEGIN OF gty_list,
  ebeln TYPE EBELN,
  ebelp TYPE ebelp,
  bstyp TYPE ebstyp,
  bsart TYPE esart,
  matnr TYPE matnr,
  menge TYPE bstmg,
  END OF gty_list.

  data: gt_list TYPE TABLE of gty_list,
        gs_list type gty_list.
*  FIELD-SYMBOLS: <fs_002> like  slis_fieldcat_alv.

  data: gt_fieldcatalog TYPE  SLIS_T_FIELDCAT_ALV.
*        gs_fieldcatalog TYPE slis_fieldcat_alv.
  FIELD-SYMBOLS:<fs_002>  TYPE slis_fieldcat_alv.


START-OF-SELECTION.
SELECT ekko~ebeln, ekpo~ebelp, ekko~bstyp, ekko~bsart, ekpo~matnr, ekpo~menge
   FROM ekko
  INNER JOIN ekpo on
  ekko~ebeln eq ekpo~ebeln
  INTO TABLE @gt_list.



APPEND INITIAL LINE TO gt_fieldcatalog ASSIGNING <fs_002>.
<fs_002>-fieldname = 'ebeln'.      "işlem yaptığımız kolon
<fs_002>-seltext_s = 'SAS NO'.       "kısa ismi
<fs_002>-seltext_m = 'SAS Numarası'.   "orta ismi
<fs_002>-seltext_l = 'SAS Numarası'.     "uzun ismi
<fs_002>-key = abap_true.                  "anahtar key ise
<fs_002>-col_pos = 0.                         "0. kolondaki değer (sıralamamıza yarar)
<fs_002>-outputlen = 20.                        " kolonun alan uzunluğu
UNASSIGN <fs_002>.


APPEND INITIAL LINE TO gt_fieldcatalog ASSIGNING <fs_002>.
<fs_002>-fieldname = 'ebelp'.
<fs_002>-seltext_s = 'Kalem'.
<fs_002>-seltext_m = 'Kalem'.
<fs_002>-seltext_l = 'Kalem'.
<fs_002>-key = abap_true.
<fs_002>-col_pos = 1.



APPEND INITIAL LINE TO gt_fieldcatalog ASSIGNING <fs_002>.
<fs_002>-fieldname = 'bstyp'.
<fs_002>-seltext_s = 'Belge Tipi'.
<fs_002>-seltext_m = 'Belge Tipi'.
<fs_002>-seltext_l = 'Belge Tipi'.
<fs_002>-col_pos = 5.


APPEND INITIAL LINE TO gt_fieldcatalog ASSIGNING <fs_002>.
<fs_002>-fieldname = 'bsart'.
<fs_002>-seltext_s = 'Belge Türü'.
<fs_002>-seltext_m = 'Belge Türü'.
<fs_002>-seltext_l = 'Belge Türü'.
<fs_002>-col_pos = 4.


APPEND INITIAL LINE TO gt_fieldcatalog ASSIGNING <fs_002>.
<fs_002>-fieldname = 'matnr'.
<fs_002>-seltext_s = 'Malzeme'.
<fs_002>-seltext_m = 'Malzeme'.
<fs_002>-seltext_l = 'Malzeme'.
<fs_002>-col_pos = 2.



APPEND INITIAL LINE TO gt_fieldcatalog ASSIGNING <fs_002>.
<fs_002>-fieldname = 'menge'.
<fs_002>-seltext_s = 'Miktar'.
<fs_002>-seltext_m = 'Miktar'.
<fs_002>-seltext_l = 'Miktar'.
<fs_002>-col_pos = 3.






CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
   I_CALLBACK_PROGRAM                = sy-repid
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
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
    t_outtab                          = gt_list
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.
