#include <Arduino.h>

extern "C" int main(void) {
  pinMode(13, OUTPUT);

  while (true) {
    digitalWrite(13, HIGH);
    delay(500);
    digitalWrite(13, LOW);
    delay(500);
  }
}

