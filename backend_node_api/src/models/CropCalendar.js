const mongoose = require('mongoose');

const cropCalendarSchema = new mongoose.Schema(
    {
        cropName: {
            type: String,
            required: [true, 'Crop name is required'],
            trim: true,
            index: true,
        },
        stage: {
            type: String,
            required: [true, 'Growth stage is required'],
            trim: true,
            enum: [
                'land_preparation',
                'sowing',
                'germination',
                'vegetative',
                'flowering',
                'fruiting',
                'maturity',
                'harvesting',
                'post_harvest',
            ],
        },
        recommendedAction: {
            type: String,
            required: [true, 'Recommended action is required'],
        },
        fertilizerAdvice: {
            type: String,
            default: '',
        },
        irrigationAdvice: {
            type: String,
            default: '',
        },
        month: {
            type: Number,
            required: [true, 'Month is required'],
            min: 1,
            max: 12,
            index: true,
        },
        season: {
            type: String,
            enum: ['kharif', 'rabi', 'zaid', 'perennial'],
        },
        region: {
            type: String,
            trim: true,
        },
    },
    {
        timestamps: true,
    }
);

// ─── Indexes for scale ──────────────────────────────
cropCalendarSchema.index({ cropName: 1, month: 1 }); // crop schedule lookup
cropCalendarSchema.index({ month: 1, stage: 1 }); // what to do this month
cropCalendarSchema.index({ cropName: 1, stage: 1 }, { unique: true }); // no duplicate stages per crop

module.exports = mongoose.model('CropCalendar', cropCalendarSchema);
