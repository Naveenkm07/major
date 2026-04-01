const mongoose = require('mongoose');

const marketPriceSchema = new mongoose.Schema(
    {
        cropName: {
            type: String,
            required: [true, 'Crop name is required'],
            trim: true,
            index: true,
        },
        marketName: {
            type: String,
            required: [true, 'Market/Mandi name is required'],
            trim: true,
        },
        pricePerKg: {
            type: Number,
            required: [true, 'Price is required'],
            min: [0, 'Price cannot be negative'],
        },
        trend: {
            type: String,
            enum: ['rising', 'falling', 'stable'],
            default: 'stable',
        },
        location: {
            state: { type: String, trim: true, index: true },
            district: { type: String, trim: true },
            coordinates: {
                type: { type: String, enum: ['Point'] },
                coordinates: [Number], // [longitude, latitude]
            },
        },
        lastUpdated: {
            type: Date,
            default: Date.now,
        },
    },
    {
        timestamps: true,
    }
);

// ─── Indexes for scale ──────────────────────────────
marketPriceSchema.index({ cropName: 1, 'location.state': 1, lastUpdated: -1 }); // crop+region queries
marketPriceSchema.index({ marketName: 1, cropName: 1 }); // mandi-specific lookups
marketPriceSchema.index({ 'location.coordinates': '2dsphere' }); // geo queries for nearest mandi
marketPriceSchema.index({ cropName: 'text', marketName: 'text' }); // full-text search

// ─── TTL: auto-delete prices older than 90 days ────
marketPriceSchema.index({ lastUpdated: 1 }, { expireAfterSeconds: 7776000 });

module.exports = mongoose.model('MarketPrice', marketPriceSchema);
