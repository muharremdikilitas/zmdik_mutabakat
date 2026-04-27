*&---------------------------------------------------------------------*
*& Include          ZMDIK_P79_001
*&---------------------------------------------------------------------*


data: gs_data type          zmdik_erec,
      gt_data type table of zmdik_erec.


class lcl_report definition deferred.
data: go_report type ref to lcl_report.
