*&---------------------------------------------------------------------*
*& Report ZMDIK_P53
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P53.


class lcl_cat DEFINITION DEFERRED.
    class  lcl_bird DEFINITION DEFERRED.

  data : go_cat TYPE REF TO lcl_cat,
        go_bird type ref to lcl_bird.







class lcl_animal DEFINITION.
  PUBLIC SECTION.

  methods: get_number_of_legs RETURNING VALUE(rv_legs) type i,                  "export mantığında çalışır.
            get_number_of_arms RETURNING VALUE(rv_arms) TYPE i.

  data: mv_legs type i,
        mv_arms TYPE i.




  ENDCLASS.


  class lcl_animal IMPLEMENTATION.
    METHOD get_number_of_legs.
     rv_legs = mv_legs.

     ENDMETHOD.


     method get_number_of_arms.
       rv_arms = mv_arms.

       ENDMETHOD.

    ENDCLASS.


    class lcl_cat DEFINITION INHERITING FROM lcl_animal.
      PUBLIC SECTION.
      METHODS:
     constructor.




      ENDCLASS.



      class lcl_cat IMPLEMENTATION.
        method  constructor.
          super->constructor( ).                          "super diyince üst classtan bi metod kullanırız ve constructor metodunda üst classtaki constructoru çalıştırmak zorundayız.
        mv_legs = 4.
        mv_arms = 0.
        ENDMETHOD.

        ENDCLASS.





      class lcl_bird DEFINITION INHERITING FROM lcl_animal.
      PUBLIC SECTION.
      METHODS:
     constructor.




      ENDCLASS.



      class lcl_bird IMPLEMENTATION.
        method  constructor.
          super->constructor( ).                          "super diyince üst classtan bi metod kullanırız ve constructor metodunda üst classtaki constructoru çalıştırmak zorundayız.
        mv_legs = 2.
        mv_arms = 0.
        ENDMETHOD.

        ENDCLASS.



    START-OF-SELECTION.

    CREATE OBJECT go_cat.
CREATE OBJECT go_bird.

    WRITE: / 'cats arms' , go_cat->get_number_of_arms( ), 'and cat legs: ', go_cat->get_number_of_legs( ).
    WRITE: / 'birds arms' , go_bird->get_number_of_arms( ), 'and bird legs: ', go_bird->get_number_of_legs( ).

*    data(go_bird) = new lcl_bird.                "obje oluştur ve create etmenin birleşimi olur.
