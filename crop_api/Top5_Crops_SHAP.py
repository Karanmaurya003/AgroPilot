import os
import pandas as pd
import numpy as np
import joblib
import json

# --- Emoji Mapping ---
emoji_mapping = {
    'rice': '🍚', 'maize': '🌽', 'chickpea': '🫘', 'kidneybeans': '🫘', 'pigeonpea': '🕊️',
    'mothbeans': '🫘', 'mungbean': '🌱', 'blackgram': '⚫', 'lentil': '🥣', 'pomegranate': '🍎',
    'banana': '🍌', 'mango': '🥭', 'grapes': '🍇', 'watermelon': '🍉', 'muskmelon': '🍈',
    'apple': '🍎', 'orange': '🍊', 'papaya': '🍈', 'coconut': '🥥', 'cotton': '☁️',
    'jute': '🌿', 'coffee': '☕'
}

# --- Base Directory ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# --- File Paths (relative to this script) ---
model_path = os.path.join(BASE_DIR, 'svc_poly_model.pkl')
scaler_path = os.path.join(BASE_DIR, 'scaler.pkl')
encoder_path = os.path.join(BASE_DIR, 'label_encoder.pkl')
dataset_path = os.path.join(BASE_DIR, 'datasets', 'Crop_recommendation.csv')

# --- Load Files ---
try:
    model = joblib.load(model_path)
    scaler = joblib.load(scaler_path)
    le = joblib.load(encoder_path)
    df_train_data = pd.read_csv(dataset_path)
    print("✅ All necessary files loaded successfully.")
except FileNotFoundError as e:
    print(f"❌ Error loading file: {e}")
    exit()

# --- Feature Setup ---
features = ['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']
X_train = df_train_data[features]
X_train_mean = X_train.mean().to_dict()

# --- Top 5 Recommendations ---
def get_top_5_recommendations(n, p, k, temperature, humidity, ph, rainfall):
    """
    Returns the top 5 crop recommendations and their confidence scores with emojis.
    """
    input_data = pd.DataFrame([[n, p, k, temperature, humidity, ph, rainfall]], columns=features)
    probabilities = model.predict_proba(scaler.transform(input_data))[0]
    top_5_indices = np.argsort(probabilities)[::-1][:5]
    
    recommendations = []
    for i in top_5_indices:
        crop_name = le.inverse_transform([i])[0]
        confidence = probabilities[i] * 100
        emoji = emoji_mapping.get(crop_name, '🌱')
        recommendations.append({
            "crop": crop_name,
            "confidence_score": confidence,
            "emoji": emoji
        })
    return recommendations

# --- Crop Detail with Explainability ---
def get_crop_details_with_explainability(n, p, k, temperature, humidity, ph, rainfall, crop_name):
    """
    Returns detailed explainability data for a specific crop with emoji.
    """
    input_data = pd.DataFrame([[n, p, k, temperature, humidity, ph, rainfall]], columns=features)
    probabilities = model.predict_proba(scaler.transform(input_data))[0]
    
    try:
        crop_index = list(le.classes_).index(crop_name)
        confidence = probabilities[crop_index] * 100
    except ValueError:
        return {"error": f"Crop '{crop_name}' not found in the model's classes."}
    
    positive_contributions = []
    negative_contributions = []
    
    for feature in features:
        input_value = input_data[feature].iloc[0]
        mean_value = X_train_mean[feature]
        if input_value > mean_value:
            positive_contributions.append(f"{feature} ({input_value:.2f} > avg)")
        elif input_value < mean_value:
            negative_contributions.append(f"{feature} ({input_value:.2f} < avg)")
    
    emoji = emoji_mapping.get(crop_name, '🌱')
    explanation = {
        "crop": crop_name,
        "confidence_score": confidence,
        "emoji": emoji,
        "positive_contributions": positive_contributions,
        "negative_contributions": negative_contributions
    }
    return explanation

# --- Example Local Test ---
if __name__ == "__main__":
    input_n = 50
    input_p = 51
    input_k = 36
    input_temp = 22.69
    input_humidity = 20
    input_ph = 34
    input_rainfall = 70
    
    top_5 = get_top_5_recommendations(input_n, input_p, input_k, input_temp, input_humidity, input_ph, input_rainfall)
    print("Main Page Output (for Flutter):")
    print(json.dumps(top_5, indent=2))
    
    selected_crop = 'muskmelon'
    details = get_crop_details_with_explainability(input_n, input_p, input_k, input_temp, input_humidity, input_ph, input_rainfall, selected_crop)
    print(f"\nDetail Page Output (for {selected_crop}):")
    print(json.dumps(details, indent=2))
