import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestRegressor
import pickle
import os
import sys

def train_model():
    try:
        # Load your training data
        df = pd.read_excel('data/Final_fyp_dataset.xlsx')
        
        # Convert all column names to lowercase for consistency
        df.columns = df.columns.str.lower()
        
        # Print available columns for debugging
        print("Available columns:", df.columns.tolist())
        
        # Define features and target
        feature_columns = [
            'Gender',
            'Customer_Login_Type',
            'Order_Priority',
            'Product',
            'Payment_Method'
        ]
        
        # Verify all required columns exist
        missing_columns = [col for col in feature_columns if col not in df.columns]
        if missing_columns:
            raise ValueError(f"Missing required columns: {missing_columns}")
            
        X = df[feature_columns]
        y = df['sales']
        
        # Create preprocessing pipeline
        categorical_features = feature_columns
        preprocessor = ColumnTransformer(
            transformers=[
                ('cat', OneHotEncoder(
                    sparse_output=False,
                    handle_unknown='ignore'
                ), categorical_features)
            ])
        
        # Create model pipeline
        model = Pipeline([
            ('preprocessor', preprocessor),
            ('regressor', RandomForestRegressor(
                n_estimators=100,
                random_state=42,
            ))
        ])
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        # Train model
        print("\nTraining model...")
        model.fit(X_train, y_train)
        
        # Evaluate model
        train_score = model.score(X_train, y_train)
        test_score = model.score(X_test, y_test)
        print(f"Train Score: {train_score:.4f}")
        print(f"Test Score: {test_score:.4f}")
        
        # Save model
        os.makedirs('models', exist_ok=True)
        with open('models/sales_model.pkl', 'wb') as f:
            pickle.dump(model, f)
            
        print("Model saved successfully!")
        
    except Exception as e:
        print(f"Error training model: {str(e)}")
        if 'df' in locals():
            print("DataFrame columns:", df.columns.tolist())
        raise

if __name__ == "__main__":
    train_model()