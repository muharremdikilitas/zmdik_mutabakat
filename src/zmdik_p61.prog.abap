*&---------------------------------------------------------------------*
*& Report ZMDIK_P61
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P61.
data: application TYPE ole2_object,
      workbook TYPE ole2_object,
      sheet TYPE ole2_object,
      cells TYPE ole2_object.


data: gv_row type i,
      gs_scarr type scarr,
      gt_scarr type table of scarr.

START-OF-SELECTION.

create OBJECT application 'excel.application'.
set PROPERTY OF application 'visible' = 1.
call METHOD of application 'Workbooks' = workbook.
call METHOD of workbook 'Add'.



call METHOD of application 'Worksheets' = sheet
EXPORTING #1 = 1.
call METHOD of sheet 'Activate'.
set PROPERTY OF sheet 'Name' = 'Sheet1'.

SELECT * from scarr into TABLE gt_scarr.


PERFORM fill_cell USING 1 1 'Üst Birim'.
PERFORM fill_cell USING 1 2 'Kısa Tanım'.
PERFORM fill_cell USING 1 1 'Havayolu Şirketinin Adı'.
PERFORM fill_cell USING 1 1 'PB'.
PERFORM fill_cell USING 1 1 'URL'.


LOOP AT gt_scarr into gs_scarr.
  gv_row = sy-tabix + 1.

 PERFORM fill_cell USING gv_row 1 gs_scarr-mandt.
 PERFORM fill_cell USING gv_row 2 gs_scarr-carrid.
 PERFORM fill_cell USING gv_row 3 gs_scarr-carrname.
 PERFORM fill_cell USING gv_row 4 gs_scarr-currcode.
 PERFORM fill_cell USING gv_row 5 gs_scarr-url.

ENDLOOP.

form fill_cell USING row col val.
  call METHOD of sheet 'Cells' = cells EXPORTING #1 = row #2 = col.
  set PROPERTY OF cells 'Value' = val.
  ENDFORM.
