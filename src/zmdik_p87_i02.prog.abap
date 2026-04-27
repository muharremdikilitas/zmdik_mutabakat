*&---------------------------------------------------------------------*
*& Include          ZMDIK_P86_I02
*&---------------------------------------------------------------------*


selection-screen begin of block blk1 with frame title text-001.

  select-options  : s_bukrs  for bkpf-bukrs matchcode object buk .
  parameters      : p_prdat  type zeho_t012-prdat obligatory .

selection-screen end of block blk1.

selection-screen begin of block blk2 with frame title text-002.

  select-options  : s_bankc  for ZMDIK_t002-bankc ,
                    s_hbkid  for ZMDIK_t002-hbkid ,
                    s_hktid  for ZMDIK_t002-hktid ,
                    s_bankn  for ZMDIK_t002-bankn ,
                    s_acctp  for ZMDIK_t002-acc_type .

selection-screen end of block blk2.

selection-screen begin of block blk3 with frame title text-001.

  parameters     : p_mail type c as checkbox.
  select-options : s_mail for adr6-smtp_addr no intervals .

selection-screen end of block blk3.
