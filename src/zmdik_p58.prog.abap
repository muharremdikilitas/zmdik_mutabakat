*&---------------------------------------------------------------------*
*& Report ZMDIK_P58
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P58.

types: BEGIN OF gty_itab,
  kolon1 TYPE char20,
  kolon2 TYPE char20,
  kolon3 TYPE char20,
  kolon4 TYPE char20,
  kolon5 TYPE char20,
  END OF gty_itab.

  DATA: gt_itab type TABLE of gty_itab,
        gt_raw_data type truxs_t_text_data.


PARAMETERS: p_file type rlgrap-filename.                    "rlgrap sap standardı

at SELECTION-SCREEN on VALUE-REQUEST FOR p_file.      "searchhelp oluşturmak için


  CALL FUNCTION 'F4_FILENAME'
   EXPORTING
*     PROGRAM_NAME        = SYST-CPROG
*     DYNPRO_NUMBER       = SYST-DYNNR
     FIELD_NAME          = 'P_FILE '
   IMPORTING
     FILE_NAME           = p_file
            .



START-OF-SELECTION.



CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'                   "bilgisayardaki excel dosyasını SAP tarafına aktarmayı sağlayan yapı
  EXPORTING
*   I_FIELD_SEPERATOR          =
   I_LINE_HEADER              = 'X'                            "excelinizde başlık var mı diye sprar eğer varsa buna X veririz ve başlık kısmını kaldırır
    i_tab_raw_data             = gt_raw_data
    i_filename                 = p_file
  TABLES
    i_tab_converted_data       = gt_itab
 EXCEPTIONS
   CONVERSION_FAILED          = 1
   OTHERS                     = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
  else.

ENDIF.


"herhangi bir hücrenin dolu olması yeterlidir yazdırmak için
