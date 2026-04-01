const mongoose = require('mongoose');

const farmerLocationSchema = new mongoose.Schema(
    {
        farmerId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Farmer',
            required: [true, 'Farmer reference is required'],
            unique: true, // one location doc per farmer
        },
        location: {
            type: {
                type: String,
                enum: ['Point'],
                default: 'Point',
                required: true,
            },
            coordinates: {
                type: [Number], // [longitude, latitude]
                required: [true, 'Coordinates are required'],
            },
        },
        cropType: {
            type: [String],
            default: [],
        },
        resourcesAvailable: {
            type: [String],
            default: [],
            // e.g., ['tractor', 'harvester', 'seeds', 'irrigation_pump']
        },
        isVisible: {
            type: Boolean,
            default: true,
        },
    },
    {
        timestamps: true, // updatedAt tracks when location was last refreshed
    }
);

// ─── Geospatial 2dsphere index (REQUIRED for $near queries) ─
farmerLocationSchema.index({ location: '2dsphere' });

// ─── Compound index: crop+location for "nearby farmers growing wheat" ─
farmerLocationSchema.index({ cropType: 1, location: '2dsphere' });

// ─── Index: resources for sharing/rental queries ─
farmerLocationSchema.index({ resourcesAvailable: 1 });

// ─── Static: find nearby farmers ────────────────────
farmerLocationSchema.statics.findNearby = function (longitude, latitude, maxDistanceKm = 50) {
    return this.find({
        isVisible: true,
        location: {
            $near: {
                $geometry: {
                    type: 'Point',
                    coordinates: [longitude, latitude],
                },
                $maxDistance: maxDistanceKm * 1000, // convert km to meters
            },
        },
    }).populate('farmerId', 'name phoneNumber village district');
};

// ─── Static: find nearby farmers with specific crop ─
farmerLocationSchema.statics.findNearbyCropFarmers = function (longitude, latitude, cropType, maxDistanceKm = 50) {
    return this.find({
        isVisible: true,
        cropType: cropType,
        location: {
            $near: {
                $geometry: {
                    type: 'Point',
                    coordinates: [longitude, latitude],
                },
                $maxDistance: maxDistanceKm * 1000,
            },
        },
    }).populate('farmerId', 'name phoneNumber village district');
};

// ─── Static: find farmers sharing resources ─────────
farmerLocationSchema.statics.findResourceProviders = function (longitude, latitude, resource, maxDistanceKm = 30) {
    return this.find({
        isVisible: true,
        resourcesAvailable: resource,
        location: {
            $near: {
                $geometry: {
                    type: 'Point',
                    coordinates: [longitude, latitude],
                },
                $maxDistance: maxDistanceKm * 1000,
            },
        },
    }).populate('farmerId', 'name phoneNumber village district');
};

module.exports = mongoose.model('FarmerLocation', farmerLocationSchema);
