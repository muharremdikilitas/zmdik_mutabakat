*&---------------------------------------------------------------------*
*& Report ZMDIK_P004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P004.

.



DATA: name TYPE string,
      sname TYPE string,
      age TYPE i,
      bdate TYPE sy-datum,
      has_licnse TYPE char1.

PARAMETERS: p_name TYPE string,
            p_sname TYPE string,
            p_age TYPE i,
            p_bdate TYPE sy-datum,
            p_licnse RADIOBUTTON GROUP grp1 USER-COMMAND licnse,
            p_no_lic RADIOBUTTON GROUP grp1.

START-OF-SELECTION.


  name = p_name.
  sname = p_sname.
  age = p_age.
  bdate = p_bdate.


  IF p_licnse = 'X'.
    has_licnse = 'E'.
  ELSEIF p_no_lic = 'X'.
    has_licnse = 'H'.
  ENDIF.


  WRITE: / 'İsim: ', name,
         / 'Soyisim: ', sname,
         / 'Yaş: ', age,
         / 'Doğum Tarihi: ', bdate,
         / 'Ehliyet Durumu: ', has_licnse.
