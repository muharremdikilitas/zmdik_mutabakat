*&---------------------------------------------------------------------*
*& Report ZMDIK_P56
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P56.
class: lcl_dog DEFINITION DEFERRED,
  lcl_cat DEFINITION DEFERRED,
  lcl_main DEFINITION DEFERRED.

  data: go_dog TYPE REF TO lcl_dog,
        go_cat TYPE REF TO lcl_cat,
        go_main TYPE REF TO lcl_main.





class lcl_animal DEFINITION ABSTRACT.
  PUBLIC SECTION.
  METHODS:
  get_type ABSTRACT,
  speak ABSTRACT.
  ENDCLASS.


class lcl_dog DEFINITION INHERITING FROM lcl_animal.
  PUBLIC SECTION.
  METHODS:
  get_type REDEFINITION,
  speak REDEFINITION.                           "redefinition etmek abstract metodumu kullanacağım demek.

  ENDCLASS.


  class lcl_dog IMPLEMENTATION.
    method get_type.
      WRITE: 'Dog'.
      ENDMETHOD.




    METHOD speak.
      WRITE: 'BARK'.

      ENDMETHOD.
    ENDCLASS.



    class lcl_cat DEFINITION INHERITING FROM lcl_animal.
  PUBLIC SECTION.
  METHODS:
  get_type REDEFINITION,
  speak REDEFINITION.                           "redefinition etmek abstract metodumu kullanacağım demek.

  ENDCLASS.


  class lcl_cat IMPLEMENTATION.
    method get_type.
      WRITE: 'cat'.
      ENDMETHOD.




    METHOD speak.
      WRITE: 'meow'.

      ENDMETHOD.
    ENDCLASS.


    class lcl_main DEFINITION.
      PUBLIC SECTION.
      methods: play IMPORTING io_animal TYPE REF TO lcl_animal.



      ENDCLASS.



      class lcl_main IMPLEMENTATION.
        method play.
          WRITE: 'The.'.
          io_animal->get_type( ).
          WRITE: 'says'.
          io_animal->speak( ).
          new-LINE.
          ENDMETHOD.


        ENDCLASS.


        START-OF-SELECTION.

CREATE OBJECT: go_dog,
               go_cat,
               go_main.


go_main->play( io_animal = go_dog ).
go_main->play( io_animal = go_cat ).
