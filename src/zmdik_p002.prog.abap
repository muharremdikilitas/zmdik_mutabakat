*&---------------------------------------------------------------------*
*& Report ZMDIK_P002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P002.






DATA: num1 TYPE i,
      num2 TYPE i,
      result TYPE i,
      operation TYPE string.

PARAMETERS: p_num1 TYPE i,
            p_num2 TYPE i.


PARAMETERS: p_add RADIOBUTTON GROUP grp1 USER-COMMAND operation,
            p_sub RADIOBUTTON GROUP grp1,
            p_mul RADIOBUTTON GROUP grp1,
            p_div RADIOBUTTON GROUP grp1.


START-OF-SELECTION.


  IF p_add = 'X'.
    operation = 'ADD'.
  ELSEIF p_sub = 'X'.
    operation = 'SUB'.
  ELSEIF p_mul = 'X'.
    operation = 'MUL'.
  ELSEIF p_div = 'X'.
    operation = 'DIV'.
  ENDIF.


  num1 = p_num1.
  num2 = p_num2.


  CASE operation.
    WHEN 'ADD'.
      result = num1 + num2.
      MESSAGE |Sonuç: { result }| TYPE 'I'.
    WHEN 'SUB'.
      result = num1 - num2.
      MESSAGE |Sonuç: { result }| TYPE 'I'.
    WHEN 'MUL'.
      result = num1 * num2.
      MESSAGE |Sonuç: { result }| TYPE 'I'.
    WHEN 'DIV'.
      IF num2 = 0.
        MESSAGE 'Bir sayıyı sıfıra bölemezsiniz' TYPE 'E'.
      ELSE.
        result = num1 / num2.
        MESSAGE |Sonuç: { result }| TYPE 'I'.
      ENDIF.
    WHEN OTHERS.
      MESSAGE 'Geçersiz işlem' TYPE 'E'.
  ENDCASE.
