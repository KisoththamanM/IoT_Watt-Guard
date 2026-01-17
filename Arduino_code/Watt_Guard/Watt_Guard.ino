#include <WiFi.h>
#include <PubSubClient.h>

#define RELAY_PIN 26

const char* ssid = "Wifi";
const char* password = "********";
const char* mqtt_server = "broker.hivemq.com";

WiFiClient espClient;
PubSubClient client(espClient);

void setupWiFi() {
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  String message = "";

  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  if (String(topic) == "iot/wattguard/relay") {
    if (message == "ON") {
      digitalWrite(RELAY_PIN, LOW);   // Relay ON
    }
    else if (message == "OFF") {
      digitalWrite(RELAY_PIN, HIGH);  // Relay OFF
    }
  }
}

void reconnectMQTT() {
  while (!client.connected()) {
    if (client.connect("esp32_wattguard")) {
      client.subscribe("iot/wattguard/relay");
    } else {
      delay(2000);
    }
  }
}

void setup() {
  Serial.begin(9600);

  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, HIGH); // Relay OFF initially

  setupWiFi();

  client.setServer(mqtt_server, 1883);
  client.setCallback(mqttCallback);
}

void loop() {
  if (!client.connected()) {
    reconnectMQTT();
  }
  client.loop();
}
