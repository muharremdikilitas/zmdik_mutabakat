*&---------------------------------------------------------------------*
*& Report ZMDIK_P021
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P021.

*
*PARAMETERS: sayi type i.
*
*
*IF sayi >= 0 and sayi =< 25.
*  WRITE ' Sayı 25 ten küçüktür.'.
*  ELSEIF sayi >= 25.
*    WRITE 'sayı 25 ten büyüktür.'.
*
*ENDIF.

*data : sonuc type i.
*PARAMETERS: sayi1 TYPE i,
*            sayi2 TYPE i,
*            islem TYPE char1.
*
*
*CASE islem.
*  WHEN '+' .
*sonuc = sayi1 + sayi2.
*WRITE sonuc.
*  WHEN '-' .
*    sonuc = sayi1 - sayi2.
*    WRITE sonuc.
*  WHEN '*'.
*    sonuc = sayi1 * sayi2.
*    WRITE sonuc.
*    WHEN '/'.
*      sonuc = sayi1 / sayi2.
*      WRITE sonuc.
*ENDCASE.


*data: sayi TYPE i value '10' .
*
*PARAMETERS: p_chbx1 AS CHECKBOX,
*            p_chbx2 AS CHECKBOX,
*            p_chbx3 as CHECKBOX.
*
*
*START-OF-SELECTION.
*IF p_chbx1 = abap_true .
*sayi = sayi + 2.
*WRITE sayi.
*ENDIF.
*if p_chbx2 = abap_true.
*  sayi = sayi + 3.
*  WRITE sayi.
*  endif.
*  if p_chbx3 = abap_true.
*    sayi = sayi + 5.
*    WRITE sayi.
*    endif.


data:
      sonuc type p DECIMALS 2 .

PARAMETERS: num1 TYPE i,
            num2 TYPE i.


START-OF-SELECTION.
PERFORM islem.












FORM islem.
IF num1 > num2.
sonuc = num1 / num2.
WRITE sonuc.
else.
  sonuc = num2 / num1.
  WRITE sonuc.
ENDIF.
endform.
