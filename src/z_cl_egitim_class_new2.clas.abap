class Z_CL_EGITIM_CLASS_NEW2 definition
  public
  final
  create public .

public section.

  interfaces Z_CL_EGITIM_INTERFACE .

  types NUMBER_TYP type INT4 .

  constants CV_NUMBER type NUMBER_TYP value 100 ##NO_TEXT.

  methods SUM_NUMBERS
    importing
      value(IV_NUM1) type INT4 optional
      value(IV_NUM2) type INT4 optional
    exporting
      value(EV_RESULT) type NUMBER_TYP .
  class-methods SUM_NUMBERS_V2 .
  class-methods DIFF_NUMBERS
    importing
      value(IV_NUM1) type INT4 optional
      value(IV_NUM2) type INT4 optional
    exporting
      value(EV_RESULT) type INT4 .
protected section.
private section.

  methods SUM_NUMBERS_PRIVATE .
ENDCLASS.



CLASS Z_CL_EGITIM_CLASS_NEW2 IMPLEMENTATION.


  method DIFF_NUMBERS.
    z_cl_egitim_class_v3=>diff_number(
      EXPORTING
        iv_num1   =  iv_num1                " 4 bayt işaretli tamsayı
        iv_num2   =  iv_num2                " 4 bayt işaretli tamsayı
      IMPORTING
        ev_result =  ev_result                " 4 bayt işaretli tamsayı
    ).
  endmethod.


  method SUM_NUMBERS.

    ev_result = iv_num1 + iv_num2 + cv_number.

  endmethod.


  method SUM_NUMBERS_PRIVATE.
  endmethod.


  method SUM_NUMBERS_V2.
  endmethod.


  method Z_CL_EGITIM_INTERFACE~MULT_NUMBERS.
  endmethod.
ENDCLASS.
