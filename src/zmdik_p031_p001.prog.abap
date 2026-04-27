*&---------------------------------------------------------------------*
*& Include          ZMDIK_P031_P001
*&---------------------------------------------------------------------*



data: BEGIN OF gst_str,
  pers_id TYPE ZMDIK_PERSID_DE,
  pers_ad TYPE ZMDIK_PERSAD_DE,
  pers_soyad TYPE ZMDIK_PERSSOYAD_DE,
  pers_cins TYPE ZMDIK_PERSCINS_DE,
  PER_AD TYPE ZMDIK_DEDEPAD,
  P_MAAS TYPE ZMDIK_DEMAAS,
  END OF gst_str.


  DATA: gt_it like TABLE OF gst_str,
        gs_it like gst_str.


  data: gt_fieldcatalog TYPE slis_t_fieldcat_alv,
        gs_fieldcatalog TYPE slis_fieldcat_alv,
        gs_layout TYPE slis_layout_alv.
