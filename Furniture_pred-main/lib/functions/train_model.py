import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestRegressor
from sklearn.pipeline import Pipeline
import pickle
import os

def train_and_save_model():
    try:
        # Load your training data
        data = pd.read_excel('functions/data/Final_fyp_dataset.xlsx')
        
        # Define features
        categorical_features = ['gender', 'customer_login_type', 'order_priority', 'product', 'payment_method']
        
        # Create preprocessing pipeline
        preprocessor = ColumnTransformer(
            transformers=[
                ('cat', OneHotEncoder(drop='first', sparse=False), categorical_features)
            ])
        
        # Create model pipeline
        model = Pipeline([
            ('preprocessor', preprocessor),
            ('regressor', RandomForestRegressor(n_estimators=100, random_state=42))
        ])
        
        # Split features and target
        X = data[categorical_features]
        y = data['sales']  # Replace with your target column
        
        # Train model
        model.fit(X, y)
        
        # Save model
        model_path = os.path.join(os.path.dirname(__file__), 'models', 'sales_model.pkl')
        os.makedirs(os.path.dirname(model_path), exist_ok=True)
        
        with open(model_path, 'wb') as f:
            pickle.dump(model, f)
            
        print(f"Model saved successfully at {model_path}")
        return True
        
    except Exception as e:
        print(f"Error training model: {str(e)}")
        return False

if __name__ == "__main__":
    train_and_save_model() 