*&---------------------------------------------------------------------*
*& Include          ZMDIK_P036_P001
*&---------------------------------------------------------------------*
tables: bkpf, bseg, T003T.
data: BEGIN OF gt_data occurs 0 ,

  BUKRS like bkpf-bukrs,
  BELNR like bkpf-belnr,
  GJAHR like bkpf-GJAHR,
  BLART like bkpf-BLART,
  LTEXT like t003t-ltext,
  BLDAT like bkpf-bldat,
  WAERS like bkpf-waers,
  wrbtr like bseg-wrbtr,

  end of gt_data.

*  data: gs_data TYPE gsy_str,
*    data:   gs_data like TABLE OF gt_data.
*  data: gs_data2 TYPE gsy_str,
*        gt_data2 TYPE gsy_str.
data: gv_value type bkpf-belnr,
      gt_selrow like gt_data,
      gs_selrow like bkpf.


    data : lv_belnr like bkpf-belnr.
    data : lv_gjahr like bkpf-gjahr.

data: BEGIN OF gt_bseg occurs 0 ,

   bukrs like bseg-bukrs,
        belnr like bseg-belnr,
        gjahr like bseg-gjahr,
        buzei like bseg-buzei,
        wrbtr like bseg-wrbtr,
  end of gt_bseg.

  data: gt_fieldcatalog TYPE  SLIS_T_FIELDCAT_ALV,
        gs_fieldcatalog TYPE slis_fieldcat_alv.

  data: go_alv TYPE REF TO cl_salv_table.

  DATA: gs_layout TYPE slis_layout_alv.
