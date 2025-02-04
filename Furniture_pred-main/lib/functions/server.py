from flask import Flask, request, jsonify
import pandas as pd
import pickle
import os
import logging
from pathlib import Path
import traceback
from werkzeug.utils import secure_filename
import numpy as np
from concurrent.futures import ThreadPoolExecutor
from ..database.firebase_db import FirebaseDB

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB limit
executor = ThreadPoolExecutor(max_workers=3)

# Setup local storage
UPLOAD_FOLDER = Path(__file__).parent / 'uploads'
UPLOAD_FOLDER.mkdir(exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Initialize database
db = FirebaseDB()

def save_file_locally(file):
    """Save file to local storage"""
    filename = secure_filename(file.filename)
    file_path = UPLOAD_FOLDER / filename
    file.save(file_path)
    return file_path

@app.route('/upload', methods=['POST'])
def upload_file():
    try:
        logger.info("Starting file upload process")
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
            
        file = request.files['file']
        if not file or file.filename == '':
            return jsonify({'error': 'No file selected'}), 400

        # Process in smaller chunks
        df = pd.read_csv(file, chunksize=5000)
        df = pd.concat(df, ignore_index=True)
        
        # Process data and get predictions
        predictions = process_data(df)
        
        # Create item-specific predictions
        items_data = [
            {
                'name': 'Dining Table',
                'predicted_sales': round(float(predictions[0]), 2)
            },
            {
                'name': 'Chair',
                'predicted_sales': round(float(predictions[1]), 2)
            },
            {
                'name': 'Sofa',
                'predicted_sales': round(float(predictions[2]), 2)
            },
            {
                'name': 'Bed',
                'predicted_sales': round(float(predictions[3]), 2)
            },
            {
                'name': 'Wardrobe',
                'predicted_sales': round(float(predictions[4]), 2)
            }
        ]
        
        # Save predictions to Firebase
        prediction_id = db.save_prediction(items_data)
        
        response_data = {
            'status': 'success',
            'message': f'Generated predictions for {len(items_data)} items',
            'items': items_data,
            'prediction_id': prediction_id
        }
        
        logger.info(f"Sending response with predictions for {len(items_data)} items")
        return jsonify(response_data), 200
        
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        logger.error(traceback.format_exc())  # Add detailed error logging
        return jsonify({'error': str(e)}), 500

def process_data(df):
    """Process dataframe and return predictions"""
    try:
        logger.info("Starting data processing")
        df = preprocess_data(df)
        
        model_path = Path(__file__).parent / 'models' / 'sales_model.pkl'
        with open(model_path, 'rb') as f:
            model = pickle.load(f)
            
        predictions = model.predict(df)
        logger.info("Predictions generated successfully")
        return predictions
        
    except Exception as e:
        logger.error(f"Prediction error: {str(e)}")
        raise

def preprocess_data(df):
    """Preprocess data before prediction"""
    try:
        df = df.copy()
        
        # Convert column names to lowercase
        df.columns = df.columns.str.lower()
        
        # Required columns
        required_columns = [
            'Gender',
            'Customer_Login_type',
            'Order_Priority',
            'Product',
            'Payment_Method'
        ]
        
        # Check for missing columns
        missing_columns = set(required_columns) - set(df.columns)
        if missing_columns:
            raise ValueError(f"Missing columns: {missing_columns}")
        
        # Handle missing values
        df = df.dropna(subset=required_columns)
        
        # Basic text cleaning
        for col in required_columns:
            if df[col].dtype == 'object':
                df[col] = df[col].str.strip().str.title()
        
        # Convert 'Critical' to 'High' in order_priority
        df['Order_Priority'] = df['Order_Priority'].replace('Critical', 'High')
        
        return df[required_columns]  # Return only required columns
        
    except Exception as e:
        logger.error(f"Error in preprocessing: {e}")
        raise

# Add new endpoints for stock management
@app.route('/stock/update', methods=['POST'])
def update_stock():
    try:
        data = request.json
        item_name = data.get('item_name')
        quantity = data.get('quantity')
        action_type = data.get('action_type')
        
        db.update_current_stock(item_name, quantity)
        db.save_stock_update(item_name, quantity, action_type)
        
        return jsonify({'status': 'success'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/stock/current', methods=['GET'])
def get_stock():
    try:
        item_name = request.args.get('item_name')
        quantity = db.get_current_stock(item_name)
        
        return jsonify({
            'item_name': item_name,
            'quantity': quantity
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True,
        threaded=True,
        processes=1  # Use threading instead of multiprocessing
    )
