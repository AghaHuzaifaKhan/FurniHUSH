import firebase_admin
from firebase_admin import credentials, firestore
import os
import logging

logger = logging.getLogger(__name__)

def initialize_firebase():
    """Initialize Firebase Admin SDK with credentials"""
    try:
        # Check if already initialized
        if len(firebase_admin._apps) > 0:
            return firestore.client()

        # Get the path to service account key
        cred_path = 'D:/SOFTWARE/Firebase DB/serviceAccountKey.json'
        
        if not os.path.exists(cred_path):
            raise FileNotFoundError(f"Firebase credentials not found at {cred_path}")
            
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred, {
            'projectId': 'furniture-sales-pred',
            'timeoutSeconds': 30,
        })
        
        # Get Firestore client
        db = firestore.client()
        return db
    except Exception as e:
        logger.error(f"Firebase initialization error: {str(e)}")
        raise