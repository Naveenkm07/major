const mongoose = require('mongoose');

const pestScanSchema = new mongoose.Schema(
    {
        farmerId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Farmer',
            required: [true, 'Farmer reference is required'],
            index: true,
        },
        imageUrl: {
            type: String,
            required: [true, 'Scan image URL is required'],
        },
        cropType: {
            type: String,
            required: [true, 'Crop type is required'],
            trim: true,
            index: true,
        },
        diseaseDetected: {
            type: String,
            required: true,
            trim: true,
            default: 'healthy',
        },
        confidenceScore: {
            type: Number,
            required: true,
            min: 0,
            max: 1,
        },
        treatmentSuggestion: {
            type: String,
            default: '',
        },
        scanDate: {
            type: Date,
            default: Date.now,
            index: true,
        },
    },
    {
        timestamps: true,
    }
);

// ─── Indexes for scale ──────────────────────────────
pestScanSchema.index({ farmerId: 1, scanDate: -1 }); // farmer's recent scans
pestScanSchema.index({ diseaseDetected: 1, cropType: 1 }); // analytics queries
pestScanSchema.index({ cropType: 1, scanDate: -1 }); // crop-wise trends

// ─── TTL index: auto-delete scans older than 2 years ─
// Uncomment for production if storage is a concern:
// pestScanSchema.index({ scanDate: 1 }, { expireAfterSeconds: 63072000 });

module.exports = mongoose.model('PestScan', pestScanSchema);
