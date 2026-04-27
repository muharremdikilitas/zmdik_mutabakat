*&---------------------------------------------------------------------*
*& Include          ZMDIK_P76_I001
*&---------------------------------------------------------------------*


TYPE-POOLS: icon.
TYPE-POOLS: lvc.

" Class'ı daha sonra (I003'te) tanımlayacağız; burada forward declare yapıyoruz
CLASS lcl_app DEFINITION DEFERRED.

" Kaynak tablo satırı (ZEHO_T600)
" NOT: BANKC ve AMOUNT veri elemanlarını kendi sistemine göre ayarla.
"      Aşağıdaki ZEHO_DE001 ve KWBTR_EB senin ekranlarından alınmıştı.
"      Eğer sende farklıysa değiştirebilirsin.
TYPES: BEGIN OF ty_src,
         bukrs   TYPE bukrs,        " Şirket
         bankc   TYPE zeho_de001,   " Banka kodu   (gerekirse CHAR10 yap)
         bankn   TYPE bankn,        " Banka hesabı
         prdat   TYPE dats,         " Tarih
         b_prtim TYPE tims,         " Başlangıç saati (interval begin)
         p_prtim TYPE tims,         " Bitiş saati   (interval end)
         sdis    TYPE char3,        " Opsiyonel alan
         sign    TYPE char1,        " Opsiyonel alan
         amount  TYPE kwbtr_eb,     " Tutar alanı   (gerekirse TYPE p DECIMALS 2 yap)
       END OF ty_src.

" ALV satırı
TYPES: BEGIN OF ty_out,
         bukrs       TYPE bukrs,
         bankc       TYPE zeho_de001,
         bankn       TYPE bankn,
         prdat       TYPE dats,
         prtim       TYPE tims,        " 1 dk slot başlangıcı
         slot_end    TYPE tims,        " slot bitişi
         sdis        TYPE char3,
         sign        TYPE char1,
         amount      TYPE kwbtr_eb,
         status      TYPE char10,      " DATA | ZERO | NO_DATA
         status_icon TYPE icon_d,      " ikon göstermek için
         ctab        TYPE lvc_t_scol,  " hücre boyama (CTAB)
       END OF ty_out.

" Tablo tipleri
TYPES: ty_src_tab TYPE STANDARD TABLE OF ty_src WITH EMPTY KEY.
TYPES: ty_out_tab TYPE STANDARD TABLE OF ty_out WITH EMPTY KEY.

" Global iç tablolar
DATA: gt_src TYPE ty_src_tab,
      gt_out TYPE ty_out_tab.

" ALV nesneleri
DATA: go_cont TYPE REF TO cl_gui_custom_container,
      go_alv  TYPE REF TO cl_gui_alv_grid.

" Ekran/ALV hazır mı bayrağı (ileride kullanacağız)
DATA: gv_alv_ready TYPE abap_bool VALUE abap_false.

" Uygulama sınıfı örneği (I003'te sınıfı yazacağız)
*class lcl_app DEFINITION DEFERRED.
DATA: go_app TYPE REF TO lcl_app.
