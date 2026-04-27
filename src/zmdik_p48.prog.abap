*&---------------------------------------------------------------------*
*& Report ZMDIK_P48
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P48.
*class math_op DEFINITION.                   "definiationda bu clasın içinde kullanılacak dataları metodları tanımlıyoruz
*PUBLIC SECTION.
*
*data: lv_num1 type i ,
*      lv_num2 type i,
*      lv_result type i.
*
*methods: sum_numbers.
*
*
*ENDCLASS.
*
*                                              "implementationun altında kodlamasını yapıyoruz
*
*class math_op IMPLEMENTATION.
*
*  method sum_numbers.
*    lv_result = lv_num1 + lv_num2.
*
*    ENDMETHOD.
*  endclass.
*
*
*DATA: go_math_op type ref to math_op.
*
*START-OF-SELECTION.
*CREATE OBJECT go_math_op.
*
*go_math_op->lv_num1 = 12.
*go_math_op->lv_num1 = 13.
*go_math_op->sum_numbers( ).
*
*
*WRITE: go_math_op->lv_result.







class math_op DEFINITION.
  PUBLIC SECTION.

  data: lv_num1 type i,
        lv_num2 type i,
        lv_result type i.
  data: lv_public type i.

  METHODS: sum_numbers.

  PROTECTED SECTION.
  data:  lv_protected type i.


  PRIVATE SECTION.
  data: lv_private type i.

  ENDCLASS.





class math_op IMPLEMENTATION.

  METHOD sum_numbers.
    lv_result = lv_num1 + lv_num2.
    lv_public = 1.
    lv_private = 1.
    lv_protected = 1.
    ENDMETHOD.
    ENDCLASS.


class math_op_diff DEFINITION INHERITING FROM math_op.                  "inheritance mantığında math_op tan kalıtım alıyor ve math_op ta girdiğimiz değerleri kullanabiliyoruz.
  PUBLIC SECTION.                                                       "public şekilde erişmek için yapıyoruz



  methods: diff_num.

  ENDCLASS.




  class math_op_diff IMPLEMENTATION.

    method diff_num.
      lv_public = 2.                             "public ve protectedde alt classlara erişiyor fakat private olduğunda alt classlara erişemiyor
      lv_protected = 2.
      lv_result = lv_num1 - lv_num2 .
      ENDMETHOD.

     ENDCLASS.


     START-OF-SELECTION.

data: go_math_op_diff TYPE ref to math_op_diff.                 "class objesini oluşturuyoruz
CREATE OBJECT go_math_op_diff.
go_math_op_diff->lv_public = 10.                              "sadece public sectinda yazdığın clastaki verilere erişebiliyosun.
go_math_op_diff->lv_num1 = 17.
go_math_op_diff->lv_num2 = 13.
go_math_op_diff->diff_num( ).


WRITE: go_math_op_diff->lv_result.


WRITE: sy-uline.












    data: go_math_op TYPE ref to math_op.

    CREATE OBJECT go_math_op.

    go_math_op->lv_num1 = 12.
    go_math_op->lv_num2 = 13.
    go_math_op->sum_numbers( ).



    WRITE: go_math_op->lv_result.
