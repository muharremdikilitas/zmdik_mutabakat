*&---------------------------------------------------------------------*
*& Report ZMDIK_P50
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P50.


PARAMETERS: p_num1 type int4,
            p_num2 type int4.

data: mv_sum type int4,
      mv_sub type int4,
      gv_sum type  int4,
      gv_changing_num TYPE int4.

class lcl_main DEFINITION DEFERRED.           "programın bir yerlerinde lcl_main classı olduğunu söylüyor. clasın yukarısında clasa ait data tanımlaması yaptık ve kızmadı.
  data: go_main TYPE ref to lcl_main.



class lcl_main DEFINITION.
  PUBLIC SECTION.

methods: sum_numbers,
 sub_numbers,
 sum_numbers_v2 IMPORTING iv_num1 type int4
                          iv_num2 type int4
                          EXPORTING ev_sum type int4,

 sum_numbersV3 IMPORTING iv_num1 type int4
                CHANGING cv_num2 type int4,

 sum_numbersV4 IMPORTING iv_num1 type int4
                          iv_num2 type int4
               RETURNING VALUE(rv_sum) type int4.

ENDCLASS.


class lcl_main IMPLEMENTATION.
  method sum_numbers.

mv_sum = p_num1 + p_num2.
  ENDMETHOD.


  method sub_numbers.
    mv_sub = p_num1 - p_num2.
    ENDMETHOD.

    METHOD sum_numbers_v2.
      ev_sum = iv_num1 + iv_num2.
      ENDMETHOD.

      METHOD sum_numbersv3.
        cv_num2 = iv_num1 - cv_num2.
        ENDMETHOD.

         METHOD sum_numbersv4.
        rv_sum = iv_num1 + iv_num2.
        ENDMETHOD.
  ENDCLASS.




START-OF-SELECTION.

CREATE OBJECT go_main.

go_main->sum_numbers( ).
WRITE : 'toplam = ', mv_sum.

go_main->sub_numbers( ).
WRITE : 'çıkaım = ', mv_sub.

go_main->sum_numbers_v2(
  EXPORTING
    iv_num1 = p_num1
    iv_num2 = p_num2
  IMPORTING
    ev_sum  = gv_sum
).

WRITE: 'toplamV2 =', gv_sum.

gv_changing_num = p_num2.
go_main->sum_numbersv3(
  EXPORTING
    iv_num1 = p_num1
  CHANGING
    cv_num2 = gv_changing_num
).

write: 'FARKI ', gv_changing_num.

go_main->sum_numbersv4(
  EXPORTING
    iv_num1 = p_num1
    iv_num2 = p_num2
  RECEIVING
    rv_sum  = gv_sum
).


WRITE: 'Toplamı V3 ' , gv_sum.

gv_sum = go_main->sum_numbersv4(                        "returning value dediğimiz için sadece go_main-> de sum_numbersV4 ü istedi ve daha az kod bloğu oluştu.
           iv_num1 = p_num1
           iv_num2 =  p_num2
         ).


WRITE: 'Toplamı V3 ' , gv_sum.
