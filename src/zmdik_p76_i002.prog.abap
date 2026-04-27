*&---------------------------------------------------------------------*
*& Include          ZMDIK_P76_I002
*&---------------------------------------------------------------------*
tables: zeho_t600.
"--- Seçim ekranı (basit) ---
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
  SELECT-OPTIONS: s_bukrs FOR zeho_t600-bukrs,
                  s_bankc FOR zeho_t600-bankc,
                  s_bankn FOR zeho_t600-bankn,
                  s_prdat FOR zeho_t600-prdat.
SELECTION-SCREEN END OF BLOCK b1.

"--- Screen 0100 için PBO/PAI modülleri ---
DATA ok_code TYPE sy-ucomm.

MODULE status_0100 OUTPUT.
  " Şimdilik başlık/ALV kurmuyoruz. Class tarafını (I003) bitirince bağlayacağız.
  " Ekran Flow Logic’ine bu modülü PBO’da bağlayacaksın (aşağıda anlatıldı).
ENDMODULE.

MODULE user_command_0100 INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE PROGRAM.
    WHEN OTHERS.
      " RUN/REFR gibi komutları I003’te ekleyip burada işleyeceğiz.
  ENDCASE.
ENDMODULE.
