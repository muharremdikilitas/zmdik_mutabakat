*&---------------------------------------------------------------------*
*& Include          ZMDIK_P013_001
*&---------------------------------------------------------------------*



DATA: BEGIN Of gs_str,
  carrid TYPE scarr-carrid,
  carrname TYPE scarr-carrname,
  fldate type sflight-fldate,
  connid TYPE sflight-connid,
  url TYPE scarr-url,
  END OF gs_str.

  DATA: lt_it like TABLE OF gs_str.
