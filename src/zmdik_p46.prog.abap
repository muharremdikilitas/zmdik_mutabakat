*&---------------------------------------------------------------------*
*& Report ZMDIK_P46
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P46.


data: gv_fm__name type RS38L_FNAM,
      gs_controls type SSFCTRLOP,
      gs_output_opt TYPE SSFCOMPOP.



      gs_controls-no_dialog = 'X'.              "yaptğımız sayfa gelmeden önce pup op ekranı çıkmaması için yapılır.
      gs_controls-preview = 'X'.                "çıktımızın tasarım ettiğimiz ekranın dönmesi için
      gs_output_opt-tddest = 'LP01'.            "pop up ta görüntüle kısmı gibi

data: gv_currcode TYPE s_currcode.
data: gt_scarr type TABLE of scarr.

 SELECT-OPTIONS s_code for gv_currcode.

START-OF-SELECTION.

SELECT * from scarr into TABLE gt_scarr
  WHERE currcode in s_code.



CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname                 = 'ZMDIK_SF_0003'
*   VARIANT                  =
*   DIRECT_CALL              = ' '
 IMPORTING
   FM_NAME                  = gv_fm__name
* EXCEPTIONS
*   NO_FORM                  = 1
*   NO_FUNCTION_MODULE       = 2
*   OTHERS                   = 3
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.








CALL FUNCTION gv_fm__name                            "samrtforms çağırmak için
 EXPORTING
   CONTROL_PARAMETERS         = gs_controls
   OUTPUT_OPTIONS             =  gs_output_opt
   USER_SETTINGS              = ''                          "herhangi değişikliğin aktif olarak gözükmesi için.
      IT_SCARR                   = gt_scarr
 EXCEPTIONS
   FORMATTING_ERROR           = 1
   INTERNAL_ERROR             = 2
   SEND_ERROR                 = 3
   USER_CANCELED              = 4
   OTHERS                     = 5
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.
