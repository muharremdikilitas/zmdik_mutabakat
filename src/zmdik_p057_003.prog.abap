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
      send_mail,
      icon,
      set_top_of_page,
      receiver_email,
      counter RETURNING VALUE(iv_count) TYPE i.

  PROTECTED SECTION.

    DATA: mo_alv       TYPE REF TO cl_salv_table,                             "alv nin ana nesnesidir
          mo_exp_msg   TYPE REF TO cx_salv_msg,                                "bir hata mesajı oluşursa bu nesne içine düşer
          mo_display   TYPE REF TO cl_salv_display_settings,                    "alv görünümümü anlamak için kullanılır. zebra falan
          mo_columns   TYPE REF TO cl_salv_columns_table,                       "Tek tek kolon ayarları yapılmak isteniyorsa bu nesne kullanılır.
          mo_column    TYPE REF TO cl_salv_column_table,                        "Tek bir kolona özel işlem yapmak için kullanılır.
          mo_events    TYPE REF TO cl_salv_events_table,                        "ALV'de kullanıcı tıklamaları gibi etkinlikleri (event) kontrol eder.
          mo_layout    TYPE REF TO cl_salv_layout,                                "Kullanıcının ALV görünümünü kaydedip tekrar kullanabilmesini sağlar.
          mo_selection TYPE REF TO cl_salv_selections.                            "ALV içinde seçim işlemleri yapmak için kullanılır.



    METHODS :
      save_getkey,
      set_column_text
        IMPORTING iv_fname TYPE lvc_fname           "ALV GRİDDEKİ KOLONUN TEKNİK ADI
                  iv_text  TYPE any,                "any herhangi bir türde veri anlamına geliyor

      on_user_command       FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_link_click         FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row
                  column .

ENDCLASS.

CLASS lcl_report IMPLEMENTATION.
  METHOD select.

    IF tarihbil IS INITIAL.
      tarihbil = sy-datum.
    ENDIF.

    SELECT
    kna1~kunnr,
    kna1~stcd1,
    kna1~name1,
    kna1~land1,
    kna1~txjcd
     FROM kna1
     INTO CORRESPONDING FIELDS OF TABLE @gt_kna1
      WHERE kna1~kunnr IN @cm_no.


  ENDMETHOD.

  METHOD mainloop.

    SORT gt_kna1 ASCENDING BY kunnr.

    LOOP AT gt_kna1 INTO gs_kna1.                               "gt_kna1 i müşteri numrasına göre sıralıyor.

      ms_list-cm_numb = gs_kna1-kunnr.
      ms_list-cm_taxno = gs_kna1-stcd1.
      ms_list-name = gs_kna1-name1.
      ms_list-cm_cntry = gs_kna1-land1.
      ms_list-tax_ofc = gs_kna1-txjcd.
      ms_list-year = tarihbil+0(4).
      ms_list-month = tarihbil+4(2).
      ms_list-detail = '@16@'.

      SELECT SINGLE msg_ind FROM zmdik_t_003
      INTO gv_last_id
      WHERE cm_numb = ms_list-cm_numb.

      CLEAR ms_list-msg_ind.
      IF gv_last_id IS NOT INITIAL.
        ms_list-msg_ind = gv_last_id.
        CLEAR gv_last_id.
      ENDIF.

      me->icon( ).

      CALL FUNCTION 'BAPI_AR_ACC_GETKEYDATEBALANCE'
        EXPORTING
          companycode  = sirket
          customer     = gs_kna1-kunnr
          keydate      = tarihbil
          balancespgli = 'X'
          noteditems   = ''
        TABLES
          keybalance   = gt_keybalance.

      me->save_getkey( ).
      me->bapi( ).

    ENDLOOP.

  ENDMETHOD.

  METHOD save_getkey.

    LOOP AT gt_keybalance INTO gs_keybalance.

      ms_list-odkindex = gs_keybalance-sp_gl_ind.
      ms_list-tot_bal = gs_keybalance-t_curr_bal.
      ms_list-currency  = gs_keybalance-currency.
      ms_list-loc_bal = gs_keybalance-lc_bal.
      ms_list-loc_cur  = gs_keybalance-loc_currcy.

      CASE gs_keybalance-sp_gl_ind.
        WHEN 'A' .
          ms_list-int_text = TEXT-004.
          ms_list-odktext = TEXT-005.
        WHEN ''.
          ms_list-int_text = TEXT-006.
          ms_list-odktext = ''.
      ENDCASE.

      CASE gs_keybalance-db_cr_ind.
        WHEN 'H'.
          ms_list-def = TEXT-002.
        WHEN 'S'.
          ms_list-def = TEXT-003.
      ENDCASE.

      APPEND ms_list TO mt_list.
    ENDLOOP.

  ENDMETHOD.

  METHOD bapi.

    DATA: lt_bapi TYPE TABLE OF bapi3007_2,
          ls_bapi TYPE bapi3007_2.

    CALL FUNCTION 'BAPI_AR_ACC_GETOPENITEMS'
      EXPORTING
        companycode = sirket
        customer    = gs_kna1-kunnr
        keydate     = tarihbil
      TABLES
        lineitems   = lt_bapi.

    LOOP AT lt_bapi INTO ls_bapi.
      gs_popuptable-currency = ls_bapi-currency.
      gs_popuptable-db_cr_ind = ls_bapi-db_cr_ind.
      gs_popuptable-doc_date = ls_bapi-doc_date.
      gs_popuptable-doc_type = ls_bapi-doc_type.
      gs_popuptable-item_text = ls_bapi-item_text.
      gs_popuptable-lc_amount = ls_bapi-lc_amount.
      gs_popuptable-ref_doc_no = ls_bapi-ref_doc_no.
      APPEND gs_popuptable TO gt_popuptable.
    ENDLOOP.


  ENDMETHOD.

  METHOD create_alv.
*
    TRY.
        cl_salv_table=>factory(                                 "cl_salv_table üzerinden bir ALV grid oluşturulur.
          IMPORTING
            r_salv_table = mo_alv                                 "oluşturulan alv nesnesi mo_alv referans değişkenine atılır.
          CHANGING
            t_table      = mt_list ).                             "mt_list tablosundaki veriler bu ALV de gösterilecek.
      CATCH
        cx_salv_msg INTO mo_exp_msg.                            "Eğer factory çağrısı sırasında bir hata olursa (cx_salv_msg istisnası), bu hata mo_exp_msg içine alınır.

                                                                  "Bu sayede programın dump'a düşmesi engellenir.
    ENDTRY.

  ENDMETHOD.

  METHOD display_alv.

    mo_alv->display( ).                                           "ALV yi display et

  ENDMETHOD.
  METHOD set_alv_properties.

    mo_selection = mo_alv->get_selections( ).                                 "ALV de kulllanıcıların satır, hücre veya sütun seçmesine olanak tanır.
    mo_selection->set_selection_mode( if_salv_c_selection_mode=>cell ).         "burada CELL seçildiği için kullanıcı ALV tablosundaki tek bir hücreyi seçebililr.

    mo_display = mo_alv->get_display_settings( ).                               "ALV'nin genel görsel ayarlarına (örneğin zebra deseni gibi) erişmek için nesne alınır.

*     Set ALV Events.
    mo_events = mo_alv->get_event( ).                                             "ALV içinde kullanıcı butona bastığında added_function ya da hücereye tıklandığında link_click ne yapılacağını belirtir.
    SET HANDLER go_report->on_user_command FOR mo_events.                       "Bu olayları gı_report  nesnesinin ilgili metodlarıyla karşılar.
    SET HANDLER go_report->on_link_click FOR mo_events.

*     Zebra sytle..
    mo_display->set_striped_pattern( cl_salv_display_settings=>true ).                    "zebra desenini aktif ediyoruz
    mo_columns = mo_alv->get_columns( ).

*   column optimize
    mo_columns = mo_alv->get_columns( ).                                "Tüm sütun genişlikleri, içeriklerine göre otomatik olarak çalışır.
    mo_columns->set_optimize( abap_true ).

*   Set Optimize
    mo_columns->set_optimize( abap_true ).
    mo_layout = mo_alv->get_layout( ).

    me->set_column_text( iv_fname = 'YEAR' iv_text = TEXT-h01 ).                        "kolon başlıklarını özelleştiriyoruz.
    me->set_column_text( iv_fname = 'MONTH' iv_text = TEXT-h02 ).
    me->set_column_text( iv_fname = 'INT_TEXT' iv_text = TEXT-h03 ).
    me->set_column_text( iv_fname = 'ODKTEXT' iv_text = TEXT-h04 ).
    me->set_column_text( iv_fname = 'DEF' iv_text = TEXT-h05 ).
    me->set_column_text( iv_fname = 'RECON_DES' iv_text = TEXT-018 ).

    TRY.
        mo_column ?= mo_columns->get_column( 'DETAIL' ).                            "detail kolonundaki hücreleri tıklanabilir hale getirilir (hotspot)
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).                   "kullanıcı buraya tıkladığında on_link_click eventi tetiklenir.

      CATCH cx_salv_not_found .

    ENDTRY.

  ENDMETHOD.

  METHOD prepare_alv .

    me->create_alv( ).
    me->set_pf_status( ).
    me->set_alv_properties( ).
    me->set_top_of_page( ).
    me->display_alv( ).

  ENDMETHOD.

  METHOD on_link_click.

    DATA ls_take_indx TYPE poptable.

    CASE column.
      WHEN 'DETAIL'.

        READ TABLE mt_list INTO ms_list INDEX row.        "tıklanılan alv satırının index numarasıdır. mt_list tablosunun row numaralı satırını bulur ve ms_liste aktarır.
        me->bapi( ).
        ls_take_indx = gt_popuptable[ row ].
        APPEND ls_take_indx TO gt_take_indx.
        me->show_popup( ).

    ENDCASE.

  ENDMETHOD.

  METHOD set_pf_status.                                 "Bu metot, CL_SALV_TABLE ile oluşturulan ALV grid için PF-STATUS (yani ekran fonksiyon menüsü, butonlar ayarlarını yapar.
*
    mo_alv->set_screen_status(
                pfstatus      = '0100'
                report        = sy-repid
                set_functions = mo_alv->c_functions_all ).        "Desteklenen tüm fonksiyonların aktif olmasını sağlar.

  ENDMETHOD.

  METHOD on_user_command.
    CASE e_salv_function.
      WHEN '&MBUT'.
        me->receiver_email( ).
        me->send_mail( ).

        MESSAGE TEXT-010 TYPE 'I'.
    ENDCASE.

  ENDMETHOD.

  METHOD set_column_text.

    DATA : lv_textl TYPE scrtext_l,
           lv_textm TYPE scrtext_m,
           lv_texts TYPE scrtext_s.

    lv_texts = lv_textm = lv_textl = iv_text.

    TRY.
        mo_column ?= mo_columns->get_column( iv_fname ).              "iv_fname ile verilen teknik isimli sütun bulunmaya çalışılır. bulunursa referans mo_column içine atanır.
        mo_column->set_long_text( lv_textl ).
        mo_column->set_medium_text( lv_textm ).
        mo_column->set_short_text( lv_texts ).
      CATCH cx_salv_not_found .                                         "Eğer iv_fname ismiyle bir sütun bulunamazsa bu exception yakalanır ve program dump yemez
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
                start_column = 1              "sol üstten başlar
                end_column   = 0               "son sütunu kendisi ayarlar
                start_line   = 1
                end_line     = 0
            ).

        mo_alv->display( ).                     "popup ekranı gösteriliyor
        CLEAR gt_take_indx.
      CATCH cx_salv_msg INTO DATA(lx_salv_msg).         "dump yerine hata mesajı vermesi için
        WRITE: TEXT-014.
    ENDTRY.
  ENDMETHOD.

  METHOD receiver_email.

    DATA: lv_mail_adress TYPE string.

    " email yaratma
    LOOP AT mt_list INTO ms_list.

      gs_email-cm_numb_mail = ms_list-cm_numb.
      CONCATENATE ms_list-cm_numb TEXT-011 INTO lv_mail_adress.
      gs_email-cm_mail = lv_mail_adress.

      APPEND gs_email TO gt_email.

    ENDLOOP.

    MODIFY zmdik_t_003_mail FROM TABLE gt_email.

  ENDMETHOD.

  METHOD send_mail.

    DATA:
      lv_tot_s         TYPE string,
      lv_loc_s         TYPE string,
      lv_temp          TYPE string,
      lv_cus_mail      TYPE string,
      lv_combined_line TYPE string,
      lv_recon_id      TYPE string,
      lv_link          TYPE string,
      lt_table         TYPE TABLE OF zmdik_t_003,
      ls_table         TYPE zmdik_t_003,
      lv_mail_feature  TYPE sodocchgi1,
      lt_rows          TYPE salv_t_row,
      lv_sender        TYPE soextreci1-receiver,
      lt_table_tline   TYPE TABLE OF tline,
      ls_table_tline   TYPE tline,
      lt_reciver_info  TYPE STANDARD TABLE OF somlreci1,
      ls_reciver_info  TYPE somlreci1,
      lt_mail_content  TYPE STANDARD TABLE OF solisti1,
      ls_mail_content  TYPE solisti1,
      lt_content_info  TYPE STANDARD TABLE OF sopcklsti1,
      ls_content_info  TYPE sopcklsti1,
      lv_existing_id   TYPE zmdik_t_003-msg_ind,
      lv_kunnr         TYPE kunnr,
      lv_balance       TYPE string,
      lv_balance_sl    TYPE string,
      lv_stat(1)       TYPE c,
      lv_numb          TYPE i.

    CALL FUNCTION 'READ_TEXT'                                               "metin okunur içeriği html olarak e postada kullanılacaktır.
      EXPORTING
        client   = '100'
        id       = 'ST'
        language = 'T'
        name     = 'MUTABAKAT METNI'
        object   = 'TEXT'
      TABLES
        lines    = lt_table_tline.

    lt_rows = mo_alv->get_selections( )->get_selected_rows( ).                    "Seçilen satırın indeksi alıncaktır.

    LOOP AT lt_rows INTO DATA(ls_row).

      CLEAR: lv_balance,lv_balance_sl.

      READ TABLE mt_list INTO ms_list INDEX ls_row.                             "seçilen müşterinin simgesi ve açıklaması güncellenir
      ms_list-recon_des = TEXT-017.
      ms_list-icon = icon_time_control.                                             "modify ile tabloyu güncelledik

      MODIFY mt_list FROM ms_list INDEX ls_row.

      "Öncelikle zmdik_t_003 tablosundan mevcut bir kayıt var mı diye kontrol ediliyor
      SELECT SINGLE msg_ind FROM zmdik_t_003
        INTO lv_existing_id
        WHERE cm_numb = ms_list-cm_numb.

      IF sy-subrc = 0.
        " Kayıt bulunursa Mevcut ID'yi kullanılıyor
        ms_list-msg_ind = lv_existing_id.
        lv_recon_id = ms_list-msg_ind.
      ELSE.

        " Z tablosunda kayıt yok; o halde ms_list-msg_ind boşsa yeni ID üretilir
        IF ms_list-msg_ind IS INITIAL.
          CALL FUNCTION 'NUMBER_GET_NEXT'
            EXPORTING
              nr_range_nr             = '01'
              object                  = 'ZED_O_001'
            IMPORTING
              number                  = lv_numb
            EXCEPTIONS
              interval_not_found      = 1
              number_range_not_intern = 2
              object_not_found        = 3
              quantity_is_0           = 4
              quantity_is_not_1       = 5
              interval_overflow       = 6
              buffer_overflow         = 7
              OTHERS                  = 8.
          IF sy-subrc = 0.
            ms_list-msg_ind = lv_numb.
            lv_recon_id = ms_list-msg_ind.
          ELSE.
            WRITE: 'ID oluşturulamadı!'.
            CONTINUE.
          ENDIF.

        ELSE.
          lv_recon_id = ms_list-msg_ind.
        ENDIF.
      ENDIF.
      MODIFY mt_list FROM ms_list INDEX ls_row.

      READ TABLE mt_list INTO ms_list INDEX ls_row.


      lv_kunnr = ms_list-cm_numb.

      MODIFY mt_list FROM ms_list INDEX ls_row.

      CLEAR: lt_reciver_info,lt_mail_content,lt_content_info.

      LOOP AT mt_list INTO ms_list WHERE cm_numb = lv_kunnr.
        CASE ms_list-odkindex.
          WHEN ''.
            lv_balance = ms_list-tot_bal.
          WHEN 'A'.
            lv_balance_sl = ms_list-loc_bal.
        ENDCASE.
      ENDLOOP.

      lv_link = TEXT-012 && lv_recon_id && TEXT-013.  " Link oluşturma

      LOOP AT gt_email INTO gs_email.
        IF gs_email-cm_numb_mail EQ lv_kunnr.
          lv_temp = gs_email-cm_mail.
          EXIT.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_table_tline INTO ls_table_tline.
        REPLACE '&1' WITH ms_list-year INTO ls_table_tline-tdline.
        REPLACE '&2' WITH ms_list-month INTO ls_table_tline-tdline.
        REPLACE '&3' WITH ms_list-name INTO ls_table_tline-tdline.
        REPLACE '&4' WITH lv_balance INTO ls_table_tline-tdline.
        REPLACE '&5' WITH ms_list-currency INTO ls_table_tline-tdline.
        REPLACE '&6' WITH lv_link INTO ls_table_tline-tdline.
        REPLACE '&7' WITH lv_balance_sl INTO ls_table_tline-tdline.

        CONCATENATE '<P>' ls_table_tline-tdline '</P>' INTO lv_combined_line.
        ls_mail_content-line = lv_combined_line.
        APPEND ls_mail_content TO lt_mail_content.

      ENDLOOP.

      CLEAR: ls_reciver_info, ls_content_info.

      lv_sender = TEXT-007.
      lv_cus_mail = lv_temp.

      ls_reciver_info-receiver = lv_cus_mail.
      ls_reciver_info-rec_type = 'U'.
      APPEND ls_reciver_info TO lt_reciver_info.

      lv_mail_feature-obj_langu = 'T'.
      lv_mail_feature-obj_name = TEXT-008.
      lv_mail_feature-obj_descr = TEXT-009.

      ls_content_info-transf_bin = space.
      ls_content_info-head_start = 1.
      ls_content_info-head_num   = 0.
      ls_content_info-body_start = 1.

      DESCRIBE TABLE lt_mail_content LINES ls_content_info-body_num.
      ls_content_info-doc_type = 'HTM'.
      APPEND ls_content_info TO lt_content_info.

      SELECT SINGLE status FROM zmdik_t_003 INTO lv_stat WHERE cm_numb = ms_list-cm_numb.

      IF lv_stat IS INITIAL.

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

      ENDIF.

      CLEAR: lv_stat,lv_mail_feature, lv_sender, lt_content_info, lt_mail_content, lt_reciver_info.

      LOOP AT mt_list INTO ms_list WHERE cm_numb = lv_kunnr.
        CASE ms_list-odkindex.
          WHEN ''.
            ls_table-cm_blnc_tot = ms_list-tot_bal.
          WHEN 'A'.
            ls_table-cm_blnc_lc = ms_list-loc_bal.
        ENDCASE.

        ls_table-odkindex = ms_list-odkindex.
        ls_table-d_year = ms_list-year.
        ls_table-d_month = ms_list-month.
        ls_table-cm_numb = ms_list-cm_numb.
        ls_table-cm_cntry = ms_list-cm_cntry.
        ls_table-msg_ind = ms_list-msg_ind.
        ls_table-currency = ms_list-currency.
        ls_table-cm_blnc_tot = ms_list-tot_bal.
        ls_table-cm_blnc_lc = ms_list-loc_bal.
        ls_table-currency = ms_list-loc_cur.
        ls_table-cm_taxno = ms_list-cm_taxno.
        ls_table-tax_ofc = ms_list-tax_ofc.
        IF ls_table-status IS INITIAL.
          ls_table-status = 'A'.
        ENDIF.
        IF ms_list-msg_ind NE 0.
          APPEND ls_table TO lt_table.
        ENDIF.
      ENDLOOP.

      MODIFY zmdik_t_003 FROM TABLE lt_table.

    ENDLOOP.

    mo_alv->refresh( ).

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
                  text    = TEXT-015
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
                   text    = TEXT-016 ).

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
    SELECT SINGLE status FROM zmdik_t_003 INTO lv_status WHERE cm_numb = ms_list-cm_numb.

    CLEAR: ms_list-recon_des, ms_list-icon.

    IF lv_status IS NOT INITIAL.
      CASE lv_status.
        WHEN 'A'.
          ms_list-icon = icon_time_control.
          ms_list-recon_des = TEXT-017.
        WHEN 'B'.
          ms_list-icon = icon_led_green.
          ms_list-recon_des = TEXT-019.
        WHEN 'C'.
          ms_list-icon = icon_led_red.
          ms_list-recon_des = TEXT-020.
        WHEN OTHERS.
          ms_list-icon = icon_dummy.
      ENDCASE.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
