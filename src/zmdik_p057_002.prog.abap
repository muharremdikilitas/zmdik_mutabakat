*&---------------------------------------------------------------------*
*& Include          ZMDIK_P057_002
*&---------------------------------------------------------------------*


PARAMETERS: sirket type bkpf-bukrs OBLIGATORY,  "şirket kodu zorunlu
            tarihbil type sy-datum.             "tarih bilgisi



SELECT-OPTIONS: cm_no for kna1-kunnr OBLIGATORY.  "Müşteri numarası için aralık zorunlu
