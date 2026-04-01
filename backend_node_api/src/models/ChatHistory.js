const mongoose = require('mongoose');

const chatHistorySchema = new mongoose.Schema(
    {
        farmerId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Farmer',
            required: [true, 'Farmer reference is required'],
            index: true,
        },
        question: {
            type: String,
            required: [true, 'Question is required'],
        },
        answer: {
            type: String,
            required: [true, 'Answer is required'],
        },
        intent: {
            type: String,
            trim: true,
        },
        confidence: {
            type: Number,
            min: 0,
            max: 1,
        },
        language: {
            type: String,
            enum: ['en', 'hi', 'kn', 'te', 'ta', 'mr', 'gu', 'pa', 'bn', 'or'],
            default: 'en',
        },
        sessionId: {
            type: String,
            index: true,
        },
        timestamp: {
            type: Date,
            default: Date.now,
        },
    },
    {
        timestamps: true,
    }
);

// ─── Indexes for scale ──────────────────────────────
chatHistorySchema.index({ farmerId: 1, timestamp: -1 }); // farmer's chat history
chatHistorySchema.index({ farmerId: 1, sessionId: 1, timestamp: 1 }); // session replay
chatHistorySchema.index({ intent: 1, timestamp: -1 }); // analytics: popular intents

// ─── TTL: auto-delete chats older than 1 year ──────
chatHistorySchema.index({ timestamp: 1 }, { expireAfterSeconds: 31536000 });

// ─── Static: get recent sessions for a farmer ──────
chatHistorySchema.statics.getRecentSessions = function (farmerId, limit = 20) {
    return this.aggregate([
        { $match: { farmerId: new mongoose.Types.ObjectId(farmerId) } },
        { $sort: { timestamp: -1 } },
        {
            $group: {
                _id: '$sessionId',
                lastQuestion: { $first: '$question' },
                lastAnswer: { $first: '$answer' },
                lastTimestamp: { $first: '$timestamp' },
                messageCount: { $sum: 1 },
            },
        },
        { $sort: { lastTimestamp: -1 } },
        { $limit: limit },
    ]);
};

module.exports = mongoose.model('ChatHistory', chatHistorySchema);
