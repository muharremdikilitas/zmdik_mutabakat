class Z_CL_EGITIM_CLASS_V3 definition
  public
  final
  create public

  global friends Z_CL_EGITIM_CLASS_NEW2 .

public section.
protected section.
private section.

  class-methods DIFF_NUMBER
    importing
      value(IV_NUM1) type INT4 optional
      value(IV_NUM2) type INT4 optional
    exporting
      value(EV_RESULT) type INT4 .
ENDCLASS.



CLASS Z_CL_EGITIM_CLASS_V3 IMPLEMENTATION.


  method DIFF_NUMBER.

    ev_result = iv_num1 - iv_num2.
  endmethod.
ENDCLASS.
