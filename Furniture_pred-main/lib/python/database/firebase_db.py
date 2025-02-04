from firebase_admin import firestore
from .firebase_config import initialize_firebase
from datetime import datetime
import time
import logging

logger = logging.getLogger(__name__)

class FirebaseDB:
    def __init__(self, max_retries=3):
        """Initialize Firebase database connection with retry logic"""
        self.max_retries = max_retries
        self.db = self._initialize_with_retry()
    
    def _initialize_with_retry(self):
        """Initialize Firebase with retry logic"""
        for attempt in range(self.max_retries):
            try:
                return initialize_firebase()
            except Exception as e:
                if attempt == self.max_retries - 1:
                    raise
                logger.warning(f"Connection attempt {attempt + 1} failed, retrying...")
                time.sleep(2 ** attempt)  # Exponential backoff
    
    def initialize_inventory(self):
        """Initialize the furniture inventory collection"""
        try:
            # Comprehensive furniture items with more details
            furniture_items = [
                {
                    "name": "Office Chair",
                    "category": "Chairs",
                    "price": 199.99,
                    "description": "Ergonomic office chair with lumbar support",
                    "stock": 50,
                    "created_at": datetime.now(),
                    "material": "Mesh and Metal",
                    "dimensions": "26W x 26D x 38H inches",
                    "color": "Black"
                },
                {
                    "name": "Executive Desk",
                    "category": "Tables",
                    "price": 399.99,
                    "description": "Large executive desk with drawers",
                    "stock": 30,
                    "created_at": datetime.now(),
                    "material": "Oak Wood",
                    "dimensions": "60W x 30D x 30H inches",
                    "color": "Brown"
                },
                {
                    "name": "Bookshelf",
                    "category": "Storage",
                    "price": 149.99,
                    "description": "5-tier bookshelf with adjustable shelves",
                    "stock": 40,
                    "created_at": datetime.now(),
                    "material": "Engineered Wood",
                    "dimensions": "32W x 12D x 72H inches",
                    "color": "Walnut"
                },
                {
                    "name": "Sofa",
                    "category": "Seating",
                    "price": 699.99,
                    "description": "3-seater comfortable sofa",
                    "stock": 25,
                    "created_at": datetime.now(),
                    "material": "Fabric",
                    "dimensions": "84W x 36D x 38H inches",
                    "color": "Gray"
                }
            ]
            
            # Add items to Firestore
            collection = self.db.collection('inventory')
            for item in furniture_items:
                collection.add(item)
            
            print(f"Successfully added {len(furniture_items)} furniture items")
            return True
            
        except Exception as e:
            print(f"Error initializing inventory: {str(e)}")
            return False
    
    def save_model_metrics(self, metrics):
        """Save model training metrics to Firebase"""
        try:
            metrics['recorded_at'] = datetime.now()
            doc_ref = self.db.collection('model_metrics').document()
            doc_ref.set(metrics)
            return True
        except Exception as e:
            print(f"Error saving metrics: {str(e)}")
            return False
    
    def get_inventory(self):
        """Retrieve all furniture items"""
        try:
            docs = self.db.collection('inventory').stream()
            return [doc.to_dict() for doc in docs]
        except Exception as e:
            print(f"Error retrieving inventory: {str(e)}")
            return []
    
    def update_stock(self, item_id, new_stock):
        """Update stock quantity for a furniture item"""
        try:
            doc_ref = self.db.collection('inventory').document(item_id)
            doc_ref.update({'stock': new_stock})
            return True
        except Exception as e:
            print(f"Error updating stock: {str(e)}")
            return False
    
    def save_predictions(self, predictions):
        """Save sales predictions to Firebase"""
        try:
            batch = self.db.batch()
            collection = self.db.collection('predictions')
            
            for pred in predictions:
                doc_ref = collection.document()
                batch.set(doc_ref, pred)
            
            batch.commit()
            return True
        except Exception as e:
            print(f"Error saving predictions: {str(e)}")
            return False
    
    def get_current_stock(self, item_name):
        """Get current stock for an item"""
        try:
            docs = self.db.collection('inventory').where('name', '==', item_name).limit(1).stream()
            for doc in docs:
                return doc.to_dict().get('stock', 0)
            return 0
        except Exception as e:
            print(f"Error getting stock: {str(e)}")
            return 0
    
    def update_current_stock(self, item_name, new_stock):
        """Update current stock for an item"""
        try:
            docs = self.db.collection('inventory').where('name', '==', item_name).limit(1).stream()
            for doc in docs:
                doc.reference.update({'stock': new_stock})
                return True
            return False
        except Exception as e:
            print(f"Error updating stock: {str(e)}")
            return False
    
    def save_stock_update(self, item_name, quantity, action_type):
        """Log stock updates"""
        try:
            self.db.collection('stock_updates').add({
                'item_name': item_name,
                'quantity': quantity,
                'action_type': action_type,
                'timestamp': datetime.now()
            })
            return True
        except Exception as e:
            print(f"Error logging stock update: {str(e)}")
            return False