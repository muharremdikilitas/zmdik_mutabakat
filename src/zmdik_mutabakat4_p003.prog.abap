
*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTABAKAT4_P003
*&---------------------------------------------------------------------*

CLASS lcl_agreement DEFINITION.

  PUBLIC SECTION.                 "Public section, sınıfın dışarıya açılan (genel) özelliklerini ve metotlarını tanımlar

    TYPES: BEGIN OF ty_display,
             doc_date   TYPE bapi3007_2-doc_date,
             doc_type   TYPE bapi3007_2-doc_type,
             item_text  TYPE bapi3007_2-item_text,
             ref_doc_no TYPE bapi3007_2-ref_doc_no,
             db_cr_ind  TYPE bapi3007_2-db_cr_ind,
             lc_amount  TYPE bapi3007_2-lc_amount,
             currency   TYPE bapi3007_2-currency,
           END OF ty_display.



    DATA : mt_list       TYPE STANDARD TABLE OF zmdik_str,
           ms_list       TYPE zmdik_str,
           mv_bukrs      TYPE knb1-bukrs,
           mv_date       TYPE sy-datum,
           ms_key        TYPE salv_s_layout_key,
           gt_bapi_data  TYPE TABLE OF bapi3007_2,
           gs_bapi_data  TYPE bapi3007_2,
           gt_display    TYPE TABLE OF ty_display,
           gs_display    TYPE ty_display,
           gt_keybalance TYPE TABLE OF bapi3007_3,
           gs_keybalance TYPE bapi3007_3,
           gv_subject    TYPE so_obj_des,
           gs_selected   TYPE zmdik_str,
           gt_selected   TYPE STANDARD TABLE OF zmdik_str.

    METHODS :
      get_customer_data,                ": Müşteri verilerini alır.
      initialization,                       "Başlangıç ayarlarını yapar.
      set_first_status,                           "İlk durumu ayarlamak için kullanılır
      at_selection_screen,
      get_data RETURNING VALUE(rv_subrc) TYPE sy-subrc,         "Veri alır, dönen değeri sy-subrc olarak verir.
      set_data,                                                         " Veriyi ayarlamak için kullanılan metot.
      " Filtresiz veri ayarları yapar.
      progress_indicator IMPORTING iv_text TYPE any,                        "İşlem ilerleme göstergesi için kullanılır.
      check_fields,                                                         "Alan doğrulama işlemi.
      start_report,                                                          "Raporu başlatır.
      prepare_report,                                                         "Raporu hazırlar
      prepare_alv,                                                              "ALV raporunu hazırlar.
      counter RETURNING VALUE(iv_count) TYPE i.

  PROTECTED SECTION.                                                      " türetilmiş sınıflar tarafından erişilebilen metodlar

    DATA : mo_alv       TYPE REF TO cl_salv_table,
           mo_display   TYPE REF TO cl_salv_display_settings,
           mo_columns   TYPE REF TO cl_salv_columns_table,
           mo_column    TYPE REF TO cl_salv_column_table,
           mo_selection TYPE REF TO cl_salv_selections,
           mo_layout    TYPE REF TO cl_salv_layout,
           mo_events    TYPE REF TO cl_salv_events_table,
           mo_sorts     TYPE REF TO cl_salv_sorts,
           ##NEEDED
           mo_exp_msg   TYPE REF TO cx_salv_msg.
  PRIVATE SECTION.

    METHODS :
      create_alv,
      display_alv,
      set_pf_status,
      set_top_of_page,
      set_alv_properties,
      append_to_list,

      get_customer_balance                          " Müşteri bakiyelerini alır.
        IMPORTING iv_kunnr TYPE kna1-kunnr,

      get_customer_details                            "Müşteri detaylarını alır.
        IMPORTING iv_kunnr TYPE kna1-kunnr,

      get_oedk_text                                   "açıklamayı alır.
        IMPORTING iv_sp_gl_ind TYPE t074t-shbkz
        CHANGING  cv_oedk_txt  TYPE zoedk_txt
                  cv_oedk_sts  TYPE ztanitici,
      get_reconciliation_status                             "mutabakat durumu
        IMPORTING
          iv_kunnr         TYPE kna1-kunnr
          iv_gjahr         TYPE gjahr
          iv_monat         TYPE monat
          iv_bukrs         TYPE bukrs
          iv_upb_balance   TYPE zmdik_mutabakat4-upb_balance
        CHANGING
          cv_agreement_sts TYPE zmdik_mutabakat4-agreement_sts
          cv_description   TYPE zmdik_mutabakat4-description,
      get_reconciliation_text                             "mutabakat açıklaması
        CHANGING
          cv_agreement_sts     TYPE zmdik_mutabakat4-agreement_sts
          cv_agreement_sts_dtl TYPE zmutabakat_drm_dtl
          cv_status_icon       TYPE icon_d,
      determine_status_icon                                       "mutabakat durumu simgesi
        IMPORTING
          iv_agreement_sts TYPE zmdik_mutabakat4-agreement_sts
        EXPORTING
          ev_status_icon   TYPE icon_d,
      get_shkzg_text                                        "Borç / alacak
        IMPORTING iv_shkzg       TYPE shkzg
        RETURNING VALUE(rv_text) TYPE string,
        ##RELAX
      set_column_text                                               "Sütun metnini ayarlar.
        IMPORTING iv_fname TYPE lvc_fname
                  iv_text  TYPE any,
       ##RELAX
      set_sort                                                      " Verileri sıralar.
        IMPORTING VALUE(iv_col)  TYPE lvc_fname
                  VALUE(iv_seq)  TYPE salv_de_sort_sequence
                  VALUE(iv_subt) TYPE sap_bool ,
      on_user_command FOR EVENT added_function OF cl_salv_events              "Kullanıcı komutları içi
        IMPORTING e_salv_function,
      configure_salv,                                                         " ALV yapılandırma işlemi
      handle_email_button,                                                    "E-posta butonunu yönetir.
      send_reconciliation_email,                                              "Mutabakat e-postasını gönderir.
      update_reconciliation,                                                    "Mutabakat bilgisini günceller.
      add_to_gt_selected                                                        " Seçilen kayıtları bir listeye ekler.
        IMPORTING
          ps_row TYPE zmdik_str,
      send_group_mail                                                         "Grup e-postası gönderir
        IMPORTING
          iv_kunnr     TYPE kna1-kunnr
          iv_mail_text TYPE string
          iv_rows      TYPE string
          iv_has_notok TYPE abap_bool DEFAULT abap_false,
      on_link_click FOR EVENT link_click OF cl_salv_events_table
      ##NEEDED
        IMPORTING row
                  column,
           ##RELAX
      on_after_user_command FOR EVENT if_salv_events_functions~added_function OF cl_salv_events_table.


ENDCLASS.                    "lcl_agreement definition


CLASS lcl_agreement IMPLEMENTATION.


*
  METHOD get_customer_data.
    DATA: lt_kunnr TYPE TABLE OF kna1-kunnr,
          lv_kunnr TYPE kna1-kunnr.

    " p_kunnr (select-options) kullanılarak müşteri numaralarını alıyoruz
    SELECT kunnr FROM kna1
      INTO TABLE @lt_kunnr
      WHERE kunnr IN @p_kunnr.

    LOOP AT lt_kunnr INTO lv_kunnr.           "
      CLEAR gt_keybalance.
      get_customer_balance( lv_kunnr ).
      LOOP AT gt_keybalance INTO gs_keybalance.                       "döngü içinde bakiyeleri atıyoruz.
        CLEAR ms_list.
        ms_list-kunnr      = lv_kunnr.
        ms_list-gjahr      = mv_date(4).
        ms_list-monat      = mv_date+4(2).
        ms_list-oedk       = gs_keybalance-sp_gl_ind.
        ms_list-bakiye     = gs_keybalance-t_curr_bal.
        ms_list-waers      = gs_keybalance-currency.
        ms_list-upb_bakiye = gs_keybalance-lc_bal_long.
        ms_list-upb_waers  = gs_keybalance-loc_currcy.
        ms_list-detay      = TEXT-004.

        get_customer_details( lv_kunnr ).                         "müşterinin detaylı bilgileri
        get_oedk_text(
          EXPORTING iv_sp_gl_ind = gs_keybalance-sp_gl_ind
          CHANGING  cv_oedk_txt  = ms_list-oedk_txt
                    cv_oedk_sts  = ms_list-tanitici ).
        get_reconciliation_status(                                  "
          EXPORTING
            iv_kunnr       = ms_list-kunnr
            iv_gjahr       = ms_list-gjahr
            iv_monat       = ms_list-monat
            iv_bukrs       = mv_bukrs
            iv_upb_balance = ms_list-upb_bakiye
          CHANGING
            cv_agreement_sts = ms_list-mutabakat_drm
            cv_description   = ms_list-aciklama ).
        get_reconciliation_text(
          CHANGING
            cv_agreement_sts     = ms_list-mutabakat_drm
            cv_agreement_sts_dtl = ms_list-mutabakat_drm_dtl
            cv_status_icon       = ms_list-status_icon ).
        ms_list-tanim = get_shkzg_text( gs_keybalance-db_cr_ind ).
        append_to_list( ).                                          "tüm müşteri bilgileri ms_list'e eklenir.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.



  METHOD get_customer_balance.                                        "her müşteri için hesap bakiyelerini alır.
    CALL FUNCTION 'BAPI_AR_ACC_GETKEYDATEBALANCE'
      EXPORTING
        companycode  = mv_bukrs
        customer     = iv_kunnr
        keydate      = mv_date
        balancespgli = 'X'
        noteditems   = ' '
      TABLES
        keybalance   = gt_keybalance.
  ENDMETHOD.                "get_customer_balance

  METHOD get_customer_details.                                              "müşteri bilgileri
    SELECT SINGLE stcd1, name1, stceg, land1
      INTO ( @ms_list-stcd1, @ms_list-name1, @ms_list-stceg, @ms_list-land1 )
      FROM kna1
      WHERE kunnr = @iv_kunnr.
  ENDMETHOD.                "get_customer_details

  METHOD get_oedk_text.
    ##WARN_OK                                                    "müşteri ödk bakiyesi / müşteri bakiyesi
    SELECT SINGLE ltext
      INTO cv_oedk_txt
      FROM t074t
      WHERE shbkz = iv_sp_gl_ind
        AND spras = TEXT-003.
    cv_oedk_sts = COND string(
      WHEN cv_oedk_txt IS NOT INITIAL THEN TEXT-001
      ELSE TEXT-002
    ).
  ENDMETHOD.                "get_oedk_text

  METHOD get_reconciliation_status.                                                               " Mutabakat durumu bilgileri
   ##NEEDED
    DATA: lv_id TYPE zmdik_mutabakat4-id.
##WARN_OK
    SELECT SINGLE agreement_sts, id, description
      INTO (@cv_agreement_sts, @lv_id, @cv_description)
      FROM zmdik_mutabakat4
      WHERE kunnr       = @iv_kunnr
        AND gjahr       = @iv_gjahr
        AND monat       = @iv_monat
        AND bukrs       = @iv_bukrs
        AND upb_balance = @iv_upb_balance.

    IF sy-subrc <> 0.
      cv_agreement_sts = TEXT-007.  " Mutabakat bulunamadı mesajı
      cv_description   = ''.
    ENDIF.
  ENDMETHOD.               "get_reconciliation_status

  METHOD get_reconciliation_text.
    DATA: lt_dd07l TYPE TABLE OF dd07v,
          ls_dd07l TYPE dd07v.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = TEXT-008
        text      = abap_true
      TABLES
        dd07v_tab = lt_dd07l
      EXCEPTIONS
        OTHERS    = 1.

    IF sy-subrc <> 0.
      MESSAGE TEXT-055 TYPE 'E'.
    ENDIF.

    IF sy-subrc <> 0.
      cv_agreement_sts_dtl = TEXT-009.
    ELSE.
      " İlgili domain değerini bul
      READ TABLE lt_dd07l INTO ls_dd07l WITH KEY domvalue_l = cv_agreement_sts.
      IF sy-subrc = 0.
        cv_agreement_sts_dtl = ls_dd07l-ddtext.
      ELSE.
        cv_agreement_sts_dtl = TEXT-009.
      ENDIF.
    ENDIF.

    determine_status_icon(                                              "mutabakat durumu için ikon belirleme
      EXPORTING iv_agreement_sts  = cv_agreement_sts
      IMPORTING ev_status_icon    = cv_status_icon ).
  ENDMETHOD.                "get_reconciliation_text

  METHOD determine_status_icon.
    CASE iv_agreement_sts.
      WHEN TEXT-010. ev_status_icon = TEXT-013. " Mutabık
      WHEN TEXT-011. ev_status_icon = TEXT-014. " Mutabık Değil
      WHEN TEXT-012. ev_status_icon = TEXT-015. " Kısmi Mutabık
      WHEN OTHERS. ev_status_icon   = TEXT-016. " Beklemede
    ENDCASE.
  ENDMETHOD.                "determine_status_icon

  METHOD get_shkzg_text.
    DATA: lt_dd07l TYPE TABLE OF dd07v,
          ls_dd07l TYPE dd07v.
    " Domain değerlerini al
    CALL FUNCTION 'DD_DOMVALUES_GET'   " Domain değerlerini al, mutabakat durumunu belirle
      EXPORTING
        domname   = TEXT-008
        text      = abap_true
      TABLES
        dd07v_tab = lt_dd07l
      EXCEPTIONS
        OTHERS    = 1.  " NOT_FOUND hatasını kaldırdık

    IF sy-subrc <> 0.
      MESSAGE TEXT-055 TYPE 'E'.
    ENDIF.

    IF sy-subrc <> 0.
      rv_text = TEXT-009.
    ELSE.
      " İlgili domain değerini bul
      READ TABLE lt_dd07l INTO ls_dd07l WITH KEY domvalue_l = iv_shkzg.
      IF sy-subrc = 0.
        rv_text  = ls_dd07l-ddtext.
      ELSE.
        rv_text  = TEXT-009.
      ENDIF.
    ENDIF.
  ENDMETHOD.                "get_shkzg_text

  METHOD append_to_list.
    APPEND ms_list TO mt_list.
  ENDMETHOD.                "append_to_list
##NEEDED
  METHOD initialization.
*
  ENDMETHOD.                "initialization
  ##NEEDED
  METHOD set_first_status.
*
  ENDMETHOD.                "set_first_status
##NEEDED
  METHOD at_selection_screen.
*
  ENDMETHOD.                "at_selection_screen

  METHOD get_data.
    mv_bukrs = p_bukrs.
    mv_date  = p_date.
    " p_kunnr, selection screen'den gelen select-options'dur.
    go_agreement->get_customer_data( ).
  ENDMETHOD.

*  METHOD get_data.
*    mv_bukrs       = p_bukrs.
*    mv_date        = p_date.
*    mt_kunnr_range = p_kunnr[].
*
*    go_agreement->get_customer_data( ).
*  ENDMETHOD.                "get_data

##NEEDED
  METHOD set_data.
*
  ENDMETHOD.                "set_data

  METHOD progress_indicator.                    "ilerleme göstergesi
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 75
        text       = iv_text.
  ENDMETHOD.                "progress_indicator
##NEEDED
  METHOD check_fields.
*
  ENDMETHOD.                "check_fields

  METHOD start_report.
    me->prepare_report( ).
  ENDMETHOD.                "start_report

  METHOD prepare_report.
    ##NEEDED
    DATA(lv_subrc) = me->get_data( ).
    progress_indicator( TEXT-054 ).
    me->set_data( ) .
  ENDMETHOD.              "prepare_report

  METHOD prepare_alv.
    me->create_alv( ).
    me->configure_salv( ).
    me->set_pf_status( ).
    me->set_alv_properties( ).
    me->set_top_of_page( ).
    me->display_alv( ).
  ENDMETHOD.                "prepare_alv

  METHOD create_alv.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = mo_alv
          CHANGING
            t_table      = mt_list ).
      CATCH
        cx_salv_msg INTO mo_exp_msg.
        MESSAGE mo_exp_msg->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.                "create_alv

  METHOD display_alv.
    mo_alv->display( ).
  ENDMETHOD.                "display_alv

  METHOD set_pf_status.
    mo_alv->set_screen_status(
                pfstatus      = '0200'
                report        = sy-repid
                set_functions = mo_alv->c_functions_all ).
  ENDMETHOD.                "set_pf_status

  METHOD set_top_of_page.
    DATA: lo_grid_top    TYPE REF TO cl_salv_form_layout_grid,
          lo_grid_sub    TYPE REF TO cl_salv_form_layout_grid,
          lo_text        TYPE REF TO cl_salv_form_text,
          lo_logo        TYPE REF TO cl_salv_form_layout_logo,
          lv_count       TYPE i,
          lv_header_text TYPE string.

    " Üst grid oluştur
    CREATE OBJECT lo_grid_top.

    " İlk satırda sabit başlık: Örneğin, "Mutabakat Raporu"
    lo_grid_top->create_header_information(
        row     = 1
        column  = 1
        text    = TEXT-056
        tooltip = TEXT-056 ).

    " Alt bölüme geçmek için yeni bir satır ekle
    lo_grid_top->add_row( ).

    " Veri sayısını al
    lv_count = me->counter( ).

    " Dinamik header metnini oluştur (HTML <b> etiketleriyle kalınlaştırılmış)
    lv_header_text = |{ TEXT-068 }  { lv_count } - { TEXT-068 } { sy-uname }|.

    " Alt grid oluştur; 1 satır, 2 sütun
    lo_grid_sub = lo_grid_top->create_grid(
                    row    = 2
                    column = 2 ).

    " Sol sütuna metin nesnesi oluştur
    lo_text = lo_grid_sub->create_text(
                row     = 1
                column  = 1
                text    = lv_header_text
                tooltip = lv_header_text ).

    " Sağ sütun için logo nesnesi oluştur
    CREATE OBJECT lo_logo.
    lo_logo->set_right_logo( 'BL_LOGO' ).  " Sisteminizde tanımlı logo ID'si

    " Alt grid hücrelerine içerik yerleştirme: set_element metodunun parametresi "r_element" kullanılıyor
    lo_grid_sub->set_element(
        row     = 1
        column  = 1
        r_element = lo_text ).
    lo_grid_sub->set_element(
        row     = 1
        column  = 2
        r_element = lo_logo ).

    " Oluşturulan üst grid, ALV'nin üst kısmı olarak atanır
    mo_alv->set_top_of_list( lo_grid_top ).
  ENDMETHOD.





  METHOD set_alv_properties.
    mo_display = mo_alv->get_display_settings( ).
* Zebra sytle..
    mo_display->set_striped_pattern( cl_salv_display_settings=>true ).
    mo_columns = mo_alv->get_columns( ).
* Set optimize..
    mo_columns->set_optimize( abap_true ).
    mo_layout = mo_alv->get_layout( ).
* Set variant..
    ms_key-report = sy-repid.
    mo_layout->set_key( ms_key ).
    mo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
    mo_layout->set_default( abap_true ).
* Set selection..
    mo_selection = mo_alv->get_selections( ).
    mo_selection->set_selection_mode( if_salv_c_selection_mode=>row_column ).
    mo_events = mo_alv->get_event( ).
* Set ALV Events.
    SET HANDLER go_agreement->on_user_command FOR mo_events.
    SET HANDLER go_agreement->on_link_click FOR mo_events.

* ---- Sütun başlıklarını ayarla ----
    set_column_text( iv_fname = 'KUNNR'             iv_text = 'Müşteri No' ).
    set_column_text( iv_fname = 'NAME1'             iv_text = 'Müşteri Adı' ).
    set_column_text( iv_fname = 'STCD1'             iv_text = 'Vergi No' ).
    set_column_text( iv_fname = 'STCEG'             iv_text = 'VKN' ).
    set_column_text( iv_fname = 'LAND1'             iv_text = 'Ülke' ).
    set_column_text( iv_fname = 'GJAHR'             iv_text = 'Yıl' ).
    set_column_text( iv_fname = 'MONAT'             iv_text = 'Ay' ).
    set_column_text( iv_fname = 'OEDK'              iv_text = 'ÖDK Kodu' ).
    set_column_text( iv_fname = 'OEDK_TXT'          iv_text = 'ÖDK Metni' ).
    set_column_text( iv_fname = 'TANITICI'          iv_text = 'Tanıtıcı' ).
    set_column_text( iv_fname = 'BAKIYE'            iv_text = 'Bakiye' ).
    set_column_text( iv_fname = 'WAERS'             iv_text = 'Para Birimi' ).
    set_column_text( iv_fname = 'UPB_BAKIYE'        iv_text = 'UPB Bakiye' ).
    set_column_text( iv_fname = 'UPB_WAERS'         iv_text = 'UPB Para Bir.' ).
    set_column_text( iv_fname = 'TANIM'             iv_text = 'Borç/Alacak' ).
    set_column_text( iv_fname = 'MUTABAKAT_DRM'     iv_text = 'Mut. Kodu' ).
    set_column_text( iv_fname = 'MUTABAKAT_DRM_DTL' iv_text = 'Mutabakat Durumu' ).
    set_column_text( iv_fname = 'STATUS_ICON'       iv_text = 'Durum' ).
    set_column_text( iv_fname = 'ACIKLAMA'          iv_text = 'Açıklama' ).
    set_column_text( iv_fname = 'DETAY'             iv_text = 'Detay' ).

* ---- MANDT sütununu gizle ----
    TRY.
        DATA(lo_col_mandt) = CAST cl_salv_column_table(
                               mo_columns->get_column( 'MANDT' ) ).
        lo_col_mandt->set_visible( abap_false ).
      CATCH cx_salv_not_found. " MANDT yapıda yoksa sorun yok
    ENDTRY.
  ENDMETHOD.                "set_alv_properties

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
         MESSAGE mo_exp_msg->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.                 "set_column_text

  METHOD set_sort.
    TRY.
        mo_sorts->add_sort( columnname = iv_col
                            sequence   = iv_seq
                            subtotal   = iv_subt ).
     CATCH cx_salv_not_found .
        MESSAGE mo_exp_msg->get_text( ) TYPE 'E'.
      CATCH cx_salv_existing .
        MESSAGE mo_exp_msg->get_text( ) TYPE 'E'.
      CATCH cx_salv_data_error .
        MESSAGE mo_exp_msg->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.                 "set_sort

  METHOD on_user_command.
    CASE e_salv_function.
      WHEN '&MTB'.    " PF-status’te tanımlı email butonunun function code’u
        me->handle_email_button( ).
      WHEN 'EXCEL'.
        mo_alv->refresh( ).
      WHEN OTHERS.
        " Diğer işlemler
    ENDCASE.
  ENDMETHOD.                 "on_user_command

  METHOD configure_salv.
    DATA: lo_columns TYPE REF TO cl_salv_columns_table,
          lo_column  TYPE REF TO cl_salv_column_table.

    lo_columns = mo_alv->get_columns( ).

    TRY.
        " 'DETAY' sütununu al ve HOTSPOT olarak ayarla
        lo_column = CAST cl_salv_column_table( lo_columns->get_column( TEXT-018 ) ).      "cast üst sınıf nesneyi alt sınıfa dönüşümünü sağlar.
        lo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
        lo_column->set_medium_text( TEXT-019 ).
      CATCH cx_salv_not_found.
        RETURN.
    ENDTRY.

    mo_events = mo_alv->get_event( ).
    SET HANDLER go_agreement->on_link_click FOR mo_events.
  ENDMETHOD.                 "configure_salv

  METHOD on_link_click.
    DATA: ls_selected_local TYPE zmdik_str.
    " Tıklanan satırın indeksine göre kaydı mt_list'ten al
    READ TABLE mt_list INTO ls_selected_local INDEX row.
    IF sy-subrc <> 0.
      MESSAGE TEXT-020 TYPE TEXT-021.
      RETURN.
    ENDIF.

    gs_selected = ls_selected_local.

    CLEAR gt_bapi_data.
    CALL FUNCTION 'BAPI_AR_ACC_GETOPENITEMS'
      EXPORTING
        companycode = mv_bukrs
        customer    = gs_selected-kunnr
        keydate     = mv_date
      TABLES
        lineitems   = gt_bapi_data.

    CLEAR gt_display.
    LOOP AT gt_bapi_data INTO gs_bapi_data.
      CLEAR gs_display.
      gs_display-doc_date   = gs_bapi_data-doc_date.
      gs_display-doc_type   = gs_bapi_data-doc_type.
      gs_display-item_text  = gs_bapi_data-item_text.
      gs_display-ref_doc_no = gs_bapi_data-ref_doc_no.
      gs_display-db_cr_ind  = gs_bapi_data-db_cr_ind.
      gs_display-lc_amount  = gs_bapi_data-lc_amount.
      gs_display-currency   = gs_bapi_data-currency.
      APPEND gs_display TO gt_display.
    ENDLOOP.
    " Detay pop-up gösterimi (mevcut kodunuz)
    DATA: lr_popup     TYPE REF TO cl_salv_table,
          lr_functions TYPE REF TO cl_salv_functions.
    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lr_popup
          CHANGING  t_table      = gt_display ).

        lr_popup->set_screen_popup(
          start_column = 10
          end_column   = 120
          start_line   = 5
          end_line     = 25 ).

        lr_functions = lr_popup->get_functions( ).
        lr_functions->set_all( abap_true ).

        lr_popup->display( ).
      CATCH cx_salv_msg INTO DATA(lx_popup).
        MESSAGE lx_popup->get_text( ) TYPE TEXT-021.
    ENDTRY.
  ENDMETHOD.                 "on_link_click

  METHOD handle_email_button.
    DATA: lt_sel_rows TYPE STANDARD TABLE OF i,
          lv_row      TYPE i,
          gv_answer   TYPE c.

    CLEAR gt_selected. " gt_selected: global tablo, tip: STANDARD TABLE OF ZMDIK_STR

    " ALV seçim bilgisini al
    DATA(loSel) = mo_alv->get_Selections( ).          "alv deki seçim bilgileri
    lt_sel_rows = loSel->get_Selected_Rows( ).          "kullanıcının hangi satırı seçtiği
    IF lt_sel_rows IS INITIAL.
      MESSAGE TEXT-057 TYPE 'E'.
      RETURN.
    ENDIF.

    " Her seçili satır için mt_list içerisindeki kaydı ve aynı grup (KUNNR, GJAHR, MONAT) değerlerine sahip diğer satırları gt_selected'e ekle
    LOOP AT lt_sel_rows INTO lv_row.
      READ TABLE mt_list INTO DATA(ls_main) INDEX lv_row.
      IF sy-subrc = 0.
        me->add_to_gt_selected( ps_row = ls_main ).
        " Aynı grup için diğer kayıtları da ekle:
        LOOP AT mt_list INTO DATA(ls_check).
          IF ls_check-kunnr = ls_main-kunnr
             AND ls_check-gjahr = ls_main-gjahr
             AND ls_check-monat = ls_main-monat
             AND ls_check <> ls_main.
            me->add_to_gt_selected( ps_row = ls_check ).
          ENDIF.
        ENDLOOP.
      ELSE.
        MESSAGE TEXT-058 TYPE 'E'.
      ENDIF.
    ENDLOOP.

    " Kullanıcı onayını al
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = TEXT-060
        text_question         = TEXT-059
        text_button_1         = TEXT-024
        text_button_2         = TEXT-025
        default_button        = '2'
        display_cancel_button = 'X'
      IMPORTING
        answer                = gv_answer.
    IF gv_answer = '1'.
      me->update_reconciliation( ).
      me->send_reconciliation_email( ).
      CLEAR mt_list. me->get_data( ). SORT mt_list ASCENDING BY kunnr.
      mo_alv->refresh( ).
    ELSE.
      MESSAGE TEXT-061 TYPE 'I'.
    ENDIF.
  ENDMETHOD.


  METHOD add_to_gt_selected.
    " Aynı kaydı tekrar eklememek için basit kontrol
    FIELD-SYMBOLS <fs_sel> TYPE zmdik_str.
    LOOP AT gt_selected ASSIGNING <fs_sel>
      WHERE kunnr = ps_row-kunnr
        AND gjahr = ps_row-gjahr
        AND monat = ps_row-monat
        AND upb_bakiye = ps_row-upb_bakiye
        " Diğer karşılaştırılacak alanlar varsa ekleyin (örneğin, OEDK, NAME1 vb.)
      .
      RETURN. " Kayıt zaten eklenmişse çık
    ENDLOOP.
    APPEND ps_row TO gt_selected.
  ENDMETHOD.




  METHOD update_reconciliation.
    DATA: lv_id     TYPE zmdik_mutabakat4-id,
          lv_number TYPE num10,
          ls_record TYPE zmdik_mutabakat4.

    IF gt_selected IS INITIAL.
      MESSAGE TEXT-062 TYPE 'E'.
      RETURN.
    ENDIF.

    " gt_selected içindeki kayıtları, (KUNNR, GJAHR, MONAT) bazında gruplamak için sıralıyoruz.
    DATA: lt_sorted TYPE STANDARD TABLE OF zmdik_str.
    lt_sorted = gt_selected.
    SORT lt_sorted BY kunnr gjahr monat.

    DATA: lv_group_key TYPE string,
          lv_old_key   TYPE string.
##INTO_OK
    LOOP AT lt_sorted INTO DATA(ls_sel).
      " Grup anahtarını oluşturuyoruz: KUNNR_GJAHR_MONAT
      lv_group_key = |{ ls_sel-kunnr }_{ ls_sel-gjahr }_{ ls_sel-monat }|.

      IF lv_group_key <> lv_old_key.
        " Yeni grup başlıyor: bu grup için ZMDIK_MUTABAKAT4 tablosunda zaten kayıt var mı diye kontrol ediyoruz
        ##WARN_OK
        SELECT SINGLE id INTO @lv_id
          FROM zmdik_mutabakat4
          WHERE kunnr = @ls_sel-kunnr
            AND gjahr = @ls_sel-gjahr
            AND monat = @ls_sel-monat
            AND bukrs = @mv_bukrs.
        IF sy-subrc <> 0.
          " Eğer grup için kayıt yoksa, NUMBER_GET_NEXT ile yeni ID alıyoruz
          CALL FUNCTION 'NUMBER_GET_NEXT'
            EXPORTING
              nr_range_nr = '01'
              object      = 'ZMDIK_001'
            IMPORTING
              number      = lv_number
            EXCEPTIONS
              OTHERS      = 1.
          IF sy-subrc = 0.
            lv_id = lv_number.
          ELSE.
            MESSAGE TEXT-063 TYPE 'E'.
            CONTINUE.
          ENDIF.
        ENDIF.
        lv_old_key = lv_group_key.
      ENDIF.

      " Her kayıt için, manuel olarak alan eşleştirmesi yapıyoruz.
      CLEAR ls_record.
      ls_record-id                = lv_id.                         " Grup ID'si
      ls_record-kunnr             = ls_sel-kunnr.
      ls_record-gjahr             = ls_sel-gjahr.
      ls_record-monat             = ls_sel-monat.
      ls_record-bukrs             = mv_bukrs.                      " Global değer
      ls_record-stcd1             = ls_sel-stcd1.
      ls_record-stceg             = ls_sel-stceg.
      ls_record-land1             = ls_sel-land1.
      ls_record-customer_balance  = ls_sel-bakiye.                " BAKIYE → CUSTOMER_BALANCE
      ls_record-oedk_balance      = ls_sel-upb_bakiye.              " UPB_BAKIYE → OEDK_BALANCE
      ls_record-oedk              = ls_sel-oedk.
      ls_record-balance           = ls_sel-bakiye.
      ls_record-waers             = ls_sel-waers.
      ls_record-upb_balance       = ls_sel-upb_bakiye.              " UPB_BAKIYE → UPB_BALANCE
      ls_record-upb_waers         = ls_sel-upb_waers.
      ls_record-agreement_sts     = ls_sel-mutabakat_drm.           " MUTABAKAT_DRM → AGREEMENT_STS
      ls_record-description       = ls_sel-aciklama.                " ACIKLAMA → DESCRIPTION

      " Her kaydı, OEDK alanı da kontrol edilerek ayrı ayrı INSERT/UPDATE yapıyoruz:
      ##WARN_OK
      ##NEEDED
      SELECT SINGLE id INTO @DATA(lv_check)
        FROM zmdik_mutabakat4
        WHERE kunnr = @ls_sel-kunnr
          AND gjahr = @ls_sel-gjahr
          AND monat = @ls_sel-monat
          AND bukrs = @mv_bukrs
          AND oedk  = @ls_sel-oedk.
      IF sy-subrc = 0.
        UPDATE zmdik_mutabakat4 FROM ls_record.
      ELSE.
        ls_record-agreement_sts = TEXT-010.
        INSERT zmdik_mutabakat4 FROM ls_record.
      ENDIF.
    ENDLOOP.

    COMMIT WORK.
    MESSAGE TEXT-064 TYPE 'S'.
  ENDMETHOD.




  METHOD send_reconciliation_email.
    DATA: lt_text_lines TYPE STANDARD TABLE OF tline,
          ls_text_line  TYPE tline,
          lv_template   TYPE string,
          lv_mail_text  TYPE string,
          lt_sorted     TYPE STANDARD TABLE OF zmdik_str,
          ls_sel        TYPE zmdik_str,
          lv_group_key  TYPE string,
          lv_old_key    TYPE string,
          lv_table_rows TYPE string,
          lv_rec_id     TYPE num10,
          " Bir önceki grubun bilgilerini saklamak için
          lv_old_kunnr  TYPE kna1-kunnr,
          lv_old_gjahr  TYPE gjahr,
          lv_old_monat  TYPE monat,
          lv_old_name1  TYPE kna1-name1,
          " Mutabık değil durumu
          lv_has_notok  TYPE abap_bool.

    IF gt_selected IS INITIAL.
      MESSAGE TEXT-062 TYPE 'I'.
      RETURN.
    ENDIF.

    " 1) SO10 şablonunu oku
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client    = sy-mandt
        id        = 'ST'
        language  = sy-langu
        name      = 'ZMDIK_TXT001'
        object    = 'TEXT'
      TABLES
        lines     = lt_text_lines
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      MESSAGE TEXT-065 TYPE 'E'.
      RETURN.
    ENDIF.

    CLEAR lv_template.
    ##INTO_OK
    LOOP AT lt_text_lines INTO ls_text_line.
      CONCATENATE lv_template ls_text_line-tdline INTO lv_template
        SEPARATED BY cl_abap_char_utilities=>newline.
    ENDLOOP.

    " 2) KUNNR, GJAHR, MONAT bazında sırala
    lt_sorted = gt_selected.
    SORT lt_sorted BY kunnr gjahr monat.

    CLEAR: lv_old_key, lv_table_rows, lv_mail_text.

    ##INTO_OK
    LOOP AT lt_sorted INTO ls_sel.
      lv_group_key = |{ ls_sel-kunnr }_{ ls_sel-gjahr }_{ ls_sel-monat }|.

      IF lv_group_key <> lv_old_key.
        " Yeni grup başlamadan önce, önceki grubun mailini gönder
        IF lv_old_key IS NOT INITIAL.
          ##WARN_OK
          SELECT SINGLE id INTO @lv_rec_id
            FROM zmdik_mutabakat4
            WHERE kunnr = @lv_old_kunnr
              AND gjahr = @lv_old_gjahr
              AND monat = @lv_old_monat
              AND bukrs = @mv_bukrs.
          gv_subject = |Mutabakat - { lv_old_name1 } - { lv_old_gjahr }/{ lv_old_monat }|.
          lv_mail_text = lv_template.
          REPLACE ALL OCCURRENCES OF '&SUBJECT' IN lv_mail_text WITH gv_subject.
          REPLACE ALL OCCURRENCES OF '&NAME'    IN lv_mail_text WITH lv_old_name1.
          REPLACE ALL OCCURRENCES OF '&ID'      IN lv_mail_text WITH lv_rec_id.
          REPLACE '&TABLE_CONTENT' IN lv_mail_text WITH lv_table_rows.
          me->send_group_mail(
            iv_kunnr     = lv_old_kunnr
            iv_mail_text = lv_mail_text
            iv_rows      = lv_table_rows
            iv_has_notok = lv_has_notok ).
          CLEAR: lv_table_rows, lv_has_notok.
        ENDIF.
        " Yeni grubun bilgilerini kaydet
        lv_old_key   = lv_group_key.
        lv_old_kunnr = ls_sel-kunnr.
        lv_old_gjahr = ls_sel-gjahr.
        lv_old_monat = ls_sel-monat.
        lv_old_name1 = ls_sel-name1.
      ENDIF.

      " Mutabık değil satır var mı?
      IF ls_sel-mutabakat_drm = TEXT-011.  " 'B' = Mutabık Değil
        lv_has_notok = abap_true.
      ENDIF.

      " HTML tablo satırı – SO10 şablonundaki 3 sütunla eşleşiyor
      DATA(lv_tr) = |<tr>|
        & |<td>{ ls_sel-tanitici } { ls_sel-oedk_txt }</td>|
        & |<td align="right">{ ls_sel-upb_bakiye }</td>|
        & |<td>{ ls_sel-upb_waers }</td>|
        & |</tr>|.
      CONCATENATE lv_table_rows lv_tr INTO lv_table_rows
        SEPARATED BY cl_abap_char_utilities=>newline.
    ENDLOOP.

    " Son grup için mail gönder
    IF lv_table_rows IS NOT INITIAL.
      ##WARN_OK
      SELECT SINGLE id INTO @lv_rec_id
        FROM zmdik_mutabakat4
        WHERE kunnr = @lv_old_kunnr
          AND gjahr = @lv_old_gjahr
          AND monat = @lv_old_monat
          AND bukrs = @mv_bukrs.
      gv_subject = |Mutabakat - { lv_old_name1 } - { lv_old_gjahr }/{ lv_old_monat }|.
      lv_mail_text = lv_template.
      REPLACE ALL OCCURRENCES OF '&SUBJECT' IN lv_mail_text WITH gv_subject.
      REPLACE ALL OCCURRENCES OF '&NAME'    IN lv_mail_text WITH lv_old_name1.
      REPLACE ALL OCCURRENCES OF '&ID'      IN lv_mail_text WITH lv_rec_id.
      REPLACE '&TABLE_CONTENT' IN lv_mail_text WITH lv_table_rows.
      me->send_group_mail(
        iv_kunnr     = lv_old_kunnr
        iv_mail_text = lv_mail_text
        iv_rows      = lv_table_rows
        iv_has_notok = lv_has_notok ).
    ENDIF.
  ENDMETHOD.



  METHOD send_group_mail.
    " Parametreler: iv_mail_text (HTML şablonu), iv_rows (tablo satırları),
    " iv_has_notok (mutabık değil satır var mı? -> Excel eki ekle)
    DATA: lo_bcs       TYPE REF TO cl_bcs,
          lo_doc       TYPE REF TO cl_document_bcs,
          lo_recipient TYPE REF TO if_recipient_bcs,
          lt_body      TYPE bcsy_text,
          lv_mail      TYPE string,
          lt_lines     TYPE TABLE OF string,
          lv_line      TYPE string,
          lt_emails    TYPE TABLE OF zmdik_mail_tablo,
          ls_email     TYPE zmdik_mail_tablo,
          lx_bcs       TYPE REF TO cx_bcs.

    " Placeholder'ları doldur
    lv_mail = iv_mail_text.
    REPLACE '&TABLE_CONTENT' IN lv_mail WITH iv_rows.

    " String'i satırlara böl
    SPLIT lv_mail AT cl_abap_char_utilities=>newline INTO TABLE lt_lines.
    LOOP AT lt_lines INTO lv_line.
      APPEND lv_line TO lt_body.
    ENDLOOP.

    TRY.
        " BCS gönderim isteği
        lo_bcs = cl_bcs=>create_persistent( ).

        " HTML doküman oluştur
        lo_doc = cl_document_bcs=>create_document(
                   i_type    = 'HTM'
                   i_subject = gv_subject
                   i_text    = lt_body ).

        " Mutabık değil durumunda Excel eki ekle
        IF iv_has_notok = abap_true.
          DATA: lv_excel_str TYPE string,
                lv_xstr      TYPE xstring,
                lt_excel_bin TYPE solix_tab,
                lv_att_size  TYPE i.

          " HTML tablo formatında Excel içeriği oluştur
          lv_excel_str =
            |<html><head><meta charset="UTF-8"/></head><body>|
            & |<h2>Mutabakat Detayı - { gv_subject }</h2>|
            & |<table border="1" cellpadding="4" cellspacing="0">|
            & |<tr>|
            & |<th>Tanıtıcı</th>|
            & |<th>ÖDK Metni</th>|
            & |<th>Bakiye</th>|
            & |<th>Para Birimi</th>|
            & |<th>UPB Bakiye</th>|
            & |<th>UPB Para Bir.</th>|
            & |<th>Mutabakat Durumu</th>|
            & |</tr>|
            & |iv_rows|
            & |</table></body></html>|.

          " String -> xstring (UTF-8)
          CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
            EXPORTING
              text     = lv_excel_str
            IMPORTING
              buffer   = lv_xstr
            EXCEPTIONS
              OTHERS   = 1.
          IF sy-subrc = 0.
            CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
              EXPORTING
                buffer        = lv_xstr
              IMPORTING
                output_length = lv_att_size
              TABLES
                binary_tab    = lt_excel_bin.
            lo_doc->add_attachment(
              i_attachment_type    = 'XLS'
              i_attachment_subject =
                |Mutabakat_Detay_{ sy-datum }.xls|
              i_att_content_hex    = lt_excel_bin ).
          ENDIF.
        ENDIF.

        lo_bcs->set_document( lo_doc ).

        " Alıcıları ekle – yalnızca seçili müşterinin e-posta adresi
        SELECT * FROM zmdik_mail_tablo
          INTO TABLE @lt_emails
          WHERE kunnr = @iv_kunnr.
        IF lt_emails IS INITIAL.
          " Müşteriye özel kayıt yoksa genel (kunnr boş) kayıtları al
          SELECT * FROM zmdik_mail_tablo
            INTO TABLE @lt_emails
            WHERE kunnr = @space.
        ENDIF.
        LOOP AT lt_emails INTO ls_email.
          IF ls_email-email IS NOT INITIAL.
            lo_recipient =
              cl_cam_address_bcs=>create_internet_address(
                ls_email-email ).
            lo_bcs->add_recipient( lo_recipient ).
          ENDIF.
        ENDLOOP.

        lo_bcs->send( i_with_error_screen = abap_false ).
        COMMIT WORK.
        MESSAGE TEXT-066 TYPE 'S'.

      CATCH cx_bcs INTO lx_bcs.
        MESSAGE lx_bcs->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.
##NEEDED
  METHOD on_after_user_command.
*
  ENDMETHOD.                "on_user_command

  METHOD counter.
    DESCRIBE TABLE mt_list LINES iv_count.
  ENDMETHOD.                "counter



ENDCLASS.
