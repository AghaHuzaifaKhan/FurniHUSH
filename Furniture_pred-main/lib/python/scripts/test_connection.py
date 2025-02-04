from database.firebase_db import FirebaseDB
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def test_connection():
    try:
        db = FirebaseDB()
        inventory = db.get_inventory()
        logger.info(f"Successfully connected to database. Found {len(inventory)} items.")
        return True
    except Exception as e:
        logger.error(f"Connection test failed: {str(e)}")
        return False

if __name__ == "__main__":
    test_connection() 