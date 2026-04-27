*&---------------------------------------------------------------------*
*& Report ZMDIK_P026
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P026.


*TABLES: sflight.

*DATA: BEGIN OF wa_flight,
*        carrid TYPE sflight-carrid,
*        flights_count TYPE i,
*      END OF wa_flight.
*
*DATA: it_flights LIKE TABLE OF wa_flight.
*
*SELECT carrid,
*       COUNT( * ) AS flights_count
*  FROM sflight
*  GROUP BY carrid
*  INTO TABLE @it_flights.
*
*LOOP AT it_flights INTO wa_flight.
*  WRITE: / 'Havayolu:', wa_flight-carrid,
*          ' Uçuş Sayısı:', wa_flight-flights_count.
*ENDLOOP.

*DATA: BEGIN OF wa_capacity,
*        carrid TYPE sflight-carrid,
*        total_capacity TYPE i,
*      END OF wa_capacity.
*
*DATA: it_capacity LIKE TABLE OF wa_capacity.
*
*SELECT carrid,
*       SUM( seatsmax ) AS total_capacity
*  FROM sflight
*  GROUP BY carrid
*  INTO TABLE @it_capacity.
*
*LOOP AT it_capacity INTO wa_capacity.
*  WRITE: / 'Havayolu:', wa_capacity-carrid,
*          ' Toplam Kapasite:', wa_capacity-total_capacity.
*ENDLOOP.


TABLES: scarr, sflight.
START-OF-SELECTION.

DATA: it_scarr TYPE TABLE OF scarr,
      it_flight TYPE TABLE OF sflight,
      gs_flight TYPE sflight.

" SCARR tablosundan belirli hava yollarını alıyoruz
SELECT carrid
  FROM scarr
  INTO TABLE it_scarr
  WHERE carrname LIKE 'Lufthansa%' OR carrname LIKE 'Singapore%'.

" SFLIGHT tablosundan bu hava yollarına ait uçuş bilgilerini alıyoruz
IF it_scarr IS NOT INITIAL.
  SELECT *
    FROM sflight
    INTO TABLE it_flight
    FOR ALL ENTRIES IN it_scarr
    WHERE carrid = it_scarr-carrid. " Doğru eşleştirme
ENDIF.

" Uçuş bilgilerini yazdırıyoruz
LOOP AT it_flight INTO gs_flight.
  WRITE: / 'Havayolu:', gs_flight-carrid,
          ' Uçuş No:', gs_flight-connid,
          ' Fiyat:', gs_flight-price.
ENDLOOP.
