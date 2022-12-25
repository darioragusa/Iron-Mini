#include "mcp2515_can.h"
#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>

#define MAX_DATA_SIZE 8
#define DEBUG false
#define DEBUG_SKIP false
#define SEND_INTERVAL 20

const int SPI_CS_PIN = 53;
const int CAN_INT_PIN = 2;
mcp2515_can CAN(SPI_CS_PIN); // Set CS pin

unsigned int localPort = 16344;
unsigned int   remPort = 16344;

byte mac[] = {0xBA, 0xDA, 0x55, 0xFF, 0x80, 0x00};
IPAddress      ip(192, 168, 1, 100);
IPAddress gateway(255, 255, 255, 0);
IPAddress    dest(192, 168, 1, 200);

EthernetUDP UDP;

void setup() {
  SERIAL_PORT_MONITOR.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);
  while (!SERIAL_PORT_MONITOR) {}
  digitalWrite(LED_BUILTIN, LOW);
  
  if (!DEBUG_SKIP) {
    while (CAN_OK != CAN.begin(CAN_1000KBPS)) {
      SERIAL_PORT_MONITOR.println(F("CAN init fail, retry..."));
      delay(100);
    }
  }
  SERIAL_PORT_MONITOR.println(F("CAN init ok!"));

  pinMode(2, INPUT); // Setting pin 2, MCP2515 /INT, to input mode  NB!!!!
  Ethernet.begin(mac, ip);
  UDP.begin(localPort);
  
  digitalWrite(LED_BUILTIN, HIGH);
}

uint32_t id;
uint8_t  type; // bit0: ext, bit1: rtr
uint8_t  len;
byte cdata[MAX_DATA_SIZE] = {0};
unsigned long time_now = 0;

uint8_t kmh = 0;
uint8_t fuel = 0;
uint8_t coolant = 0;
uint16_t rpm = 0;

void loop() {
#if !DEBUG_SKIP
  // check if data coming
  // if(!digitalRead(2)) { // If pin 2 is low, read receive buffer
  if (CAN_MSGAVAIL != CAN.checkReceive()) {
    return;
  }

  //unsigned long t = millis();
  // read data, len: data length, buf: data buf
  CAN.readMsgBuf(&len, cdata);

  if (len > 8) {
    return;
  }
    
  if (((CAN.isExtendedFrame() << 0) |
      (CAN.isRemoteRequest() << 1)) != 0) {
    return;
  }
    
  id = CAN.getCanId();

  switch (id) {
    case 339: // 00000153
      kmh = (uint8_t)(((cdata[2] * 256) + cdata[1]) / 128);
      break;
    case 790: // 00000316
      rpm = (uint16_t)((cdata[2] + (cdata[3] * 256)) / 6.4);
      break;
    case 809: // 00000329
      coolant = (uint8_t)((cdata[1] * 0.75) - 48.373);
      break;
    case 1555: // 00000613
      fuel = (uint8_t)((cdata[2] > 128) ? cdata[2] - 128 : cdata[2]);
      break;
    default:
      return;
      break;
  }
#endif

#if DEBUG
  char prbuf[32];
  sprintf(prbuf, "%08lX %02X %02X %02X %02X %02X %02X %02X %02X", (unsigned long)id, cdata[0], cdata[1], cdata[2], cdata[3], cdata[4], cdata[5], cdata[6], cdata[7]);
  SERIAL_PORT_MONITOR.println(prbuf);
#else
  unsigned char prbuf[5];
  prbuf[0] = kmh;
  prbuf[1] = rpm & 0x00FF;
  prbuf[2] = (rpm & 0xFF00) >> 8;
  prbuf[3] = coolant;
  prbuf[4] = fuel;
#endif

  if ((unsigned long)(millis() - time_now) > SEND_INTERVAL) {
    time_now = millis();
    UDP.beginPacket(dest, remPort);
    UDP.write(prbuf, sizeof(prbuf));
    UDP.endPacket();
  }
}
