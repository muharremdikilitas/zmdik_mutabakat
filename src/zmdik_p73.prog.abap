*&**********************************************************************
*&                         MDP Group                                   *
*&**********************************************************************
*&  Program : zmdik_p73                                                *
*&  Version : 1.0                          Creation Date: 06.08.2025   *
*&  T.Code  : ZMM027                                                   *
*&  Author  : Muharrem Dikilitaş                                       *
*&**********************************************************************
*&  Program Description: Vodafone                                      *
*&                                                                     *
*&**********************************************************************
*&  Program - Changes                                                  *
*&  +-----------------------------------------------------------------+*
*&  | Code           | Programmer    | Title / Change                 |*
*&  +-----------------------------------------------------------------+*
*&  |                | mdik     | NEW                                 |*
*&  +-----------------------------------------------------------------+*
*&  Email : muharrem.dikiltas@mdpgroup.com                             *
************************************************************************
report zmdik_p73.

include zmdik_p73_i001.    "data definiations
include zmdik_p73_i002.    "select,on screen
include zmdik_p73_i003.    "class


start-of-selection.
  create object go_report.
  go_report->prepare_alv( ).
