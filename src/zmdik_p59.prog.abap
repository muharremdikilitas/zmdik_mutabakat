*&---------------------------------------------------------------------*
*& Report ZMDIK_P59
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P59.

types: BEGIN OF gty_itab,
  kolon1 TYPE char20,
  kolon2 TYPE char20,
  kolon3 TYPE char20,
  kolon4 TYPE char20,
  kolon5 TYPE char20,
  END OF gty_itab.



data: gt_intern TYPE TABLE of ALSMEX_TABLINE,
      gs_intern type ALSMEX_TABLINE,
      gt_itab TYPE TABLE of gty_itab,
      gs_itab type gty_itab.

FIELD-SYMBOLS: <gfv_value> TYPE any.

PARAMETERS: p_file type rlgrap-filename.

at SELECTION-SCREEN on VALUE-REQUEST FOR p_file.


  CALL FUNCTION 'F4_FILENAME'                                   "dosyayı masaüstünden açmak için

   IMPORTING
     FILE_NAME           = p_file
            .

START-OF-SELECTION.


CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
  EXPORTING
    filename                      = p_file
    i_begin_col                   =  1                                       "başlangıç bitiş kolon ve satırları yazıyoruz ve bunları getiriyorr
    i_begin_row                   = 2
    i_end_col                     = 15
    i_end_row                     = 15
  TABLES
    intern                        = gt_intern
 EXCEPTIONS
   INCONSISTENT_PARAMETERS       = 1
   UPLOAD_OLE                    = 2
   OTHERS                        = 3
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.


LOOP AT gt_intern into gs_intern .
  ASSIGN COMPONENT gs_intern-col OF STRUCTURE gs_itab to <gfv_value>.                   "o anki döndüğüm kolon gs_itab kolonuna eşit ve bunun anlık olarak valuesi <gfv_value> ye eşit oluyor.
<gfv_value> = gs_intern-value.
at END OF row.                                                                      "row kolonu değiştiyse aşağıdaki kod çalışır
  APPEND gs_itab to gt_itab.
  ENDAT.
ENDLOOP.

BREAK-POINT.
