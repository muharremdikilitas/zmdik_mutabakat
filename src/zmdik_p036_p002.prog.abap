*&---------------------------------------------------------------------*
*& Include          ZMDIK_P036_P002
*&---------------------------------------------------------------------*

PARAMETERS: p_bukrs TYPE bkpf-bukrs OBLIGATORY,
            p_gjahr TYPE bkpf-gjahr OBLIGATORY.

SELECT-OPTIONS: g_belnr for bkpf-belnr.
