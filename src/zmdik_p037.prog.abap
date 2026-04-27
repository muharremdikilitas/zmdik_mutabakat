*&---------------------------------------------------------------------*
*& Report ZMDIK_P037
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P037.

TABLES: zmdik_pers_t.


data: ls_customers TYPE zmdik_pers_t,
      lt_customers TYPE TABLE OF zmdik_pers_t.

PARAMETERS: p_custid TYPE zmdik_pers_t-pers_id OBLIGATORY.
START-OF-SELECTION.

SELECT SINGLE * from zmdik_pers_t into ls_customers
  WHERE  pers_id  = p_custid.

  WRITE: 'Tek Kayıt' , ls_customers-pers_id.

  SELECT * from zmdik_pers_t into TABLE lt_customers
    WHERE PERS_ID = 4 and PERS_CINS = 'E' .

    cl_demo_output=>display( lt_customers ).
