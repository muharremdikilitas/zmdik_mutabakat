*&---------------------------------------------------------------------*
*& Report ZMDIK_P52
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P52.



class lcl_main DEFINITION DEFERRED.


  data: go_main1 type ref to lcl_main,
        go_main2 type ref to lcl_main,
        go_main3 type ref to lcl_main.

class lcl_main DEFINITION.
  PUBLIC SECTION.

  METHODS: constructor,
      do_process  IMPORTING  iv_pers_id    type char10
                             iv_pers_name type char20
                             iv_pers_age  type numc2.
  CLASS-METHODS:                                    "static tanımladığımız metodları böyle tanımlarız.
  class_constructor.


  data: mv_pers_id type char10,
        mv_pers_name TYPE char20.

  class-DATA: mv_pers_age type numc2,           "class data diyerek static hale çeviriyoruz ve static olduğunda hepsinde tek bir değer döner.
              mv_ttl_num type i.                    "bir kere değişken atadıktan sonra altına baika bir şey atasanda ilk atadığın sayıyı döner her zaman.

  ENDCLASS.




  class lcl_main IMPLEMENTATION.
    METHOD constructor.
      ENDMETHOD.


      METHOD class_constructor.                 "ilk objede class_constructor çalışır. static metodlarda sadece statik değişkenler kullanılabilir.
        mv_ttl_num = mv_ttl_num + 1.
      ENDMETHOD.




      METHOD do_process.
         mv_pers_id =   iv_pers_id  .
         mv_pers_name = iv_pers_name .
         mv_pers_age =  iv_pers_age .            "instance metodun içinde statik değişken tanımlayabiliriz.


        ENDMETHOD.
    ENDCLASS.



    START-OF-SELECTION.
    CREATE OBJECT: go_main1,
                  go_main2,
                  go_main3.

    go_main1->do_process(
      EXPORTING
        iv_pers_id   = '1000000001'
        iv_pers_name = 'Muharrem'
        iv_pers_age  = '30'
    ).


        go_main2->do_process(
      EXPORTING
        iv_pers_id   = '2000000001'
        iv_pers_name = 'ali'
        iv_pers_age  = '20'
    ).


        go_main3->do_process(
      EXPORTING
        iv_pers_id   = '3000000001'
        iv_pers_name = 'enes'
        iv_pers_age  = '21'
    ).

    write: / go_main1->mv_pers_id , go_main1->mv_pers_name, go_main1->mv_pers_age.
    write: / go_main2->mv_pers_id , go_main2->mv_pers_name, go_main2->mv_pers_age.
    write: / go_main3->mv_pers_id , go_main3->mv_pers_name, go_main3->mv_pers_age.

    WRITE: / 'total_num : ', go_main1->mv_ttl_num.
    WRITE: / 'total_num : ', go_main2->mv_ttl_num.
    WRITE: / 'total_num : ', go_main3->mv_ttl_num.
