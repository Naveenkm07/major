const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../config');

const userSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: [true, 'Please provide a name'],
            trim: true,
            maxlength: [100, 'Name cannot exceed 100 characters'],
        },
        email: {
            type: String,
            required: [true, 'Please provide an email'],
            unique: true,
            lowercase: true,
            match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please provide a valid email'],
        },
        phone: {
            type: String,
            required: [true, 'Please provide a phone number'],
            unique: true,
            match: [/^[6-9]\d{9}$/, 'Please provide a valid Indian phone number'],
        },
        password: {
            type: String,
            required: [true, 'Please provide a password'],
            minlength: [6, 'Password must be at least 6 characters'],
            select: false,
        },
        role: {
            type: String,
            enum: ['farmer', 'expert', 'admin'],
            default: 'farmer',
        },
        avatar: {
            type: String,
            default: 'default-avatar.png',
        },
        location: {
            state: { type: String, trim: true },
            district: { type: String, trim: true },
            village: { type: String, trim: true },
            coordinates: {
                type: { type: String, enum: ['Point'] },
                coordinates: [Number],
            },
        },
        farmDetails: {
            landArea: { type: Number }, // in acres
            soilType: { type: String },
            irrigationType: { type: String, enum: ['rainfed', 'irrigated', 'mixed'] },
            crops: [{ type: String }],
        },
        fcmToken: { type: String },
        isVerified: { type: Boolean, default: false },
        isActive: { type: Boolean, default: true },
    },
    {
        timestamps: true,
        toJSON: { virtuals: true },
        toObject: { virtuals: true },
    }
);

// Index for geospatial queries
userSchema.index({ 'location.coordinates': '2dsphere' });

// Hash password before save
userSchema.pre('save', async function (next) {
    if (!this.isModified('password')) return next();
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
});

// Compare password
userSchema.methods.matchPassword = async function (enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password);
};

// Generate JWT
userSchema.methods.getSignedJwtToken = function () {
    return jwt.sign({ id: this._id, role: this.role }, config.jwt.secret, {
        expiresIn: config.jwt.expire,
    });
};

module.exports = mongoose.model('User', userSchema);
