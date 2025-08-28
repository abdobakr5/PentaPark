#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include <Wire.h>
#include <Keypad.h>
#include <LiquidCrystal_I2C.h>
#include <ESP32Servo.h>
#include <PubSubClient.h>

// ---------- Pins ----------
#define IR_ENTRY   32
#define IR_EXIT    33
#define IR_SLOT1   34     // input-only pin (OK)
#define IR_SLOT2   35      // input-only pin (OK)
#define GAS_SENSOR 39      // input-only pin (ADC1_CH0)
#define temp_sensor 36
#define ledPin  2
#define buzzerPin  4


float R0 = 0.0;
// R_load is the load resistor on the MQ-2 module. It's usually 10kΩ.
const float R_load = 10.0; // In kΩ


bool entryDoorOpen = false;
bool exitDoorOpen = false;
bool ledOn = false;
bool buzzerOn = false;





// ---------- Peripherals ----------
LiquidCrystal_I2C lcd(0x27, 16, 2);  // change to 0x3F if your LCD uses that addr
Servo servoEntry, servoExit;

// ---------- WiFi ----------
const char* ssid       = "WE7C40D4";
const char* password   = "kb214227";

// ---------- MQTT (HiveMQ Cloud) ----------
const char* mqtt_server = "7d838d4406204b7798758a6bc4117f48.s1.eu.hivemq.cloud";
const uint16_t mqtt_port = 8883;      // TLS port
const char* mqtt_user   = "Ahmed"; // <-- REQUIRED
const char* mqtt_pass   = "Am1992005"; // <-- REQUIRED

WiFiClientSecure tlsClient;
PubSubClient client(tlsClient);


const char* supabase_url_base = "https://niajwjjmknwlbeybndbq.supabase.co"; // project ref domain
const char* supabase_anon_key =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5pYWp3ampta253bGJleWJuZGJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2NTg4NjUsImV4cCI6MjA3MDIzNDg2NX0.t9S41O5wqv4Y6_L9YIPus3Rr1LW2HOQR5f2KrRH27U8";

int last_entry_state = -1;
int last_exit_state  = -1;
int last_slot1       = -1;
int last_slot2       = -1;
float last_gas       = NAN;
int last_temp      = NAN;
float last_hum       = NAN;
bool alert_heat=true;
bool alert_gas=true;
unsigned long entPressTime=0;
unsigned long exPressTime=0;
unsigned long sensor_read_timer = 0;


const byte ROWS = 4;
const byte COLS = 4;
char keys[ROWS][COLS] = {
  {'1','2','3','A'},
  {'4','5','6','B'},
  {'7','8','9','C'},
  {'*','0','#','D'}
};
byte rowPins[ROWS] = {19, 18, 5, 23};
byte colPins[COLS] = {12, 13, 25, 26};
Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);


void setup_wifi() {
  Serial.println("Connecting to WiFi...");
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print('.');
  }
  Serial.print("\nWiFi connected. IP: ");
  Serial.println(WiFi.localIP());
}
float calibrateSensor() {
  const int calibration_samples = 50; // Use a large number of samples for a stable R0
  float sum_Rs = 0.0;
  for (int i = 0; i < calibration_samples; i++) {
    int rawADC = analogRead(GAS_SENSOR);
    float V_out = (float)rawADC / 4095.0 * 3.3;
    float Rs = ((3.3 * R_load) / V_out) - R_load;
    sum_Rs += Rs;

     delay(100); // Wait between samples
  }
  // R0 is the average Rs in clean air.
  float R0_avg = sum_Rs / (float)calibration_samples;

  // The datasheet for the MQ-2 shows that in clean air, the Rs/R0 ratio is around 9.8.
  // We can use this to get a more accurate R0 value.
  // R0 = Rs_in_clean_air / 9.8
  // This gives us a calibrated R0 based on a known reference point.
  return R0_avg / 9.8;
}
float readVoltage() {
  const int samples = 30; // Increased number of samples for better stability
  long sum = 0;
  for (int i = 0; i < samples; i++) {
    sum += analogRead(temp_sensor);
    delay(2); // Reduced delay to speed up the loop
  }
  float raw = sum / (float)samples;
  // Convert the 0-4095 raw reading to voltage (3.3V reference)
  float voltage = raw * (3.3 / 4095.0);
  return voltage;
}
void setup() {
  Serial.begin(115200);

  // I/O
  pinMode(IR_ENTRY, INPUT);
  pinMode(IR_EXIT,  INPUT);
  pinMode(IR_SLOT1, INPUT);
  pinMode(IR_SLOT2, INPUT);
  pinMode(GAS_SENSOR, INPUT);
  pinMode(temp_sensor, INPUT);
  pinMode(ledPin,OUTPUT);
  pinMode(buzzerPin,OUTPUT);


  // LCD
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0); lcd.print("Welcome to");
  lcd.setCursor(6, 1); lcd.print("Penta Park");


  // Servos
  servoEntry.attach(14);
  servoExit.attach(27);
  servoEntry.write(90);
  servoExit.write(0);
  R0 = calibrateSensor();

  // WiFi
  setup_wifi();

  // MQTT (TLS)
  tlsClient.setInsecure();      // quick start; use certificate for production
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}
// ---------- Supabase helper ----------
bool sendToSupabase(const char* tableName, const String& jsonPayload,
                    const char* method, const char* filter = "") {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi not connected. Cannot send to Supabase.");
    return false;
  }

  String url = String(supabase_url_base) + "/rest/v1/" + tableName;
  if (filter && strlen(filter) > 0) url += "?" + String(filter);

  WiFiClientSecure https;
  https.setInsecure(); // for quick start; replace with root CA for production

  HTTPClient http;
  if (!http.begin(https, url)) {
    Serial.println("HTTP begin() failed");
    return false;
  }

  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", supabase_anon_key);
  http.addHeader("Authorization", String("Bearer ") + supabase_anon_key);
  http.addHeader("Prefer", "return=minimal"); // reduce response size

  int code = -1;
  if (strcmp(method, "POST") == 0)       code = http.POST(jsonPayload);
  else if (strcmp(method, "PATCH") == 0) code = http.PATCH(jsonPayload);
  else                                   Serial.println("Unsupported HTTP method");

  if (code > 0) {
    Serial.printf("Supabase %s %s → HTTP %d\n", method, tableName, code);
  } else {
    Serial.printf("Supabase %s %s failed → %d (%s)\n",
                  method, tableName, code, http.errorToString(code).c_str());
  }
  http.end();
  return code >= 200 && code < 300;
}

void callback(char* topic, byte* payload, unsigned int length) {
  payload[length] = '\0';
  String message = String((char*)payload);

  Serial.print("📩 Topic: ");
  Serial.print(topic);
  Serial.print(" | Message: ");
  Serial.println(message);

  // -------- Entry Door --------
  if (String(topic) == "home/entrydoor") {
    if (message == "open") {
      servoEntry.write(0);   
      entryDoorOpen = true;
    } else {
      servoEntry.write(90);    
      entryDoorOpen = false;
    }
  }

  // -------- Exit Door --------
  else if (String(topic) == "home/exitdoor") {
    if (message == "open") {
      servoExit.write(90);    // افتح الباب
      exitDoorOpen = true;
    } else {
      servoExit.write(0);     // اقفل الباب
      exitDoorOpen = false;
    }
  }

  // -------- LED --------
  else if (String(topic) == "home/led") {
    ledOn = (message == "on");
    digitalWrite(ledPin, ledOn ? HIGH : LOW);
  }

  // -------- Buzzer --------
  else if (String(topic) == "home/buzzer") {
    buzzerOn = (message == "on");
    digitalWrite(buzzerPin, buzzerOn ? HIGH : LOW);
  }
}

void reconnect() {
  Serial.print("MQTT connecting...");
  String clientId = "ESP32ClientGarage-" + String((uint32_t)ESP.getEfuseMac(), HEX);
  if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass)) {
    Serial.println("connected");
    client.subscribe("garage/control");
    client.subscribe("home/entrydoor");
    client.subscribe("home/exitdoor");
    client.subscribe("home/led");
    client.subscribe("home/buzzer");
  } else {
    Serial.printf("failed, rc=%d. retry in 5s\n", client.state());
    delay(5000);
  } 
}

// ---------- Loop ----------
void loop() {
 if (!client.connected()) reconnect();
 client.loop();

  // Check for a key press
  char key = keypad.getKey();
  if (key == '#') {
    if (entPressTime == 0) {
      entPressTime = millis();
      Serial.println("Key # was pressed.");
      Serial.println(key);
    }
  } 

  if (key == '*') {
    if (exPressTime == 0) {
      exPressTime = millis();
      Serial.println("Key * was pressed.");
    }
  } 
  // Non-blocking sensor reading and data sending
  if (millis() - sensor_read_timer > 1500) { // Replaced delay(1500)
    sensor_read_timer = millis();

    // Read all sensors at the beginning of the timed interval
    int entry = digitalRead(IR_ENTRY);
    int exit_ = digitalRead(IR_EXIT);
    int slot1 = digitalRead(IR_SLOT1);
    int slot2 = digitalRead(IR_SLOT2);
    int gas_raw_value = analogRead(GAS_SENSOR);

    // Temp sensor calculation
    float v = readVoltage();
    int temp = v * 100.0;

    // GAS sensor calculation
    float V_out = (float)gas_raw_value / 4095.0 * 3.3;
    float Rs = ((3.3 * R_load) / V_out) - R_load;
    float ratio = Rs / R0;
    const float clean_air_ratio = 9.8;
    const float danger_air_ratio = 5.0;

    float cleanliness_percent = map(ratio * 100, danger_air_ratio * 100, clean_air_ratio * 100, 0, 100);
    if (cleanliness_percent > 100) {
      cleanliness_percent = 100;
    } else if (cleanliness_percent < 0) {
      cleanliness_percent = 0;
    }
    
    // Check for alerts and send to Supabase
    if ((temp > 40) && alert_heat) {
      alert_heat = false;
      DynamicJsonDocument doc(256);
      doc["alert_type"] = "over heat";
      String payload; serializeJson(doc, payload);
      sendToSupabase("alerts", payload, "POST");
    } else if (temp < 40) {
      alert_heat = true;
    }

    if (cleanliness_percent <= 50 && alert_gas) {
      alert_gas = false;
      DynamicJsonDocument doc(256);
      doc["alert_type"] = "gas leakage";
      String payload; serializeJson(doc, payload);
      sendToSupabase("alerts", payload, "POST");
    } else if (cleanliness_percent > 50) {
      alert_gas = true;
    }

    // Door and slot changes → POST
    if (entry != last_entry_state || exit_ != last_exit_state || last_slot1 != slot1 || last_slot2 != slot2) {
      last_entry_state = entry;
      last_exit_state = exit_;
      last_slot1 = slot1;
      last_slot2 = slot2;

      DynamicJsonDocument doc(256);
      doc["entry_status"] = entry ? "No Detection" : "Car Detected";
      doc["exit_status"] = exit_ ? "No Detection" : "Car Detected";
      doc["slot1"] = slot1 ? "Empty" : "Taken";
      doc["slot2"] = slot2 ? "Empty" : "Taken";
      String payload; serializeJson(doc, payload);
      sendToSupabase("doors_readings", payload, "POST");
    }

    // DHT valid & changed → POST
    if (temp != last_temp) {
      last_temp = temp;
      DynamicJsonDocument doc(256);
      doc["temperature"] = temp;
      String payload; serializeJson(doc, payload);
      sendToSupabase("heat_sensor", payload, "POST");
    }

    // GAS changed → POST
    if (cleanliness_percent != last_gas) {
      last_gas = cleanliness_percent;
      DynamicJsonDocument doc(256);
      doc["sensor_reading"] = cleanliness_percent;
      String payload; serializeJson(doc, payload);
      sendToSupabase("gas_sensor", payload, "POST");
    }
  }

  // Check if '#' key has been held for 2.5 seconds
  if (entPressTime > 0 && (millis() - entPressTime) >= 2500) {
    Serial.println("Key held: #");
    if (!entryDoorOpen) {
      servoEntry.write(0);
      client.publish("home/entrydoor", "open");
      entryDoorOpen = true;
      Serial.println("Entry door opened.");
    } else {
       servoEntry.write(90);
       client.publish("home/entrydoor", "close");
      entryDoorOpen = false;
      Serial.println("Entry door closed.");
    }
    entPressTime = 0;
  }

  // Check if '*' key has been held for 2.5 seconds
  if (exPressTime > 0 && (millis() - exPressTime) >= 2500) {
    Serial.println("Key held: *");
    if (!exitDoorOpen) {
       servoExit.write(90);
       client.publish("home/exitdoor", "open");
      exitDoorOpen = true;
      Serial.println("Exit door opened.");
    } else {
       servoExit.write(0);
       client.publish("home/exitdoor", "close");
      exitDoorOpen = false;
      Serial.println("Exit door closed.");
    }
    exPressTime=0;
}
}