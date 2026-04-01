const mongoose = require('mongoose');

const weatherLogSchema = new mongoose.Schema(
    {
        location: {
            type: String,
            required: [true, 'Location is required'],
            trim: true,
            index: true,
        },
        coordinates: {
            lat: { type: Number },
            lon: { type: Number },
        },
        temperature: {
            type: Number,
            required: true,
        },
        humidity: {
            type: Number,
            required: true,
        },
        rainfall: {
            type: Number,
            default: 0,
        },
        description: {
            type: String,
            default: '',
        },
        windSpeed: {
            type: Number,
            default: 0,
        },
        pressure: {
            type: Number,
        },
        recommendation: {
            type: String,
            default: '',
        },
        timestamp: {
            type: Date,
            default: Date.now,
        },
    },
    { timestamps: true }
);

// Auto-delete logs older than 30 days
weatherLogSchema.index({ timestamp: 1 }, { expireAfterSeconds: 2592000 });

// Query: latest weather by location
weatherLogSchema.statics.getLatest = function (location) {
    return this.findOne({ location: { $regex: location, $options: 'i' } })
        .sort({ timestamp: -1 });
};

module.exports = mongoose.model('WeatherLog', weatherLogSchema);
