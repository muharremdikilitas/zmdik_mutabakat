method ONACTIONCALL_ANT_APPL .

 DATA : o_comp TYPE REF TO if_wd_component.

   "CALL API METHOD TO GET THE REFERENCE OF THE COMPONNET CONTROLLER

  CALL METHOD wd_comp_controller->wd_get_api

    RECEIVING

      result = o_comp.


  DATA : wdw_mgr TYPE REF TO  if_wd_window_manager.

  "CALL BELOW METHOD TO GET THE REFERENCE OF WINDOW MANAGER

  CALL METHOD o_comp->get_window_manager

    RECEIVING

      window_manager = wdw_mgr.   "Reference to Window Manager



  DATA : appl_url TYPE string.

  "CALL THIS METHOS TO GET THE URL OF THE WEB DYNPRO APPLICATION TO BE CALLED

  CALL METHOD cl_wd_utilities=>construct_wd_url

    EXPORTING

      application_name = 'ZWD_COMP_CALLED_APPL'   " Application

    IMPORTING

      out_absolute_url = appl_url.   "Absolute URL (Incl. Log, Host, Port)


  DATA : wdw TYPE REF TO if_wd_window.

  "CALL THE BELOW METHOD TO CRETAE A WINDOW BY PASSING THE URL

  CALL METHOD wdw_mgr->create_external_window

    EXPORTING


      url    = appl_url

    RECEIVING

      window = wdw.

"CALL BELOW METHOD TO OPEN THE WINDOW

  CALL METHOD wdw->open.



endmethod.

method WDDOAFTERACTION .
endmethod.

method WDDOBEFOREACTION .
*  data lo_api_controller type ref to if_wd_view_controller.
*  data lo_action         type ref to if_wd_action.

*  lo_api_controller = wd_this->wd_get_api( ).
*  lo_action = lo_api_controller->get_current_action( ).

*  if lo_action is bound.
*    case lo_action->name.
*      when '...'.

*    endcase.
*  endif.
endmethod.

method WDDOEXIT .
endmethod.

method WDDOINIT .
endmethod.

method WDDOMODIFYVIEW .
endmethod.

method WDDOONCONTEXTMENU .
endmethod.

