# Import the function from your model file
from crop_recommendor import get_final_recommendation

# --- Assume these are the inputs from your UI/API ---
district_input = 'Ahmednagar'
season_input = 'kharif'
temp_input = 26.0
rainfall_input = 200.0

# Call the function to get the final recommendation
final_recommendation_df = get_final_recommendation(district_input, season_input, temp_input, rainfall_input)

# Check if the result is not empty before printing
if not final_recommendation_df.empty:
    print("Final Top 5 Crop Recommendation:")
    print(final_recommendation_df.to_markdown(index=False))
else:
    print("Could not generate a recommendation based on the provided inputs.")