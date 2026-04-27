*&---------------------------------------------------------------------*
*& Include          ZMDIK_P066_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
   IF go_cont IS INITIAL.

    CREATE OBJECT go_cont
      EXPORTING container_name = 'CC_ALV'.

    CREATE OBJECT go_alv
      EXPORTING i_parent = go_cont.

    PERFORM build_fcat.

    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING i_structure_name = ''
      CHANGING  it_outtab        = gt_list
                it_fieldcatalog  = gt_fcat.

  ENDIF.
ENDMODULE.
