*&---------------------------------------------------------------------*
*& Report ZMDIK_P011
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P011.

START-OF-SELECTION.

PERFORM iki_sayiyi_carp USING 5 10.



end-of-SELECTION.
Form iki_sayiyi_carp USING pnm1 pnm2.
  data: toplam TYPE i.
  toplam = pnm1 * pnm2.
  WRITE toplam.
  ENDFORM.
