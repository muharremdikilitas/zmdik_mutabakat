*&---------------------------------------------------------------------*
*& Report ZMDIK_P54
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P54.

class lcl_animal DEFINITION DEFERRED.
class lcl_cat DEFINITION DEFERRED.

data: go_cat TYPE REF TO lcl_cat,
      go_animal TYPE REF TO lcl_animal.






class lcl_animal DEFINITION.
  public SECTION.
  METHODS: get_number_of_legs RETURNING VALUE(rv_legs) type i.


data: mv_legs type i.



PROTECTED SECTION.
 METHODS: get_number_of_arms RETURNING VALUE(rv_arms) type i.
data: mv_arms type i.
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

  methods:
  constructor.



  ENDCLASS.


class lcl_cat IMPLEMENTATION.
method constructor.
  super->constructor( ).
  mv_legs = 4.
  mv_arms = 0.
ENDMETHOD.


ENDCLASS.


    START-OF-SELECTION.

    CREATE OBJECT go_animal.
    CREATE OBJECT go_cat.


    write : go_animal->get_number_of_legs( ).
*   write : go_animal->get_number_of_arms( ).                 "protected yaptığında kendi ve alt classı içinde kullanıldı ama dışarıdan erişemedik.
*   write : go_animal->mv_arms.                                "privatede sadece kendi classında erişebiliriz.
   write : go_animal->mv_legs.



   write : go_cat->get_number_of_legs( ).
*   write : go_cat->get_number_of_arms( ).
*   write : go_cat->mv_arms.
   write : go_cat->mv_legs.
