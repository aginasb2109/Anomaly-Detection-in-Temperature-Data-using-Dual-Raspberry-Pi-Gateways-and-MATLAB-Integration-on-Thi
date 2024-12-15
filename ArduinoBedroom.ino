#include <DHT.h>
#define DHTPIN 2
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);
void setup() {
 Serial.begin(9600);
 dht.begin();
}
void loop() {
 float temp = dht.readTemperature();
 if (!isnan(temp)) {
 Serial.println(temp);
 }
 delay(2000);
}