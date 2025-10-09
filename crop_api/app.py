# Save this code as 'app.py' in your crop_api folder
from flask import Flask, request, jsonify
from weather_service import get_weather_data
from crop_recommender import get_final_recommendation
from geopy.geocoders import Nominatim
# Import lab report recommender functions
from Top5_Crops_SHAP import get_top_5_recommendations, get_crop_details_with_explainability

app = Flask(__name__)

# This is the API endpoint your Flutter app will call
@app.route('/get_weather_and_location', methods=['GET'])
def get_weather_and_location():
    lat = request.args.get('lat', type=float)
    lon = request.args.get('lon', type=float)
    
    if not lat or not lon:
        return jsonify({"error": "Latitude and longitude are required."}), 400
    
    # 1. Get weather data from the OpenWeatherMap API
    temp, humidity, rainfall = get_weather_data(lat, lon)
    
    # 2. Perform reverse geocoding to get location name
    geolocator = Nominatim(user_agent="agropilot")
    location = geolocator.reverse((lat, lon), language="en")
    
    location_data = {
        'district': location.raw['address'].get('city', ''),
        'state': location.raw['address'].get('state', '')
    }
    

    response_data = {
        "weather": {
            "temperature": temp,
            "humidity": humidity,
            "rainfall": rainfall
        },
        "location": location_data
    }

    return jsonify(response_data)

@app.route('/recommendations', methods=['POST'])
def recommendations():
    data = request.json
    
    # Print to confirm that a request has been received
    print("Received a request for recommendations.")
    
    lat = data.get('latitude')
    lon = data.get('longitude')
    
    if not lat or not lon:
        return jsonify({"error": "Latitude and longitude are required."}), 400
    
    temp, humidity, rainfall = get_weather_data(lat, lon)
    
    # These would come from a different input screen
    district = 'Ahmednagar'
    season = 'kharif'
    
    final_recs = get_final_recommendation(district, season, temp, rainfall)
    
    return jsonify(final_recs.to_dict(orient='records'))
  
# --------------------------
# Case 1: With Lab Report
# --------------------------
@app.route('/predict_lab_report', methods=['POST'])
def predict_lab_report():
    data = request.json
    
    try:
        n = data['N']
        p = data['P']
        k = data['K']
        temperature = data['temperature']
        humidity = data['humidity']
        ph = data['ph']
        rainfall = data['rainfall']

        # Get top 5 crops
        recommendations = get_top_5_recommendations(n, p, k, temperature, humidity, ph, rainfall)
        return jsonify({"recommendations": recommendations})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# --------------------------
# Case 2: Without Lab Report
# --------------------------
@app.route('/predict_no_lab_report', methods=['POST'])
def predict_no_lab_report():
    data = request.json
    
    try:
        district = data['district']
        season = data['season']
        temperature = data['temperature']
        rainfall = data['rainfall']

        # Call your no-report recommender
        final_recs = get_final_recommendation(district, season, temperature, rainfall)

        if final_recs.empty:
            return jsonify({"error": "No recommendations available"}), 404

        return jsonify(final_recs.to_dict(orient='records'))
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500
@app.route('/get_crop_details', methods=['POST'])
def get_crop_details():
    """Get detailed explainability for specific crop"""
    try:
        data = request.json
        print(f"\n📥 Detail request for crop: {data.get('crop_name')}")
        
        n = float(data['N'])
        p = float(data['P'])
        k = float(data['K'])
        ph = float(data['ph'])
        temperature = float(data['temperature'])
        humidity = float(data['humidity'])
        rainfall = float(data['rainfall'])
        crop_name = data['crop_name']
        
        details = get_crop_details_with_explainability(
            n, p, k, temperature, humidity, ph, rainfall, crop_name
        )
        
        print(f"📤 Sending details for {crop_name}: {details['confidence_score']:.2f}%")
        return jsonify(details), 200
        
    except Exception as e:
        print(f"❌ Error in get_crop_details: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    import os
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
