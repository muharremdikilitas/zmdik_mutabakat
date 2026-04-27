*&---------------------------------------------------------------------*
*& Include          ZMDIK_P066_001
*&---------------------------------------------------------------------*



"― Standart tabloları referans göstermek ―
TABLES: kna1,            "Müşteri ana verisi
        knb1,            "Müşteri–şirket kodu
        bsid.            "Müşteri açık kalem

"― Ekran nesneleri için OO sınıflarını yükle ―
CLASS cl_gui_custom_container DEFINITION LOAD.
CLASS cl_gui_alv_grid         DEFINITION LOAD.

"― 1) Ekranda kullanacağımız ALV nesneleri ―
DATA: go_cont  TYPE REF TO cl_gui_custom_container,
      go_alv   TYPE REF TO cl_gui_alv_grid.

"― 2) Field-catalog dahili tablosu ―
DATA: gt_fcat TYPE lvc_t_fcat,
      gs_fcat TYPE lvc_s_fcat.

"― 3) JOIN sonucu ve ALV’de göstereceğimiz ana tablo ―
TYPES: BEGIN OF ty_join,
         bukrs TYPE bukrs,         "Şirket kodu
         kunnr TYPE kna1-kunnr,    "Müşteri
         name1 TYPE kna1-name1,    "Ad
         borc  TYPE wrbtr,         "Toplam borç
         mail  TYPE adr6-smtp_addr,"E-posta (şimdilik boş)
         risk  TYPE char5,         "Risk skoru (örnek)
       END OF ty_join.

DATA: gt_list TYPE STANDARD TABLE OF ty_join,
      gs_list TYPE ty_join.
