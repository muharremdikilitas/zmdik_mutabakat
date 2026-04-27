PROCESS BEFORE OUTPUT.
  module status_0100.
  module set_dynpro_screen.
  call SUBSCREEN sub1 INCLUDING sy-repid  gv_dynpro_num.


PROCESS AFTER INPUT.
   CALL SUBSCREEN sub1.
   module user_command_0100.
     MODULE islem.
     module proc_type.
