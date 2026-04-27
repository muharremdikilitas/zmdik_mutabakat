*&---------------------------------------------------------------------*
*& Report ZMDIK_P006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P006.

DATA: gv_title1 TYPE string VALUE   'malzeme bilgileri',
      gv_title2 TYPE string VALUE 'tarih bilgiler',
      malno TYPE i,
      ikod  TYPE i,
      skod TYPE i,
      tarih TYPE sy-datum.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE gv_til1.
PARAMETERS: p_malno TYPE i,
            p_ikod TYPE i,
            p_skod TYPE i.
SELECTION-SCREEN END OF BLOCK b1.



SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE gv_til2.
select-OPTIONS: p_tarih FOR sy-datum.
SELECTION-SCREEN END OF BLOCK b2.

START-OF-SELECTION.
WRITE: / 'Malzeme no' , malno,
       / 'İşletme Kodu' , ikod,
       / 'Şirket Kodu' , skod,
       / 'Tarih' , tarih.
