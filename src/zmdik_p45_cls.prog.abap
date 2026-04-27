*&---------------------------------------------------------------------*
*& Include          ZMDIK_P45_CLS
*&---------------------------------------------------------------------*
class cl_event_receiver DEFINITION.
PUBLIC SECTION.


methods handle_onf4
      for EVENT onf4 of cl_gui_alv_grid
      IMPORTING
        e_fieldname
        e_fieldvalue
        es_row_no
        er_event_data
        et_bad_cells
        e_display.


ENDCLASS.


class cl_event_receiver IMPLEMENTATION.

    method handle_onf4.
      types: BEGIN OF lty_value_tab,
        carrname type s_carrname,
        end of lty_value_tab.

        data: lt_value_tab type TABLE of lty_value_tab,
              ls_value_tab type lty_value_tab.


      data: lt_return_tab type table of DDSHRETVAL,
            ls_return_tab type DDSHRETVAL.

        CLEAR: ls_value_tab.
        ls_value_tab-carrname = 'uçuş 1'.
        APPEND ls_value_tab to lt_value_tab.


           CLEAR: ls_value_tab.
        ls_value_tab-carrname = 'uçuş 2'.
        APPEND ls_value_tab to lt_value_tab.


           CLEAR: ls_value_tab.
        ls_value_tab-carrname = 'uçuş 3'.
        APPEND ls_value_tab to lt_value_tab.


           CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'                         "searchhelp ayarları
             EXPORTING

               retfield               = 'CARRNAME'
              WINDOW_TITLE           = 'Carrname f4'
              VALUE_ORG              = 'S'
             tables
               value_tab              = lt_value_tab
               return_tab             = lt_return_tab.

           READ TABLE lt_return_tab into ls_return_tab with key fieldname = 'F0001'.
           IF sy-subrc eq 0.
             READ TABLE gt_scarr ASSIGNING <gfs_scarr> INDEX es_row_no-row_id.
              IF sy-subrc eq 0.
                <gfs_scarr>-carrname = ls_return_tab-fieldval.

                go_grid->refresh_table_display( ).
                ENDIF.
           ENDIF.
           er_event_data->m_event_handled = 'X'.


            ENDMETHOD.
  ENDCLASS.
