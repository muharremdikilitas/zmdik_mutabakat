*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTAKABAT_P002
*&---------------------------------------------------------------------*

SELECTION-SCREEN begin of block b1 WITH FRAME TITLE baslik.

SELECTION-SCREEN begin of line.
SELECTION-SCREEN COMMENT 5(15) c1.
PARAMETERS:p_bukrs type bkpf-bukrs OBLIGATORY.
SELECTION-SCREEN end of line.

SELECTION-SCREEN begin of line.
SELECTION-SCREEN COMMENT 5(15) c2.
PARAMETERS:p_kunnr type kna1-kunnr OBLIGATORY.
SELECTION-SCREEN end of line.

SELECTION-SCREEN begin of line.
SELECTION-SCREEN COMMENT 5(15) c3.
PARAMETERS: p_datum type datum .
SELECTION-SCREEN end of line.

SELECTION-SCREEN end of block b1.
