*&---------------------------------------------------------------------*
*& Include          ZMDIK_P039_P002
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
  select
   ekko~ebeln
   ekpo~ebelp
   ekko~bstyp
   ekko~bsart
   ekpo~matnr
   ekpo~menge
    ekpo~meins
   from ekko
   inner join ekpo
   on ekpo~ebeln eq ekko~ebeln
   into CORRESPONDING FIELDS OF table gt_list.


LOOP AT gt_list into gs_list.
  IF gs_list-ebelp eq '10'.
    clear gs_cell_color.
    gs_cell_color-fieldname = 'MATNR'.
    gs_cell_color-color-col = 5.
    gs_cell_color-color-int = 1.
    gs_cell_color-color-inv = 0.
    APPEND gs_cell_color to gs_list-cell_color.

    clear gs_cell_color.
    gs_cell_color-fieldname = 'EBELP'.
    gs_cell_color-color-col = 7.
    gs_cell_color-color-int = 1.
    gs_cell_color-color-inv = 0.
    APPEND gs_cell_color to gs_list-cell_color.
    MODIFY gt_list from gs_list.
    ENDIF.




*IF gs_list-ebelp eq '10'.
*  gs_list-line_color = 'C500'.
*    MODIFY gt_list from gs_list.
*    ELSEIF gs_list-ebelp eq '20'.
*      gs_list-line_color = 'C710'.
*    MODIFY gt_list from gs_list.
*     ELSEIF gs_list-ebelp eq '20'.
*      gs_list-line_color = 'C600'.
*    MODIFY gt_list from gs_list.
*
*ENDIF.
*
ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_fc.

*  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*   EXPORTING
*     I_PROGRAM_NAME               = sy-repid
*     I_INTERNAL_TABNAME           = 'GT_LIST'
**     I_STRUCTURE_NAME             =
*     I_INCLNAME                   = sy-repid
*
*    CHANGING
*      ct_fieldcat                  = gt_fieldcatalog.
*



  PERFORM: set_fc_sub USING 'EBELN'  'SAS NO' 'SAS Numarası' 'SAS Numarası' abap_true '0' '' 'X',
           set_fc_sub USING 'EBELP'  'Kalem' 'Kalem' 'Kalem' ''  '1' '' '' ,
           set_fc_sub USING 'BSTYP'  'Belge tipi' 'Belge tipi' 'Belge tipi' '' '2' '' '',
           set_fc_sub USING 'BSART'  'Belge Türü' 'Belge Türü' 'Belge Türü' '' '3' '' '',
           set_fc_sub USING 'MATNR'  'Malzeme' 'Malzeme' 'Malzeme' '' '4' '' 'X',
           set_fc_sub USING 'MENGE'  'Miktar' 'Miktar' 'Miktar' '' '5' 'X' '',
           set_fc_sub USING 'MEINS'  'ölçü birimi' 'ölçü birimi' 'ölçü birimi' '' '6' '' ''.

  endform.




*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*


FORM set_layout.

gs_layout-window_titlebar = 'Reuse ALV'.
gs_layout-zebra = abap_true.
gs_layout-box_fieldname = 'SELKZ'.
*gs_layout-info_fieldname = 'LINE_COLOR'.
gs_layout-coltab_fieldname = 'CELL_COLOR'.

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
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
   I_CALLBACK_PROGRAM                = sy-repid
   I_CALLBACK_PF_STATUS_SET          = 'PF_STATUS_SET'
   I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
   IS_LAYOUT                         = gs_layout
   IT_FIELDCAT =                   gt_fieldcatalog
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fc_sub
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fc_sub USING p_fieldname
                      p_seltext_s
                      p_seltext_m
                      p_seltext_l
                      p_key
                      p_col_pos
                      p_do_sum
                      p_hotspot.
  gs_fieldcatalog-fieldname = p_fieldname.
gs_fieldcatalog-seltext_s = p_seltext_s.
gs_fieldcatalog-seltext_m = p_seltext_m.
gs_fieldcatalog-seltext_l = p_seltext_l.
gs_fieldcatalog-key = p_key.
gs_fieldcatalog-col_pos = p_col_pos.
gs_fieldcatalog-do_sum = p_do_sum.
gs_fieldcatalog-hotspot = p_hotspot.
APPEND gs_fieldcatalog to gt_fieldcatalog.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PF_STATUS_SET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PF_STATUS_SET USING p_extab TYPE slis_t_extab.
  set PF-STATUS 'STANDARD'.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command USING p_ucomm     TYPE sy-ucomm                 "herhangi bir işlem yapıldığında çalışır
                        ps_selfield type slis_selfield .            "nereye tıklandığını bilmek için kullanırız
data: lv_msg TYPE char200,
      lv_index type numc2.
CASE p_ucomm.
  WHEN '&MSS'.
    LOOP AT gt_list INTO gs_list where selkz eq 'X'.
      lv_index = lv_index + 1.
    ENDLOOP.
    CONCATENATE lv_index
                  'kadar satır seçilmiştir.'
                  INTO lv_msg SEPARATED BY space.
       MESSAGE lv_msg TYPE 'I'.

  WHEN '&IC1'.
   CASE ps_selfield-fieldname.
   	WHEN 'EBELN'.
      CONCATENATE ps_selfield-value
                  'numaralı SAS tıklanmıştır.'
                  INTO lv_msg SEPARATED BY space.
      MESSAGE lv_msg TYPE 'I'.
   	WHEN 'MATNR'.
      CONCATENATE ps_selfield-value
      'numaralı malzeme tıklanmıştır.'
                  INTO lv_msg SEPARATED BY space.
                   MESSAGE lv_msg TYPE 'I'.
   	WHEN OTHERS.
   ENDCASE.
  WHEN OTHERS.
ENDCASE.
ENDFORM.
