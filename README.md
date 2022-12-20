# Iron-Mini
A stupid thing I made for my car (a Mini One D R50). Reads the data from the CAN bus and display speed, rpm, fuel level and coolant temp.

<img src="https://user-images.githubusercontent.com/46404000/208539874-e32677b3-666e-4bea-aa5c-749cefd283f1.PNG" width="50%"/>
<img src="https://user-images.githubusercontent.com/46404000/208540430-9cbb8751-9b74-46d1-a3fe-88bddaa9b17f.png" width="50%"/>

## How to use
 * Upload `Captain_Americar` sketch to an Arduino board (I used an Arduino Mega + Ethernet shield + MCP2515 module)
 * Install Iron Mini app on an iPhone (with static ip 192.168.1.200 or update the sketch with another ip)
 * Put a modem in your car and connect both device (no internet needed).

Yes, you read that correctly, a freaking modem! Just remember to turn everything off or the car won't start next time 😉.

 <img src="https://user-images.githubusercontent.com/46404000/208545781-414a3571-f1ad-496b-bd98-2ec3356979a0.png" width="50%"/>
 
### Offline maps tiles
I know I souldn't download Google Maps tiles, but hey, for personal use nobody cares.
Use(?) `Iron Mini/Iron Mini/Tiles/download.sh` to download tiles for your region and `Iron Mini/Iron Mini/Tiles/TilesToSQLiteBlob.playground` to move them to a SQLite db.

### Things to fix
* Sometimes the connection is delayed.
* The speed is ~(±4%) off.
