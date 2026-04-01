const mongoose = require('mongoose');

const cropSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: [true, 'Crop name is required'],
            trim: true,
            index: true,
        },
        localName: { type: String, trim: true },
        category: {
            type: String,
            required: true,
            enum: ['cereal', 'pulse', 'oilseed', 'vegetable', 'fruit', 'spice', 'fiber', 'other'],
        },
        season: {
            type: String,
            required: true,
            enum: ['kharif', 'rabi', 'zaid', 'perennial'],
        },
        description: { type: String },
        growthDuration: { type: Number }, // days
        optimalConditions: {
            temperature: { min: Number, max: Number },
            rainfall: { min: Number, max: Number },
            soilType: [String],
            soilPh: { min: Number, max: Number },
        },
        calendar: [
            {
                stage: { type: String, required: true },
                startWeek: { type: Number, required: true },
                endWeek: { type: Number, required: true },
                activities: [String],
                tips: [String],
            },
        ],
        diseases: [
            {
                name: { type: String },
                symptoms: [String],
                treatment: [String],
                preventiveMeasures: [String],
                imageUrl: { type: String },
            },
        ],
        imageUrl: { type: String },
    },
    {
        timestamps: true,
    }
);

cropSchema.index({ name: 'text', localName: 'text' });

module.exports = mongoose.model('Crop', cropSchema);
