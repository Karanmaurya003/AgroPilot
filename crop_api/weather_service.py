import requests
import os

# Your OpenWeatherMap API key
# Best practice is to load this from an environment variable.
API_KEY = "4dbc41b812e09d7531fc17cdcbec7082"

def get_weather_data(lat: float, lon: float):
    """
    Fetches the current temperature and 5-day rainfall forecast from the free OpenWeatherMap API.
    
    Args:
        lat (float): Latitude of the location.
        lon (float): Longitude of the location.
    
    Returns:
        tuple: A tuple containing the current temperature (float, in Celsius) and 
               the total 5-day rainfall (float, in mm).
               Returns (None, None) on error.
    """
    # Using the free 5 Day / 3 Hour Forecast API endpoint.
    # We set units to 'metric' for Celsius and mm.
    WEATHER_URL = f"https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API_KEY}&units=metric"
    
    try:
        response = requests.get(WEATHER_URL)
        response.raise_for_status()  # Raise HTTPError for bad responses
        data = response.json()
        
        # Get current temperature from the first forecast entry as a proxy
        current_temp = data['list'][0]['main']['temp']
        current_humidity = data['list'][0]['main']['humidity']
        
        # Calculate total 5-day rainfall by summing up 'rain.3h' for each entry
        total_rainfall = 0
        if 'list' in data:
            for entry in data['list']:
                total_rainfall += entry.get('rain', {}).get('3h', 0)
        
        return current_temp, current_humidity, total_rainfall
    except requests.exceptions.RequestException as e:
        print(f"Error during API call to 5 Day / 3 Hour Forecast API: {e}")
        return None, None, None
    except KeyError as e:
        print(f"Error parsing weather data: Missing key {e}. API response format may have changed or data is unavailable.")
        return None, None, None
# Save this code as 'app.py' in your crop_api folder

from flask import Flask, request, jsonify
from crop_recommender import get_final_recommendation
from weather_service import get_weather_data # Correctly import the function

app = Flask(__name__)

# This is the API endpoint your Flutter app will call
@app.route('/recommendations', methods=['POST'])
def recommendations():
    data = request.json
    
    # Print to confirm that a request has been received
    print("Received a request for recommendations.")
    
    lat = data.get('latitude')
    lon = data.get('longitude')
    
    if not lat or not lon:
        return jsonify({"error": "Latitude and longitude are required."}), 400
    
    # Call the get_weather_data function directly
    temp, humidity, rainfall = get_weather_data(lat, lon)
    
    # These would come from a different input screen
    district = 'Ahmednagar'
    season = 'kharif'
    
    # Call the crop recommender with dummy inputs
    final_recs = get_final_recommendation(district, season, temp, rainfall)
    
    return jsonify(final_recs.to_dict(orient='records'))

if __name__ == '__main__':
    # This will expose your API to the local network
    app.run(host='0.0.0.0', port=5000, debug=True)
# Example usage of the function
if __name__ == "__main__":
    # Example coordinates for Borivali, Mumbai, Maharashtra, India
    latitude = 19.23
    longitude = 72.86
    
    temp, humidity, rain = get_weather_data(latitude, longitude)
    
    if temp is not None and rain is not None:
        print(f"Current Weather for Borivali, Mumbai:")
        print(f"Temperature: {temp:.2f}°C")
        print(f"Humidity: {humidity}%")
        print(f"5-day Rainfall: {rain:.2f} mm")
    else:
        print("Failed to get weather data.")
