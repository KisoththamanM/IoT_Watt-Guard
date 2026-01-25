#include <WiFi.h>
#include <PubSubClient.h>
#include "ACS712.h"

#define RELAY_PIN 26
#define CURRENT_PIN 32
ACS712 currentSensor(CURRENT_PIN, 5.0, 4095, 185);

const char* ssid = "WiFi";
const char* password = "********";
const char* mqtt_server = "broker.hivemq.com";

WiFiClient espClient;
PubSubClient client(espClient);

//For millis()
unsigned long lastSendTime = 0;
const unsigned long interval = 1000;

void setupWiFi(){
  WiFi.begin(ssid,password);
  while (WiFi.status()!= WL_CONNECTED){delay(500);}
  Serial.println("Wifi connected..........");
}

void mqttCallback(char* topic, byte* payload, unsigned int length){
  String message = "";
  for (int i = 0; i < length; i++){
    message += (char)payload[i];
  }
  if(String(topic) == "WattGuard/relay"){
    if(message == "ON"){
      digitalWrite(RELAY_PIN, LOW);
    }
    else if (message == "OFF"){
      digitalWrite(RELAY_PIN, HIGH);
    }
  }
}

void connectMQTT(){
  while(!client.connected()){
    if(client.connect("ESP32_WattGuard")){
      client.subscribe("WattGuard/relay");
    }
    else{delay(2000);}
  }
}

void setup(){
  Serial.begin(9600);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, HIGH); // Relay OFF initially

  setupWiFi();

  client.setServer(mqtt_server, 1883);
  client.setCallback(mqttCallback);

  //ACS712 Calibration
  Serial.println("Calibrating ACS712 at no load");
  delay(2000);
  currentSensor.autoMidPoint();
  Serial.println("Calibration done!");
}

void loop() {
  if (!client.connected()) {
    connectMQTT();
  }
  client.loop();

  unsigned long now = millis();
  if(now - lastSendTime >= interval){
    lastSendTime = now;
    float current = currentSensor.mA_AC()/1000.0;
    
    //Checking serial print
    Serial.print("Current: ");
    Serial.print(current, 3);
    Serial.println(" A");

    //Publish to MQTT
    char payload[10];
    dtostrf(current, 4, 3, payload);
    client.publish("WattGuard/current", payload);
  }
}