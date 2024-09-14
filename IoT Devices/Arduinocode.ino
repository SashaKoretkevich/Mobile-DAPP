#include <ArduinoJson.h>
const int echo = 13;
const int trig = 12;
int duration = 0;
int distance = 0;
int potPin = A0; 
int greenLed = 5;
int redLed = 6;
int yellowLed = 7;
int potValue;
int percent;
int outputs [20];
int i = 0;
int maximum = 0;
void setup() 
{
  pinMode(trig, OUTPUT);
  pinMode(echo, INPUT);
  pinMode(greenLed, OUTPUT);
  pinMode(yellowLed, OUTPUT); 
  pinMode(redLed, OUTPUT);
  Serial.begin(9600);
}

void loop() 
{
  potValue = analogRead(potPin);
  percent = map(potValue, 0, 1023, 0, 100); 
  if (percent < 70) 
  {
      digitalWrite(greenLed, HIGH);
      digitalWrite(yellowLed, LOW); 
      digitalWrite(redLed, LOW); 
  } 
  else if(percent >= 70 && percent < 85)
  {
      digitalWrite(greenLed, LOW);
      digitalWrite(redLed, LOW); 
      digitalWrite(yellowLed, HIGH); 
  }
    else if(percent >= 85)
  {
      digitalWrite(greenLed, LOW);
      digitalWrite(yellowLed, LOW); 
      digitalWrite(redLed, HIGH); 
  }
  digitalWrite(trig, HIGH);
  delay(1000);
  digitalWrite(trig, LOW);
  duration = pulseIn(echo, HIGH);
  distance = (duration/2)/28.5;
  Serial.println(distance);
  
  Serial.println(percent);
  delay(1000); 
}