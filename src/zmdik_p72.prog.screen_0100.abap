process before output.
  module status_0100.
  module set_dynpro_screen.
  call subscreen sub1 including sy-repid  gv_dynpro_num.
*  module clear_memory.



process after input.

  call subscreen sub1.

*  field gv_comp_code module user_command_0100.
*  field gv_doc_date module user_command_0100.
  module user_command_0100.
  module islem.
  module proc_type.
