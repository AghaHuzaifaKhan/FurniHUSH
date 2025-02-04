from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
import pickle
import os
import logging
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Update model path to the correct location
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MODEL_PATH = os.path.join(BASE_DIR, 'lib', 'functions', 'models', 'sales_model.pkl')

def load_model():
    try:
        app.logger.info(f'Attempting to load model from: {MODEL_PATH}')
        with open(MODEL_PATH, 'rb') as file:
            model = pickle.load(file)
            app.logger.info('Model loaded successfully')
            return model
    except Exception as e:
        app.logger.error(f'Error loading model: {str(e)}')
        return None

model = load_model()

def validate_columns(df):
    required_columns = {'gender', 'customer_login_type', 'order_priority', 'product', 'payment_method'}
    missing_columns = required_columns - set(df.columns)
    if missing_columns:
        raise ValueError(f"columns are missing: {missing_columns}")

@app.route('/upload', methods=['POST'])
def upload_file():
    app.logger.info('Upload endpoint accessed')
    if not model:
        return jsonify({"error": "Model not loaded"}), 500
        
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        # Read the uploaded file
        df = pd.read_csv(file)
        df.columns = df.columns.str.lower()
        validate_columns(df)
        
        # Define furniture keywords for filtering
        furniture_keywords = [
            'chair', 'table', 'bed', 'sofa', 'almirah', 'wardrobe', 
            'cabinet', 'shelf', 'desk', 'dresser', 'dressing', 
            'stool', 'bench', 'couch', 'ottoman', 'bookcase',
            'sideboard', 'cupboard', 'chest', 'drawer', 'rack',
            'stand', 'unit', 'storage', 'furniture'
        ]
        
        # Filter for furniture items using keywords
        df['product'] = df['product'].str.lower()
        furniture_mask = df['product'].str.contains('|'.join(furniture_keywords), case=False, na=False)
        furniture_df = df[furniture_mask]
        
        if furniture_df.empty:
            return jsonify({"error": "No furniture items found in the data"}), 400
        
        # Make predictions for furniture items only
        predictions = model.predict(furniture_df)
        
        # Calculate average predictions per product
        products_df = pd.DataFrame({
            'product': furniture_df['product'],
            'predicted_sales': predictions
        })
        
        unique_products = products_df.groupby('product')['predicted_sales'].mean().reset_index()
        
        # Format items response with capitalized product names
        items = [{
            "name": row['product'].title(),
            "predicted_sales": round(float(row['predicted_sales']), 2)
        } for _, row in unique_products.iterrows()]
        
        # Sort items by predicted sales in descending order
        items.sort(key=lambda x: x['predicted_sales'], reverse=True)
        
        return jsonify({
            "message": "File processed successfully",
            "items": items
        }), 200
        
    except ValueError as ve:
        app.logger.error(f'Validation error: {str(ve)}')
        return jsonify({"error": str(ve)}), 400
    except Exception as e:
        app.logger.error(f'Upload error: {str(e)}')
        return jsonify({"error": str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    try:
        return jsonify({"status": "healthy"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        # Add your prediction logic here
        
        return jsonify({
            'success': True,
            'prediction': result
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True,
        threaded=True
    )