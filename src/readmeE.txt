FirmwareUploader ( � 2010 / ruby.gruena.net )
=============================================

Function
---------
Upload your firmware to printers etc. over TCP/IP

Why ?
------
Example:

* Printer HP LaserJet P1005 (no internal firmware) *

=> you have to load the firmware after switching on
=> you have problems when the printer is not connected directly to your
   machine / connected to printer server (samba, cups etc.)
   
Usage
------
Configuration inside "config.txt"

    server  ... IP address or host name
    port    ... Port number of server
    file    ... Firmware file name
                for example: "sihpP1005.dl" (for HP LJ P1005)

=>  then start "upload.exe", which looks inside you configuration and
    transmit the firmware file to server
        
Testing
---------
If selected during installation local testing is possible.

!!! Don't change in "config.txt" server + port (localhost / 91000) !!!

=> start "test_server.exe" => console (cmd.exe) opens
=> start "upload.exe"
=> server (inside console) shows message for receive
=> new file *.new inside progarm folder (copy of firmware)
=> close console
