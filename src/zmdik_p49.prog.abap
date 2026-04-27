*&---------------------------------------------------------------------*
*& Report ZMDIK_P49
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P49.

PARAMETERS: p_num1 type int4,
            p_num2 type int4.

data: mv_sum type int4,
      mv_sub type int4.

class lcl_main DEFINITION DEFERRED.           "programın bir yerlerinde lcl_main classı olduğunu söylüyor. clasın yukarısında clasa ait data tanımlaması yaptık ve kızmadı.
  data: go_main TYPE ref to lcl_main.



class lcl_main DEFINITION.
  PUBLIC SECTION.

methods: sum_numbers, sub_numbers.


ENDCLASS.


class lcl_main IMPLEMENTATION.
  method sum_numbers.

mv_sum = p_num1 + p_num2.
  ENDMETHOD.


  method sub_numbers.
    mv_sub = p_num1 - p_num2.
    ENDMETHOD.
  ENDCLASS.




START-OF-SELECTION.

CREATE OBJECT go_main.

go_main->sum_numbers( ).
WRITE : 'toplam = ', mv_sum.

go_main->sub_numbers( ).
WRITE : 'çıkaım = ', mv_sub.
