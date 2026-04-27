*&---------------------------------------------------------------------*
*& Include          ZMDIK_P029_P001
*&---------------------------------------------------------------------*
DATA: BEGIN OF gt_list occurs 0 ,
  ebeln like ekko-EBELN,
  ebelp like ekpo-ebelp,
  bstyp like ekko-bstyp,
  bsart like ekko-bsart,
  matnr like ekpo-matnr,
  menge like ekpo-menge,
  meins like ekpo-meins,


  END OF gt_list.




TYPES: BEGIN OF gty_list,
  ebeln TYPE EBELN,
  ebelp TYPE ebelp,
  bstyp TYPE ebstyp,
  bsart TYPE esart,
  matnr TYPE matnr,
  menge TYPE bstmg,
  meins TYPE meins,
  line_color TYPE char4,
  END OF gty_list.

 data:
*gt_list TYPE TABLE of gty_list,
        gs_list type gty_list.

  data: gt_fieldcatalog TYPE  SLIS_T_FIELDCAT_ALV,
        gs_fieldcatalog TYPE slis_fieldcat_alv.
  DATA: gs_layout TYPE slis_layout_alv.


  DATA: gt_events type SLIS_T_EVENT,
        gs_event TYPE slis_alv_event.
