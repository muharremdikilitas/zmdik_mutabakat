*&---------------------------------------------------------------------*
*& Include          ZMDIK_P65_CLSS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZMDIK_P43_CLS
*&---------------------------------------------------------------------*
class cl_event_receiver DEFINITION.
PUBLIC SECTION.


METHODS handle_top_of_page
      for EVENT top_of_page of cl_gui_alv_grid
      IMPORTING
        e_dyndoc_id
        table_index.


 METHODS handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.


   METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column.




  ENDCLASS.






class cl_event_receiver IMPLEMENTATION.

  method handle_top_of_page.
    data: lv_text type sdydo_text_element.

    lv_text = 'flight details'.

    call METHOD go_docu->add_text
      EXPORTING
        text          = lv_text
        sap_style     = cl_dd_document=>heading.



    CALL METHOD go_docu->new_line.

    CLEAR: lv_text.

    CONCATENATE 'User ' sy-uname into lv_text SEPARATED BY space.
    call  METHOD go_docu->add_text
      EXPORTING
        text          = lv_text
        sap_color     = cl_dd_document=>list_positive
        sap_fontsize  = cl_dd_document=>medium.


    call METHOD go_docu->display_document
      EXPORTING

        parent             = go_gui1.



    ENDMETHOD.

 METHOD handle_user_command.

    DATA: lt_rows   TYPE lvc_t_row,
          lv_index  TYPE lvc_index,
          ls_scarr  TYPE scarr,
          ls_temp   TYPE scarr.

    CALL METHOD go_alv->get_selected_rows
      IMPORTING
        et_index_rows = lt_rows.

    READ TABLE lt_rows INTO DATA(ls_row) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_index = ls_row-index.

    READ TABLE gt_scarr INTO ls_scarr INDEX lv_index.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CLEAR gt_scarr2.
    LOOP AT gt_scarr INTO ls_temp.
      IF ls_temp-carrid = ls_scarr-carrid.
        APPEND ls_temp TO gt_scarr2.
      ENDIF.
    ENDLOOP.

    CALL METHOD go_alv2->refresh_table_display( ).

  ENDMETHOD.

 METHOD handle_double_click.

    DATA: ls_scarr  TYPE scarr,
          ls_temp   TYPE scarr.

    READ TABLE gt_scarr INTO ls_scarr INDEX e_row.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CLEAR gt_scarr2.

    LOOP AT gt_scarr INTO ls_temp.
      IF ls_temp-carrid = ls_scarr-carrid.
        APPEND ls_temp TO gt_scarr2.
      ENDIF.
    ENDLOOP.

    CALL METHOD go_alv2->refresh_table_display( ).

  ENDMETHOD.





  ENDCLASS.
