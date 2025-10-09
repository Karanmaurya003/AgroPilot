# Save this code as 'crop_recommender.py'

import pandas as pd
import numpy as np

def get_final_recommendation(district_name_input, season_name_input, current_temp, current_rainfall):
    """
    Provides a final crop recommendation by combining historical yield and real-time
    weather data.
    
    Args:
        district_name_input (str): The name of the district.
        season_name_input (str): The name of the season.
        current_temp (float): The current temperature in Celsius.
        current_rainfall (float): The current rainfall in mm.
    
    Returns:
        A pandas DataFrame of the final top 5 recommended crops with a combined score.
    """
    
    # --- Step 1: Load and standardize datasets ---
    # The paths are relative to where the script is run.
    try:
        df_season = pd.read_csv('datasets\season-wise-crop.csv')
        df_weather = pd.read_excel('datasets\weather-wise-crop.xlsx')
    except (FileNotFoundError, pd.errors.ParserError) as e:
        # Return an empty DataFrame on error, so it can be handled by the caller
        return pd.DataFrame()

    # Standardize crop names
    season_mapping = {'arhar/tur': 'pigeonpea', 'gram': 'chickpea', 'moong': 'mungbean', 'urad': 'blackgram'}
    df_season['crop_name'] = df_season['crop_name'].map(season_mapping).fillna(df_season['crop_name'])
    weather_mapping = {'chickpea': 'chickpea', 'pigeonpea': 'pigeonpea', 'mungbean': 'mungbean', 'blackgram': 'blackgram'}
    df_weather['label'] = df_weather['label'].map(weather_mapping).fillna(df_weather['label'])

    # --- Step 2: Stage 1 - Get top 5 crops from the season dataset ---
    filtered_season_df = df_season[(df_season['district_name'] == district_name_input) & (df_season['season'] == season_name_input)]
    if filtered_season_df.empty:
        # If no season data is found, return an empty DataFrame
        return pd.DataFrame()
        
    yield_by_crop = filtered_season_df.groupby('crop_name')['yield'].mean().reset_index()
    top_5_season_crops = yield_by_crop.sort_values(by='yield', ascending=False).head(5).rename(columns={'crop_name': 'crop', 'yield': 'score'})

    # --- Step 3: Stage 2 - Get top crops from the weather dataset ---
    temp_bins = [0, 10, 20, 30, 40, 50]
    temp_labels = ['0-10C', '10-20C', '20-30C', '30-40C', '40-50C']
    rainfall_bins = [0, 50, 100, 150, 200, 250, 300]
    rainfall_labels = ['0-50mm', '50-100mm', '100-150mm', '150-200mm', '200-250mm', '250-300mm']

    df_weather['temp_bin'] = pd.cut(df_weather['temperature'], bins=temp_bins, labels=temp_labels, right=False)
    df_weather['rainfall_bin'] = pd.cut(df_weather['rainfall'], bins=rainfall_bins, labels=rainfall_labels, right=False)

    current_temp_bin = pd.cut([current_temp], bins=temp_bins, labels=temp_labels, right=False)[0]
    current_rainfall_bin = pd.cut([current_rainfall], bins=rainfall_bins, labels=rainfall_labels, right=False)[0]

    filtered_weather_df = df_weather[(df_weather['temp_bin'] == current_temp_bin) & (df_weather['rainfall_bin'] == current_rainfall_bin)]
    
    if filtered_weather_df.empty:
        return top_5_season_crops.rename(columns={'score': 'final_score'})
        
    weather_counts = filtered_weather_df['label'].value_counts()
    total_count = len(filtered_weather_df)
    weather_confidence = (weather_counts / total_count) * 100
    
    top_weather_crops = pd.DataFrame({
        'crop': weather_confidence.index,
        'score': weather_confidence.values
    })

    # --- Step 4: Combine and rank final results ---
    combined_scores = {}
    explanations = {}
    
    for index, row in top_weather_crops.iterrows():
        crop = row['crop']
        combined_scores[crop] = row['score']
        explanations[crop] = f"This crop has a strong historical success rate in conditions with a temperature of {current_temp:.1f}°C and rainfall of {current_rainfall:.1f}mm."

    for index, row in top_5_season_crops.iterrows():
        crop = row['crop']
        season_score = row['score'] * 10 
        
        if crop in combined_scores:
            combined_scores[crop] += season_score + 50
            explanations[crop] = f"The model highly recommends this crop because it has both high historical yield AND a high success rate in current weather conditions."
        else:
            combined_scores[crop] = season_score
            explanations[crop] = f"This crop is a top performer in your district with an average yield of {row['score']:.2f} tonnes/hectare."
    
    final_results = pd.DataFrame(combined_scores.items(), columns=['crop', 'final_score'])
    final_results['explanation'] = final_results['crop'].map(explanations)
    
    # --- Adding Emojis ---
    emoji_mapping = {
        'rice': '🍚', 'maize': '🌽', 'chickpea': '🫘', 'kidneybean': '🫘', 'pigeonpea': '🕊️', 'mothbeans': '🫘',
        'mungbean': '🌱', 'blackgram': '⚫', 'lentil': '🥣', 'pomegranate': '🍎', 'banana': '🍌', 'mango': '🥭',
        'grapes': '🍇', 'watermelon': '🍉', 'muskmelon': '🍈', 'apple': '🍎', 'orange': '🍊', 'papaya': '🍈',
        'coconut': '🥥', 'cotton': '☁️', 'jute': '🌿', 'coffee': '☕', 'bajra': '🌾', 'groundnut': '🥜',
        'jowar': '🌽', 'niger seed': '🌻', 'ragi': '🌾', 'sesamum': '🫘', 'soyabean': '🫘', 'sunflower': '🌻',
        'wheat': '🌾', 'other pulses': '🫘', 'other cere': '🌾', 'other oilse': '🫘'
    }
    final_results['emoji'] = final_results['crop'].map(emoji_mapping)

    return final_results.sort_values(by='final_score', ascending=False).head(5)