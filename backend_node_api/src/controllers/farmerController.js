/**
 * Farmer Controller
 * Public directory of farmers based on location.
 */
const Farmer = require('../models/Farmer');
const { ApiError, asyncHandler } = require('../utils/helpers');

// @desc    Get nearby farmers within radius
// @route   GET /api/v1/farmers/nearby
// @access  Private
exports.getNearbyFarmers = asyncHandler(async (req, res) => {
    const { lat, lng, radius = 10 } = req.query; // radius in km

    if (!lat || !lng) {
        throw new ApiError(400, 'Latitude and longitude are required');
    }

    // Convert radius from km to radians for MongoDB geo-spatial queries
    // Earth radius is approx 6378.1 km
    const radiusInRadians = parseFloat(radius) / 6378.1;

    // We assume you have a 2dsphere index on location field in Farmer model
    // which was defined as: { type: 'Point', coordinates: [lng, lat] }
    // If not, we can do a simple haversine distance calc in JS for MVP

    const farmers = await Farmer.find({
        isActive: true,
        // Exclude self
        _id: { $ne: req.user.id },
        'location.coordinates': {
            $geoWithin: {
                $centerSphere: [[parseFloat(lng), parseFloat(lat)], radiusInRadians]
            }
        }
    })
        .select('name location village district state cropTypes phoneNumber resourcesAvailable')
        .lean();

    // Calculate exact distance for sorting (Haversine formula approximation)
    const toRad = x => x * Math.PI / 180;
    const R = 6371; // km
    const lat1 = parseFloat(lat);
    const lon1 = parseFloat(lng);

    const farmersWithDistance = farmers.map(f => {
        if (!f.location || !f.location.coordinates) return { ...f, distance: 0 };

        const lon2 = f.location.coordinates[0];
        const lat2 = f.location.coordinates[1];

        const dLat = toRad(lat2 - lat1);
        const dLon = toRad(lon2 - lon1);
        const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        const distance = R * c;

        return {
            ...f,
            distance: Number(distance.toFixed(1))
        };
    }).sort((a, b) => a.distance - b.distance);

    res.status(200).json({
        success: true,
        count: farmersWithDistance.length,
        radius: parseInt(radius),
        data: farmersWithDistance
    });
});
