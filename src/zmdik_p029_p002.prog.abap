*&---------------------------------------------------------------------*
*& Include          ZMDIK_P029_P002
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
  SELECT ekko~ebeln, ekpo~ebelp, ekko~bstyp, ekko~bsart, ekpo~matnr, ekpo~menge
   UP TO 50 ROWS
     FROM ekko
  INNER JOIN ekpo on
  ekko~ebeln eq ekpo~ebeln
  INTO TABLE @gt_list.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fc .
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
  EXPORTING
     I_PROGRAM_NAME               = sy-repid
*  I_INTERNAL_TABNAME           = 'GT_LIST'
    I_STRUCTURE_NAME             = 'GT_LIST'
     I_INCLNAME                   = sy-repid

    CHANGING
      ct_fieldcat                  = gt_fieldcatalog.






  clear gs_fieldcatalog.
gs_fieldcatalog-fieldname = 'ebeln'.      "işlem yaptığımız kolon
gs_fieldcatalog-seltext_s = 'SAS NO'.       "kısa ismi
gs_fieldcatalog-seltext_m = 'SAS Numarası'.   "orta ismi
gs_fieldcatalog-seltext_l = 'SAS Numarası'.     "uzun ismi
gs_fieldcatalog-key = abap_true.                  "anahtar key ise
gs_fieldcatalog-col_pos = 0.                         "0. kolondaki değer (sıralamamıza yarar)
gs_fieldcatalog-outputlen = 20.                         " kolonun alan uzunluğu
gs_fieldcatalog-hotspot = ''.
append gs_fieldcatalog to gt_fieldcatalog.

clear gs_fieldcatalog.
gs_fieldcatalog-fieldname = 'ebelp'.
gs_fieldcatalog-seltext_s = 'Kalem'.
gs_fieldcatalog-seltext_m = 'Kalem'.
gs_fieldcatalog-seltext_l = 'Kalem'.
gs_fieldcatalog-key = abap_true.
gs_fieldcatalog-col_pos = 1.
gs_fieldcatalog-hotspot = ''.
append gs_fieldcatalog to gt_fieldcatalog.


clear gs_fieldcatalog.
gs_fieldcatalog-fieldname = 'bstyp'.
gs_fieldcatalog-seltext_s = 'Belge Tipi'.
gs_fieldcatalog-seltext_m = 'Belge Tipi'.
gs_fieldcatalog-seltext_l = 'Belge Tipi'.
gs_fieldcatalog-col_pos = 5.
gs_fieldcatalog-hotspot = ''.
append gs_fieldcatalog to gt_fieldcatalog.

clear gs_fieldcatalog.
gs_fieldcatalog-fieldname = 'bsart'.
gs_fieldcatalog-seltext_s = 'Belge Türü'.
gs_fieldcatalog-seltext_m = 'Belge Türü'.
gs_fieldcatalog-seltext_l = 'Belge Türü'.
gs_fieldcatalog-col_pos = 4.
append gs_fieldcatalog to gt_fieldcatalog.

clear gs_fieldcatalog.
gs_fieldcatalog-fieldname = 'matnr'.
gs_fieldcatalog-seltext_s = 'Malzeme'.
gs_fieldcatalog-seltext_m = 'Malzeme'.
gs_fieldcatalog-seltext_l = 'Malzeme'.
gs_fieldcatalog-col_pos = 2.
gs_fieldcatalog-hotspot = 'X'.
append gs_fieldcatalog to gt_fieldcatalog.


clear gs_fieldcatalog.
gs_fieldcatalog-fieldname = 'menge'.
gs_fieldcatalog-seltext_s = 'Miktar'.
gs_fieldcatalog-seltext_m = 'Miktar'.
gs_fieldcatalog-seltext_l = 'Miktar'.
gs_fieldcatalog-col_pos = 3.
gs_fieldcatalog-hotspot = ''.
append gs_fieldcatalog to gt_fieldcatalog.


ENDFORM.







FORM set_layout .
  gs_layout-window_titlebar = 'Ruese alv eğitim videosu '.
gs_layout-zebra = abap_true.
gs_layout-colwidth_optimize = abap_true.

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
  gs_event-name = slis_ev_top_of_page.
  gs_event-form = 'TOP_OF_PAGE'.
  APPEND gs_event to gt_events.
  gs_event-name = slis_ev_end_of_list.
  gs_event-form = 'END_OF_LİST'.
  APPEND gs_event to gt_events.
  gs_event-name = slis_ev_pf_status_set.
  gs_event-form = 'PF_STATUS_SET'.
  APPEND gs_event to gt_events.



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
   I_CALLBACK_PROGRAM                = sy-repid
*   I_CALLBACK_PF_STATUS_SET          = 'PF_STATUS_SET'
   I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
*   I_CALLBACK_TOP_OF_PAGE            = 'TOP_OF_PAGE'
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ''
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
  IS_LAYOUT                         = gs_layout
   IT_FIELDCAT                       = gt_fieldcatalog
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
   IT_EVENTS                         = gt_events
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fc_sub
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form top_of_page
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*



FORM top_of_page .

 data: lt_header TYPE slis_t_listheader,
       ls_header TYPE slis_listheader.
 ls_header-typ = 'H'.
 ls_header-info = 'Satınalma sipariş rapor'.
 APPEND ls_header to lt_header.

 clear ls_header.
 ls_header-typ = 'S'.
 ls_header-key = 'Tarih'.
 ls_header-info = sy-datum.
 APPEND ls_header to lt_header.

 CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
   EXPORTING
     it_list_commentary       = lt_header.






ENDFORM.


FORM  end_of_list .

ENDFORM.

form PF_STATUS_SET USING p_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD'.

  ENDFORM.

  FORM USER_COMMAND USING p_ucomm TYPE sy-ucomm
                    ps_selfield TYPE slis_selfield.    "kolon ve row bilgisini dönen yapı
data : lv_mes TYPE char200.
    CASE p_ucomm .
      WHEN '&MSG' .
        MESSAGE 'Mesaj butonuna basıldı' TYPE 'I'.
      WHEN '&IC1' .
        case ps_selfield-fieldname.
          when 'EBELN'.
         CONCATENATE   ps_selfield-value
            'numaralı sas tıklanmıştır.'
            into lv_mes SEPARATED BY space.
         MESSAGE lv_mes TYPE 'I'.

           WHEN 'MATNR'.
             CONCATENATE   ps_selfield-value
            'numaralı malzeme tıklanmıştır.'
            into lv_mes SEPARATED BY space.
         MESSAGE lv_mes TYPE 'I'.

        endcase.

    ENDCASE.

    ENDFORM.
