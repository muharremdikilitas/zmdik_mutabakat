*&---------------------------------------------------------------------*
*& Include          ZMDIK_P039_P001
*&---------------------------------------------------------------------*

*data : begin of gt_list occurs 0,
*  ebeln like ekko-ebeln,
*  ebelp like ekpo-ebelp,
*  bstyp like ekko-bstyp,
*  bsart like ekko-bsart,
*  matnr like ekpo-matnr,
*  menge like ekpo-menge,
*  meins like ekpo-meins,
*  END OF gt_list.




TYPES: BEGIN OF gty_list,
  selkz type char1,
  ebeln TYPE ebeln,
  ebelp TYPE ebelp,
  bstyp TYPE bstyp,
  bsart TYPE esart,
  matnr TYPE matnr,
  menge type bstmg,
  meins TYPE meins,
  line_color type char4,
  cell_color type slis_t_specialcol_alv,
  end of gty_list.



data: gs_cell_color type slis_specialcol_alv.

  data: gt_list TYPE TABLE of gty_list,
        gs_list TYPE gty_list.

data: gt_fieldcatalog TYPE SLIS_T_FIELDCAT_ALV,
      gs_fieldcatalog TYPE SLIS_FIELDCAT_ALV.


data: gs_layout type slis_layout_alv.
