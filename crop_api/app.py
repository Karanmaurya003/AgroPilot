# Save this as crop_api/app.py

from flask import Flask, request, jsonify
from geopy.geocoders import Nominatim

# Import your internal modules
from weather_service import get_weather_data
from crop_recommender import get_final_recommendation
from Top5_Crops_SHAP import (
    get_top_5_recommendations,
    get_crop_details_with_explainability
)

import os

app = Flask(__name__)

# ----------------------------------------
# Root endpoint (helps avoid 404 at root)
# ----------------------------------------
@app.route('/')
def home():
    return jsonify({"message": "🌱 AgroPilot Backend is running successfully!"}), 200


# ----------------------------------------
# 1️⃣ Get weather and location details
# ----------------------------------------
@app.route('/get_weather_and_location', methods=['GET'])
def get_weather_and_location():
    lat = request.args.get('lat', type=float)
    lon = request.args.get('lon', type=float)

    if lat is None or lon is None:
        return jsonify({"error": "Latitude and longitude are required."}), 400

    try:
        # Get weather data
        temp, humidity, rainfall = get_weather_data(lat, lon)

        # Reverse geocoding
        geolocator = Nominatim(user_agent="agropilot")
        location = geolocator.reverse((lat, lon), language="en")

        location_data = {
            'district': location.raw['address'].get('city', '') or location.raw['address'].get('county', ''),
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

        return jsonify(response_data), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ----------------------------------------
# 2️⃣ Recommend crops (generic)
# ----------------------------------------
@app.route('/recommendations', methods=['POST'])
def recommendations():
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided."}), 400

    lat = data.get('latitude')
    lon = data.get('longitude')

    if lat is None or lon is None:
        return jsonify({"error": "Latitude and longitude are required."}), 400

    try:
        temp, humidity, rainfall = get_weather_data(lat, lon)

        district = 'Ahmednagar'  # you can change later to dynamic input
        season = 'kharif'

        final_recs = get_final_recommendation(district, season, temp, rainfall)

        return jsonify(final_recs.to_dict(orient='records')), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ----------------------------------------
# 3️⃣ With Lab Report
# ----------------------------------------
@app.route('/predict_lab_report', methods=['POST'])
def predict_lab_report():
    data = request.get_json()

    try:
        n = data['N']
        p = data['P']
        k = data['K']
        temperature = data['temperature']
        humidity = data['humidity']
        ph = data['ph']
        rainfall = data['rainfall']

        recommendations = get_top_5_recommendations(n, p, k, temperature, humidity, ph, rainfall)
        return jsonify({"recommendations": recommendations}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ----------------------------------------
# 4️⃣ Without Lab Report
@app.route('/predict_no_lab_report', methods=['POST'])
def predict_no_lab_report():
    data = request.get_json()
    print("\n🛰️ Incoming request to /predict_no_lab_report:", data)  # ADD THIS LINE

    try:
        district = data['district']
        season = data['season']
        temperature = data['temperature']
        rainfall = data['rainfall']

        print(f"📊 Inputs → District: {district}, Season: {season}, Temp: {temperature}, Rainfall: {rainfall}")

        final_recs = get_final_recommendation(district, season, temperature, rainfall)
        print(f"✅ get_final_recommendation returned {len(final_recs)} records")

        if final_recs.empty:
            return jsonify({"error": "No recommendations available"}), 404

        return jsonify(final_recs.to_dict(orient='records')), 200

    except Exception as e:
        print(f"❌ Error in /predict_no_lab_report: {e}")
        return jsonify({"error": str(e)}), 500

# ----------------------------------------
# 5️⃣ Crop details explainability
# ----------------------------------------
@app.route('/get_crop_details', methods=['POST'])
def get_crop_details():
    try:
        data = request.get_json()
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
        return jsonify({'error': str(e)}), 500


# ----------------------------------------
# Run the Flask app
# ----------------------------------------
if __name__ == '__main__':
    import os
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
