*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTABAKAT3_P003
*&---------------------------------------------------------------------*
class lcl_report definition.

  public section.

TYPES : BEGIN OF gty_table,
              report_id   TYPE i,
              report_icon       TYPE icon-id,
              year(4)          TYPE c,
              month(2)         TYPE c,
              kunnr            TYPE kna1-kunnr,
              stcd1            TYPE kna1-stcd1,
              name1            TYPE kna1-name1,
              report_status    TYPE char30,
              email            TYPE zmdik_mail_tablo-email,
              land1            TYPE kna1-land1,
              stceg            TYPE kna1-stceg,
              musteri_bakiye   TYPE bapi3007_3-lc_bal,
              musteri_bakiyepb2 TYPE bapi3007_3-currency,
              upb_bakiye        TYPE bapi3007_3-t_curr_bal,
              upb_para_birimi   TYPE  bapi3007_3-loc_currcy,
              odk_gost          TYPE  bapi3007_3-sp_gl_ind,
                ktext           TYPE  char30,
                intro_text      TYPE char20,
              detail_icon      TYPE icon-id,
              BORC_ALACAK       TYPE SHKZG,
              BORC_ALACAK_TEXT  TYPE char6,
            END OF gty_table.


            types: begin of gty_lineitems ,
        doc_date   type bapi3007_2-doc_date,
        doc_type   type bapi3007_2-doc_type,
        item_text  type bapi3007_2-item_text,
        ref_doc_no type bapi3007_2-ref_doc_no,
        db_cr_ind  type bapi3007_2-db_cr_ind,
        currency   type bapi3007_2-currency,
        lc_amount  TYPE bapi3007_2-lc_amount,
        item_num   TYPE bapi3007_2-item_num,
          end of gty_lineitems.



           TYPES: BEGIN OF gty_table_email,
             kunnr TYPE kna1-kunnr,
             email TYPE string,
           END OF gty_table_email.


      data:    gs_table TYPE gty_table,
               gt_table TYPE TABLE of gty_table,
               gs_lineitems TYPE gty_lineitems,
               gt_lineitems type TABLE of gty_lineitems,
               gt_table_kna1       TYPE TABLE OF kna1,
               gs_table_kna1       TYPE kna1,
               gs_bapi3 TYPE bapi3007_3,
               gt_bapi3 TYPE TABLE of bapi3007_3,
               gs_bapi2 TYPE bapi3007_2,
               gt_bapi2 TYPE TABLE of bapi3007_2,
               gt_table_single_cus TYPE TABLE OF gty_lineitems,
               gs_table_single_cus TYPE gty_lineitems,
               gt_table_popup      TYPE TABLE OF gty_lineitems,
               gt_reciver_email    TYPE TABLE OF gty_table_email,
               gs_reciver_email    TYPE gty_table_email,
               gt_table_tline      TYPE TABLE OF tline,
               gs_table_tline      TYPE tline,
               gs_table_z           type ZMDIK_MUTAKABAT2,
               gt_table_z           TYPE TABLE of ZMDIK_MUTAKABAT2.


      METHODS :
      initialization,
      set_first_status,
      at_selection_screen,
      check_fields,
      start_report,
      prepare_alv,
      receiver_email,
      send_email,
      set_column_text
        IMPORTING iv_fname TYPE lvc_fname
                  iv_text  TYPE any.



      PROTECTED SECTION.

    DATA: mo_alv       TYPE REF TO cl_salv_table,
          mo_exp_msg   TYPE REF TO cx_salv_msg,
          mo_display   TYPE REF TO cl_salv_display_settings,
          mo_columns   TYPE REF TO cl_salv_columns_table,
          mo_column    TYPE REF TO cl_salv_column_table,
          mo_selection TYPE REF TO cl_salv_selections,
          mo_events    TYPE REF TO cl_salv_events_table.




PRIVATE SECTION.

    METHODS :
      create_alv,
      set_pf_status,
      set_alv_properties,
      set_top_of_page,
      display_alv,
      select_kna1,
      fill_table,
      loop_bapi_fun,
      push_email,
*      fill_table_z,
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row
                  column,
      on_function FOR EVENT if_salv_events_functions~added_function OF cl_salv_events_table
        IMPORTING e_salv_function ,
      fill_pop_table,
      show_popup.


ENDCLASS.

CLASS lcl_report IMPLEMENTATION.
   METHOD initialization.
  ENDMETHOD.

  METHOD set_first_status.

  ENDMETHOD.

  METHOD at_selection_screen.
  ENDMETHOD.

  METHOD check_fields.
  ENDMETHOD.

  METHOD start_report.
    me->select_kna1( ).
    me->fill_table( ).
  ENDMETHOD.





  METHOD select_kna1.

    SELECT
      kna1~kunnr,
      kna1~stcd1,
      kna1~name1,
      kna1~stceg,
      kna1~land1 FROM kna1
      INTO CORRESPONDING FIELDS OF TABLE @gt_table_kna1
      WHERE kna1~kunnr IN @s_kunnr.


  ENDMETHOD.

       METHOD fill_table.

    LOOP AT gt_table_kna1 INTO gs_table_kna1.
      DATA lv_number TYPE i.

       CALL FUNCTION 'BAPI_AR_ACC_GETKEYDATEBALANCE'
        EXPORTING
          companycode  = p_bukrs
          customer     = gs_table_kna1-kunnr
          keydate      = p_datum
          balancespgli = 'X'
          noteditems   = ''
        TABLES
          keybalance   = gt_bapi3.

       CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '01'
          object                  = 'ZMDIK_001'
        IMPORTING
          number                  = lv_number
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.


       gs_table-report_id = lv_number.
       gs_table-year = p_datum+0(4).
       gs_table-month = p_datum+4(2).
       gs_table-kunnr = gs_table_kna1-kunnr.
       gs_table-stcd1 = gs_table_kna1-stcd1.
       gs_table-name1 = gs_table_kna1-name1.
       gs_table-stceg = gs_table_kna1-stceg.
       gs_table-land1 = gs_table_kna1-land1.
       gs_table-detail_icon = icon_select_detail.

       me->loop_bapi_fun( ).

       APPEND gs_table to gt_table.
       clear lv_number.

       ENDLOOP.
       ENDMETHOD.


       METHOD loop_bapi_fun.

         LOOP AT gt_bapi3 into gs_bapi3.

           gs_table-musteri_bakiye = gs_bapi3-lc_bal.
           gs_table-musteri_bakiyepb2 = gs_bapi3-currency.
           gs_table-upb_bakiye = gs_bapi3-t_curr_bal.
           gs_table-upb_para_birimi = gs_bapi3-loc_currcy.

           IF gs_bapi3-sp_gl_ind IS NOT INITIAL.
        gs_table-odk_gost = gs_bapi3-sp_gl_ind.
        SELECT SINGLE ltext FROM t074t INTO gs_table-ktext
        WHERE koart = 'D' AND shbkz = gs_bapi3-sp_gl_ind AND spras = 'T'.
        gs_table-intro_text = 'Müşteri ÖDK Bakiyesi' .
      ELSE.
        gs_table-intro_text = 'Müşteri Bakiyesi'.
      ENDIF.


        IF gs_table-borc_alacak EQ 'H'.                       "müşterinin borç mu yoksa alacak mı olduğunun kontrolünü yapıyoruz.
        gs_table-borc_alacak_text = 'ALACAK'.
      ELSE.
        gs_table-borc_alacak_text = 'BORÇ'.
        ENDIF.


         ENDLOOP.
         ENDMETHOD.


   METHOD prepare_alv.

    me->create_alv( ).
    me->set_pf_status( ).
    me->set_alv_properties( ).
    me->set_top_of_page( ).
    me->display_alv( ).

  ENDMETHOD.



   METHOD create_alv.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = mo_alv
          CHANGING
            t_table      = gt_table ).
      CATCH
        cx_salv_msg INTO mo_exp_msg.
    ENDTRY.

  ENDMETHOD.



   METHOD display_alv.

    mo_alv->display( ).

  ENDMETHOD.

   METHOD set_pf_status.

    mo_alv->set_screen_status(
        report        = sy-repid
        pfstatus      = '0001'
        set_functions = mo_alv->c_functions_all
    ).

  ENDMETHOD.


   METHOD set_alv_properties.

    "set seletion
    mo_selection = mo_alv->get_selections( ).
    mo_selection->set_selection_mode( if_salv_c_selection_mode=>cell ).

    "set alv events
    mo_events = mo_alv->get_event( ).
    SET HANDLER go_report->on_link_click FOR mo_events.
    SET HANDLER go_report->on_function FOR mo_events.

    "zebra style
    mo_display = mo_alv->get_display_settings( ).
    mo_display->set_striped_pattern( cl_salv_display_settings=>true ).

    "optimize column
    mo_columns = mo_alv->get_columns( ).
    mo_columns->set_optimize( abap_true ).

    me->set_column_text( iv_fname = 'YEAR' iv_text  = 'YIL' ).
    me->set_column_text( iv_fname = 'MONTH' iv_text  = 'AY' ).
    me->set_column_text( iv_fname = 'KUNNR' iv_text  = 'Müşteri Numarası' ).
    me->set_column_text( iv_fname = 'NAME1' iv_text  = 'Ad' ).
    me->set_column_text( iv_fname = 'ULKE' iv_text  = 'Ülke Anahtarı' ).
    me->set_column_text( iv_fname = 'ODK_GOST' iv_text  = 'ÖDK Göstergesi' ).
    me->set_column_text( iv_fname = 'KTEXT' iv_text  = 'ÖDK Açıklama' ).
    me->set_column_text( iv_fname = 'BORC_ALACAK' iv_text  = 'B/A' ).
    me->set_column_text( iv_fname = 'BORC_ALACAK_TEXT' iv_text  = 'B/A Text' ).
    me->set_column_text( iv_fname = 'MUSTERI_BAKIYE' iv_text  ='Bakiye' ).
    me->set_column_text( iv_fname = 'MUSTERI_BAKIYEPB2' iv_text  = 'MUSTERI_BAKIYEPB2' ).
    me->set_column_text( iv_fname = 'UPB_BAKIYE' iv_text  ='UPB Bakiye' ).
    me->set_column_text( iv_fname = 'UPB_PARA_BIRIMI' iv_text  = 'UBP PB' ).
    me->set_column_text( iv_fname = 'MUTABAT_DURUM'  iv_text  ='Mutabık Durumu' ).
    me->set_column_text( iv_fname = 'MTB_DURUM_ACIKLA' iv_text  ='Açıklama' ).

    "hotspot
    TRY .
        mo_column ?= mo_columns->get_column( columnname = 'DETAIL_ICON' ).
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

      CATCH cx_salv_not_found.

    ENDTRY.

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



  METHOD set_top_of_page.
  ENDMETHOD.



  METHOD on_link_click.

    CASE column.

      WHEN 'DETAIL_ICON'.

        READ TABLE gt_table INTO gs_table INDEX row.
        me->fill_pop_table( ).
        gs_table_single_cus = gt_lineitems[ row ].
        APPEND gs_table_single_cus TO gt_table_single_cus.
        me->show_popup( ).

    ENDCASE.
  ENDMETHOD.




   METHOD fill_pop_table.

    LOOP AT gt_table_kna1 INTO gs_table_kna1.
      CALL FUNCTION 'BAPI_AR_ACC_GETOPENITEMS'
        EXPORTING
          companycode = p_bukrs
          customer    = gs_table_kna1-kunnr
          keydate     = p_datum
          noteditems  = 'X'
          secindex    = ''
        TABLES
          lineitems   = gt_bapi2.

      LOOP AT gt_bapi2 INTO gs_bapi2.
       gs_lineitems-doc_date = gs_bapi2-doc_date.
       gs_lineitems-doc_type = gs_bapi2-doc_type.
       gs_lineitems-item_num = gs_bapi2-item_num.
       gs_lineitems-ref_doc_no = gs_bapi2-ref_doc_no.
       gs_lineitems-db_cr_ind = gs_bapi2-db_cr_ind.
       gs_lineitems-lc_amount = gs_bapi2-lc_amount.
       gs_lineitems-currency = gs_bapi2-currency.

        APPEND gs_lineitems TO gt_lineitems.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


    METHOD show_popup.
IF gt_table_single_cus IS INITIAL.
  MESSAGE 'Pop-up için veri yok' TYPE 'I'.
  RETURN.
ENDIF.

    TRY .

        cl_salv_table=>factory(
          IMPORTING
            r_salv_table   = mo_alv
          CHANGING
            t_table        = gt_lineitems
        ).


        mo_alv->set_screen_popup(
              EXPORTING
                start_column = 10
                end_column   = 100
                start_line   = 5
                end_line     = 15
            ).
        mo_alv->display( ).

        CLEAR gt_table_single_cus.

      CATCH cx_salv_msg INTO DATA(lx_salv_msg).
        WRITE: 'Beklenmedik bir hata oluştu.'.

    ENDTRY.
  ENDMETHOD.


  METHOD on_function.
    CASE e_salv_function.
      WHEN '&RECON'.

        me->receiver_email( ).
        me->send_email( ).
        IF sy-subrc eq 0 .
 MESSAGE |Mutabakat gönderimi başarılı| TYPE 'I'.
        ENDIF.


     ENDCASE.
  ENDMETHOD.

   METHOD receiver_email.

    DATA: lv_mail_adress TYPE string.

    " generate email for custmers
    LOOP AT gt_table INTO gs_table.

      gs_reciver_email-kunnr = gs_table-kunnr.
      CONCATENATE gs_table-kunnr 'mdpgroup.com' INTO lv_mail_adress.
      gs_reciver_email-email = lv_mail_adress.

      APPEND gs_reciver_email TO gt_reciver_email.

    ENDLOOP.

  ENDMETHOD.


    METHOD send_email.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client   = '100'
        id       = 'ST'
        language = 'T'
        name     = 'ZMDIK_TXT001'
        object   = 'TEXT'
      TABLES
        lines    = gt_table_tline.

    me->push_email( ).


  ENDMETHOD.


  METHOD push_email.

    DATA : lt_reciver_info  TYPE STANDARD TABLE OF somlreci1,
           ls_reciver_info  TYPE somlreci1,
           lt_mail_content  TYPE STANDARD TABLE OF solisti1,
           ls_mail_content  TYPE solisti1,
           lt_content_info  TYPE STANDARD TABLE OF sopcklsti1,
           ls_content_info  TYPE sopcklsti1,
           lv_mail_feature  TYPE sodocchgi1,
           lt_rows          TYPE salv_t_row,
           lv_report_id      TYPE string,
           lv_combined_line TYPE string,
           lv_balance       TYPE string,
           lv_cus_mail      TYPE string,
           lv_temp          TYPE string,
           lv_sender        TYPE soextreci1-receiver.


    "seçilan satır numarasını alıyoruz
    lt_rows = mo_alv->get_selections( )->get_selected_rows( ).

    LOOP AT lt_rows INTO DATA(ls_row).

      READ TABLE gt_table INTO gs_table INDEX ls_row.
      lv_report_id = gs_table-report_id.

       email içeriğini değiştiriyorum
      LOOP AT gt_table_tline INTO gs_table_tline.
        REPLACE '&1' WITH gs_table-year INTO gs_table_tline-tdline.
        REPLACE '&2' WITH gs_table-month INTO gs_table_tline-tdline.
        REPLACE '&3' WITH gs_table-name1 INTO gs_table_tline-tdline.
        REPLACE '&4' WITH lv_balance INTO gs_table_tline-tdline.
        REPLACE '&5' WITH gs_table-upb_para_birimi INTO gs_table_tline-tdline.
        REPLACE '&6' WITH lv_report_id INTO gs_table_tline-tdline.

        MODIFY gt_table_tline FROM gs_table_tline.
      ENDLOOP.

      " mail tablosundaki email i satırdaki müşteriye göre değiştiriyorum.
      LOOP AT gt_reciver_email INTO gs_reciver_email.
        IF gs_reciver_email-kunnr EQ gs_table-kunnr.
          lv_temp = gs_reciver_email-email.
        ENDIF.
      ENDLOOP.

      " email içeriğini dolduruyoruz.
      LOOP AT gt_table_tline INTO gs_table_tline.

        CONCATENATE '<P>' gs_table_tline-tdline '</P>'
        INTO lv_combined_line.

        ls_mail_content-line = lv_combined_line.
        APPEND ls_mail_content TO lt_mail_content.

      ENDLOOP.

      gs_table_z-report_id = gs_table-report_id.
      gs_table_z-report_yil = p_datum+0(4).
      gs_table_z-report_ay = p_datum+4(2).
      gs_table_z-KUNNR = gs_table-kunnr.
      gs_table_z-NAME1 = sy-uname.
      gs_table_z-OFFICAL_PER = sy-uname.
      gs_table_z-SENDER_MAIL = 'muharrem@mdp.com'.
*      gs_table_z-SENDER_MAIL = 'Muharrem@com'.
      gs_table_z-RECEIVER_NAME = 'test@gmail.com'.
      gs_table_z-RECEIVER_MAIL = lv_temp.
*      gs_table_z-reciver_tax = gs_table-txjcd.
      gs_table_z-MUSTERI_BAKIYE = gs_table-upb_bakiye.
      gs_table_z-para_birimi = gs_table-musteri_bakiyepb2.

      APPEND gs_table_z TO gt_table_z.

      lv_sender = 'muharrem@mdp.com'.
      lv_cus_mail = lv_temp.
      lv_balance = gs_table-musteri_bakiye.

      ls_reciver_info-receiver = lv_cus_mail.
      ls_reciver_info-rec_type = 'U'.

      APPEND ls_reciver_info TO lt_reciver_info.

      lv_mail_feature-obj_langu = 'T'.
      lv_mail_feature-obj_name = 'Mesaj'.
      lv_mail_feature-obj_descr = 'Mutabakat Raporu'.

      ls_content_info-transf_bin = space.
      ls_content_info-head_start = 1.
      ls_content_info-head_num   = 0.
      ls_content_info-body_start = 1.

      DESCRIBE TABLE lt_mail_content LINES ls_content_info-body_num.
      ls_content_info-doc_type = 'HTM'.
      APPEND ls_content_info TO lt_content_info.

      CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
        EXPORTING
          document_data              = lv_mail_feature
          sender_address             = lv_sender
          sender_address_type        = 'INT'
          commit_work                = 'X'
        TABLES
          packing_list               = lt_content_info
          contents_txt               = lt_mail_content
          receivers                  = lt_reciver_info
        EXCEPTIONS
          too_many_receivers         = 1
          document_not_sent          = 2
          document_type_not_exist    = 3
          operation_no_authorization = 4
          parameter_error            = 5
          x_error                    = 6
          enqueue_error              = 7
          OTHERS                     = 8.

    ENDLOOP.

 IF sy-subrc = 0.
    WRITE: 'E-posta başarıyla gönderildi!'.
  ELSE.
    WRITE: 'E-posta gönderilemedi!'.
  ENDIF.

*    MODIFY  ZMDIK_MUTAKABAT2 FROM TABLE gt_table_z.

  ENDMETHOD.






ENDCLASS.
