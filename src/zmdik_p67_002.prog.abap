*&---------------------------------------------------------------------*
*& Include          ZMDIK_P67_002
*&---------------------------------------------------------------------*


TABLES: kna1, knb1, t001, ztcakmak_t0006.
" Bu TABLES bildirimi, belirtilen tabloları programda kullanmak için tanımlar.
" KNA1: Müşteri genel verileri
" KNB1: Müşteri muhasebe verileri
" T001: Şirket kodu verileri
" ZTCAKMAK_T0006: Kullanıcı tanımlı özel bir tablo (mutabakat bilgileri içeriyor)


PARAMETERS: p_bukrs type knb1-bukrs  OBLIGATORY,          "şirket kodu girişi zorunlu
            p_tarih type sy-datum     OBLIGATORY.           "Anahtar tarih giriş zorunlu



select-OPTIONS: p_kunnr for kna1-kunnr.                 "Müşteri kodu için çoklu seçim imkanı
