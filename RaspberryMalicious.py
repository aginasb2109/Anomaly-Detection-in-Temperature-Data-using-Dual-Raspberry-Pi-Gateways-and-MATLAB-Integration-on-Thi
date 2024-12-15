import time
import serial
import requests
import random

# Initialize the serial connection
arduino_serial = serial.Serial('/dev/ttyACM0', 9600, timeout=1)

def malicious_data_manipulation(data):
    try:
        
        tampered_data = float(data) + random.uniform(50, 60)
        print(f"Original data: {data}, Maliciously tampered data: {tampered_data}")
        return str(tampered_data)
    except ValueError:
        print("Invalid data received from Arduino, cannot process.")
        return "0"  

def read_and_send_data():
    while True:
        try:
           
            data = arduino_serial.readline().decode('utf-8', 'ignore').strip()
            if data:
                print(f"Original data from Arduino: {data}")
                tampered_data = malicious_data_manipulation(data)
                
                # Prepare parameters for ThingSpeak API
                url = "https://api.thingspeak.com/update"
                params = {
                    "api_key": "",  #add you api write key
                    "field1": tampered_data  
                }

               
                response = requests.get(url, params=params)
                print(f"Malicious data sent to cloud, response: {response.status_code}")
            
            time.sleep(5) 
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    read_and_send_data()
