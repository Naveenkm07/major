/**
 * Firebase Cloud Messaging Notification Service
 * Sends push notifications to farmers' devices.
 * Stores notifications in MongoDB for in-app notification history.
 */
const config = require('../config');
const Notification = require('../models/Notification');
const Farmer = require('../models/Farmer');
const logger = require('../utils/logger');

let firebaseAdmin = null;

// ─── Initialize Firebase Admin SDK ────────────────────
const initializeFirebase = () => {
    if (firebaseAdmin) return;

    try {
        const admin = require('firebase-admin');

        if (config.firebase.projectId && config.firebase.clientEmail && config.firebase.privateKey) {
            admin.initializeApp({
                credential: admin.credential.cert({
                    projectId: config.firebase.projectId,
                    clientEmail: config.firebase.clientEmail,
                    privateKey: config.firebase.privateKey,
                }),
            });
            firebaseAdmin = admin;
            logger.info('Firebase Admin SDK initialized');
        } else {
            logger.warn('Firebase credentials not configured. Push notifications disabled.');
        }
    } catch (error) {
        logger.error(`Firebase initialization failed: ${error.message}`);
    }
};

// Initialize on load
initializeFirebase();

// ═══════════════════════════════════════════════════════
// Send push notification to a single farmer
// ═══════════════════════════════════════════════════════
const sendToFarmer = async (farmerId, title, message, type = 'system', metadata = {}) => {
    // Save to DB (in-app notification)
    const notification = await Notification.create({
        farmerId,
        title,
        message,
        type,
        metadata,
    });

    // Send via FCM if available
    const farmer = await Farmer.findById(farmerId);
    if (farmer?.fcmToken && firebaseAdmin) {
        try {
            await firebaseAdmin.messaging().send({
                token: farmer.fcmToken,
                notification: { title, body: message },
                data: {
                    type,
                    notificationId: notification._id.toString(),
                    ...Object.fromEntries(
                        Object.entries(metadata).map(([k, v]) => [k, String(v)])
                    ),
                },
                android: {
                    priority: 'high',
                    notification: {
                        channelId: 'krushikadhara_alerts',
                        sound: 'default',
                    },
                },
            });
            logger.info(`FCM sent to farmer ${farmerId}: ${title}`);
        } catch (err) {
            logger.error(`FCM send failed for ${farmerId}: ${err.message}`);
            // Remove invalid token
            if (err.code === 'messaging/registration-token-not-registered') {
                await Farmer.findByIdAndUpdate(farmerId, { $unset: { fcmToken: 1 } });
            }
        }
    }

    return notification;
};

// ═══════════════════════════════════════════════════════
// Send push notification to multiple farmers
// ═══════════════════════════════════════════════════════
const sendToMultiple = async (farmerIds, title, message, type = 'system', metadata = {}) => {
    const results = [];
    for (const farmerId of farmerIds) {
        try {
            const notif = await sendToFarmer(farmerId, title, message, type, metadata);
            results.push({ farmerId, success: true, notificationId: notif._id });
        } catch (err) {
            results.push({ farmerId, success: false, error: err.message });
        }
    }
    return results;
};

// ═══════════════════════════════════════════════════════
// Broadcast to all farmers (or by filter)
// ═══════════════════════════════════════════════════════
const broadcast = async (title, message, type = 'system', filter = {}) => {
    const query = { isActive: true, ...filter };
    const farmers = await Farmer.find(query).select('_id').lean();
    const farmerIds = farmers.map((f) => f._id);

    logger.info(`Broadcasting "${title}" to ${farmerIds.length} farmers`);
    return sendToMultiple(farmerIds, title, message, type);
};

// ═══════════════════════════════════════════════════════
// Specialized notification senders
// ═══════════════════════════════════════════════════════
const sendWeatherAlert = async (location, message) => {
    const farmers = await Farmer.find({
        $or: [
            { district: { $regex: location, $options: 'i' } },
            { state: { $regex: location, $options: 'i' } },
        ],
        isActive: true,
    }).select('_id');

    return sendToMultiple(
        farmers.map((f) => f._id),
        '⛈️ Weather Alert',
        message,
        'weather_warning'
    );
};

const sendMarketAlert = async (crop, market, priceChange) => {
    const direction = priceChange > 0 ? 'increased' : 'decreased';
    const emoji = priceChange > 0 ? '📈' : '📉';
    const message = `${emoji} ${crop} prices ${direction} by ${Math.abs(priceChange)}% at ${market}.`;

    const farmers = await Farmer.find({
        cropTypes: { $regex: crop, $options: 'i' },
        isActive: true,
    }).select('_id');

    return sendToMultiple(
        farmers.map((f) => f._id),
        '💰 Market Price Alert',
        message,
        'market_update'
    );
};

const sendSchemeNotification = async (schemeName, description) => {
    return broadcast(
        '🏛️ New Government Scheme',
        `${schemeName}: ${description}`,
        'scheme_update'
    );
};

module.exports = {
    sendToFarmer,
    sendToMultiple,
    broadcast,
    sendWeatherAlert,
    sendMarketAlert,
    sendSchemeNotification,
};
