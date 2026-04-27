*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTABAKAT2_P002
*&---------------------------------------------------------------------*
TABLES: bseg.
selection-screen begin of block b1 with frame title t1.
  select-options: s_kunnr for bseg-kunnr obligatory.

  parameters: p_bukrs type knb1-bukrs obligatory,
              p_datum type knb1-erdat obligatory.
selection-screen end of block b1.
