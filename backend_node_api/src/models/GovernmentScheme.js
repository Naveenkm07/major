const mongoose = require('mongoose');

const governmentSchemeSchema = new mongoose.Schema(
    {
        schemeName: {
            type: String,
            required: [true, 'Scheme name is required'],
            trim: true,
            unique: true,
        },
        description: {
            type: String,
            required: [true, 'Description is required'],
        },
        eligibility: {
            type: [String],
            default: [],
        },
        benefits: {
            type: [String],
            default: [],
        },
        applicationLink: {
            type: String,
            default: '',
        },
        ministry: {
            type: String,
            trim: true,
        },
        schemeType: {
            type: String,
            enum: ['central', 'state'],
            default: 'central',
        },
        targetState: {
            type: String,
            trim: true,
        },
        isActive: {
            type: Boolean,
            default: true,
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
governmentSchemeSchema.index({ schemeName: 'text', description: 'text' }); // full-text search
governmentSchemeSchema.index({ schemeType: 1, isActive: 1 }); // filter by type
governmentSchemeSchema.index({ targetState: 1 }); // state-specific schemes
governmentSchemeSchema.index({ lastUpdated: -1 }); // recently updated first

module.exports = mongoose.model('GovernmentScheme', governmentSchemeSchema);
