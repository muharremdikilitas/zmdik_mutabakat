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





methods handle_hotspot_click
FOR EVENT hotspot_click of cl_gui_alv_grid
      IMPORTING
        e_row_id
       e_column_id.







methods handle_double_click
      for EVENT double_click of cl_gui_alv_grid
      IMPORTING
        e_row
        e_column
        es_row_no.





methods handle_data_changed
      for EVENT data_changed of cl_gui_alv_grid
      IMPORTING
        er_data_changed
        e_onf4
        e_onf4_before
        e_onf4_after
        e_ucomm.




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

        parent             = go_sub1.



    ENDMETHOD.






    METHOD handle_hotspot_click.
      data: lv_mess type char200.


      read table gt_scarr into gs_scarr INDEX e_row_id-index.             "tabloyu oku indexlerine göre ve  e_row_id nin indeksi olarak karşılaştırıp gs_scarr a at.
      IF sy-subrc eq 0.
        CASE e_column_id-fieldname.
          WHEN 'CARRID'.
        CONCATENATE 'tıklanan kolon'
        e_column_id-fieldname
        'değeri'
        gs_scarr-carrid
        INTO lv_mess
        SEPARATED BY space.
        MESSAGE lv_mess type 'I'.

        when 'CARRNAME'.
         CONCATENATE 'tıklanan kolon'
        e_column_id-fieldname
        'değeri'
        gs_scarr-carrname
        INTO lv_mess
        SEPARATED BY space.
        MESSAGE lv_mess type 'I'.
        ENDCASE.
      ENDIF.


      ENDMETHOD.











      METHOD handle_double_click.
        data: lv_mess type char200.

        read TABLE gt_scarr into gs_scarr INDEX e_row-index.

      IF sy-subrc eq 0.

         CONCATENATE 'tıklanan kolon'
         e_column-fieldname
         ' , satırın değeri'
         gs_scarr
         INTO lv_mess SEPARATED BY space.

         MESSAGE lv_mess type 'I'.

      ENDIF.
        ENDMETHOD.



        method handle_data_changed.
          "er_data_changed özelliğinin içinde bi internal table var ve o internal tablenin içinde yapılan değişikliği satır satır dönen bir yapı var. Bu yapıyla oynuyoruz

          DATA: ls_modi type lvc_s_modi,
                lv_mess type char200.



          LOOP AT er_data_changed->mt_good_cells INTO ls_modi .
            READ TABLE gt_scarr INTO gs_scarr INDEX ls_modi-row_id.
            IF sy-subrc eq 0 .
                CONCATENATE ls_modi-fieldname
            '=> eski değer '
            gs_scarr-carrname
            ', yeni değer'
            ls_modi-value
            into lv_mess
            SEPARATED BY space.

                MESSAGE lv_mess type 'I'.
            ENDIF.


          ENDLOOP.

          ENDMETHOD.








          method handle_onf4.
            BREAK-POINT.

            ENDMETHOD.
  ENDCLASS.
