const mongoose = require('mongoose');

const equipmentSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Equipment name is required'],
        trim: true
    },
    type: {
        type: String,
        required: [true, 'Equipment type is required'],
        enum: ['Tractor', 'Harvester', 'Plough', 'Seeder', 'Sprayer', 'Other'],
        default: 'Other'
    },
    owner: {
        type: String,
        required: true
    },
    ownerName: {
        type: String,
        required: true
    },
    description: {
        type: String,
        trim: true
    },
    pricePerHour: {
        type: Number,
        required: [true, 'Price per hour is required']
    },
    availability: {
        type: Boolean,
        default: true
    },
    location: {
        village: String,
        district: String,
        state: String
    },
    contactPhone: {
        type: String,
        required: true
    },
    images: [String],
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Equipment', equipmentSchema);
