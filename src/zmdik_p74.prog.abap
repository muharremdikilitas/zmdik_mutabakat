*&**********************************************************************
*&                         MDP Group                                   *
*&**********************************************************************
*&  Program : zmdik_p74                                                *
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
report zmdik_p74.

include zmdik_p74_i001.  "data definiations
include zmdik_p74_i002.  "selection screen
include zmdik_p74_i003.  "class

start-of-selection.
  create object go_report.
  go_report->prepare_alv( ).
