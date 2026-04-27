FUNCTION ZMDP_FM0001.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"--------------------------------------------------------------------

  " 1) Döndüreceğimiz iki alanı tutacak yerel tipi tanımlıyoruz
  TYPES: BEGIN OF ty_buk_butxt,
           bukrs TYPE zeho_t002-bukrs,
           butxt TYPE t001-butxt,
         END OF ty_buk_butxt.

  " 2) Bu tipe uygun internal table ve work area
  DATA: lt_result    TYPE STANDARD TABLE OF ty_buk_butxt WITH EMPTY KEY,
        ls_result    TYPE ty_buk_butxt,
        ls_seahlpres TYPE seahlpres.

* EXIT immediately, if you do not want to handle this step
  IF callcontrol-step <> 'SELONE' AND
     callcontrol-step <> 'SELECT' AND
     callcontrol-step <> 'RETURN' AND
     " AND SO ON
     callcontrol-step <> 'DISP'.
    EXIT.
  ENDIF.

*"----------------------------------------------------------------------
* STEP SELONE  (Select one of the elementary searchhelps)
*"----------------------------------------------------------------------
* This step is only called for collective searchhelps. It may be used
* to reduce the amount of elementary searchhelps given in SHLP_TAB.
* The compound searchhelp is given in SHLP.
* If you do not change CALLCONTROL-STEP, the next step is the
* dialog, to select one of the elementary searchhelps.
* If you want to skip this dialog, you have to return the selected
* elementary searchhelp in SHLP and to change CALLCONTROL-STEP to
* either to 'PRESEL' or to 'SELECT'.
  IF callcontrol-step = 'SELONE'.
*   PERFORM SELONE .........
    EXIT.
  ENDIF.

*"----------------------------------------------------------------------
* STEP PRESEL  (Enter selection conditions)
*"----------------------------------------------------------------------
* This step allows you, to influence the selection conditions either
* before they are displayed or in order to skip the dialog completely.
* If you want to skip the dialog, you should change CALLCONTROL-STEP
* to 'SELECT'.
* Normaly only SHLP-SELOPT should be changed in this step.
  IF callcontrol-step = 'PRESEL'.
*   PERFORM PRESEL ..........
    EXIT.
  ENDIF.
*"----------------------------------------------------------------------
* STEP SELECT    (Select values)
*"----------------------------------------------------------------------
* This step may be used to overtake the data selection completely.
* To skip the standard seletion, you should return 'DISP' as following
* step in CALLCONTROL-STEP.
* Normally RECORD_TAB should be filled after this step.
* Standard function module F4UT_RESULTS_MAP may be very helpfull in this
* step.

  IF callcontrol-step = 'SELECT'.

  " 3) Sadece ZEHO_T002'deki kodlar + T001'den karşılık gelen BUTXT
  SELECT DISTINCT a~bukrs
                  b~butxt
    FROM zeho_t002 AS a
    INNER JOIN t001     AS b
      ON a~bukrs = b~bukrs
    INTO TABLE lt_result
    WHERE a~mandt = sy-mandt.

  IF lt_result IS INITIAL.
    RAISE no_records.
  ENDIF.

  " 4) Her kaydı SEAHLPRES formatına çevir
  LOOP AT lt_result INTO ls_result.
    CLEAR ls_seahlpres.

    " F4 popup'ta görünen metin
    ls_seahlpres-string    = |{ ls_result-bukrs } { ls_result-butxt }|.
    ls_seahlpres-pack_no   = sy-tabix.
    ls_seahlpres-pack_kind = 'S'.

    APPEND ls_seahlpres TO record_tab.
  ENDLOOP.

  " 5) F4 listesi gösterilsin
  callcontrol-step = 'DISP'.
  RETURN.



ENDIF.
IF callcontrol-step = 'RETURN'. " Kullanıcı seçim yaptıktan sonra

  DATA(lv_bukrs) = VALUE string( ).

  READ TABLE record_tab INDEX 1 INTO DATA(ls_selected).
  IF sy-subrc = 0.
    " Seçilen değeri al
    SPLIT ls_selected-string AT space INTO lv_bukrs DATA(dummy).
    " Hafızaya yaz
    EXPORT lv_bukrs TO MEMORY ID 'Z_SELECTED_BUKRS'.
  ENDIF.
    ENDIF.
*  IF callcontrol-step = 'SELECT'.
*
*
*    " 3) Sadece ZEHO_T002'deki kodlar + T001'den karşılık gelen BUTXT
*    SELECT DISTINCT a~bukrs
*                    b~butxt
*      FROM zeho_t002 AS a
*      INNER JOIN t001     AS b
*        ON a~bukrs = b~bukrs
*      INTO TABLE lt_result
*      WHERE a~mandt = sy-mandt.
*
*    IF lt_result IS INITIAL.
*      RAISE no_records.
*    ENDIF.
*
*    " 4) Her kaydı SEAHLPRES formatına çevir
*    LOOP AT lt_result INTO ls_result.
*      CLEAR ls_seahlpres.
*
*      " F4 popup'ta görünen metin
*      ls_seahlpres-string    = |{ ls_result-bukrs } { ls_result-butxt }|.
*      " OPSİYONEL: sıra numarası
*      ls_seahlpres-pack_no   = sy-tabix.
*      " S = Search Help Result
*      ls_seahlpres-pack_kind = 'S'.
*
*      APPEND ls_seahlpres TO record_tab.
*    ENDLOOP.
*
*    " 5) Standart F4 listesi
*    callcontrol-step = 'DISP'.
*    RETURN.
*      DATA(lv_bukrs) = selected_record-bukrs.  " Kullanıcının seçtiği değer
*  EXPORT lv_bukrs TO MEMORY ID 'Z_SELECTED_BUKRS'.
*  ENDIF.
*"----------------------------------------------------------------------
* STEP DISP     (Display values)
*"----------------------------------------------------------------------
* This step is called, before the selected data is displayed.
* You can e.g. modify or reduce the data in RECORD_TAB
* according to the users authority.
* If you want to get the standard display dialog afterwards, you
* should not change CALLCONTROL-STEP.
* If you want to overtake the dialog on you own, you must return
* the following values in CALLCONTROL-STEP:
* - "RETURN" if one line was selected. The selected line must be
*   the only record left in RECORD_TAB. The corresponding fields of
*   this line are entered into the screen.
* - "EXIT" if the values request should be aborted
* - "PRESEL" if you want to return to the selection dialog
* Standard function modules F4UT_PARAMETER_VALUE_GET and
* F4UT_PARAMETER_RESULTS_PUT may be very helpfull in this step.
  IF callcontrol-step = 'DISP'.
*   PERFORM AUTHORITY_CHECK TABLES RECORD_TAB SHLP_TAB
*                           CHANGING SHLP CALLCONTROL.
    EXIT.
  ENDIF.
ENDFUNCTION.
