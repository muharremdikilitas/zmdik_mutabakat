FUNCTION ZMDP_FM005 .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"      DYNPFIELDS STRUCTURE  DYNPREAD OPTIONAL
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------



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

    " 1. Uygun yapı tanımı
    TYPES: BEGIN OF ty_result,
             bukrs TYPE zeho_t002-bukrs,
             bankc TYPE zeho_t002-bankc,
             hktid TYPE zeho_t002-hktid,
             iban  TYPE zeho_t002-iban,
             waers TYPE zeho_t002-waers,
           END OF ty_result.

    " 2. Bu yapıya göre dahili tablo
    DATA: lt_result     TYPE STANDARD TABLE OF ty_result,
          ls_result     TYPE ty_result,
          ls_seahlpres  TYPE seahlpres,
          lt_source_tab TYPE TABLE OF ddshretval,
          ls_retval     TYPE ddshretval.

    " 3. Bellekten değer al
    DATA: lv_bukrs TYPE string,
          lv_bankc TYPE string.
    IMPORT lv_bukrs FROM MEMORY ID 'Z_SELECTED_BUKRS'.
    IMPORT lv_bankc FROM MEMORY ID 'Z_SELECTED_BANKC'.

    " 4. Veriyi filtrele – 4 senaryo
    CLEAR lt_result.

    IF lv_bukrs IS NOT INITIAL AND lv_bankc IS NOT INITIAL.
      SELECT bukrs, bankc, hktid, iban, waers
        INTO TABLE @lt_result
        FROM zeho_t002
        WHERE bukrs = @lv_bukrs
          AND bankc = @lv_bankc.

    ELSEIF lv_bukrs IS NOT INITIAL AND lv_bankc IS INITIAL.
      SELECT bukrs, bankc, hktid, iban, waers
        INTO TABLE @lt_result
        FROM zeho_t002
        WHERE bukrs = @lv_bukrs.

    ELSEIF lv_bukrs IS INITIAL AND lv_bankc IS NOT INITIAL.
      SELECT bukrs, bankc, hktid, iban, waers
        INTO TABLE @lt_result
        FROM zeho_t002
        WHERE bankc = @lv_bankc.

    ELSE.
      SELECT bukrs, bankc, hktid, iban, waers
        INTO TABLE @lt_result
        FROM zeho_t002.
    ENDIF.

    " 5. Kayıt yoksa hata fırlat
    IF lt_result IS INITIAL.
      RAISE no_records.
    ENDIF.

DATA: lt_source_tab_groups TYPE STANDARD TABLE OF ddshretval,
      lt_group             TYPE STANDARD TABLE OF ddshretval.

*LOOP AT lt_result INTO ls_result.
*
*  CLEAR lt_group.
*
*  CLEAR ls_retval.
*  ls_retval-fieldname = 'BUKRS'.
*  ls_retval-fieldval  = ls_result-bukrs.
*  APPEND ls_retval TO lt_group.
*
*  CLEAR ls_retval.
*  ls_retval-fieldname = 'BANKC'.
*  ls_retval-fieldval  = ls_result-bankc.
*  APPEND ls_retval TO lt_group.
*
*  CLEAR ls_retval.
*  ls_retval-fieldname = 'HKTID'.
*  ls_retval-fieldval  = ls_result-hktid.
*  APPEND ls_retval TO lt_group.
*
*  CLEAR ls_retval.
*  ls_retval-fieldname = 'IBAN'.
*  ls_retval-fieldval  = ls_result-iban.
*  APPEND ls_retval TO lt_group.
*
*  CLEAR ls_retval.
*  ls_retval-fieldname = 'WAERS'.
*  ls_retval-fieldval  = ls_result-waers.
*  APPEND ls_retval TO lt_group.
*
*  " Her bir grup sonrasında tüm alanları tek seferde ana tabloya ekle
*  APPEND LINES OF lt_group TO lt_source_tab_groups.
*
*ENDLOOP.


    " Sonuçları map'le – doğru eşleştirme için structure boş
CALL FUNCTION 'F4UT_RESULTS_MAP'
  EXPORTING
    source_structure   = ''              " boş kalsın, SHLP kullanılsın
    apply_restrictions = ' '
  TABLES
    shlp_tab    = shlp_tab
    source_tab  = lt_result
    record_tab  = record_tab
  CHANGING
    shlp        = shlp
    callcontrol = callcontrol
  EXCEPTIONS
    OTHERS = 1.

    IF sy-subrc <> 0.
      " hata handling
    ENDIF.

    " 7. Ekrana göster
    callcontrol-step = 'DISP'.

  ENDIF.

IF callcontrol-step = 'RETURN'.


  EXIT.
ENDIF.


ENDFUNCTION.
