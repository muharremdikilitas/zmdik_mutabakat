*&---------------------------------------------------------------------*
*& Report ZMDIK_P55
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P55.

class lcl_cat DEFINITION DEFERRED.
  data: go_cat TYPE REF TO lcl_cat.





interface lif_animal.
  methods:
  get_number_of_arms RETURNING VALUE(rv_arms) TYPE i,
  get_number_of_legs RETURNING VALUE(rv_legs) TYPE i.



  data: mv_arms type i,
        mv_legs type i.


  ENDINTERFACE.





  class lcl_cat DEFINITION.
    PUBLIC SECTION.
  METHODS:
  constructor.
  interfaces lif_animal.                                "bunu yaparak interface yapısını bağlıyoruz.
                                                          "interfaceyi bir classa tanımladıysak onun içindeki bütün metodları kullanmamız gerekiyor.
    ENDCLASS.


    class lcl_cat IMPLEMENTATION.
      METHOD constructor.
        lif_animal~mv_legs = 4.                       "interfaceden bir yapı kullanıdığımız için burada interfacemizin adını başına yazıp öyle devam ediyoruz.
        lif_animal~mv_arms = 0.                           " - yerine araya ~ işareti koyarız.


        ENDMETHOD.

        METHOD lif_animal~get_number_of_arms.
          rv_arms = lif_animal~mv_arms.

          ENDMETHOD.

          METHOD lif_animal~get_number_of_legs.
            rv_legs = lif_animal~mv_legs.
            ENDMETHOD.

      ENDCLASS.



      START-OF-SELECTION.

      CREATE OBJECT go_cat.

      WRITE: 'cats legs', go_cat->lif_animal~get_number_of_legs( ), 'and cats arms' , go_cat->lif_animal~get_number_of_arms( ).
