import time
import serial
import requests

# Initialize the serial connection
arduino_serial = serial.Serial('/dev/ttyACM0', 9600, timeout=1)

def read_and_send_data():
    while True:
        try:
            data = arduino_serial.readline().decode('utf-8', 'ignore').strip()
            if data:
                print(f"Data received from Arduino: {data}")
                if "temp:" in data and "humidity:" in data:
                    try:
                       
                        parts = data.split() 
                        temp_value = float(parts[0].split(":")[1])
                        humidity_value = float(parts[1].split(":")[1])
                    except (ValueError, IndexError) as e:
                        print("Error parsing data:", e)
                        continue
                    
                  
                    url = "https://api.thingspeak.com/update"
                    params = {
                        "api_key": "",  # Your ThingSpeak Write API key
                        "field1": temp_value,  # Temperature data
                        "field2": humidity_value  # Humidity data
                    }
                    
                    # Send the data to ThingSpeak
                    response = requests.get(url, params=params)
                    if response.status_code == 200:
                        print("Data successfully sent to ThingSpeak (temp to field1, humidity to field2).")
                    else:
                        print(f"Error sending data. Status code: {response.status_code}")
                        print(f"Error message: {response.text}")
                else:
                    print("No temperature and humidity data found in received data.")
            time.sleep(15)
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    read_and_send_data()
