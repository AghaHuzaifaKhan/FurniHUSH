import os
import sys

# Add the project root directory to Python path
root_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
sys.path.append(root_dir)

# Now we can import using the path from the root
from python.database.firebase_db import FirebaseDB

if __name__ == "__main__":
    db = FirebaseDB()
    db.initialize_inventory()
    print("Firebase DB initialized successfully!") 