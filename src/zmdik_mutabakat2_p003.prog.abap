*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTABAKAT2_P003
*&---------------------------------------------------------------------*

class lcl_report definition.
  public section.
    methods:
      init_alv,
      get_data,
      set_layo,
      set_fcat,
      display_alv,
      handle_hotspot_click                    "HOTSPOT_CLICK
      for event hotspot_click of cl_gui_alv_grid
      importing
        e_row_id
        e_column_id,

        handle_toolbar                       "TOOLBAR
      for event toolbar of cl_gui_alv_grid
      importing
        e_object
        e_interactive,

      set_lineitems,
      display_salv,



      handle_user_command                  "USER_COMMAND
      for event user_command of cl_gui_alv_grid
      importing
        e_ucomm,

      send_mail.
endclass.





class lcl_report implementation.
  method init_alv.
    call method: get_data,
                 handle_hotspot_click,
                 handle_toolbar,
                 handle_user_command,                  "USER_COMMAND
                 set_layo,
                 set_fcat,
                 display_alv.
    ENDMETHOD.
method handle_hotspot_click.
    gv_salv_index = e_row_id-index.
*    call method go_lcl_report->display_salv .
  endmethod.

method handle_toolbar.
    data: ls_toolbar type stb_button.

*    clear ls_toolbar.
*    ls_toolbar-function  = '&SEND_MAIL'.         "sy-ucomm ile yakalanan obje
*    ls_toolbar-text      = 'Mutabakat Gönder'.
*    ls_toolbar-icon      = '@1S@'.
*    ls_toolbar-quickinfo = 'Send Mail'.
*    ls_toolbar-disabled  = abap_false.
*    append ls_toolbar to e_object->mt_toolbar.
  endmethod.


  method handle_user_command.
    case e_ucomm.
      when '&SEND_MAIL'.
*        data: lt_rows  type lvc_t_row,
*              ls_row   type lvc_s_row,
*              lv_index type sy-tabix.
*
*        call method go_grid->get_selected_rows
*          importing
*            et_index_rows = lt_rows.
*
*        loop at lt_rows into ls_row.
*          read table gt_data into data(wa_data) index ls_row-index.
*          if sy-subrc eq 0.
*            wa_data-selkz = 'X'.
*            modify gt_data from wa_data index ls_row-index.
*          endif.
*        endloop.
*        call method go_lcl_report->send_mail.
*        go_grid->refresh_table_display( ).
**        modify zcust_rec from wa_data.
    endcase.
  endmethod.











    method get_data.

        data: gt_kna1 type table of kna1,
          gt_cust type table of gty_data.





    SELECT  kunnr                 "müşteri bilgilerini kna1 tablosundan çekiyoruz.
    FROM kna1
    INTO CORRESPONDING FIELDS OF TABLE gt_kna1
    WHERE kunnr in s_kunnr.


 loop at gt_kna1 into data(gs_kna1).
      select * from zmdik_mutakabat
        into corresponding fields of table gt_cust
        where kunnr eq gs_kna1-kunnr.


        if gt_cust is initial.
        select single email from zcust_mail
          into gv_email where kunnr eq gs_kna1-kunnr.

          select single butxt from t001
          into gv_butxt where bukrs eq p_bukrs.


    call function 'BAPI_AR_ACC_GETKEYDATEBALANCE'
          exporting
            companycode  = p_bukrs
            customer     = gs_kna1-kunnr
            keydate      = p_datum
            balancespgli = 'X'
            noteditems   = ''
          tables
            keybalance   = gt_bapi.


    LOOP AT gt_bapi INTO gs_bapi.
       clear gs_bapi.
                                        "mutabakat kaydı oluşturuyoruz ve müşteri bilgilerini içine atıyoruz.
      gs_data-kunnr = gs_kna1-kunnr.
*      gs_data-name1 = ls_kna1-name1.
*      gs_data-detay = '@16@'.


      gs_data-bukrs = p_bukrs.
      gs_data-tarih = p_datum.
      gs_data-yil = p_datum+0(4).
      gs_data-ay = p_datum+4(2).
      gs_data-smtp_addr = 'Mdik_38@gmail.com'.
      gs_data-y_kisi = sy-uname.
       gs_data-mutabat_durum = 'A'.

      gs_data-borc_alacak = gs_bapi-db_cr_ind.

      IF gs_data-borc_alacak EQ 'H'.                       "müşterinin borç mu yoksa alacak mı olduğunun kontrolünü yapıyoruz.
        gs_data-borc_alacak_text = 'ALACAK'.
      ELSE.
        gs_data-borc_alacak_text = 'BORÇ'.
      ENDIF.
      gs_data-odk_text = gs_bapi-sp_gl_ind.
      IF gs_data-odk_text EQ 'A'.
      ENDIF.
      gs_data-musteri_bakiye = gs_bapi-lc_bal.
      gs_data-musteri_bakiyepb2 = gs_bapi-currency.
      gs_data-upb_bakiye = gs_bapi-t_curr_bal.
      gs_data-upb_para_birimi = gs_bapi-loc_currcy.
      IF gs_bapi-sp_gl_ind IS NOT INITIAL.
        gs_data-odk_gost = gs_bapi-sp_gl_ind.
        SELECT SINGLE ltext FROM t074t INTO gs_data-ktext
        WHERE koart = 'D' AND shbkz = gs_bapi-sp_gl_ind AND spras = 'T'.
        gs_data-intro_text = 'Müşteri ÖDK Bakiyesi' .
      ELSE.
        gs_data-intro_text = 'Müşteri Bakiyesi'.
      ENDIF.


      select single * from kna1
            into corresponding fields of gs_data
            where kunnr eq gs_kna1-kunnr.
          append gs_data to gt_data.
    ENDLOOP.

else.
        loop at gt_cust into data(wa_cust).
          append wa_cust to gt_data.
        endloop.
        clear: gt_cust, wa_cust.
      endif.
    endloop.
  endmethod.





   method set_layo.
    gs_layo-cwidth_opt = abap_true.
    gs_layo-zebra      = abap_true.
    gs_layo-sel_mode   = 'D'.
  endmethod.



   method set_fcat.

  PERFORM set_fcat_sub USING 'KUNNR'               'Müşteri Numarası'.        "Sütun başlıklarını belirliyoruz.
  PERFORM set_fcat_sub USING 'YIL'                 'Yıl'.
  PERFORM set_fcat_sub USING 'AY'                  'Ay'.
  PERFORM set_fcat_sub USING 'STCD1'               'Vergi Numarası'.
  PERFORM set_fcat_sub USING 'NAME1'               'Ad'.
  PERFORM set_fcat_sub USING 'VERGI_DAIRE'         'KDV Tanıtıcı No'.
  PERFORM set_fcat_sub USING 'ULKE'                'Ülke Anahtarı'.
  PERFORM set_fcat_sub USING 'TANITICI_METIN'      'Tanıtıcı Metin'.
  PERFORM set_fcat_sub USING 'ODK_GOST'            'ÖDK Göstergesi'.
  PERFORM set_fcat_sub USING 'KTEXT'               'ÖDK Açıklama'.
  PERFORM set_fcat_sub USING 'BORC_ALACAK'         'B/A'.
  PERFORM set_fcat_sub USING 'BORC_ALACAK_TEXT'    'B/A Text'.
  PERFORM set_fcat_sub USING 'MUSTERI_BAKIYE'      'Bakiye'.
  PERFORM set_fcat_sub USING 'MUSTERI_BAKIYEPB2'   'Bakiye PB'.
  PERFORM set_fcat_sub USING 'UPB_BAKIYE'          'UPB Bakiye'.
  PERFORM set_fcat_sub USING 'UPB_PARA_BIRIMI'     'UBP PB'.
  PERFORM set_fcat_sub USING 'DETAY'               'Detay'.
  PERFORM set_fcat_sub USING 'MUTABAT_DURUM'       'Mutabık Durumu'.
  PERFORM set_fcat_sub USING 'MTB_DURUM_ACIKLA'    'Açıklama'.


  LOOP AT gt_fcat INTO gs_fcat.

    IF gs_fcat-fieldname = 'DETAY'.
      gs_fcat-hotspot = abap_true.  " Alanı hotspot yapar (Tıklanabilir)
    ENDIF.
    MODIFY gt_fcat FROM gs_fcat.

  ENDLOOP.
  ENDMETHOD.



method display_alv.
    if go_grid is initial.

      create object go_grid
        exporting
          i_parent = cl_gui_container=>screen0.


      go_grid->set_table_for_first_display(
        exporting
          is_layout                     = gs_layo
        changing
          it_outtab                     = gt_data
          it_fieldcatalog               = gt_fcat ).

      call method go_grid->register_edit_event
        exporting
          i_event_id = cl_gui_alv_grid=>mc_evt_enter.
    else.
      call method go_grid->refresh_table_display.
    endif.
  endmethod.




method display_salv.
    data: lo_salv  type ref to cl_salv_table.

    call method go_lcl_report->set_lineitems.

    cl_salv_table=>factory(
      importing
        r_salv_table   = lo_salv
      changing
        t_table        = gt_lineitems[]
        ).

    "popup
    lo_salv->set_screen_popup(
      exporting
        start_column = 20
        end_column   = 100
        start_line   = 5
        end_line     = 20
    ).
    lo_salv->display( ).
  endmethod.









   method set_lineitems.
    data: lt_lt type table of bapi3007_2.

    read table gt_data into data(wa_data) index gv_salv_index.

    call function 'BAPI_AR_ACC_GETOPENITEMS'
      exporting
        companycode = p_bukrs
        customer    = wa_data-kunnr
        keydate     = p_datum
      tables
        lineitems   = lt_lt.

    loop at lt_lt into data(gs_lt).
      gs_lineitems-doc_date   = gs_lt-doc_date.
      gs_lineitems-doc_type   = gs_lt-doc_type.
      gs_lineitems-item_text  = gs_lt-post_key.
      gs_lineitems-ref_doc_no = gs_lt-ref_doc_no.
      gs_lineitems-db_cr_ind  = gs_lt-db_cr_ind.
      gs_lineitems-currency   = gs_lt-currency.

      select single ltext from tbslt
        into gs_lineitems-text
        where spras = 'T'           and
              umskz = gs_data-mutabat_durum and
              bschl = gs_lt-post_key.

      append gs_lineitems to gt_lineitems.
    endloop.
  endmethod.





   method send_mail.
    data: lo_gbt       type ref to cl_gbt_multirelated_service,
          lo_bcs       type ref to cl_bcs,
          lo_doc_bcs   type ref to cl_document_bcs,
          lo_recipient type ref to if_recipient_bcs,
          lt_soli      type table of soli,
          lv_soli      type soli,
          lv_status    type bcs_rqst,
          lv_content   type string.

    data lv_lines type i.
    describe table gt_data lines lv_lines.

    read table gt_data into data(wa_data) with key selkz = 'X'.

    if lo_gbt is initial.
      create object lo_gbt.
    endif.

    lv_content =  '<!DOCTYPE html>                            '
            && '<html>                                      '
            && '  <head>                                    '
            && '      <meta charset="utf-8">                '
            && '        <style type="text/css">             '
            && '          p{                                '
            && '              border: 1pxsolid;             '
            && '           }                                '
            && '        </style>                            '
            && '  </head>                                   '
            && '                                            '
            && '  <body>                                    '
            && '    <p>Mutabakat  :' && wa_data-yil && '-' && wa_data-ay && '  </p> '
            && '    <p>Sayın, ' && wa_data-name1 && ' </p>            '
            && '    <p>Karşılıklı mutabakat sağlanması için firmanıza ait alış/satış bilgilerimiz </p> '
            && '    <p>aşağıda gösterilmiştir. Eğer mutabık değilseniz firmanız kayıtlarında </p> '
            && '    <p>görünen fatura adedini ve tutarını belirtiniz. </p> '
            && '    <p>Saygılarımızla,</p> '
            && '    <p>UBP Tutar    : ' && wa_data-upb_bakiye && '</p>'
            && '    <p>Para Birimi  : ' && wa_data-upb_para_birimi && '</p>'
            && '    <p><a href="http://localhost:8080/">Mutabakat Formunu Görüntüle</a></p>'
            && '  </body>                                   '
            && '</html>                                     '.

    lt_soli = cl_document_bcs=>string_to_soli( lv_content ).

    call method lo_gbt->set_main_html
      exporting
        content = lt_soli.

    lo_doc_bcs = cl_document_bcs=>create_from_multirelated(
                   i_subject          = 'Mutabakat Raporu'
                   i_multirel_service = lo_gbt ).

    if gv_email is initial.
      select single email from zcust_mail
        into gv_email where kunnr eq wa_data-kunnr.
    endif.

    lo_recipient = cl_cam_address_bcs=>create_internet_address(
                     i_address_string = gv_email ).

    lo_bcs = cl_bcs=>create_persistent( ).
    lo_bcs->set_document( i_document = lo_doc_bcs ).
    lo_bcs->add_recipient( i_recipient = lo_recipient ).

    lv_status = 'N'.

    call method lo_bcs->set_status_attributes
      exporting
        i_requested_status = lv_status.

    lo_bcs->send( ).





    commit work.


  endmethod.
 ENDCLASS.
