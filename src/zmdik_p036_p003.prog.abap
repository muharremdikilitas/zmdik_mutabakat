*&---------------------------------------------------------------------*
*& Include          ZMDIK_P036_P003
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
  DATA: lv_total TYPE bseg-wrbtr.

*  SELECT bkpf~bukrs, bkpf~belnr, bkpf~gjahr, bkpf~blart, bkpf~bldat, bkpf~waers, t003t~ltext,
*    SUM( bseg~wrbtr ) INTO lv_total FROM bkpf LEFT JOIN bseg ON bkpf~belnr EQ bseg~belnr LEFT JOIN t003t ON bkpf~blart EQ t003t~blart
* where bukrs eq p_bukrs and
*          gjahr eq p_gjahr and
*          belnr in g_belnr
*
*    GROUP BY bkpf~bukrs, bkpf~belnr, bkpf~gjahr, bkpf~blart, t003t~ltext,  bkpf~bldat, bkpf~waers.
*
*into corresponding fields of table gt_data.

  SELECT bkpf~bukrs,
         bkpf~belnr,
         bkpf~gjahr,
         bkpf~blart,
       t003t~ltext,
      bkpf~bldat,
    bkpf~waers,
         SUM( bseg~wrbtr ) AS tutar
    INTO  TABLE @gt_data
    FROM bkpf
    inner JOIN bseg
      ON bkpf~belnr = bseg~belnr
     AND bkpf~bukrs = bseg~bukrs
     AND bkpf~gjahr = bseg~gjahr
    LEFT JOIN t003t
      ON bkpf~blart = t003t~blart
     AND t003t~spras = @sy-langu  " Dil filtresi ekleyerek doğru açıklamayı almak
   WHERE bkpf~bukrs = @p_bukrs
     AND bkpf~gjahr = @p_gjahr
     AND bkpf~belnr IN @g_belnr
   GROUP BY bkpf~bukrs,
            bkpf~belnr,
            bkpf~gjahr,
            bkpf~blart,
            bkpf~bldat,
            bkpf~waers,
            t003t~ltext.












*
* BEGIN OF gsy_str,
*  BUKRS type bkpf-bukrs,
*  BELNR TYPE bkpf-belnr,
*  GJAHR TYPE bkpf-GJAHR,
*  BLART TYPE bkpf-BLART,
*  BLDAT TYPE bkpf-bldat,
*  WAERS TYPE bkpf-waers,
*  WRBTR TYPE bseg-wrbtr,
*  LTEXT TYPE t003t-ltext,
*  end of gsy_str.
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
*   I_STRUCTURE_NAME             = 'BSEG'
*   I_CLIENT_NEVER_DISPLAY       = 'X'
   I_INCLNAME                   = sy-repid
*   I_BYPASSING_BUFFER           =
*   I_BUFFER_ACTIVE              =
  CHANGING
    ct_fieldcat                  = gt_fieldcatalog.
* EXCEPTIONS
*   INCONSISTENT_INTERFACE       = 1
*   PROGRAM_ERROR                = 2
*   OTHERS                       = 3



LOOP AT gt_fieldcatalog into gs_fieldcatalog .
  IF gs_fieldcatalog-fieldname = 'BELNR'..
          gs_fieldcatalog-hotspot = abap_true.

            modify gt_fieldcatalog from gs_fieldcatalog.
  ENDIF.



ENDLOOP.




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

form PF_STATUS_SET USING p_extab TYPE slis_t_extab.
  SET PF-STATUS '0300'.

  ENDFORM.


   FORM USER_COMMAND USING p_ucomm TYPE sy-ucomm
                    ps_selfield TYPE slis_selfield.    "kolon ve row bilgisini dönen yapı



     CASE p_ucomm .
     	when '&IC1'.
          READ TABLE gt_data INTO gt_selrow WITH KEY belnr = ps_selfield-value.
          IF sy-subrc eq 0.

                  lv_Belnr = gt_selrow-belnr.
                  lv_gjahr = gt_selrow-gjahr.

          ENDIF.

*      ps_selfield-refresh = 'X'.
*        gv_value = ps_selfield-value.
*        gs_selrow = ls_selected.
        PERFORM show_popup.
     ENDCASE.

     ENDFORM.


   FORM show_popup.

     select * FROM bseg WHERE belnr = @lv_belnr and gjahr = @lv_gjahr and bukrs = @p_bukrs into CORRESPONDING FIELDS OF TABLE @gt_bseg.

*     data: ps_selfield TYPE slis_selfield.

* SELECT * FROM bkpf
*    WHERE belnr = @gs_selrow-belnr
*    INTO TABLE  @gt_bseg .




  cl_salv_table=>factory(
*  EXPORTING
*    list_display   = if_salv_c_bool_sap=>false " ALV Displayed in List Mode
*    r_container    =                           " Abstract Container for GUI Controls
*    container_name =
   IMPORTING
      r_salv_table   =  go_alv                         " Basis Class Simple ALV Tables
    CHANGING
      t_table        = gt_bseg[]
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
