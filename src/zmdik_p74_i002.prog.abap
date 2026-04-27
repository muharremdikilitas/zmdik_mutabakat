*&---------------------------------------------------------------------*
*& Include          ZMDIK_P74_I002
*&---------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK bl  WITH FRAME TITLE text-t01.

 SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 5(20) text-001 FOR FIELD s_kod.
  PARAMETERS s_kod TYPE bukrs.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK bl.
