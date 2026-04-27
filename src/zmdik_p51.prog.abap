*&---------------------------------------------------------------------*
*& Report ZMDIK_P51
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P51.
class lcl_main DEFINITION DEFERRED.

  data: go_main TYPE REF TO lcl_main.
PARAMETERS: p_num1 type int4,
            p_num2 type int4.



class lcl_main DEFINITION.
  PUBLIC SECTION.
  METHODS:
  constructor IMPORTING iv_num1 type i
                         iv_num2 type i,
   sum_numbers.


    data: mv_num1 type i,
          mv_num2 type i,
          mv_sum type i.



  ENDCLASS.





class lcl_main IMPLEMENTATION.
  METHOD constructor.                               "özel bir metoddur ve class create edilir edilmez öncelikle bu method çalışır.
mv_num1 = iv_num1.
mv_num2 = iv_num2.

    ENDMETHOD.




  METHOD sum_numbers.
mv_sum = mv_num1 + mv_num2.
    ENDMETHOD.
  ENDCLASS.



  START-OF-SELECTION.

*  CREATE OBJECT go_main.
*
*  go_main->mv_num1 = p_num1.
*  go_main->mv_num2 = p_num2.


CREATE OBJECT go_main
  EXPORTING
    iv_num1 = p_num1
    iv_num2 = p_num2
  .
  go_main->sum_numbers( ).


  WRITE: 'toplamı =' , go_main->mv_sum.
