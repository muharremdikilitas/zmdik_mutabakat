*&---------------------------------------------------------------------*
*& Include          ZMDIK_P67_P001
*&---------------------------------------------------------------------*


tables: spfli, sflight, sbook.

data: BEGIN OF gs_flight_inf,
      carrid like spfli-carrid,
      connid like spfli-connid,
      countryfr like spfli-countryfr,
      cityfrom  like spfli-cityfrom,
      airpfrom  like  spfli-airpfrom,
      cityto    like  spfli-cityto,
      airpto   like   spfli-airpto,
      fltime    like  spfli-fltime,
      deptime   like   spfli-deptime,
      arrtime   like    spfli-arrtime,
      distance  like    spfli-distance,
      distid    like      spfli-distid,
      fltype    like      spfli-fltype,
      period    like      spfli-period,
      fldate    like      sflight-fldate,
      currency  like      sflight-currency,
      planetype like      sflight-planetype,
      seatsmax  like       sflight-seatsmax,
      seatsocc  like      sflight-seatsocc,
  end of gs_flight_inf.




  data: gt_flight_inf  like TABLE OF gs_flight_inf,
        gt_sbook       type table of sbook.


  data: gt_fieldcatalog type slis_t_fieldcat_alv,
        gs_fieldcatalog type slis_fieldcat_alv.


  data: gs_layout type slis_layout_alv.

  data: gv_number type char10 VALUE '0123456789'.
