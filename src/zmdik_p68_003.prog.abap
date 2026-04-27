*&---------------------------------------------------------------------*
*& Include          ZMDIK_P68_003
*&---------------------------------------------------------------------*


CLASS lcl_report DEFINITION.

  PUBLIC SECTION.

    TYPES : BEGIN OF ts_list ,
              icon          TYPE  icon_d,
              msg_ind       TYPE  zmdik_t_003-msg_ind,
              cm_numb       TYPE  kna1-kunnr,
              year          TYPE  zmdik_t_003-d_year,
              month         TYPE  zmdik_t_003-d_month,
              cm_taxno      TYPE  kna1-stcd1,
              name          TYPE  kna1-name1,
              tax_ofc       TYPE  kna1-txjcd,
              cm_cntry      TYPE  kna1-land1,
              int_text(30)  TYPE  c,
              Odktext(30)   TYPE  c,
              def(30)       TYPE  c,
              recon_des(30) TYPE  c,
              odkindex      TYPE  bapi3007_3-sp_gl_ind,
              tot_bal       TYPE  bapi3007_3-t_curr_bal,
              currency      TYPE  bapi3007_3-currency,
              loc_bal       TYPE  bapi3007_3-lc_bal,
              loc_cur       TYPE  bapi3007_3-loc_currcy,
              Detail        TYPE  icon_d,

            END OF ts_list .

    TYPES: BEGIN OF poptable,
             doc_date   TYPE bapi3007_2-doc_date,
             doc_type   TYPE bapi3007_2-doc_type,
             item_text  TYPE bapi3007_2-item_text,
             ref_doc_no TYPE bapi3007_2-ref_doc_no,
             db_cr_ind  TYPE bapi3007_2-db_cr_ind,
             lc_amount  TYPE bapi3007_2-lc_amount,
             currency   TYPE bapi3007_2-currency,

           END OF poptable.

    DATA: mt_list       TYPE TABLE OF ts_list,
          ms_list       TYPE ts_list,
          gt_kna1       TYPE TABLE OF kna1,
          gs_kna1       TYPE kna1,
          gt_keybalance TYPE TABLE OF bapi3007_3,
          gs_keybalance TYPE bapi3007_3,
          gt_popuptable TYPE TABLE OF poptable,
          gs_popuptable TYPE poptable,
          gt_take_indx  TYPE TABLE OF poptable,
          gt_email      TYPE TABLE OF zmdik_t_003_mail,
          gs_email      TYPE zmdik_t_003_mail,
          gv_last_id    TYPE zmdik_t_003-msg_ind.

    DATA: lt_bapi TYPE TABLE OF bapi3007_2,
          ls_bapi TYPE bapi3007_2.
*    DATA ls_take_indx TYPE poptable.

    METHODS :
      select,
      mainloop,
      prepare_alv,
      create_alv,
      set_alv_properties,
      display_alv,
      set_pf_status,
      bapi,
      show_popup,
      icon,
      set_top_of_page,
      counter RETURNING VALUE(iv_count) TYPE i.

  PROTECTED SECTION.

    DATA: mo_alv       TYPE REF TO cl_salv_table,
          mo_exp_msg   TYPE REF TO cx_salv_msg,
          mo_display   TYPE REF TO cl_salv_display_settings,
          mo_columns   TYPE REF TO cl_salv_columns_table,
          mo_column    TYPE REF TO cl_salv_column_table,
          mo_events    TYPE REF TO cl_salv_events_table,
          mo_layout    TYPE REF TO cl_salv_layout,
          mo_selection TYPE REF TO cl_salv_selections.

    METHODS :
      save_getkey,
      set_column_text
        IMPORTING iv_fname TYPE lvc_fname
                  iv_text  TYPE any,

      on_user_command       FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_link_click         FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row
                  column .

ENDCLASS.


class lcl_report IMPLEMENTATION.
  METHOD select.
    IF tarihbil is INITIAL .
      tarihbil = sy-datum.
    ENDIF.

    SELECT
      kna1~kunnr
      kna1~stcd1
      kna1~txjcd
      kna1~land1
      kna1~name1
      FROM kna1
      into CORRESPONDING FIELDS OF table gt_kna1
      WHERE  kna1~kunnr in cm_no.

      endmethod.


      METHOD mainloop.

     LOOP AT gt_kna1 into gs_kna1.
       ms_list-cm_numb = gs_kna1-kunnr.
       ms_list-cm_taxno = gs_kna1-stcd1.
       ms_list-tax_ofc = gs_kna1-txjcd.
       ms_list-cm_cntry = gs_kna1-land1.
       ms_list-name =   gs_kna1-name1.
       ms_list-year =   tarihbil+0(4).
       ms_list-month =  tarihbil+4(2).
       ms_list-detail = '@16@'.

       SELECT SINGLE msg_ind FROM zmdik_t_003
         into gv_last_id
         WHERE
         cm_numb = ms_list-cm_numb.



         clear: ms_list-msg_ind.
         IF gv_last_id is NOT INITIAL.
           ms_list-msg_ind = gv_last_id.
           CLEAR gv_last_id.
         ENDIF.


           me->icon( ).

           CALL FUNCTION 'BAPI_AR_ACC_GETKEYDATEBALANCE'
             EXPORTING
               companycode        = sirket
               customer           = gs_kna1-kunnr
               keydate            = tarihbil
              BALANCESPGLI       = 'X'
             TABLES
               keybalance         = gt_keybalance
                     .


           me->save_getkey( ).
           me->bapi( ).

     ENDLOOP.
      ENDMETHOD.

      method save_getkey.







        LOOP AT gt_keybalance into gs_keybalance.

          ms_list-odkindex = gs_keybalance-sp_gl_ind.
          ms_list-tot_bal = gs_keybalance-t_curr_bal.
          ms_list-currency = gs_keybalance-currency.
          ms_list-loc_bal = gs_keybalance-lc_bal.
          ms_list-loc_cur = gs_keybalance-loc_currcy.



          CASE gs_keybalance-sp_gl_ind.
            WHEN 'A'.
            ms_list-int_text = 'Müşteri ÖDK Bakiye'.
            ms_list-odktext = 'Peşinat'.
            when ''.
              ms_list-int_text = 'Müşteri Bakiyesi'.
              ms_list-odktext = ' '.
          ENDCASE.


          CASE gs_keybalance-db_cr_ind.
            WHEN 'H' .
              ms_list-def = 'Alacak'.
            WHEN 'S' .
              ms_list-def = 'Borç'.
          ENDCASE.


          APPEND ms_list to mt_list.

        ENDLOOP.
        ENDMETHOD.

method bapi.

  data: ls_bapi type bapi3007_2,
        lt_bapi type table of bapi3007_2.


  CALL FUNCTION 'BAPI_AR_ACC_GETOPENITEMS'
    EXPORTING
      companycode       = sirket
      customer          = kna1-kunnr
      keydate           = tarihbil

    TABLES
      lineitems         = lt_bapi
            .


  LOOP AT lt_bapi into ls_bapi.

    gs_popuptable-doc_date       =   ls_bapi-doc_date     .
    gs_popuptable-doc_type       =   ls_bapi-doc_type     .
    gs_popuptable-item_text      =   ls_bapi-item_text    .
    gs_popuptable-ref_doc_no     =   ls_bapi-ref_doc_no   .
    gs_popuptable-db_cr_ind      =   ls_bapi-db_cr_ind    .
    gs_popuptable-lc_amount      =   ls_bapi-lc_amount    .
    gs_popuptable-currency       =   ls_bapi-currency     .

  ENDLOOP.

  ENDMETHOD.



  method create_alv.
    TRY .

    cl_salv_table=>factory(

      IMPORTING
        r_salv_table   = mo_alv
      CHANGING
        t_table        = mt_list
    ).
    CATCH cx_salv_msg into mo_exp_msg.
      ENDTRY.


      ENDMETHOD.


  METHOD display_alv.


    mo_alv->display( ).

    ENDMETHOD.

 METHOD set_alv_properties.

   mo_selection = mo_alv->get_selections( ).
   mo_selection->set_selection_mode( if_salv_c_selection_mode=>cell  ).


  mo_display = mo_alv->get_display_settings( ).

       "set alv events
      mo_events = mo_alv->get_event( ).
      set handler go_report->on_user_command for mo_events.
      SET HANDLER go_report->on_link_click for mo_events.


      "zebra style
      mo_display->set_striped_pattern( cl_salv_display_settings=>true ).
      mo_columns = mo_alv->get_columns( ).


      "column optimize
      mo_columns = mo_alv->get_columns( ).
      mo_columns->set_optimize( abap_true ).



      "set optimize
      mo_columns->set_optimize( abap_true ).
          mo_layout = mo_alv->get_layout( ).

    me->set_column_text( iv_fname = 'YEAR' iv_text = TEXT-h01 ).
    me->set_column_text( iv_fname = 'MONTH' iv_text = TEXT-h02 ).
    me->set_column_text( iv_fname = 'INT_TEXT' iv_text = TEXT-h03 ).
    me->set_column_text( iv_fname = 'ODKTEXT' iv_text = TEXT-h04 ).
    me->set_column_text( iv_fname = 'DEF' iv_text = TEXT-h05 ).
    me->set_column_text( iv_fname = 'RECON_DES' iv_text = TEXT-018 ).

    TRY.
        mo_column ?= mo_columns->get_column( 'DETAIL' ).
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

      CATCH cx_salv_not_found .

    ENDTRY.
ENDMETHOD.


method prepare_alv.

  me->create_alv( ).
  me->set_pf_status( ).
  me->set_alv_properties( ).
  me->set_top_of_page( ).
  me->display_alv( ).

  ENDMETHOD.


 method on_link_click.

    data: ls_take_indx type poptable.

   CASE column .
   	WHEN 'DETAIL' .



   READ TABLE mt_list INTO ms_list INDEX row.
   me->bapi( ).
   ls_take_indx = gt_popuptable[ row ].
   APPEND  ls_take_indx to gt_take_indx.
   me->show_popup( ).

   ENDCASE.


     ENDMETHOD.



     METHOD set_pf_status.

       mo_alv->set_screen_status(
         EXPORTING
           report        = sy-repid
           pfstatus      = '0100'
           set_functions = mo_alv->c_functions_all
       ).

       ENDMETHOD.



         METHOD on_user_command.
    CASE e_salv_function.
      WHEN '&MBUT'.


        MESSAGE 'mutabakat Gönderildi'  TYPE 'I'.
    ENDCASE.

  ENDMETHOD.

    METHOD set_column_text.

    DATA : lv_textl TYPE scrtext_l,
           lv_textm TYPE scrtext_m,
           lv_texts TYPE scrtext_s.

    lv_texts = lv_textm = lv_textl = iv_text.

    TRY.
        mo_column ?= mo_columns->get_column( iv_fname ).
        mo_column->set_long_text( lv_textl ).
        mo_column->set_medium_text( lv_textm ).
        mo_column->set_short_text( lv_texts ).
      CATCH cx_salv_not_found .
    ENDTRY.

  ENDMETHOD.




    METHOD  show_popup .
    TRY .
        cl_salv_table=>factory(
            IMPORTING
              r_salv_table = mo_alv
            CHANGING
              t_table      = gt_take_indx
          ).

        mo_alv->set_screen_popup(
              EXPORTING
                start_column = 1
                end_column   = 0
                start_line   = 1
                end_line     = 0
            ).

        mo_alv->display( ).
        CLEAR gt_take_indx.
      CATCH cx_salv_msg INTO DATA(lx_salv_msg).
        WRITE: 'Beklenmedik hata'.
    ENDTRY.

  ENDMETHOD.

 METHOD set_top_of_page.

    DATA : lo_grid_top    TYPE REF TO cl_salv_form_layout_grid,
           lo_text        TYPE REF TO cl_salv_form_text,
           lo_label       TYPE REF TO cl_salv_form_label,
           lo_logo        TYPE REF TO cl_salv_form_layout_logo,
           lv_count       TYPE i,
           lv_date        TYPE string,
           lv_user        TYPE string,
           lo_grid_bottom TYPE REF TO cl_salv_form_layout_grid.

    CREATE OBJECT lo_grid_top.

    lo_grid_top->create_header_information(
                  row     = 1
                  column  = 1
                  text    = 'Mutabakat ALV raporu'
                  tooltip = TEXT-t01 ).

    lo_grid_top->add_row( ).
    lv_count = me->counter( ).

    lo_grid_bottom = lo_grid_top->create_grid(
                   row    = 5
                   column = 1
                                 ).
    DATA(lo_text1) = lo_grid_bottom->create_text(
                    row     = 5
                    column  = 1
                    text    = lv_count
                    tooltip = lv_count ).

    lo_label = lo_grid_bottom->create_label(
                   row     = 1
                   column  = 1
                   text    = 'Bilgiler' ).

    lv_date = |{ sy-datum DATE = ISO }|.  " ISO formatında tarih alınıyor

    lo_text = lo_grid_bottom->create_text(
                   row     = 3      " İkinci satır
                   column  = 1      " Aynı sütun
                   text    = lv_date
                   tooltip = lv_date ).

    lo_label->set_label_for( lo_text ).

    CREATE OBJECT lo_logo.
    lo_logo->set_right_logo( 'ENJOYSAP_LOGO' ).  " Logo ekleme
    lo_logo->set_left_content( lo_grid_top ).

    mo_alv->set_top_of_list( lo_logo ).

    lv_user = sy-uname.
    lo_label = lo_grid_top->create_label(
                   row     = 4      " İkinci satır
                   column  = 1
                   text    = lv_user
                   tooltip = lv_user ).

    lo_label->set_label_for( lo_text ).

  ENDMETHOD.






 METHOD counter.

    DESCRIBE TABLE mt_list LINES iv_count.

  ENDMETHOD.

 METHOD icon.
    DATA:           lv_status(1)   TYPE c.

    CLEAR lv_status.
    SELECT SINGLE status FROM zed_t_003 INTO lv_status WHERE cm_numb = ms_list-cm_numb.

    CLEAR: ms_list-recon_des, ms_list-icon.

    IF lv_status IS NOT INITIAL.
      CASE lv_status.
        WHEN 'A'.
          ms_list-icon = icon_time_control.
          ms_list-recon_des = 'mutabakat gönderildi'.
        WHEN 'B'.
          ms_list-icon = icon_led_green.
          ms_list-recon_des = 'Mutabakat açıklama'.
        WHEN 'C'.
          ms_list-icon = icon_led_red.
          ms_list-recon_des = 'Mutabıkım'.
        WHEN OTHERS.
          ms_list-icon = icon_dummy.
      ENDCASE.
    ENDIF.

  ENDMETHOD.







      ENDCLASS.
