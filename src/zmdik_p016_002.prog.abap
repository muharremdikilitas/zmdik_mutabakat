*&---------------------------------------------------------------------*
*& Include          ZMDIK_P016_002
*&---------------------------------------------------------------------*


PARAMETERS:  num_1 TYPE i,
             num_2 TYPE i.

PARAMETERS topla RADIOBUTTON GROUP gr1 USER-COMMAND gr1 DEFAULT 'X'.
PARAMETERS cikar RADIOBUTTON GROUP gr1 .
PARAMETERS carp RADIOBUTTON GROUP gr1.
PARAMETERS bol RADIOBUTTON GROUP gr1.



START-OF-SELECTION.

PERFORM hesapla USING num_1 num_2.







end-of-SELECTION.


form hesapla USING sayi1 sayi2 .

  IF topla = 'X'.
    sonuc = sayi1 + sayi2.
    WRITE: 'Sonuç' , sonuc.

ENDIF.
IF cikar = 'X'.
  sonuc = sayi1 - sayi2.
  WRITE: 'Sonuç' , sonuc.
endif.

  IF carp = 'X'.
    sonuc = sayi1 * sayi2.
    WRITE: 'Sonuç' , sonuc.
  endif.
  if
    bol = 'X'.
    sonuc = sayi1 / sayi2.
    WRITE: 'Sonuç' , sonuc.
    endif.
  ENDFORM.
