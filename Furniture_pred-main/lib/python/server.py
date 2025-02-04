from unittest import result
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
from sklearn.preprocessing import ColumnTransformer, OneHotEncoder
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestRegressor

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Update model path to the correct location
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MODEL_PATH = os.path.join(BASE_DIR, 'lib', 'functions', 'models', 'sales_model.pkl')

# Increase maximum content length to 16MB
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

def load_model():
    try:
        app.logger.info(f'Attempting to load model from: {MODEL_PATH}')
        with open(MODEL_PATH, 'rb') as file:
            model = pickle.load(file)
            app.logger.info('Model loaded successfully')
            return model
    except Exception as e:
        app.logger.error(f'Error loading model: {str(e)}')
        try:
            # Retrain model with current scikit-learn version
            data = pd.read_csv('path/to/your/training_data.csv')
            categorical_features = ['gender', 'customer_login_type', 'order_priority', 'product', 'payment_method']
            
            # Use sparse_output instead of sparse for newer scikit-learn versions
            preprocessor = ColumnTransformer(
                transformers=[
                    ('cat', OneHotEncoder(drop='first', sparse_output=False), categorical_features)
                ])
            
            model = Pipeline([
                ('preprocessor', preprocessor),
                ('regressor', RandomForestRegressor(n_estimators=100, random_state=42))
            ])
            
            X = data[categorical_features]
            y = data['sales']
            model.fit(X, y)
            
            # Save the retrained model
            os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)
            with open(MODEL_PATH, 'wb') as f:
                pickle.dump(model, f)
                
            app.logger.info('Model retrained and saved successfully')
            return model
            
        except Exception as train_error:
            app.logger.error(f'Error retraining model: {str(train_error)}')
            return None

model = load_model()

def validate_columns(df):
    required_columns = {'gender', 'customer_login_type', 'order_priority', 'product', 'payment_method'}
    missing_columns = required_columns - set(df.columns)
    if missing_columns:
        raise ValueError(f"columns are missing: {missing_columns}")

@app.route('/upload', methods=['POST'])
def upload_file():
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file uploaded'}), 400
            
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
            
        if not file.filename.endswith('.csv'):
            return jsonify({'error': 'Only CSV files are allowed'}), 400

        # Read CSV file
        df = pd.read_csv(file)
        df.columns = df.columns.str.lower()
        validate_columns(df)
        
        # Define furniture keywords for filtering
        furniture_keywords = [
            'chair', 'table', 'bed', 'sofa', 'almirah', 'wardrobe', 
            'cabinet', 'shelf', 'desk', 'dresser'
        ]
        
        # Filter for furniture items
        df['product'] = df['product'].str.lower()
        furniture_mask = df['product'].str.contains('|'.join(furniture_keywords), case=False, na=False)
        furniture_df = df[furniture_mask]
        
        if furniture_df.empty:
            return jsonify({'error': 'No furniture items found in data'}), 400
            
        # Make predictions
        predictions = model.predict(furniture_df)
        
        # Calculate average predictions per product
        results = pd.DataFrame({
            'product': furniture_df['product'],
            'predicted_sales': predictions
        }).groupby('product')['predicted_sales'].mean()
        
        items = [{
            'name': name.title(),
            'predicted_sales': round(float(value), 2)
        } for name, value in results.items()]
        
        return jsonify({
            'message': 'File processed successfully',
            'items': sorted(items, key=lambda x: x['predicted_sales'], reverse=True)
        })

    except ValueError as ve:
        logger.error(f'Validation error: {str(ve)}')
        return jsonify({'error': str(ve)}), 400
    except Exception as e:
        logger.error(f'Error processing file: {str(e)}')
        return jsonify({'error': str(e)}), 500

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