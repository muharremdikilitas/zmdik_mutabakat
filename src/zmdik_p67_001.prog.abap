*&---------------------------------------------------------------------*
*& Include          ZMDIK_P67_001
*&---------------------------------------------------------------------*


data: gt_keybalance type TABLE OF bapi3007_3,
      gs_keybalance type bapi3007_3,
      gt_data       type TABLE OF ztcakmak_t0006,
      gs_data       type          ztcakmak_t0006.

"veritabanı işlemleri ve geçici veri saklama için iç tablolar ve yapı tanımlamaları yapılıyor.


data : gv_test type c length 1.
"tek karakterlik bir değişken debug veya test amaçlı



data gv_first_mutabakat type c LENGTH 1.
"ilk mutabakat işlemini belirlemek için bir bayrak değişkeni

data: gt_dd07l_tab    type TABLE OF dd07v,
      gs_dd07l        type          dd07v,
      gv_shkgz_txt   type           string.           "shkzg açıklaması



"mutabakat durumu açıklamalarını dinamik olarak almak için dd07l tablosunu kullan.
data: gv_mutabakat_drm_txt    type string,
      gv_status_icon          type string.



"ALV için alan tanımlamaları

data: gt_fieldcat type slis_t_fieldcat_alv,
      gs_fieldcat type slis_fieldcat_alv,
      gs_layout type  slis_layout_alv.


data: gt_fields type TABLE OF string,                         "alan adlarını tutacak tablo
      gv_field type string.                                   "geçici alan adı değişkeni



 types: BEGIN OF ty_display,
        doc_date        type bapi3007_2-doc_date,                      "Belge tarihi
        doc_type        TYPE bapi3007_2-doc_type,                      "belge tipi
        item_text       type bapi3007_2-item_text,                     "ürün metni
        ref_doc_no      type bapi3007_2-ref_doc_no,                     "referans belge numarası
        db_cr_ind       type bapi3007_2-db_cr_ind,                      "Borç/Alacak göstergesi
        lc_amount       type bapi3007_2-lc_amount,                      "tutar
        currency        type bapi3007_2-currency,                       "Para Birimi
      END OF ty_display.





data: gt_display TYPE TABLE OF ty_display,                      "gösterilecek veriler
      gs_display type          ty_display.



 data:  gt_bapi_data   type TABLE OF  bapi3007_2,           "BAPI den gelen veriler
        gs_bapi_data   TYPE           bapi3007_2,
        gt_slav_data   type TABLE OF  ztcakmak_t0006,         "SALV verisi
        go_salv_table  TYPE REF TO    cl_salv_table,          "SALV tablo nesnesi
        go_salv_functions TYPE REF TO cl_salv_functions,        "SALV fonksiyonları
        gv_noteditems   type  bapi3007-ntditms_rq VALUE ' ' ,      "Not edilen kalemler
        gv_secindex    TYPE  bapi3007-sindex_rq  VALUE ' '.         "sekonder endeks


   data: gt_answer type c.   "Kullanıcı onayı



   data: go_alv     type REF TO  cl_salv_table,               "SALV tablo nesnesi
         go_functions TYPE REF TO cl_salv_functions.            "SALV fonksiyonları




   data: gt_emails      type TABLE OF  ztcakmak_t0007,            "Müşteriye ait e-posta adreslerini tutacak tablo
         gs_email       type           ztcakmak_t0007,             "tek bir e-posta yapısı için satır yapısı,
         gv_subject     TYPE           so_obj_des,                  "Eposta konusu
         gt_body        type TABLE OF  soli,                        "e posta içeriğini tutacak tablo
         gt_header      type TABLE OF solisti1,                      "eposta başlığını tutacak tablo
         doc_data       type          sodocchgi1,                     "eposta döküman bilgileri
         objcont     TYPE soli OCCURS 10 WITH HEADER LINE,
         receiver    TYPE somlreci1 OCCURS 1 WITH HEADER LINE,
         gv_name1    TYPE kna1-name1,                                 " Müşteri adı
         gs_selected TYPE ztcakmak_t0006.                               " Seçilen satırın yapısı




         DATA: g_grid TYPE REF TO cl_gui_alv_grid. " ALV Grid nesnesi
