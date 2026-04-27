*&---------------------------------------------------------------------*
*& Include          ZMDIK_P120_003
*&---------------------------------------------------------------------*


SELECT * FROM sflight into TABLE gt_it UP TO p_rows ROWS WHERE
  carrid in s_opt and connid in s_opt3.

WRITE : '   İnternal Table ' COLOR 6 INVERSE on,/'',' Kayıt Sırası' COLOR 6 INVERSE on,
          '     CARRID  ' COLOR 6 INVERSE   ,
          '   CONNID    ' COLOR 6 INVERSE on  .
  ULINE.
loop at gt_it into gs_st.
   WRITE : /'','Kayıt ',sayac LEFT-JUSTIFIED,sy-vline LEFT-JUSTIFIED ,
            gs_st-CARRID, '    ', sy-vline ,
            gs_st-CONNID CENTERED,'         ',
 sy-vline ,
         sy-uline  .
    sayac = sayac + 1 .
  endloop.
