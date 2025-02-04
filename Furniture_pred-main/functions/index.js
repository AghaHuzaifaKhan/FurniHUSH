/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();

const app = express();
app.use(cors({ origin: true }));

// Predictions endpoint
app.post('/predictions', async (req, res) => {
  try {
    const db = admin.firestore();
    const predictions = await db.collection('predictions')
      .orderBy('timestamp', 'desc')
      .limit(1)
      .get();
    
    const data = predictions.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    res.json({ items: data });
  } catch (error) {
    logger.error('Prediction error:', error);
    res.status(500).json({ error: error.message });
  }
});

exports.api = functions.https.onRequest(app);
