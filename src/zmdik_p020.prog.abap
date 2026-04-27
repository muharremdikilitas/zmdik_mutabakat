*&---------------------------------------------------------------------*
*& Report ZMDIK_P020
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P020.
*
*data : sayi1 TYPE i.
*
*  DO 100 TIMES.
*    if sayi1 mod 2 = 0.
*      WRITE:  / 'Çift Sayı =' , sayi1.
*      ELSE .
*        WRITE: / 'Tek Sayı' , sayi1.
*        ENDIF.
*        sayi1 = sayi1 + 1.
*
*  ENDDO.



data : sayi1 TYPE i.

sayi1 = 0.
WRITE: / 'ikiye tam bölünebilen sayılar'.

  DO 50 TIMES.
    sayi1 = sayi1 + 1.
    if sayi1 mod 2 = 0.
      WRITE  sayi1.

        ENDIF.


  ENDDO.


sayi1 = 0.
WRITE: / 'üçe tam bölünebilen sayılar'.

  DO 50 TIMES.
    sayi1 = sayi1 + 1.
    if sayi1 mod 3 = 0.
      WRITE sayi1.

        ENDIF.


  ENDDO.



sayi1 = 0.
WRITE: / 'beşe tam bölünebilen sayılar'.

  DO 50 TIMES.
     sayi1 = sayi1 + 1.
    if sayi1 mod 5 = 0.
      WRITE sayi1.

        ENDIF.


  ENDDO.
