FirmwareUploader ( � 2010 / ruby.gruena.net )
=============================================

Funktion
------------
�bertr�gt die Firmware �ber TCP/IP zum Drucker etc.

Warum ?
------------
Beispiel:

* Drucker HP LaserJet P1005 (keine interne Firmware) *

=> Drucker ben�tigt Firmware nach jedem Einschalten
=> Problem, wenn Drucker nicht direkt (parallel / USB) am Computer
   angeschlossen
   
Nutzung
-----------
Konfiguration in Datei  "config.txt"

    server  ... IP-Adresse oder Hostname des Servers etc.
    port    ... Portnummer des Servers etc.
    file    ... Firmware-Dateiname
                z.B.: "sihpP1005.dl" (f�r HP LJ P1005)

=>  Danach "upload.exe" starten
=>  Konfiguration wird gelesen
=>  Firmware wird �bertragen        

Test
-----------
Wenn bei Installation ausgew�hlt, l��t sich die Funktion lokal testen.

!!! In "config.txt" die Server-Adresse + Port (localhost / 91000)
NICHT ver�ndern !!!

=> "test_server.exe" starten => Konsole (cmd.exe) �ffnet sich
=> "upload.exe" starten
=> Server (in Konsole) meldet Empfang
=> neue Datei *.new im Pfad (Kopie von Firmware)
=> Konsole schlie�en
