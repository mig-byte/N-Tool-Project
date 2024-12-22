::N-Tool Batch Script
 @echo off
	:: The echo function is used for many different reasons. In this instance it disables command echoing to keep the script output clean,
	:: Oherwise, the echo off command would be shown in the output.
	title N-Tool
	echo Loading and Displaying Network Stats

set /p refresh_rate= "Enter refresh rate in seconds. The default is 5 seconds: "
if "%refresh_rate%" == "" set refresh_rate=5
	::Allows user to set a refresh rate dynamically. The default refresh rate is 5 seconds.

:: This loop is what ensures that the netowrk tool can continously update the metrics and data in the output.	
 :loop

:: The following commands will retrieve and filter key network information using the 'netsh' command
:: Each command searches the output for specific data using 'find' and 'for' to extract and parse the relevant information.

for /f "tokens=2 delims=: " %%a in ('netsh wlan show interface ^| find "SSID" ^| findstr /v "BSSID"') do set ssid=%%a
	:: Finds and extracts network's SSID
for /f "tokens=2 delims=: " %%a in ('netsh wlan show interface ^| find "Description"') do set adapter=%%a
	:: Retrieves Network Interface Controller 'NIC' description
for /f "tokens=2 delims=: " %%a in ('netsh wlan show interface ^| find "State"') do set state=%%a
	:: Retrieves if connected or disconnected to the network
for /f "tokens=2 delims=: " %%a in ('netsh wlan show interface ^| find "Signal"') do set signal=%%a
	::Retrieves the signal strength of the network connection
for /f "tokens=2,3 delims=: " %%a in ('netsh wlan show interface ^| find "Band"') do set band=%%a
	::Retrieves the radio band (2.4 GHz, 5 GHz) being used for the connection

ping -n 3 8.8.8.8>%temp%\ping.txt
	:: Saves the ping results into a text file for later use, boosintg performance
	
for /f "tokens=4 delims== " %%a in ('type %TEMP%\ping.txt ^| find "Average"') do set ping=%%a
	:: Retrieves average ping time from the result file
for /f "tokens=10 delims= " %%a in ('type %TEMP%\ping.txt ^| find "Lost"') do set packet_loss=%%a
	:: Retrieves packet loss percentage from result file
	
for /f "tokens=3 delims= " %%a in ('netstat -e ^| find "Bytes"') do set received_bytes=%%a
for /f "tokens=3 delims= " %%a in ('netstat -e ^| find "Bytes"') do set sent_bytes=%%a
	::Retrieves number of received and sent bytes from netstat output
cls
	:: Clears the terminal output so following details may be displayed
		
echo  Network Details:
echo  ---------------------------
echo  SSID: %ssid%
echo  NIC: %adapter%
echo  State: %state%
echo  Signal: %signal%
echo  Band: %band%Ghz
	:: Displays network details: 
echo.
echo  Connection Metrics:
echo ---------------------------
echo Ping: %ping%
echo Received: %received_bytes% bytes
echo Sent: %sent_bytes% bytes
echo Packet Loss: %packet_loss% packets
	:: Displays connection metrics, wwhile being updated in real-time

timeout /t %refresh_rate% >nul
	:: Wait before the next refresh
	
goto loop
	:: Returns to beginning of the loop:

pause  
	::Prevents the window from closing immediately