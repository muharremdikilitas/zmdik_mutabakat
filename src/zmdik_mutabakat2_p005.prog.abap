*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTABAKAT2_P005
*&---------------------------------------------------------------------*

module status_0100 output.
  set pf-status 'S_0100'.
  set titlebar 'TITLE_0100'.
endmodule.

module user_command_0100 input.
  case sy-ucomm.
    when '&BACK'.
      leave to screen 0.
  endcase.
endmodule.
*&---------------------------------------------------------------------*
*& Form set_fcat_sub
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_fcat_sub  USING    p_fieldname
                            p_seltext_l.


    clear gs_fcat.
  gs_fcat-fieldname = p_fieldname.
  gs_fcat-scrtext_l = p_seltext_l.
  append gs_fcat to gt_fcat.
ENDFORM.
