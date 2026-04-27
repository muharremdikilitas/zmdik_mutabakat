*&---------------------------------------------------------------------*
*& Include          ZMDIK_P44_FORM
*&---------------------------------------------------------------------*

FORM display_alv .




     CREATE OBJECT go_cont
      EXPORTING
        container_name = 'CC_ALV'.

     CREATE OBJECT go_splitter
       EXPORTING
         parent                  =  go_cont                                    ""hangi objeyi split edeceksem vermem gereken alan
         rows                    = 1                                      "verdiğin split objesini kaça bölsün. kaç row kaç columns olsun
         columns                 = 2.



     CALL METHOD go_splitter->get_container
       EXPORTING
         row       = 1
         column    = 1
       RECEIVING
         container = go_gui1
       .




               CALL METHOD go_splitter->get_container
       EXPORTING
         row       = 1
         column    = 2
       RECEIVING
         container = go_gui2
       .



        CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_gui1.





  CREATE OBJECT go_alv2
      EXPORTING
        i_parent = go_gui2.





       CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_scarr
        it_fieldcatalog = gt_fcat.




     CALL METHOD go_alv2->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_sflight
        it_fieldcatalog = gt_fcat2.







ENDFORM.




FORM get_data .

  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.


  SELECT * FROM sflight INTO CORRESPONDING FIELDS OF TABLE gt_sflight.








ENDFORM.

FORM set_data .
*
CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
 EXPORTING
   I_STRUCTURE_NAME             = 'SCARR'
  CHANGING
    ct_fieldcat                  = gt_fcat.


CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
 EXPORTING
   I_STRUCTURE_NAME             = 'SFLIGHT'
  CHANGING
    ct_fieldcat                  = gt_fcat2.
ENDFORM.



*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .
  CLEAR: gs_layout.
  gs_layout-cwidth_opt = abap_true.         "layoutta yaptığımız değişiklikler tüm alv nin tüm kolonlarını etkiler.
  gs_layout-no_toolbar = abap_true.     " bu alv de ki toolbarı kaldırır.


ENDFORM.
