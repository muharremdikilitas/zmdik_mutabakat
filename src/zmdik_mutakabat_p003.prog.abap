

*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTAKABAT_P003
*&---------------------------------------------------------------------*
*



START-OF-SELECTION.

  CALL FUNCTION 'BAPI_AR_ACC_GETKEYDATEBALANCE'         "Bu fonksiyon, SAP'deki müşteri bakiyesini getirir.
    EXPORTING
      companycode  = p_bukrs
      customer     = p_kunnr
      keydate      = p_datum
      balancespgli = 'X'
*     NOTEDITEMS   = ' '
* IMPORTING
*     RETURN       =
    TABLES
      keybalance   = gt_bapi.

  DATA: gt_lt TYPE TABLE OF bapi3007_2.
  CALL FUNCTION 'BAPI_AR_ACC_GETOPENITEMS'        "Bu fonksiyon, müşterinin açık hesap kalemlerini getirir.
    EXPORTING
      companycode = p_bukrs
      customer    = p_kunnr
      keydate     = p_datum
*     NOTEDITEMS  = ' '
*     SECINDEX    = ' '
* IMPORTING
*     RETURN      =
    TABLES
      lineitems   = gt_lt.



  DATA: lv_ulke TYPE land1.
  DATA: ls_kna1 TYPE kna1.


  SELECT SINGLE kunnr land1 stcd1 name1 stceg                 "müşteri bilgilerini kna1 tablosundan çekiyoruz.
    FROM kna1
    INTO CORRESPONDING FIELDS OF ls_kna1
    WHERE kunnr EQ p_kunnr.
  lv_ulke = ls_kna1-land1.


  CLEAR gs_bapi.
  DATA ls_mut TYPE zmdik_mutakabat.

  READ TABLE lt_mutabakat WITH  KEY kunnr = p_kunnr INTO ls_mut.        "müşteri için mutabakat kaydı olup olmadığını kontrol eder. Eğer müşteri için bir mutabakat kaydı yoksa, yeni bir kayıt oluşturulacak.



  IF ls_mut IS INITIAL.


    LOOP AT gt_bapi INTO gs_bapi.

      ls_mutabakat-ulke = lv_ulke.                            "mutabakat kaydı oluşturuyoruz ve müşteri bilgilerini içine atıyoruz.
      ls_mutabakat-kunnr = p_kunnr.
      ls_mutabakat-name1 = ls_kna1-name1.
      ls_mutabakat-detay = '@16@'.


      ls_mutabakat-bukrs = p_bukrs.
      ls_mutabakat-tarih = p_datum.
      ls_mutabakat-yil = p_datum+0(4).
      ls_mutabakat-ay = p_datum+4(2).
      ls_mutabakat-smtp_addr = 'Mdik_38@gmail.com'.
      ls_mutabakat-y_kisi = sy-uname.
       ls_mutabakat-mutabat_durum = 'A'.

      ls_mutabakat-borc_alacak = gs_bapi-db_cr_ind.

      IF ls_mutabakat-borc_alacak EQ 'H'.                       "müşterinin borç mu yoksa alacak mı olduğunun kontrolünü yapıyoruz.
        ls_mutabakat-borc_alacak_text = 'ALACAK'.
      ELSE.
        ls_mutabakat-borc_alacak_text = 'BORÇ'.
      ENDIF.
      ls_mutabakat-odk_text = gs_bapi-sp_gl_ind.
      IF ls_mutabakat-odk_text EQ 'A'.
      ENDIF.
      ls_mutabakat-musteri_bakiye = gs_bapi-lc_bal.
      ls_mutabakat-musteri_bakiyepb2 = gs_bapi-currency.
      ls_mutabakat-upb_bakiye = gs_bapi-t_curr_bal.
      ls_mutabakat-upb_para_birimi = gs_bapi-loc_currcy.
      IF gs_bapi-sp_gl_ind IS NOT INITIAL.
        ls_mutabakat-odk_gost = gs_bapi-sp_gl_ind.
        SELECT SINGLE ltext FROM t074t INTO ls_mutabakat-ktext
        WHERE koart = 'D' AND shbkz = gs_bapi-sp_gl_ind AND spras = 'T'.
        ls_mutabakat-intro_text = 'Müşteri ÖDK Bakiyesi' .
      ELSE.
        ls_mutabakat-intro_text = 'Müşteri Bakiyesi'.
      ENDIF.
      ls_mutabakat-detay  = icon_display_text.

      SELECT SINGLE email kunnr FROM zmdik_mail_tablo INTO CORRESPONDING FIELDS OF  gs_mail WHERE kunnr EQ p_kunnr.

      ls_mutabakat-mail = gs_mail-email.

      SELECT SINGLE butxt FROM t001 INTO CORRESPONDING FIELDS OF ls_mutabakat WHERE bukrs = p_bukrs.

      APPEND ls_mutabakat TO lt_mutabakat.
      CLEAR ls_mutabakat.
    ENDLOOP.


    MODIFY zmdik_mutakabat FROM TABLE lt_mutabakat.
  ENDIF.

  DATA : gt_it2 TYPE TABLE OF zmdik_mutakabat.
  SELECT * FROM zmdik_mutakabat INTO TABLE gt_it2.



  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'            ", ALV raporunda kullanılacak alan listesini oluşturuyoruz
    EXPORTING
      i_program_name     = sy-repid
*     I_INTERNAL_TABNAME = 'ZMDIK_STR_01'
      i_structure_name   = 'ZMDIK_STR_01'
*     I_CLIENT_NEVER_DISPLAY       = 'X'
      i_inclname         = sy-repid
      i_bypassing_buffer = 'X'
*     I_BUFFER_ACTIVE    =
    CHANGING
      ct_fieldcat        = gt_fcat2
* EXCEPTIONS
*     INCONSISTENT_INTERFACE       = 1
*     PROGRAM_ERROR      = 2
*     OTHERS             = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

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


  LOOP AT gt_fcat2 INTO gs_fcat2.

    IF gs_fcat2-fieldname = 'DETAY'.
      gs_fcat2-hotspot = abap_true.  " Alanı hotspot yapar (Tıklanabilir)
    ENDIF.
    MODIFY gt_fcat2 FROM gs_fcat2.

  ENDLOOP.






  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'                "ALV raporunu görüntülüyoruz.
    EXPORTING
      i_callback_program       = sy-repid
*     it_toolbar_excluding     = gt_toolbar
      i_callback_pf_status_set = 'PF_STATUS_SET'
      i_callback_user_command  = 'USER_COMMAND'
*     IS_LAYOUT                =
*     IT_FIELDCAT              = gt_fieldcat
      it_fieldcat              = gt_fcat2
*     IT_FIELDCAT              = gs_fcat2
    TABLES
*     t_outtab                 = lt_mutabakat
      t_outtab                 = gt_it2
*  EXCEPTIONS
*     PROGRAM_ERROR            = 1
*     OTHERS                   = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

FORM pf_status_set USING p_extab TYPE slis_t_extab.
  SET PF-STATUS 'STATUS_0001'.
ENDFORM.









FORM set_fcat_sub USING p_fieldname
                        p_seltext_l .
  CLEAR gs_fcat2.
  gs_fcat2-fieldname = p_fieldname.
  gs_fcat2-seltext_l = p_seltext_l.
  APPEND gs_fcat2 TO gt_fcat2.
ENDFORM.









FORM user_command USING p_ucomm     TYPE sy-ucomm                           "kullanıcı komutları işlemlerini yapıyoruz.
                          ps_selfield TYPE slis_selfield.


  CASE p_ucomm.
    WHEN '&MD'.
      PERFORM send_mail.

ps_selfield-refresh = 'X'.

    WHEN '&F03'.
      LEAVE TO SCREEN 0.
    WHEN '&IC1'.
      PERFORM display_salv USING ps_selfield.
  ENDCASE.
ENDFORM.
FORM display_salv USING ps_selfield TYPE slis_selfield.           "Detaylı açık hesap kalemlerini pop up ekranıo ile gösteriyoruz.
  DATA: lo_salv  TYPE REF TO cl_salv_table.

  PERFORM set_lineitems.

  cl_salv_table=>factory(
IMPORTING
  r_salv_table   = lo_salv
CHANGING
  t_table        = gt_lineitems[]
).

  "popup
  lo_salv->set_screen_popup(
    EXPORTING
      start_column = 20
      end_column   = 100
      start_line   = 5
      end_line     = 20
  ).
  lo_salv->display( ).
ENDFORM.

FORM set_lineitems.
  DATA: lt_lt TYPE TABLE OF bapi3007_2.
  CALL FUNCTION 'BAPI_AR_ACC_GETOPENITEMS'
    EXPORTING
      companycode = p_bukrs
      customer    = p_kunnr
      keydate     = p_datum
    TABLES
      lineitems   = lt_lt.

  LOOP AT lt_lt INTO DATA(gs_lt).
    gs_lineitems-doc_date = gs_lt-doc_date.
    gs_lineitems-doc_type  = gs_lt-doc_type.
    gs_lineitems-item_text = gs_lt-item_text.
    gs_lineitems-ref_doc_no = gs_lt-ref_doc_no.
    gs_lineitems-db_cr_ind = gs_lt-db_cr_ind.
    gs_lineitems-currency  = gs_lt-currency.
    APPEND gs_lineitems TO gt_lineitems.
  ENDLOOP.
ENDFORM.

FORM send_mail.                                                 "Mutabakat e postasını gönderiyoruz.

  DATA: lo_gbt       TYPE REF TO cl_gbt_multirelated_service,       "lo_gbt → HTML tabanlı içeriği çoklu ilişkili belge olarak oluşturmak için
        lo_bcs       TYPE REF TO cl_bcs,                        "SAP Business Communication Services kullanarak e-posta göndermek için
        lo_doc_bcs   TYPE REF TO cl_document_bcs,               "→ E-posta içeriği için belge nesnesi.
        lo_recipient TYPE REF TO if_recipient_bcs,              "E-postayı göndereceğimiz alıcıyı tanımlayan nesne.
        lt_soli      TYPE TABLE OF soli,                          "E-posta içeriğinin satır bazında saklanacağı tablo ve satır değişkenleri.
        lv_soli      TYPE soli,
        lv_status    TYPE bcs_rqst,                                 "Gönderilecek e-postanın durumu.
        lv_content   TYPE string,                                     " E-postanın HTML formatındaki içeriği
        lv_email     TYPE zmdik_mail_tablo-email.                     "Alıcının e-posta adresini saklayan değişken

  IF lo_gbt IS INITIAL.
    CREATE OBJECT lo_gbt.
  ENDIF.

  SELECT SINGLE email FROM zmdik_mail_tablo
    INTO lv_email
    WHERE kunnr EQ p_kunnr.

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
            && '    <p>Mutabakat  :' && ls_mutabakat-yil && '-' && ls_mutabakat-ay && '  </p> '
            && '    <p>Sayın Müşterimiz</p>            '
            && '    <p>Karşılıklı mutabakat sağlanması için firmanıza ait alış/satış bilgilerimiz </p> '
            && '    <p>aşağıda gösterilmiştir. Eğer mutabık değilseniz firmanız kayıtlarında </p> '
            && '    <p>görünen fatura adedini ve tutarını belirtiniz. </p> '
            && '    <p>Saygılarımızla,</p> '
            && '    <p>UBP Tutar    : ' && ls_mutabakat-upb_bakiye && '</p>'
            && '    <p>Para Birimi  : ' && ls_mutabakat-upb_para_birimi && '</p>'
            && '    <p><a href="https://www.google.com">Mutabakat Formunu Görüntüle</a></p>'
            && '  </body>                                   '
            && '</html>                                     '.

  lt_soli = cl_document_bcs=>string_to_soli( lv_content ).        "lv_content değişkenindeki HTML metni soli formatına çevriliyor ve lt_soli tablosuna ekleniyor.

  CALL METHOD lo_gbt->set_main_html                 "lt_soli içeriğini e-posta gövdesine yerleştiriyor.
    EXPORTING
      content = lt_soli.

  lo_doc_bcs = cl_document_bcs=>create_from_multirelated(         "E-posta için bir doküman nesnesi oluşturuyor
                 i_subject          = 'Mutabakat Raporu'
                 i_multirel_service = lo_gbt ).

  lo_recipient = cl_cam_address_bcs=>create_internet_address(     "Müşterinin e-posta adresiyle bir alıcı nesnesi oluşturuluyor.

                   i_address_string =  lv_email ).

  lo_bcs = cl_bcs=>create_persistent( ).                  " Yeni bir e-posta nesnesi (lo_bcs) oluşturuluyor
  lo_bcs->set_document( i_document = lo_doc_bcs ).          " E-posta içeriği (doküman) eklendi.
  lo_bcs->add_recipient( i_recipient = lo_recipient ).        "Alıcı eklendi.

  lv_status = 'N'.                                            "E-postanın gönderilme isteği başlatıldı.

  CALL METHOD lo_bcs->set_status_attributes                     " E-posta durum bilgisi ayarlandı.
    EXPORTING
      i_requested_status = lv_status.

  lo_bcs->send( ).                                                " E-posta gönderildi.

  COMMIT WORK.                                                    "Değişiklikleri kaydederek işlemi tamamlıyor

  IF sy-subrc EQ 0.

    MESSAGE 'Mail Gönderim Başarılı' TYPE 'I' DISPLAY LIKE 'S'.
  ENDIF  .


  PERFORM get_log_table.
ENDFORM.




FORM get_log_table .

  "Log tablosu veri kaydı
  SELECT mandt kullanici_id name tarih saat FROM zmdik_mtb_log INTO TABLE gt_listele.
  IF gt_listele IS NOT INITIAL.
    SORT gt_listele BY kullanici_id DESCENDING.
    READ TABLE gt_listele INTO gs_listele INDEX 1.
    gv_data = gs_listele-kullanici_id + 1.
  ELSE.
    gv_data = 1.
  ENDIF.

* Yeni kayıt oluştur
  CLEAR gs_listele.
  gs_listele-mandt = sy-mandt.
  gs_listele-kullanici_id  = gv_data.
  gs_listele-name  = sy-uname.
  gs_listele-saat  = sy-uzeit.
  gs_listele-tarih = sy-datum.

  INSERT INTO zmdik_mtb_log VALUES gs_listele.
ENDFORM.
