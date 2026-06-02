const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../config');

const farmerSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: [true, 'Name is required'],
            trim: true,
            maxlength: [100, 'Name cannot exceed 100 characters'],
            index: true,
        },
        phoneNumber: {
            type: String,
            required: [true, 'Phone number is required'],
            unique: true,
            match: [/^[6-9]\d{9}$/, 'Please provide a valid 10-digit Indian phone number'],
        },
        email: {
            type: String,
            unique: true,
            sparse: true, // allows multiple null values
            lowercase: true,
            match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please provide a valid email'],
        },
        passwordHash: {
            type: String,
            minlength: [6, 'Password must be at least 6 characters'],
            select: false, // never return in queries by default
        },
        village: {
            type: String,
            trim: true,
        },
        district: {
            type: String,
            trim: true,
            index: true,
        },
        state: {
            type: String,
            trim: true,
            index: true,
        },
        farmSize: {
            type: Number, // in acres
            min: [0, 'Farm size cannot be negative'],
        },
        cropTypes: {
            type: [String],
            default: [],
        },
        soilType: {
            type: String,
            enum: ['Red Soil', 'Black Soil', 'Alluvial Soil', 'Laterite Soil', 'Sandy Soil', 'Clay Soil', 'Other', null],
            default: null,
        },
        irrigationType: {
            type: String,
            enum: ['Drip', 'Sprinkler', 'Rainfed', 'Canal', 'Tube Well', 'Other', null],
            default: null,
        },
        preferredLanguage: {
            type: String,
            enum: ['en', 'hi', 'kn', 'te', 'ta', 'mr', 'gu', 'pa', 'bn', 'or'],
            default: 'en',
        },
        avatar: {
            type: String,
            default: 'default-avatar.png',
        },
        fcmToken: {
            type: String,
        },
        isVerified: {
            type: Boolean,
            default: false,
        },
        isActive: {
            type: Boolean,
            default: true,
        },
        lastLoginAt: {
            type: Date,
        },
    },
    {
        timestamps: true, // auto createdAt, updatedAt
        toJSON: { virtuals: true },
        toObject: { virtuals: true },
    }
);

// ─── Indexes for scale ──────────────────────────────
farmerSchema.index({ state: 1, district: 1 }); // location-based queries
farmerSchema.index({ cropTypes: 1 }); // filter by crop
farmerSchema.index({ createdAt: -1 }); // recent users

// ─── Virtual: full location string ──────────────────
farmerSchema.virtual('fullLocation').get(function () {
    return [this.village, this.district, this.state].filter(Boolean).join(', ');
});

// ─── Virtual: pest scans ────────────────────────────
farmerSchema.virtual('pestScans', {
    ref: 'PestScan',
    localField: '_id',
    foreignField: 'farmerId',
    justOne: false,
});

// ─── Virtual: community posts ───────────────────────
farmerSchema.virtual('posts', {
    ref: 'CommunityPost',
    localField: '_id',
    foreignField: 'farmerId',
    justOne: false,
});

// ─── Pre-save: hash password ────────────────────────
farmerSchema.pre('save', async function (next) {
    if (!this.isModified('passwordHash')) return next();
    const salt = await bcrypt.genSalt(12);
    this.passwordHash = await bcrypt.hash(this.passwordHash, salt);
    next();
});

// ─── Method: compare password ───────────────────────
farmerSchema.methods.matchPassword = async function (enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.passwordHash);
};

// ─── Method: generate JWT ───────────────────────────
farmerSchema.methods.getSignedJwtToken = function () {
    return jwt.sign(
        { id: this._id, phoneNumber: this.phoneNumber },
        config.jwt.secret,
        { expiresIn: config.jwt.expire }
    );
};

// ─── Static: find by phone ──────────────────────────
farmerSchema.statics.findByPhone = function (phoneNumber) {
    return this.findOne({ phoneNumber });
};

module.exports = mongoose.model('Farmer', farmerSchema);
