*&---------------------------------------------------------------------*
*& Include          ZMDIK_P027_P001
*&---------------------------------------------------------------------*

TABLES: zmdik_log, zmdik_log2.
data: gs_data TYPE zmdik_log,
      gt_data TYPE TABLE OF zmdik_log,
      gs_kullanici TYPE zmdik_log2,
      gt_kullanici TYPE TABLE OF zmdik_log2,
      go_alv TYPE ref to cl_salv_table.

PARAMETERS: k_no TYPE zmdik_log2-k_no,
            k_adi TYPE zmdik_log2-k_adi,
            k_sifre TYPE zmdik_log2-k_sifre.
