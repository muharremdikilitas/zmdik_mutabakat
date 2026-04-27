*&---------------------------------------------------------------------*
*& Include          ZMDIK_P68_002
*&---------------------------------------------------------------------*


  PARAMETERS: sirket   TYPE bkpf-bukrs OBLIGATORY, " Şirket kodu zorunlu
              tarihbil TYPE sy-datum . " Tarih bilgisi

  SELECT-OPTIONS: cm_no FOR kna1-kunnr OBLIGATORY. " Müşteri numarası için aralıks
