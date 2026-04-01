const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
    {
        farmerId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Farmer',
            required: [true, 'Farmer reference is required'],
            index: true,
        },
        title: {
            type: String,
            required: [true, 'Notification title is required'],
            maxlength: [200, 'Title cannot exceed 200 characters'],
        },
        message: {
            type: String,
            required: [true, 'Notification message is required'],
            maxlength: [1000, 'Message cannot exceed 1000 characters'],
        },
        type: {
            type: String,
            enum: [
                'disease_alert',
                'market_update',
                'weather_warning',
                'scheme_update',
                'community_activity',
                'system',
                'reminder',
            ],
            required: [true, 'Notification type is required'],
            index: true,
        },
        readStatus: {
            type: Boolean,
            default: false,
        },
        metadata: {
            // Optional link to related entity
            entityType: { type: String }, // 'pest_scan', 'market_price', 'scheme', 'post'
            entityId: { type: mongoose.Schema.Types.ObjectId },
        },
    },
    {
        timestamps: true, // createdAt acts as notification timestamp
    }
);

// ─── Indexes for scale ──────────────────────────────
notificationSchema.index({ farmerId: 1, readStatus: 1, createdAt: -1 }); // unread notifications
notificationSchema.index({ farmerId: 1, createdAt: -1 }); // all notifications feed
notificationSchema.index({ type: 1, createdAt: -1 }); // notifications by type

// ─── TTL: auto-delete read notifications after 30 days ─
// We don't TTL all notifications, but you could add conditional logic
notificationSchema.index({ createdAt: 1 }, { expireAfterSeconds: 7776000 }); // 90 days

// ─── Static: mark all as read for a farmer ──────────
notificationSchema.statics.markAllRead = function (farmerId) {
    return this.updateMany(
        { farmerId, readStatus: false },
        { $set: { readStatus: true } }
    );
};

// ─── Static: unread count ───────────────────────────
notificationSchema.statics.getUnreadCount = function (farmerId) {
    return this.countDocuments({ farmerId, readStatus: false });
};

module.exports = mongoose.model('Notification', notificationSchema);
