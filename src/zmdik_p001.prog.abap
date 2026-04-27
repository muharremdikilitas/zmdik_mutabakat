****&---------------------------------------------------------------------*
*** Report ZMDIK_P001
****&---------------------------------------------------------------------*
****&
****&---------------------------------------------------------------------*
REPORT ZMDIK_P001.
***
****data: sayi1 type i value 10,
***      sayi2 type i value 20,
***      toplam type string.
***toplam = sayi1 + sayi2.
***if toplam = 30.
***  WRITE: 'başarılı , toplamınız: ' , toplam.
***  else.
***    WRITE: 'başarısız'.
****    ENDIF.
**
**REPORT ZMDIK_P001.
**
***data: counter type i value 0.
*** while counter <= 10.
***WRITE: / counter.
***Add 1 to counter.
***endwhile.
**
**
**
**
***DATA: number         TYPE i,
***      formatted_text TYPE c LENGTH 10.
***
***DO 10 TIMES.
***  number = sy-index - 5.
***  IF number >= 0.
***    WRITE number TO formatted_text.
***    MESSAGE formatted_text TYPE 'I'.
***  ELSE.
***    WRITE number TO formatted_text NO-SIGN.
***    MESSAGE formatted_text TYPE 'I' DISPLAY LIKE 'E'.
***  ENDIF.
***ENDDO.
**
**
**
***DATA: num            TYPE n LENGTH 10 VALUE '123',
***      format_text TYPE c LENGTH 10.
***
***WRITE num TO format_text.
***MESSAGE format_text TYPE 'I'.
***WRITE num TO format_text NO-ZERO.
***MESSAGE format_text TYPE 'I'.
**
**WRITE : / 'Burak'  COLOR 1 INVERSE OFF,
**        / 'Mesut'  COLOR 1 INVERSE ON.
**
**
***DATA: counter TYPE i VALUE 1.
***WRITE 'Enter the limit:'.
***PARAMETERS : p_test TYPE i.
****READ VALUE counter.
***WHILE counter <= p_test.
***   WRITE: / counter.
***   counter = counter + 1.
***ENDWHILE.
**
**DATA: lv_counter TYPE i,
**      index type i value 10.
**
**DO 10 TIMES.
**  lv_counter = index.
**  index = index - 1.
**  IF lv_counter MOD 3 = 0.
**    WRITE: / lv_counter, '3’ün katıdır.'.
**  ELSE.
**    WRITE: / lv_counter, '3’ün katı değildir.'.
**  ENDIF.
**ENDDO.
**
**
**
**
*
*
*
*DATA: lt_textlines TYPE TABLE OF tline,
*      ls_textline  TYPE tline,
*      lv_fulltext  TYPE string.
*
*CALL FUNCTION 'READ_TEXT'
*  EXPORTING
*    id       = 'ST'
*    language = sy-langu
*    name     = 'ZMDIK_TXT001'
*    object   = 'TEXT'
*  TABLES
*    lines    = lt_textlines
*  EXCEPTIONS
*    not_found = 1
*    others    = 2.
*
*IF sy-subrc = 0.
*  LOOP AT lt_textlines INTO ls_textline.
*    CONCATENATE lv_fulltext ls_textline-tdline INTO lv_fulltext SEPARATED BY space.
*  ENDLOOP.
*  WRITE: lv_fulltext.
*ENDIF.
*
*
*
*
*DATA:
*      lt_mail_body  TYPE TABLE OF solisti1,  " Mail içeriği
*      ls_mail_body  TYPE solisti1,
*      lt_content    TYPE TABLE OF sopcklsti1, " Mail paketi
*      ls_content    TYPE sopcklsti1,
**      lt_textlines  TYPE TABLE OF tline,    " SO10'dan okunan metin
**      ls_textline   TYPE tline,
**      lv_fulltext   TYPE string,   " Metin birleştirme için
*      lv_sender     TYPE soextreci1-receiver, " Gönderen mail adresi
*      lt_recipients TYPE TABLE OF somlreci1,  " Alıcı listesi
*      ls_recipient  TYPE somlreci1,
*      lv_mail_subject TYPE so_obj_des, " E-posta konusu
*      lv_customer_email TYPE string.  " Alıcı e-posta
*
*" 1️⃣ SO10 METNİNİ OKU
*CALL FUNCTION 'READ_TEXT'
*  EXPORTING
*    id       = 'ST'
*    language = sy-langu
*    name     = 'ZMDIK_TXT001'  " SO10'daki metin adı
*    object   = 'TEXT'
*  TABLES
*    lines    = lt_textlines
*  EXCEPTIONS
*    not_found = 1
*    others    = 2.
*
*IF sy-subrc = 0.
*
*  LOOP AT lt_textlines INTO ls_textline.
*    CONCATENATE '<p>' ls_textline-tdline '</p>' INTO lv_fulltext.
*  ENDLOOP.
*
*  lv_mail_subject = 'Mutabakat Bildirimi'.
*
*  " 2️⃣ Mail İçeriğini Hazırla
*  ls_mail_body-line = lv_fulltext.
*  APPEND ls_mail_body TO lt_mail_body.
*
*  " 3️⃣ Alıcı Mail Adresini Ayarla (Gerçek Bir E-Posta Adresi Gir!)
*
*
*  ls_recipient-receiver = lv_customer_email.
*  ls_recipient-rec_type = 'U'. " Kullanıcı e-posta tipi (External User)
*  APPEND ls_recipient TO lt_recipients.
*
*  " 4️⃣ Mail Paketini Tanımla
*  CLEAR ls_content.
*  ls_content-doc_size = 1.
*  APPEND ls_content TO lt_content.
*
*  " 5️⃣ E-Posta Gönder
*  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
*    EXPORTING
*      document_data              = VALUE sodocchgi1( obj_name = 'Mutabakat'
*                                                     obj_descr = lv_mail_subject
*                                                     obj_langu = 'EN' ) " E-posta konusu
*      sender_address             = 'muharrem@mdp.com'  " GERÇEK BİR GÖNDERİCİ E-POSTASI YAZ!
*      sender_address_type        = 'INT'
*      commit_work                = 'X'
*    TABLES
*      packing_list               = lt_content
*      contents_txt               = lt_mail_body
*      receivers                  = lt_recipients
*    EXCEPTIONS
*      too_many_receivers         = 1
*      document_not_sent          = 2
*      document_type_not_exist    = 3
*      operation_no_authorization = 4
*      parameter_error            = 5
*      x_error                    = 6
*      enqueue_error              = 7
*      OTHERS                     = 8.
*
*  " 6️⃣ Hata Kontrolü
*  IF sy-subrc = 0.
*    WRITE: '✅ E-posta başarıyla gönderildi!'.
*  ELSE.
*    DATA: lv_error TYPE string.
*    CASE sy-subrc.
*      WHEN 1. lv_error = '⚠️ Çok fazla alıcı var! (Too Many Receivers)'.
*      WHEN 2. lv_error = '⚠️ E-posta gönderilemedi! (Document Not Sent)'.
*      WHEN 3. lv_error = '⚠️ Doküman tipi geçersiz! (Document Type Not Exist)'.
*      WHEN 4. lv_error = '⚠️ Yetki hatası! (SU53 ile kontrol et)'.
*      WHEN 5. lv_error = '⚠️ Parametre hatası! (Parameter Error)'.
*      WHEN 6. lv_error = '⚠️ X Hatası! (X Error)'.
*      WHEN 7. lv_error = '⚠️ Kilit hatası! (Enqueue Error)'.
*      WHEN OTHERS. lv_error = '⚠️ Bilinmeyen hata! (Others)'.
*    ENDCASE.
*    WRITE: lv_error.
*  ENDIF.
*
*ELSE.
*  WRITE: '⚠️ SO10 metni bulunamadı!'.
*ENDIF.



TYPES: BEGIN OF adres_bilgileri,
  sokak type c,
  cadde type c,
  sehir TYPE c,
  ev_no type n,
  end of adres_bilgileri.


  TYPES: BEGIN OF personel_bilgileri,
    ad type c,
    soyad TYPE c,
    telefon_no type n,
    adres type adres_bilgileri,
    END OF personel_bilgileri.



    DATA : personel_1 type personel_bilgileri,
          personel_2 type personel_bilgileri,
          adres_1 type adres_bilgileri.

    personel_1-ad = 'Muharrem'.
    personel_1-soyad = 'dikilitaş'.
    personel_1-telefon_no = '05394212096'.
    personel_1-adres-cadde = '2.cadde'.
    personel_1-adres-sehir = 'Kayseri'.
    personel_1-adres-ev_no = '13'.
    personel_1-adres-sokak = 'çıkmaz'.


    adres_1-cadde = 'sfv'.
    adres_1-ev_no = '32'.
    adres_1-sehir = 'sivas'.
    adres_1-sokak = 'çıkar'.

    personel_2-adres = adres_1.
