*&---------------------------------------------------------------------*
*& Report ZMDIK_P47
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P47.

data: gv_egitim_class type ref to Z_CL_EGITIM_CLASS_NEW2.           "instance metodunda referans alarak objeyi yaratıp çağırmamız gerekiyor
data: gv_num1 type int4,
      gv_num2 type int4,
      gv_result type int4.


START-OF-SELECTION.

CREATE OBJECT gv_egitim_class.

gv_num1 = 12.
gv_num2 = 15.

gv_egitim_class->sum_numbers(
  EXPORTING
    iv_num1   = gv_num1                 " 4 bayt işaretli tamsayı
    iv_num2   = gv_num2                 " 4 bayt işaretli tamsayı
  IMPORTING
    ev_result = gv_result                 " 4 bayt işaretli tamsayı
).

WRITE: gv_result.

*Z_CL_EGITIM_CLASS_NEW2=>sum_numbers_v2( ).                          "static metodda ise direkt bu şekilde çağırabiliyoruz.
