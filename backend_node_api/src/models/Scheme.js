const mongoose = require('mongoose');

const schemeSchema = new mongoose.Schema(
    {
        title: {
            type: String,
            required: [true, 'Scheme title is required'],
            trim: true,
        },
        description: { type: String, required: true },
        ministry: { type: String, required: true, trim: true },
        type: {
            type: String,
            enum: ['central', 'state'],
            required: true,
        },
        state: { type: String, trim: true }, // null for central schemes
        eligibility: [String],
        benefits: [String],
        documents: [String],
        applicationProcess: { type: String },
        applicationUrl: { type: String },
        startDate: { type: Date },
        endDate: { type: Date },
        isActive: { type: Boolean, default: true },
        tags: [String],
    },
    {
        timestamps: true,
    }
);

schemeSchema.index({ title: 'text', description: 'text', tags: 'text' });

module.exports = mongoose.model('Scheme', schemeSchema);
